/*
* Purpose: Server side controller methods for passing data to corresponding LC
* Change Log:
*         2019-08-01 initial for #101928 User Story (Eshwar) 
*         2019-08-02 updates for #101928 User Story (Andrew Sim)
*/
public with sharing class NES_DocumentFileRefListController {
    
    // return a list of Document file references to display
    @AuraEnabled
    public static List <Document_File_References__c> getDocList(Id enrollmentDocumentId) {
        system.debug('getDocList(' + enrollmentDocumentId + ');');
        return [SELECT Document_Link__c,Document_Type__c,Enrollment_Document__c,File_Path__c,Id,Name,Version__c,CreatedDate  FROM Document_File_References__c WHERE Enrollment_Document__c = :enrollmentDocumentId ORDER BY CreatedDate DESC];
    }
    
    // return the utility settings for this user
    @AuraEnabled
    public static Utility_Settings__c getUtilitySettings() {
        return Utility_Settings__c.getInstance();
    }
    
}