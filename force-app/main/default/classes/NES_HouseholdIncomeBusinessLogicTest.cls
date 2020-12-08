/**
 * Created by Raju on 19-12-2018.
 * Purpose : Test class for HouseholdIncomeBusinessLogic apex class.
 */
@isTest
public class NES_HouseholdIncomeBusinessLogicTest {
    @TestSetup
    static void setup(){

        Peak_TestUtils.createNESBusinessLogicSwitch('Federal Poverty Eligibility', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Total Gross HH Income', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('HH Income Foster Child', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2019-2020',System.today());
        system.debug('current sy ' + currentSchoolYear.Name);

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
		Contact contact1 = Peak_TestUtils.createTestContact('Caretaker', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        system.debug('1 ' + academicProgramAccount);

        hed__Program_Enrollment__c progEnrollmentWithoutStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentWithoutStatus.Status__c = 'Time Expired';
        insert progEnrollmentWithoutStatus;
        system.debug('1 ' + progEnrollmentWithoutStatus);

        hed__Program_Enrollment__c progEnrollmentWithStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentWithStatus.Status__c = 'In Progress';
        insert progEnrollmentWithStatus;
        hed__Program_Enrollment__c progEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentTest.ELLFlag__c='Potential';
        Insert progEnrollmentTest;
		
    }
   
    static testMethod void AfterInsertTestScenarioOne(){

        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'Time Expired' limit 1];
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2019-2020' limit 1];
        Annual_Household_Information__c currentAHI = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);
        Test.startTest();
        insert currentAHI;
        Annual_Household_Information__c householdRecord = [SELECT Id,Federal_Poverty_Eligibility__c FROM Annual_Household_Information__c WHERE Id=:currentAHI.Id]; System.debug('***'+householdRecord.Federal_Poverty_Eligibility__c);
        currentAHI.Total_Gross_HH_Income__c =10;
        update currentAHI;
        Annual_Household_Information__c householdRecordUpdated = [SELECT Id,Federal_Poverty_Eligibility__c FROM Annual_Household_Information__c WHERE Id=:currentAHI.Id];
        insert currentHI;
        currentHI.HHFosterChild__c='No';
        update currentHI;
        Test.stopTest();
    }

    static testMethod void UnitTestPositiveScenarios(){
        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2019-2020' limit 1];
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);
        currentHI.HHAdultIncome_1__c = 10;
        currentHI.Adult_Income_Received_1__c = 'yearly';
        currentHI.HHAdultIncome_2__c = 10;
        currentHI.Adult_Income_Received_2__c = 'yearly';
        currentHI.HHAdultIncome_3__c = 10;
        currentHI.Adult_Income_Received_3__c = 'yearly';
        Test.startTest();
        insert currentHI;
        System.debug('------->'+currentHI);
        programEnrollment.status__c = 'In Progress';
        update programEnrollment;
        currentHI.HHAdultIncome_1__c = 100;
        currentHI.Adult_Income_Received_1__c = 'monthly';
        currentHI.HHAdultIncome_2__c = 100;
        currentHI.Adult_Income_Received_2__c = 'monthly';
        currentHI.HHAdultIncome_3__c = 100;
        currentHI.Adult_Income_Received_3__c = 'monthly';
        update currentHI;
        System.debug('2------->'+currentHI);
        Test.stopTest();
        Annual_Household_Information__c householdRecord = [SELECT Id,Total_Gross_HH_Income__c FROM Annual_Household_Information__c];
        System.assertEquals(3600.00, householdRecord.Total_Gross_HH_Income__c);
    }

    /**
     * Created By : Anushka Bansal
     * Purpose : To Test calculateHHIncomeFosterChild method on Update
     */
    static testMethod void testUpdateCalculateHHIncomeFosterChild(){
        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'Time Expired' limit 1];
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2019-2020' limit 1];
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);

        Test.startTest();

        Test.stopTest();
    }

    /**
     * Created By : Anushka Bansal
     * Purpose : To Test calculateHHIncomeFosterChild method on Insert
     */
    static testMethod void testInsertCalculateHHIncomeFosterChild(){
        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'Time Expired' limit 1];
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2019-2020' limit 1];
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);
        currentHI.HHFosterChild__c = 'No';
        Test.startTest();
        insert currentHI;
        Test.stopTest();
    }
    
}