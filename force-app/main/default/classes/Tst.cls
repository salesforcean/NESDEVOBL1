public without Sharing class Tst {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ReEnrUtilities');
    
    public static void reenrollingStudent(Id studentContactId, Id studentPEId,String callType){
        Peak_Response peakResponse = new Peak_Response();
        
        try{
        
            
            // Make sure that completion logic is not evaluated now through triggers
            NES_ECACompletion.shouldRunCompletion = false;
            NES_Constants.runAssignment = false;
            NES_LTSUtility.runLTSFlag = false;
            NES_ProgramEnrollmentHandler.runCBL = false;

            //System.debug('Contact Id' + studentContactId);
            
            
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
                                                                    WHERE Id = : studentPERecord.Household_Program_Enrollment__c ];
            
            // Get the Caretaker User Record
            User careTaker = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE ContactId = :caretakerEnrollment[0].hed__Contact__c];
            
            
            /*
            List<Enrollment_Component__c> processComponent = [
                SELECT Id, Assignment_Logic__c
                FROM Enrollment_Component__c
                WHERE Process_Academic_Program__c = :AcademicProgram[0].Id
                AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                LIMIT 1
            ]; */
            
            List <Id> ecIdList = new List <Id> ();
            
            // Start updating the ECAs
            List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>([
                    SELECT  Id, SystemModstamp, Enrollment_Component__c,Status__c,Order__c,
                            Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c,
                            Enrollment_Component__r.Needed_for_Re_enrollment__c,Enrollment_Component__r.Needed_for_ITR__c,Enrollment_Component__r.Assignment_Logic__c,Enrollment_Component__r.Name,
                            Enrollment_Component__r.RecordTypeId, Enrollment_Component__r.Component_Type__c
                    FROM    Enrollment_Component_Affiliation__c 
                    WHERE   
                        Program_Enrollment__c =: studentPERecord.Id
                     AND 
                        ( 
                            (
                                ( 
                                    Status__c = 'Complete' 
                                    AND 
									Enrollment_Component__r.Component_Type__c != : 'Household'
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
            for(Enrollment_Component_Affiliation__c eca : ecaList){
                ecIdList.add(eca.Enrollment_Component__c);
            }
            
           	List <Enrollment_Component_Relationship__c> ecrList = [Select Id, Parent_Enrollment_Component__c, Parent_Enrollment_Component__r.Name, Parent_Enrollment_Component__r.Order__c, 
                                                     Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__c
                                                     from Enrollment_Component_Relationship__c where Child_Enrollment_Component__c in: ecIdList];
            
            
            Map <Id, Enrollment_Component_Relationship__c> ecIdToECRMap = new Map <Id, Enrollment_Component_Relationship__c> ();
            for(Enrollment_Component_Relationship__c ecr: ecrList){
                ecIdToECRMap.put(ecr.Child_Enrollment_Component__c, ecr);
            }
            

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
                //if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)) || (eca.Enrollment_Component__r.Needed_for_Re_enrollment__c)){
                if(ecIdToECRMap.get(eca.Enrollment_Component__c).Parent_Enrollment_Component__r.Name == 'Tell us About your Student' &&
                   ecIdToECRMap.get(eca.Enrollment_Component__c).Parent_Enrollment_Component__r.RecordType.Name == 'Stage' && eca.Enrollment_Component__r.RecordType.Name == 'Form'){
                   System.debug('NDEBUG :::: Got the Forms under Stage 2::::::::');
                   eca.Status__c = 'Not Started';
                   eca.Is_Dirty__c = true;
                }
                else
                if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c))){
					eca.Status__c = 'Not Started';
                    eca.Is_Dirty__c = true;
				}
				else{
					eca.Status__c = 'Not Applicable';
                    eca.Is_Dirty__c = true;
				}
            }else if((eca.Enrollment_Component__r.RecordType.Name == 'Stage')  && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')){
                if(eca.Order__c == 2){
                    eca.Status__c = 'In Progress';
                    eca.Is_Dirty__c = true;
                }else if(eca.Order__c > 2){
					if(String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)){
						eca.Status__c = 'Not Started';
                        //eca.Is_Dirty__c = true;
					}
					else{
						eca.Status__c = 'Not Applicable';
                        //eca.Is_Dirty__c = true;
					}
                }
            }
                // Added for testing
               if(!StageECASet.Contains(eca.Id))
               {
                StageEcaToUpdate.add(eca); 	
                StageECASet.add(eca.Id);
               }
                 
            
            //store the ECAs of document
            if (eca.Enrollment_Component__r.RecordType.Name == 'Document') {
                System.debug('Document ECA name' + eca.Enrollment_Component__r.Name);
                System.debug('Document ECA Status' + eca.Status__c);
                ECAsOfTypeDocument.add(eca.id);       
                ECsOfTypeDocument.add(eca.Enrollment_Component__c);                   
            }
            //added for testing
                
        }
            
               //Mark any Enrollment document that is tied to any ECA we are opening as Invalid.
               Set<id> EDsAlreadyAdded = new Set<Id> ();
               List<Enrollment_Document__c> allEDsToUpdate = new List<Enrollment_Document__c> ();
              for (Enrollment_Document__c ed : [select id, Enrollment_Component_Affiliation__c, Status_Reason__c from Enrollment_Document__c where Enrollment_Component_Affiliation__c in : ECAsOfTypeDocument]) {
                   System.debug('NDEBUG ED ID:::' + ed.Id);
                   System.debug('NDEBUG ED Status_Reason__c:::' + ed.Status_Reason__c);
                   ed.Status_Reason__c = 'Invalid-Reenrollment';
                   //ed.Enrollment_Component_Affiliation__c = null;
                   EDsAlreadyAdded.add(ed.id);
                   allEDsToUpdate.add(ed);
               } 

               //MM 10/5/2020 We need to find the house docs that might be tied to a different ECA.
               List<Enrollment_Document__c> allHouseholdEDsToUpdate = new List<Enrollment_Document__c> ([select id, Status_Reason__c 
                                                                                from Enrollment_Document__c 
                                                                                where Program_Enrollment__c =: studentPERecord.Household_Program_Enrollment__c
                                                                                and Enrollment_Component_Affiliation__r.Enrollment_Component__c in :ECsOfTypeDocument ]);
               for (Enrollment_Document__c ed : allHouseholdEDsToUpdate) {
                   ed.Status_Reason__c = 'Invalid';
                   if (!EDsAlreadyAdded.contains(ed.id))
                       allEDsToUpdate.add(ed);
               }

               if (allEDsToUpdate.size() > 0)
                   update allEDsToUpdate;
            
            if(StageEcaToUpdate.Size()>0)
            	update StageEcaToUpdate;
            
            //Determine which version of the ECA process we are using.       
            //Call the future method that will create the remaining ECAs and the PE Criteria.            
            //PerformAsyncNewStudentSteps(studentPERecord.Id, processComponent[0].Id, caretakerEnrollment[0].Id); 

                     
            //The case creation is now seperated out to a queable.
            System.enqueueJob(new NES_AddStudentCaseQueueable(caretaker,studentPERecord.Id,studentContact[0]));
            peakResponse.success = true;  
            
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
            // Added by Maddileti for defect 452181 on 26/07/2021
            if(callType=='Full'){
            oppToInsert.How_Student_Was_Reactivated__c='Staff';
            oppToInsert.Full_Reactivation_Date__c = Date.today();
            oppToInsert.Full_Reactivation_User__c = UserInfo.getUserId(); 
            } else
            if(callType=='ReActivation'){
            oppToInsert.How_Student_Was_Reactivated__c='Caretaker';
            oppToInsert.Full_Reactivation_Date__c = Date.today();
            oppToInsert.Full_Reactivation_User__c = UserInfo.getUserId(); 
            }
            // End by Maddileti for defect 452181 on 26/07/2021
            //Insert oppToInsert;
            
            String gradeLevel = studentPERecord?.Program_Grade_Level__r?.Grade_Level__r?.Name;
            //ReEnrResults result = new ReEnrResults(studentPERecord.id , processComponent[0].Id, gradelevel, true);
            //return result;
        }
        catch(Exception e){
            peakResponse.success = false;
            peakResponse.messages.add('Could not complete Re-Enrollment process');
            system.debug('exception*************'+e.getMessage());
            logger.logException('There is some issue with the ReEnrollment'+studentPEId, e);
            logger.saveLogs();
            //return null;
    	}
    }
    
}