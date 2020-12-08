/*
* Created by:  Rakesh Ramaswamy, Sumanth
* Created date: 2020-Apr-14
* User Story : 130549, 164369
* Purpose: This utility class handles the association and removal of permission sets to/from the User (Student/Caretaker/Learning Coach)
            
* Change Log: 

* Test Class:  CS_PermissionSetsAccessUtilityTest
*
*/

public class CS_PermissionSetsAccessUtility {   
   
   // This method is a PermissionSetUtility method/library to check whether the permission-set is already assigned to the User record. 
   // This method is invoked from the assignPermissionSetToUser( ) method below.
   public static map<Id, set<Id>> checkWhetherPermSetsToAssign(map<Id, set<Id>> userPermSetsMap){
        set<Id> permSetTempIdSet = new set<Id>();
        set<Id> userSetTempIdSet = new set<Id>();
        map<String, Id> userIdPermSetIdPermSetsMap = new map<String, Id>();
        map<Id, set<Id>> userPermSetsTempMap = new map<Id, set<Id>>();
        
        for(Id userRecId : userPermSetsMap.keySet()){
            set<Id> permsSetIdSet = userPermSetsMap.get(userRecId);
            for(Id permSetId : permsSetIdSet){
                if(!userIdPermSetIdPermSetsMap.containsKey(String.valueOf(userRecId)+String.valueOf(permSetId))){
                    userIdPermSetIdPermSetsMap.put(String.valueOf(userRecId)+String.valueOf(permSetId), permSetId);                                       
                }
                  permSetTempIdSet.add(permSetId);              
            }
            userSetTempIdSet.add(userRecId);
        }
        
        system.debug('*** permSetTempIdSet ===> '+permSetTempIdSet);
        system.debug('*** userSetTempIdSet ==> '+userSetTempIdSet);
        system.debug('*** checkWhetherPermSetsToAssign == userIdPermSetIdPermSetsMap ==> '+userIdPermSetIdPermSetsMap);
        
        for(PermissionSetAssignment permSetObj : [SELECT Id, AssigneeId, PermissionSetId 
                                                  FROM PermissionSetAssignment 
                                                  WHERE AssigneeId IN :userSetTempIdSet
                                                  AND PermissionSetId IN :permSetTempIdSet]){
          //  system.debug('*** permSetObj ==> '+permSetObj);
            if(userIdPermSetIdPermSetsMap.containsKey(String.valueOf(permSetObj.AssigneeId)+String.valueOf(permSetObj.PermissionSetId))){
                if(userPermSetsTempMap.containsKey(permSetObj.AssigneeId)){
                    set<Id> permSetsIdSet = new set<Id>();
                    permSetsIdSet = userPermSetsTempMap.get(permSetObj.AssigneeId);
                    permSetsIdSet.add(permSetObj.PermissionSetId);
                    userPermSetsTempMap.put(permSetObj.AssigneeId, permSetsIdSet);
                }
                else{
                    set<Id> permSetsIdSet = new set<Id>();
                    permSetsIdSet.add(permSetObj.PermissionSetId);
                    userPermSetsTempMap.put(permSetObj.AssigneeId, permSetsIdSet);
                }
             }
        }
        system.debug('*** checkWhetherPermSetsToAssign method end == final userPermSetsTempMap ==> '+userPermSetsTempMap);               
                    
        return userPermSetsTempMap;
    }
    
