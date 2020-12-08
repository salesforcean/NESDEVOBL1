/*
*   Class Name: NES_ExperianIntegrationTest
*   Description: Test class for NES_ExperianIntegration
*
*   Date          New/Modified     User
*   11/22/2018    New        	  Akhilesh Kumar
*   12/5/208      Modified       S.Anand
*
*/
@isTest
private class NES_ExperianIntegrationTest {

	/*@TestSetup
	static void setup() {
		Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();

		Contact TestContact = Peak_TestUtils.createTestContact();
		School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
		Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);

		School_Year__c pSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));

		hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,pSchoolYear.Id, false);
		insert progEnrollment;


		// Create a Enrollment Components with different record type
		List<Enrollment_Component__c> componentList = new List<Enrollment_Component__c>();
		Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Question', false);
		questionComponent.API_Mapping__c = 'country';
		Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Section', false);
		componentList.add(sectionComponent);
		componentList.add(questionComponent);
		insert componentList;

		// create Enrollment Component Relationships
		Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);

		// create Enrollment Component Affiliations with different parent Enrollment Components.
		List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
		Enrollment_Component_Affiliation__c affiliationQuestion = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, questionComponent.Id, false);
		affiliationQuestion.Status__c = 'In Progress';
		enrollmentComponentAffiliations.add(affiliationQuestion);

		insert enrollmentComponentAffiliations;


	}*/

	static testMethod void searchAddressTest() {

		Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());

		String response = NES_ExperianIntegration.searchAddress('1600 Pennsylvania Ave');
        System.debug('response>>>>>>>>>>>'+response);
		System.assert(true,response != null); 
		// create custom setting record
		Address_Search_Settings__c addressSearchRec=Peak_TestUtils.createAddressSearchSettings(123,456);
		// calling getSearchSettings function
		Address_Search_Settings__c customSettingRec = NES_ExperianIntegration.getSearchSettings();
		system.assert(true, customSettingRec!= null);
	}

    static testMethod void getFormattedAddressTest() {
        String sampleId ='d29eee21-95c5-46be-b5bd-4e0e48a1de7b_U40_24_0_0_0%3D103%24QL3%24GEO0';
		Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());

		String response = NES_ExperianIntegration.getFormattedAddress(sampleId);
		System.assert(true,response != null);
		// create custom setting record
		Address_Search_Settings__c addressSearchRec=Peak_TestUtils.createAddressSearchSettings(123,456);
		// calling getSearchSettings function
		Address_Search_Settings__c customSettingRec = NES_ExperianIntegration.getSearchSettings();
		system.assert(true, customSettingRec!= null);
	}

	static testMethod void saveAddressFieldsTest(){
        
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();

		Contact TestContact = Peak_TestUtils.createTestContact();
		School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
		Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);

		School_Year__c pSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));

		hed__Program_Enrollment__c programEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,pSchoolYear.Id, false);
		insert programEnrollment;
        
        Enrollment_Component__c groupId = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Section', false);
        
		
		List<NES_ExperianIntegration.AddressData> addressData = new List<NES_ExperianIntegration.AddressData>();
		NES_ExperianIntegration.AddressData wrapData = new NES_ExperianIntegration.AddressData();
		wrapData.addressLine1 = 'Test Address One';
		wrapData.addressLine2 = 'Test Addr Two';
		wrapData.addressLine3 = 'Test Addr Three';
		wrapData.postalCode = '123456';
		wrapData.locality = 'Test';
		wrapData.province = 'Province Test';
		wrapData.country = 'USA';
		addressData.add(wrapData);
		String JSONString = JSON.serialize(addressData);
		Test.startTest();
		NES_ExperianIntegration.getQuestions(groupId.Id, programEnrollment.Id);
		NES_ExperianIntegration.saveAddressFields(groupId.Id, programEnrollment.Id, JSONString, true);
		Test.stopTest();
	}
}