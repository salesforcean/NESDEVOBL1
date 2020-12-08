/**
 * Created by Ritvik on 26-12-2018.
 */

@IsTest
private class NES_ApplicationSummaryTest {
    @TestSetup
    static void setup() {
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, true);
    }

    static testMethod void setFinalConfirmationViewed_Test(){
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id,Viewed_Final_Confirmation__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id];
        Test.startTest();
        NES_ApplicationSummary.setFinalConfirmationViewed(programEnrollment);
        hed__Program_Enrollment__c programEnrollmentRecord = [SELECT Id,Viewed_Final_Confirmation__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id];
        Test.stopTest();
        System.assertEquals(true,programEnrollmentRecord.Viewed_Final_Confirmation__c);
    }

    static testMethod void getSuccessfulEnrollmentMessage_Test(){
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        hed__Program_Enrollment__c programEnrollment = [SELECT Id,Viewed_Final_Confirmation__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id];
        Test.startTest();
        System.assertEquals('Confirmed...',NES_ApplicationSummary.getSuccessfulEnrollmentMessage(programEnrollment));
        Test.stopTest();
    }
}