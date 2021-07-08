/**
 * Created by triciaigoe on 1/15/19.
 */

public with sharing class NES_ExtendedDataHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('ExtendedDataHandler');

    public static void completionCheck(Map<Id, Extended_Data__c> oldMap, Map<Id, Extended_Data__c> newMap) {
        Extended_Data__c newObject = new Extended_Data__c(); // This takes all available fields from the required object.
        Schema.SObjectType objType = newObject.getSObjectType();
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Extended_Data__c.fields.getMap();
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
        Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

        for (Extended_Data__c newInfo : newMap.values()) {

            Extended_Data__c oldInfo = oldMap.get(newInfo.Id);
            List<String> changedFields = new List<String>();
            for (String str : mapFields.keySet()) {
                try {
                    if (newInfo.get(str) != oldInfo.get(str)) {
                        changedFields.add(str);
                        //These are for the new ECA processing model.  
                        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                        newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                        newFieldUpdate.objectAndFieldName = 'Extended_Data__c.' + str;
                        newFieldUpdate.newValue = newInfo.get(str);
                        newFieldUpdate.schoolYear = newInfo.School_Year__c;
                        fieldUpdateList.add(newFieldUpdate);
                    }
                } catch (Exception e) {
                    System.debug('Error: ' + e);
                    logger.logException('completionCheck', e);
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
        NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Extended_Data__c', peToObjectMap, fieldUpdateList);
    }
    
    // Fix for Defect 410602
    // Popluate School Year on Extended Data Record if blank from PE Start Year.    
    public static void updateSchoolYear(list <Extended_Data__c> newRecList){
        
        List <String> peIdList = new List <String> ();
        Map <Id, Extended_Data__c> peToExDtRecMap = new Map <Id, Extended_Data__c> ();
        Map <Id, Id> peIdToSchYrMap = new Map <Id, Id> ();
        List <Extended_Data__c> updRecList = new List <Extended_Data__c> ();
        
        // Get the Extended Data record Info and prepare the diff maps.
        for(Extended_Data__c edRec: newRecList){
            if(edRec.School_Year__c == null){
                if(String.isNotBlank(edRec.Program_Enrollment__c)){
                	peIdList.add(edRec.Program_Enrollment__c);
                	peToExDtRecMap.put(edRec.Program_Enrollment__c, edRec);
                	updRecList.add(edRec);
                }
            }            
        }
        
        // Get the PE Id to PE School Year Map
        List <hed__Program_Enrollment__c> peList = [Select Id, Start_Year__c from hed__Program_Enrollment__c where Id in : peIdList];
        for(hed__Program_Enrollment__c pe : peList){
            if(String.isNotBlank(pe.Start_Year__c)){
                peIdToSchYrMap.put(pe.Id, pe.Start_Year__c);
            }
        }
        
        // Start updating the required Extended Data records
        for( Extended_Data__c edRec : updRecList){
            if(peIdToSchYrMap.containsKey(edRec.Program_Enrollment__c)){
            	edRec.School_Year__c = peIdToSchYrMap.get(edRec.Program_Enrollment__c);
        	}
        }
        
    }

    public static void runCompletion(Map<Id, Extended_Data__c> newMap) {

        Extended_Data__c newObject = new Extended_Data__c(); // This takes all available fields from the required object.
        Schema.SObjectType objType = newObject.getSObjectType();
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Extended_Data__c.fields.getMap();
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
        Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

        for (Extended_Data__c newInfo : newMap.values()) {

            List<String> changedFields = new List<String>();
            for (String str : mapFields.keySet()) {
                try {
                    if (newInfo.get(str) != null) {
                        changedFields.add(str);
                        //These are for the new ECA processing model.  
                        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                        newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                        newFieldUpdate.objectAndFieldName = 'Extended_Data__c.' + str;
                        newFieldUpdate.newValue = newInfo.get(str);
                        newFieldUpdate.schoolYear = newInfo.School_Year__c;
                        fieldUpdateList.add(newFieldUpdate);
                    }
                } catch (Exception e) {
                    System.debug('Error: ' + e);
                    logger.logException('runCompletion', e);
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
        NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Extended_Data__c', peToObjectMap, fieldUpdateList);

    }
}