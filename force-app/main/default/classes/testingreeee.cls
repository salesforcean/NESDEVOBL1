public class testingreeee {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ReEnrUtilities');
    
    public static ReEnrResults reenrollingStudent(Id studentContactId, Id studentPEId){
        Peak_Response peakResponse = new Peak_Response();
        
        try{
            // Get the Student Contact
            List<Contact> studentContact = [Select Id, FirstName,AccountId, LastName, Caretaker_Id__c from contact where Id =: studentContactId];
            
            // Get the Student PE Record
            hed__Program_Enrollment__c studentPERecord = [Select Id,Status__c,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,
                                                          Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c, OwnerId,
                                                          Enrollment_Type__c from hed__Program_Enrollment__c where Id=:studentPEId limit 1];
            
            // Get the Academic Program
            List<Account> AcademicProgram  = [Select Id,OwnerId,ParentId,Confirmation_End_Date__c,School_Year__c,Registration_Start_Date__c,Registration_End_Date__c, 
                                              Use_Updated_ECA_Process__c from Account where ParentId =:studentPERecord.hed__Account__r.ParentId 
                                              and Id =:studentPERecord.hed__Account__c ] ; 
            
            // Get the Caretaker PE Record
            List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c 
                                                                    WHERE Id = :studentPERecord.Household_Program_Enrollment__c ];
            
            // Get the Caretaker User Record
            User careTaker = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE ContactId = :caretakerEnrollment[0].hed__Contact__c];
            
            
            
            
            
            hed__Program_Enrollment__c toUpdatePE = new hed__Program_Enrollment__c( 
                Id =studentPERecord.id,
                Status__c = 'In Progress',
                Enrollment_Type__c ='Re-enrolling student',
                WaitlistFlag__c = null,
                WaitlistCounter__c = null,
                Waitlist_Time_Date_Stamp__c = null,
                Waitlist_Time_Date_Stamp_Override__c = null,
                Initial_ECA_Creation_Complete__c = true
            );
            update toUpdatePE;
            
            //Now let's create an Opportunity based on that enrollmentId
            Opportunity oppToInsert = new Opportunity(
                Name = studentContact[0].FirstName + ' ' + studentContact[0].LastName + ' Opportunity',
                OwnerId = AcademicProgram[0].OwnerId,
                Caretaker_Id__c = studentContact[0].Caretaker_Id__c,
                Student_Id__c = studentContact[0].Id,
                AccountId = studentContact[0].AccountId,
                Program_Enrollment__c = studentPERecord.Id,
                StageName = 'Open',
                CloseDate = AcademicProgram[0].Confirmation_End_Date__c == null ? Date.today() : AcademicProgram[0].Confirmation_End_Date__c.date()
            );        
            Insert oppToInsert;
            
            //
            List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>([
                SELECT  Id, SystemModstamp, Enrollment_Component__c,Status__c,Order__c,
                Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c,
                Enrollment_Component__r.Needed_for_Re_enrollment__c,
                Enrollment_Component__r.RecordTypeId
                FROM    Enrollment_Component_Affiliation__c
                WHERE  
                Program_Enrollment__c =: studentPERecord.id
                
                
                AND
                (
                    (
                        (
                            Status__c= 'Complete' AND Enrollment_Component__r.Component_Type__c !='Household'
                            AND
                            Enrollment_Component__r.RecordType.Name
                            IN ('Section', 'Form', 'Question', 'Question Group', 'Document', 'Flag', 'Message', 'Text')
                        )
                        OR
                        (
                            (  
                                Status__c IN ('In Progress', 'Complete')
                                AND
                                (
                                    Enrollment_Component__r.RecordType.Name = 'Stage'
                                    AND
                                    Order__c != 1
                                )
                            )
                        )
                    )
                )
            ]);
            
            String enrollmentType='RE-ENROLLMENT';
            List<Enrollment_Component_Affiliation__c> ecaToUpdate = new List<Enrollment_Component_Affiliation__c>();
            //Added for testing
            List<Enrollment_Component_Affiliation__c> StageEcaToUpdate = new List<Enrollment_Component_Affiliation__c>();
            Set<Id> StageECASet = new Set<Id>();
            //Added for testing
            
            //Fix for Bug #195463 on 2020-06-25 (Krishna Peddanagammol)
            //Added Else If condition for defect #210102
            
            Set<Id> ECAsOfTypeDocument = new Set<Id>();
            Set<Id> ECsOfTypeDocument = new Set<Id>();
            
            for (Enrollment_Component_Affiliation__c eca : ecaList) {
                System.debug('my list-----'+eca);
                if((eca.Enrollment_Component__r.RecordType.Name != 'Stage') && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')) {
                    eca.Status__c = 'Not Started';
                }else if((eca.Enrollment_Component__r.RecordType.Name == 'Stage')  && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')){
                    if(eca.Order__c == 2){
                        eca.Status__c = 'In Progress';
                    }else if(eca.Order__c > 2){
                        eca.Status__c = 'Not Started';
                    }
                    // Added for testing
                    StageEcaToUpdate.add(eca);
                    StageECASet.add(eca.Id);
                    // Added for testing
                }
                system.debug('Enrollment Type*********'+eca.Program_Enrollment__r.Enrollment_Type__c);
                //Added for making Form status as In Progress, This will run only for Re-Enrolling Students for Defect 244255
                // if((eca.Enrollment_Component__r.RecordType.Name == 'Form') && enrollmentType == 'RE-ENROLLMENT')
                // eca.Status__c = 'In Progress';
                
                //store the ECAs of document because during a reenrollment, we have to update the Enrollment docs tied to these ECAs
                if (eca.Enrollment_Component__r.RecordType.Name == 'Document') {
                    ECAsOfTypeDocument.add(eca.id);      
                    ECsOfTypeDocument.add(eca.Enrollment_Component__c);
                    
                    //For Reenrollments, all ECAs should have been completed once and for documents, they should be marked as In Progress.
                    if(enrollmentType == 'RE-ENROLLMENT')
                        eca.Status__c = 'In Progress';
                }
                //added for testing
                if(!StageECASet.Contains(eca.Id))
                    //added for testing
                    ecaToUpdate.add(eca);    
            }
            //added for testing
            if(StageEcaToUpdate.Size()>0)
                update StageEcaToUpdate;
            //added for testing
            
            if (ecaToUpdate.size()>0) {
                // Added code for the defect 228339 by Maddileti on 28-08-2020  
                // To bypass the auto-completion logic , passing Flag value from  NES_EnrollmentReactivationBase class to NES_AddStudentCBLQueueable class
                if(enrollmentType == 'RE-ENROLLMENT') {
                    //Mark any Enrollment document that is tied to any ECA we are opening as invalid.
                    Set<id> EDsAlreadyAdded = new Set<Id> ();
                    List<Enrollment_Document__c> allEDsToUpdate = new List<Enrollment_Document__c> ([select id, Status_Reason__c from Enrollment_Document__c where Enrollment_Component_Affiliation__c in :ECAsOfTypeDocument]);
                    for (Enrollment_Document__c ed : allEDsToUpdate) {
                        ed.Status_Reason__c = 'Invalid-Reenrollment';
                        EDsAlreadyAdded.add(ed.id);
                    }
                    
                    //MM 10/5/2020 We need to find the house docs that might be tied to a different ECA.
                    List<Enrollment_Document__c> allHouseholdEDsToUpdate = new List<Enrollment_Document__c> ([select id, Status_Reason__c
                                                                                                              from Enrollment_Document__c
                                                                                                              where Program_Enrollment__c =: studentPERecord.Household_Program_Enrollment__c
                                                                                                              and Enrollment_Component_Affiliation__r.Enrollment_Component__c in :ECsOfTypeDocument ]);
                    for (Enrollment_Document__c ed : allHouseholdEDsToUpdate) {
                        ed.Status_Reason__c = 'Invalid-Reenrollment';
                        if (!EDsAlreadyAdded.contains(ed.id))
                            allEDsToUpdate.add(ed);
                    }
                    
                    if (allEDsToUpdate.size() > 0)
                        update allEDsToUpdate;
                }
                
                update ecaToUpdate;
            }	
            peakResponse.success = true; 		
            ReEnrResults result = new ReEnrResults(studentPERecord.id ,true);
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
    public class ReEnrResults{
        @AuraEnabled public Id programEnrollmentId{get;set;}
        @AuraEnabled public Boolean success{get;set;}
        public ReEnrResults(Id programEnrollmentId, Boolean success){
            this.programEnrollmentId = programEnrollmentId;
            this.success = success;
        }
    }
    
}