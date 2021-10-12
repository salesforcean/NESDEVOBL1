/**
 * Created by Ritvik on 19-11-2018.
 * Modified by Ritvik on 28-11-2018.
 * Purpose : Test class for AnnualStudentInformationBusinessLogic apex class.
 * Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
 */

@isTest
public class NES_AnnualStudentInfoTriggerTest { 

    @TestSetup
    static void setup(){
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged',true);
        Peak_TestUtils.createNESBusinessLogicSwitch('AnnualStudentInformationTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('High School LTS Group', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('High School LTS Score',true);
        Peak_TestUtils.createNESBusinessLogicSwitch('HomeLanguageSurveyTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Waitlist Flag Calculation', true);

        Account account = Peak_TestUtils.createTestAccount();
//date.parse('11/17/2018')
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
        School_Year__c prevSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',System.today().addYears(-1));
        system.debug('current sy ' + currentSchoolYear.Name);

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        system.debug('1 ' + academicProgramAccount);
		academicProgramAccount.Registration_Start_Date__c = Date.today().addMonths(-2);
		update academicProgramAccount;

        hed__Program_Enrollment__c progEnrollmentWithoutStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentWithoutStatus.Status__c = 'Time Expired';
        insert progEnrollmentWithoutStatus;
        system.debug('1 ' + progEnrollmentWithoutStatus);

        hed__Program_Enrollment__c progEnrollmentWithStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentWithStatus.Status__c = 'In Progress';
        progEnrollmentWithStatus.ELLFlag__c='Potential EL';
        insert progEnrollmentWithStatus;
        hed__Program_Enrollment__c progEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentTest.ELLFlag__c='Potential';
        Insert progEnrollmentTest;
        //Test Data for Why Flag Method
        School_Year__c SchoolYear =Peak_TestUtils.createSchoolYears('2018-2019', Date.newInstance(2018, 1, 1));
        SchoolYear.Name = '2018-2019';
        SchoolYear.Start_Date__c = Date.newInstance(2018, 1, 1);
        SchoolYear.End_Date__c = Date.newInstance(2019, 1, 1);
        update SchoolYear ;

        // School_Year__c  SchoolYear =[SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c LIMIT 1 WHERE NAME='2018-2019'];
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        List<Special_Education__c> specialEducationList = new List<Special_Education__c>();
        List<Enrollment_Document__c> enrollmentDocumentList = new List<Enrollment_Document__c> ();
        List<Annual_Student_Information__c> studentInfoList = new List<Annual_Student_Information__c> ();
        List<Opportunity> opportunityList = new List<Opportunity> ();
        List<Enrollment_Document__c> enrollmentDocList = new List<Enrollment_Document__c>();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,SchoolYear.Id, false);
        progEnrollment.Status__c = 'In Progress';
        progEnrollment.CounselingFlag__c = 'Stop';
        progEnrollment.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment.PORFlag__c ='Pending';
        progEnrollment.Start_Year__c = SchoolYear.Id;
        progEnrollment.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible' ;
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.DisciplinaryFlagOverride__c = 'Pending Review';



        programEnrollmentList.add(progEnrollment) ;

        hed__Program_Enrollment__c progEnrollment2 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,SchoolYear.Id, false);
        progEnrollment2.Status__c = 'In Progress';
        progEnrollment2.CounselingFlag__c = 'Stop';
        progEnrollment2.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment2.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment2.PORFlag__c ='Pending';
        progEnrollment2.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment2.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment2.EntranceAgeEligibilityOverride__c = 'Eligible' ;
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.DisciplinaryFlagOverride__c = 'Pending Review';
        programEnrollmentList.add(progEnrollment2);

