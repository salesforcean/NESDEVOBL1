/*
  Author:Guravaiah Gunturi
  ****************************
  User Story: #123101 (Task: #158397,160126)
  *******************************************
  Date:23/03/2020
  ********************************************
  Apex Classes: SSTFPublicGroupUserPermissionBatch,SSTFUserPermissionBatch_TEST
  *****************************************************************************
  Description:This class is controller for Assigning permission set to Public Group Members 
			    -Batch Class Needs to be run with the Batch Size of 1
			    - Query all the Group Members of the Particular Group,identify whether the perimission set is already been assigned for each Member
				- If the User is already having the permission set ->Ignore
				- The group member doesn't have permission set assigned to them -> New Member to the Group -> Assign the Permisison Set
				- Users who has Permission set but not part of the Group -> Remove the Permisison Set from that User
*/

global class SSTFPublicGroupUserPermissionBatch implements Schedulable,Database.Batchable <sObject> {
    Global List<Educational_Institution_SSTF_Mapping__mdt> EISSTFMappingList = new List<Educational_Institution_SSTF_Mapping__mdt>();
    
    //Assign all custom metadata records to declared metadata list variable in constructor
    global SSTFPublicGroupUserPermissionBatch(){
        this.EISSTFMappingList = getAllEISSTFmappingList();
    }
    //  While running the batch class this method will start and fetching all the Groups from the custom metadata.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> groupNameList = new Set<String>();
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList ){
            groupNameList.add(cutMdt.Group_Name__c);
        }
       
        //Running Batch for Each Group from the Custom Metadata
        String query = 'SELECT Id,Name FROM Group WHERE Name in:groupNameList and SystemModstamp=TODAY';
        if(test.isRunningTest()){
            query = 'SELECT Id,Name FROM Group WHERE Name =\'TNCA\'';
        }
        system.debug('query====='+query);
        return Database.getQueryLocator(query);
    }
    //This method divided the number of Group records into batches and execte the one by one batch.
    global void execute(Database.BatchableContext bc, List<Group> groupRecords){
        //Query All the GroupMembers under the Group
        //List<GroupMember> records=[SELECT UserOrGroupId,SystemModstamp,Group.Name FROM GroupMember WHERE SystemModstamp=TODAY AND Group.Id=:groupRecords[0].Id];
        List<GroupMember> records=[SELECT UserOrGroupId,SystemModstamp,Group.Name FROM GroupMember WHERE Group.Id=:groupRecords[0].Id];
        System.debug('records--------->'+records);
        set<Id> userIdSet = new set<Id>();
        for (GroupMember gm :records)
        { 
            userIdSet.add(gm.UserOrGroupId);            
        }
        Set<String> profileName = new set<String>();
        for(Mapping_Profiles__mdt	mp:[Select Profile_Name__c from Mapping_Profiles__mdt]){
            profileName.add(mp.Profile_Name__c);
        }
        Map<Id,User> userMap = new Map<Id,User>([Select Id,profile.Name from user where Id in:userIdSet AND profile.name IN:profileName]);
        System.debug('SystemModeStamp======='+records);
        String permissionSetName;
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> deletePermissionSetList = new List<PermissionSetAssignment>();
        
        //Identify the Corresponsing permission set name for that Group
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList ){
            if(cutMdt.Group_Name__c==groupRecords[0].Name){
                permissionSetName = cutMdt.Permission_Set_Name__c;                                
            }            
        }
        
        system.debug('permissionSetName====='+permissionSetName);
        
        //Query the Permission Set where name in custom metadata
        List<PermissionSet> psList = [Select id,Name from PermissionSet Where Name =:permissionSetName];
        
        
        if(!psList.isEmpty())
        {
            Map<Id,Id> existingPAUsers = new Map<Id,Id>();
            //Query all the Users who are having the Existing Permission Set assigned to them
            for(PermissionSetAssignment psa : [Select Id,AssigneeId from PermissionSetAssignment where PermissionSetId=:psList[0].Id]){
                existingPAUsers.put(psa.AssigneeId,psa.Id);
            }                        
            Map<Id,User> existingPAUsersMap = new Map<Id,User>([Select id from User WHERE Contact.Account.RecordType.Name ='Educational Institution' and id in:existingPAUsers.keyset()]);
            for (GroupMember gm :records)
            {
                 System.debug('Printing usermap'+userMap.get(gm.UserOrGroupId));
                if(userMap.get(gm.UserOrGroupId)!=null && profileName.contains(userMap.get(gm.UserOrGroupId).profile.Name)){ //Assign Permission setto the Corresponding Profile Users only
                    if(existingPAUsers.containsKey(gm.UserOrGroupId) || existingPAUsersMap.containskey(gm.UserOrGroupId)){ //If the User is already having the permission set ->Ignore
                        existingPAUsers.remove(gm.UserOrGroupId);
                    }else{ //The group member doesn't have permission set assigned to them -> New Member to the Group -> Assign the Permisison Set
                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =psList[0].Id , AssigneeId = gm.UserOrGroupId);
                        permissionSetList.add(psa);       
                    }
                }
            }
            if(!existingPAUsers.isEmpty()){ // Users who has Permission set but not part of the Group -> Remove the Permisison Set from that User
                for(Id psaId:existingPAUsers.values()){
                    deletePermissionSetList.add(new PermissionSetAssignment(Id=psaId));
                }                
            }
            system.debug('permissionSetList====='+permissionSetList);
            system.debug('deletePermissionSetList====='+deletePermissionSetList);
            try{
                Database.insert(permissionSetList,false);
                delete deletePermissionSetList;
            }Catch(Exception ex){
                system.debug('Exception---'+ex);
            }
            
        }
        
    }  
    //This metod will be stop the process once execute method completed.
    global void finish(Database.BatchableContext bc){
        
    }  //Scheduled batch class
    global void execute(SchedulableContext scon) {
        Database.executeBatch(new SSTFPublicGroupUserPermissionBatch(),1);
    }
    
    //This metod returning all the Permissionsets,Groups and Profiles from the Custom Meatadata.
    Public List<Educational_Institution_SSTF_Mapping__mdt> getAllEISSTFmappingList(){
        return [SELECT MasterLabel,
                Permission_Set_Name__c,
                User_Profile__c,
                Group_Name__c
                FROM Educational_Institution_SSTF_Mapping__mdt];
    }
}