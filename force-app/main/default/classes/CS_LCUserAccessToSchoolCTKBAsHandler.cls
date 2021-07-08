/*
 * Developed By: Rakesh Ramaswamy (NESS TECHNOLOGIES)
 * User Story #. 164369
 * Description - This is a handler class used to capture the Learning Coaches access to the KBAs depending on the School that the LC falls under.
             This handler class is used by the respective batch jobs on the Program Enrollment object as well as the Relationship object.
                1. Batch Job on Program Enrollment - CS_LCUserCTPermSetsAccessProgEnrollBatch.cls
                2. Batch Job on Relationship -   CS_LCUserCTPermSetsAccessRelnshipBatch.cls   



* ChangeLog: 
Sumanth B: 11-May-2020: Included the Program Enrollment Trigger changes as part of Task # 177185 in US # 176990, 
               Added the below 2 methods
               -> CT_StdAssociatePermSets
               -> CT_StdRemovePermSets
Sumanth B/Rakesh R: 16-June-2020: Added Concatenated Status field condition to consider only Complete To Withdrawn records for processing 
								in Batchjob as per US # 186957 (Task# 195460, 195459) 

 */

public class CS_LCUserAccessToSchoolCTKBAsHandler {

    // This method is invoked from the Program Enrollment Batch processing job context.
    // This method is invoked from the batch class named - CS_LCUserCTPermSetsAccessProgEnrollBatch.cls


    public map<String, list<PermissionSetAssignment>> LCUserSchoolCTPermSetsAccessProgEnroll(set<Id> studentRecsIdSet){
        map<String, list<PermissionSetAssignment>> permissionSetsRemovalMap = new map<String, list<PermissionSetAssignment>>();
        map<String, set<Id>> schoolIdAndLCRecIdGivesActiveStudentIdSetMap = new map<String, set<Id>>();
        map<Id, set<String>> schoolIdWithSchoolIdAndLCRecIdMap = new map<Id, set<String>>();
        map<Id, set<Id>> studentIdWithSetOfLCRecIdSetMap = new map<Id, set<Id>>();        
        map<String, hed__Relationship__c> studentIdAndLCRecIdWithRelationshipsMap = new map<String, hed__Relationship__c>();
        map<String, list<hed__Relationship__c>> schoolIdAndLCRecIdWithRelationshipsMap= new map<String, list<hed__Relationship__c>>();
        map<Id, Id> stdIdSchoolIdMap = new map<Id, Id>();
        map<Id, String> schoolIdSchoolNameMap = new map<Id, String>();
        list<hed__Program_Enrollment__c> programEnrollsList = new list<hed__Program_Enrollment__c>();
        map<String, map<Id, hed__Program_Enrollment__c>> schoolIdAndLCRecIdWithStudsMostRecentPEMapMap = new map<String, map<Id, hed__Program_Enrollment__c>>();         
        
        // Added by Sumanth B to assign/revoke Permissionsets for CT & STD as part of merging the PE trigger code to the Batch
        Set<id> stdIdsWithCmpStatus = new Set<Id>(); 
        Set<id> stdIdsWithWDStatus = new Set<id>();
        Set<String> schools4CmpStds = new Set<String>();
        Set<String> schools4WDStds = new Set<String>();
        Map<String,hed__Program_Enrollment__c> WDStdIdAndSchoolMap = new Map<String,hed__Program_Enrollment__c>(); //Withdrawn Student+School,PE
        Map<Id,Id> stdCTIdAndUsrIds4WDMap = new Map<Id,Id>();
        
        
        // We are querying the most recently updated Program Enrollments for a given student across schools.
        // We are processing both the "Withdrawn" and "Complete" Program Enrollments of students to determine which takes precedence in providing access
        // to the LC Community users in association with "Former" or "Current" Relationships that are defined between a Learning Coach and Students.


         for(hed__Program_Enrollment__c programEnrollObj : [SELECT Id, Name, Concatenated_Status__c, School_Name__c, School_Account_ID__c, hed__Account__c, 
                                                            hed__Contact__c, Status__c, hed__Contact__r.Name,Contact_RecordType__c,
                                                            Enrollment_Type__c,hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,Old_Status__c
                                    FROM hed__Program_Enrollment__c 
                                    WHERE hed__Contact__c IN :studentRecsIdSet                               
                                AND ((Status__c = :CS_Constants.PE_COMPLETE_STATUS) 
                                    OR ( 
                                          Status__c = :CS_Constants.PE_WITHDRAWN_STATUS 
                                          AND 
                                          Concatenated_Status__c =: CS_Constants.PE_COMPLETE_WITHDRAWN_STATUS 
                                       ) 
                                    OR (
                                          Status__c = :CS_Constants.PE_IN_PROGRESS_STATUS 
                                          AND 
                                          Concatenated_Status__c = :CS_Constants.PE_COMPLETE_IN_PROGRESS_STATUS
                                        )
                                    )
                                    ORDER BY LastModifiedDate DESC]
            ){  
       if(!stdIdSchoolIdMap.containsKey(programEnrollObj.hed__Contact__c)){
                stdIdSchoolIdMap.put(programEnrollObj.hed__Contact__c, programEnrollObj.School_Account_ID__c);
                System.debug('Printing stdIdschoolIdMap with student as key'+stdIdSchoolIdMap);
       }

           if(!schoolIdSchoolNameMap.containsKey(programEnrollObj.School_Account_ID__c)){
                schoolIdSchoolNameMap.put(programEnrollObj.School_Account_ID__c, programEnrollObj.School_Name__c);

                System.debug('Printing stdIdschoolIdNameMap with School as key'+schoolIdSchoolNameMap);
           }
                   
           programEnrollsList.add(programEnrollObj);
           
           // Added by Sumanth B to assign/revoke Permissionsets for CT & STD as part of merging the PE trigger code to the Batch


           if((programEnrollObj.Status__c != null) && (programEnrollObj.Status__c == CS_Constants.PE_COMPLETE_STATUS) && (programEnrollObj.Contact_RecordType__c == 'Students'))
           {
                if(programEnrollObj.hed__Contact__c <> null && programEnrollObj.School_Name__c <> null)
                {
                    stdIdsWithCmpStatus.add(programEnrollObj.hed__Contact__c);
                    schools4CmpStds.add(programEnrollObj.School_Name__c);
                }
           }
           else


           if(                
                    (
                        ( 	
                            (programEnrollObj.Status__c != null) &&	
                            (programEnrollObj.Status__c == CS_Constants.PE_WITHDRAWN_STATUS) &&                             
                            (programEnrollObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_WITHDRAWN_STATUS)                            
                        ) ||
                        (
                            (programEnrollObj.Status__c != null) &&
                            (programEnrollObj.Status__c == CS_Constants.PE_IN_PROGRESS_STATUS) &&                                                          
                            (programEnrollObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_IN_PROGRESS_STATUS)                             
                        )
                    ) &&
                (programEnrollObj.Contact_RecordType__c == 'Students')
            )
           {
                if(programEnrollObj.hed__Contact__c <> null && programEnrollObj.School_Name__c <> null)
                {
                    stdIdsWithWDStatus.add(programEnrollObj.hed__Contact__c);
                    schools4WDStds.add(programEnrollObj.School_Name__c);
                    stdCTIdAndUsrIds4WDMap.put(programEnrollObj.hed__Contact__r.Caretaker_Id__c,programEnrollObj.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id);
                    //Holds the Std-School,pe record who are withdrawn
                    WDStdIdAndSchoolMap.put(programEnrollObj.hed__Contact__c + '-' + programEnrollObj.School_Name__c, programEnrollObj); 
                }
           }
    }
       
        // Here we are determining the Student and corresponding Learning Coaches that are related to the Relationship records associated to the Program Enrollment records through the respective Students.
        // We are determining who are the Learning Coaches associated to each given student in the process of contexting different relationship records here.
        for(hed__Relationship__c relationRecObj : [SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Status__c, hed__RelatedContact__c, hed__RelatedContact__r.Name FROM hed__Relationship__c WHERE (hed__Type__c = :CS_Constants.LEARNING_COACH_TYPE) AND (hed__Contact__c IN :studentRecsIdSet)]){
            // Identifying Relationship records mapping for a given Student and associated Learning Coach
            if(!studentIdAndLCRecIdWithRelationshipsMap.containsKey(String.valueOf(relationRecObj.hed__Contact__c)+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c))){
                studentIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(relationRecObj.hed__Contact__c)+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c), relationRecObj);

