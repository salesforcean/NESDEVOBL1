/*
* Created by:  Anitha P
* Created date: 2019-08-01
* Purpose: Handle class to update custom settings
* Change Log:
*         2019-08-01 initial Anitha P for #102150 User Story
*/
public with sharing class NES_UserTriggerHandler {
    
    @future
    public static void afterInsertUpdateFuture(Set<Id> objIdList){
        List<SObject> newList = [select Id, Document_Download__c from User where Id in : objIdList];
        updateUtilitySettings(newList);
    }
    
    public static void afterInsertUpdate(List<SObject> oldList, List<SObject> newList){
        updateUtilitySettings(newList);
    }
    
    public static void updateUtilitySettings(List<SObject> newList) {
        
        List<Utility_Settings__c> upsertList = new List<Utility_Settings__c>();
        Map<Id, Utility_Settings__c> utilitySettingsMap = new Map<Id, Utility_Settings__c>();
        
        // get list of user_settings from user ids and add to map
        for (Utility_Settings__c obj : [select Id, SetupOwnerId, Document_Download__c from Utility_Settings__c where SetupOwnerId in :newList]) {
            utilitySettingsMap.put(obj.SetupOwnerId, obj);
        }
        // system.debug('utilitySettingsMap: ' + utilitySettingsMap);
        
        // set document_download__c values in utility settings if the user is enabled for document download
        for (User obj : (List<User>) newList) {  
	        if (utilitySettingsMap.containsKey(obj.Id)) {
	        	// update document_download__c 
	            Utility_Settings__c utilitySettings = utilitySettingsMap.get(obj.Id);
	            utilitySettings.Document_Download__c = obj.Document_Download__c;
	            upsertList.add(utilitySettings);
	        } 
        	else if (obj.Document_Download__c == true){
        		upsertList.add(new Utility_Settings__c(SetupOwnerId = obj.Id, Document_Download__c = obj.Document_Download__c));    
	        }
        	
        }
        // system.debug('upsertList: ' + upsertList);
        
        // update the utility settings 
        upsert upsertList;
        
    }
}