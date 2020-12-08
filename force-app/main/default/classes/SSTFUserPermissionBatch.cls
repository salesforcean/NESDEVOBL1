/***************************************************************************************************************************************
* Name: SSTFUserPermissionBatch
****************************************************************************************************************************************
* Author: Ranjit Chaganti
* Purpose: This class is controller for Assigning permission set to School Staff Community User .
* Created Date: 03/24/2020
****************************************************************************************************************************************
* <Modification History>
* <initials> - <date> - <reason for update>
*                     - <what was changed/added>
***************************************************************************************************************************************/

global class SSTFUserPermissionBatch implements Schedulable,Database.Batchable <sObject> {
    Global List<Educational_Institution_SSTF_Mapping__mdt> EISSTFMappingList = new List<Educational_Institution_SSTF_Mapping__mdt>();
    
    //Assign all custom metadata records to declared metadata list variable in constructor 
    global SSTFUserPermissionBatch(){
        this.EISSTFMappingList = getAllEISSTFmappingList();
    }
    
    //fetching all community users where Account is Educational Institution and profile which are matched with custom metadata profiles 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> profileList = new Set<String>();
        
        //looping metadata and capturing profiles into profileList variable
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList ){
            profileList.add(cutMdt.User_Profile__c);
        }
        system.debug('profileList====='+profileList);
        String query = 'Select id,Profile.Name,Contact.RecordType.Name,Contact.Account.Name from User WHERE Profile.Name IN: profileList AND Contact.Account.RecordType.Name =\'Educational Institution\' AND  LastModifiedDate = TODAY ';
        system.debug('query====='+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<User> records){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Set<String> permissionSetNames = new Set<String>();
        Map<String,Id> permissionSetMap = new Map<String,Id>();
        Map<String,List<Educational_Institution_SSTF_Mapping__mdt>> accountMDTmap = new Map<String,List<Educational_Institution_SSTF_Mapping__mdt>>();
        
        //looping metadata and capturing permissionSet names
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList )
            permissionSetNames.add(cutMdt.Permission_Set_Name__c);
            system.debug('permissionSetNames====='+permissionSetNames);
        
        //Preparing map with metadata permissionSet names with permission id
        for(PermissionSet ps: [Select id,Name from PermissionSet Where Name IN:permissionSetNames ])
            permissionSetMap.put(ps.Name,ps.Id);
            system.debug('permissionSetMap====='+permissionSetMap);
        
        if(!permissionSetMap.isEmpty())
        {
            //Preparing map with account and its related records from custom metadata
            for(Educational_Institution_SSTF_Mapping__mdt custMdt :EISSTFMappingList )
            {
                if(accountMDTmap.containsKey(custMdt.School__c)){
                    List<Educational_Institution_SSTF_Mapping__mdt> oldMdt = accountMDTmap.get(custMdt.School__c);
                    oldMdt.add(custMdt);
                    accountMDTmap.put(custMdt.School__c,oldMdt);
                }
                else{
                    accountMDTmap.put(custMdt.School__c,new List<Educational_Institution_SSTF_Mapping__mdt>{custMdt});
                }
            }
                       
            // looping community users and creating permission set assignment with suitable permission set
            for (User communityUser :records)
            {
                if(communityUser.Contact.AccountId!=null){
                    system.debug(communityUser.Contact.AccountId);
                    
                    If(accountMDTmap.containskey(communityUser.Contact.Account.Name)){
                        for(Educational_Institution_SSTF_Mapping__mdt cMdt: accountMDTmap.get(communityUser.Contact.Account.Name)){
                            if(cMdt.User_Profile__c == communityUser.Profile.Name){
                                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =permissionSetMap.get(cMdt.Permission_Set_Name__c) ,
                                                                                           AssigneeId = communityUser.Id);
                                permissionSetList.add(psa);
                            }
                        }
                    }
                }
            }
             system.debug('permissionSetList====='+permissionSetList);
            
            try{
                If(!permissionSetList.isEmpty()){
                    
                    // inserting PermissionSet assignment for cummunity users              
                    Database.SaveResult[] srList = Database.insert(permissionSetList, false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess())                         
                            System.debug('Successfully inserted Permission Set: ' + sr.getId());                    
                        else{
                            
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors())                                             
                                System.debug('Exception==='+err);                                                   
                        }
                    }
                }
            }
                Catch(Exception ex){
                system.debug('Exception---'+ex);
            }
            
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        
    }  
    global void execute(SchedulableContext scon) {
        //Executing batch class
        Database.executeBatch(new SSTFUserPermissionBatch());
    }

    // Fetching all custom metadata records from system
    Public List<Educational_Institution_SSTF_Mapping__mdt> getAllEISSTFmappingList(){
        return [SELECT MasterLabel,
                       Permission_Set_Name__c,
                       School__c,
                       User_Profile__c 
                       FROM Educational_Institution_SSTF_Mapping__mdt];
    }
}