               System.debug('Printing studentIdAndLCRecIdWithRelationshipsMap with student as key'+studentIdAndLCRecIdWithRelationshipsMap); 
            }
            
            // Identifying for a given student who are the associated Learning Coaches.
            if(!studentIdWithSetOfLCRecIdSetMap.containsKey(relationRecObj.hed__Contact__c)){
                set<Id> relatedLCRecsIdSet = new set<Id>();
                relatedLCRecsIdSet.add(relationRecObj.hed__RelatedContact__c);
                studentIdWithSetOfLCRecIdSetMap.put(relationRecObj.hed__Contact__c, relatedLCRecsIdSet);

            }
            else{
                set<Id> relatedLCRecsIdSet = studentIdWithSetOfLCRecIdSetMap.get(relationRecObj.hed__Contact__c);
                relatedLCRecsIdSet.add(relationRecObj.hed__RelatedContact__c);
                studentIdWithSetOfLCRecIdSetMap.put(relationRecObj.hed__Contact__c, relatedLCRecsIdSet);

            }            

            System.debug('student with Learning coaches with student as key'+studentIdWithSetOfLCRecIdSetMap);
        }
        
        // Here we are determining at the School level and for each given Learning Coach what are the different Relationship records that the Learning Coach is associated with.        
        for(hed__Relationship__c relationRecObj : studentIdAndLCRecIdWithRelationshipsMap.values()){            
            // Identifying which relationship records are present under a given School and for a given Learning Coach is concerned.            
            if(!schoolIdAndLCRecIdWithRelationshipsMap.containsKey(String.valueOf(stdIdSchoolIdMap.get(relationRecObj.hed__Contact__c))+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c))){
              list<hed__Relationship__c> relationsTempList = new list<hed__Relationship__c>();
              relationsTempList.add(relationRecObj);
              schoolIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(stdIdSchoolIdMap.get(relationRecObj.hed__Contact__c))+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c), relationsTempList);

            }
            else{
              list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(String.valueOf(stdIdSchoolIdMap.get(relationRecObj.hed__Contact__c))+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c));
              relationsTempList.add(relationRecObj);
              schoolIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(stdIdSchoolIdMap.get(relationRecObj.hed__Contact__c))+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c), relationsTempList);
            }

            System.debug('Identify Learning coach and other Relationshiprecords--->'+schoolIdAndLCRecIdWithRelationshipsMap);
        }                       
        
       // Here we are deciphering for each School and each given Learning Coach as part of the data setup, what are the different most recent Program Enrollment records that are associated to the different students.
       // Only the most recently updated Program Enrollment needs to be picked for each student falling under a school in determining whether access should be provisioned to the Learning Coach for that school provided there are no
       // other students who do not also have completed enrollments and active current relationships with the given Learning Coach is concerned.              
       for(Id studentRecId : studentIdWithSetOfLCRecIdSetMap.keySet()){                
            set<Id> LCRecsIdSet = studentIdWithSetOfLCRecIdSetMap.get(studentRecId);
            for(Id LCRecId : LCRecsIdSet){
               for(hed__Program_Enrollment__c programEnrollObj : programEnrollsList){
                     if(programEnrollObj.hed__Contact__c == studentRecId){                                                
                            if(!schoolIdWithSchoolIdAndLCRecIdMap.containsKey(programEnrollObj.School_Account_ID__c)){
                                    set<String> studRecIdWithLCRecIdSet = new set<String>();
                                    studRecIdWithLCRecIdSet.add(String.valueOf(programEnrollObj.School_Account_ID__c)+'-'+String.valueOf(LCRecId));
                                    schoolIdWithSchoolIdAndLCRecIdMap.put(programEnrollObj.School_Account_ID__c, studRecIdWithLCRecIdSet);
                              }
                              else{
                                    set<String> studRecIdWithLCRecIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(programEnrollObj.School_Account_ID__c);
                                    studRecIdWithLCRecIdSet.add(String.valueOf(programEnrollObj.School_Account_ID__c)+'-'+String.valueOf(LCRecId));
                                    schoolIdWithSchoolIdAndLCRecIdMap.put(programEnrollObj.School_Account_ID__c, studRecIdWithLCRecIdSet);
                              } 

                            System.debug('Identify Learning coach and other Relationshiprecords--->'+schoolIdWithSchoolIdAndLCRecIdMap);
                             if(!schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId))){
                                map<Id, hed__Program_Enrollment__c> studIdAndProgramEnrollTempMap = new map<Id, hed__Program_Enrollment__c>();
                                studIdAndProgramEnrollTempMap.put(studentRecId, programEnrollObj);                
                                schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.put(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId), studIdAndProgramEnrollTempMap);
                                }
                                else{
                                    map<Id, hed__Program_Enrollment__c> studIdAndProgramEnrollTempMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId));
                                    if(!studIdAndProgramEnrollTempMap.containsKey(studentRecId)){
                                        studIdAndProgramEnrollTempMap.put(studentRecId, programEnrollObj);
                                        schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.put(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId), studIdAndProgramEnrollTempMap);
                                    }                  
                                }                                                                                    
                         }
                    }
                }
            }
       
       // Here we are trying to capture all the active students that are associated to any given Learning Coach and School at any given point of time.
       // Active students meaning student who has completed program enrollment and also has active current relationship with the concerned Learning Coach.
       // This map collection constructed here is being used to determine whether access to the CT permission-set for a given school should be retained or removed
       // for a given Learning Coach being processed. This will help us at the time of the revoking procedure.
       for(String schoolAcctId : schoolIdWithSchoolIdAndLCRecIdMap.keySet()){         
         if(schoolAcctId != null) {            
            set<String> schoolRecIdAndLCRedIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(schoolAcctId);
          for(String schoolRecIdAndLCRedId : schoolRecIdAndLCRedIdSet){                
                String[] schoolRecIdAndLCRedIdArray = schoolRecIdAndLCRedId.split('-');                
                String schoolRecId = schoolRecIdAndLCRedIdArray.get(0);                
                String LCRecId = schoolRecIdAndLCRedIdArray.get(1);                         
               if(!schoolIdAndLCRecIdGivesActiveStudentIdSetMap.containsKey(schoolRecId+'-'+LCRecId)){
                   set<Id> activeStudentsIdSet = new set<Id>();
                   if(schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(schoolRecId+'-'+LCRecId) && schoolIdAndLCRecIdWithRelationshipsMap.containsKey(schoolRecId+'-'+LCRecId)) {
                       map<Id, hed__Program_Enrollment__c> studentIdMostRecentPEMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecId+'-'+LCRecId);
                       list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecId+'-'+LCRecId);
                       for(hed__Relationship__c relationRecObj : relationsTempList){                           
                           if((relationRecObj.hed__Status__c != null) && relationRecObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) && studentIdMostRecentPEMap.containsKey(relationRecObj.hed__Contact__c)){                               
                               hed__Program_Enrollment__c progEnrollTempObj = studentIdMostRecentPEMap.get(relationRecObj.hed__Contact__c);                               
                               if((progEnrollTempObj.Status__c != null) && (progEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS))){
                                   activeStudentsIdSet.add(progEnrollTempObj.hed__Contact__c);                                  
                               }
                           }
                       }
                   }
                      schoolIdAndLCRecIdGivesActiveStudentIdSetMap.put(schoolRecId+'-'+LCRecId, activeStudentsIdSet);                   
               }
               else {
                   set<Id> activeStudentsIdSet = schoolIdAndLCRecIdGivesActiveStudentIdSetMap.get(schoolRecId+'-'+LCRecId);
                   if(schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(schoolRecId+'-'+LCRecId) && schoolIdAndLCRecIdWithRelationshipsMap.containsKey(schoolRecId+'-'+LCRecId)) {
                       map<Id, hed__Program_Enrollment__c> studentIdMostRecentPEMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecId+'-'+LCRecId);
                       list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecId+'-'+LCRecId);
                       for(hed__Relationship__c relationRecObj : relationsTempList){
                           if((relationRecObj.hed__Status__c != null) && relationRecObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) && studentIdMostRecentPEMap.containsKey(relationRecObj.hed__Contact__c)){
                               hed__Program_Enrollment__c progEnrollTempObj = studentIdMostRecentPEMap.get(relationRecObj.hed__Contact__c);
                               if((progEnrollTempObj.Status__c != null) && (progEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS))){
                                   activeStudentsIdSet.add(progEnrollTempObj.hed__Contact__c);                                   
                               }
                           }
                       }
                   }
                   
                   schoolIdAndLCRecIdGivesActiveStudentIdSetMap.put(schoolRecId+'-'+LCRecId, activeStudentsIdSet);
               }               
         }
      }    
    }
     
     // Here we are processing at the school level every matching relationship record with the corresponding Program Enrollment record through the student look-up association to determine
     // whether access should be provisioned to the LC Community user or not.
     // We are using a wrapper class and two map collections on the wrapper class to understand the removal states and the provisioning of the permission-sets is concerned for each LC user in the batch processing context.   
    for(String schoolAcctId : schoolIdWithSchoolIdAndLCRecIdMap.keySet()){         
         if(schoolAcctId != null) {                        
            set<String> schoolRecIdAndLCRedIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(schoolAcctId);
            for(String schoolRecIdAndLCRedId : schoolRecIdAndLCRedIdSet){                
                String[] schoolRecIdAndLCRedIdArray = schoolRecIdAndLCRedId.split('-');                
                String schoolRecId = schoolRecIdAndLCRedIdArray.get(0);                
                String LCRecId = schoolRecIdAndLCRedIdArray.get(1);               
                // For a given school is concerned processing all the associated Relationship Records and associated Program Enrollment records through the related Student records.
                // To help determine when access should be provisioned to a Learning Coach Community User to the CT Permission Sets defined for each School in the system.               
                list<hed__Relationship__c> relationshipRecsList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecIdAndLCRedId);                                
                map<Id, hed__Program_Enrollment__c> programEnrollMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecIdAndLCRedId);                

                list<hed__Program_Enrollment__c> programEnrollsTempList = new list<hed__Program_Enrollment__c>();
                if((programEnrollMap != null) && !programEnrollMap.isEmpty()){
                    programEnrollsTempList =  programEnrollMap.values();      
                }                              
                if((relationshipRecsList != null) && (programEnrollsTempList != null)){                   
                    for(hed__Relationship__c relationTempObj : relationshipRecsList){                       
                        for(hed__Program_Enrollment__c programEnrollTempObj : programEnrollsTempList){                                                       
                            if(programEnrollTempObj.hed__Contact__c == relationTempObj.hed__Contact__c){
                            if((relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS) && (programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_WITHDRAWN_STATUS)){
                                 if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                    if(!CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                        CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsRemoveAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, false, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                        CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsRemoveAccessWrapperObj);
                                    }
                                 }                                
                                 break;
                            }
                             // processing the wrapper instance seperately for providing access and removal of access to the permission sets.
                             // The wrapper holds the state depending on whether the LC User has to be provided with the access or de-provisioned with the access accordingly.   
                            if((programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS) && (relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS)){                                                           
                                   if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                       CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsProvideAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, true, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                       CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsProvideAccessWrapperObj);
                                    }
                                
                                   if(CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                        CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.remove(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c));
                                   }                                 
                                   break;
                                }
                             if(


                                (
                                    (programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS) && (relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS)) ||
                                    (
                                        (
                                            (
                                                (programEnrollTempObj.Status__c != null) && 
                                                (programEnrollTempObj.Status__c.equals(CS_Constants.PE_WITHDRAWN_STATUS)) &&                                                                                     		                                                                                                                                                     
                                                (programEnrollTempObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_WITHDRAWN_STATUS)                                                   
                                            ) ||
                                            (
                                                (programEnrollTempObj.Status__c != null) && 
                                                (programEnrollTempObj.Status__c == CS_Constants.PE_IN_PROGRESS_STATUS) && 
                                                (programEnrollTempObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_IN_PROGRESS_STATUS)
                                            )                                                                            
                                        ) &&                                      
                                        (
                                            (relationTempObj.hed__Status__c != null) && 
                                            (
                                                relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) ||
                                                relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS)
                                            )
                                        )
                                    )
                                )
                             {                                                                          
                                  if(schoolIdAndLCRecIdGivesActiveStudentIdSetMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                         set<Id> activeStudentsIdSet = schoolIdAndLCRecIdGivesActiveStudentIdSetMap.get(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c));
                                         if(activeStudentsIdSet.isEmpty() || !activeStudentsIdSet.contains(programEnrollTempObj.hed__Contact__c)){
                                            if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                                if(!CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                                    CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsRemoveAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, false, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                                    CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsRemoveAccessWrapperObj);
                                                }
                                            }
                                         }
                                    }                                  
                                   
                                }                                                                                                                                                                                                                                                                                 
                           }
                      }                                                
                  }
               }
          }
        }
      }                                                       
        
    list<PermissionSetAssignment> permSetAssignTempList = new list<PermissionSetAssignment>();
    
    // Processing the access provisioning wrapper map collection to identify those LC Community Users who should be given the permission-sets access.
    if((CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap != null) && !CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.isEmpty()){
      permSetAssignTempList = associatePermSetsToLCUsers(CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap);
    }
    


    list<PermissionSetAssignment> permSetAssignDeleteList = new list<PermissionSetAssignment>();
    // Processing the access removal wrapper map collection to identify those LC Community Users who should not be given the permission-sets access.
    if((CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap != null) && !CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.isEmpty()){
        permSetAssignDeleteList = revokePermSetsToLCUsers(CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap, permSetAssignTempList);
        permissionSetsRemovalMap.put('To Delete', permSetAssignDeleteList);
    }
     
        // Added by Sumanth B to assign Permissionsets for CT & STD as part of merging the PE trigger code to the Batch
        system.debug('stdIdsWithCmpStatus ===> '+stdIdsWithCmpStatus);
        system.debug('schools4CmpStds ===> '+schools4CmpStds);
        if(stdIdsWithCmpStatus.size() > 0)
            CT_StdAssociatePermSets(stdIdsWithCmpStatus,schools4CmpStds);
        // Added by Sumanth B to remove Permissionsets from CT & STD as part of merging the PE trigger code to the Batch
        system.debug('stdIdsWithWDStatus ===> '+stdIdsWithWDStatus);
        system.debug('schools4WDStds ===> '+schools4WDStds);
        system.debug('stdCTIdAndUsrIds4WDMap ===> '+stdCTIdAndUsrIds4WDMap);
        system.debug('WDStdIdAndSchoolMap ===> '+WDStdIdAndSchoolMap);
        if(stdIdsWithWDStatus.size() > 0)
            CT_StdRemovePermSets(stdIdsWithWDStatus,stdCTIdAndUsrIds4WDMap,schools4WDStds,WDStdIdAndSchoolMap);    
        


        return permissionSetsRemovalMap;
  }        
  
    // This method is invoked from the Relationship batch-job processing context.
    // Relationship Batch Class Name - CS_LCUserCTPermSetsAccessRelnshipBatch.cls


    public map<String, list<PermissionSetAssignment>> processRelationshipRecsForCTPermSetsAccess(map<Id, set<Id>> studentIdWithSetOfLCRecIdSetMap, map<String, hed__Relationship__c> studentIdAndLCRecIdWithRelationshipsMap){
        map<String, list<PermissionSetAssignment>> permissionSetsRemovalMap = new map<String, list<PermissionSetAssignment>>();
        map<String, map<Id, hed__Program_Enrollment__c>> schoolIdAndLCRecIdWithStudsMostRecentPEMapMap = new map<String, map<Id, hed__Program_Enrollment__c>>();
        map<String, set<Id>> schoolIdAndLCRecIdGivesActiveStudentIdSetMap = new map<String, set<Id>>();    
        map<Id, Id> stdIdSchoolIdMap = new map<Id, Id>();
        map<Id, String> schoolIdSchoolNameMap = new map<Id, String>();
        map<Id, set<String>> schoolIdWithSchoolIdAndLCRecIdMap = new map<Id, set<String>>();    
        map<String, list<hed__Relationship__c>> schoolIdAndLCRecIdWithRelationshipsMap= new map<String, list<hed__Relationship__c>>();      
        list<hed__Program_Enrollment__c> programEnrollsList = new list<hed__Program_Enrollment__c>();

        for(hed__Program_Enrollment__c programEnrollObj : [SELECT Id, Name, School_Name__c, School_Account_ID__c, hed__Account__c, 


                                                                         hed__Contact__c, Status__c, hed__Contact__r.Name, Concatenated_Status__c
                                          FROM hed__Program_Enrollment__c 
                                          WHERE hed__Contact__c IN :studentIdWithSetOfLCRecIdSetMap.keySet()                                       
                                            AND ((Status__c = :CS_Constants.PE_COMPLETE_STATUS) 
                                            OR ( 
                                                  Status__c = :CS_Constants.PE_WITHDRAWN_STATUS 
                                                  AND 
                                                  Concatenated_Status__c =: CS_Constants.PE_COMPLETE_WITHDRAWN_STATUS                                                                                                     
                                               ) 
                                            OR (
                                                 Status__c = :CS_Constants.PE_IN_PROGRESS_STATUS                                                 
                                                 AND 
                                                 Concatenated_Status__c = :CS_Constants.PE_COMPLETE_IN_PROGRESS_STATUS                                                                                                           
                                               )
                                            )
                                                ORDER BY LastModifiedDate DESC]
            ){
                      
          if(!stdIdSchoolIdMap.containsKey(programEnrollObj.hed__Contact__c)){
            stdIdSchoolIdMap.put(programEnrollObj.hed__Contact__c, programEnrollObj.School_Account_ID__c);
          }
               
          if(!schoolIdSchoolNameMap.containsKey(programEnrollObj.School_Account_ID__c)){
            schoolIdSchoolNameMap.put(programEnrollObj.School_Account_ID__c, programEnrollObj.School_Name__c);
          }

        for(Id studentRecId : studentIdWithSetOfLCRecIdSetMap.keySet()){                
                set<Id> LCRecsIdSet = studentIdWithSetOfLCRecIdSetMap.get(studentRecId);
                for(Id LCRecId : LCRecsIdSet){
                    if(programEnrollObj.hed__Contact__c == studentRecId){                                                
                          if(!schoolIdWithSchoolIdAndLCRecIdMap.containsKey(programEnrollObj.School_Account_ID__c)){
                                set<String> studRecIdWithLCRecIdSet = new set<String>();
                                studRecIdWithLCRecIdSet.add(String.valueOf(programEnrollObj.School_Account_ID__c)+'-'+String.valueOf(LCRecId));
                                schoolIdWithSchoolIdAndLCRecIdMap.put(programEnrollObj.School_Account_ID__c, studRecIdWithLCRecIdSet);
                          }
                          else{
                                set<String> studRecIdWithLCRecIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(programEnrollObj.School_Account_ID__c);
                                studRecIdWithLCRecIdSet.add(String.valueOf(programEnrollObj.School_Account_ID__c)+'-'+String.valueOf(LCRecId));
                                schoolIdWithSchoolIdAndLCRecIdMap.put(programEnrollObj.School_Account_ID__c, studRecIdWithLCRecIdSet);
                          }                        
                     }                                        
                }
            }  
       programEnrollsList.add(programEnrollObj);                                                                                          
     }
        
        for(Id studentRecId : studentIdWithSetOfLCRecIdSetMap.keySet()){  
        set<Id> LCRecIdSet = studentIdWithSetOfLCRecIdSetMap.get(studentRecId);
                
         for(Id LCRecId : LCRecIdSet) {        
            for(hed__Program_Enrollment__c programEnrollObj : programEnrollsList){              
              if(studentRecId == programEnrollObj.hed__Contact__c){
                if(!schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId))){
                  map<Id, hed__Program_Enrollment__c> studIdAndProgramEnrollTempMap = new map<Id, hed__Program_Enrollment__c>();
                  studIdAndProgramEnrollTempMap.put(studentRecId, programEnrollObj);                
                  schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.put(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId), studIdAndProgramEnrollTempMap);
                }
                else{
                  map<Id, hed__Program_Enrollment__c> studIdAndProgramEnrollTempMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId));
                  if(!studIdAndProgramEnrollTempMap.containsKey(studentRecId)){
                    studIdAndProgramEnrollTempMap.put(studentRecId, programEnrollObj);
                    schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.put(String.valueOf(stdIdSchoolIdMap.get(studentRecId))+'-'+String.valueOf(LCRecId), studIdAndProgramEnrollTempMap);
                  }                  
                }  
              }
            }
          }        
      }
    
    for(hed__Relationship__c relationshipRecObj : studentIdAndLCRecIdWithRelationshipsMap.values()){
      if(!schoolIdAndLCRecIdWithRelationshipsMap.containsKey(String.valueOf(stdIdSchoolIdMap.get(relationshipRecObj.hed__Contact__c))+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c))){
          list<hed__Relationship__c> relationsTempList = new list<hed__Relationship__c>();
          relationsTempList.add(relationshipRecObj);
          schoolIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(stdIdSchoolIdMap.get(relationshipRecObj.hed__Contact__c))+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c), relationsTempList);
        }
        else{
          list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(String.valueOf(stdIdSchoolIdMap.get(relationshipRecObj.hed__Contact__c))+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c));
          relationsTempList.add(relationshipRecObj);
          schoolIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(stdIdSchoolIdMap.get(relationshipRecObj.hed__Contact__c))+'-'+String.valueOf(relationshipRecObj.hed__RelatedContact__c), relationsTempList);
        }
     }
    
    for(String schoolAcctId : schoolIdWithSchoolIdAndLCRecIdMap.keySet()){         
         if(schoolAcctId != null) {            
            set<String> schoolRecIdAndLCRedIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(schoolAcctId);
            for(String schoolRecIdAndLCRedId : schoolRecIdAndLCRedIdSet){                
                String[] schoolRecIdAndLCRedIdArray = schoolRecIdAndLCRedId.split('-');               
                String schoolRecId = schoolRecIdAndLCRedIdArray.get(0);               
                String LCRecId = schoolRecIdAndLCRedIdArray.get(1);                                    
                if(!schoolIdAndLCRecIdGivesActiveStudentIdSetMap.containsKey(schoolRecId+'-'+LCRecId)){
                   set<Id> activeStudentsIdSet = new set<Id>();
                   if(schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(schoolRecId+'-'+LCRecId) && schoolIdAndLCRecIdWithRelationshipsMap.containsKey(schoolRecId+'-'+LCRecId)) {
                       map<Id, hed__Program_Enrollment__c> studentIdMostRecentPEMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecId+'-'+LCRecId);
                       list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecId+'-'+LCRecId);
                       for(hed__Relationship__c relationRecObj : relationsTempList){                           
                           if((relationRecObj.hed__Status__c != null) && relationRecObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) && studentIdMostRecentPEMap.containsKey(relationRecObj.hed__Contact__c)){                               
                               hed__Program_Enrollment__c progEnrollTempObj = studentIdMostRecentPEMap.get(relationRecObj.hed__Contact__c);                              
                               if((progEnrollTempObj.Status__c != null) && (progEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS))){
                                   activeStudentsIdSet.add(progEnrollTempObj.hed__Contact__c);
                               }
                           }
                       }
                   }
                schoolIdAndLCRecIdGivesActiveStudentIdSetMap.put(schoolRecId+'-'+LCRecId, activeStudentsIdSet);                   
               }
               else {
                   set<Id> activeStudentsIdSet = schoolIdAndLCRecIdGivesActiveStudentIdSetMap.get(schoolRecId+'-'+LCRecId);
                   if(schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.containsKey(schoolRecId+'-'+LCRecId) && schoolIdAndLCRecIdWithRelationshipsMap.containsKey(schoolRecId+'-'+LCRecId)) {
                       map<Id, hed__Program_Enrollment__c> studentIdMostRecentPEMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecId+'-'+LCRecId);
                       list<hed__Relationship__c> relationsTempList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecId+'-'+LCRecId);
                       for(hed__Relationship__c relationRecObj : relationsTempList){
                           if((relationRecObj.hed__Status__c != null) && relationRecObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) && studentIdMostRecentPEMap.containsKey(relationRecObj.hed__Contact__c)){
                               hed__Program_Enrollment__c progEnrollTempObj = studentIdMostRecentPEMap.get(relationRecObj.hed__Contact__c);
                               if((progEnrollTempObj.Status__c != null) && (progEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS))){
                                   activeStudentsIdSet.add(progEnrollTempObj.hed__Contact__c);                                   
                               }
                           }
                       }
                   }
                   
                   schoolIdAndLCRecIdGivesActiveStudentIdSetMap.put(schoolRecId+'-'+LCRecId, activeStudentsIdSet);
               }               
         }
      }    
    }        
        
     for(String schoolAcctId : schoolIdWithSchoolIdAndLCRecIdMap.keySet()){         
         if(schoolAcctId != null) {           
            set<String> schoolRecIdAndLCRedIdSet = schoolIdWithSchoolIdAndLCRecIdMap.get(schoolAcctId);
            for(String schoolRecIdAndLCRedId : schoolRecIdAndLCRedIdSet){
                String[] schoolRecIdAndLCRedIdArray = schoolRecIdAndLCRedId.split('-');                
                String schoolRecId = schoolRecIdAndLCRedIdArray.get(0);                
                String LCRecId = schoolRecIdAndLCRedIdArray.get(1);                             
                list<hed__Relationship__c> relationshipRecsList = schoolIdAndLCRecIdWithRelationshipsMap.get(schoolRecIdAndLCRedId);
                map<Id, hed__Program_Enrollment__c> programEnrollMap = schoolIdAndLCRecIdWithStudsMostRecentPEMapMap.get(schoolRecIdAndLCRedId);

                list<hed__Program_Enrollment__c> programEnrollsTempList = new list<hed__Program_Enrollment__c>();
                if((programEnrollMap != null) && !programEnrollMap.isEmpty()){
               	  programEnrollsTempList = programEnrollMap.values();
                }
             if((relationshipRecsList != null) && (programEnrollsTempList != null)){                               
                    for(hed__Relationship__c relationTempObj : relationshipRecsList){                       
                        for(hed__Program_Enrollment__c programEnrollTempObj : programEnrollsTempList){                                                                           
                            if(programEnrollTempObj.hed__Contact__c == relationTempObj.hed__Contact__c){
                            if((relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS) && (programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_WITHDRAWN_STATUS)){
                                 if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                    if(!CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                        CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsRemoveAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, false, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                        CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsRemoveAccessWrapperObj);
                                    }
                                 }                                                           
                                 break;
                            }
                            if((programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS) && (relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS)){                                                              
                                   if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                       CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsProvideAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, true, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                       CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsProvideAccessWrapperObj);
                                    }
                                
                                   if(CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                        CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.remove(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c));
                                   }
                                   break;
                                }
                               if(


                                (
                                    (programEnrollTempObj.Status__c != null) && programEnrollTempObj.Status__c.equals(CS_Constants.PE_COMPLETE_STATUS) && (relationTempObj.hed__Status__c != null) && relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS)) ||
                                    (
                                        (
                                            (
                                                (programEnrollTempObj.Status__c != null) && 
                                                (programEnrollTempObj.Status__c.equals(CS_Constants.PE_WITHDRAWN_STATUS)) &&                                                                                     		                                                                                                                                                     
                                                (programEnrollTempObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_WITHDRAWN_STATUS)                                                   
                                            ) ||
                                            (
                                                (programEnrollTempObj.Status__c != null) && 
                                                (programEnrollTempObj.Status__c == CS_Constants.PE_IN_PROGRESS_STATUS) && 
                                                (programEnrollTempObj.Concatenated_Status__c == CS_Constants.PE_COMPLETE_IN_PROGRESS_STATUS)
                                            )                                                                            
                                        ) &&                                      
                                        (
                                            (relationTempObj.hed__Status__c != null) && 
                                            ( 
                                                relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_CURRENT_STATUS) ||
                                                relationTempObj.hed__Status__c.equals(CS_Constants.RELATIONSHIP_FORMER_STATUS)
                                            )
                                        )
                                    )
                                )
                             {
                  if(schoolIdAndLCRecIdGivesActiveStudentIdSetMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                         set<Id> activeStudentsIdSet = schoolIdAndLCRecIdGivesActiveStudentIdSetMap.get(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c));
                                         if(activeStudentsIdSet.isEmpty() || !activeStudentsIdSet.contains(programEnrollTempObj.hed__Contact__c)){
                                            if(!CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                                if(!CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.containsKey(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c))){
                                                    CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsRemoveAccessWrapperObj = new CS_LCUserCTPermSetsAccessWrapper(String.valueOf(programEnrollTempObj.School_Account_ID__c), schoolIdSchoolNameMap.get(programEnrollTempObj.School_Account_ID__c), programEnrollTempObj.hed__Contact__c, relationTempObj.hed__RelatedContact__c, programEnrollTempObj.Status__c, programEnrollTempObj.Name, false, relationTempObj.hed__Status__c, relationTempObj.Name, relationTempObj);
                                                    CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.put(String.valueOf(programEnrollTempObj.School_Account_ID__c)+'-'+String.valueOf(relationTempObj.hed__RelatedContact__c), LCUserCTPermSetsRemoveAccessWrapperObj);
                                                }
                                            }
                                         }
                                    }
                             }
                          }
                      }                    
                  }
              }
          }
        }
      }           
                
    list<PermissionSetAssignment> permSetAssignTempList = new list<PermissionSetAssignment>();
    

    // Provisioning of Permission-Sets related to KBAs to Learning Coaches is handled here during the Relationships Batch Logic execution.
    if((CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap != null) && !CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap.isEmpty()){
      permSetAssignTempList = associatePermSetsToLCUsers(CS_Constants.LCUserCTPermSetsProvideAccessWrapperMap);
    }
    


    list<PermissionSetAssignment> permSetAssignDeleteList = new list<PermissionSetAssignment>();
    // Revoking of Permission-Sets related to KBAs to Learning Coaches is handled here during the Relationships Batch Logic execution.
    if((CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap != null) && !CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap.isEmpty()){
        permSetAssignDeleteList = revokePermSetsToLCUsers(CS_Constants.LCUserCTPermSetsRemoveAccessWrapperMap, permSetAssignTempList);
        permissionSetsRemovalMap.put('To Delete', permSetAssignDeleteList);
    }

    return permissionSetsRemovalMap;
    }
  
  // This method is responsible for the provisioning of permission-sets to the users (Learning Coach).
  public list<PermissionSetAssignment> associatePermSetsToLCUsers(map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsProvideAccessWrapperMap){
    
    map<Id, Id> studIdSchoolIdTempMap = new map<Id, Id>();
        map<Id, String> studIdSchoolNameTempMap = new map<Id, String>();
    map<String,String> schoolNameCTPermSetMap = new map<String,String>();
    map<String, Id> pSetNameIdMap = new Map<String, Id>();
    map<Id,Id> LCContactIdLCUsrIdMap = new map<Id,Id>();
    set<Id> LCRecIdsSet = new set<Id>();

    system.debug('LCUserCTPermSetsProvideAccessWrapperMap-->'+LCUserCTPermSetsProvideAccessWrapperMap);
      
    // preparing the association between students and the schools that they represent.
    // identifying all the Learning Coaches to whom permission-sets access needs to be provisioned.
    for(String schoolRecIdAndLCRecId : LCUserCTPermSetsProvideAccessWrapperMap.keySet()){
            CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsProvideAccessWrapperObj = LCUserCTPermSetsProvideAccessWrapperMap.get(schoolRecIdAndLCRecId);
            if((LCUserCTPermSetsProvideAccessWrapperObj.schoolName != null) && (LCUserCTPermSetsProvideAccessWrapperObj.studentRecId != null)){
                studIdSchoolNameTempMap.put(LCUserCTPermSetsProvideAccessWrapperObj.studentRecId, LCUserCTPermSetsProvideAccessWrapperObj.schoolName);
            }
      
            if(LCUserCTPermSetsProvideAccessWrapperObj.LCRecId != null){
                LCRecIdsSet.add(LCUserCTPermSetsProvideAccessWrapperObj.LCRecId);
              }
        }
        
    // Capturing all the school names and their associated CareTaker Permission Set Names in a map collection.
    for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                                      FROM CS_School_PermissionSet_Mapping__mdt 
                                                                      WHERE School_Name__c IN : studIdSchoolNameTempMap.values()])
        {
            schoolNameCTPermSetMap.put(scPS.School_Name__c,scPS.Caretaker_PSet__c); //SchoolName, SchoolPermissionSet
        }
    
    // Preparing a map collection to identify the caretaker permission-set names and their salesforce record ids in the system.
    for(PermissionSet pSet : [SELECT Id,name FROM PermissionSet WHERE Name IN : schoolNameCTPermSetMap.values()])
        {
            pSetNameIdMap.put(pSet.Name,pSet.Id);  //PermissionSetName, Id
        }
    
    // Determining the user record Ids of the corresponding LC User existing as Contact also in the systems.
    // This is related to Customer Portal Enablement concept.
    for(User usr : [SELECT ContactId, Id FROM User WHERE ContactId IN :LCRecIdsSet])
        {
            LCContactIdLCUsrIdMap.put(usr.ContactId,usr.Id);
        }

    system.debug('LCContactIdLCUsrIdMap-->'+LCContactIdLCUsrIdMap);
    list<PermissionSetAssignment> permSetAssignList = new list<PermissionSetAssignment>();
    list<PermissionSetAssignment> permSetAssignTempList = new list<PermissionSetAssignment>();
    list<PermissionSetAssignment> permSetAssignFinalList = new list<PermissionSetAssignment>();
    set<Id> userRecIdsSet = new set<Id>();
    set<Id> permSetRecIdsSet = new set<Id>();
    map<String, PermissionSetAssignment> userRecIdAndPermSetIdGivesPermSetAssignMap = new map<String, PermissionSetAssignment>();
        
    for(CS_LCUserCTPermSetsAccessWrapper LCAccessWrapperObj : LCUserCTPermSetsProvideAccessWrapperMap.values()){
      String permSetId;
      String userId;
      
      if(LCAccessWrapperObj.schoolName != null){
        if(schoolNameCTPermSetMap.containsKey(LCAccessWrapperObj.schoolName)){
              permSetId = pSetNameIdMap.get(schoolNameCTPermSetMap.get(LCAccessWrapperObj.schoolName));
              permSetRecIdsSet.add(permSetId);
        }
      }
      
      if(LCAccessWrapperObj.LCRecId != null){
        if(LCContactIdLCUsrIdMap.containsKey(LCAccessWrapperObj.LCRecId)){
              userId = LCContactIdLCUsrIdMap.get(LCAccessWrapperObj.LCRecId);  
              userRecIdsSet.add(userId);
        }
      }
      
      // Preparing a temporary permission set assignment list
      // To help determine whether these permission sets already exist on the LC User record or not.      
      if((permSetId != null) && (userId != null)){
            PermissionSetAssignment permSetAssignObj = new PermissionSetAssignment(
                                                                    PermissionSetId = permSetId,
                                                                    AssigneeId = userId                                              
                                                                );
            permSetAssignTempList.add(permSetAssignObj);                    
          }
   }
        
      // Existence of permission sets on the LC User check is done here...
      // By checking for the presence of permission-set assignment records.
      for(PermissionSetAssignment permSetsAssignRecObj : [SELECT Id, PermissionSetId, AssigneeId 
                                    FROM PermissionSetAssignment 
                                    WHERE AssigneeId IN :userRecIdsSet
                                    AND PermissionSetId IN :permSetRecIdsSet]){
          if(!userRecIdAndPermSetIdGivesPermSetAssignMap.containsKey(String.valueOf(permSetsAssignRecObj.AssigneeId)+'-'+String.valueOf(permSetsAssignRecObj.PermissionSetId))){
                  userRecIdAndPermSetIdGivesPermSetAssignMap.put(String.valueOf(permSetsAssignRecObj.AssigneeId)+'-'+String.valueOf(permSetsAssignRecObj.PermissionSetId), permSetsAssignRecObj);
            }
      }                                                                                                
      
        // Only those permission-set assignments that are not already present on the LC User record are identified for insertion in the final permission-set assignment list.
        // Failing which salesforce CRM system doesn't allow duplicate permission set assignments to get inserted on a user record.
        for(PermissionSetAssignment permSetAssignObj : permSetAssignTempList){
            if(!userRecIdAndPermSetIdGivesPermSetAssignMap.containsKey(String.valueOf(permSetAssignObj.AssigneeId)+'-'+String.valueOf(permSetAssignObj.PermissionSetId))){
                permSetAssignFinalList.add(permSetAssignObj);
            }            
        }

    system.debug('permSetAssignFinalList-->'+permSetAssignFinalList);     
    if((permSetAssignFinalList != null) && !permSetAssignFinalList.isEmpty()){
      database.insert(permSetAssignFinalList, false);
    }
    
    return permSetAssignFinalList;
  }
  
  // This method is responsible for the revoking of the permission sets where necessary from the users. (Learning Coaches).


  public list<PermissionSetAssignment> revokePermSetsToLCUsers(map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsRemoveAccessWrapperMap, list<PermissionSetAssignment> permSetAssignTempList){
  
    map<Id, Id> studIdSchoolIdTempMap = new map<Id, Id>();
        map<Id, String> studIdSchoolNameTempMap = new map<Id, String>();
    map<String,String> schoolNameCTPermSetMap = new map<String,String>();
    map<String, Id> pSetNameIdMap = new Map<String, Id>();
    map<Id,Id> LCContactIdLCUsrIdMap = new map<Id,Id>();    
    set<Id> LCRecIdsSet = new set<Id>();
    
    // Preparing the association between the Students and the Schools they represent.
    // Also preparing a set collection to determine the LC Contact records.
    for(String schoolRecIdAndLCRecId : LCUserCTPermSetsRemoveAccessWrapperMap.keySet()){
            CS_LCUserCTPermSetsAccessWrapper LCUserCTPermSetsRemoveAccessWrapperObj = LCUserCTPermSetsRemoveAccessWrapperMap.get(schoolRecIdAndLCRecId);
            if((LCUserCTPermSetsRemoveAccessWrapperObj.schoolName != null) && (LCUserCTPermSetsRemoveAccessWrapperObj.studentRecId != null)){
                studIdSchoolNameTempMap.put(LCUserCTPermSetsRemoveAccessWrapperObj.studentRecId, LCUserCTPermSetsRemoveAccessWrapperObj.schoolName);
              }
      
            if(LCUserCTPermSetsRemoveAccessWrapperObj.LCRecId != null){
                LCRecIdsSet.add(LCUserCTPermSetsRemoveAccessWrapperObj.LCRecId);
              }
     }
    
    // Preparing the School Name and CareTaker Permission Sets Names associated with the respective schools.
    for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                                      FROM CS_School_PermissionSet_Mapping__mdt 
                                                                      WHERE School_Name__c IN : studIdSchoolNameTempMap.values()])
        {
            schoolNameCTPermSetMap.put(scPS.School_Name__c,scPS.Caretaker_PSet__c); //SchoolName, SchoolPermissionSet
        }
    
    // Preparing a map collection herewith to determine the Permission Set Names and their corresponding Salesforce Recs Ids in the system.
    for(PermissionSet pSet : [SELECT Id,name FROM PermissionSet WHERE Name IN : schoolNameCTPermSetMap.values()])
        {
            pSetNameIdMap.put(pSet.Name,pSet.Id);  //PermissionSetName, Id
        }
    
    // Preparing a map collection to identify and determine the user record Ids of the Learning Coaches present as Contacts in the system
    // Customer Partner Enablement process helps identify the User and Contact association for every community user in the system.
    for(User usr : [SELECT ContactId, Id FROM User WHERE ContactId IN :LCRecIdsSet])
        {
            LCContactIdLCUsrIdMap.put(usr.ContactId,usr.Id);
        }
        
    map<Id, PermissionSetAssignment> existingPermSetsAssignMap = new map<Id, PermissionSetAssignment>();
    map<Id, PermissionSetAssignment> finalPermSetsAssignDeleteMap = new map<Id, PermissionSetAssignment>();
    map<Id, PermissionSetAssignment> insertPermsSetAssignMap = new map<Id, PermissionSetAssignment>();    
    insertPermsSetAssignMap.putAll(permSetAssignTempList);
    set<Id> userRecIdsSet = new set<Id>();
    set<Id> permsSetIdsSet = new set<Id>();
    
    for(CS_LCUserCTPermSetsAccessWrapper LCAccessWrapperObj : LCUserCTPermSetsRemoveAccessWrapperMap.values()){      
      
      if(LCAccessWrapperObj.schoolName != null){
        if(schoolNameCTPermSetMap.containsKey(LCAccessWrapperObj.schoolName)){
          String permSetId = pSetNameIdMap.get(schoolNameCTPermSetMap.get(LCAccessWrapperObj.schoolName));
          permsSetIdsSet.add(permSetId);
        }
      }
      
      if(LCAccessWrapperObj.LCRecId != null){
        if(LCContactIdLCUsrIdMap.containsKey(LCAccessWrapperObj.LCRecId)){
          String userId = LCContactIdLCUsrIdMap.get(LCAccessWrapperObj.LCRecId);
          userRecIdsSet.add(userId);
        }
      }
        }
    
    // Checking for the existence of already provisioned permission sets through PermissionSetAssignments. to the respective users.
      if((permsSetIdsSet != null) && (userRecIdsSet != null)){
        for(PermissionSetAssignment permSetsAssignRecObj : [SELECT Id, PermissionSetId, AssigneeId 
                                    FROM PermissionSetAssignment 
                                    WHERE AssigneeId IN :userRecIdsSet
                                    AND PermissionSetId IN :permsSetIdsSet]){
                                       
        if(!existingPermSetsAssignMap.containsKey(permSetsAssignRecObj.Id)){
          existingPermSetsAssignMap.put(permSetsAssignRecObj.Id, permSetsAssignRecObj);
        }
      }
    }
    
    // Developing the final list of PermissionSetAssignments that will have to be inserted.
    for(PermissionSetAssignment permSetAssignRecObj : existingPermSetsAssignMap.values()){
      if(!insertPermsSetAssignMap.containsKey(permSetAssignRecObj.Id)){      
        if(!finalPermSetsAssignDeleteMap.containsKey(permSetAssignRecObj.Id)){
          finalPermSetsAssignDeleteMap.put(permSetAssignRecObj.Id, permSetAssignRecObj);
        }
      }
    }
    


    list<PermissionSetAssignment> permsSetAssignDeleteList = new list<PermissionSetAssignment>();
    // Only those permission-sets that were not recently inserted through permission-set assignment on the user will be getting purged.           
    if((finalPermSetsAssignDeleteMap != null) && !finalPermSetsAssignDeleteMap.isEmpty()){
        permsSetAssignDeleteList = finalPermSetsAssignDeleteMap.values();
    }

    return permsSetAssignDeleteList;
  } 
    
    //Sumanth B: 2020-May-05:The below method handles the association of permission sets to CT and Students 
 public static void CT_StdAssociatePermSets(Set<Id> StdIds, Set<String> schoolNamesToSearch)
 { 
        Map<String,String> CTPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, CT Permissions Set for the Caretaker 
        Map<String,String> StudentPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, STD Permissions Set for the Student 
      //  Map<String,id> StudentPsetNameIdList = new Map<String,Id>(); // Map to house the Perm set name, id 
        Map<Id,Set<Id>> CTUserAndPsIdsMap = new Map<Id,Set<Id>>(); //Map to house the CT UserId, Permission Set Ids
        Map<Id,Set<Id>> StdUserAndPsIdMap = new Map<Id,Set<Id>>(); //Map to house the Student UserId, Permission Set Id
        Set<String> AllPermissionSetNames = new Set<String>();
        Map<String,id> PermSetNameAndIdMap = new Map<String,Id>(); // Map to house the Perm set name, id 
        
        //Capture all the Permission Set names from CustomMeta Data (i.e.School names and corresponding Student,Caretaker Permissions Sets)
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                    FROM CS_School_PermissionSet_Mapping__mdt 
                                                    where School_Name__c IN : schoolNamesToSearch]){
                                                        
            CTPermissionSetsMap.put(scPS.School_Name__c,scPS.Caretaker_PSet__c); // SchoolName, SchoolName_CT for CT
            AllPermissionSetNames.add(scPS.Caretaker_PSet__c);
            StudentPermissionSetsMap.put(scPS.School_Name__c,scPS.Student_PSet__c);  // SchoolName, SchoolName_STD for STD
            AllPermissionSetNames.add(scPS.Student_PSet__c);
        }
        System.debug('CTPermissionSetsMap--> '+CTPermissionSetsMap);
        System.debug('StudentPermissionSetsMap--> '+StudentPermissionSetsMap);
        System.debug('AllPermissionSetNames--> '+AllPermissionSetNames);
         
        for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : AllPermissionSetNames]){
            PermSetNameAndIdMap.put(pSet.Name,pSet.Id);  
        }
        system.debug('PermSetNameAndIdMap-->: '+PermSetNameAndIdMap);
        
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Commuity_User__c,
                                                 School_Name__c,Status__c,
                                                 hed__Contact__r.Caretaker_Id__c,
                                                 hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id
                                                 from hed__Program_Enrollment__c where School_Name__c <> null       
                                                 AND hed__Contact__c in : StdIds order by LastModifiedDate desc])
        {
                if(pe.hed__Contact__r.Commuity_User__c <> null)            // Student UserId, Permission Set Id
                {
                    Set<Id> IdList; 
                  //  Id stdPsetIdVal;
                    if(!StdUserAndPsIdMap.containsKey(pe.hed__Contact__r.Commuity_User__c))
                    {
                        IdList = new Set<id>(); 
                       // stdPsetIdVal = PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(pe.School_Name__c)); 
                       // if(stdPsetIdVal <> null)
                        if(PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(pe.School_Name__c)) <> null)
                        {
                            //IdList.add(stdPsetIdVal);
                            IdList.add(PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(pe.School_Name__c)));
                            StdUserAndPsIdMap.put(pe.hed__Contact__r.Commuity_User__c,IdList);
                        }
                    }
                }
                
                if(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id <> null)     // CT UserId, Permission Set Id
                {
                    Set<id> PsIdList;
                   // Id CTPsetIdVal;
                    if(!CTUserAndPsIdsMap.containsKey(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id))
                    {
                        PsIdList = new Set<id>();
                    }
                    else
                    {
                        PsIdList = CTUserAndPsIdsMap.get(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id);
                    }
                   // CTPsetIdVal = PermSetNameAndIdMap.get(CTPermissionSetsMap.get(pe.School_Name__c));
                   // if(CTPsetIdVal <> null)
                    if(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(pe.School_Name__c)) <> null)
                    {
                        //PsIdList.add(CTPsetIdVal);
                        PsIdList.add(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(pe.School_Name__c)));
                        CTUserAndPsIdsMap.put(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,PsIdList); 
                    }
                }
        }
        system.debug('StdUserAndPsIdMap-->: '+StdUserAndPsIdMap);
        system.debug('CTUserAndPsIdsMap-->: '+CTUserAndPsIdsMap);
        
        if(!CTUserAndPsIdsMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.assignPermissionSetToUser(CTUserAndPsIdsMap);
            System.debug('CT Association List Sent for Utility-->'+ CTUserAndPsIdsMap);
        }
        if(!StdUserAndPsIdMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.assignPermissionSetToUser(StdUserAndPsIdMap);
            System.debug('Student Association List Sent for Utility-->'+StdUserAndPsIdMap);
        }
        
 }//CT_StdAssociatePermSets
    
    //Sumanth B: 2020-May-07:The below method handles the removal of permission sets to CT and Students 
 public static void CT_StdRemovePermSets(Set<Id> StdIds, Map<Id,Id> StdCTIdAndCTUsrIdMap, Set<String> schoolNamesToSearch,Map<String,hed__Program_Enrollment__c> WDStdId_SchId)
 { 
        Map<String,String> CTPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, CT Permissions Set for the Caretaker 
        Map<String,String> StudentPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, STD Permissions Set for the Student 
        Map<Id,Set<Id>> CTUserAndPsIdsMap = new Map<Id,Set<Id>>(); //Map to house the CT UserId, Permission Set Ids
        Map<Id,Set<Id>> StdUserAndPsIdMap = new Map<Id,Set<Id>>(); //Map to house the Student UserId, Permission Set Id
        Set<String> AllPermissionSetNames = new Set<String>();
        Map<String,id> PermSetNameAndIdMap = new Map<String,Id>(); // Map to house the Perm set name, id 
        
        //Capture all the Permission Set names from CustomMeta Data (i.e.School names and corresponding Student,Caretaker Permissions Sets)
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                    FROM CS_School_PermissionSet_Mapping__mdt 
                                                    where School_Name__c IN : schoolNamesToSearch]){
                                                        
            CTPermissionSetsMap.put(scPS.School_Name__c,scPS.Caretaker_PSet__c); // SchoolName, SchoolName_CT for CT
            AllPermissionSetNames.add(scPS.Caretaker_PSet__c);
            StudentPermissionSetsMap.put(scPS.School_Name__c,scPS.Student_PSet__c);  // SchoolName, SchoolName_STD for STD
            AllPermissionSetNames.add(scPS.Student_PSet__c);    //try to keep in one common function
        }
        System.debug('CTPermissionSetsMap--> '+CTPermissionSetsMap);
        System.debug('StudentPermissionSetsMap--> '+StudentPermissionSetsMap);
        System.debug('AllPermissionSetNames--> '+AllPermissionSetNames);
         
        for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : AllPermissionSetNames]){
            PermSetNameAndIdMap.put(pSet.Name,pSet.Id);  
        }
        system.debug('PermSetNameAndIdMap-->: '+PermSetNameAndIdMap);
        
        //Holds the withdraw Std's CT-School,PE record
        Map<String,hed__Program_Enrollment__c> mapCTSchool = new Map<String,hed__Program_Enrollment__c>(); 
        //Holds the all the Std's CT-School,Student Ids
        Map<String,List<Id>> mapCTSchoolAll = new Map<String,List<Id>>();
        Set<id> OthrStds = new Set<Id>();
        Map<id,String> othrStd_Status = new Map<Id,String>();
        System.debug('Printing the keyset before query:::'+StdCTIdAndCTUsrIdMap.keyset());
        for(hed__Program_Enrollment__c pe: [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                            School_Name__c,status__c from hed__Program_Enrollment__c where 
                                            hed__Contact__r.Caretaker_Id__c in: StdCTIdAndCTUsrIdMap.keyset()]){
                    
                    if (WDStdId_SchId.containsKey(pe.hed__Contact__c + '-' + pe.School_Name__C)){
                        mapCTSchool.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.School_Name__C,pe); //withdraw Std's CT-School , pe
                    }
                    
                    if (!mapCTSchoolAll.containsKey(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.School_Name__C)){
                        mapCTSchoolAll.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.School_Name__C, new List<Id>{pe.hed__Contact__c});
                        OthrStds.add(pe.hed__Contact__c);
                        othrStd_Status.put(pe.hed__Contact__c,pe.status__c);
                    }else{
                        List<Id> temp =  mapCTSchoolAll.get(pe.hed__Contact__r.Caretaker_Id__c  + '-' +  pe.School_Name__C);
                        temp.add(pe.hed__Contact__c);
                        OthrStds.add(pe.hed__Contact__c);
                        othrStd_Status.put(pe.hed__Contact__c,pe.status__c);
                        mapCTSchoolAll.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.School_Name__C, temp);
                    }
                }
        system.debug('mapCTSchool -->'+mapCTSchool);
        system.debug('mapCTSchoolAll -->'+mapCTSchoolAll);
        
      /*  Map<id,String> othrStd_Status = new Map<Id,String>();
        for(hed__Program_Enrollment__c pe: [select hed__Contact__c,status__c
                from hed__Program_Enrollment__c where hed__Contact__c in: OthrStds])
                {
                    othrStd_Status.put(pe.hed__Contact__c,pe.status__c); 
                } */
        system.debug('othrStd_Status -->'+othrStd_Status);
        integer exitVar;
        String CTRemovePsflg='';
        Map<id,Set<Id>> CtPSToDel = new Map<id,Set<Id>>(); // Holds the CT,school to delete Permission Sets

        for(string str: mapCTSchoolAll.keySet()){
            exitVar = 0;
            if (mapCTSchool.containsKey(str)){
                List<Id> pe = mapCTSchoolAll.get(str); //list of students under CT&School
                system.debug('pe-size-->'+pe);
                Set<Id> PsIdList;
              //  Id CTPsetIdVal;
                if (pe.size() == 1){

                        CTRemovePsflg = 'Req';
                        if(!CtPSToDel.containsKey(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c))
                        {
                            PsIdList = new Set<Id>();
                        }
                        else
                        {
                            PsIdList = CtPSToDel.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c);
                        }
                       // CTPsetIdVal = PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C));
                       // if(CTPsetIdVal <> null && StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c) <> null)
                       if(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C)) <> null 
                          && StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c) <> null)

                        {
                          //  PsIdList.add(CTPsetIdVal);
                            PsIdList.add(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C)));  
                            CtPSToDel.put(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c,PsIdList); 
                            CTUserAndPsIdsMap.put(StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c),PsIdList);
                        }

                }//if - pe.size
                else
                if(pe.size() > 1)
                {
                    for(Id stdId : pe)
                    {
                       // if(othrStd_Status.get(stdId) != 'Withdrawn')
                        if(othrStd_Status.get(stdId) == 'Complete')
                        {
                            exitVar++;
                            CTRemovePsflg = 'NR';
                            break;
                        }
                    }
                    if(exitVar == 0)
                    {
                        if(!CtPSToDel.containsKey(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c))
                        {
                            PsIdList = new Set<Id>();
                        }
                        else
                        {
                            PsIdList = CtPSToDel.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c);
                        }
                       // CTPsetIdVal = PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C));
                       // if(CTPsetIdVal <> null && StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c) <> null)
                       if(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C)) <> null 
                          && StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c) <> null)
                        {
                         //   PsIdList.add(CTPsetIdVal);
                            PsIdList.add(PermSetNameAndIdMap.get(CTPermissionSetsMap.get(mapCTSchool.get(str).School_Name__C)));       
                            CtPSToDel.put(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c,PsIdList); 
                            CTUserAndPsIdsMap.put(StdCTIdAndCTUsrIdMap.get(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c),PsIdList);
                        }

                    }
                }
            }
        }
        system.debug('CTRemovePsflg -->'+CTRemovePsflg);
        system.debug('CtPSToDel--'+CtPSToDel);
        system.debug('CTUserAndPsIdsMap--'+CTUserAndPsIdsMap);
        //Student UserId, PermsetId
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                             hed__Contact__r.Commuity_User__c,School_Name__c
                                             from hed__Program_Enrollment__c where hed__Contact__c in : StdIds])
        {
            if(pe.hed__Contact__r.Commuity_User__c <> null)
            {
                Set<Id> IdList; 
                Id stdPsetIdVal;
                if(!StdUserAndPsIdMap.containsKey(pe.hed__Contact__r.Commuity_User__c))
                    {
                        IdList = new Set<id>(); 
                        stdPsetIdVal = PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(pe.School_Name__c)); 
                        if(stdPsetIdVal <> null)
                        {
                            IdList.add(stdPsetIdVal);
                            StdUserAndPsIdMap.put(pe.hed__Contact__r.Commuity_User__c,IdList);
                        }
                    }
                //StdUserAndPsIdMap.put(pe.hed__Contact__r.Commuity_User__c,PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(pe.School_Name__c)));
            }
        }
        if(!CTUserAndPsIdsMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.removePermissionSetFromUser(CTUserAndPsIdsMap);
            System.debug('CT Removal List Sent to Utility-->'+ CTUserAndPsIdsMap);
        }
        if(!StdUserAndPsIdMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.removePermissionSetFromUser(StdUserAndPsIdMap);
            System.debug('Student Removal List Sent to Utility-->'+StdUserAndPsIdMap);
        }
  }//CT_StdRemovePermSets
    
}