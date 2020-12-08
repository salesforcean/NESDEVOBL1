/**
 * Created by Anushka on 19-12-2018.
 * Purpose : Handler class for PlacementAndElectiveTrigger.
 * Added exclude auto course logic for ASI record for US 117571 (Task # 118636) by Anitha P on 15-11-2019
 */

public class NES_PlacementAndElectiveHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('PlacementAndElectiveHandler');

    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');

    public static void handleAfterInsert(List<Placement_and_Elective__c> newList) {


        //if (NES_Constants.runAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Placement_and_Elective__c newObject = new Placement_and_Elective__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Placement_and_Elective__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Placement_and_Elective__c newInfo : newList) {

                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Placement_and_Elective__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterInsert', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id>();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Placement_and_Elective__c', peToObjectMap, fieldUpdateList);
        //}

        //MM 9/11/2020 Commented out the call to LTS on insert because it is called from update already and it sometimes causes soql limit errors.
        //if (likelihoodToTransitionScore) {
        //    NES_PlacementAndElectiveBusinessLogic.calculateLTS_Insert(newList);
        //}

         NES_PlacementAndElectiveBusinessLogic.excludeAutoCourseFromASI(newList);//added for US 117571 (Task # 118636) by anitha p

    }
    public static void handleAfterUpdate(Map<Id, Placement_and_Elective__c> newMap, Map<Id, Placement_and_Elective__c> oldMap) {

        if (likelihoodToTransitionScore) {
            NES_PlacementAndElectiveBusinessLogic.calculateLTS_Update(oldMap, newMap);
        }

        /* 11/9/2019 Alex - removing as part of the placement redesign
        NES_PlacementAndElectiveBusinessLogic.shouldRunPlacement(newMap.values(), oldMap); */

        //if (NES_Constants.runAssignment) { //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Placement_and_Elective__c newObject = new Placement_and_Elective__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Placement_and_Elective__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Placement_and_Elective__c newInfo : newMap.values()) {

                Placement_and_Elective__c oldInfo = oldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Placement_and_Elective__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterUpdate', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id>();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Placement_and_Elective__c', peToObjectMap, fieldUpdateList);
        //}
    }
   
 }