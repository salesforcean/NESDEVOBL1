/*
 * Developed By: Sai Rakesh Puli (NESS TECHNOLOGIES)

 * User Story # 176990 
 * Task # 177183 
 * Description - This batch job class used to process School staff records on Contact object.This job will associate or remove permission set for School staff based on the School and its related permission sets
 *               All the School Staff contact records will be pulled that were updated on a specific time frame (Historical records processing)/Last modified date 
 *  TestClass -  Refer CS_SSTFPermissionBatchTest             
*/

global class CS_SSTFPermissionBatch implements  Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.SSTF_PERMISSION_ACCESS_PROCESS];
        DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));    
        String schoolstaffRec = CS_Constants.SCHOOL_RECTYPE_STAFF;
        String batchQueryStr = 'SELECT Id, Name, AccountId,Account.Name, Commuity_User__c,Commuity_User__r.Profile.Name FROM Contact WHERE Recordtype.DeveloperName=:schoolstaffRec  AND Commuity_User__c !=null AND LastModifiedDate >= :dateTimeInterval';         



        //System.debug('TEST REC'+batchQueryStr);
        return Database.getQueryLocator(batchQueryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> ContactList){
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Set<String> permissionSetNames = new Set<String>();


        Set<PermissionSetAssignment> deletepermSet = new Set<PermissionSetAssignment>();
        List<PermissionSetAssignment> deletepermList = new List<PermissionSetAssignment>();
        Map<String,Id> permissionSetMap = new Map<String,Id>();
        Map<String,PermissionSetAssignment> permissionSetAssignetoIdMap = new Map<String,PermissionSetAssignment>();
        Map<String,String> permissionSetAssignmentMap = new Map<String,String>();
        Map<String,Educational_Institution_SSTF_Mapping__mdt> schooltoMdtMap = new Map<String,Educational_Institution_SSTF_Mapping__mdt>();
        Set<String> uniqueCommuserSet = new Set<String>();
        

        Set<String> profileName = new set<String>();  
         //Looping Metadata and capturing Profile Names
        for(Mapping_Profiles__mdt	mp:[Select Profile_Name__c from Mapping_Profiles__mdt]){
            profileName.add(mp.Profile_Name__c);
        }
        
        for(contact cont:ContactList){
            if(profileName.contains(cont.Commuity_User__r.Profile.Name)){
            uniqueCommuserSet.add(cont.Commuity_User__c);
            }
        }
        
        //fetching all Metadata from org
        List<Educational_Institution_SSTF_Mapping__mdt> EISSTFMappingList =  [SELECT MasterLabel,
                                                                        Permission_Set_Name__c,

                                                                        School__c                                                                     
                                                                        FROM Educational_Institution_SSTF_Mapping__mdt];
        //looping metadata and capturing permissionSet names
        
        for(Educational_Institution_SSTF_Mapping__mdt custMdt: EISSTFMappingList)
        {
            permissionSetNames.add(custMdt.Permission_Set_Name__c);
           // system.debug('permissionSetNames====='+permissionSetNames);
            schooltoMdtMap.put(custMdt.School__c,custMdt);
            
          
        } 
        //Preparing map with metadata permissionSet names with permission id
        for(PermissionSet ps: [Select id,Name from PermissionSet WHERE Name IN:permissionSetNames AND IsOwnedByProfile = FALSE])
        {
            permissionSetMap.put(ps.Name,ps.Id);
            //system.debug('permissionSetMap====='+permissionSetMap);
        }
        
        //Query for PermissionSetAssignment 
        for(PermissionSetAssignment psa: [Select id,AssigneeId,PermissionSetId  from PermissionSetAssignment WHERE AssigneeId=:uniqueCommuserSet
                                                  AND PermissionSetId IN (SELECT Id  FROM PermissionSet WHERE IsOwnedByProfile =false)])                                                
        {


            
            permissionSetAssignmentMap.put(psa.AssigneeId,psa.PermissionSetId);
            permissionSetAssignetoIdMap.put(psa.AssigneeId,psa);

        }
        
        //Populate Associate and removal permission sets based on Contact iteration
          for(Contact con: ContactList) 
          {
              //System.debug('Printing SchooltoMdtMap'+schooltoMdtMap.get(con.account.name));

              if(con.AccountId !=null && schooltoMdtMap.get(con.account.name) !=null && uniqueCommuserSet.contains(con.Commuity_User__c))
              {


                      //For the existing School staff if there is a realignment to different School then remove the old permission set
                      if(permissionSetAssignmentMap.get(con.Commuity_User__c)!=null && permissionSetAssignmentMap.get(con.Commuity_User__c)!=permissionSetMap.get(schooltoMdtMap.get(con.account.name).Permission_Set_Name__c)){
                          //System.debug('Lets delete this permission-->'+permissionSetAssignetoIdMap.get(con.Commuity_User__c));


                          deletepermSet.add(permissionSetAssignetoIdMap.get(con.Commuity_User__c));
                      }
                      // 
                       if(permissionSetAssignmentMap.get(con.Commuity_User__c)== permissionSetMap.get(schooltoMdtMap.get(con.account.name).Permission_Set_Name__c)){
                           //If there is no realignment to different school and if there is already existing permissionset for the School staff then do
                           //nothing 


                          // System.debug('Conditions are matched so do nothing-->'+con.Id+'==comm user-->'+con.Commuity_User__c);
                       }else{    
                      PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =permissionSetMap.get(schooltoMdtMap.get(con.account.name).Permission_Set_Name__c) ,
                                                                                           AssigneeId = con.Commuity_User__c);
                      permissionSetList.add(psa);
                       }


                    // }
              }
              
          }
        
        if(permissionSetList !=null && permissionSetList.size() >0)
        {

            Database.insert(permissionSetList,false);
        }
       


        if(deletepermSet !=null && deletepermSet.size() > 0){
            deletepermList.addAll(deletepermSet);
             //System.debug('Printing DELETE PERM LIST'+deletepermList);

             Database.delete(deletepermList,false);
        }
    }
      
    global void finish(Database.BatchableContext bc){
       
    }
}