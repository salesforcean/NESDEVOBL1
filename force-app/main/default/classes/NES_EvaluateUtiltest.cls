@isTest
public with sharing class NES_EvaluateUtiltest{
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

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        //Commenting the insertion of the Relationship and PE record since they would be inserted from the AddStudentHelper Code
        //Create a relationship between the User Contact and Student Contact
       // hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);

        //Create a student enrollment for the CareTaker Contact
       // hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, true);
       
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);

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
        questionGroupComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;
        
        Enrollment_Component__c questionComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponentNew.Question_Type__c = 'Checkbox Group';
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = null;
        //insert questionComponentNew;
        
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
        componentList.add(questionComponentNew);
        insert componentList;
        
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(String.valueOf(questionComponentNew.Id), true);
        
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

        Enrollment_Component_Relationship__c section_questionGroup_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_ECR.Order__c = 3;
        update section_questionGroup_ECR;
        Enrollment_Component_Relationship__c section_questionGroup_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent_With_No_Logic.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_with_no_logic_ECR.Order__c = 4;
        update section_questionGroup_with_no_logic_ECR;
        
        List<Criteria__c> CriteriaList = new List<Criteria__c>();
        
        Criteria__c finalConformationCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c', '<=', false);
        finalConformationCriteria.Comparison_Data_Type__c = 'Datetime';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        finalConformationCriteria.Comparison_Field__c = 'hed__Program_Enrollment__c.Document_Extension_Date__c';
        //criteria2.Comparison_Data_Type__c = 'Date';
         insert finalConformationCriteria;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;

        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        houseHoldEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        houseHoldEnrollmentComponentCriteria.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria;

        Criteria__c cr2 = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c', '<=', false);
        cr2.Comparison_Data_Type__c = 'Datetime';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        cr2.Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c';
        insert cr2;

        Criteria__c criteria3 = Peak_TestUtils.createCriteriaRecord(null, 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', false);
        criteria3.Comparison_Data_Type__c = 'Text';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        criteria3.Comparison_Field__c = 'Annual_Student_Information__c.Grade_Level_Completed__c';
        insert criteria3;
        
        Criteria__c criteria4 = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.Eligibility_Future_Contact_Date__c', '=', false);
        criteria4.Comparison_Data_Type__c = 'Date';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        criteria4.Comparison_Field__c = 'hed__Program_Enrollment__c.Eligibility_Contact_Date__c';
         insert criteria4;
        
        Criteria__c criteria5 = Peak_TestUtils.createCriteriaRecord(null, 'Account.MaxBirthdate__c', '=', false);
        criteria5.Comparison_Data_Type__c = 'Date';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        criteria5.Comparison_Field__c = 'Account.Document_Extension_Date__c';
         insert criteria5;
        
        Criteria__c criteria6 = Peak_TestUtils.createCriteriaRecord(null, 'Contact.Document_Extension_Date__c', '=', false);
        criteria6.Comparison_Data_Type__c = 'Date';
        //finalConformationCriteria.Comparison_Value__c = 'today()';
        criteria6.Comparison_Field__c = 'Contact.US_Entry_Date__c';
        insert criteria6;
        // Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
        Criteria__c criteria7 = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.AutomatedPlacementMaxCutoff__c', '=', false);
        criteria7.Comparison_Data_Type__c = 'Number';
        criteria7.Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Account__r.AutomatedPlacementMaxCutoff__c';
        insert criteria7;
        // End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
        Enrollment_Component_Criteria__c ecc2 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc2.Criteria__c = cr2.Id;
        ecc2.Student_or_Household__c = 'Student';
        ecc2.Criteria_Number__c = 1;
        insert ecc2;

        Enrollment_Component_Criteria__c ecc3 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc3.Criteria__c = cr2.Id;
        ecc3.Student_or_Household__c = 'Household';
        ecc3.Criteria_Number__c = 2;
        insert ecc3;
        
        Enrollment_Component_Criteria__c ecc4 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc4.Criteria__c = criteria4.Id;
        ecc4.Student_or_Household__c = 'Student';
        ecc4.Criteria_Number__c = 2;
        insert ecc4;
        
        Enrollment_Component_Criteria__c ecc5 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc5.Criteria__c = criteria3.Id;
        ecc5.Student_or_Household__c = 'Student';
        ecc5.Criteria_Number__c = 2;
        insert ecc5;
        
        Enrollment_Component_Criteria__c ecc6 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc6.Criteria__c = criteria5.Id;
        ecc6.Student_or_Household__c = 'Student';
        ecc6.Criteria_Number__c = 2;
        insert ecc6;
        
        Enrollment_Component_Criteria__c ecc7 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        ecc7.Criteria__c = criteria6.Id;
        ecc7.Student_or_Household__c = 'Student';
        ecc7.Criteria_Number__c = 2;
        insert ecc7;
        
        Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup(null, formComponent.Id, false);
        criteriaGroup.Group_Number__c = 1;
        criteriaGroup.Group_Logic__c = '2';
        insert criteriaGroup;

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

        Criteria_Refinement__c refinementThree = new Criteria_Refinement__c();
        refinementThree.Criteria__c = finalConformationCriteria.Id;
        refinementThree.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementThree.Refinement_Type__c = 'Left Side';
        refinementThree.Operator__c = '=';
        refinementThree.Refinement_Value__c = 'Pearson Pre';
        insert refinementThree;
        
        Criteria_Refinement__c refine4 = new Criteria_Refinement__c();
        refine4.Criteria__c = finalConformationCriteria.Id;
        refine4.Refinement_Field_Left__c = 'hed__account__r.Name';
        refine4.Refinement_Type__c = 'Left Side';
        refine4.Operator__c = '=';
        refine4.Refinement_Field_Right__c = 'hed__account__r.Name';
        insert refine4;
        
        Criteria_Refinement__c refine5 = new Criteria_Refinement__c();
        refine5.Criteria__c = finalConformationCriteria.Id;
        refine5.Refinement_Field_Left__c = 'Name';
        refine5.Refinement_Type__c = 'Left Side';
        refine5.Operator__c = '=';
        refine5.Refinement_Field_Right__c = 'hed__account__r.Name';
        //insert refine5;
        
        Criteria_Refinement__c cr1 = new Criteria_Refinement__c();
        cr1.Criteria__c = cr2.Id;
        cr1.Refinement_Field_Left__c = 'hed__account__r.Name';
        cr1.Refinement_Type__c = 'Right Side';
        cr1.Operator__c = '=';
        cr1.Refinement_Value__c = 'TNCA';
        insert cr1;

        Criteria_Refinement__c crr2 = new Criteria_Refinement__c();
        crr2.Criteria__c = cr2.Id;
        crr2.Refinement_Field_Left__c = 'Academic_Doc_Performance__c';
        crr2.Refinement_Type__c = 'Right Side';
        crr2.Operator__c = '=';
        //crr2.Refinement_Value__c = 'Yes';
        crr2.Refinement_Field_Right__c = 'Academic_Doc_Performance__c';
        insert crr2;
        

        Criteria_Refinement__c cr3 = new Criteria_Refinement__c();
        cr3.Criteria__c = cr2.Id;
        cr3.Refinement_Field_Left__c = 'hed__account__r.Name';
        cr3.Refinement_Type__c = 'Left Side';
        cr3.Operator__c = '=';
        cr3.Refinement_Value__c = 'Pearson Pre';
        //cr3.Refinement_Field_Right__c = 'hed__account__r.Name';
        insert cr3;
        
        List<Enrollment_Component_Criteria__c> EnrollmentCompCriteriaList = new List<Enrollment_Component_Criteria__c>();

        Enrollment_Component_Criteria__c EnrollmentCompCriteria1= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria1', String.valueOf(processComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria2= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria2', String.valueOf(stageComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria3= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria3', String.valueOf(formComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria4= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria4', String.valueOf(sectionComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria5= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria5', String.valueOf(processComponent.Id),false);
        EnrollmentCompCriteria1.Criteria__c = finalConformationCriteria.id;
        EnrollmentCompCriteria2.Criteria__c = finalConformationCriteria.id;
        EnrollmentCompCriteria3.Criteria__c = finalConformationCriteria.id;
        EnrollmentCompCriteria4.Criteria__c = finalConformationCriteria.id;
        EnrollmentCompCriteria5.Criteria__c = finalConformationCriteria.id;
        EnrollmentCompCriteria1.Student_or_Household__c = 'Student';
        EnrollmentCompCriteria2.Student_or_Household__c = 'Household';
        EnrollmentCompCriteria3.Student_or_Household__c = 'Student';
        EnrollmentCompCriteria4.Student_or_Household__c = 'Household';
        EnrollmentCompCriteria5.Student_or_Household__c = 'Household';
        
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria1);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria2);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria3);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria4);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria5);
        
        insert EnrollmentCompCriteriaList;
        
        hed__program_enrollment__c program_enrollment_1 = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        //program_enrollment_1.Eligibility_Contact_Date__c = Date.Today();
        //program_enrollment_1.Eligibility_Contact_Date__c = Date.Today();
        insert program_enrollment_1;
        
        //Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup('testCriteriaGroup',componentList[0].Id,true);        
    }
    
    static testMethod void unitTest_getChildComponentIds(){
        Enrollment_Component__c parentEnrollmentComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        Test.startTest();
        NES_EvaluateUtil.getChildComponentIds(new Set<Id>{parentEnrollmentComponent.Id}, new Set<String>{'Process'}, new Set<String>{'Stage'});
        Test.stopTest();
    }
    static testMethod void unitTest_getCriteriaResultMap(){
        Enrollment_Component__c parentEnrollmentComponent = [SELECT Id,Assignment_Logic__c,(SELECT Id,Criteria_Number__c FROM Enrollment_Component_Criteria__r) FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        Contact student = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Students' LIMIT 1];
        User caretakerUser = [SELECT Id, ContactId FROM User LIMIT 1];
        hed__program_enrollment__c pgEnrollment1 = [SELECT Id FROM hed__program_enrollment__c LIMIT 1];
        Contact caretaker = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Test.startTest();
        //NES_EvaluateUtil.getQueryMap();
        Criteria_Group__c cg = [SELECT Id,Group_Number__c, Group_Logic__c FROM Criteria_Group__c LIMIT 1];
        Map<String, Boolean> componentCriteriaResultMap = new Map<String, Boolean>();
        componentCriteriaResultMap = NES_EvaluateUtil.getResultMap(parentEnrollmentComponent.Id, student, caretakerUser, pgEnrollment1.Id, caretaker.Id);
        Map<String, Boolean> criteriaResultMap = NES_ECAEvaluation.getBooleansByNumber(componentCriteriaResultMap, parentEnrollmentComponent.Enrollment_Component_Criteria__r);
        NES_EvaluateUtil.evaluateCriteriaGroups(new List<Criteria_Group__c>{cg}, criteriaResultMap,parentEnrollmentComponent.Assignment_Logic__c);
        Test.stopTest();
    }
    static testMethod void unitTest_getCriteriaResultMap2(){
        List<Enrollment_Component__c> parentEnrollmentComponent = [SELECT Id,Assignment_Logic__c,(SELECT Id,Criteria_Number__c FROM Enrollment_Component_Criteria__r) FROM Enrollment_Component__c WHERE RecordType.Name = 'Form' LIMIT 1];
        Contact student = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Students' LIMIT 1];
        User caretakerUser = [SELECT Id, ContactId FROM User LIMIT 1];
        hed__program_enrollment__c pgEnrollment1 = [SELECT Id FROM hed__program_enrollment__c LIMIT 1];
        Contact caretaker = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Test.startTest();
        //NES_EvaluateUtil.getQueryMap();
        Criteria_Group__c cg = [SELECT Id,Group_Number__c, Group_Logic__c FROM Criteria_Group__c LIMIT 1];
        Map<String, Boolean> componentCriteriaResultMap = new Map<String, Boolean>();
        for(Enrollment_Component__c ec:  parentEnrollmentComponent){
            componentCriteriaResultMap = NES_EvaluateUtil.getResultMap(ec.Id, student, caretakerUser, pgEnrollment1.Id, caretaker.Id);
            Map<String, Boolean> criteriaResultMap = NES_ECAEvaluation.getBooleansByNumber(componentCriteriaResultMap, ec.Enrollment_Component_Criteria__r);
            NES_EvaluateUtil.evaluateCriteriaGroups(new List<Criteria_Group__c>{cg}, criteriaResultMap,ec.Assignment_Logic__c);
        }
        Test.stopTest();
    }
    // Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
    static testMethod void testdirectEvaluate(){
        Criteria__c cr1 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c 
                                       WHERE Comparison_Data_Type__c = 'Date'
                           and Comparison_Field__c = 'hed__Program_Enrollment__c.Eligibility_Contact_Date__c' LIMIT 1 ];
      
        sObject s =[select Id,eligibility_contact_date__c from hed__Program_Enrollment__c limit 1];
        hed__Program_Enrollment__c a=(hed__Program_Enrollment__c)s;
        a.eligibility_contact_date__c = system.today();
    
           String answer = '09/26/2019';
           String compareValue = String.valueOf(Date.Today() + 1);
        
        Criteria__c cr2 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c 
                                         WHERE Comparison_Data_Type__c = 'Datetime'
                             and Comparison_Field__c='hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c' limit 1 ];
     
     
        SObject ss =[select Id,hed__Account__r.Confirmation_Start_Date__c from hed__Program_Enrollment__c limit 1];
         hed__Program_Enrollment__c aa=(hed__Program_Enrollment__c)ss;
         String answer1 = '09/26/2019';
       
       
       Criteria__c cr3 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c 
                                              WHERE Comparison_Data_Type__c = 'Number'
                           and Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Account__r.AutomatedPlacementMaxCutoff__c' ];
       
        sObject sss =[select Id,hed__Account__c,hed__Account__r.AutomatedPlacementMaxCutoff__c from hed__Program_Enrollment__c limit 1];
        hed__Program_Enrollment__c aaa=(hed__Program_Enrollment__c)sss;
        aaa.hed__Account__r.AutomatedPlacementMaxCutoff__c=100;
         String answer2 = '100';
        
        Test.startTest();
        NES_EvaluateUtil.directEvaluate(cr1,answer,a);
        NES_EvaluateUtil.directEvaluate(cr2,answer1,aa);
        cr2.Operator__c='=';
        update cr2;
        String  answer41 = '9/26/2019';
        NES_EvaluateUtil.directEvaluate(cr2,answer41,aaa);
        
        cr2.Operator__c='>';
        update cr2;
        answer41 = '01/26/2019';
        NES_EvaluateUtil.directEvaluate(cr2,answer41,aaa); 
        
        cr2.Operator__c='!=';
        update cr2;
        answer41 = '09/26/2019';
        NES_EvaluateUtil.directEvaluate(cr2,answer41,aaa);
        
        cr2.Operator__c='>=';
        update cr2;
        NES_EvaluateUtil.directEvaluate(cr2,answer41,aaa);
        
        cr2.Operator__c='<=';
        update cr2;
        NES_EvaluateUtil.directEvaluate(cr2,answer41,aaa);
       
        NES_EvaluateUtil.directEvaluate(cr3,answer2,aaa);
       
        cr3.Operator__c='>';
        update cr3;
        String answer3 = '104';
        NES_EvaluateUtil.directEvaluate(cr3,answer3,aaa);
        
        cr3.Operator__c='<';
        update cr3;
        answer3 = '10';
        NES_EvaluateUtil.directEvaluate(cr3,answer3,aaa);
        
        cr3.Operator__c='<=';
        update cr3;
         answer3 = '10';
        NES_EvaluateUtil.directEvaluate(cr3,answer3,aaa);
       
        cr3.Operator__c='>=';
        update cr3;
        answer3 = '104';
        NES_EvaluateUtil.directEvaluate(cr3,answer3,aaa);
        
        cr3.Operator__c='!=';
        update cr3;
        answer3 = '109';
        NES_EvaluateUtil.directEvaluate(cr3,answer3,aaa);
        
        Test.stopTest();
    }
    // End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
    // Created methods testdirectEvaluate2 and testdirectEvaluate3 by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
    static testMethod void testdirectEvaluate2(){
        Criteria__c cr1 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c 
                           WHERE Comparison_Data_Type__c = 'Date'
                           and Comparison_Field__c = 'hed__Program_Enrollment__c.Eligibility_Contact_Date__c' LIMIT 1 ];
        cr1.Operator__c = '<';
        update cr1;
        sObject s =[select Id,eligibility_contact_date__c from hed__Program_Enrollment__c limit 1];
        hed__Program_Enrollment__c a=(hed__Program_Enrollment__c)s;
        a.eligibility_contact_date__c = system.today();
        String answer = '09/24/2019';
        String compareValue = String.valueOf(Date.Today() + 1);

        Test.startTest();
         NES_EvaluateUtil.directEvaluate(cr1,answer,a);   
         cr1.Operator__c = '<=';
         update cr1;
         NES_EvaluateUtil.directEvaluate(cr1,answer,a);
        
         cr1.Operator__c ='!=';
         update cr1;
         NES_EvaluateUtil.directEvaluate(cr1,answer,a);
        
         cr1.Operator__c ='<';
         update cr1;
         NES_EvaluateUtil.directEvaluate(cr1,answer,a);
        
         cr1.Operator__c ='>';
         update cr1;
         String answer1 = '09/24/2019';
         NES_EvaluateUtil.directEvaluate(cr1,answer1,a);  
         Test.stopTest();
    }
    
     static testMethod void testdirectEvaluate3(){
                       Criteria__c cr1 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c 
                                                                    WHERE Comparison_Data_Type__c = 'Date'
                                                   and Comparison_Field__c = 'hed__Program_Enrollment__c.Eligibility_Contact_Date__c' LIMIT 1 ];
        
        cr1.Operator__c = '>';
        update cr1;
        sObject s =[select Id,eligibility_contact_date__c from hed__Program_Enrollment__c limit 1];
        hed__Program_Enrollment__c a=(hed__Program_Enrollment__c)s;
        a.eligibility_contact_date__c = system.today();
        String answer = '09/29/2019';
        String compareValue = String.valueOf(Date.Today() + 1);

        Test.startTest();
        NES_EvaluateUtil.directEvaluate(cr1,answer,a);   
         cr1.Operator__c = '>=';
         update cr1;
         NES_EvaluateUtil.directEvaluate(cr1,answer,a);  
        Test.stopTest();
    } 
    //End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
    static testMethod void testupdateDataVoidBoolean(){
        String dataType = 'Boolean';
        String fieldData = 'true';
        String fieldName = 'DoNotCall';
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Schema.SObjectType sobjectType = conId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject sObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :conId');
        Test.startTest();
        NES_EvaluateUtil.updateDataVoid(dataType, fieldData, fieldName, sObj);
        Test.stopTest();
    }
    
    static testMethod void testupdateDataVoidDate(){
        String dataType = 'Date';
        Date fieldData = Date.Today();
        String fieldName = 'Birthdate';
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Schema.SObjectType sobjectType = conId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject sObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :conId');
        Test.startTest();
        NES_EvaluateUtil.updateDataVoid(dataType, String.valueOf(fieldData), fieldName, sObj);
        Test.stopTest();
    }
    static testMethod void testupdateDataVoidNumber(){
        String dataType = 'Number';
        String fieldData = '12';
        String fieldName = 'Form_Sequence__c';
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Schema.SObjectType sobjectType = conId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject sObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :conId');
        Test.startTest();
        NES_EvaluateUtil.updateDataVoid(dataType, fieldData, fieldName, sObj);
        Test.stopTest();
    }
    static testMethod void testupdateDataVoidDatetime(){
        String dataType = 'Picklist';
        String fieldData = 'false';
        String fieldName = 'Enrolling_4_Students_Flag__c';
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Schema.SObjectType sobjectType = conId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject sObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :conId');
        Test.startTest();
        NES_EvaluateUtil.updateDataVoid(dataType, fieldData, fieldName, sObj);
        Test.stopTest();
    }   

    static testMethod void testupdateDataVoidBlank(){
        String dataType = 'Boolean';
        String fieldData = '';
        String fieldName = 'DoNotCall';
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Schema.SObjectType sobjectType = conId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject sObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :conId');
        Test.startTest();
        NES_EvaluateUtil.updateDataVoid(dataType, fieldData, fieldName, sObj);
        Test.stopTest();
    }   
}