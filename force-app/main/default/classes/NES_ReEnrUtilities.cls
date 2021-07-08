public class NES_ReEnrUtilities {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ReEnrUtilities');
    
    public static ReEnrResults reenrollingStudent(Id studentContactId, Id studentPEId){
        Peak_Response peakResponse = new Peak_Response();
        
        try{
        
            // Make sure that completion logic is not evaluated now through triggers
            NES_ECACompletion.shouldRunCompletion = false;
            NES_Constants.runAssignment = false;
            NES_LTSUtility.runLTSFlag = false;
            NES_ProgramEnrollmentHandler.runCBL = false;
            
            
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
            
            
            
            // Delete the existing ECAs for this PE
            List <Enrollment_Component_Affiliation__c> oldEcalist = [Select Id, Program_Enrollment__c, Order__c, Status__c from Enrollment_Component_Affiliation__c where 
                                   Program_Enrollment__c =: studentPERecord.Id];
            if(oldEcalist != null && oldEcalist.size()>0)
                delete oldEcalist;
            
            // Delete the Prior School Record attached to this PE
            List <Prior_School__c> oldPrScRec = [Select Id from Prior_School__c where Program_Enrollment__c =: studentPERecord.Id];
            if(oldPrScRec != null && oldPrScRec.size()>0)
                delete oldPrScRec;
            
            // Delete the Special Education Record
            List <Special_Education__c> oldSpEdRec = [select Id from Special_Education__c where Program_Enrollment__c =: studentPERecord.Id];
            if(oldSpEdRec != null && oldSpEdRec.size()>0)
                delete oldSpEdRec;
            
            // Delete the Home Language Survey Record
            List <Home_Language_Survey__c> oldHmLangSRec = [select Id from Home_Language_Survey__c where Program_Enrollment__c =: studentPERecord.Id];
            if(oldHmLangSRec != null && oldHmLangSRec.size()>0)
                delete oldHmLangSRec;
            
            /*
            // Delete the old PECs attached
            List <Program_Enrollment_Criteria__c> oldPecRecs = [Select Id from Program_Enrollment_Criteria__c where Program_Enrollment__c =: studentPERecord.Id];
            if(oldPecRecs != null && oldPecRecs.size()>0)
                delete oldPecRecs;
            */
            
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
            
            // instantiate affiliations to insert, gather record type ids
            Set<Enrollment_Component_Affiliation__c> ecAffiliationsToInsert = new Set<Enrollment_Component_Affiliation__c>();
            
            List<Enrollment_Component__c> processComponent = [
                SELECT Id, Assignment_Logic__c
                FROM Enrollment_Component__c
                WHERE Process_Academic_Program__c = :AcademicProgram[0].Id
                AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                LIMIT 1
            ];
            
            //Get all the stages
            List<Enrollment_Component_Relationship__c> relationships = [
                SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c,
                Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :processComponent
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
                ORDER BY Order__c ASC
            ];
            
            // Add process affiliation
            Enrollment_Component_Affiliation__c affiliationRecord1 = new Enrollment_Component_Affiliation__c();
            affiliationRecord1.Enrollment_Component__c = processComponent[0].Id;
            affiliationRecord1.Program_Enrollment__c = studentPERecord.Id;
            affiliationRecord1.Status__c = 'In Progress';
            ecAffiliationsToInsert.add(affiliationRecord1);
            
            // add stage 1 affiliation
            Enrollment_Component_Affiliation__c affiliationRecord2 = new Enrollment_Component_Affiliation__c();
            affiliationRecord2.Enrollment_Component__c = relationships[0].Child_Enrollment_Component__c;
            affiliationRecord2.Program_Enrollment__c = studentPERecord.Id;
            affiliationRecord2.Status__c = 'Complete';
            affiliationRecord2.Order__c = relationships[0].Order__c;
            ecAffiliationsToInsert.add(affiliationRecord2);
    
            //Add the rest of the stages that have no assignment logic.
            for (Integer i = 1; i < relationships.size(); i++) {
                if (String.isBlank(relationships[i].Child_Enrollment_Component__r.Assignment_Logic__c)) {                
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord.Enrollment_Component__c = relationships[i].Child_Enrollment_Component__c;
                    affiliationRecord.Program_Enrollment__c = studentPERecord.Id;
                    affiliationRecord.Order__c = relationships[i].Order__c;
                    //The second stage should be in progress all others not started.
                    if (i == 1)
                        affiliationRecord.Status__c = 'In Progress';
                    else
                        affiliationRecord.Status__c = 'Not Started';
                    ecAffiliationsToInsert.add(affiliationRecord);
                }
            } 
            
            //add forms affiliation for the forms under stage 1 that have no assignment logic
            List<Enrollment_Component_Relationship__c> formRelationships = [
                SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = :relationships[0].Child_Enrollment_Component__c
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
                ORDER BY Order__c
            ];
            System.debug(formRelationships);
            List<Id> formRelationshipIds = new List<Id>();
            for (Enrollment_Component_Relationship__c formRelationship : formRelationships) {
                if (String.isBlank(formRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                    Enrollment_Component_Affiliation__c affiliationRecord3 = new Enrollment_Component_Affiliation__c();
                    affiliationRecord3.Enrollment_Component__c = formRelationship.Child_Enrollment_Component__c;
                    affiliationRecord3.Program_Enrollment__c = studentPERecord.Id;
                    affiliationRecord3.Status__c = 'Complete';
                    affiliationRecord3.Order__c = formRelationship.Order__c;
                    ecAffiliationsToInsert.add(affiliationRecord3);
                    formRelationshipIds.add(formRelationship.Child_Enrollment_Component__c);
                }
            }
            
            //add section affiliations that have assignment criteria that were added in the previous section.
            List<Enrollment_Component_Relationship__c> sectionRelationships = [
                SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :formRelationshipIds
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
            ];
            System.debug(sectionRelationships);
            for (Enrollment_Component_Relationship__c sectionRelationship : sectionRelationships) {
                if (String.isBlank(sectionRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                    Enrollment_Component_Affiliation__c affiliationRecord3 = new Enrollment_Component_Affiliation__c();
                    affiliationRecord3.Enrollment_Component__c = sectionRelationship.Child_Enrollment_Component__c;
                    affiliationRecord3.Program_Enrollment__c = studentPERecord.Id;
                    affiliationRecord3.Status__c = 'Complete';
                    affiliationRecord3.Order__c = sectionRelationship.Order__c;
                    ecAffiliationsToInsert.add(affiliationRecord3);
                }
            }
            
            List<Enrollment_Component_Affiliation__c> nonNullInsertingAffiliations = new List<Enrollment_Component_Affiliation__c>();
            for (Enrollment_Component_Affiliation__c eca : ecAffiliationsToInsert) {
                if (eca <> null && eca.Enrollment_Component__c <> null && eca.Program_Enrollment__c <> null)
                    nonNullInsertingAffiliations.add(eca);
            }
                    //Commented the below try catch and implemented retry logic to fix issue reported by Perf Team for BUG217916
                    /*try {
                        insert nonNullInsertingAffiliations;
                    } catch (Exception e) {
                        //Try again if it failed.
                        logger.logException('Retrying a timed out insert', e);
                        logger.saveLogs();
                        insert nonNullInsertingAffiliations;
                    }*/
            integer i=0;
            do{
                try{
                    i++;
                    insert nonNullInsertingAffiliations;                
                    break;//Breaking the loop as the DML executed and no exceptions
                }
                catch(Exception e){
                    logger.logException('Retrying a timed out insert', e);
                    logger.saveLogs();                        
                }
            }while(i<5);
            
            
            //Determine which version of the ECA process we are using.       
            //Call the future method that will create the remaining ECAs and the PE Criteria.            
            PerformAsyncNewStudentSteps(studentPERecord.Id, processComponent[0].Id, caretakerEnrollment[0].Id,''); 
            
            //The case creation is now seperated out to a queable.
            System.enqueueJob(new NES_AddStudentCaseQueueable(caretaker,studentPERecord.Id,studentContact[0]));
            peakResponse.success = true;  
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

    PerformAsyncNewStudentSteps( id programEnrollment,  Id processId, id caretakerEnrollmentId, String EnrollmentType)

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

            //Started the loop by Jagadish Babu for ITR
            if(EnrollmentType == 'Returning Student' ){
                if (!ECsAlreadyAddedToPE.contains(ecr.Child_Enrollment_Component__c) && !ECANotNeededForThisRecType){ // && ecr.Child_Enrollment_Component__r.RecordType.Name != 'Stage') {
                    if(ecr.Child_Enrollment_Component__r.Needed_For_ITR__c == true){
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = ecr.Child_Enrollment_Component__c;
                        affiliationRecord.Program_Enrollment__c = programEnrollment;
                        affiliationRecord.Order__c = ecr.Order__c;
                        affiliationRecord.EC_Record_Type__c = ecr.Child_Enrollment_Component__r.RecordType.Name;
                       if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) {
                            affiliationRecord.Status__c = 'Not Started';                           
                        }                            
                        else{
                            affiliationRecord.Status__c = 'Not Applicable';                           
                        } 
                        newAffiliations.add(affiliationRecord);
                        system.debug('Affiliations*********'+affiliationRecord);
                    }  
                }
                
                
            }else{

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

            }//Ended loop Jagadish Babu

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

        //Call a method that will set the initial values for PE Criteria based on current data.
        if (eccs.size()>0) 
            EvaluationUtils.evaluatePECs(eccs, programEnrollment);

        //Mark the PE as ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollment,
                                                                        Enrollment_Type__c = 'Re-enrolling student',
                                                                        Status__c = 'In Progress',
                                                                        Initial_ECA_Creation_Complete__c = true);
        update pe;

        /*
        if(EnrollmentType == 'Returning Student'){
             List<hed__Program_Enrollment__c> programEnrollments = [
                SELECT Id, hed__Contact__c, Start_Year__c, hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
                    EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c,
                    (SELECT Id, Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__c FROM Annual_Student_Information__r)
                FROM hed__Program_Enrollment__c
                WHERE Id = : programEnrollment];
        NES_AnnualStudentInfoBusinessLogic.populateProgramGradeLevel(programEnrollments[0].Annual_Student_Information__r, null);
        }
        else{
           System.enqueueJob(new NES_AddStudentCBLQueueable(programEnrollment)); 
        }
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