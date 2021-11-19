public class NES_IntentToReturnHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('IntentToReturnHandler');
    
    public static void handleAfterInsert(List<Intent_To_Return__c> newList) {
        if (NES_Constants.runAssignment || Test.isRunningTest()) {
             Intent_To_Return__c newObject = new Intent_To_Return__c();
             Schema.SObjectType objType = newObject.getSObjectType();
             Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Intent_To_Return__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Intent_To_Return__c newInfo : newList) {
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Intent_To_Return__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('afterInsert', e);
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
            if (fieldUpdateList.size()>0) {
                NES_ECACompletion.shouldRunCompletion = true;
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Intent_To_Return__c', peToObjectMap, fieldUpdateList);
            NES_ECACompletion.shouldRunCompletion = false;
        }
    }
    
    
    public static void handleAfterUpdate(List<Intent_To_Return__c> newList, Map<Id, Intent_To_Return__c> oldMap, Map<Id, Intent_To_Return__c> newMap) {
        Boolean origRunAssignment = NES_Constants.runAssignment;
        NES_Constants.runAssignment = false;
        NES_Constants.runAssignment = origRunAssignment;
        Intent_To_Return__c newObject = new Intent_To_Return__c(); // This takes all available fields from the required object.
        Schema.SObjectType objType = newObject.getSObjectType();      
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Intent_To_Return__c.fields.getMap();
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
        Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); 
        for (Intent_To_Return__c newInfo : newMap.values()) {
            Intent_To_Return__c oldInfo = oldMap.get(newInfo.Id);
            List<String> changedFields = new List<String> ();
            for (String str : mapFields.keySet()) {
                try {
                    if (newInfo.get(str) != oldInfo.get(str)) {
                        changedFields.add(str);
                        //These are for the new ECA processing model.  
                        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                        newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                        newFieldUpdate.objectAndFieldName = 'Intent_To_Return__c.' + str;
                        newFieldUpdate.newValue =  newInfo.get(str);
                        newFieldUpdate.studentOrHousehold = 'Student';
                        fieldUpdateList.add(newFieldUpdate);
                    }
                }
                catch(Exception e){
                    System.debug('Error: ' + e);
                    logger.logException('afterInsert', e);
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
         if (fieldUpdateList.size()>0) {
             NES_ECACompletion.shouldRunCompletion = true;
         }
        NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Intent_To_Return__c', peToObjectMap, fieldUpdateList); 
        NES_ECACompletion.shouldRunCompletion = false;
    }
}