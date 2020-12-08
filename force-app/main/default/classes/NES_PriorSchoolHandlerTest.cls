/**
 * Created by ajith on 13/12/18.
 */
@isTest
public class NES_PriorSchoolHandlerTest {

    @TestSetup
    static void setup(){

        Peak_TestUtils.createNESBusinessLogicSwitch('Last School Type and State', true);

        Account account = Peak_TestUtils.createTestAccount();

        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,schoolYear.Id);

        hed__Program_Enrollment__c programEnrollmentRec = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id, schoolYear.Id, true);

    }

    static testMethod void unitTestPositiveCases(){
        Test.startTest();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, Start_Year__c FROM hed__Program_Enrollment__c LIMIT 1];
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c LIMIT 1];

        Prior_School__c pSchool = Peak_TestUtils.createPriorSchool(programEnrollment.Id, schoolYear.Id, false);
        pSchool.State__c = 'AA';
        pSchool.SchoolType__c = 'Homeschool';

        insert pSchool;

        pSchool.SchoolType__c = 'Public School';
        update pSchool;

        hed__Program_Enrollment__c programEnrollment1 = [SELECT Id, Start_Year__c,LastSchoolState__c,LastSchoolType__c FROM hed__Program_Enrollment__c LIMIT 1];
        System.assertEquals(pSchool.State__c,programEnrollment1.LastSchoolState__c);
        System.assertEquals(pSchool.SchoolType__c,programEnrollment1.LastSchoolType__c);
        pSchool.State__c = 'AE';
        update pSchool;

        
        hed__Program_Enrollment__c programEnrollment2 = [SELECT Id, Start_Year__c,LastSchoolState__c,LastSchoolType__c FROM hed__Program_Enrollment__c LIMIT 1];
        System.assertEquals(pSchool.State__c,programEnrollment2.LastSchoolState__c);
        Test.stopTest();
    }

}