    // This method is a PermissionSetUtility method/library to assign the permission-set to the User record.    
    public static void assignPermissionSetToUser(map<Id, set<Id>> userPermSetsMap){
        
        // validate if permission sets already assigned to the LC User.
        list<PermissionSetAssignment> permSetAssignList = new list<PermissionSetAssignment>();
        map<Id, set<Id>> userPermSetsTempMap = new map<Id, set<Id>>();
        
        system.debug('*** assignPermissionSetToUser Method Start userPermSetsMap ==> '+userPermSetsMap);
        
        userPermSetsTempMap = CS_PermissionSetsAccessUtility.checkWhetherPermSetsToAssign(userPermSetsMap);
        system.debug('*** assignPermissionSetToUser Method - userPermSetsTempMap ==> '+userPermSetsTempMap);
        
        if(userPermSetsTempMap.isEmpty()){
            system.debug('*** userPermSetsMap ==> '+userPermSetsMap);
            for(Id userRecId : userPermSetsMap.keySet()){  
              //  system.debug('*** userRecId ==> '+userRecId);
                for(Id permSetId : userPermSetsMap.get(userRecId)){
                //    system.debug('*** PermSetId ==> '+permSetId);
                    PermissionSetAssignment permSetAssignObj = new PermissionSetAssignment(
                                                                    PermissionSetId = permSetId,
                                                                    AssigneeId = userRecId                                              
                                                                );
                    permSetAssignList.add(permSetAssignObj);
                }
            }       
        }
        else if(!userPermSetsTempMap.isEmpty() && !userPermSetsMap.isEmpty()){
              system.debug('*** userPermSetsMap ==> '+userPermSetsMap);
              system.debug('*** userPermSetsTempMap ==> '+userPermSetsTempMap);
              for(Id userRecId : userPermSetsMap.keySet()){
                  if(!userPermSetsTempMap.containsKey(userRecId)){
                      // set<Id> permsetsExistSet = userPermSetsTempMap.get(userRecId);
                      set<Id> newPermSetsAddSet = userPermSetsMap.get(userRecId);
                      // system.debug('*** permsetsExistSet ==> '+permsetsExistSet);
                  //    system.debug('*** newPermSetsAddSet ==> '+newPermSetsAddSet);
                      for(Id existPermSetsId : newPermSetsAddSet){
                    //      system.debug('*** existPermSetsId ==> '+existPermSetsId);
                          // system.debug('*** permsetsExistSet.contains(existPermSetsId) ==> '+permsetsExistSet.contains(existPermSetsId));
                         // if(!permsetsExistSet.contains(existPermSetsId)){
                              PermissionSetAssignment permSetAssignObj = new PermissionSetAssignment(
                                                                    PermissionSetId = existPermSetsId,
                                                                    AssigneeId = userRecId                                              
                                                                );
                          permSetAssignList.add(permSetAssignObj);
                          //}
                      }
                  }
                  else {
                      set<Id> permsetsExistSet = userPermSetsTempMap.get(userRecId);
                      set<Id> newPermSetsAddSet = userPermSetsMap.get(userRecId);
                      system.debug('*** permsetsExistSet ==> '+permsetsExistSet);
                      system.debug('*** newPermSetsAddSet ==> '+newPermSetsAddSet);
                      for(Id existPermSetsId : newPermSetsAddSet){
                      //    system.debug('*** existPermSetsId ==> '+existPermSetsId);
                      //    system.debug('*** permsetsExistSet.contains(existPermSetsId) ==> '+permsetsExistSet.contains(existPermSetsId));
                          if(!permsetsExistSet.contains(existPermSetsId)){
                              PermissionSetAssignment permSetAssignObj = new PermissionSetAssignment(
                                                                    PermissionSetId = existPermSetsId,
                                                                    AssigneeId = userRecId                                              
                                                                );
                          permSetAssignList.add(permSetAssignObj);
                          }
                      }
                  }
              }
            }
        
        system.debug('*** permSetAssignList ==> '+permSetAssignList);
        if((permSetAssignList != null) && !permSetAssignList.isEmpty()){
          //  insert permSetAssignList;
            try{
	          	Database.SaveResult[] resList = Database.insert(permSetAssignList,false);
                for (Database.SaveResult sr : resList) {
                        if (sr.isSuccess())                         
                            System.debug('Successfully inserted Permission Set: ' + sr.getId());                    
                        else{
                            for(Database.Error err : sr.getErrors())                                             
                                System.debug('Exception Occured while inserting PermisionSet-->'+err.getMessage());                                                   
                        }
                    }
            }
            Catch(Exception ex){
                system.debug('ExceptionOccured in Insert-->'+ex);
            }
        }
    }
    
    // This permission-set utility library is used to identify the users and the corresponding permissionset assignments that needed to be removed accordingly.
    // This will arise in situations whereby the user does not have an active relationship record or program enrollment record for all the students under a given school.
    public static void removePermissionSetFromUser(map<Id, set<Id>> userPermSetsMap){
                
        list<PermissionSetAssignment> permSetToDeleteList = new list<PermissionSetAssignment>();
        set<Id> permsIdTempSet = new set<Id>();
        
        for(Id userRecId : userPermSetsMap.keySet()){
            for(Id permSetId : userPermSetsMap.get(userRecId)){
                permsIdTempSet.add(permSetId);
            }
        }
        system.debug('*** permsIdTempSet ==> '+permsIdTempSet);
        
        for(PermissionSetAssignment permSetsAssignRecObj : [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment 
                                                            WHERE AssigneeId IN :userPermSetsMap.keySet() AND 
                                                            PermissionSetId IN :permsIdTempSet]){
            permSetToDeleteList.add(permSetsAssignRecObj);
        }
        
        system.debug('*** permSetToDeleteList ==> '+permSetToDeleteList);
        if((permSetToDeleteList != null) && !permSetToDeleteList.isEmpty()){
            try{
	          //  delete permSetToDeleteList;
                Database.DeleteResult [] resList = Database.delete(permSetToDeleteList,false);
                for (Database.DeleteResult  sr : resList) {
                        if (sr.isSuccess())                         
                            System.debug('Successfully deleted Permission Set: ' + sr.getId());                    
                        else{
                            for(Database.Error err : sr.getErrors())                                             
                                System.debug('Exception Occured while deleting PermisionSet-->'+err.getMessage());                                                   
                        }
                    }  
            }
            Catch(Exception ex){
                system.debug('ExceptionOccured in Delete-->'+ex);
            }
        }
    }
}