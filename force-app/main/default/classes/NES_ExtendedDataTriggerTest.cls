@isTest
private class NES_ExtendedDataTriggerTest {
	@TestSetup static void setup() {
		Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('CSY', System.today());
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);

        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, True);
        
	}
	@isTest static void test_method_one() {
		// Implement test code
		Test.startTest();
        	hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
		 	Extended_Data__c extendedData = new Extended_Data__c();
		 	extendedData.Name = 'Test';
		 	extendedData.Program_Enrollment__c = ProgramEnrollmentTest.Id;
		 	insert extendedData;
		 	extendedData.Name = 'Test1';
		 	update extendedData;
		Test.stopTest();
	}
}