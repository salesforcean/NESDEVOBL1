/**
 * Created by ajith on 04/04/19.
 */

@istest
public class NES_QuestionsControllerTest {
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
        // Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
        academicProgram.Document_Start_Date__c=System.today().addDays(10);
        update academicProgram;
           System.debug('the values are academicProgram 55::'+academicProgram);
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
          System.debug('the values are careTakerContact 55::'+careTakerContact);
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
         //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;

        //End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
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
        /*
        Enrollment_Component__c formComponent_With_No_Logicxxxx = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        formComponent_With_No_Logicxxxx.Assignment_Logic__c = null;
        componentList.add(formComponent_With_No_Logicxxxx);
        */
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        processComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        processComponent.Completion_Logic__c = 'test';

        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = '1';
       

        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
       

        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = null;
      

        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Assignment_Logic__c = '1';

        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Student';
        questionComponent.Question_School_Year__c = schoolYear.Id;
        questionComponent.Assignment_Logic__c = null;
        questionComponent.Question_Type__c = 'Picklist';//added logic for 113424 bug
        questionComponent.Answer_Target__c = 'Prior_School__c.SchoolType__c';//added logic for 113424 bug
        questionComponent.Assignment_Logic__c = null;//added

        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Student';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;
        questionComponent_With_No_Logic.Question_School_Year__c = schoolYear.Id;
       