        hed__Program_Enrollment__c progEnrollment3 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,SchoolYear.Id, false);
        progEnrollment3.Status__c = 'In Progress';
        progEnrollment3.CounselingFlag__c = 'Stop';
        progEnrollment3.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment3.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment3.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment3.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment3.PORFlag__c ='Pending';
        progEnrollment3.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment3.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment3.EntranceAgeEligibilityOverride__c = 'Eligible' ;
        progEnrollment3.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment3.DisciplinaryFlagOverride__c = 'Pending Review';
        programEnrollmentList.add(progEnrollment3);

        Insert programEnrollmentList;
        List<hed__Program_Enrollment__c> progEnrollments = [SELECT Id FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress'];



        Opportunity opp = Peak_TestUtils.createOpportunity('Test1',academicProgramAccount.Id,System.Today(),'Closed Won',false);
        opp.Program_Enrollment__c = programEnrollmentList[0].Id;
        opportunityList.add(opp);
        Opportunity opp1 = Peak_TestUtils.createOpportunity('Test2',academicProgramAccount.Id,System.Today(),'Closed Won',false);
        opp1.Program_Enrollment__c = programEnrollmentList[1].Id;
        opportunityList.add(opp1);
        Insert opportunityList;

        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(programEnrollmentList[1].Id,false);
        specialEducation.IEP__c = 'Documenting';
        specialEducation.Plan504__c = 'Received';
        specialEducationList.add(specialEducation);

        Special_Education__c specialEducation1 = Peak_TestUtils.createSpecialEducation(programEnrollmentList[0].Id,false);
        specialEducation1.IEP__c = 'IEP';
        specialEducation1.Plan504__c = '504-No Documentation Available';
        specialEducationList.add(specialEducation1);
        Insert  specialEducationList;

        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollmentList[0].Id,'Choice Transfer Form','Invalid-Denied',False);
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollmentList[1].Id,'Choice Transfer Form','Invalid-Denied',False);
        enrollmentDocList.add(enrollmentDocument1);
        enrollmentDocList.add(enrollmentDocument2);
        Insert enrollmentDocList;
        List<Enrollment_Document__c> enrollmentDocToUpdate = [Select Id,Status_Reason__c From Enrollment_Document__c Where Status_Reason__c = 'Invalid-Denied'];
        enrollmentDocToUpdate[0].Type__c = 'Choice Transfer Form';
        enrollmentDocToUpdate[0].Status_Reason__c = 'Invalid-Denied';
        update enrollmentDocToUpdate;
        
        
    }

     static testMethod void AfterInsertTestScenario1(){
            
          hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'Time Expired' limit 1];
          School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
          Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, false);
          currentASI.Final_Grade_Level__c = '7';

          Test.startTest();
          insert currentASI;

          Annual_Student_Information__c record = [SELECT Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__r.Final_Grade_Level__c FROM Annual_Student_Information__c WHERE Id =: currentASI.Id ];
          System.assertEquals(null, record.Program_Enrollment__r.Final_Grade_Level__c);
          //System.assertEquals(record.Final_Grade_Level__c, record.Grade_Level_Requested__c);
          Test.stopTest();
      }

      static testMethod void AfterInsertTestScenario2(){

          hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];
          School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
          Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, false);
          currentASI.Final_Grade_Level__c = '7';

          Test.startTest();
          insert currentASI;

          Annual_Student_Information__c record = [SELECT Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__r.Final_Grade_Level__c FROM Annual_Student_Information__c WHERE Id =: currentASI.Id ];
          System.assertEquals(record.Final_Grade_Level__c, record.Program_Enrollment__r.Final_Grade_Level__c);
          //System.assertEquals(record.Final_Grade_Level__c, record.Grade_Level_Requested__c);
          Test.stopTest();
      }

      static testMethod void AfterUpdateTestScenario1(){
          School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
          hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'Time Expired'  limit 1];
          Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);

            currentASI.Final_Grade_Level__c ='8';

         Test.startTest();
         upsert currentASI;

         Annual_Student_Information__c record = [SELECT Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__r.Final_Grade_Level__c FROM Annual_Student_Information__c WHERE Id =: currentASI.Id ];
         System.assertEquals(null, record.Program_Enrollment__r.Final_Grade_Level__c);
         //System.assertEquals(record.Final_Grade_Level__c, record.Grade_Level_Requested__c);
         Test.stopTest();
     }

     static testMethod void AfterUpdateTestScenario2(){

         hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];
         School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
         Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
    /*currentASI.Grade_Level_Requested__c = '10';
    insert currentASI;*/
     currentASI.Final_Grade_Level__c ='3';

      Test.startTest();
         //NES_ECACompletion.shouldRunCompletion = false;
      upsert currentASI;

      Annual_Student_Information__c record = [SELECT Final_Grade_Level__c, Grade_Level_Requested__c, Program_Enrollment__r.Final_Grade_Level__c FROM Annual_Student_Information__c WHERE Id =: currentASI.Id ];
      System.assertEquals(record.Final_Grade_Level__c, record.Program_Enrollment__r.Final_Grade_Level__c);
      //System.assertEquals(record.Final_Grade_Level__c, record.Grade_Level_Requested__c);
      Test.stopTest();
  }

  static testMethod void test_populateStudentPlacementBucket_Update(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
      currentASI.AutomatedPlacementScore__c = 70;
      Test.startTest();
       update currentASI;
      Annual_Student_Information__c ASIrecord = [SELECT StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Id =: currentASI.Id];
      //System.assertEquals('BROKEN',ASIrecord.StudentPlacementBucket__c);
      Test.stopTest();
  }

  static testMethod void test_populatePEHighSchoolLTSGroup_AfterInsert1(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, false);
      currentASI.Grade_Level_Requested__c = '10';
      //currentASI.HS_LTS__c = '12';
      Test.startTest();
      System.debug('Before insert ASI+++'+currentASI);
      insert currentASI;
      Annual_Student_Information__c asiRecord = [SELECT Id,Program_Enrollment__r.HS_LTS_Group__c FROM Annual_Student_Information__c
      WHERE Id =: currentASI.Id];
      System.assertEquals('Medium HS LTS',asiRecord.Program_Enrollment__r.HS_LTS_Group__c);
      Test.stopTest();
  }

  static testMethod void test_populatePEHighSchoolLTSGroup_AfterInsert2(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, false);
      currentASI.Grade_Level_Requested__c = '10';
      //currentASI.HS_LTS__c = '1';
      Test.startTest();
      insert currentASI;
      Annual_Student_Information__c asiRecord = [SELECT Id,Program_Enrollment__r.HS_LTS_Group__c FROM Annual_Student_Information__c
      WHERE Id =: currentASI.Id];
      System.assertEquals('Medium HS LTS',asiRecord.Program_Enrollment__r.HS_LTS_Group__c);
      Test.stopTest();
  }

  static testMethod void test_populatePEHighSchoolLTSGroup_AfterUpdate1(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
      currentASI.Grade_Level_Requested__c = '10';
      //currentASI.HS_LTS__c = '-12';
      Test.startTest();
      update currentASI;
      Annual_Student_Information__c asiRecord = [SELECT Id,Program_Enrollment__r.HS_LTS_Group__c FROM Annual_Student_Information__c
      WHERE Id =: currentASI.Id];
      System.assertEquals('Medium HS LTS',asiRecord.Program_Enrollment__r.HS_LTS_Group__c);
      Test.stopTest();
  }

  static testMethod void test_populatePEHighSchoolLTSGroup_AfterUpdate2(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
      currentASI.Grade_Level_Requested__c = '1';
      //currentASI.HS_LTS__c = '-12';
      Test.startTest();
      update currentASI;
      Annual_Student_Information__c asiRecord = [SELECT Id,Program_Enrollment__r.HS_LTS_Group__c FROM Annual_Student_Information__c
      WHERE Id =: currentASI.Id];
      System.assertEquals(null,asiRecord.Program_Enrollment__r.HS_LTS_Group__c);
      Test.stopTest();
  }

   //Added By Anand
  static testMethod void calculateEllTest(){
      School_Year__c cSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c progEnrollment1 = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential'];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment1.Id, cSchoolYear.Id, false);
      currentASI.StudentIsELL__c=True;

      Test.StartTest();
      Insert currentASI;
      hed__Program_Enrollment__c progEnrollment2=[SELECT ID,ELLFlag__c FROM  hed__Program_Enrollment__c WHERE Id=:progEnrollment1.Id];
      System.assertEquals('EL Student',progEnrollment2.ELLFlag__c);
      Test.StopTest();

  }
     //Created by Anand
    Static testMethod void CalculateELLFlagTest(){
        Test.startTest();
        hed__Program_Enrollment__c progEnrollment1 = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
        Home_Language_Survey__c   homeLangSurveyTest=Peak_TestUtils.createHomeLanguageSurveyRecord('Test1',progEnrollment1.Id,False);
        homeLangSurveyTest.HLS_Date_Completed__c = NULL;
        Insert homeLangSurveyTest;
        Home_Language_Survey__c hmeLangSurvey=[Select Id,HLS_Date_Completed__c,Program_Enrollment__r.ELLFlag__c FROM Home_Language_Survey__c WHERE Name='Test1' ];
        System.assertEquals(hmeLangSurvey.Program_Enrollment__r.ELLFlag__c,NUll);
        hmeLangSurvey.HLS_Date_Completed__c =System.Today();
        Update hmeLangSurvey;
        Home_Language_Survey__c hmeLangSurvey1=[Select Id,HLS_Date_Completed__c,Program_Enrollment__r.ELLFlag__c FROM Home_Language_Survey__c WHERE Id=:hmeLangSurvey.Id];
        System.assertEquals(hmeLangSurvey1.Program_Enrollment__r.ELLFlag__c,NUll);
        Test.stopTest();
    }

     //Added by Anand
  static testMethod void calculateEllTestOnUpdate(){
    
      School_Year__c cSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      hed__Program_Enrollment__c progEnrollment1 = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential'];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment1.Id, cSchoolYear.Id, false);
      currentASI.StudentIsELL__c=False;
      Insert currentASI;
      Annual_Student_Information__c ASI1 = [SELECT Id,StudentIsELL__c FROM Annual_Student_Information__c WHERE Id=:currentASI.Id];

      Test.StartTest();
      ASI1.StudentIsELL__c=True;
      Update ASI1;
      hed__Program_Enrollment__c progEnrollment2=[SELECT ID,ELLFlag__c FROM  hed__Program_Enrollment__c WHERE Id=:progEnrollment1.Id];
      System.assertEquals('EL Student',progEnrollment2.ELLFlag__c);
      Test.StopTest();

  }

  //Added by Ritvik
  static testMethod void test_calculateHighSchoolLTS_AfterInsert(){
      School_Year__c cSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
      cSchoolYear.Current_Year__c = true;
      update cSchoolYear;
      hed__Program_Enrollment__c progEnrollment1 = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential'];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment1.Id, cSchoolYear.Id, false);
      currentASI.Grade_Level_Requested__c = '6';

      Test.startTest();
      insert currentASI;
      hed__Program_Enrollment__c progEnrollment2=[SELECT ID,LTS__c FROM  hed__Program_Enrollment__c WHERE Id=:progEnrollment1.Id];
      System.assertEquals(null,progEnrollment2.LTS__c);
      Test.stopTest();
  }
  /**
     * Created By Anand 1/2/2019
     * Purpose: To test method for On Insert of AnnualStudentInformation Record
 */
    static testMethod void WhyFlaggedTestForInsert() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId=:programEnrollmentRecordTypeId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Date StartDate = Date.newInstance(2018, 1, 1);
        School_Year__c cSchoolYear = [SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c WHERE Start_Date__c = :StartDate LIMIT 1 ];
        Test.StartTest();

        School_Year__c SchoolYearToUpdate = [SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c LIMIT 1 ];
        SchoolYearToUpdate.Start_Date__c = Date.newInstance(2018, 1, 1);
        SchoolYearToUpdate.End_Date__c = Date.newInstance(2018, 1, 1);
        update SchoolYearToUpdate ;
        School_Year__c  SchoolYear =[SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c LIMIT 1];
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        List<Special_Education__c> specialEducationList = new List<Special_Education__c>();
        List<Enrollment_Document__c> enrollmentDocumentList = new List<Enrollment_Document__c> ();
        List<Annual_Student_Information__c> studentInfoList = new List<Annual_Student_Information__c> ();
        List<Opportunity> opportunityList = new List<Opportunity> ();
        List<Enrollment_Document__c> enrollmentDocList = new List<Enrollment_Document__c>();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, con.Id,SchoolYear.Id, false);

        progEnrollment.CounselingFlag__c = 'Stop';
        progEnrollment.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment.PORFlag__c ='Pending';
        progEnrollment.Start_Year__c = SchoolYear.Id;
        progEnrollment.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment.EntranceAgeEligibilitySystem__c = 'Too young' ;
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.DisciplinaryFlagOverride__c = 'Pending Review';

        programEnrollmentList.add(progEnrollment) ;

        //Start : Commented by Ritvik as per discussion with Tricia in call on 01/15/2019.
        hed__Program_Enrollment__c progEnrollment2 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, con.Id,SchoolYear.Id, false);
        progEnrollment2.CounselingFlag__c = 'Stop';
        progEnrollment2.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment2.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment2.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment2.EntranceAgeEligibilitySystem__c = 'Too young' ;
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.DisciplinaryFlagOverride__c = 'Pending Review';
        programEnrollmentList.add(progEnrollment2);
        //End

        Insert programEnrollmentList;
        
        Opportunity opp = Peak_TestUtils.createOpportunity('Test1',academicAccount.Id,System.Today(),'Closed Won',false);
        opp.Program_Enrollment__c = programEnrollmentList[0].Id;
        opportunityList.add(opp);
        Opportunity opp1 = Peak_TestUtils.createOpportunity('Test2',academicAccount.Id,System.Today(),'Closed Won',false);
        opp1.Program_Enrollment__c = programEnrollmentList[1].Id;
        opportunityList.add(opp1);
        Insert opportunityList;

        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(programEnrollmentList[0].Id,false);
        specialEducation.IEP__c = 'Documenting';
        specialEducation.Plan504__c = 'Received';
        specialEducation.IEPHistory__c = 'No';
        specialEducationList.add(specialEducation);

        Special_Education__c specialEducation1 = Peak_TestUtils.createSpecialEducation(programEnrollmentList[0].Id,false);
        specialEducation1.IEP__c = 'IEP';
        specialEducation1.Plan504__c = '504-No Documentation Available';
        specialEducation.IEPHistory__c = 'No';
        specialEducationList.add(specialEducation1);
        Insert  specialEducationList;

        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollmentList[0].Id,'Choice Transfer Form','Invalid-Denied',False);
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(programEnrollmentList[1].Id,'Choice Transfer Form','Invalid-Denied',False);
        enrollmentDocList.add(enrollmentDocument1);
        enrollmentDocList.add(enrollmentDocument2);
        Insert enrollmentDocList;
        List<Enrollment_Document__c> enrollmentDocToUpdate = [Select Id,Status_Reason__c From Enrollment_Document__c Where Status_Reason__c = 'Invalid-Denied'];
        enrollmentDocToUpdate[0].Type__c = 'Choice Transfer Form';
        enrollmentDocToUpdate[0].Status_Reason__c = 'Invalid-Denied';
        update enrollmentDocToUpdate;
        List<Annual_Student_Information__c> studInformationList = new List<Annual_Student_Information__c> ();

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollmentList[0].Id, cSchoolYear.Id, false);
        currentASI.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASI.Final_Grade_Level__c = '1';
        Insert currentASI;
        // Assert the updated ProgEnrollment WhyFlag Field
        Annual_Student_Information__c asiUpdated = [Select Program_Enrollment__r.WhyFlagged__c FROM Annual_Student_Information__c WHERE Id =:currentASI.Id];
        System.assertEquals(asiUpdated.Program_Enrollment__r.WhyFlagged__c, '{Placement}-{Program Fit}-[Waitlisted]-[Disciplinary History]-[Potential Homeless]-{Age Eligibility}-');
        Annual_Student_Information__c currentASITest = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', programEnrollmentList[1].Id, cSchoolYear.Id, false);
        currentASITest.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASITest.Final_Grade_Level__c = '2';
        Insert currentASITest;
        // Assert the updated ProgEnrollment WhyFlag Field
        Annual_Student_Information__c asiUpdated2 = [Select Program_Enrollment__r.WhyFlagged__c FROM Annual_Student_Information__c WHERE Id =:currentASITest.Id];
        System.assertEquals(asiUpdated2.Program_Enrollment__r.WhyFlagged__c, '{Program Fit}-[Waitlisted]-[Disciplinary History]-[Potential Homeless]-{Age Eligibility}-');
        Test.StopTest();
    }
    /**
 * Created By Anand 1/2/2019
 * Purpose: To test method for On Insert of AnnualStudentInformation Record
   */
    static testMethod void WhyFlaggedTestCaseTwo() {
        
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId=:programEnrollmentRecordTypeId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Date StartDate = Date.newInstance(2018, 1, 1);
        School_Year__c cSchoolYear = [SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c WHERE Start_Date__c = :StartDate LIMIT 1 ];
        School_Year__c  SchoolYear =[SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c LIMIT 1];
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        //Start : Added Limit 1 to query in for by Ritvik on 01/15/2019 as per discussion with Tricia in call. 
        for(hed__Program_Enrollment__c progEnrollment:[SELECT Id,Status__c,CounselingFlag__c,WaitlistFlag__c,UserTechnologyFlag__c,
                HomelessRiskFlag__c,PrincipalGeneralFlag__c,PlacementFlag__c,
                PORFlag__c,Start_Year__c,HHPORFlag__c,GradeLevelEligibility__c,
                EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,
                DisciplinaryFlagOverride__c FROM hed__Program_Enrollment__c LIMIT 1 ]){ //End

            progEnrollment.Status__c = 'In Progress';
            progEnrollment.Start_Year__c = cSchoolYear.Id;
            progEnrollment.CounselingFlag__c = 'Stop';
            progEnrollment.WaitlistFlag__c = 'Active';
            //Commented Deprecate Technology flag logic for US 476956
            //progEnrollment.UserTechnologyFlag__c = 'Withdraw';
            progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';

            progEnrollment.PriorWithdrawalFlag__c = 'Hold';
            progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
            progEnrollment.EntranceAgeEligibilitySystem__c = 'Eligible' ;

            programEnrollmentList.add(progEnrollment);
        }
        
        Test.StartTest();
        update programEnrollmentList;
        Test.StopTest();
        
        Grade_Level__c   gradeLevel = Peak_TestUtils.createGradeLevel('1', True);
        Program_Grade_Level__c  progGrades = Peak_TestUtils.createProgramGradeLevel ('Test1',academicAccount.Id ,gradeLevel.Id, System.today(), True);
        Program_Grade_Level__c  progGrades2 = Peak_TestUtils.createProgramGradeLevel ('Test1',academicAccount.Id ,gradeLevel.Id, System.today(), True);
        Program_Grade_Level__c  progGrades1 = Peak_TestUtils.createProgramGradeLevel ('Test2',academicAccount.Id ,gradeLevel.Id, System.today(), True);
        progGrades1.AutoPlacement_Special_EdExclude__c =True;
        update progGrades1;
       
        List<Annual_Student_Information__c> studentInfoList = new List<Annual_Student_Information__c> ();


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollmentList[0].Id, cSchoolYear.Id, false);
        currentASI.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASI.Final_Grade_Level__c = '1';
        studentInfoList.add(currentASI);
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', programEnrollmentList[0].Id, cSchoolYear.Id, false);
        currentASI1.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASI1.Final_Grade_Level__c = '1';
        studentInfoList.add(currentASI1);
        Annual_Student_Information__c currentASI2 = Peak_TestUtils.createAnnualStudentInformation('Current ASI2', programEnrollmentList[0].Id, cSchoolYear.Id, false);
        currentASI2.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASI2.Final_Grade_Level__c = '2';
        studentInfoList.add(currentASI2);
        Insert studentInfoList;
        Special_Education__c  spEducation=[SELECT Id,IEP__c,Program_Enrollment__c FROM Special_Education__c WHERE IEP__c <>Null LIMIT 1];
        spEducation.IEP__c = 'Documenting';
        update spEducation ;
        Special_Education__c specialEducationTest = [SELECT Program_Enrollment__r.WhyFlagged__c FROM Special_Education__c WHERE Id =:spEducation.Id];
        System.assertNotEquals(specialEducationTest.Program_Enrollment__r.WhyFlagged__c, null);
        hed__Program_Enrollment__c progEnrollmentToTest =[SELECT Id,HHPORFlag__c,PORFlag__c,WhyFlagged__c,PlacementFlag__c,CounselingFlag__c,Start_Year__c,
                PriorWithdrawalFlag__c,WaitlistFlag__c,
                UserTechnologyFlag__c,DisciplinaryFlagOverride__c,HomelessRiskFlag__c,PrincipalGeneralFlag__c FROM hed__Program_Enrollment__c LIMIT 1];
        System.assertNotEquals(progEnrollmentToTest.WhyFlagged__c, null);        
    }

   /* Created By Rakesh Ramaswamy on 4/30/2021
    * Purpose: To test method for On update of Program Enrollment Record when scheduled batch jobs (NES_Batch_UpdateHardStopTimeConstraint) or (NES_Batch_SecondSemester) are executed.
    *          The intention behind this test method is to test the positive scenario of the Grade_Level_Requested__c data element not being null or blank in the Current ASI record as well as the Previous ASI record.
    *          The Student related Previous ASI record and the Current ASI record are associated to the Student related Program Enrollments.
    */
    static testMethod void previousASIAndCurrentASIHaveGradeLevelRequested() {
          School_Year__c currentSchoolYear = [SELECT Id, Start_Date__c FROM School_Year__c WHERE Name = '2018-2019' limit 1];
          School_Year__c prevSchoolYear = [Select Id, Start_Date__c FROM School_Year__c WHERE Name = '2017-2018' limit 1];
          hed__Program_Enrollment__c programEnrollment = [SELECT Id, Start_Year__c, Start_Year__r.Start_Date__c FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress'  limit 1];
          Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
          Annual_Student_Information__c previousASI = Peak_TestUtils.createAnnualStudentInformation('Previous ASI', programEnrollment.Id, prevSchoolYear.Id, true);
                 
          currentASI.Grade_Level_Requested__c ='8';
          update currentASI;
                
          previousASI.Grade_Level_Requested__c ='8';
          update previousASI;

          programEnrollment.Start_Year__c = currentSchoolYear.Id;
          update programEnrollment;

          system.assert(programEnrollment.Start_Year__c != null); 
          system.assert(programEnrollment.Start_Year__r.Start_Date__c != null);
          system.assertEquals(currentASI.Grade_Level_Requested__c, previousASI.Grade_Level_Requested__c);
          system.assertEquals(programEnrollment.Start_Year__r.Start_Date__c.addYears(-1), prevSchoolYear.Start_Date__c);
    }

    /* Created By Rakesh Ramaswamy on 4/30/2021
    * Purpose: To test method for On update of Program Enrollment Record when scheduled batch jobs (NES_Batch_UpdateHardStopTimeConstraint) or (NES_Batch_SecondSemester) are executed.
    *          The intention behind this test method is to test the negative scenario of the Grade_Level_Requested__c data element not being null or blank in the Current ASI record as well as the Previous ASI record.
    *          The Student related Previous ASI record and the Current ASI record are associated to the Student related Program Enrollments.
    */
    static testMethod void previousASIAndCurrentASINotHaveGradeLevelRequested() {
        School_Year__c currentSchoolYear = [SELECT Id, Start_Date__c FROM School_Year__c WHERE Name = '2018-2019' LIMIT 1];
        School_Year__c prevSchoolYear = [SELECT Id, Start_Date__c FROM School_Year__c WHERE Name = '2017-2018' LIMIT 1];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, Start_Year__c, Start_Year__r.Start_Date__c FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress'  LIMIT 1];
        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, true);
        Annual_Student_Information__c previousASI = Peak_TestUtils.createAnnualStudentInformation('Previous ASI', programEnrollment.Id, prevSchoolYear.Id, true);
        list<School_Year__c> schoolYearList = new list<School_Year__c>();
       
        currentASI.Grade_Level_Requested__c = null;
        update currentASI;
              
        previousASI.Grade_Level_Requested__c ='7';
        update previousASI;
        
        programEnrollment.Start_Year__c = null;
        update programEnrollment;

        system.assert(programEnrollment.Start_Year__c == null);         
        system.assertNotEquals(currentASI.Grade_Level_Requested__c, previousASI.Grade_Level_Requested__c);
        
        currentSchoolYear.Start_Date__c = null;
        currentSchoolYear.End_Date__c = null;
        schoolYearList.add(currentSchoolYear);
        prevSchoolYear.Start_Date__c = Date.today().addDays(-15).addYears(-1);
        prevSchoolYear.End_Date__c = Date.today().addDays(15).addYears(-1);
        schoolYearList.add(prevSchoolYear);
        update schoolYearList;

        programEnrollment.Start_Year__c = currentSchoolYear.Id;
        update programEnrollment;        
        system.assertNotEquals(programEnrollment.Start_Year__r.Start_Date__c, null);
        system.assertNotEquals(programEnrollment.Start_Year__r.Start_Date__c, prevSchoolYear.Start_Date__c);
    }
}