public without Sharing class NES_ReEnrUtilities {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ReEnrUtilities');
    
    public static ReEnrResults InitreenrollingStudent(Id studentContactId, Id studentPEId,String callType){
        
        Peak_Response peakResponse = new Peak_Response();
        try{
                        // Get the Student Contact
            List<Contact> studentContact = [Select Id, FirstName,AccountId, LastName, Caretaker_Id__c from contact where Id =: studentContactId];
                
            // Get the Student PE Record
            hed__Program_Enrollment__c studentPERecord = [Select Id, ProfileName__c, Status__c,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,
                                                          Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c, OwnerId,
                                                          Enrollment_Type__c from hed__Program_Enrollment__c where Id=:studentPEId limit 1 FOR UPDATE]; 
            
            // Get the Academic Program
            List<Account> AcademicProgram  = [Select Id,OwnerId,ParentId,Confirmation_End_Date__c,School_Year__c,Registration_Start_Date__c,Registration_End_Date__c, 
                                                                    Use_Updated_ECA_Process__c from Account where ParentId =:studentPERecord.hed__Account__r.ParentId 
                                                                    and Id =:studentPERecord.hed__Account__c ] ; 
            
            // Get the Caretaker PE Record
            List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c 
                                                                    WHERE Id = : studentPERecord.Household_Program_Enrollment__c ];
            
            // Get the Caretaker User Record
           // User careTaker = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE ContactId = :caretakerEnrollment[0].hed__Contact__c];
            
            
            
            List<Enrollment_Component__c> processComponent = [
                SELECT Id, Assignment_Logic__c
                FROM Enrollment_Component__c
                WHERE Process_Academic_Program__c = :AcademicProgram[0].Id
                AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                LIMIT 1
            ];
           if(callType == 'SYReEnroll')
           {
                 hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id =studentPERecord.Id,CallType__c = callType,
                                                                        Enrollment_Type__c = 'Re-enrolling student'
                                                                        );
                 update pe;
           }
             else
             {
                 hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id =studentPERecord.Id,CallType__c = callType,
                                                                        Enrollment_Type__c = 'Re-enrolling student',
                                                                        Status__c = 'In Progress');
               
             update pe;
                 createOpportunity(studentContact,studentPERecord,AcademicProgram,callType);
             }
           
            peakResponse.success = true;
            UpdateECAs(studentPERecord.Id, caretakerEnrollment[0].Id,callType);
            EvaluationUtils.PerformAsyncNewStudentSteps(studentPERecord.Id, processComponent[0].Id, caretakerEnrollment[0].Id,callType); 
           // ValidateECAs(studentPERecord.Id, caretakerEnrollment[0].Id,callType);
            String gradeLevel = studentPERecord?.Program_Grade_Level__r?.Grade_Level__r?.Name; // need to remove
            ReEnrResults result = new ReEnrResults(studentPERecord.id , processComponent[0].Id, gradelevel, true);
            return result; 
        }
        catch(Exception e){
            peakResponse.success = false;
            peakResponse.messages.add('Could not complete Re-Enrollment process');
            system.debug('exception*************'+e.getMessage());
            logger.logException('There is some issue with the ReEnrollment'+studentPEId, e);
            logger.saveLogs();
            return null;
    	}
        
    }

    
  public Static void UpdateECAs(Id programEnrollment,Id caretakerEnrollmentId,string EnrollmentType){
    List<Enrollment_Component_Affiliation__c> existEcas=new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : [select id,Status__c,Order__c,Enrollment_Component__c,Enrollment_Component__r.Assignment_Logic__c,Enrollment_Component__r.RecordType.Name,Enrollment_Component__r.Component_Type__c,Enrollment_Component__r.Name from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :programEnrollment FOR UPDATE]){
           
            existEcas.add(eca);
        }
  Set<Id> STDDocECAs = new Set<Id>();
        
        Set<Id> HHDocECs = new Set<Id>();
        
        //  Set<Id> StageECA = new Set<Id>();
        
        List<Enrollment_Component_Affiliation__c> StageECAtoUpdate = new List<Enrollment_Component_Affiliation__c>();
        
        List<Enrollment_Component_Affiliation__c> ecastoUpdate=new List<Enrollment_Component_Affiliation__c>();
        
        system.debug('EvaluationUtils-Debug'+ EnrollmentType);
        
        if(existEcas != null && (EnrollmentType == 'InitReActivation' || EnrollmentType == 'InitReEnrollment')){
                        
            for(Enrollment_Component_Affiliation__c eca :existEcas){
                 if(eca.Enrollment_Component__r.RecordType.Name =='Flag'){
                     eca.Status__c = 'Not Applicable';
                 }
                else if(eca.Enrollment_Component__r.RecordType.Name !='Stage'){
                  
                    if(eca.Enrollment_Component__r.RecordType.Name == 'Document' ){
                        if(eca.Enrollment_Component__r.Component_Type__c == 'Student' && eca.Status__c != 'Not Applicable'){
                            
                            STDDocECAs.add(eca.id);
                            
                           /* if(!(String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)))
                                
                                eca.Status__c = 'Not Applicable';
                            
                            else */
                                
                                eca.Status__c = 'Not Started';
                            
                        }
                        
                        else if (eca.Enrollment_Component__r.Component_Type__c == 'Household' && eca.Status__c != 'Not Applicable'){
                            
                            eca.Status__c = 'Not Started';
                            
                            HHDocECs.add(eca.Enrollment_Component__c);
                            
                        }
                        
                    }
                
                    else if(((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)) && (eca.Enrollment_Component__r.Component_Type__c != 'Household' && eca.Status__c != 'Complete'))){
                        
                        eca.Status__c = 'Not Started';
                    }
                    
                    else if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)) && (eca.Enrollment_Component__r.Component_Type__c == 'Household' && eca.Status__c != 'Complete')){
                         eca.Status__c = 'Not Started';
                        
                    }  
                     else if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)) && (eca.Enrollment_Component__r.Component_Type__c == 'Household' && eca.Status__c == 'Complete' && eca.Enrollment_Component__r.RecordType.Name == 'Form' && eca.Enrollment_Component__r.Name == 'Household Information' )){
                         eca.Status__c = 'In Progress';
                        
                    }
                    
                    else{
                        
                    if(eca.Enrollment_Component__r.Component_Type__c == 'Student' && eca.Status__c == 'Complete')
                            
                        {  
                         
                         eca.Status__c = 'Not Started';
                        // eca.Is_Dirty__c = true;
                         
                        }
                        
                        
                  else if((!(eca.Enrollment_Component__r.Component_Type__c == 'Household' && eca.Status__c == 'Complete')))
                            
                        { 
                         
                         eca.Status__c = 'Not Applicable';
                         
                        }
                        
                    }
                    
                    ecastoUpdate.add(eca);
                    
                }
                else if((eca.Enrollment_Component__r.RecordType.Name == 'Stage')  && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')){
                    
                    if(eca.Order__c == 1 && eca.Status__c != 'Complete' ){
                        
                        eca.Status__c = 'Complete';
                        
                    }
                    
                    else if(eca.Order__c == 2){
                        
                        eca.Status__c = 'In Progress';
                        
                    }else if(eca.Order__c > 2){
                        
                        eca.Status__c = 'Not Started';
                        
                    }
                    
                    StageEcaToUpdate.add(eca);            
                    
                }
                
                
            }
                       
            List<Enrollment_Document__c> allEDsToUpdate = new List<Enrollment_Document__c> ();
            
            for (Enrollment_Document__c ed : [select id, Enrollment_Component_Affiliation__c, Status_Reason__c from Enrollment_Document__c where Enrollment_Component_Affiliation__c in : STDDocECAs or (Program_Enrollment__c = : caretakerEnrollmentId and Enrollment_Component_Affiliation__r.Enrollment_Component__c in : HHDocECs)]) {
                
                ed.Status_Reason__c = 'Not Applicable';
                
                allEDsToUpdate.add(ed);
                
            }
            
            if (allEDsToUpdate.size() > 0)
                
                update allEDsToUpdate;
            
            //if(StageEcaToUpdate.size()>0)
            
            //     update StageEcaToUpdate;
            
            try
                
            {
                
                if(StageEcaToUpdate.size()>0)
                    
                    update StageEcaToUpdate;
                
            }
            
            catch(DMLException e) {
                
                if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) {
                    
                    update StageEcaToUpdate;
                    
                }}
           
              if(ecastoUpdate.size() > 0)
                
                update ecastoUpdate;
          
        }
  }   
  
 /* public Static void ValidateECAs(Id programEnrollment,Id caretakerEnrollmentId,string EnrollmentType){
    List<Enrollment_Component_Affiliation__c> existEcas=new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : [select id,Status__c,Order__c,Enrollment_Component__c,Enrollment_Component__r.Assignment_Logic__c,Enrollment_Component__r.RecordType.Name,Enrollment_Component__r.Component_Type__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :programEnrollment AND Enrollment_Component__r.Name = 'Waitlist'and Enrollment_Component__r.RecordType.Name = 'Stage' and Program_Enrollment__r.WaitlistFlag__c ='Active']){
           
            existEcas.add(eca);
        }
         if(existEcas.size() > 0){
             system.debug('In Validate');
            for(Enrollment_Component_Affiliation__c eca :existEcas){
                 eca.Status__c = 'Not Started';
            }
        
                
                update existEcas;
         } 
         
     } */
 
 public Static void createOpportunity(List<Contact> studentContact,hed__Program_Enrollment__c studentPERecord,List<Account> AcademicProgram, string callType){
     
     //Now let's create an Opportunity based on that enrollmentId
            Opportunity oppToInsert = new Opportunity(
                Name = studentContact[0].FirstName + ' ' + studentContact[0].LastName + ' Opportunity',
                OwnerId =AcademicProgram[0].OwnerId,
                Caretaker_Id__c = studentContact[0].Caretaker_Id__c,
                Student_Id__c = studentContact[0].Id,
                AccountId = studentContact[0].AccountId,
                Program_Enrollment__c = studentPERecord.Id,
                StageName = 'Open',
                CloseDate = AcademicProgram[0].Confirmation_End_Date__c == null ? Date.today() : AcademicProgram[0].Confirmation_End_Date__c.date()
            	
            );
       
            if(callType=='InitReActivation'){
            if (studentPERecord.ProfileName__c =='Caretaker Community User'){
            oppToInsert.How_Student_Was_Reactivated__c='Caretaker';
            oppToInsert.Full_Reactivation_Date__c = Date.today();
            oppToInsert.Full_Reactivation_User__c = UserInfo.getUserId(); 
            } 
            else
            {
            oppToInsert.How_Student_Was_Reactivated__c='Staff';
            oppToInsert.Full_Reactivation_Date__c = Date.today();
            oppToInsert.Full_Reactivation_User__c = UserInfo.getUserId(); 
            }
                
         }
            Insert oppToInsert;
        
    }
    
    public class ReEnrResults{
        @AuraEnabled public Id programEnrollmentId{get;set;}
        @AuraEnabled public Id processId{get;set;}
        @AuraEnabled public String gradeLevel{get;set;}
        @AuraEnabled public Boolean success{get;set;}
        public ReEnrResults(Id programEnrollmentId, Id processId, String gradeLevel, Boolean success){
            this.programEnrollmentId = programEnrollmentId;
            this.processId = processId;
            this.gradeLevel = gradeLevel;
            this.success = success;
        }
    }


}