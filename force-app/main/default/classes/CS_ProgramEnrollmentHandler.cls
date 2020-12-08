/*
* Created by:  Sumanth B
* Created date: 2020-Apr-03
* User Story : 162232
* Purpose: Handler class to 

            * Associate the School permission sets to the Caretaker Community user and 
            Student Community User if exists when Student enrollment is completed i.e. PE Status = Complete 

            * Disassociate the School permission sets from the Caretaker Community user and 
            Student Community User if exists when Student enrollment is Withdrawn i.e. PE Status = Withdrawn

 Change Log: 30-Apr-2020 Sumanth B 
            Added not null condition at ReqUsrPsIds List to resolve the NES_ProgramEnrollmentTriggerTest class error issue
            30-Apr-2020 Rakesh Ramaswamy
            Added processUpdatedProgramEnrollmentsForLCUsersAccess( ) future method to process all related Relationship records associated with the Program Enrollment records
            that got updated to the "Withdrawn" or "Complete" Status accordingly. We will need to determine the associated Relationship records whether they are "Former" (Inactive) or "Current" (Active) status relationships.

			2020-May-15 : Sumanth B : Inactivated as its moved to Batch Job as per US # 176990 (Task # 177184)  	
*          
*/
public class CS_ProgramEnrollmentHandler {
 /*   public static void invokePermSets(List<Id> stdCmpLst,List<id> stdWDLst)
    {
        if(stdCmpLst.size()>0)      
            associatePermSets(stdCmpLst);
        else
        if(stdWDLst.size()>0)
            removePermSets(stdWDLst);
    }

    public static void associatePermSets(List<Id> newList)
    {
        //Captures the list of StudentIds
        Set<Id> StdIds = new Set<Id>();
        List<String> PsNamesToSearch = new List<String>();
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Account__c,hed__Account__r.Parent.Name
                                             from hed__Program_Enrollment__c where id in : newList])
        {
           if (pe.hed__Contact__c != null && pe.hed__Account__c != null)
           {                                                    
                StdIds.add(pe.hed__Contact__c);
                PsNamesToSearch.add(pe.hed__Account__r.Parent.Name);
           }
        }
        System.debug('StdIds '+StdIds);

        //captures studentId,student User Id if exists
        Map<Id,Id> StdId_UsrIds = new Map<Id,Id>();
        for (User usr : [select id,ContactId,Contact.Caretaker_Id__c from User where ContactId in : StdIds])
        {
            StdId_UsrIds.put(usr.ContactId,usr.id); //StudentId, StudentUserId
        }

        //Capture all the Permission Set names from CustomMeta Data (i.e.School names and corresponding Student,Caretaker Permissions Sets)
        Map<String,String> Sch_PermSets = new Map<String,String>();  
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c 
                                                    FROM CS_School_PermissionSet_Mapping__mdt 
                                                    where School_Name__c IN : PsNamesToSearch]){
            Sch_PermSets.put(scPS.School_Name__c,scPS.Student_PSet__c+';'+scPS.Caretaker_PSet__c);
        }
        System.debug('Sch_PermSets '+Sch_PermSets);
        
        Map<Id,String> StdUsrId_PsNames = new Map<Id,String>();//Holds the StudentUserId, PermSetName
        Map<Id,String> CT_PsNames = new Map<Id,String>(); //Holds the CT ContactId, PermiSet Name
        String StdPSetval='',CTPSetVal='',val='';
        List<String> psAllList = new List<String>(); //Stores List of Permissionsets for CT.
        
        //Map the CT Id, Permission Set Name
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                             hed__Account__r.Parent.Name
                                             from hed__Program_Enrollment__c where hed__Contact__c in : StdIds])
        {
                    List<String> psList;
                    val= Sch_PermSets.get(pe.hed__Account__r.Parent.Name);
                    if(val != null)
                    {
                       StdPSetval = val.substring(0,val.indexOf(';',0));  //STD Permission Set
                       CTPSetVal = val.substring(val.indexOf(';',0)+1);   //CT Permission Set
                    }
                    system.debug('StdPSetval' + StdPSetval);
                    system.debug('CTPSetVal' + CTPSetVal);
                    if(!StdId_UsrIds.isEmpty())  //If StudentUserId exists
                    {
                        StdUsrId_PsNames.put(StdId_UsrIds.get(pe.hed__Contact__c),StdPSetval); //Std UserId, STD PermSetVal
                    }
                    //Retrive CT Id, List of PermSets for CT
                      CT_PsNames.put(pe.hed__Contact__r.Caretaker_Id__c, CTPSetVal);
                      psAllList.add(StdPSetval);
                      psAllList.add(CTPSetVal);
            } 
         system.debug('CT_PsNames-->: '+CT_PsNames);
         system.debug('psAllList-->: '+psAllList);
         // map the Perm set name, id 
         Map<String,id> CTPsetNameIdList = new Map<String,Id>();
         for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : psAllList]){
                    CTPsetNameIdList.put(pSet.Name,pSet.Id);  
                }
        system.debug('CTPsetNameIdList-->: '+CTPsetNameIdList);
        Set<Id> UserIds = new Set<Id>(); // Stores the User Ids
        Set<Id> PermSetIds = new Set<Id>(); // Stores the Permission Set Ids
        List<Id> CTPsIds;
        Map<Id,Id> CTUser_CTPsIds = new Map<Id,Id>(); // Holds the CTUserId,PermSetId
        Map<Id,Id> StdUser_StdPsIds = new Map<Id,Id>(); // Holds the StdUserId,PermSetId
        
        //Maps the UserId, PermissionSet Id
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                             hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,
                                             hed__Account__r.Parent.Name from hed__Program_Enrollment__c 
                                             where hed__Contact__c in : StdIds])
        {
            if(!StdId_UsrIds.isEmpty())  //If StudentUserId exists
                    {
                        Id idVal = CTPsetNameIdList.get(StdUsrId_PsNames.get(StdId_UsrIds.get(pe.hed__Contact__c)));//Holds the STD permSetId
                        StdUser_StdPsIds.put(StdId_UsrIds.get(pe.hed__Contact__c),idVal);// map the Student User id,STD School Permission SetId  for student
                        UserIds.add(StdId_UsrIds.get(pe.hed__Contact__c));
                        PermSetIds.add(idVal);  
                    }
             CTUser_CTPsIds.put(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,CTPsetNameIdList.get(CT_PsNames.get(pe.hed__Contact__r.Caretaker_Id__c)));
             PermSetIds.add(CTPsetNameIdList.get(CT_PsNames.get(pe.hed__Contact__r.Caretaker_Id__c)));
             UserIds.add(pe.hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id);
        }
        
        system.debug('CTUser_CTPsIds-->: '+CTUser_CTPsIds);
        system.debug('UserIds-->: '+UserIds);
        system.debug('PermSetIds-->: '+PermSetIds);
        system.debug('StdUser_StdPsIds-->: '+StdUser_StdPsIds);
        
        //Verifying whether Permission set is associated to the CT/Student or not before assigning
        Map<Id,Set<Id>> pSet_Exists = new Map<Id,Set<Id>>(); // To consider 2 different students(schools) under same caretaker
        for(PermissionSetAssignment assocRec : [select AssigneeId,PermissionSetId from PermissionSetAssignment 
                                                   where AssigneeId =: UserIds and PermissionSetId =: PermSetIds]){
                if(pSet_Exists.containsKey(assocRec.AssigneeId))
                      pSet_Exists.get(assocRec.AssigneeId).add(assocRec.PermissionSetId);
                else    
                      pSet_Exists.put(assocRec.AssigneeId, new set<Id>{assocRec.PermissionSetId});
          }
        system.debug('pSet_Exists-->: '+pSet_Exists);
        Set<PermissionSetAssignment> perSetAssgnLst = new Set<PermissionSetAssignment>();
        List<String> ReqUsrPsIds = new List<String>(); //PermSetId, UserId

        //Assigning the Student Permission Set to the Student & Caretaker Users 
        PermissionSetAssignment psa;
        if(!StdId_UsrIds.isEmpty())  //If StudentUserId exists
        {
            for(Id stdAsignId : StdUser_StdPsIds.keyset())
            {
                if(!(pSet_Exists.containsKey(stdAsignId) && pSet_Exists.get(stdAsignId).contains(StdUser_StdPsIds.get(stdAsignId))))
                {
                   //ReqUsrPsIds.add(StdUser_StdPsIds.get(stdAsignId)+'-'+stdAsignId);
                   if(StdUser_StdPsIds.get(stdAsignId) <> null && stdAsignId <> null)
                     ReqUsrPsIds.add(StdUser_StdPsIds.get(stdAsignId)+'-'+stdAsignId);
                }
            }
           system.debug('STD-perSetAssgnLst-->: '+perSetAssgnLst);
           system.debug('ReqUsrPsIds--STDUsr_PSIds-->: '+ReqUsrPsIds); 
        }
        if(!CTUser_CTPsIds.isEmpty())
        {
            for(Id assgnId : CTUser_CTPsIds.keyset())
            {
                    if(!(pSet_Exists.containsKey(assgnId) && pSet_Exists.get(assgnId).contains(CTUser_CTPsIds.get(assgnId))))
                    {
                       // ReqUsrPsIds.add(CTUser_CTPsIds.get(assgnId)+'-'+assgnId);
                        if(CTUser_CTPsIds.get(assgnId) <> null && assgnId <> null)
                            ReqUsrPsIds.add(CTUser_CTPsIds.get(assgnId)+'-'+assgnId);
                            
                    }
                }
         }
        system.debug('CT & STDperSetAssgnLst-->: '+perSetAssgnLst); 
        system.debug('ReqUsrPsIds-->: '+ReqUsrPsIds); 
        if(ReqUsrPsIds.size() > 0)
             upsertPermSetAssigns(ReqUsrPsIds);

    }//associatePermSets
      
      @future
      public static void upsertPermSetAssigns(List<String> psaRecs) {
      
          List<PermissionSetAssignment> pSetToInsert = new List<PermissionSetAssignment>();
          PermissionSetAssignment psa;
          Set<PermissionSetAssignment> perSetAssgnLst = new Set<PermissionSetAssignment>();
         
          String val='';
          Id psId,usId;
          system.debug('psaRecs-->'+psaRecs+'  psaRecs-size-->'+psaRecs.size());
          
          for(String psUsrComb : psaRecs)
          {
            val = psUsrComb;
            system.debug('val: '+val);
            if(val!=null)
            {
                psId = val.substring(0,val.indexOf('-',0));
                usId = val.substring(val.indexOf('-',0)+1);
            }            
            psa = new PermissionSetAssignment (PermissionSetId = psId, AssigneeId = usId);
            perSetAssgnLst.add(psa);              
          }          
          pSetToInsert.addAll(perSetAssgnLst);
                if(pSetToInsert.size() > 0 )//!= null)
                {
                    try {
                           upsert pSetToInsert;
                        } catch (Exception ex) {
                            System.debug('Error: ' + ex.getMessage());
                        }
                }
          
      }//upsertPermSetAssigns
    

    //public static void removePermSets(List<hed__Program_Enrollment__c> newList)
    public static void removePermSets(List<Id> newList)
    {
        Set<Id> StdIds = new Set<Id>();
        Map<String,hed__Program_Enrollment__c> WDStdId_SchId = new Map<String,hed__Program_Enrollment__c>(); //Withdrawn Student+School,Pe
        Set<Id> StdCTIds = new Set<Id>();
        List<String> PsNamesToSearch = new List<String>();
       
        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,hed__Account__c,
                                             hed__Account__r.Parent.Name
                                             from hed__Program_Enrollment__c where id in : newList])
        {
            if (pe.hed__Contact__c != null && pe.hed__Account__c != null)
            {    
                StdIds.add(pe.hed__Contact__c);                             //Holds the Student Contact Ids
                StdCTIds.add(pe.hed__Contact__r.Caretaker_Id__c);           //Holds the Caretaker Ids
                PsNamesToSearch.add(pe.hed__Account__r.Parent.Name);
                    System.debug('PsNamesToSearch'+PsNamesToSearch);
                WDStdId_SchId.put(pe.hed__Contact__c + '-' + pe.hed__Account__r.Parent.Name, pe); //Holds the Std-School,pe record who are withdrawn
            }
        }
        System.debug('WDStdId_SchId'+WDStdId_SchId);
        //Holds the withdraw Std's CT-School,Pe record
        Map<String,hed__Program_Enrollment__c> mapCTSchool = new Map<String,hed__Program_Enrollment__c>(); 
        //Holds the all the Std's CT-School,Std Ids
        Map<String,List<Id>> mapCTSchoolAll = new Map<String,List<Id>>();
        Set<id> OthrStds = new Set<Id>();
        for(hed__Program_Enrollment__c pe: [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,hed__Account__c,
                hed__Account__r.Parent.Name
                from hed__Program_Enrollment__c where hed__Contact__r.Caretaker_Id__c in: StdCTIds]){
                    
                    if (WDStdId_SchId.containsKey(pe.hed__Contact__c + '-' + pe.hed__Account__r.Parent.Name)){
                        mapCTSchool.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.hed__Account__r.Parent.Name,pe);
                    }
                    
                    if (!mapCTSchoolAll.containsKey(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.hed__Account__r.Parent.Name)){
                        mapCTSchoolAll.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.hed__Account__r.Parent.Name, new List<Id>{pe.hed__Contact__c});
                        OthrStds.add(pe.hed__Contact__c);
                    }else{
                        List<Id> temp =  mapCTSchoolAll.get(pe.hed__Contact__r.Caretaker_Id__c  + '-' +  pe.hed__Account__r.Parent.Name);
                        temp.add(pe.hed__Contact__c);
                        OthrStds.add(pe.hed__Contact__c);
                        mapCTSchoolAll.put(pe.hed__Contact__r.Caretaker_Id__c + '-' +  pe.hed__Account__r.Parent.Name, temp);
                    }
                }
        system.debug('mapCTSchool -->'+mapCTSchool);
        system.debug('mapCTSchoolAll -->'+mapCTSchoolAll);
        
        Map<id,String> othrStd_Status = new Map<Id,String>();
        for(hed__Program_Enrollment__c pe: [select hed__Contact__c,status__c
                from hed__Program_Enrollment__c where hed__Contact__c in: OthrStds])
                {
                    othrStd_Status.put(pe.hed__Contact__c,pe.status__c);
                }
        system.debug('othrStd_Status -->'+othrStd_Status);
        integer exitVar=0;
        String CTRemovePsflg='';
        Map<id,String> CtPSToDel = new Map<id,String>(); // Holds the CT,school to delete Permission Sets

        for(string str: mapCTSchoolAll.keySet()){
            if (mapCTSchool.containsKey(str)){
                List<Id> pe = mapCTSchoolAll.get(str); //list of students under CT&School
                system.debug('pe-size-->'+pe);
                if (pe.size() == 1){
                    CTRemovePsflg = 'Req';
                    CtPSToDel.put(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c,mapCTSchool.get(str).hed__Account__r.Parent.Name);
                }
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
                        CtPSToDel.put(mapCTSchool.get(str).hed__Contact__r.Caretaker_Id__c,mapCTSchool.get(str).hed__Account__r.Parent.Name);
                    }
                }
            }
        }
        system.debug('CTRemovePsflg -->'+CTRemovePsflg);
        system.debug('CtPSToDel--'+CtPSToDel);
                    
        //Capture all the Permission Set names from CustomMeta Data (i.e.School names and corresponding Student,Caretaker Permissions Sets)
        Map<String,String> Sch_PermSets = new Map<String,String>();  
        for(CS_School_PermissionSet_Mapping__mdt scPS: [SELECT School_Name__c,Student_PSet__c,Caretaker_PSet__c
                                                    FROM CS_School_PermissionSet_Mapping__mdt
                                                    where School_Name__c IN : PsNamesToSearch]){
            Sch_PermSets.put(scPS.School_Name__c,scPS.Student_PSet__c+';'+scPS.Caretaker_PSet__c);
        }
        System.debug('Sch_PermSets '+Sch_PermSets);
        
        Map<Id,List<String>> CT_PsNames = new Map<Id,List<String>>(); //Holds the CT ContactId, PermiSet Name
        List<String> psAllList = new List<String>(); //Stores List of Permissionsets for CT.
        String StdPSetval='',CTPSetVal='',val='';
 
        List<Id> PsIds;
        Map<Id,List<String>> CTUser_CTPsIds = new Map<Id,List<String>>(); // Holds the CTUserId,PermSetId
        List<String> ReqUsrPsIds = new List<String>(); //PermSetId-UserId comb
        if(!CtPSToDel.isEmpty()) //In case of Removing Permissions Sets from CT
        {
            for(Id CtId:CtPSToDel.keySet())
            {
                List<String> psList;
                val= Sch_PermSets.get(CtPSToDel.get(CtId));
                if(val != null)
                {
                    StdPSetval = val.substring(0,val.indexOf(';',0));  //STD Permission Set
                    CTPSetVal = val.substring(val.indexOf(';',0)+1);   //CT Permission Set
                }
                //Retrive CT Id, List of PermSets for CT
                if(!CT_PsNames.containsKey(CtId))
                {
                    psList = new List<String>();        
                }
                else{
                    psList = CT_PsNames.get(CtId);
                }               
                psList.add(StdPSetval);
                psList.add(CTPSetVal);
                CT_PsNames.put(CtId, psList);
                psAllList.addAll(psList);
            }//for
            
            System.debug('CT_PsNames '+CT_PsNames);
            System.debug('psAllList '+psAllList);
            
            Map<String,id> CTPsetNameIdList = new Map<String,Id>();
            for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : psAllList]){
                        CTPsetNameIdList.put(pSet.Name,pSet.Id);  //Holds the Permisssion SetName, ids
             }
            system.debug('CTPsetNameIdList-->: '+CTPsetNameIdList);
            
            //captures CTId, CTUserId
            Map<Id,Id> CTId_UsrIds = new Map<Id,Id>();
            for (User usr : [select id,ContactId,Contact.Caretaker_Id__c from User where ContactId in : CtPSToDel.keySet()])
            {
                CTId_UsrIds.put(usr.ContactId,usr.id); //CTId, CTUserId
            }
                System.debug('CTId_UsrIds'+CTId_UsrIds);
            //captures CTUserId, List Permission Set Ids
            PsIds = new List<id>();
            for(Id CtId:CtPSToDel.keySet())
            {
                for(String psName : CT_PsNames.get(CtId))
                {
                    PsIds.add(CTPsetNameIdList.get(psName));
                }
                CTUser_CTPsIds.put(CTId_UsrIds.get(CtId),PsIds);
            }    
            System.debug('CTUser_CTPsIds --'+ CTUser_CTPsIds);
            Map<Id,Id> CTPsetIds = new Map<id,id>();
            for(Id assgnId : CTUser_CTPsIds.keyset())
                for(Id perId : CTUser_CTPsIds.get(assgnId))
                {
                    CTPsetIds.put(perId,assgnId);
                }
            system.Debug('CTPsetIds--' + CTPsetIds);
            for(PermissionSetAssignment psa : [select id,AssigneeId,PermissionSetId from PermissionSetAssignment 
                                               where AssigneeId in : CTPsetIds.values() and PermissionSetId in : CTPsetIds.keySet()])
            {
               // ReqUsrPsIds.add(psa.PermissionSetId+'-'+psa.AssigneeId);
                  if(psa.PermissionSetId <> null && psa.AssigneeId <> null)
                    ReqUsrPsIds.add(psa.PermissionSetId+'-'+psa.AssigneeId);
            } 
        }//if-CtToDel.isEmpty()
        
        //captures studentId,student User Id if exists
        Map<Id,Id> StdId_UsrIds = new Map<Id,Id>();
        for (User usr : [select id,ContactId,Contact.Caretaker_Id__c from User where ContactId in : StdIds])
        {
            StdId_UsrIds.put(usr.ContactId,usr.id); //StudentId, StudentUserId
        }
        System.debug('StdId_UsrIds'+StdId_UsrIds);
        Map<Id,String> StdUsrId_PsNames = new Map<id,String>();

        for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                             hed__Account__r.Parent.Name
                                             from hed__Program_Enrollment__c where hed__Contact__c in : StdIds])
        {
                if(!StdId_UsrIds.isEmpty())  //If StudentUserId exists
                {
                        val= Sch_PermSets.get(pe.hed__Account__r.Parent.Name);
                        if(val != null)
                        {
                            StdPSetval = val.substring(0,val.indexOf(';',0));  //STD Permission Set
                        }
                        StdUsrId_PsNames.put(StdId_UsrIds.get(pe.hed__Contact__c),StdPSetval); //Std UserId, STD PermSetVal
                }//StdId_UsrIds.isEmpty
        }
        System.debug('StdUsrId_PsNames'+StdUsrId_PsNames);
        if(!StdId_UsrIds.isEmpty())  //If StudentUserId exists
        {
            Map<String,Id> StdPsetNameIdList= new Map<String,Id>();
            for(PermissionSet pSet : [select Id,name from PermissionSet where Name IN : StdUsrId_PsNames.values()]){
                
                StdPsetNameIdList.put(pSet.Name,pSet.Id);  // map the Perm set name, id for Student
            }
            System.debug('StdPsetNameIdList'+StdPsetNameIdList);
            Map<Id,Id> StdUser_StdPsIds = new Map<Id,Id>(); // Holds the StdUserId,PermSetId
            
            //Maps the Std UserId, PermissionSet Id
            for(hed__Program_Enrollment__c pe : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                                 hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,
                                                 hed__Account__r.Parent.Name from hed__Program_Enrollment__c 
                                                 where hed__Contact__c in : StdIds])
            {
                            Id idVal = StdPsetNameIdList.get(StdUsrId_PsNames.get(StdId_UsrIds.get(pe.hed__Contact__c)));//Holds the STD permSetId
                            StdUser_StdPsIds.put(StdId_UsrIds.get(pe.hed__Contact__c),idVal);// map the Student User id,STD School Permission SetId  for student
            }
            System.debug('StdUser_StdPsIds'+StdUser_StdPsIds);
            for(PermissionSetAssignment psa : [select id,AssigneeId,PermissionSetId from PermissionSetAssignment 
                                               where AssigneeId in : StdUser_StdPsIds.keySet() and 
                                               PermissionSetId in : StdUser_StdPsIds.values()])
            {
                //ReqUsrPsIds.add(psa.PermissionSetId+'-'+psa.AssigneeId);
                 if(psa.PermissionSetId <> null && psa.AssigneeId <> null)
                     ReqUsrPsIds.add(psa.PermissionSetId+'-'+psa.AssigneeId);
            } 
        }//if-!StdId_UsrIds.isEmpty()
         if(ReqUsrPsIds.size() > 0)
             deletePermSetAssigns(ReqUsrPsIds);
    }//removePermSets
    
     @future(callout=true)
     public static void deletePermSetAssigns(List<String> psaRecs) {

          List<PermissionSetAssignment> pSetToDelete = new List<PermissionSetAssignment>();
          Set<PermissionSetAssignment> perSetAssgnLst = new Set<PermissionSetAssignment>();
          List<Id> psLst = new List<Id>();
          List<Id> UsrLst = new List<id>();
          String val='';
          Id psId,usId;
          for(String psUsrComb : psaRecs)
          {
                val = psUsrComb;
                if(val!=null)
                {
                    psId = val.substring(0,val.indexOf('-',0));  
                    usId = val.substring(val.indexOf('-',0)+1);
                    psLst.add(psId);
                    UsrLst.add(usId);
                }
          }
          for(PermissionSetAssignment psa : [select id,AssigneeId,PermissionSetId from PermissionSetAssignment 
                                               where AssigneeId in : UsrLst and 
                                               PermissionSetId in : psLst])
            {
                perSetAssgnLst.add(psa);
            }         
          pSetToDelete.addAll(perSetAssgnLst);
          if(pSetToDelete.size() != null)
          {
              try {
                  delete pSetToDelete;
              } catch (Exception ex) {
                  System.debug('Error: ' + ex.getMessage());
              }
          }
      }*/       
}//CS_ProgramEnrollmentHandler