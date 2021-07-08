/**
 * Created by Anand on 12/7/2018.
 */

@isTest

Private class NES_OpportunityTriggerTest {

    @TestSetup
    static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('OpportunityTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today()); 
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        academicAccount.Confirmation_End_Date__c=datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.Second_Semester_Confirmation_Date__c=datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update academicAccount;
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, false);
        ProgramEnrollmentTest.Final_Grade_Level__c = '1';
        Insert ProgramEnrollmentTest;
        List<Opportunity> optyList=new List<Opportunity>();
        Opportunity optyTest1 = Peak_TestUtils.createOpportunity('oldOpty',parentAccount.Id,System.Today(),'closed won',False);
        optyTest1.Semester_Indicator__c='First';
        optyTest1.Final_Semester_Indicator__c='Second';
        optyTest1.Earliest_Final_Confirmation_Date__c=System.today();
        optyTest1.Program_Enrollment__c=ProgramEnrollmentTest.Id;
        Insert  optyTest1;

    //Test data setup by Ritvik
        //Account account = Peak_TestUtils.createTestAccount();
        School_Year__c schoolYear1 = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        //Contact contact = Peak_TestUtils.createTestContact('Students', parentAccount.Id);
        //Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id,schoolYear1.Id);
        academicAccount.FirstDayforStudents__c = System.today().addDays(-10);
        academicAccount.PushToSecondSemester__c = System.today().addDays(-5);
        academicAccount.FirstDaySecondSemester__c = System.today().addDays(-15);
        update academicAccount;
        hed__Program_Enrollment__c programEnrollmentWithoutEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id,schlYear.Id, true);
        hed__Program_Enrollment__c programEnrollmentWithEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id,schoolYear1.Id, true);
        Enrollment__c enrollment1 = Peak_TestUtils.createEnrollmentRecord(programEnrollmentWithEnrollment.Id,schoolYear1.Id,true);
        //Enrollment__c enrollment2 = Peak_TestUtils.createEnrollmentRecord(programEnrollmentWithEnrollment.Id,schoolYear1.Id,false);
        //enrollment2.Enrollment_Date__c = System.today();
        Opportunity opportunity1 = Peak_TestUtils.createOpportunity('Test Opportunity1',academicAccount.Id,date.today(),'Proposal',false);
        opportunity1.PreferredStartDate__c = System.today().addDays(-7);
        opportunity1.Semester_Indicator__c = 'Second';
        opportunity1.Program_Enrollment__c = programEnrollmentWithoutEnrollment.Id;
        insert opportunity1;

        Opportunity opportunity2 = Peak_TestUtils.createOpportunity('Test Opportunity2',academicAccount.Id,date.today(),'Proposal',false);
        opportunity2.PreferredStartDate__c = System.today().addDays(-7);
        opportunity2.Semester_Indicator__c = 'Second';
        opportunity2.Program_Enrollment__c = programEnrollmentWithEnrollment.Id;
        insert opportunity2;

        Opportunity opportunity3 = Peak_TestUtils.createOpportunity('Test Opportunity3',academicAccount.Id,date.today(),'Proposal',false);
        opportunity3.PreferredStartDate__c = System.today().addDays(-7);
        opportunity3.Semester_Indicator__c = 'Second';
        opportunity3.Program_Enrollment__c = programEnrollmentWithEnrollment.Id;
		opportunity3.Semester_Indicator__c = 'First';
        opportunity3.Final_Semester_Indicator__c = '';
        Insert opportunity3;

        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();
    }
    /**
     * Created By Anand on 11/10/2018
     *
     */
    static testMethod void updateOpportunityConfirmationDate() {
        Opportunity optyTest1 = [
                select id,
                        Semester_Indicator__c,
                        Program_Enrollment__c,
                        Final_Semester_Indicator__c,
                        Earliest_Final_Confirmation_Date__c
                FROM OPPORTUNITY
                WHERE Final_Semester_Indicator__c = 'Second'
                LIMIT 1
        ];
        Test.startTest();
        // Condition for if Final Semester changed to First from Second
        optyTest1.Final_Semester_Indicator__c = 'First';
        update optyTest1;
        hed__Program_Enrollment__c prEnrollment = [
                SELECT Id,hed__Account__r.Second_Semester_Confirmation_Date__c,
                        hed__Account__r.Confirmation_End_Date__c
                FROM hed__Program_Enrollment__c
                WHERE ID = :optyTest1.Program_Enrollment__c
        ];
        Opportunity optyAssert1 = [
                select id,Program_Enrollment__c,Final_Semester_Indicator__c,Earliest_Final_Confirmation_Date__c
                FROM OPPORTUNITY
                WHERE Id = :optyTest1.Id
        ];
        // Assert the final Confirmation Date to Account Coniframtion End Date
        System.assertEquals(optyAssert1.Earliest_Final_Confirmation_Date__c, prEnrollment.hed__Account__r.Confirmation_End_Date__c);
        // update the final semester value to Second From First
        optyAssert1.Final_Semester_Indicator__c = 'Second';
        update optyAssert1;
        Opportunity optyAssert2 = [select id, Earliest_Final_Confirmation_Date__c FROM OPPORTUNITY WHERE Id = :optyTest1.Id];
        // Assert the final confirmation date to Second Confirmation Date
        System.assertEquals(optyAssert2.Earliest_Final_Confirmation_Date__c, prEnrollment.hed__Account__r.Second_Semester_Confirmation_Date__c);
        // checking if final semester value is Null on update
        optyTest1.Semester_Indicator__c = 'Second';
        optyTest1.Final_Semester_Indicator__c = '';
        update optyTest1;
        Opportunity optyTest2 = [select id,Semester_Indicator__c,Final_Semester_Indicator__c FROM OPPORTUNITY WHERE Id = :optyTest1.Id];
        // Assert final semister to semester Indicator__c
        System.assertEquals(optyTest2.Semester_Indicator__c, optyTest2.Final_Semester_Indicator__c);
        optyTest2.Final_Semester_Indicator__c = 'Second';
        update optyTest2;
        Test.stopTest();

    }
    /**
     * Created By Anand 12/10/2018
     */
    static TestMethod void populateFinal_SemesterIndicatorTest() {
        Account parentAccount = [select Id From Account Limit 1];
        // if  semester has value and final semester is Null
        Test.startTest();
        Opportunity optyTest2 = [select id,Semester_Indicator__c,Final_Semester_Indicator__c FROM OPPORTUNITY WHERE name = 'Test Opportunity3'];
        // Assert semesterIndicator to FinalSemesterIndicator
        System.assertEquals(optyTest2.Semester_Indicator__c, optyTest2.Final_Semester_Indicator__c);
        Opportunity optyTest3 = Peak_TestUtils.createOpportunity('Opty2', parentAccount.Id, System.Today(), 'closed won', False);
        optyTest3.Semester_Indicator__c = 'First';
        optyTest3.Final_Semester_Indicator__c = 'Second';
        Insert optyTest3;
        Opportunity optyTest4 = [select id,Semester_Indicator__c,Final_Semester_Indicator__c FROM OPPORTUNITY WHERE Id = :optyTest3.Id];
        // Assert semesterIndicator to FinalSemesterIndicator
        System.assertNotEquals(optyTest4.Semester_Indicator__c, optyTest4.Final_Semester_Indicator__c);

        Test.stopTest();

    }
    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario1() {
        Opportunity opportunityRecord1 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity1'];
        opportunityRecord1.StageName = 'Closed Won';
        Test.startTest();
        update opportunityRecord1;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord1.Program_Enrollment__c];
        System.assertEquals(System.today().addDays(1), enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }

    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario2() {
        Opportunity opportunityRecord2 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity2'];
        opportunityRecord2.StageName = 'Closed Won';
        Test.startTest();
        update opportunityRecord2;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord2.Program_Enrollment__c];
        System.assertEquals(System.today().addDays(1), enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }

    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario3() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId = :programEnrollmentRecordTypeId AND Name = 'Test Account'];
        academicAccount.FirstDaySecondSemester__c = System.today().addDays(10);
        academicAccount.FirstDayforStudents__c = System.today().addDays(20);
        update academicAccount;
        Opportunity opportunityRecord2 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity2'];
        opportunityRecord2.StageName = 'Closed Won';
        Test.startTest();
        update opportunityRecord2;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord2.Program_Enrollment__c];
        System.assertEquals(academicAccount.FirstDayforStudents__c, enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }

    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario4() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId = :programEnrollmentRecordTypeId AND Name = 'Test Account'];
        academicAccount.FirstDaySecondSemester__c = System.today().addDays(10);
        academicAccount.FirstDayforStudents__c = System.today().addDays(20);
        academicAccount.PushToSecondSemester__c = System.today().addDays(5);
        update academicAccount;
        Opportunity opportunityRecord1 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity1'];
        opportunityRecord1.StageName = 'Closed Won';
        opportunityRecord1.Semester_Indicator__c = 'First';
        Test.startTest();
        update opportunityRecord1;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord1.Program_Enrollment__c];
        System.assertEquals(academicAccount.FirstDayforStudents__c, enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }


    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario5() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId = :programEnrollmentRecordTypeId AND Name = 'Test Account'];
        //academicAccount.FirstDaySecondSemester__c = System.today().addDays(10);
        academicAccount.FirstDayforStudents__c = System.today().addDays(-5);
        academicAccount.PushToSecondSemester__c = System.today().addDays(5);
        update academicAccount;
        Opportunity opportunityRecord1 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity1'];
        opportunityRecord1.StageName = 'Closed Won';
        opportunityRecord1.Semester_Indicator__c = 'First';
        opportunityRecord1.PreferredStartDate__c = System.today().addDays(10);
        Test.startTest();
        update opportunityRecord1;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord1.Program_Enrollment__c];
        System.assertEquals(opportunityRecord1.PreferredStartDate__c, enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }

    //Created by Ritvik
    static testMethod void populateEnrollmentDate_Scenario6() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId = :programEnrollmentRecordTypeId AND Name = 'Test Account'];
        academicAccount.PushToSecondSemester__c = System.today().addDays(5);
        academicAccount.FirstDayforStudents__c = System.today().addDays(-5);
        update academicAccount;
        Opportunity opportunityRecord2 = [SELECT Id,Program_Enrollment__c FROM Opportunity WHERE Name = 'Test Opportunity2'];
        opportunityRecord2.StageName = 'Closed Won';
        opportunityRecord2.Semester_Indicator__c = 'First';
        opportunityRecord2.PreferredStartDate__c = System.today().addDays(10);
        Test.startTest();
        update opportunityRecord2;
        Enrollment__c enrollmentRecord = [SELECT Enrollment_Date__c FROM Enrollment__c WHERE Program_Enrollment__c = :opportunityRecord2.Program_Enrollment__c];
        System.assertEquals(opportunityRecord2.PreferredStartDate__c, enrollmentRecord.Enrollment_Date__c);
        Test.StopTest();
    }
    /**
     * created By Anand
     * Purpose: To test the reactivation Date method
     */
    static testMethod void calculateReactivationDate() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Reactivation Date', Active__c = true);
        insert logicSwitch ;
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Reactivation Date').Active__c;
        System.assertEquals(True, eVal);
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        update ProgramEnrollment;

        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [select ID from Account Where RecordTypeId = :programEnrollmentRecordTypeId];

        Opportunity optyTest1 = Peak_TestUtils.createOpportunity('Test Opportunity1', academicAccount.Id, date.today(), 'Proposal', false);
        optyTest1.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest1.Caretaker_Id__c = Student1.Id;
        Insert optyTest1;
        Opportunity optyTest3 = Peak_TestUtils.createOpportunity('Test Opportunity3', academicAccount.Id, date.today(), 'Proposal', false);
        optyTest3.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest3.Caretaker_Id__c = Student2.Id;
        Insert optyTest3;
        List<Opportunity> optyList = new LIst<Opportunity>();


        Opportunity optyTest2 = Peak_TestUtils.createOpportunity('Test Opportunity21', academicAccount.Id, date.today(), 'close', false);
        optyTest2.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest2.Caretaker_Id__c = portuser.ContactId;
        Opportunity optyTest4 = Peak_TestUtils.createOpportunity('Test Opportunity41', academicAccount.Id, date.today(), 'Proposal', false);
        optyTest4.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest4.Caretaker_Id__c = portuser.ContactId;
        optyList.add(optyTest2);
        optyList.add(optyTest4);
        Insert optyList;
        Test.StopTest();
        //Start : Removed Reactivation_Date__c from query by Ritvik on 01/16/2019 as it is deleted from org.
        Opportunity optyUpdate = [select Id,Reactivation__c From Opportunity Where Name = 'Test Opportunity21'];
        System.assertEquals(optyUpdate.Reactivation__c, false);
        //System.assertEquals(optyUpdate.Reactivation_Date__c, System.today());
        Opportunity optyUpdate1 = [select Id,Reactivation__c From Opportunity Where Name = 'Test Opportunity41'];
        System.assertEquals(optyUpdate1.Reactivation__c, false);
        //System.assertEquals(optyUpdate1.Reactivation_Date__c, System.today());
        //End

    }
