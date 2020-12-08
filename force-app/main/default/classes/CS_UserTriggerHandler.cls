/*
* Created by:  Sumanth B
* Created date: 2020-Mar-25
* Purpose: Handler class to associate the School related permission sets to the Student,Caretaker Community users (US # 123096)
* Change Log:

	2020-May-2 : Sumanth B : 1. Added the PE Status = Complete condition while associating the Permission sets to Caretaker/Student
							 2. Removed the logic for Assigning the STD permission sets to CT as only CT permission set is enough

    2020-May-15 : Sumanth B : Inactivated as its moved to Batch Job as per US # 176990 (Task # 177184)  
*         
*/


public class CS_UserTriggerHandler {
/*
    public static void associatePermSetafterInsert(List<User> newList)
    {
        Map<Id,Id> User_StdIds = new Map<Id,Id>();
        Map<Id,Id> User_CtIds = new Map<Id,Id>();

        for (User usr : [select id,ContactId,ProfileId,Contact.Caretaker_Id__c,Profile.Name from User where id in : newList]) {
                if (usr.ContactId != null && usr.Profile.Name == system.Label.NES_CS_Std_Profile){
                User_StdIds.put(usr.Id,usr.ContactId);
    			User_CtIds.put(usr.Id,usr.Contact.Caretaker_Id__c);
            }
		}
        system.debug('User_StdIds: '+User_StdIds);
        system.debug('User_CtIds: '+User_CtIds);
        
        
        Map<Id,String> Std_PsNames = new Map<Id,String>();
        Map<Id,Id> Std_PsIds = new Map<Id,Id>();
     	Map<Id,List<String>> CT_PsNames = new Map<Id,List<String>>();
        
        Map<String,String> Sch_PermSets = new Map<String,String>(); //Captures all the School names and corresponding Student,Caretaker Permissions Sets
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c
                									FROM CS_School_PermissionSet_Mapping__mdt])
        {
            Sch_PermSets.put(scPS.School_Name__c,scPS.Student_PSet__c+';'+scPS.Caretaker_PSet__c);
        }
        System.debug('Sch_PermSets '+Sch_PermSets);
        
        String val='';
        List<String> psAllList = new List<String>(); //Stores  Permissionsets for CT.
 		System.debug('User_StdIds.values()'+User_StdIds.values());
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,Status__c,hed__Account__r.Parent.Name
                   from hed__Program_Enrollment__c where Status__c = 'Complete' AND hed__Contact__c =: User_StdIds.values()])
            {
                       System.debug('User_StdIds.values()'+User_StdIds.values());
                       List<String> psList;
                	  val = Sch_PermSets.get(pe.hed__Account__r.Parent.Name).substring(0,Sch_PermSets.get(pe.hed__Account__r.Parent.Name).indexOf(';',0));
                	  Std_PsNames.put(pe.hed__Contact__c,val);
               
                       val = Sch_PermSets.get(pe.hed__Account__r.Parent.Name).substring(Sch_PermSets.get(pe.hed__Account__r.Parent.Name).indexOf(';',0)+1);
                       if(!CT_PsNames.containsKey(pe.hed__Contact__r.Caretaker_Id__c))
                       {
                          	psList = new List<String>();	    
                       }
                       else{
                      		 psList = CT_PsNames.get(pe.hed__Contact__r.Caretaker_Id__c);
                       }
                       psList.add(val);
                       CT_PsNames.put(pe.hed__Contact__r.Caretaker_Id__c, psList);
                       psAllList.addAll(psList);
        }
        
        system.debug('Std_PsNames-->'+Std_PsNames);
        system.debug('CT_PsNames-->'+CT_PsNames);

        Map<String,Id> StdPsetNameIdList= new Map<String,Id>();
        for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : Std_PsNames.values()]){
                    
                    StdPsetNameIdList.put(pSet.Name,pSet.Id);  // map the Perm set name, id for Student
                }
	    Map<String,Id> CTPsetNameIdList= new Map<String,Id>();
        for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : psAllList]){
                    
                    CTPsetNameIdList.put(pSet.Name,pSet.Id);  // map the Perm set name, id for CT
                }
        
        system.debug('StdPsetNameIdList-->'+StdPsetNameIdList);
        system.debug('CTPsetNameIdList-->'+CTPsetNameIdList);
        
        Map<Id,Id> StdUser_PsIds = new Map<Id,Id>(); // Stores the Student userId, Student Permission Set Id from contact
        Map<Id,List<String>> CTUser_CTPsIds = new Map<Id,List<String>>();
        Set<Id> UserIds = new Set<Id>(); // Stores the User Ids
        Set<Id> PermSetIds = new Set<Id>(); // Stores the Permission Set Ids
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Commuity_User__r.id,hed__Contact__r.Caretaker_Id__c,
                                             hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,Status__c,
                                             hed__Account__r.Parent.Name from hed__Program_Enrollment__c 
                                             where Status__c = 'Complete' AND hed__Contact__c =: User_StdIds.values()]){

	                Std_PsIds.put(pe.hed__Contact__c,StdPsetNameIdList.get(Std_PsNames.get(pe.hed__Contact__c)));  // map the Student id,School Permission SetId  for student
                    
                    CTUser_CTPsIds.put(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,CT_PsNames.get(pe.hed__Contact__r.Caretaker_Id__c));
                    UserIds.add(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id);
        }
        Map<Id,Id> ct_st_NameIds = new Map<Id,Id>();
        for(List<String> nameList : CTUser_CTPsIds.values())
        {
            for(String name : nameList){
                 PermSetIds.add(CTPsetNameIdList.get(name));// CT perm set ids
            }
        }
        
        system.debug('CTUser_CTPsIds-->: '+CTUser_CTPsIds);
        system.debug('Std_PsNames: '+Std_PsNames);
        system.debug('Std_PsIds: '+Std_PsIds.keyset());
        system.debug('CT_PsNames: '+CT_PsNames);
        
        for(User usr1 : [Select Id,ContactId from User where ContactId =: Std_PsIds.keyset()]){
            
            if(Std_PsIds.containskey(usr1.ContactId)&&Std_PsIds.get(usr1.ContactId)!=null){
                  StdUser_PsIds.put(usr1.Id,Std_PsIds.get(usr1.ContactId));
                  UserIds.add(usr1.Id);
                  PermSetIds.add(Std_PsIds.get(usr1.ContactId));
            }
            
        }
        system.debug('StdUser_PsIds: '+StdUser_PsIds);
       
            Map<Id,Set<Id>> stdPs_Exists = new Map<Id,Set<Id>>(); // To consider 2 different students(schools) under same caretaker
            for(PermissionSetAssignment prSetExists : [select AssigneeId,PermissionSetId from PermissionSetAssignment 
                                                       where AssigneeId =: UserIds and PermissionSetId =: PermSetIds]){
                                                           
                if(stdPs_Exists.containsKey(prSetExists.AssigneeId))
					stdPs_Exists.get(prSetExists.AssigneeId).add(prSetExists.PermissionSetId);
				else	
					stdPs_Exists.put(prSetExists.AssigneeId, new set<Id>{prSetExists.PermissionSetId});
            }
        
        Set<PermissionSetAssignment> permSetLst = new Set<PermissionSetAssignment>();
        system.debug('stdPs_Exists '+stdPs_Exists);
            PermissionSetAssignment psa;
               			for (User usr2 : [Select Id, Name,ContactId,Contact.Caretaker_Id__r.Commuity_User__r.id FROM User 
                                          Where Id IN : StdUser_PsIds.keyset()]){ 
                                 if(!(stdPs_Exists.containsKey(usr2.Id) && stdPs_Exists.get(usr2.Id).contains(StdUser_PsIds.get(usr2.Id)))){
                                          psa = new PermissionSetAssignment (PermissionSetId = StdUser_PsIds.get(usr2.Id), AssigneeId = usr2.Id);
                                          permSetLst.add(psa);
                                }
                           } 
            
       		system.debug('StdntPermSetLst-->STD'+permSetLst);	
                PermissionSetAssignment psa2;
                for(Id Ids : CTUser_CTPsIds.keyset())
                {
                    for(String name : CTUser_CTPsIds.get(Ids)){
                            if(!stdPs_Exists.containsKey(Ids)){
                            psa2 = new PermissionSetAssignment (PermissionSetId = CTPsetNameIdList.get(name), AssigneeId = Ids);
                                              permSetLst.add(psa2);
                        }
                    }
                }
            system.debug('CTPermSetLst--CT'+permSetLst); 
            List<PermissionSetAssignment> psToInsert = new List<PermissionSetAssignment>();
            psToInsert.addAll(permSetLst);
            if(psToInsert.size() != null)
                try {
                       upsert psToInsert;
                    } catch (Exception ex) {
                        System.debug('Error: ' + ex.getMessage());
                    }
        } */
}