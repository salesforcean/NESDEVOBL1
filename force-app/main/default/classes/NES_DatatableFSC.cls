/**

    * Created by ali.khan (Ness Tech) on 10/20/19.
    * This class covers server calls for NES_DatatableFSC aura component.

*/
public with sharing class NES_DatatableFSC {


    @AuraEnabled
    public static List<sObject> getData(List<String> queryParams) { 


        // Select Id, Name, Program_Enrollment__c, SchoolType__c,SchoolName__c,State__c,MonthStarted__c,EnrollmentStatus__c,YearStarted__c from Prior_school__c order by LastModifiedDate desc limit 10
        String queryString = 'Select {0} FROM {1}'; // WHERE {2} = {3}';
        String whereClause = ' WHERE ' + queryParams[2] + '= \'' + queryParams[3] + '\'';
        String orderBy = ' ORDER BY LastModifiedDate DESC';
        queryString = String.format(queryString, queryParams);

        List<sObject> data = Database.query(queryString + whereClause + orderBy);
        
        return data;


    }


    @AuraEnabled
    public static void updateRecords(List<SObject> recList) {


        update recList;


    }


    @AuraEnabled
    public static String createRecordGeneric(String sObjectAPIName, Map<String, String> fieldValueMap) { 
        // if its master-detail, please ensure you pass the parentFieldValue map, else this will fail.
        

        // Convert to schema.sObjectType
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sObjectAPIName);
        // Create an instance of that type
        Sobject sObj = convertType.newSObject();

        for (String fld : fieldValueMap.keySet()) {
            sObj.put(fld, fieldValueMap.get(fld));
        }
        System.debug(JSON.serialize(sObj));
        

        insert sObj;
        return (sObj.Id+'');

        
    }


    @AuraEnabled
    public static String createPriorSchoolRecord(String programEnrollmentID) {


        Map<String, String> fieldValueMap = new Map<String, String>();

        fieldValueMap.put('Program_Enrollment__c', programEnrollmentID);
        fieldValueMap.put('SchoolName__c','AUTO GENERATED, PLEASE EDIT...');
        fieldValueMap.put('State__c','TBD');
        fieldValueMap.put('SchoolType__c','None');
        // Can't set a 'TBD' default these, they are Restricted Picklist fields.
        // genericObject.put('EnrollmentStatus__c','None');
        // genericObject.put('YearStarted__c','TBD');
        // genericObject.put('MonthStarted__c','TBD');

        return createRecordGeneric('Prior_School__c', fieldValueMap);
        

    }


    // @todo: Not needed now, just keep it here, anyways for later.
    @AuraEnabled
    public static List<Id> insertRecords(List<SObject> recList) {

        insert recList;

        // return list of inserted recIDs 
        Map<Id, sObject> recordsIDMap = new Map<Id, sObject>();
        recordsIDMap.putAll(recList);
        return (new List<Id>(recordsIDMap.keySet()));

    }
    

}