/**
 * created By Anand
 * Purpose: To Negative test the reactivation Date method
 */
    static testMethod void calculateReactivationDate_Secenario2() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Reactivation Date', Active__c = true);
        insert logicSwitch ;
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Reactivation Date').Active__c;
        System.assertEquals(True, eVal);
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        update ProgramEnrollment;

        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [select ID from Account Where RecordTypeId = :programEnrollmentRecordTypeId];
        // Negative test data for opportunity stage
        Opportunity optyTest1 = Peak_TestUtils.createOpportunity('Test Opportunity1', academicAccount.Id, date.today(), 'closed won', false);
        optyTest1.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest1.Caretaker_Id__c = Student1.Id;
        Insert optyTest1;
        // Negative test data for opportunity stage
        Opportunity optyTest3 = Peak_TestUtils.createOpportunity('Test Opportunity3', academicAccount.Id, date.today(), 'closed won', false);
        optyTest3.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest3.Caretaker_Id__c = Student2.Id;
        Insert optyTest3;
        List<Opportunity> optyList = new List<Opportunity>();


        Opportunity optyTest2 = Peak_TestUtils.createOpportunity('Test Opportunity21', academicAccount.Id, date.today(), 'closed won', false);
        optyTest2.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest2.Caretaker_Id__c = portuser.ContactId;
        Opportunity optyTest4 = Peak_TestUtils.createOpportunity('Test Opportunity41', academicAccount.Id, date.today(), 'Proposal', false);
        optyTest4.Program_Enrollment__c = ProgramEnrollment.Id;
        optyTest4.Caretaker_Id__c = portuser.ContactId;
        optyList.add(optyTest2);
        optyList.add(optyTest4);
        Insert optyList;
        Test.StopTest();
        //Start : Removed Reactivation_Date__c from query by Ritvik on 01/16/2019 as it is deleted from org.
        Opportunity optyUpdate = [select Id,Reactivation__c From Opportunity Where Name = 'Test Opportunity21'];
        System.assertNotEquals(optyUpdate.Reactivation__c, True);
        //System.assertNotEquals(optyUpdate.Reactivation_Date__c, System.today());
        Opportunity optyUpdate1 = [select Id,Reactivation__c From Opportunity Where Name = 'Test Opportunity41'];
        System.assertNotEquals(optyUpdate1.Reactivation__c, True);
        //System.assertNotEquals(optyUpdate1.Reactivation_Date__c, System.today());
        //End

    }


    Static testMethod void houseHoldEnrollmentDateTest() {
        // Create Test Data for CareTakerId,Students And ProgramEnrollments
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        // Create a record for NES_LogicFeatureSwitch__c with   Household Enrollment Date Value
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        // update programEnrollments with StudentId
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];
        Enrollment__c enrollmentTest = Peak_TestUtils.createEnrollmentRecord(progEnrollmentUpdated.Id, schlYear.Id, false);
        enrollmentTest.Enrollment_Date__c = Date.newInstance(2014, 9, 15);
        Insert enrollmentTest;
        Enrollment__c enrollment1 = [select Id,Enrollment_Date__c FROM Enrollment__c WHERE Id = :enrollmentTest.Id];

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        //Update opportunity to closed won
        Opportunity opp1 = [select Id,StageName From Opportunity Where Id = :oppTest1.Id];

        opp1.StageName = 'Closed Won';
        update opp1;
        Test.StopTest();
        Opportunity oppUpdated = [select Id,StageName,Program_Enrollment__c From Opportunity Where Id = :opp1.Id];
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :oppUpdated.Program_Enrollment__c];
        // Assert the date Enrollment_Date__c to HouseholdEnrollmentDate__c which Needs to be equal
        //System.assertEquals(enrollment1.Enrollment_Date__c, progEnrollment2.HouseholdEnrollmentDate__c);
    }
    Static testMethod void houseHoldEnrollmentDateTestCase2() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        // Create A record for NES_LogicFeatureSwitch__c with  Household Enrollment Date value
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];
        Enrollment__c enrollmentTest = Peak_TestUtils.createEnrollmentRecord(progEnrollmentUpdated.Id, schlYear.Id, false);
        // Negative Testing for Date greater than Program Enrollment Date
        enrollmentTest.Enrollment_Date__c = Date.newInstance(2019, 9, 15);
        Insert enrollmentTest;
        Enrollment__c enrollment1 = [select Id,Enrollment_Date__c FROM Enrollment__c WHERE Id = :enrollmentTest.Id];

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        // update Stage to closed won
        Opportunity opp1 = [select Id,StageName From Opportunity Where Id = :oppTest1.Id];

        opp1.StageName = 'Closed Won';
        update opp1;
        Test.StopTest();
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :progEnrollmentUpdated.Id];
        // HouseholdEnrollmentDate__c of program enrollment shouldnot get updated with Enrollment Date
        System.assertNotEquals(enrollment1.Enrollment_Date__c, progEnrollment2.HouseholdEnrollmentDate__c);

    }
	
    Static testMethod void houseHoldEnrollmentDateTestCase3() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        // Create A record for NES_LogicFeatureSwitch__c with  Household Enrollment Date value
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];
        Enrollment__c enrollmentTest = Peak_TestUtils.createEnrollmentRecord(progEnrollmentUpdated.Id, schlYear.Id, false);
        // Negative Testing for Date greater than Program Enrollment Date
        enrollmentTest.Enrollment_Date__c = Date.newInstance(2019, 9, 15);
        Insert enrollmentTest;
        Enrollment__c enrollment1 = [select Id,Enrollment_Date__c FROM Enrollment__c WHERE Id = :enrollmentTest.Id];

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__r.Enrollment_Type__c,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        // update Stage to closed won
        Opportunity opp1 = [select Id,StageName,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c From Opportunity Where Id = :oppTest1.Id];
        opp1.StageName = 'Closed Won';
        update opp1;
        Test.StopTest();
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :progEnrollmentUpdated.Id];
        // HouseholdEnrollmentDate__c of program enrollment shouldnot get updated with Enrollment Date
        System.assertNotEquals(enrollment1.Enrollment_Date__c, progEnrollment2.HouseholdEnrollmentDate__c);
        hed__Program_Enrollment__c progEnrollment3 = [select Id,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :opp1.Program_Enrollment__c];       
    }
     Static testMethod void InitialEnrollmentTestCase4() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        // Create A record for NES_LogicFeatureSwitch__c with  Household Enrollment Date value
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];              

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__r.Enrollment_Type__c,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        // update Stage to closed won
        Opportunity opp1 = [select Id,StageName,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c From Opportunity Where Id = :oppTest1.Id];
        opp1.StageName = 'Closed Won';
         opp1.SFDC_Informed__c = 'Test';         
        update opp1;
        Test.StopTest();
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :progEnrollmentUpdated.Id];
        // HouseholdEnrollmentDate__c of program enrollment shouldnot get updated with Enrollment Date      
        hed__Program_Enrollment__c progEnrollment3 = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :opp1.Program_Enrollment__c];
        System.assertEquals(opp1.Program_Enrollment__r.Enrollment_Type__c, progEnrollment3.enrollments__r[0].Enrollment_Type__c);
    }
     Static testMethod void reenrollingStudentTestCase5() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        // Create A record for NES_LogicFeatureSwitch__c with  Household Enrollment Date value
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.Enrollment_Type__c = 'Re-Enrolling Student';
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];              

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__r.Enrollment_Type__c,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        // update Stage to closed won
        Opportunity opp1 = [select Id,StageName,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c From Opportunity Where Id = :oppTest1.Id];
        opp1.StageName = 'Closed Won';
         opp1.SFDC_Informed__c = 'Test';         
        update opp1;
        Test.StopTest();
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :progEnrollmentUpdated.Id];
        // HouseholdEnrollmentDate__c of program enrollment shouldnot get updated with Enrollment Date      
        hed__Program_Enrollment__c progEnrollment3 = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :opp1.Program_Enrollment__c];
        System.assertEquals(opp1.Program_Enrollment__r.Enrollment_Type__c, progEnrollment3.enrollments__r[0].Enrollment_Type__c);
    }
    Static testMethod void returningStudentTestCase6() {
        Test.StartTest();
        User portuser = [Select Id,ContactId FROM USER Where Username = 'portalUser@gmail.com'];
        Account account = Peak_TestUtils.createTestAccount();
        Contact Student1 = Peak_TestUtils.createContact('Stud1', account.Id, 'Students', True);
        Contact Student2 = Peak_TestUtils.createContact('Stud2', account.Id, 'Students', True);
        List<hed__Relationship__c> relationList = new List<hed__Relationship__c>();
        hed__Relationship__c relationship1 = Peak_TestUtils.createRelationship(portuser.contactId, Student1.Id, false);
        relationship1.hed__Contact__c = portuser.ContactId;
        Insert relationship1;
        hed__Relationship__c relationship2 = Peak_TestUtils.createRelationship(portuser.contactId, Student2.Id, false);
        relationship2.hed__Contact__c = portuser.ContactId;
        Insert relationship2;
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = 'Household Enrollment Date', Active__c = true);
        insert logicSwitch ;
        // Create A record for NES_LogicFeatureSwitch__c with  Household Enrollment Date value
        Boolean eVal = NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c;
        hed__Program_Enrollment__c ProgramEnrollment = [select Id,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c LIMIT 1];
        ProgramEnrollment.hed__Contact__c = Student1.Id;
        ProgramEnrollment.Enrollment_Type__c = 'Returning Student';
        ProgramEnrollment.HouseholdEnrollmentDate__c = System.today();
        update ProgramEnrollment;
        School_Year__c schlYear = [select Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentUpdated = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollment.Id];              

        Opportunity oppTest1 = [Select Id,StageName,Program_Enrollment__r.Enrollment_Type__c,Program_Enrollment__c FROM Opportunity WHERE StageName <> 'Closed won' LIMIT 1];
        oppTest1.Program_Enrollment__c = progEnrollmentUpdated.Id;
        oppTest1.Caretaker_Id__c = portuser.ContactId;
        update oppTest1;
        // update Stage to closed won
        Opportunity opp1 = [select Id,StageName,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c From Opportunity Where Id = :oppTest1.Id];
        opp1.StageName = 'Closed Won';
         opp1.SFDC_Informed__c = 'Test';         
        update opp1;
        Test.StopTest();
        hed__Program_Enrollment__c progEnrollment2 = [select Id,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :progEnrollmentUpdated.Id];
        // HouseholdEnrollmentDate__c of program enrollment shouldnot get updated with Enrollment Date      
        hed__Program_Enrollment__c progEnrollment3 = [select Id,Enrollment_Type__c,HouseholdEnrollmentDate__c,(Select Id, Enrollment_Type__c from enrollments__r),hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :opp1.Program_Enrollment__c];
        System.assertEquals(opp1.Program_Enrollment__r.Enrollment_Type__c, progEnrollment3.enrollments__r[0].Enrollment_Type__c);
    }
}