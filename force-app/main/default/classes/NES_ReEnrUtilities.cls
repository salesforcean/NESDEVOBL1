public without Sharing class NES_ReEnrUtilities {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ReEnrUtilities');
    
    public static ReEnrResults reenrollingStudent(Id studentContactId, Id studentPEId){
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
            
            
            
            List<Enrollment_Component__c> processComponent = [
                SELECT Id, Assignment_Logic__c
                FROM Enrollment_Component__c
                WHERE Process_Academic_Program__c = :AcademicProgram[0].Id
                AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                LIMIT 1
            ];
            
            // Start updating the ECAs
            List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>([
                    SELECT  Id, SystemModstamp, Enrollment_Component__c,Status__c,Order__c,
                            Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c,
                            Enrollment_Component__r.Needed_for_Re_enrollment__c,Enrollment_Component__r.Assignment_Logic__c,Enrollment_Component__r.Name,
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
                if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)) || (eca.Enrollment_Component__r.Needed_for_Re_enrollment__c)){
					eca.Status__c = 'Not Started';
				}
				else{
					eca.Status__c = 'Not Applicable';
				}
            }else if((eca.Enrollment_Component__r.RecordType.Name == 'Stage')  && (eca.Status__c == 'In Progress' || eca.Status__c == 'Complete')){
                if(eca.Order__c == 2){
                    eca.Status__c = 'In Progress';
                }else if(eca.Order__c > 2){
					if(String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c)){
						eca.Status__c = 'Not Started';
					}
					else{
						eca.Status__c = 'Not Applicable';
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
            PerformAsyncNewStudentSteps(studentPERecord.Id, processComponent[0].Id, caretakerEnrollment[0].Id); 

                     
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
            Insert oppToInsert;
            
            String gradeLevel = studentPERecord?.Program_Grade_Level__r?.Grade_Level__r?.Name;
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
    
    
   @future 
    public static void 

    PerformAsyncNewStudentSteps( Id programEnrollment,  Id processId, id caretakerEnrollmentId)

    {
        //This method is called from Add a student process. Runs as a future method.  Will create the remaining ECAs and all the PE Criteria Records.

        //Retrieve the ECR tree.
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
        //Retrieve all the ECRs for this process
        List<Enrollment_Component_Relationship__c> allECRs = new list <Enrollment_Component_Relationship__c> ();
        allECRs.addAll(thisProcessData.stageRelationships);
        allECRs.addAll(thisProcessData.formRelationships);
        allECRs.addAll(thisProcessData.sectionRelationships);
        allECRs.addAll(thisProcessData.questionGroupRelationships);
        allECRs.addAll(thisProcessData.questionRelationships);

        //Get the ECs that have already been added to this PE
        Set<Id> ECsAlreadyAddedToPE = new Set<Id> ();
        for (Enrollment_Component_Affiliation__c eca : [select Enrollment_Component__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :programEnrollment])
            ECsAlreadyAddedToPE.add(eca.Enrollment_Component__c);

        //Add all ther remaining ECAs
        list<Enrollment_Component_Affiliation__c> newAffiliations = new list<Enrollment_Component_Affiliation__c>();
        Set<id> allECs = new set <Id>();  // Holds all the Enrollment Components for this Academic Program

        Set<id> allQuestionECs = new set <Id>();  // Holds all the Enrollment Components that are questions so we can use that list later to set initial values.

        //Add all the ECAs that have not already been added.  The ones with assignment criteria should be 'Not Started' the ones
        //with assignment criteria should be 'Not Applicable' for now.  If their assignment criteria is met, it will get switched to not started.
        //We also don't want to create ECAs for Questions, Question Groups, Messages and Text.  The community will retrieve
        //what should appear within a section based on the ECRs instead of the ECAs.
        for (Enrollment_Component_Relationship__c ecr : allECRs) {
            //Determine if it is one of the excluded record types.
            boolean ECANotNeededForThisRecType = false;
            if ( ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.HIDDEN_INPUT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.TEXT_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT )
                    ECANotNeededForThisRecType = true;            

            if (!ECsAlreadyAddedToPE.contains(ecr.Child_Enrollment_Component__c) && !ECANotNeededForThisRecType) {
                Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                affiliationRecord.Enrollment_Component__c = ecr.Child_Enrollment_Component__c;
                affiliationRecord.Program_Enrollment__c = programEnrollment;
                affiliationRecord.Order__c = ecr.Order__c;
                affiliationRecord.EC_Record_Type__c = ecr.Child_Enrollment_Component__r.RecordType.Name;

                if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) 
                    affiliationRecord.Status__c = 'Not Started';
                else
                    affiliationRecord.Status__c = 'Not Applicable';

                newAffiliations.add(affiliationRecord);
            }

            

            //While we are looping over the ECRs, collect all the ECs for this process so we can retrieve all the required criteria.
            allECs.add(ecr.Child_Enrollment_Component__c);


            if (ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT)
                allQuestionECs.add(ecr.Child_Enrollment_Component__c);
        }

        if (newAffiliations.size() > 0)
            insert newAffiliations;



        // collect SchoolYears
        Map<String, School_Year__c> schoolYearByExternalId = new Map<String, School_Year__c>();
        // collect QuestionGroups        
        Map<String, Enrollment_Component__c> questionGroupByExternalId = new Map<String, Enrollment_Component__c>();
        // END ...


        // // collect 
        // Map<String, Map<String, List<String>>> criteriaObjectFieldsMapByPEType = new Map<String, Map<String, List<String>>>();
        List<Enrollment_Component_Criteria__c> eccs = new List<Enrollment_Component_Criteria__c>();

        //Now insert all the Program Enrollment Criteria records.
        list <Program_Enrollment_Criteria__c> pecsToInsert = new list <Program_Enrollment_Criteria__c> ();
        Set<String> pecAlreadyIncluded = new Set<String> (); //The combination of criteriaid, questiongroup, school year and student or house
        
        // Get the Existing PECs        
        for (Program_Enrollment_Criteria__c pec : [
            SELECT  Criteria__c, Criteria__r.Criteria_Field__c, Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c   
            FROM    Program_Enrollment_Criteria__c 
            WHERE   Program_Enrollment__c =: programEnrollment ]) 
        {
            pecAlreadyIncluded.add(pec.Criteria__c + pec.Student_or_Household__c + pec.Question_Group__c + pec.School_Year__c);
        }
        
        // Get the ECCs and create corresponding PECs if required
        for (Enrollment_Component_Criteria__c ecc : [
            SELECT  Criteria__c, Criteria__r.Criteria_Field__c, Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c   
            FROM    Enrollment_Component_Criteria__c 
            WHERE   Enrollment_Component__c in :allECs]) 
        {
            eccs.add(ecc);
            if (!pecAlreadyIncluded.contains(ecc.Criteria__c + ecc.Student_or_Household__c + ecc.Question_Group__c + ecc.School_Year__c)) {
                // collect schoolYearExtId && questionGroupExtId
                if (String.isNotEmpty(ecc.School_Year__c))
                    schoolYearByExternalId.put(ecc.School_Year__c,null);
                if (String.isNotEmpty(ecc.Question_Group__c))    
                    questionGroupByExternalId.put(ecc.Question_Group__c,null);
                // collect schoolYearExtId && questionGroupExtId END...


                pecAlreadyIncluded.add(ecc.Criteria__c + ecc.Student_or_Household__c + ecc.Question_Group__c + ecc.School_Year__c);
                Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c();
                newPEC.Program_Enrollment__c = programEnrollment;
                newPEC.Criteria__c = ecc.Criteria__c;
                newPEC.Student_or_Household__c = ecc.Student_or_Household__c;
                newPEC.Most_Recent__c = ecc.Most_Recent__c;
                newPEC.Question_Group__c = ecc.Question_Group__c;
                newPEC.School_Year__c = ecc.School_Year__c;
                pecsToInsert.add(newPEC);
            }
        }


        // Copying Rec.Id from ExternalId Map
        if (schoolYearByExternalId.size() > 0 ) {
            for (School_Year__c schYear : [ SELECT Id, External_Id__c, Name from School_Year__c where External_Id__c IN : schoolYearByExternalId.keySet()]) {
                schoolYearByExternalId.put(schYear.External_Id__c, schYear);
            }
            for (Program_Enrollment_Criteria__c newPEC : pecsToInsert) {
                School_Year__c tmpSY = schoolYearByExternalId.get(newPEC.School_Year__c);
                if (tmpSY!=null) {
                    newPEC.School_Year__c = tmpSY.Id;
                }
            }
        }
        if (questionGroupByExternalId.size() > 0 ) {
            for (Enrollment_Component__c questionGroupEC : [ SELECT Id, External_Id__c, Name from Enrollment_Component__c where External_Id__c IN : questionGroupByExternalId.keySet()]) {
                questionGroupByExternalId.put(questionGroupEC.External_Id__c, questionGroupEC);
            }

            for (Program_Enrollment_Criteria__c newPEC : pecsToInsert) {
                Enrollment_Component__c tmpEC = questionGroupByExternalId.get(newPEC.Question_Group__c);
                if (tmpEC!=null) {
                    newPEC.Question_Group__c = tmpEC.Id;
                }
            }
        }


        if (pecsToInsert.size() > 0)
            insert pecsToInsert;
        
        //Mark the PE as ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollment,
                                                                        Enrollment_Type__c = 'Re-enrolling student',
                                                                        Status__c = 'In Progress',
                                                                        Initial_ECA_Creation_Complete__c = true);
        update pe;

        /*
        //Call a method that will set the initial values for PE Criteria based on current data.
        if (eccs.size()>0) 
            EvaluationUtils.evaluatePECs(eccs, programEnrollment);
        */
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