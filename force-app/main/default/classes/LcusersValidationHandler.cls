public class LcusersValidationHandler{

    public void provDeprovPermissionSet(List<hed__Relationship__c> relationshipRecs){
    
        //Collect unique student Ids
        Set<Id> studentIdList = new Set<Id>();
        for(hed__Relationship__c relRec: relationshipRecs){
            studentIdList.add(relRec.hed__Contact__c);
        }
        
        //Retrieve program enrollment records for above student Ids
        Map<Id,List<hed__Program_Enrollment__c>> studentIdPrgEnrollRecsMap = new Map<Id,List<hed__Program_Enrollment__c>>();
        for(hed__Program_Enrollment__c peRec: [select hed__Contact__c,hed__Account__c,Status__c,hed__Account__r.Parent.School_Id__c,
                                              hed__Account__r.Parent.Name from hed__Program_Enrollment__c
                                                where hed__Contact__c=:studentIdList]){
            if(studentIdPrgEnrollRecsMap.get(peRec.hed__Contact__c)!=null){
                List<hed__Program_Enrollment__c> enrollRecsList = studentIdPrgEnrollRecsMap.get(peRec.hed__Contact__c);
                enrollRecsList.add(peRec);
                studentIdPrgEnrollRecsMap.put(peRec.hed__Contact__c,enrollRecsList);    
            }else{
                List<hed__Program_Enrollment__c> enrollRecsList = new List<hed__Program_Enrollment__c>();
                enrollRecsList.add(peRec);
                studentIdPrgEnrollRecsMap.put(peRec.hed__Contact__c,enrollRecsList);
            }                                                    
        }
        
        //Main Processing
        Map<String,Set<Id>> SchoolNameLCUsersMap = new Map<String,Set<Id>>();
        for(hed__Relationship__c relRec: relationshipRecs){
            //Retrieve enrollment records for student
            List<hed__Program_Enrollment__c> enrollRecs = studentIdPrgEnrollRecsMap.get(relRec.hed__Contact__c); 
            if(enrollRecs!=null && enrollRecs.size()>0){
                for(hed__Program_Enrollment__c enroll: enrollRecs){
                    if(relRec.hed__Contact__r.Account.Parent.Name == enroll.hed__Account__r.Parent.Name && relRec.hed__Status__c=='Current' && enroll.Status__c=='Complete'){
                        //Add coach to corresponding school permission set
                        if(SchoolNameLCUsersMap.get(relRec.hed__Contact__r.Account.Parent.Name)!=null){
                            Set<Id> LCIds = SchoolNameLCUsersMap.get(relRec.hed__Contact__r.Account.Parent.Name);
                            LCIds.add(relRec.hed__RelatedContact__r.Commuity_User__c);
                            SchoolNameLCUsersMap.put(relRec.hed__Contact__r.Account.Parent.Name,LCIds);
                        }else{
                            Set<Id> LCIds = new Set<Id>();
                            LCIds.add(relRec.hed__RelatedContact__r.Commuity_User__c);
                            SchoolNameLCUsersMap.put(relRec.hed__Contact__r.Account.Parent.Name,LCIds);    
                        }
                    }
                }
            }   
        }
        //get school permission sets from custom metadata type
        List<Educational_Institution_SSTF_Mapping__mdt> scPermList = [Select School__c,Permission_Set_Name__c from Educational_Institution_SSTF_Mapping__mdt where School__c=: SchoolNameLCUsersMap.keySet()];
        List<String> permSetNameList = new List<String>();
        Map<String,String> schoolPermSetNameMap = new Map<String,String>();
        for(Educational_Institution_SSTF_Mapping__mdt mdtRec: scPermList){
            permSetNameList.add(mdtRec.Permission_Set_Name__c);  
            schoolPermSetNameMap.put(mdtRec.School__c,mdtRec.Permission_Set_Name__c);          
        }
        
        //Query Permission Set Assignment to get existing assignments so that duplicates are not added
        List<PermissionSetAssignment> permAssignList = [Select AssigneeId,PermissionSetId,PermissionSet.Name from PermissionSetAssignment where PermissionSet.Name =:permSetNameList];
        Map<String,PermissionSetAssignment> permAssignMap = new Map<String,PermissionSetAssignment>();
        for(PermissionSetAssignment assign: permAssignList){
            permAssignMap.put(assign.PermissionSet.Name+'-'+assign.AssigneeId,assign);    
        }
        
        //Query for PermissionSetIds
        List<PermissionSet> permSets = [Select Id,Name from PermissionSet where Name=: permSetNameList];
        Map<String,Id> permSetNameIdMap = new Map<String,Id>();
        for(PermissionSet perm: permSets){
            permSetNameIdMap.put(perm.Name,perm.Id);       
        }
        
        List<PermissionSetAssignment> assignmentsToBeAdded = new List<PermissionSetAssignment>();
        for(String school: SchoolNameLCUsersMap.keySet()){
            Set<Id> LCusers = SchoolNameLCUsersMap.get(school);
            String permSetName = schoolPermSetNameMap.get(school);
            Id permSetId = permSetNameIdMap.get(permSetName);
            for(Id lcusr: LCusers){
                //check for existing perm set assignment
                String permSetAssignKey = permSetName+'-'+lcusr;
                if(permAssignMap.get(permSetAssignKey)!=null){
                    // do nothing
                    // LC user already exists in permission set
                }else{
                    PermissionSetAssignment newAssignRec = new PermissionSetAssignment();
                    newAssignRec.AssigneeId = lcusr;
                    newAssignRec.PermissionSetId = permSetId;
                    assignmentsToBeAdded.add(newAssignRec);
                }  
            }
        }
        if(assignmentsToBeAdded!=null && assignmentsToBeAdded.size()>0){
            Insert assignmentsToBeAdded;
        }
    }
}