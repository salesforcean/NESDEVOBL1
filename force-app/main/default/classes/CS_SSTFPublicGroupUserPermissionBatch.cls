/*
  Author:Guravaiah Gunturi
  ****************************
  User Story: #123101 (Task: #158397,160126)
  *******************************************
  Date:23/03/2020
  ********************************************
  Apex Classes: CS_SSTFPublicGroupUserPermissionBatch
  *****************************************************************************
  Description:This class is controller for Assigning permission set to Public Group Members 
			    - Query all the Group Members of the Particular Group,identify whether the perimission set is already been assigned for each Member
				- If the User is already having the permission set ->Ignore
				- The group member doesn't have permission set assigned to them -> New Member to the Group -> Assign the Permisison Set
				- Users who has Permission set but not part of the Group -> Remove the Permisison Set from that User
*/

global class CS_SSTFPublicGroupUserPermissionBatch implements Schedulable,Database.Batchable <sObject> {
    Global List<Educational_Institution_SSTF_Mapping__mdt> EISSTFMappingList = new List<Educational_Institution_SSTF_Mapping__mdt>();
    
    //Assign all custom metadata records to declared metadata list variable in constructor
    global CS_SSTFPublicGroupUserPermissionBatch(){
        this.EISSTFMappingList = getAllEISSTFmappingList();
    }
    //  While running the batch class this method will start and fetching all the Groups from the custom metadata.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> groupNameList = new Set<String>();
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList ){
            groupNameList.add(cutMdt.Group_Name__c);
        }
        Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.SSTF_PUBLIC_GROUP_USER_PERMISSION_ACCESS_PROCESS];
        DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));    
        
        //Running Batch for Each Group from the Custom Metadata
        String query = 'SELECT Id,Name FROM Group WHERE Name in:groupNameList and SystemModstamp >=:dateTimeInterval';
        if(Test.isRunningTest()){
            query = 'SELECT Id,Name FROM Group WHERE Name in:groupNameList limit 1';
        }
        //system.debug('query====='+query);
        return Database.getQueryLocator(query);
    }
    //This method divided the number of Group records into batches and execte the one by one batch.
    global void execute(Database.BatchableContext bc, List<Group> groupRecords){
        //Query All the GroupMembers under the Group
        List<GroupMember> records=[SELECT UserOrGroupId,Group.Name FROM GroupMember WHERE Group.Id=:groupRecords];
        set<Id> userIdSet = new set<Id>();
        set<String> groupNameSet = new set<String>();
        for (GroupMember gm :records)
        { 
            userIdSet.add(gm.UserOrGroupId);  
            groupNameSet.add(gm.Group.Name);
        }
        Set<String> profileName = new set<String>();
        for(Mapping_Profiles__mdt	mp:[Select Profile_Name__c from Mapping_Profiles__mdt]){
            profileName.add(mp.Profile_Name__c);
        }
        Map<Id,User> userMap = new Map<Id,User>([Select Id,profile.Name from user where Id in:userIdSet AND profile.name IN:profileName]);
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> deletePermissionSetList = new List<PermissionSetAssignment>();
        Map<String,String> GroupPermissionsetMap = new Map<String,String>();
        
        //Identify the Corresponsing permission set name for that Group
        for(Educational_Institution_SSTF_Mapping__mdt cutMdt :EISSTFMappingList ){
            if(groupNameSet.contains(cutMdt.Group_Name__c)){
                GroupPermissionsetMap.put(cutMdt.Group_Name__c,cutMdt.Permission_Set_Name__c);                   
            }
        }
        
        
        //Query the Permission Set where name in custom metadata
        Map<String,Id> permissionSetMap = new Map<String,Id>();
        for(permissionset ps:[Select id,Name from PermissionSet Where Name in:GroupPermissionsetMap.values()])
        {
            permissionSetMap.put(ps.Name,ps.Id);
        }
        
        
        
        if(!permissionSetMap.isEmpty())
        {
            Map<String,Id> existingPAUsers = new Map<String,Id>();
            //Query all the Users who are having the Existing Permission Set assigned to them
            List<PermissionSetAssignment> psaList = [Select Id,AssigneeId,Assignee.Contact.Account.RecordType.Name,PermissionSetId from PermissionSetAssignment where PermissionSetId=:permissionSetMap.values()];
            for(PermissionSetAssignment psa : psaList){                
                if(psa.Assignee.Contact.Account.RecordType.Name !='Educational Institution' ){
                    existingPAUsers.put(psa.PermissionSetId+'_'+psa.AssigneeId,psa.Id);
                }
            }  
            for (GroupMember gm :records)
            {
                System.debug('Printing usermap'+userMap.get(gm.UserOrGroupId));
                if(userMap.get(gm.UserOrGroupId)!=null && profileName.contains(userMap.get(gm.UserOrGroupId).profile.Name)){ //Assign Permission setto the Corresponding Profile Users only
                    Id permissionSetId = permissionSetMap.get(GroupPermissionsetMap.get(gm.Group.Name));
                    if(existingPAUsers.containsKey(PermissionSetId+'_'+gm.UserOrGroupId)){ //If the User is already having the permission set ->Ignore
                        existingPAUsers.remove(PermissionSetId+'_'+gm.UserOrGroupId);
                        //usersToremove.add(gm.UserOrGroupId);
                    }else{ //The group member doesn't have permission set assigned to them -> New Member to the Group -> Assign the Permisison Set
                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =permissionSetId , AssigneeId = gm.UserOrGroupId);
                        permissionSetList.add(psa);       
                    }
                }
            }
            if(!existingPAUsers.isEmpty()){ // Users who has Permission set but not part of the Group -> Remove the Permisison Set from that User
                for(Id psaId:existingPAUsers.values()){
                    deletePermissionSetList.add(new PermissionSetAssignment(Id=psaId));
                }                
            }
            //system.debug('permissionSetList====='+permissionSetList);
            //system.debug('deletePermissionSetList====='+deletePermissionSetList);
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
        Database.executeBatch(new CS_SSTFPublicGroupUserPermissionBatch());
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