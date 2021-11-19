@isTest
private class NES_ECAEvaluationTest {
    
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
        insert careTakerEnrollment;


        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);

        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        insert studentEnrollment;

        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        processComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Completion_Logic__c = 'test';

        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        //questionGroupComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        //added
        Enrollment_Component__c stageComponent1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.name = 'Waitlist';
        //added

        Enrollment_Component__c processComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);        
        Enrollment_Component__c stageComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c formComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);        
        Enrollment_Component__c sectionComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);        
        Enrollment_Component__c questionGroupComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);        
        Enrollment_Component__c questionComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c messageComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);

        componentList.add(messageComponent);
        componentList.add(processComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(formComponent_With_No_Logic);
        componentList.add(sectionComponent);
        componentList.add(sectionComponent_With_No_Logic);
        componentList.add(questionGroupComponent);
        componentList.add(questionGroupComponent_With_No_Logic);
        componentList.add(questionComponent);
        componentList.add(questionComponent_With_No_Logic);
        componentList.add(stageComponent1);//added


        //Second version of stage records
        componentList.add(processComponentNew);
        componentList.add(stageComponentNew);//added
        componentList.add(formComponentNew);//added
        componentList.add(sectionComponentNew);//added
        componentList.add(questionGroupComponentNew);//added
        componentList.add(questionComponentNew);//added
        componentList.add(messageComponentNew);//added
        
        
     
        
        Enrollment_Component__c secComplete = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        componentList.add(secComplete);

        insert componentList;

        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);

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

        //Second Version of Enrollment component Relationship records
        Enrollment_Component_Relationship__c process_stage_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentNew.Id, processComponentNew.Id);
        Enrollment_Component_Relationship__c stage_form_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(formComponentNew.Id, stageComponentNew.Id);
        Enrollment_Component_Relationship__c form_section_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponentNew.Id, formComponentNew.Id);
        Enrollment_Component_Relationship__c section_question_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentNew.Id, sectionComponentNew.Id);
        Enrollment_Component_Relationship__c questionGroup_question_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentNew.Id,questionGroupComponentNew.Id);
        Enrollment_Component_Relationship__c messageRelationShipNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponentNew.Id,messageComponentNew.Id);



        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c sectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, sectionComponent.Id, false);
        enrollmentComponentAffiliations.add(sectionAffiliation);
        Enrollment_Component_Affiliation__c questionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionComponent.Id, false);
        enrollmentComponentAffiliations.add(questionAffiliation);
        Enrollment_Component_Affiliation__c questionGrpAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionGroupComponent_With_No_Logic.Id, false);
        enrollmentComponentAffiliations.add(questionGrpAffiliation);
        Enrollment_Component_Affiliation__c completedSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, secComplete.Id, false);
        enrollmentComponentAffiliations.add(completedSecAffiliation);
        Enrollment_Component_Affiliation__c formSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, formComponent.Id, false);
        enrollmentComponentAffiliations.add(formSecAffiliation);
        Enrollment_Component_Affiliation__c stageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        enrollmentComponentAffiliations.add(stageAffiliation);
        Enrollment_Component_Affiliation__c processAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, processComponent.Id, false);
        enrollmentComponentAffiliations.add(processAffiliation);
        Enrollment_Component_Affiliation__c messageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, messageComponent.Id, false);
        enrollmentComponentAffiliations.add(messageAffiliation);

        insert enrollmentComponentAffiliations;

        
        list<Enrollment_Document__c> enrollmntDocList = new list<Enrollment_Document__c> ();
        Enrollment_Document__c enrollmntDoc  = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'Gifted Documentation','Submitted',false);
        enrollmntDoc.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc);
        Enrollment_Document__c enrollmntDoc2 = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'IEP Exit Documentation','Submitted',false); 
        enrollmntDoc2.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc2); 
        Enrollment_Document__c enrollmntDoc3 = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'Report Card','Submitted',false); 
        enrollmntDoc3.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc3);
        Enrollment_Document__c enrollmntDoc5 = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'Home School Prior Academic History','Submitted',false); 
        enrollmntDoc5.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc5);
        Enrollment_Document__c enrollmntDoc6 = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'Unofficial Transcript','Submitted',false); 
        enrollmntDoc6.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc6);
        Enrollment_Document__c enrollmntDoc7 = Peak_TestUtils.createEnrollmentDocumentRecord(careTakerEnrollment.Id,'State Test Scores','Submitted',false); 
        enrollmntDoc7.Uploader__c = careTaker.Id;
        enrollmntDocList.add(enrollmntDoc7);
        insert enrollmntDocList;
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

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Type__c = 'Assignment';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria2 = Peak_TestUtils.createEnrollCompCriteria(null, stageComponent.Id, false);
        studentEnrollmentComponentCriteria2.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria2.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria2.Criteria_Type__c = 'Assignment';
        studentEnrollmentComponentCriteria2.Criteria_Number__c = 3;
        insert studentEnrollmentComponentCriteria2;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria3 = Peak_TestUtils.createEnrollCompCriteria(null, sectionComponent.Id, false);
        studentEnrollmentComponentCriteria3.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria3.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria3.Criteria_Type__c = 'Assignment';
        studentEnrollmentComponentCriteria3.Criteria_Number__c = 4;
        insert studentEnrollmentComponentCriteria3;

        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        houseHoldEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        houseHoldEnrollmentComponentCriteria.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria.Criteria_Type__c = 'Assignment';
        houseHoldEnrollmentComponentCriteria.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria;
        
        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria4 = Peak_TestUtils.createEnrollCompCriteria(null, questionGroupComponent.Id, false);
        houseHoldEnrollmentComponentCriteria4.Criteria__c = finalConformationCriteria.Id;
        houseHoldEnrollmentComponentCriteria4.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria4.Criteria_Type__c = 'Assignment';
        houseHoldEnrollmentComponentCriteria4.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria4;
        
        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria5 = Peak_TestUtils.createEnrollCompCriteria(null, questionComponent.Id, false);
        houseHoldEnrollmentComponentCriteria5.Criteria__c = finalConformationCriteria.Id;
        houseHoldEnrollmentComponentCriteria5.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria5.Criteria_Type__c = 'Assignment';
        houseHoldEnrollmentComponentCriteria5.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria5;

        Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup(null, formComponent.Id, false);
        criteriaGroup.Group_Number__c = 1;
        criteriaGroup.Group_Logic__c = '1 OR 2 OR 3 OR 4 OR 5';
        insert criteriaGroup;

        Criteria_Group__c criteriaGroup2 = Peak_TestUtils.createCriteriaGroup(null, sectionComponent.Id, false);
        criteriaGroup2.Group_Number__c = 1;
        criteriaGroup2.Group_Logic__c = '1 OR 2 OR 3 OR 4 OR 5';
        insert criteriaGroup2;

        Criteria_Group__c criteriaGroup3 = Peak_TestUtils.createCriteriaGroup(null, stageComponent.Id, false);
        criteriaGroup3.Group_Number__c = 1;
        criteriaGroup3.Group_Logic__c = '1 OR 2 OR 3 OR 4 OR 5';
        insert criteriaGroup3;
        
        Criteria_Group__c criteriaGroup4 = Peak_TestUtils.createCriteriaGroup(null, questionGroupComponent.Id, false);
        criteriaGroup4.Group_Number__c = 1;
        criteriaGroup4.Group_Logic__c = '1 OR 2 OR 3 OR 4 OR 5';
        insert criteriaGroup4;
        
        Criteria_Group__c criteriaGroup5 = Peak_TestUtils.createCriteriaGroup(null, questionComponent.Id, false);
        criteriaGroup5.Group_Number__c = 1;
        criteriaGroup5.Group_Logic__c = '1 OR 2 OR 3 OR 4 OR 5';
        insert criteriaGroup5;
        
        
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

        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(academicProgram.Id);
    }
    
    static testMethod void unitTestOne() { 
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();

        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];

                account acctToUpdate = new account (id = studentEnrollment.hed__Contact__r.AccountId, Confirmation_Start_Date__c = System.today() + 5);
        update acctToUpdate;

        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);

        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }

        //Go get all the EC data for this process id.
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
         //added
         List<Enrollment_Component_Affiliation__c> progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();
         for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Program_Enrollment__c = :studentEnrollmentId]) {
                progEnrollECAListMap.add(affiliation);
            }
        list<id> impactedcomponents = new list<id>();
          Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Name = 'Waitlist' AND RecordType.Name = 'Stage' limit 1];  
          system.debug('qComponent'+qComponent);
        impactedcomponents.add(qComponent.id);
        //added
        Test.startTest();
            NES_ECAEvaluation.evalAssignment(studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId,
            stageRelationships, formFlagRelationships, sectionDocRelationships, questionGroupRelationships, questionRelationships, thisProcessData,impactedcomponents,progEnrollECAListMap);//added
        Test.stopTest();
    }
    static testMethod void unitTestTwo() { 
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component__c> ecomp = new List<Enrollment_Component__c>();
        for( Enrollment_Component__c ec : [SELECT Id, Assignment_Logic__c  FROM Enrollment_Component__c LIMIT 100]){
            ec.Assignment_Logic__c = null;
            ecomp.add(ec);
        }
        update ecomp;
        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            stageRelationships.add(relationShip);
            stageRelationships.add(relationShip);
        }

        //added by anitha P 
        Enrollment_Component__c processComponent = [select id from Enrollment_Component__c where RecordType.Name = 'Process' limit 1 ];
        //added by anitha P
        Test.startTest();
            List<Id> relationIds = new List<Id>();
            for (Enrollment_Component_Relationship__c r :stageRelationships)
                relationIds.add(r.id);
            NES_ECAEvaluation.createRemainingAffiliations(accountId, studentId, caretakerContactId, studentEnrollmentId, caretakerEnrollmentId, relationIds, processComponent.id);
        Test.stopTest();
    }

    static testMethod void unitTestThree() { 
        List<String> ecomp = new List<String>();
        for( Enrollment_Component__c ec : [SELECT Id, Assignment_Logic__c  FROM Enrollment_Component__c LIMIT 100]){
            ecomp.add(ec.Id);
        }
        Test.startTest();
            NES_ECAEvaluation.getCriteriaFieldList(ecomp, 'Assignment');
        Test.stopTest();
    }

    static testMethod void unitTestFour() { 
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();

        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];

        account acctToUpdate = new account (id = studentEnrollment.hed__Contact__r.AccountId, Confirmation_Start_Date__c = System.today() - 5);
        update acctToUpdate;

        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);

        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }
        
        //Go get all the EC data for this process id.
        Enrollment_Component__c processComponent = [select id from Enrollment_Component__c where RecordType.Name = 'Process' limit 1 ];

        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processComponent.id);
         //added
         List<Enrollment_Component_Affiliation__c> progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();
  
         for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Program_Enrollment__c = :studentEnrollmentId]) {
                progEnrollECAListMap.add(affiliation);
            }  
        delete progEnrollECAListMap;
        progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();

        list<id> impactedcomponents = new list<id>();
          Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Name = 'Waitlist' AND RecordType.Name = 'Stage' limit 1];  
          system.debug('qComponent'+qComponent);
        impactedcomponents.add(qComponent.id);
        impactedcomponents.addAll(allECData.enrollmentComponentMap.keySet());

        //added
        Test.startTest();
            NES_ECAEvaluation.evalAssignment(studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId,
            thisProcessData.stageRelationships, thisProcessData.formRelationships, thisProcessData.sectionRelationships, thisProcessData.questionGroupRelationships, thisProcessData.questionRelationships, thisProcessData,impactedcomponents,progEnrollECAListMap);//added
        Test.stopTest();
    }
    
    
    static testMethod void unitTestFive() {
        Id caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        Id caretakerId = [SELECT Id,ContactId FROM User WHERE ContactId=:caretakerContactId LIMIT 1].Id;
        Id studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        Id caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        
        
        Set<Id> allEC = new Set<Id>();
        List<Id> allECAId = new List<Id>();
        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ]; 
        
        
        
        
        List<Enrollment_Component__c> ECList = new List<Enrollment_Component__c>();
        for(Enrollment_Component__c EC :[Select Id,Assignment_Logic__c,RecordType.Name from Enrollment_Component__c Limit 100] ){
            allEC.add(EC.Id);
            Enrollment_Component__c enrolComponent =  new Enrollment_Component__c();
            enrolComponent.Assignment_Logic__c = null;
            enrolComponent.Id = EC.Id;
            ECList.add(enrolComponent);
            
        }
        update ECList;
        
        
        
        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c,Parent_Enrollment_Component__r.Assignment_Logic__c,Child_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            
            allECAId.add(relationship.Id); 
        }
        
        List<Enrollment_Component__c> processComponent = [select id,RecordType.Name from Enrollment_Component__c where RecordType.Name = 'Process'];        
        Test.startTest();           
           NES_ECAEvaluation.createRemainingAffiliations(accountId,studentId,caretakerId,studentEnrollmentId,caretakerEnrollmentId,allECAId,processComponent[1].Id);
            
        Test.stopTest();
    } 
    static testMethod void unitTestSix() { 
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();

        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];

        account acctToUpdate = new account (id = studentEnrollment.hed__Contact__r.AccountId, Confirmation_Start_Date__c = System.today() - 5);
        update acctToUpdate;

        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);

        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }
        
        //Go get all the EC data for this process id.
        Enrollment_Component__c processComponent = [select id from Enrollment_Component__c where RecordType.Name = 'Process' limit 1 ];

        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processComponent.id);
         //added
         List<Enrollment_Component_Affiliation__c> progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();
  
         for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Program_Enrollment__c = :studentEnrollmentId]) {
                if(affiliation.Enrollment_Component__r.RecordType.Name == 'Stage')
                    progEnrollECAListMap.add(affiliation);
            }  
        //delete progEnrollECAListMap;
        progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();
        list<id> impactedcomponents = new list<id>();
          Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Form' limit 1];  
          system.debug('qComponent'+qComponent);
        impactedcomponents.add(qComponent.id);
        impactedcomponents.addAll(allECData.enrollmentComponentMap.keySet());
        
        Id studentEnrolId = Id.valueOf(studentEnrollmentId);
        Id caretakerEnrolId = Id.valueOf(caretakerEnrollmentId);
        Id stId = Id.valueOf(studentId);
        Id crId =Id.valueOf(caretakerContactId);
        Id acId =Id.valueOf(accountId);
        
        //added 
        Test.startTest();
        
        List<Id> ECIds =  NES_ECAEvaluation.getMoreComponents(studentEnrollmentId,caretakerEnrollmentId,studentId,caretakerContactId,accountId,'Assignment',allECData.enrollmentComponentMap,true,impactedcomponents,progEnrollECAListMap); 
        //system.assertEquals(true, ECIds.size()>0);
            NES_ECAEvaluation.evalAssignment(studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId,
            thisProcessData.stageRelationships, thisProcessData.formRelationships, thisProcessData.sectionRelationships, thisProcessData.questionGroupRelationships, thisProcessData.questionRelationships, thisProcessData,impactedcomponents,progEnrollECAListMap);//added
         
        Test.stopTest();
    }
    static testMethod void unitTestSeven() { 
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Criteria_Group__c>  LstCriteria= [SELECT Enrollment_Component__r.RecordType.Name,Group_Logic__c,Group_Number__c FROM Criteria_Group__c];
        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];

        account acctToUpdate = new account (id = studentEnrollment.hed__Contact__r.AccountId, Confirmation_Start_Date__c = System.today() - 5);
        update acctToUpdate;

        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);

        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }
        
        //Go get all the EC data for this process id.
        Enrollment_Component__c processComponent = [select id from Enrollment_Component__c where RecordType.Name = 'Process' limit 1 ];

        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processComponent.id);
         //added
         List<Enrollment_Component_Affiliation__c> progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();
  
         for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Program_Enrollment__c = :studentEnrollmentId]) {
                if(affiliation.Enrollment_Component__r.RecordType.Name != 'Section')
                    progEnrollECAListMap.add(affiliation);
            }  
        //delete progEnrollECAListMap;
        progEnrollECAListMap = new List<Enrollment_Component_Affiliation__c> ();

        list<id> impactedcomponents = new list<id>();
          Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' limit 1];  
          system.debug('qComponent'+qComponent);
        impactedcomponents.add(qComponent.id);
        impactedcomponents.addAll(allECData.enrollmentComponentMap.keySet());
        
        Id studentEnrolId = Id.valueOf(studentEnrollmentId);
        Id caretakerEnrolId = Id.valueOf(caretakerEnrollmentId);
        Id stId = Id.valueOf(studentId);
        Id crId =Id.valueOf(caretakerContactId);
        Id acId =Id.valueOf(accountId);
        
        //added 
        Test.startTest();
        
        List<Id> ECIds = NES_ECAEvaluation.getMoreComponents(studentEnrollmentId,caretakerEnrollmentId,studentId,caretakerContactId,accountId,'Assignment',allECData.enrollmentComponentMap,true,impactedcomponents,progEnrollECAListMap); 
            //system.assertEquals(true, ECIds.size()>0);
            NES_ECAEvaluation.evalAssignment(studentId, caretakerContactId, accountId, studentEnrollmentId, caretakerEnrollmentId,
            thisProcessData.stageRelationships, thisProcessData.formRelationships, thisProcessData.sectionRelationships, thisProcessData.questionGroupRelationships, thisProcessData.questionRelationships, thisProcessData,impactedcomponents,progEnrollECAListMap);//added
        Test.stopTest();
    }
    
    //Added as part of BUG217916 to cover runAssignment method (Jagadish Babu)
    static testMethod void runAssignmentTest(){
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Criteria_Group__c>  LstCriteria= [SELECT Enrollment_Component__r.RecordType.Name,Group_Logic__c,Group_Number__c FROM Criteria_Group__c];
        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }
        
        List<hed__Program_Enrollment__c> studentEnrollment = [
                SELECT Id, hed__Account__c,v2_External_Id__c,Enrollment_Type__c, hed__Contact__c,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId,(Select Id,Enrollment_Component__c,Program_Enrollment__c,Status__c from Enrollment_Component_Affiliation__r)
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(studentEnrollment[0].hed__Account__c, 'Stage', false);
        stageComponent.Completion_Logic__c = 'test Stage';
        insert stageComponent;
        
        List<Enrollment_Component__c> processECRec = [Select Id,
                                                                 RecordType.Name,
                                                                 Process_Academic_Program__c
                                                                 from Enrollment_Component__c where Process_Academic_Program__c=:studentEnrollment[0].hed__Account__c and RecordType.Name =: NES_DashboardUtilities.PROCESS_RT];
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processECRec[0].Id);                                                               
        system.assertEquals(studentEnrollment.size()>0, true);         
        test.startTest();
        NES_ECAEvaluation.runAssignment(studentEnrollmentId,null,studentEnrollment[0],null,processECRec[0].Id);
        test.stopTest();
        system.assertEquals(true, [select id,Program_Enrollment__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c=:studentEnrollment[0].Id].size()>0);
    }
    //End of BUG217916
    //Added as part of BUG217916 to cover runAssignment method (Jagadish Babu)
    static testMethod void runAssignmentReEnrollTest(){
        String caretakerContactId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Caretaker' LIMIT 1].Id;
        String studentId = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Students' LIMIT 1].Id;
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        String studentEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: studentId LIMIT 1].Id;
        String caretakerEnrollmentId = [SELECT Id FROM hed__Program_Enrollment__c WHERE hed__Contact__c =: caretakerContactId LIMIT 1].Id;
        List<Enrollment_Component_Relationship__c> stageRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> formFlagRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> sectionDocRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Enrollment_Component_Relationship__c> questionRelationships = new List<Enrollment_Component_Relationship__c>();
        List<Criteria_Group__c>  LstCriteria= [SELECT Enrollment_Component__r.RecordType.Name,Group_Logic__c,Group_Number__c FROM Criteria_Group__c];
        for(Enrollment_Component_Relationship__c relationShip : [SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.DeveloperName FROM Enrollment_Component_Relationship__c LIMIT 100]) {
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Stage') {
                stageRelationships.add(relationShip);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Form') {
                formFlagRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Section') {
                sectionDocRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question_Group') {
                questionGroupRelationships.add(relationship);
            }
            if(relationShip.Child_Enrollment_Component__r.RecordType.DeveloperName == 'Question') {
                questionRelationships.add(relationship);
            }
        }
        
        List<hed__Program_Enrollment__c> studentEnrollment = [
                SELECT Id, hed__Account__c,v2_External_Id__c,Enrollment_Type__c, hed__Contact__c,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId,(Select Id,Enrollment_Component__c,Program_Enrollment__c,Status__c from Enrollment_Component_Affiliation__r)
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(studentEnrollment[0].hed__Account__c, 'Stage', false);
        stageComponent.Completion_Logic__c = 'test Stage';
        insert stageComponent;
        
        List<Enrollment_Component__c> processECRec = [Select Id,
                                                                 RecordType.Name,
                                                                 Process_Academic_Program__c
                                                                 from Enrollment_Component__c where Process_Academic_Program__c=:studentEnrollment[0].hed__Account__c and RecordType.Name =: NES_DashboardUtilities.PROCESS_RT];
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processECRec[0].Id);                                                               
        system.assertEquals(studentEnrollment.size()>0, true);         
        studentEnrollment[0].Enrollment_Type__c = 'Re-enrolling Student';
        update studentEnrollment[0];
        test.startTest();
        NES_ECAEvaluation.runAssignment(studentEnrollmentId,null,studentEnrollment[0],null,processECRec[0].Id);
        test.stopTest();
        system.assertEquals(true, [select id,Program_Enrollment__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c=:studentEnrollment[0].Id].size()>0);
    }
    //End of BUG217916
}