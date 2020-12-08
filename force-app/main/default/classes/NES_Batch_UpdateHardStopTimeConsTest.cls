@isTest
/**
 * Created By Anand
 * purpose : To Test The NES_Batch_UpdateHardStopTimeCons
 */
private class NES_Batch_UpdateHardStopTimeConsTest {
    @testSetup static void setup() {
        DateTime DateTimeTest = System.Now();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Id RecordTypeIdEnrollment = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Process').getRecordTypeId();
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        Account account = Peak_TestUtils.createTestAccount();
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Account parentAccount1 = [Select id,Name FROM Account WHERE Id = :parentAccount.Id];
        parentAccount1.Name = 'TestAccount1';
        update parentAccount1;
        Account accTest = [Select id,Name FROM Account WHERE Id = :parentAccount1.Id];
        Contact testContact = Peak_TestUtils.createTestContact();
        TestContact.LastName = 'TestCon';
        update TestContact;
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        School_Year__c schlYearTest = Peak_TestUtils.createSchoolYears('SchoolTest1', System.today());


        Account academicAccount = Peak_TestUtils.createAcademicAccount('TestAcc1', parentAccount.Id, schlYear.Id, false);
        academicAccount.Enrollment_stop_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.Confirmation_End_Date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.Confirmation_Start_Date__c = datetime.newInstance(2017, 9, 15, 12, 30, 0);
        insert academicAccount;
        Account academicAccountTest = Peak_TestUtils.createAcademicAccount('TestAcc2', accTest.Id, schlYearTest.Id, false);

        academicAccountTest.Enrollment_stop_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        insert academicAccountTest;
        Account accountTest1 = [select Id,Enrollment_stop_date__c from Account WHERE Name = 'TestAcc1' LIMIT 1];
        Account accountTest2 = [select Id from Account WHERE Name = 'TestAcc2' LIMIT 1];
        List<Enrollment_Component__c> componentList = new List<Enrollment_Component__c>();
        for (Integer i = 0; i < 20; i++) {
            Enrollment_Component__c enrollmentComponent1 = Peak_TestUtils.createEnrollmentComponent(schlYear.Id, 'Process', false);
            enrollmentComponent1.Name = 'PE' + i;
            if (i <= 5) {
                Enrollment_Component__c enrollmentComponent2 = Peak_TestUtils.createEnrollmentComponent(schlYear.Id, 'form', false);
                enrollmentComponent2.Name = 'PE' + i;
                enrollmentComponent2.Process_Academic_Program__c = academicAccount.Id;
                enrollmentComponent2.Confirmation_Form__c = True;
                componentList.add(enrollmentComponent2);
            } if(i  >5 && i < 10){
                Enrollment_Component__c enrollmentComponent2 = Peak_TestUtils.createEnrollmentComponent(schlYear.Id, 'form', false);
                enrollmentComponent2.Name = 'PE' + i;
                enrollmentComponent2.Process_Academic_Program__c = academicAccount.Id;
                enrollmentComponent2.Confirmation_Form__c = false;
                componentList.add(enrollmentComponent2);
            }
            else {
                enrollmentComponent1.Process_Academic_Program__c = academicAccountTest.Id;
                componentList.add(enrollmentComponent1);
            }

        }
        Insert componentList;
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, testContact.Id, schlYear.Id, True);
        hed__Program_Enrollment__c progEnrollment1 = Peak_TestUtils.createProgramEnrollment(academicAccountTest.Id, testContact.Id, schlYear.Id, True);
        List<Opportunity> optyList = new List<Opportunity>();
        for (Integer i = 0; i < 20; i++) {
            Opportunity optyTest1 = Peak_TestUtils.createOpportunity('oldOpty' + i, accountTest1.Id, System.Today(), 'closed Lost', False);
            optyTest1.Program_Enrollment__c = progEnrollment.Id;
            optyList.add(optyTest1);
        }
        Insert optyList;


    }
    /**
     * Created By Anand
     * Purpose : To  Test  the  NES_Batch_UpdateHardStopTimeCons Batch Class
     */
    static testMethod void testBatchUpdateHardStopTimeContraint() {
        Account accountTest1 = [select Id,Enrollment_stop_date__c from Account WHERE Name = 'TestAcc1' LIMIT 1];
        Account accountTest2 = [select Id from Account WHERE Name = 'TestAcc2' LIMIT 1];
        List<Enrollment_Component_Affiliation__c> affiliationList = new List<Enrollment_Component_Affiliation__c>();

        hed__Program_Enrollment__c progEnrollmentTest1 = [Select Id FROM hed__Program_Enrollment__c WHERE hed__Account__c = :accountTest1.Id LIMIT 1];
        hed__Program_Enrollment__c progEnrollmentTest = [Select Id FROM hed__Program_Enrollment__c WHERE hed__Account__c = :accountTest2.Id LIMIT 1];
        Integer i = 0;
        for (Enrollment_Component__c component : [select Id,Confirmation_Form__c FROM Enrollment_Component__c]) {
            Enrollment_Component_Affiliation__c affiliationTest;
            if (component.Confirmation_Form__c) {
                affiliationTest  = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollmentTest1.Id, component.Id, false);

            } else {
                affiliationTest = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollmentTest.Id, component.Id, false);
            }
            affiliationTest.status__c = 'Exempt';
            affiliationList.add(affiliationTest);

        }
        Insert affiliationList;
        Test.startTest();

        NES_Batch_UpdateHardStopTimeConstraint obj = new NES_Batch_UpdateHardStopTimeConstraint();
        DataBase.executeBatch(obj);


        Test.stopTest();
        List<Enrollment_Component_Affiliation__c> affiliationsTest1 = [Select Id from Enrollment_Component_Affiliation__c Where Status__c = 'Time Expired'];
        System.assertEquals(26, affiliationsTest1.Size());

        for (Opportunity opp : [select Id,StageName From Opportunity Where Program_Enrollment__c IN (Select Id from hed__Program_Enrollment__c)]) {
            System.assertEquals('Closed Lost', opp.StageName);
        }


    }



}