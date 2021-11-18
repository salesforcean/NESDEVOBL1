/**
 * Created by triciaigoe on 12/27/18.
 */
@IsTest
public with sharing class NES_EnrollmentControllerTest {
 
    @TestSetup 
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));

        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, true);
		
		User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);

        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);

        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(sectionComponent);
        componentList.add(formComponent);
        componentList.add(messageComponent);
        componentList.add(documentComponent);
        insert componentList;

        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship3 = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship4 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship5 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);

        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
       
        Enrollment_Component_Affiliation__c  affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        affiliationSection.Status__c='In Progress';
        update affiliationSection;
        Enrollment_Component_Affiliation__c  affiliationSection2 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);

         Enrollment_Component_Affiliation__c affiliationDocument2 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);
 
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment.id);
        enrollmentDocument1.Enrollment_Component_Affiliation__c = affiliationSection.Id;
        update enrollmentDocument1;

        //

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('Test',true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test', academicProgram.Id, gradeLevel.Id,Datetime.now(), true);

        // Create a Standard User

        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser(contact.Id);
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, schlYear.Id, false);
        insert ProgramEnrollmentTest;

    }

    /**
   * Created by Anushka on 20/11/18.
   * Purpose : This method is a Test method for getRelatedFormContent method of NES_DashboardUtilities class.
*/
 static testMethod void testGetRelatedFormContent() {
  Enrollment_Component__c formComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Form' LIMIT 1];
  hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
     
  List<NES_DashboardUtilities.RelatedFormContent> relatedForm = NES_EnrollmentController.getRelatedFormContent(formComponent.Id, programEnrollment.Id);
  System.assertNotEquals(null,relatedForm );
  relatedForm = NES_EnrollmentController.getRelatedFormContent(null,null);
  System.assertEquals(null,relatedForm );

     update new Enrollment_Component__c(Id = formComponent.Id, Document_Submission_Start_Date__c = Date.today().addMonths(2));
     relatedForm = NES_EnrollmentController.getRelatedFormContent(formComponent.Id, null);
     System.assertNotEquals(null,relatedForm );
 }

    /**
      * Created by Anushka on 20/11/18.
      * Purpose : This method is a Test method for getRelatedStages method of NES_DashboardController class.
   */
    static testMethod void testGetRelatedStages() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,Status__c FROM hed__Program_Enrollment__c LIMIT 1];
        List<Enrollment_Component_Affiliation__c> affiliations  = NES_EnrollmentController.getRelatedStages(progEnrollment.Id);
        System.assertNotEquals(null,affiliations );
        affiliations = NES_EnrollmentController.getRelatedStages(null);
        System.assertEquals(null,affiliations );
        
    }

    /**
      * Created by Anushka on 20/11/18.
      * Purpose : This method is a Test method for getRelatedMessages method of NES_DashboardController class.
   */
    static testMethod void testGetRelatedMessages() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        Enrollment_Component__c stageComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Form' 
        LIMIT 1];
        List<Enrollment_Component__c> enrollmentComponents =  NES_EnrollmentController.getRelatedMessages(stageComponent.Id, progEnrollment.Id);
        System.assertNotEquals(null,enrollmentComponents );
        enrollmentComponents = NES_EnrollmentController.getRelatedMessages(null, progEnrollment.Id);
        System.assertEquals(0,enrollmentComponents.size() );
    }

    /**
      * Created by Anushka on 20/11/18.
      * Purpose : This method is a Test method for getProcessInformation method of NES_DashboardController class.
     **/
    static testMethod void testGetProcessInformation() {
        Enrollment_Component__c processComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Process' LIMIT 1];
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c FROM hed__Program_Enrollment__c LIMIT 1];

        NES_DashboardUtilities.Process process = NES_EnrollmentController.getProcessInformation(processComponent.Id, progEnrollment.Id);
        System.assertNotEquals(null,process );
        process = NES_EnrollmentController.getProcessInformation(null, progEnrollment.Id);
        System.assertEquals(null,process );
    }

    /**
      * Created by Anushka on 20/11/18 .
      * Purpose : This method is a Test method for getRelatedForms method of NES_DashboardController class.
     **/
    static testMethod void testGetRelatedForms() {
     Enrollment_Component__c stageComponent = [Select id from Enrollment_Component__c where RecordType.DeveloperName = 'Stage' limit 1];
     hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c FROM hed__Program_Enrollment__c LIMIT 1];

     List<NES_DashboardUtilities.Form> form = NES_EnrollmentController.getRelatedForms(stageComponent.Id, progEnrollment.Id);
     System.assertNotEquals(null,form );
     form = NES_EnrollmentController.getRelatedForms(null,null);
     System.assertEquals(null,form );
        update new Enrollment_Component__c(Id = stageComponent.Id, Document_Submission_Start_Date__c = Date.today().addMonths(2));
        form = NES_EnrollmentController.getRelatedForms(stageComponent.Id, progEnrollment.Id);
        System.assertNotEquals(null,form );
    }


    /**
     * Created by Raju on 30/11/18.
     * Purpose : This method is a Test method for both getTerminationReasons and terminateApplication methods of NES_DashboardController class.
     */
    static testMethod void testTerminateApplication() {
        hed__Program_Enrollment__c hpe = [SELECT Id, Status__c FROM hed__Program_Enrollment__c WHERE CreatedDate = TODAY LIMIT 1];
        Opportunity opty=Peak_TestUtils.createOpportunity(hpe.Id);
        Test.startTest();
        Peak_Response response = NES_EnrollmentController.terminateApplication(hpe.Id, 'Not a good fit');
        NES_EnrollmentController.getTerminationReasons();
        Test.stopTest();
    }
    
    static testMethod void testTerminate() {
        hed__Program_Enrollment__c hpe = [SELECT Id,Status__c,Enrollment_Type__c FROM hed__Program_Enrollment__c LIMIT 1];
        hpe.Enrollment_Type__c='Re-enrolling student';
        update hpe;
        Opportunity opty=Peak_TestUtils.createOpportunity(hpe.Id);
        Test.startTest();
       	Peak_Response response = NES_EnrollmentController.terminateApplication(hpe.Id, 'Not a good fit');
       
        Test.stopTest();
        hed__Program_Enrollment__c hpe1 = [SELECT Id,Status__c,Enrollment_Type__c FROM hed__Program_Enrollment__c where id=:hpe.id];
        System.assertEquals('Withdrawn', hpe1.Status__c);
        System.assertNotEquals('Inactive',hpe1.Status__c);
    }
    /**
     * Created by Gourav on 3/3/19.
     * Purpose : This method is a Test method for negative testing of terminateApplication methods of NES_DashboardController class.
     */
    static testMethod void testTerminateApplicationNegative() {
        hed__Program_Enrollment__c hpe = [SELECT Id, Status__c FROM hed__Program_Enrollment__c WHERE CreatedDate = TODAY LIMIT 1];
        //Opportunity opty=Peak_TestUtils.createOpportunity(hpe.Id);
        Test.startTest();
        Peak_Response response = NES_EnrollmentController.terminateApplication(hpe.Id, 'Not a good fit');
        NES_EnrollmentController.getTerminationReasons();
        Test.stopTest();
    }
    /**
     * Created by Gourav on 3/3/19.
     * Purpose : This method is a Test method grabNameOfStudent of NES_DashboardController class.
     */
    static testMethod void testgrabNameOfStudent() {
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        User portalUser = [SELECT Id FROM User WHERE ContactId != null AND IsActive=TRUE LIMIT 1];
        Test.startTest();
            system.runAs(portalUser) {
                NES_EnrollmentController.grabNameOfStudent(student.Id, null);
            }
        Test.stopTest();
    }

    static testMethod void testGetCaretakers() {
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Peak_Response response =  NES_EnrollmentController.getCaretakers(student.Id);
        System.assertNotEquals(null,response);
    }

    /*static testMethod void testSubmitQuestions(){
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c FROM hed__Program_Enrollment__c LIMIT 1];
        Enrollment_Component__c processComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Process' LIMIT 1];
        Enrollment_Component__c sectionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Section' LIMIT 1];
        Enrollment_Component__c questionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question' LIMIT 1];

        List<NES_EvaluateUtil.Question> questionsList = new List<NES_EvaluateUtil.Question>();
        NES_EvaluateUtil.Question questionWrap = new NES_EvaluateUtil.Question();
        questionWrap.questionPrompt = 'questionPromptTest';
        questionWrap.tooltipText = 'tooltipTextTest';
        questionWrap.componentMessage = 'componentMessageTest';
        questionWrap.questionType = 'Text';
        questionWrap.questionId = questionComponent.Id;
        questionWrap.parentId = sectionComponent.Id;
        questionWrap.targetField = 'Contact.Name';
        questionWrap.componentType = 'Student';
        questionWrap.questionTarget = '';
        questionWrap.required = false;
        questionsList.add(questionWrap);

        String questionJSON = JSON.serialize(questionsList);
        Test.startTest();
        NES_EnrollmentController.submitQuestions(progEnrollment.Id, questionJSON, processComponent.Id, sectionComponent.Id);
        Test.stopTest();
    }*/
    
    /**
     * Created by Chinnamanaidu Neerasa on 29/11/2019 for US#119347
     * Purpose : This method is used to display popup window when the  Program Enrollment's related
     *           Opportunity Application End Reason (Internal) field starts with "Regulation" 
     */
    static testMethod void testdisplayPopupReg() {

     Contact student = [SELECT Id FROM Contact LIMIT 1];
            Opportunity opty = new Opportunity();
                opty.Name = 'test 1';
                opty.StageName = 'Closed Lost';
                opty.Reactivation__c = true;
                opty.CloseDate = Date.today().addMonths(1);
               
                opty.Student_Id__c=student.Id;
               opty.Full_Reactivation_Date__c = system.today();
                                    
                
        insert opty;
        Test.startTest();
       
        opty.Application_End_Reason_internal__c ='Regulation';
        update opty;
       boolean res =  NES_EnrollmentController.displayPopupReg(student.Id);
       
       
        Test.stopTest();
        System.assertEquals( true,res);
    }
    
    /*Created By : Jagadish Babu
     *Purpose : this method is use to cover getIsEnrollmentReady method and reactivateStudent Method
	 */
    static testMethod void testEnrollmentsReady() {
        hed__Program_Enrollment__c hpe = [SELECT Id, Initial_ECA_Creation_Complete__c FROM hed__Program_Enrollment__c where Initial_ECA_Creation_Complete__c = false  LIMIT 1 ];
        test.startTest();
        Boolean response = NES_EnrollmentController.getIsEnrollmentReady(hpe.Id);
        Peak_Response pResponse = NES_EnrollmentController.reactivateStudent(hpe.Id);
        system.assertEquals(false, response);
        test.stopTest();
    }
	
    
    /*Created By : Jagadish Babu
     *Purpose : this method is use to cover getSchoolId
	 */
    static testMethod void testGetSchoolId() {
        hed__Program_Enrollment__c hpe = [SELECT Id,hed__Account__r.ParentId FROM hed__Program_Enrollment__c LIMIT 1 ];
        test.startTest();       
        Id schoolRecId = NES_EnrollmentController.getSchoolId(hpe.Id);
        system.assertEquals(hpe.hed__Account__r.ParentId, schoolRecId);
        test.stopTest();
    }
    
    static testMethod void gradeLevelsTest() {
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        School_Year__c schoolYears = [Select id,Name FROM School_Year__c WHERE Name ='2018-2019' LIMIT 1]; 
        test.startTest();       
        List<Grade_Level__c> gradeLevelId = NES_EnrollmentController.getGradeLevels(academicProgram.Name,schoolYears.Name);
        Boolean flag = NES_EnrollmentController.getNextYearAvailability(academicProgram.Name,schoolYears.Name);
        test.stopTest();
    }
       static testMethod void schoolYearsTest() {
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        //School_Year__c schoolYears = [Select id,Name FROM School_Year__c WHERE Name ='2018-2019' LIMIT 1]; 
        test.startTest();       
        List<School_Year__c> schoolIds = NES_EnrollmentController.getSchoolYears(academicProgram.Name);
        test.stopTest();
    }
    
    static testMethod void updatedOpenAppReleasedTest() {
        hed__Program_Enrollment__c hpe = [SELECT Id,Open_Application__c FROM hed__Program_Enrollment__c LIMIT 1 ];
        hpe.Open_Application__c = 'Released';
        update hpe;
        test.startTest();       
        	NES_EnrollmentController.updatedOpenAppReleased(hpe.Id);
        test.stopTest();
    }
    
}