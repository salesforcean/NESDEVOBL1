/*
* Created by:  Sumanth B
* Created date: 2020-Apr-21
* User Story : 130549
* Purpose: Handler class to 

            * Associate the School permission sets(SchoolName_CT & SchoolName_STD) to the existing Caretaker Community user and 
            Student Community User if any when Student enrollment is completed i.e. PE Status = Complete 
*
* Test Class:  CS_AssignPermissionSetToCT_STDBatchTest
* Change Log: 
*
*/
public class CS_AssignPermissionSetToCT_STDHandler {

    public void associatePermissionSets(Set<Id> ctIds, Set<Id> stdIds)
    {
        Set<String> allSchoolsList = new Set<String>();
        Set<Id> allStudentIdList = new Set<Id>();
        Map<String,String> CTPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, CT Permissions Set for the Caretaker 
        Map<String,String> StudentPermissionSetsMap = new Map<String,String>(); // Set to house the SchoolName, STD Permissions Set for the Student 
        Map<Id,String> StdUserId_SchoolNameMap = new Map<Id,String>(); //Map to house the Student UserId, SchoolName
        Map<Id,Set<String>> CTUserId_SchoolNameMap = new Map<Id,Set<String>>(); // Map to house the CTUserId and List of Student's School Names
        Map<Id,Set<Id>> CTUserAndPsIdsMap = new Map<Id,Set<Id>>(); //Map to house the CT UserId, Permission Set Ids
        Map<Id,Set<Id>> StdUserAndPsIdMap = new Map<Id,Set<Id>>(); //Map to house the Student UserId, Permission Set Id
        Set<String> AllPermissionSetNames = new Set<String>();
        Map<String,id> PermSetNameAndIdMap = new Map<String,Id>(); // Map to house the Perm set name, id 
		
        Set<Id> studentIdList;
        for(hed__Relationship__c relObject : [SELECT Id, hed__Contact__c,hed__Type__c,
                                                       hed__RelatedContact__c                                                              
                                                       FROM hed__Relationship__c 
                                              		   WHERE hed__RelatedContact__c IN: ctIds]){
                  
                       allStudentIdList.add(relObject.hed__Contact__c);
        }
        System.debug('allStudentIdList -->'+ allStudentIdList);
        System.debug('List of All Students for the Eligible CTs -->'+ allStudentIdList.size());
        if(stdIds.size() >0)
            allStudentIdList.addAll(stdIds);
        System.debug('allStudentIdList with StdIds Size-->'+ allStudentIdList);
		Map<Id,String> StudentAndSchoolMap = new Map<Id,String>();
		//Map the CT Id, Permission Set Name
		if(allStudentIdList.size() > 0)
        {
            for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,hed__Contact__r.Commuity_User__c,
                                                 hed__Account__r.Parent.Name,School_Name__c,Status__c,
                                                 hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id
                                                 from hed__Program_Enrollment__c where Status__c = 'Complete' 
                                                 AND School_Name__c <> null       
                                                 AND hed__Contact__c in : allStudentIdList order by LastModifiedDate desc])
            {
                  System.debug('Student: '+pe.hed__Contact__c+' Caretaker--> '+pe.hed__Contact__r.Caretaker_Id__c);
                  Set<String> schoolList;		
                  if(!CTUserId_SchoolNameMap.containsKey(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id))
                  {
                      schoolList = new Set<String>();
                  }
                  else{
                         schoolList = CTUserId_SchoolNameMap.get(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id);
                   }
                   schoolList.add(pe.School_Name__c);
                   if(pe.hed__Contact__r.Caretaker_Id__c <> null)
                 	 CTUserId_SchoolNameMap.put(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id, schoolList);
                   if(pe.hed__Contact__c <> null)
                 	 StudentAndSchoolMap.put(pe.hed__Contact__c,pe.School_Name__c); 

                   if(pe.hed__Contact__r.Commuity_User__c <> null)
                   {
                       StdUserId_SchoolNameMap.put(pe.hed__Contact__r.Commuity_User__c,pe.School_Name__c);
                   }	
                   allSchoolsList.addAll(schoolList);
            } 
        }
         system.debug('StudentAndSchoolMap-->: '+StudentAndSchoolMap);
         system.debug('StdUserId_SchoolNameMap-->: '+StdUserId_SchoolNameMap);
         system.debug('CTUserId_SchoolNameMap-->: '+CTUserId_SchoolNameMap);
         system.debug('allSchoolsList-->: '+allSchoolsList+ 'with PE Status=Complete-->: '+allSchoolsList.size());

        //Capture all the Permission Set names from CustomMeta Data (i.e.School names and corresponding Student,Caretaker Permissions Sets)
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                    FROM CS_School_PermissionSet_Mapping__mdt 
                                                    where School_Name__c IN : allSchoolsList]){
            CTPermissionSetsMap.put(scPS.School_Name__c,scPS.Caretaker_PSet__c);
            AllPermissionSetNames.add(scPS.Caretaker_PSet__c);
			StudentPermissionSetsMap.put(scPS.School_Name__c,scPS.Student_PSet__c);
            AllPermissionSetNames.add(scPS.Student_PSet__c);
        }
        System.debug('CTPermissionSetsMap--> '+CTPermissionSetsMap);
		System.debug('StudentPermissionSetsMap--> '+StudentPermissionSetsMap);
        System.debug('AllPermissionSetNames--> '+AllPermissionSetNames);
         
	    for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : AllPermissionSetNames]){
            PermSetNameAndIdMap.put(pSet.Name,pSet.Id);  
        }
        system.debug('PermSetNameAndIdMap-->: '+PermSetNameAndIdMap);

        Set<Id> IdList;	
        Id stdPsetIdVal;
		for(Id Ids : StdUserId_SchoolNameMap.keySet()){
				//StdUserAndPsIdMap.put(Ids,PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(StdUserId_SchoolNameMap.get(Ids))));
            	if(!StdUserAndPsIdMap.containsKey(Ids))
                {
                    IdList = new Set<id>(); 
                    stdPsetIdVal =PermSetNameAndIdMap.get(StudentPermissionSetsMap.get(StdUserId_SchoolNameMap.get(Ids))); 
                    if(stdPsetIdVal <> null)
                    {
                        IdList.add(stdPsetIdVal);
                        StdUserAndPsIdMap.put(Ids,IdList);
                    }
                }
		}
        system.debug('StdUserAndPsIdMap-->: '+StdUserAndPsIdMap);
        
        Set<id> PsIdList;
        Id CTPsetIdVal;
        for(Id Ids : CTUserId_SchoolNameMap.keyset())
        {
            for(String psName : CTUserId_SchoolNameMap.get(Ids))
            {
                if(!CTUserAndPsIdsMap.containsKey(Ids))
                {
                    PsIdList = new Set<id>();
                }
                else
                {
                    PsIdList = CTUserAndPsIdsMap.get(Ids);
                }
                CTPsetIdVal = PermSetNameAndIdMap.get(CTPermissionSetsMap.get(psName));
                if(CTPsetIdVal <> null)
                {
                    PsIdList.add(CTPsetIdVal);
                    CTUserAndPsIdsMap.put(Ids,PsIdList); 
                }
            }
        }
        system.debug('CTUserAndPsIdsMap-->: '+CTUserAndPsIdsMap);
        if(!CTUserAndPsIdsMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.assignPermissionSetToUser(CTUserAndPsIdsMap);
            System.debug('CT Records sent for Association -->');
         }
        if(!StdUserAndPsIdMap.isEmpty()){            
            CS_PermissionSetsAccessUtility.assignPermissionSetToUser(StdUserAndPsIdMap);
            System.debug('Student Records sent for Association-->');
         }
    }
}