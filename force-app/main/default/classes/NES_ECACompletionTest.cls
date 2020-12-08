/**
* Created by triciaigoe on 2019-05-21.
* * * Change Log: Added code by Anitha P for #108693 User Story (Task 109667) on 2019-09-23
*/
@IsTest(SeeAllData=false isParallel=true)
private class NES_ECACompletionTest {
    

    @TestSetup
    static void setup(){
        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        
        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        // careTakerEnrollment.hed__Contact__c = careTakerContact .id;
        insert careTakerEnrollment;
        
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Household_Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.hed__Account__c  = academicProgram.Id;
        // studentEnrollment.hed__Contact__c  = student.Id;
        insert studentEnrollment;
        
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        processComponent.Assignment_Logic__c = '1';
        processComponent.Process_Academic_Program__c = academicProgram.Id;
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        //stageComponent.Completion_Logic__c = 'test';
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Completion_Logic__c = '1';
        // formComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Completion_Logic__c = '1';
        //Start- Added code for #108693 User Story (Task 109667)
        //Create a Document  
        Enrollment_Component__c DocumentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        DocumentComponent.is_Required__c = false;
        DocumentComponent.name ='Document';
        //End- Added code for #108693 User Story (Task 109667) 
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Completion_Logic__c = '1';
        
        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Completion_Logic__c = '1';
        
        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Completion_Logic__c = null;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        
        componentList.add(processComponent);
        componentList.add(DocumentComponent);
        componentList.add(messageComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(formComponent_With_No_Logic);
        componentList.add(sectionComponent);
        componentList.add(sectionComponent_With_No_Logic);
        componentList.add(questionGroupComponent);
        componentList.add(questionGroupComponent_With_No_Logic);
        componentList.add(questionComponent);
        componentList.add(questionComponent_With_No_Logic);
        
        Enrollment_Component__c secComplete = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Completion_Logic__c = null;
        componentList.add(secComplete);
        
        insert componentList;
        

        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        system.debug(stageComponent.Id);
        system.debug('pp'+processComponent.Id);
        Enrollment_Component_Relationship__c stage_form_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c stage_form_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent_With_No_Logic.Id, stageComponent.Id);
        stage_form_with_no_logic_ECR.Order__c = 2;
        update stage_form_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c form_section_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c form_section_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent_With_No_Logic.Id, formComponent.Id);
        form_section_with_no_logic_ECR.Order__c = 2;
        update form_section_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c section_question_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent_With_No_Logic.Id);
        Enrollment_Component_Relationship__c section_question_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent_With_No_Logic.Id, sectionComponent_With_No_Logic.Id);
        section_question_with_no_logic_ECR.Order__c = 2;
        update section_question_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c questionGroup_question_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id,questionGroupComponent_With_No_Logic.Id);
        Enrollment_Component_Relationship__c questionGroup_question_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent_With_No_Logic.Id,questionGroupComponent_With_No_Logic.Id);
        questionGroup_question_with_no_logic_ECR.Order__c = 2;
        update questionGroup_question_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c section_questionGroup_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,sectionComponent.Id);
        section_questionGroup_ECR.Order__c = 3;
        update section_questionGroup_ECR;
        
        Enrollment_Component_Relationship__c section_questionGroup_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent_With_No_Logic.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_with_no_logic_ECR.Order__c = 4;
        update section_questionGroup_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c messageRelationShip = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,messageComponent.Id);
        
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c sectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, sectionComponent.Id, false);
        sectionAffiliation.Status__c = 'In Progress';
        enrollmentComponentAffiliations.add(sectionAffiliation);
        
        //Start- Added code for #108693 User Story (Task 109667) 
        //Create ECA for the Document
        Enrollment_Component_Affiliation__c documentAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, DocumentComponent.Id, false);
        documentAffiliation.Status__c = 'Complete';
        enrollmentComponentAffiliations.add(documentAffiliation);
        //End- Added code for #108693 User Story (Task 109667)     
        
        Enrollment_Component_Affiliation__c questionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionComponent.Id, false);
        enrollmentComponentAffiliations.add(questionAffiliation);
        Enrollment_Component_Affiliation__c questionGrpAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionGroupComponent_With_No_Logic.Id, false);
        enrollmentComponentAffiliations.add(questionGrpAffiliation);
        Enrollment_Component_Affiliation__c completedSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, secComplete.Id, false);
        enrollmentComponentAffiliations.add(completedSecAffiliation);
        Enrollment_Component_Affiliation__c formSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, formComponent.Id, false);
        enrollmentComponentAffiliations.add(formSecAffiliation);
        Enrollment_Component_Affiliation__c stageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        stageAffiliation.Status__c = 'In Progress';
        stageAffiliation.Order__c = 0;
        enrollmentComponentAffiliations.add(stageAffiliation);
        Enrollment_Component_Affiliation__c processAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, processComponent.Id, false);
        enrollmentComponentAffiliations.add(processAffiliation);
        Enrollment_Component_Affiliation__c messageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, messageComponent.Id, false);
        enrollmentComponentAffiliations.add(messageAffiliation);
        
        insert enrollmentComponentAffiliations;                
        
        Opportunity opp = Peak_TestUtils.createOpportunity(studentEnrollment.Id);
        
        List<Enrollment_Component_Picklist_Option__c> picklistOptionList = new List<Enrollment_Component_Picklist_Option__c>();
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        insert picklistOptionList;
        
        List<Option_Exclusion__c> optionExclusionList = new List<Option_Exclusion__c>();
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        insert optionExclusionList;
        
        Criteria__c finalConformationCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c', '<=', false);
        finalConformationCriteria.Comparison_Data_Type__c = 'Datetime';
        finalConformationCriteria.Comparison_Value__c = 'today()';
        insert finalConformationCriteria;
        
        Criteria__c additionalCriteria = Peak_TestUtils.createCriteriaRecord(null, 'Account.Internet_Connection_Type__c', '=', false);
        additionalCriteria.Comparison_Data_Type__c = 'Text';
        additionalCriteria.Comparison_Value__c = 'Cable';
        insert additionalCriteria;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria2 = Peak_TestUtils.createEnrollCompCriteria(null, stageComponent.Id, false);
        studentEnrollmentComponentCriteria2.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria2.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria2.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria2.Criteria_Number__c = 3;
        insert studentEnrollmentComponentCriteria2;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria3 = Peak_TestUtils.createEnrollCompCriteria(null, sectionComponent.Id, false);
        studentEnrollmentComponentCriteria3.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria3.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria3.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria3.Criteria_Number__c = 4;
        insert studentEnrollmentComponentCriteria3;
        
        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        houseHoldEnrollmentComponentCriteria.Criteria__c = additionalCriteria.Id;
        houseHoldEnrollmentComponentCriteria.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria.Criteria_Type__c = 'Completion';
        houseHoldEnrollmentComponentCriteria.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria;
        
        Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup(null, formComponent.Id, false);
        criteriaGroup.Group_Number__c = 1;
        criteriaGroup.Group_Logic__c = '2';
        insert criteriaGroup;
        
        Criteria_Group__c criteriaGroup2 = Peak_TestUtils.createCriteriaGroup(null, sectionComponent.Id, false);
        criteriaGroup2.Group_Number__c = 1;
        criteriaGroup2.Group_Logic__c = '2';
        insert criteriaGroup2;
        
        Criteria_Group__c criteriaGroup3 = Peak_TestUtils.createCriteriaGroup(null, stageComponent.Id, false);
        criteriaGroup3.Group_Number__c = 1;
        criteriaGroup3.Group_Logic__c = '2';
        insert criteriaGroup3;
        
        Criteria_Refinement__c refinementOne = new Criteria_Refinement__c();
        refinementOne.Criteria__c = finalConformationCriteria.Id;
        refinementOne.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementOne.Refinement_Type__c = 'Right Side';
        refinementOne.Operator__c = '=';
        refinementOne.Refinement_Value__c = 'TNCA';
        insert refinementOne;
        
        Criteria_Refinement__c refinementTwo = new Criteria_Refinement__c();
        refinementTwo.Criteria__c = finalConformationCriteria.Id;
        refinementTwo.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementTwo.Refinement_Type__c = 'Right Side';
        refinementTwo.Operator__c = '=';
        refinementTwo.Refinement_Value__c = 'Pearson Pre';
        insert refinementTwo;
    }


    /**
    * @author: Ali KM created on 01-22-2020 for [US 122106]
    * @purpose : This method is test coverage for ECAs that are set to NotApplicable & need SectionCompletion logic executed.
    *            related code is in NES_ECABusinessLogic.runECACompletionForNAStatus() method.
    */
    static testMethod void naECAsCompletionLogic_PositiveTest() { 

        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        String accountId = programEnrollment.hed__Contact__r.AccountId;
        String processIdstring = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.PROCESS_RT LIMIT 1].Id;
        
        Enrollment_Component__c  prEn=[select id from Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.SECTION_RT LIMIT 1];
         
        System.debug('prEn.id'+prEn.id);
        map<id,id> ecaMap = new map<id,id>();
        list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c>();
        
        for( Enrollment_Component_Affiliation__c  ecaAffiliation : 
            [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
                Where Status__c='In Progress' and Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT]){
                    ecaAffiliation.Status__c='Not Applicable';
                    ecaList.add(ecaAffiliation);
                    ecaMap.put(ecaAffiliation.Enrollment_Component__c, ecaAffiliation.Program_Enrollment__c);  
                }
      
        update ecaList;

    }
    
    static testMethod void unitTestOne() {
        Test.startTest();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        String accountId = programEnrollment.hed__Contact__r.AccountId;
        String processIdstring = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.PROCESS_RT LIMIT 1].Id;
        Set<Id> processId = new set<Id>();//added
        processId.add(processIdstring);//added
        List<Id> processChildren = NES_ECACompletion.grabProcessChildrenIds(processId);
        List<String> changedFields = new List<String>();
        changedFields.add('Internet_Connection_Type__c');
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
        changedFieldsMap.put(accountId, changedFields);
        NES_ECACompletion.accountCompletion(changedFieldsMap);
        Test.stopTest();
        System.assertNotEquals(null, changedFieldsMap);
    }
    
    //Start- Added code for #108693 User Story (Task 109667) 
    //create test method for contactCompletion method
    static testMethod void unitTestwo() {
        Test.startTest();
        //fetch program enrollment
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        String contactId = programEnrollment.hed__Contact__c;
        //Fetch Enrollment component
        String processIdstring = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.PROCESS_RT LIMIT 1].Id;
        Set<Id> processId = new set<Id>();//added
        processId.add(processIdstring);//added
        List<Id> processChildren = NES_ECACompletion.grabProcessChildrenIds(processId);
        List<String> changedFields = new List<String>();
        changedFields.add('Internet_Connection_Type__c');
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
        changedFieldsMap.put( contactId, changedFields);
        //call method contactCompletion
        NES_ECACompletion.contactCompletion(changedFieldsMap);
        Test.stopTest();
       
    }
     //create test method for fireAssignment,fireCompletion
    static testMethod void unitTest3() {
        Test.startTest();
        Map<Id, Boolean> completionMap = new  Map<Id, Boolean> ();
         //fetch program enrollment
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        String contactId = programEnrollment.hed__Contact__c;
         //Fetch Enrollment component
        String processId = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.PROCESS_RT LIMIT 1].Id;
        completionMap.put(programEnrollment.id,true);
        //call method fireAssignment,fireCompletion
        //NES_ECACompletion.fireAssignment(completionMap);
        Map<Id, List<Id>> completionMapvalues = new Map<Id, List<Id>> ();//added
        list<id> impactedcomp = new list<id>();
        impactedcomp.add(processId);
        completionMapvalues.put(programEnrollment.id,impactedcomp);

		Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap = new Map<Id,List<Enrollment_Component_Affiliation__c>> ();
		for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
															FROM Enrollment_Component_Affiliation__c
															WHERE Program_Enrollment__c = :programEnrollment.id]) {
			if (!progEnrollECAListMap.containsKey(affiliation.Program_Enrollment__c)){
				list <Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
				ecas.add(affiliation);
				progEnrollECAListMap.put(affiliation.Program_Enrollment__c, ecas);
			} else
				progEnrollECAListMap.get(affiliation.Program_Enrollment__c).add(affiliation);
		}

		Set<Id> acedemicProgramsReferenced = new Set<Id> ();
		map<Id,hed__Program_Enrollment__c> EnrollmentsMap = new map<Id,hed__Program_Enrollment__c>();
        for (hed__Program_Enrollment__c pe: [ SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, 
								hed__Contact__r.AccountId, Household_Program_Enrollment__c
                        FROM hed__Program_Enrollment__c
                        WHERE id = :programEnrollment.id ]) {
			EnrollmentsMap.put(pe.Id, pe);
			acedemicProgramsReferenced.add(pe.hed__Account__c);
		}

		//Build a map between Academic Programs and Process ids.
		map <Id, Id> academicProgramProcessIdMap = new Map<Id,Id>();
		for (Enrollment_Component__c e : [SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :acedemicProgramsReferenced])
		{
			academicProgramProcessIdMap.put(e.Process_Academic_Program__c, e.id);
		}

        NES_ECACompletion.fireCompletion(completionMapvalues, progEnrollECAListMap, EnrollmentsMap, academicProgramProcessIdMap);//added

        Test.stopTest();  
    }
    //create test method for programEnrollmentCriteria method
    static testMethod void unitTest4() {
        Test.startTest();
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
         List<String> changedFields = new List<String>();
        //fetch program enrollment
        hed__Program_Enrollment__c programEnrollment = [SELECT Id,hed__Account__c, hed__Contact__c,hed__Contact__r.RecordType.Name,
                                                        Household_Program_Enrollment__c,
                                                        Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                                                        FROM hed__Program_Enrollment__c 
                                                        WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        //Fetch ECA
        
        Enrollment_Component_Affiliation__c ecaAffrecord = new Enrollment_Component_Affiliation__c ();
       for (Enrollment_Component_Affiliation__c ecaAffiliation : [SELECT id,Status__c FROM Enrollment_Component_Affiliation__c 
                                                              where Status__c = 'In Progress'
                                                                  and Program_Enrollment__c =: programEnrollment.ID limit 1]){
        ecaAffiliation.Status__c = 'Complete';
         ecaAffrecord = ecaAffiliation;
         break;
        }
       
        Update ecaAffrecord;
        String contactId = programEnrollment.hed__Contact__c;
         //call method fireAssignment,fireCompletion
        String processIdstring = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.PROCESS_RT LIMIT 1].Id;
        Set<Id> processId = new set<Id>();//added
        processId.add(processIdstring);//added
        List<Id> processChildren = NES_ECACompletion.grabProcessChildrenIds(processId);
        changedFields.add('Status__c');
        changedFieldsMap.put( programEnrollment.id, changedFields);
        string obj = 'Enrollment_Component_Affiliation__c';
        List<hed__Program_Enrollment__c> programEnrollments  = new List<hed__Program_Enrollment__c> ();
        programEnrollments.add(programEnrollment);
        //Call programEnrollmentCriteria method
        NES_ECACompletion.programEnrollmentCriteria( changedFieldsMap,obj,programEnrollments);
        Test.stopTest(); 
    }
    //create test method for grabIncompleteBoolean method
    static testMethod void unitTest5() {
        Test.startTest();
         Map<Id, Enrollment_Component_Affiliation__c>  ecamap= new Map<Id, Enrollment_Component_Affiliation__c> ();
         List<Id> childIds = new List<Id> ();
        //Fetch ECA
        Enrollment_Component_Affiliation__c ecaAffiliation = [SELECT id,Status__c,Program_Enrollment__c,Enrollment_Component__c ,Enrollment_Component__r.RecordType.Name,Enrollment_Component__r.Is_Required__c
                                                              FROM Enrollment_Component_Affiliation__c where Enrollment_Component__r.Name = 'Document' limit 1];
        ecaAffiliation.Status__c = 'In Progress';
        update  ecaAffiliation;
        childIds.add(ecaAffiliation.id);
        ecamap.put(ecaAffiliation.id,ecaAffiliation);
        //Call grabIncompleteBoolean method
        NES_ECACompletion.grabIncompleteBoolean( childIds, ecamap);
        childIds.clear();
        ecamap.clear();
        ecaAffiliation.Enrollment_Component__r.Is_Required__c= true;
        update  ecaAffiliation;
        childIds.add(ecaAffiliation.id);
        ecamap.put(ecaAffiliation.id,ecaAffiliation);
        //Call grabIncompleteBoolean method
        NES_ECACompletion.grabIncompleteBoolean( childIds, ecamap);
        Test.stopTest(); 
    }
    //create test method for evaluateCompletion
    static testMethod void unitTest6() {
        Test.startTest();
          
        Map<Id, Enrollment_Component_Affiliation__c> singleAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();  
         List<Id> stageIds = new List<Id>();
         Set<Id> formFlagIds = new Set<Id>();
        Id sectionid;
         //Fetch program enrollment
        hed__Program_Enrollment__c programEnrollment = [SELECT Id,hed__Account__c , hed__Contact__r.AccountId ,hed__Contact__c,hed__Contact__r.RecordType.Name, Household_Program_Enrollment__r.hed__Contact__c, Household_Program_Enrollment__c  FROM hed__Program_Enrollment__c 
                                                        WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        //Fecth Enrollment componet
        Enrollment_Component__c processComponent = [SELECT Id FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :programEnrollment.hed__Account__c LIMIT 1];
        Id processId = processComponent.Id;
        iD enrollmentId = programEnrollment.ID; 
       //Fetch Relationships
        for ( Enrollment_Component_Relationship__c  processRelationship : [
            SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name,
            Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c = :processId
            AND Child_Enrollment_Component__r.RecordType.Name = 'Stage' ORDER BY Order__c]){
                stageIds.add(processRelationship.Child_Enrollment_Component__c);
            }
        //Fetch Relationships 
        for( Enrollment_Component_Relationship__c stageRelationship :[
            SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.RecordType.Name,
            Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Completion_Logic__c,
            Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN :stageIds
            AND (Child_Enrollment_Component__r.RecordType.Name = 'Form'
                 OR Child_Enrollment_Component__r.RecordType.Name = 'Flag'
                 OR Child_Enrollment_Component__r.RecordType.Name = 'Message')]){
                     
                     formFlagIds.add(stageRelationship.Child_Enrollment_Component__c);
                 }
        //Fetch Relationships
        List<Enrollment_Component_Relationship__c> formRelationships = [
            SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.RecordType.Name,
            Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Completion_Logic__c,
            Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN :formFlagIds
            AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
                 OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT)
        ];
       //Feltch ECA's
	   List<Enrollment_Component_Affiliation__c> thisStudentsECAs = new List<Enrollment_Component_Affiliation__c>();
        for( Enrollment_Component_Affiliation__c studentAffiliations :[
            SELECT Id, Enrollment_Component__c, Order__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.Assignment_Logic__c,
            Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Is_Required__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c = : programEnrollment.id]){
                singleAffiliationMap.put(studentAffiliations.Enrollment_Component__c, studentAffiliations);
                sectionid =  formRelationships[0].Child_Enrollment_Component__c;
				thisStudentsECAs.add(studentAffiliations);
            }

        //call evaluateCompletion method
        NES_ECACompletion.evaluateCompletion(enrollmentId, null,null,  singleAffiliationMap, thisStudentsECAs, programEnrollment);
        //call evaluateCompletion method for sectionID
        NES_ECACompletion.evaluateCompletion(enrollmentId, null,sectionid,  singleAffiliationMap, thisStudentsECAs, programEnrollment);
        Test.stopTest(); 
    }
    //create test method for relatedCompletion and programEnrollmentCompletion
    static testMethod void unitTest7() {
        Test.startTest();
        Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
        List<String> changedFields = new List<String>();
         Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();
        List<Id> peids = new list<id>();
        //Fetch program enrollment
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker'];
        String contactId = programEnrollment.hed__Contact__c;
        peids.add(programEnrollment.id);
        peToObjectMap.put(programEnrollment.id ,peids);
        //Fecth Ecnrollmet component
        Enrollment_Component__c stageComponent = [SELECT Id ,Completion_Logic__c FROM Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.STAGE_RT LIMIT 1];
        stageComponent.Completion_Logic__c = 'test';
        update stageComponent;
        changedFields.add('Internet_Connection_Type__c');
        changedFieldsMap.put( programEnrollment.id, changedFields);
        //call relatedCompletion
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

        NES_ECACompletion.relatedCompletion(changedFieldsMap,'Account',peToObjectMap, fieldUpdateList);
        //call programEnrollmentCompletion
        NES_ECACompletion.programEnrollmentCompletion(changedFieldsMap,'Account');
        Test.stopTest();
    }
    
    //End- Added code for #108693 User Story (Task 109667)

    static testMethod void waitListDate_PositiveTest() { 

        hed__Program_Enrollment__c programEnrollment = [SELECT Id, Waitlist_Time_Date_Stamp__c FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];
        system.assertEquals(null, programEnrollment.Waitlist_Time_Date_Stamp__c, 'Waitlist should be null to begin with.');

        Enrollment_Component__c  prEn=[select id from Enrollment_Component__c WHERE RecordType.Name =: NES_DashboardUtilities.SECTION_RT LIMIT 1];
        prEn.Waitlist__c = true;
		update prEn;
		 
        list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c> ([select id from Enrollment_Component_Affiliation__c where Enrollment_Component__c = :prEn.id]);
        ecaList[0].Status__c='Not Started';
        update ecaList;

        ecaList[0].Status__c='In Progress';
        update ecaList;

		//Re get the PE and make sure the waitlist date has been set.
		programEnrollment = [SELECT Id, Waitlist_Time_Date_Stamp__c FROM hed__Program_Enrollment__c WHERE Household_Program_Enrollment__c != NULL LIMIT 1];

		system.assertNotEquals(null, programEnrollment.Waitlist_Time_Date_Stamp__c, 'Waitlist should no longer be null.');
    }
}