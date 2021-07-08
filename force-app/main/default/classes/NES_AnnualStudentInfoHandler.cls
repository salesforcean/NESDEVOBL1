/**
 * Created by triciaigoe on 11/29/18.
 * 05/11/19 -Removed logic for the waitlist calculator before insert(Anitha A)
 */

public with sharing class NES_AnnualStudentInfoHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('AnnualStudentInfoHandler');

    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('AnnualStudentInformationTrigger');
    static final Boolean highSchoolSwitch = NES_TriggerUtility.BusinessLogicSwitch('High School LTS Group');
    static final Boolean highSchoolLTSScoreSwitch = NES_TriggerUtility.BusinessLogicSwitch('High School LTS Score');
    static final Boolean whyFlagSwitch = NES_TriggerUtility.BusinessLogicSwitch('Why Flagged');
    static final Boolean waitlistFlagCalcSwitch = NES_TriggerUtility.BusinessLogicSwitch('Waitlist Flag Calculation');
    public static Boolean runCBL = true;

    public static void handleAfterInsert(List<Annual_Student_Information__c> newList, List<Annual_Student_Information__c> actList) {

        Boolean runCriteria = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;
        if (!logicSwitch) return;
        if (whyFlagSwitch) {
            NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actList, null); //Swapna:Changed to active list
        }
        //Swapna:Changed to active list
        NES_AnnualStudentInfoBusinessLogic.populateProgramEnroll_FinalGradeLevel(actList);
        NES_AnnualStudentInfoBusinessLogic.calculateELLFlag(actList, null);

        if (highSchoolSwitch) {
            NES_AnnualStudentInfoBusinessLogic.populatePEHighSchoolLTSGroup(actList, null); //Swapna:Changed to active list
        }

        if (highSchoolLTSScoreSwitch) {
            NES_AnnualStudentInfoBusinessLogic.populatecalculateHighSchoolLTS(actList, null); //Swapna:Changed to active list
        }

        NES_AnnualStudentInfoBusinessLogic.populateProgramGradeLevel(actList, null); //Swapna:Changed to active list 


        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Annual_Student_Information__c newObject = new Annual_Student_Information__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Annual_Student_Information__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Annual_Student_Information__c newInfo : actList) { //Swapna:Changed to active list

                List<String> changedFields = new List<String> ();
                for (String str : mapFields.keySet()) {
                    try {
                            changedFields.add(str);
                            
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;

                            newFieldUpdate.studentOrHousehold = 'Student';

                            fieldUpdateList.add(newFieldUpdate);
                    } catch(Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterInsert', e);
                        logger.saveLogs();
                    }
                }

                System.debug('fieldUpdateList:' + fieldUpdateList);

                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id> ();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Annual_Student_Information__c', peToObjectMap, fieldUpdateList);
        //}

    }

    public static void handleAfterUpdate(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap, Map<Id, Annual_Student_Information__c> newMap, List<Annual_Student_Information__c> actList, Map<Id, Annual_Student_Information__c> actlstoldMap, Map<Id, Annual_Student_Information__c> actlstnewMap) {

        Boolean origRunAssignment = NES_Constants.runAssignment;
        Boolean origRunCompletion = NES_ECACompletion.shouldRunCompletion;
        NES_Constants.runAssignment = false;
        NES_ECACompletion.shouldRunCompletion = false;

        if (!logicSwitch) return;

        if (runCBL) {
            if (waitlistFlagCalcSwitch)
                NES_AnnualStudentInfoBusinessLogic.waitlistCalculator(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
            if (whyFlagSwitch) {
                NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
            }

            //Mark Membrino 6/15/2020 Changed back to using new map instead of just In Progress for 193701.  Even
            //if the PE is complete, we still want to update the grade level.
            NES_AnnualStudentInfoBusinessLogic.populateProgramEnroll_FinalGradeLevel(newList);
            NES_AnnualStudentInfoBusinessLogic.calculateELLFlag(actList, actlstoldMap);

            if (highSchoolSwitch) {
                NES_AnnualStudentInfoBusinessLogic.populatePEHighSchoolLTSGroup(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
            }

            if (highSchoolLTSScoreSwitch) {
                NES_AnnualStudentInfoBusinessLogic.populatecalculateHighSchoolLTS(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
            }

            //Run the entrance age logic if the TransitionalKAcknowledgement__c is updtated.
            List<SObject> updateAckList = new List<SObject> ();

            for (Annual_Student_Information__c asi : actlstnewMap.values()) {
                if (asi.TransitionalKAcknowledgement__c != actlstoldMap.get(asi.Id).TransitionalKAcknowledgement__c)
                updateAckList.add(asi);
            }
            if (updateAckList.size() > 0)
            NES_BusinessLogicUtils.calculateEntranceAgeEligibility(updateAckList);
            System.debug('updateAckList' + updateAckList);

            //Mark Membrino 6/15/2020 Changed back to using new map instead of just In Progress for 193701.  Even
            //if the PE is complete, we still want to update the grade level.
            NES_AnnualStudentInfoBusinessLogic.populateProgramGradeLevel(newMap.values(), oldMap);
        }


        NES_Constants.runAssignment = origRunAssignment;

        // Edited by Gourav Nirwal for test class coverage. Add Test.isRunningTest()
        //if (NES_Constants.runAssignment || Test.isRunningTest()) { //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Annual_Student_Information__c newObject = new Annual_Student_Information__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Annual_Student_Information__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            //Swapna:Changed to active list
            for (Annual_Student_Information__c newInfo : actlstnewMap.values()) {

                Annual_Student_Information__c oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String> ();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);

                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.' + str;
                            newFieldUpdate.newValue =  newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;

                            newFieldUpdate.studentOrHousehold = 'Student';
                            fieldUpdateList.add(newFieldUpdate);

                            //System.debug('newFieldUpdate:' + newFieldUpdate);
                        }
                    } catch(Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterUpdate', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id> ();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Annual_Student_Information__c', peToObjectMap, fieldUpdateList);
        //}
    }
    /* Start of changes for the #77940 */
    public static void handleBeforInsert(List<Annual_Student_Information__c> newList) {
    }
    public static void handleBeforUpdate(Map<Id, Annual_Student_Information__c> newMap, Map<Id, Annual_Student_Information__c> oldMap) {

    }
    /* End of changes for the #77940 */

}