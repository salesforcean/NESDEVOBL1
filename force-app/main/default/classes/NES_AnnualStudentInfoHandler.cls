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
    public static String accountObject ='Account';
    public static String programEnrollmentObject ='hed__Program_Enrollment__c';
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
        System.debug('<<newMaphandleBeforUpdate>>'+newMap+'<<oldMap>>'+oldMap);
           
    }
    public static Map<String,String> getASIInformation(Id programId) {
       Map<String,String> peMapData=new Map<String,String>();

       List<hed__Program_Enrollment__c> listObj=new List<hed__Program_Enrollment__c>();
        try{
            listObj=[SELECT Id, hed__Account__r.Id,hed__Account__r.Name,hed__Contact__r.Birthdate__c FROM hed__Program_Enrollment__c where id=:programId];
             if((listObj.size()>0)){
              peMapData.put('programName',listObj[0].hed__Account__r.Name);
              peMapData.put('birthDate',String.valueOf(listObj[0].hed__Contact__r.Birthdate__c));  
             }

            
        }catch(Exception ex){
            System.debug('Error occured while retrieving Id:'+ex.getMessage());
        }
        return peMapData;
   }
   public static Id getProgramGradeLevelId(String programEnId,String gradeLevel) {
       Id returnProgramId=null;
       Id acadProgId=null;
       try{
           System.debug('before loop>>'+programEnId+'<<gradeLevel>>'+gradeLevel);
           if(NES_AnnualStudentInfoHandler.findObjectAPIName(programEnId)==accountObject){
               System.debug('inside loop>>'+programEnId+'<<gradeLevel>>'+gradeLevel);
              List<Program_Grade_Level__c> listObj=[SELECT Id FROM Program_Grade_Level__c WHERE Academic_Program__c =:programEnId limit 1 ];
               //SELECT Id FROM Program_Grade_Level__c WHERE Academic_Program__c =:programEnId  and Grade_Level__r.Name=:gradeLevel limit 1 
              System.debug('Account conidtion>>'+listObj[0].id);
           }  
           if(NES_AnnualStudentInfoHandler.findObjectAPIName(programEnId)==programEnrollmentObject){
               acadProgId=[SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id =:programEnId limit 1].hed__Account__c;
               returnProgramId=[SELECT Id FROM Program_Grade_Level__c WHERE Academic_Program__c =:acadProgId  and Grade_Level__r.Name=:gradeLevel limit 1 ].Id;
            System.debug('ProgramEnrollment conidtion>>'+returnProgramId);
           }
           System.debug('else conidtion>>'+returnProgramId);
       }catch(Exception ex){
           System.debug('Error occured while retrieving Id:'+ex.getMessage());
       }
       System.debug('programEnId>>'+programEnId+'<>'+returnProgramId);
       //returnProgramId='a2X0x000000mG4QEAU';
        return returnProgramId;
   }
   public static String findObjectAPIName( String recordId ){
       System.debug('findObjectAPIName conidtion>>'+recordId);
       String keyPrefix;
       String objectAPIName = '';
        if(recordId == null)
            return null;
        keyPrefix = recordId.substring(0,3);
         for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
              String prefix = obj.getDescribe().getKeyPrefix();
               if(prefix == keyPrefix){
                         objectAPIName = obj.getDescribe().getName();
                          break;
                }
         }
         return objectAPIName;
    }
    /* End of changes for the #77940 */

}