       // questionComponent_With_No_Logic.Question_Type__c='School Search';
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);


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

        Enrollment_Component__c secComplete = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        componentList.add(secComplete);

        insert componentList;
        // Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
         Map<Id, Enrollment_Component__c> enrollmentComponentMap=new  Map<Id, Enrollment_Component__c>();
        List<Enrollment_Component__c> componets=[select id from Enrollment_Component__c where id in :componentList];
        for(Enrollment_Component__c myData:componets){
            enrollmentComponentMap.put(myData.id,myData);
        } 
        // End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
         Criteria__c abcd=new Criteria__c();
         abcd.Comparison_Field__c= 'prior_school__c.SchoolType__c';//'Annual_Student_Information__c.Grade_Level_Completed__c'; //added logic for 113424 bug
        insert abcd;
         Enrollment_Component_Criteria__c ecacriteria=Peak_TestUtils.createEnrollCompCriteria('madhu',questionGroupComponent.Id,false);
          ecacriteria.Student_or_Household__c='Student';
          ecacriteria.Criteria__c=abcd.id;
          //ecacriteria.Criteria__r.Comparison_Field__c='Annual_Student_Information__c.Grade_Level_Completed__c';
         insert ecacriteria; 
        
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
        Enrollment_Component_Relationship__c section_questionGroup_ECRs = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id,questionGroupComponent.Id);
         section_questionGroup_ECRs.Order__c = 3;
        update section_questionGroup_ECRs;

        Enrollment_Component_Relationship__c section_questionGroup_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent_With_No_Logic.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_with_no_logic_ECR.Order__c = 4;
        update section_questionGroup_with_no_logic_ECR;
         
        Enrollment_Component_Relationship__c messageRelationShip = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,messageComponent.Id);

        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c sectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, sectionComponent.Id, false);
        sectionAffiliation.Status__c = 'In Progress';
        sectionAffiliation.Order__c = 1; //US#117040 Added order field assignment. (Krishna Peddanagammol)
        enrollmentComponentAffiliations.add(sectionAffiliation);

    
        Enrollment_Component_Affiliation__c questionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionComponent.Id, false);
        questionAffiliation.Status__c = 'In Progress';
        sectionAffiliation.Order__c = 1; //US#117040 Added order field assignment. (Krishna Peddanagammol)
        enrollmentComponentAffiliations.add(questionAffiliation);

        Enrollment_Component_Affiliation__c questionGrpAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionGroupComponent_With_No_Logic.Id, false);
        questionGrpAffiliation.Status__c = 'In Progress';
        sectionAffiliation.Order__c = 1; //US#117040 Added order field assignment. (Krishna Peddanagammol)
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
        //  Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09

        list <id> listids = NES_ECAEvaluation.getMoreComponents(studentEnrollment.Id, careTakerEnrollment.Id,
                            student.Id, caretaker.ContactId,institutionAccount.Id , 'Assignment', enrollmentComponentMap, false, null, null); 
     
       //  End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09 
        insert enrollmentComponentAffiliations;

        List<Enrollment_Component_Picklist_Option__c> picklistOptionList = new List<Enrollment_Component_Picklist_Option__c>();
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        insert picklistOptionList;

        List<Option_Exclusion__c> optionExclusionList = new List<Option_Exclusion__c>();
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        insert optionExclusionList;
    }

    static testMethod void unitTestOne() {

        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                          WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        Enrollment_Component__c sectionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        
        System.runAs(careTaker) {
            Test.startTest();
            List<NES_EvaluateUtil.Question> response = NES_QuestionsController.getRelatedQuestions(sectionComponent.Id, enrollment.Id);
            Test.stopTest();
        }
    }

    static testMethod void unitTestTwo() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        Enrollment_Component_Affiliation__c ecaCompleted = [SELECT Id, Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Complete' AND Enrollment_Component__r.RecordType.Name = 'Section' LIMIT 1];


        System.runAs(careTaker) {
            Test.startTest();
            List<NES_EvaluateUtil.Question> response = NES_QuestionsController.getRelatedQuestions(ecaCompleted.Enrollment_Component__c, enrollment.Id);
            List<NES_EvaluateUtil.Question> response2 = NES_QuestionsController.getRelatedQuestions2(ecaCompleted.Enrollment_Component__c, enrollment.Id);
            Test.stopTest();
        }
    }

    static testMethod void unitTestThree() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        Enrollment_Component__c questionGroupComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c question = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        Enrollment_Component_Affiliation__c ecaCompleted = [SELECT Id, Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Complete' AND Enrollment_Component__r.RecordType.Name = 'Section' LIMIT 1];

        System.runAs(careTaker) {
            Test.startTest();
            List<NES_EvaluateUtil.Question> questions = NES_ExperianIntegration.getQuestions(questionGroupComponent.Id, enrollment.Id);
            List<NES_EvaluateUtil.Question> response3 = NES_QuestionsController.evaluateQuestion(enrollment.id,JSON.serialize(questions),ecaCompleted.Enrollment_Component__c,process.Id);
            Test.stopTest();
        }
    }
    static testMethod void unitTestFour() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        Enrollment_Component__c questionGroupComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c question = [SELECT Id,Question_Type__c FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];
        // Start add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
        System.debug('The values are types::'+question.Question_Type__c);
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        Enrollment_Component_Affiliation__c affiliation = [SELECT Id,Status__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__c =: section.Id];
        affiliation.Status__c = 'In Progress';
        update affiliation;
        // End add by Maddileti for User Story #101934(#109433 Bug) (Maddileti Boya) on 2019-09-09
        System.runAs(careTaker) {
            Test.startTest();
            List<NES_EvaluateUtil.Question> questions = NES_ExperianIntegration.getQuestions(questionGroupComponent.Id, enrollment.Id);
                NES_EvaluateUtil.Question newQuestion = new NES_EvaluateUtil.Question();
                newQuestion.questionId = question.Id;
                questions.add(newQuestion);
            List<NES_EvaluateUtil.Question> response2 = NES_QuestionsHelper.getRelatedQuestions2(enrollment.Id, JSON.serialize(questions),section.Id,false);
            Test.stopTest();
        }
    }
    static testMethod void testsubmitQuestions() { 

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c questionGroupComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c question = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];


        System.runAs(careTaker) {
            Test.startTest();
                List<NES_EvaluateUtil.Question> questions = NES_ExperianIntegration.getQuestions(questionGroupComponent.Id, enrollment.Id);
                NES_EvaluateUtil.Question newQuestion = new NES_EvaluateUtil.Question();
                newQuestion.questionId = question.Id;
                questions.add(newQuestion);
                NES_QuestionsController.submitQuestions(enrollment.Id,JSON.serialize(questions),process.Id,section.Id);
            Test.stopTest();
        }
    }

    static testMethod void testControllerGrabNextURL() { 

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c questionGroupComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c question = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];


        System.runAs(careTaker) {
            Test.startTest();
                NES_QuestionsController.grabNextURL(enrollment.Id,process.Id,section.Id);
            Test.stopTest();
        }
    }

    static testMethod void testsubmitQuestions2() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id,hed__Contact__c,Final_Grade_Level__c,hed__Contact__r.Name FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        
        Enrollment_Component__c stage = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Form' LIMIT 1];
        Enrollment_Component_Affiliation__c affiliation = [SELECT Id,Status__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__c =: stage.Id];
        affiliation.Status__c = 'In Progress';
        update affiliation;


        System.runAs(careTaker) { 
            Test.startTest();
                NES_QuestionsHelper.grabNextURL(enrollment.Id,section.Id,enrollment.hed__Contact__r.Name,process.Id,enrollment.Final_Grade_Level__c, enrollment.hed__Contact__c, true);
            Test.stopTest();
        }
    }
    //US#117040 Test for Last Section Submitted in a form (Krishna Peddanagammol)
    static testMethod void testSubmitLastQuestion() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id,hed__Contact__c,Final_Grade_Level__c,hed__Contact__r.Name FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];    
        Enrollment_Component__c stage = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Form' LIMIT 1];
        Enrollment_Component_Relationship__c sectionParentRelationship = [
                SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                FROM Enrollment_Component_Relationship__c
                WHERE Child_Enrollment_Component__c = :section.Id
                AND Parent_Enrollment_Component__c = :stage.Id
                ORDER BY Order__c DESC LIMIT 1
        ];
        Enrollment_Component_Affiliation__c affiliation = [SELECT Id,Status__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__c =: sectionParentRelationship.Child_Enrollment_Component__c];
        affiliation.Status__c = 'Complete';
        update affiliation;

        System.runAs(careTaker) { 
            Test.startTest();
                NES_QuestionsHelper.grabNextURL(enrollment.Id,section.Id,enrollment.hed__Contact__r.Name,process.Id,enrollment.Final_Grade_Level__c, enrollment.hed__Contact__c, true);
            Test.stopTest();
        }
    }
    static testMethod void grabNextURL() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id,hed__Contact__c,Final_Grade_Level__c,hed__Contact__r.Name FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c process = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Process' LIMIT 1];
        Enrollment_Component__c formComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Form' LIMIT 1];
        
        Enrollment_Component__c stage = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'stage' LIMIT 1];
        Enrollment_Component_Affiliation__c affiliation = [SELECT Id,Status__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__c =: stage.Id];
        affiliation.Status__c = 'In Progress';
        update affiliation;

        System.runAs(careTaker) {
            Test.startTest();
                NES_QuestionsHelper.grabNextURL(enrollment.Id,section.Id,enrollment.hed__Contact__r.Name,process.Id,enrollment.Final_Grade_Level__c, enrollment.hed__Contact__c, true);
               
                List<Enrollment_Component_Affiliation__c> affiliationsNow = [SELECT Id, Status__c, Date_Completed__c, Deferral_Date__c, Program_Enrollment__c, Enrollment_Component__c FROM Enrollment_Component_Affiliation__c LIMIT 100];
                Map<Id,Enrollment_Component_Affiliation__c> affiliationMap = new Map<Id,Enrollment_Component_Affiliation__c>();
                for (Enrollment_Component_Affiliation__c affiliationRec : affiliationsNow) {
                    affiliationRec.Status__c = 'Complete';
                    affiliationMap.put(affiliationRec.Enrollment_Component__c, affiliationRec);
                }
                List<Enrollment_Component_Relationship__c> relationships = [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c FROM Enrollment_Component_Relationship__c WHERE Child_Enrollment_Component__c IN: affiliationMap.keySet() ];

                NES_QuestionsHelper.grabNext(relationships,affiliationMap, stage.Id, 'Stage');
                NES_QuestionsHelper.grabNext(relationships,affiliationMap, null, 'Stage');
                NES_QuestionsHelper.grabNext(relationships,affiliationMap, formComponent.Id, 'Form');
                NES_QuestionsHelper.grabNext(relationships,affiliationMap, null, 'Form');
            Test.stopTest();
        }
    }

    static testMethod void testgetRelatedPicklistOptions() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        Enrollment_Component__c question = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];

        System.runAs(careTaker) {
            Test.startTest();
                NES_QuestionsController.getRelatedPicklistOptions(question.Id);
            Test.stopTest();
        }
    } 
    static testMethod void testCase3() {

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        Enrollment_Component__c section = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        Enrollment_Component__c question = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' AND Assignment_Logic__c = null LIMIT 1];
        Enrollment_Component__c message = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Message' LIMIT 1];
        System.runAs(careTaker) {
            Test.startTest();
                NES_QuestionsController.getSchoolId(enrollment.Id);
                NES_QuestionsController.getSectionName(section.Id);
                NES_QuestionsController.grabNameOfStudent(careTaker.ContactId,enrollment.Id);
                NES_QuestionsController.getRelatedMessages(message.Id,enrollment.id);
            Test.stopTest();
        }
    }

  
    static testMethod void unitNewECAProcess() {

        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                          WHERE RecordType.Name = 'Academic Program' LIMIT 1];

        academicProgram.Use_Updated_ECA_Process__c = true;
        update academicProgram;

        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

        
        //Create a student enrollment for the CareTaker Contact
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYears[0].Id, true);

        System.runAs(careTaker) {
            Test.startTest();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Peak_Response response = NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
            List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYears[0].Id);

            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle', 'MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null); //added for US116612 
            newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
            String studentJSON = JSON.serialize(newStudentData);
            System.debug('studentJSON++'+studentJSON);

            Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Question' LIMIT 1];
            List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
            NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
            q1.order = 1;
            q1.componentType = 'Student';
            q1.questionGroup = false;
            q1.questionPrompt = 'What grade is the student going into?';
            q1.questionTarget = 'hed__Program_Enrollment__c.Final_Grade_Level__c';
            q1.questionType = 'Picklist';
            q1.required = true;
            q1.schoolYear = schoolYears[0].Id;
            q1.targetField = 'K';
            q1.componentType = 'false';
            q1.questionId = qComponent.Id;
            questionDataList.add(q1);
            String questionJSON = JSON.serialize(questionDataList);

            Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
            Test.stopTest();
        }


        hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' and Final_Grade_Level__c = 'K' LIMIT 1];
        Enrollment_Component__c sectionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
        
        System.runAs(careTaker) {
            //Test.startTest();
            List<NES_EvaluateUtil.Question> response = NES_QuestionsController.getRelatedQuestions(sectionComponent.Id, enrollment.Id);
            //Test.stopTest();
        }
    }

    /**
     * @author: Mark Membrino
     * @date: 10/13/2020
     * @usecase:
     *          Adding new test scenario to support the new ECA Model. 
     *          When NES_QuestionsHelper.grabNext() is called on 'Living Accommodation' Section, 
     *          the very next ordered section (Migratory Information) has status ='Not Applicable', 
     *          grabNext() should skip the 'Not Applicable' section and return the next 'Not Started' 
     *          section, in this case 'Household Description'.
     */
    static testMethod void grabNextPositive() 
    {
        // * Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();

        // * Create School Year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears(ECA_EvaluationTestData.SCHOOL_YEAR, System.today());

        // * Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.Use_Updated_ECA_Process__c = true; // this flag controls the triggering of new ECA Assignment / Completion code.
        update academicProgram;

        // * Fetch RecordTypes
        Map<String, Id> ecRecTypes = ECA_EvaluationTestData.getRecordTypeIdName('Enrollment_Component__c', new List<String>{'Process', 'Stage', 'Form', 'Section', 'Document'});

        // * Create ECs
        Enrollment_Component__c formBFI = ECA_EvaluationTestData.createBaseEC(false, 'Basic Family Information', academicProgram.Id, ecRecTypes.get('Form'));
        Enrollment_Component__c sectionCI = ECA_EvaluationTestData.createBaseEC(false, 'Contact Information', academicProgram.Id, ecRecTypes.get('Section'));
        Enrollment_Component__c sectionAI = ECA_EvaluationTestData.createBaseEC(false, 'Address Information', academicProgram.Id, ecRecTypes.get('Section'));
        Enrollment_Component__c sectionPoR = ECA_EvaluationTestData.createBaseEC(false, 'Proof of Residency', academicProgram.Id, ecRecTypes.get('Section'));
        Enrollment_Component__c sectionLA = ECA_EvaluationTestData.createBaseEC(false, 'Living Accommodation', academicProgram.Id, ecRecTypes.get('Section'));
        Enrollment_Component__c sectionMI = ECA_EvaluationTestData.createBaseEC(false, 'Migratory Information', academicProgram.Id, ecRecTypes.get('Section'));
        Enrollment_Component__c sectionHHD = ECA_EvaluationTestData.createBaseEC(false, 'HouseHold Description', academicProgram.Id, ecRecTypes.get('Section'));
        List<Enrollment_Component__c> ecs =  new List<Enrollment_Component__c> {formBFI, sectionCI, sectionAI, sectionPoR, sectionLA, sectionMI, sectionHHD};
        insert ecs;

        // * tie the ECs (by ECRs)
        Enrollment_Component_Relationship__c formBFIsectionCI = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionCI.Id, 1);
        Enrollment_Component_Relationship__c formBFIsectionAI = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionAI.Id, 2);
        Enrollment_Component_Relationship__c formBFIsectionPoR = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionPoR.Id, 3);
        Enrollment_Component_Relationship__c formBFIsectionLA = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionLA.Id, 3);
        Enrollment_Component_Relationship__c formBFIsectionMI = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionMI.Id, 5);
        Enrollment_Component_Relationship__c formBFIsectionHHD = ECA_EvaluationTestData.createECR(false, formBFI.Id, sectionHHD.Id, 6);
        List<Enrollment_Component_Relationship__c> ecrs = new List<Enrollment_Component_Relationship__c> {formBFIsectionCI, formBFIsectionAI, formBFIsectionPoR, formBFIsectionLA, formBFIsectionMI, formBFIsectionHHD};
        insert ecrs;

        // create PE
        // * Create a Contact with 'Students' record type  
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // * Create PE
        hed__program_enrollment__c studPE = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert studPE;

        // * create ECAs
        List<Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c>();
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionCI.Order__c, formBFIsectionCI.Parent_Enrollment_Component__c, ECA_EvaluationTestData.IN_PROGRESS_STATUS));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionCI.Order__c, formBFIsectionCI.Child_Enrollment_Component__c, ECA_EvaluationTestData.COMPLETE_STATUS));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionAI.Order__c, formBFIsectionAI.Child_Enrollment_Component__c, ECA_EvaluationTestData.COMPLETE_STATUS));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionPoR.Order__c, formBFIsectionPoR.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionLA.Order__c, formBFIsectionLA.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionMI.Order__c, formBFIsectionMI.Child_Enrollment_Component__c, 'Not Applicable'));
        ecas.add(ECA_EvaluationTestData.createECAs(studPE.Id, formBFIsectionHHD.Order__c, formBFIsectionHHD.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS));
        insert ecas;

        Map<Id, Enrollment_Component_Affiliation__c> ecToECAMap = new Map<Id, Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : ecas)
            ecToECAMap.put(eca.Enrollment_Component__c, eca);

        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];
        String sectionId = '';
        System.runAs(careTaker) {
            Test.startTest();
                sectionId = NES_QuestionsHelper.grabNext(ecrs, ecToECAMap, sectionLA.Id, 'Section');
            Test.stopTest();
        }
        
        System.assertEquals(sectionId, sectionHHD.Id); // grabNext should return the Household Description sectionId & not 'Migratiory Information' sectionId.
    }

    /*  static testMethod void testgetRecordString() {


    Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
    Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                        WHERE RecordType.Name = 'Academic Program' LIMIT 1];
    System.debug('academicProgram++'+academicProgram);
    List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];

    User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];

    hed__Program_Enrollment__c enrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
    Enrollment_Component__c sectionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.Name = 'Section' AND Assignment_Logic__c = '1' LIMIT 1];
    System.runAs(careTaker) {
        Test.startTest();
        List<NES_EvaluateUtil.Question> response = NES_QuestionsController.getRelatedQuestions(sectionComponent.Id, enrollment.Id);
        Test.stopTest();
    }
    }*/
    
}