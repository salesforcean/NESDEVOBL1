/**
 * Created by Anushka on 11-12-2018.
 * Purpose : Handler class for HealthAndImmunizationTrigger.
 */

public class NES_HealthAndImmunizationHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('HealthAndImmunizationHandler');

    static final Boolean immunizationStatusSwitch = NES_TriggerUtility.BusinessLogicSwitch('Immunization Status Current');

    public static void handleBeforeUpdate(Map<Id, Health_and_Immunization__c> newMap, Map<Id, Health_and_Immunization__c> oldMap) {
        if (immunizationStatusSwitch)
            NES_HealthAndImmunizationBusinessLogic.updateImmunizationStatusCurrent(newMap, oldMap);

    }
    public static void handleAfterUpdate(Map<Id, Health_and_Immunization__c> newMap, Map<Id, Health_and_Immunization__c> oldMap) {

        //if (NES_Constants.runAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Health_and_Immunization__c newObject = new Health_and_Immunization__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Health_and_Immunization__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

            for (Health_and_Immunization__c newInfo : newMap.values()) {

                Health_and_Immunization__c oldInfo = oldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Health_and_Immunization__c.' + str;
                            newFieldUpdate.newValue =  newInfo.get(str);
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Health_and_Immunization__c', peToObjectMap, fieldUpdateList);
        //}

    }
    public static void handleAfterInsert(Map<Id, Health_and_Immunization__c> newMap) {

        //if (NES_Constants.runAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Health_and_Immunization__c newObject = new Health_and_Immunization__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Health_and_Immunization__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Health_and_Immunization__c newInfo : newMap.values()) {

                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Health_and_Immunization__c.' + str;
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Health_and_Immunization__c', peToObjectMap, fieldUpdateList);
        //}

    }

}