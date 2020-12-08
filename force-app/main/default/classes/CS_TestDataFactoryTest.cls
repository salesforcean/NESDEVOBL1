/***
* 
@author: Rakesh Ramaswamy (Ness Technologies)
* Created this test class on 07/29/2020 for [US 164369 / Pi-01 (Sprint-07) & Pi-02 (Sprint-01) identified.]
* This class will act as Unit Test Class for ensuring the TestDataFactory class code lines are code covered.
* The TestDataFactory class is a utility class to help create multiple test data records or single-instance records of different tables as per the data-model of the PEARSON Connexus Salesforce CRM.
* Test coverage for Test Data Factory class for the Pearson Connexus CRM system.
=> CS_TestDataFactory.cls
*
* Change Log:
* Sumanth:31 Aug 2020: Added programEnrollRecordWithRecordType for US # 216780
*
*/
@isTest
public class CS_TestDataFactoryTest {
        
    private static testMethod void testAllDataFactoryMethods(){
        CS_TestDataFactory testDataFactoryObj = new CS_TestDataFactory();
        
        UserRole userRoleObj = testDataFactoryObj.fetchUserRole('Pearson Community Role');
        list<School_Year__c> schoolYearList = new list<School_Year__c>();
        School_Year__c schoolYearObj = testDataFactoryObj.createSchoolYear(false, system.today()+5, system.today()-5, 'S77321');
        schoolYearList.add(schoolYearObj);
               
        Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT).getRecordTypeId();
        Id recordTypeIdLC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_LEARNING_COACH).getRecordTypeId();
        Profile LCCommunityProfile = [SELECT Id, Name from Profile WHERE Name='Learning Coach Community User'];
        
        list<Account> householdAccList = testDataFactoryObj.createListOfAccounts('HouseHoldAcc', recordTypeIdHH, null, null, schoolYearList.get(0).Id, 3) ; // Household
        insert householdAccList;
        list<Contact> LCHouseHold1ConList =  testDataFactoryObj.createListOfContacts('LCContact0', recordTypeIdLC, householdAccList.get(1).Id, null, 1);
        insert LCHouseHold1ConList;
        User portalUsr = testDataFactoryObj.createnewPortalUser('lcportalUser1@abc.com', 'lcpu1', 'America/Los_Angeles', 'en_US', 'en_US', 'UTF-8', 'United States', LCCommunityProfile.Id,'LCU1LastName','LCUser1@pearson.com',LCHouseHold1ConList.get(0).Id);
        
        UserRole usrRole = testDataFactoryObj.fetchUserRole('Pearson Community Role');
        User userRecord = testDataFactoryObj.createNewUser('teste123@pearson.com.admin', usrRole.Id, 'adminn', 'America/Los_Angeles', 
                                              'en_US', 'en_US', 'UTF-8', 'United States', UserInfo.getProfileId(), 
                                              'admin', 'test123@pearson.com.admin');
                                              
        Account acctRecord = testDataFactoryObj.createNewAccount('Pearson Account', recordTypeIdHH, null, system.today(), schoolYearList.get(0).Id);
        list<Account> pcxAcctsList = testDataFactoryObj.createListOfAccounts('Pearson Account', recordTypeIdHH, null, system.today()+1, schoolYearList.get(0).Id, 5);
        
        Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();       
        Contact LCContact = testDataFactoryObj.createNewContact('Pearson LC Contact', recordTypeIdLC, acctRecord.Id, null);
        Contact contactRecord = testDataFactoryObj.createNewContact('Pearson Contact', recordTypeIdSTD, acctRecord.Id, null);
        list<Contact> pcxContactsList = testDataFactoryObj.createListOfContacts('Pearson Contact', recordTypeIdSTD, acctRecord.Id, null, 6);
        
        hed__Relationship__c relationshipRecord = testDataFactoryObj.createNewRelationship(CS_Constants.RELATIONSHIP_FORMER_STATUS, contactRecord.Id, LCContact.Id, CS_Constants.LEARNING_COACH_TYPE);
        Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_ACADEMIC_PROGRAM).getRecordTypeId();
        Account programAccount = testDataFactoryObj.createNewAccount('Pearson Program', recordTypeIdAP, null, system.today(), schoolYearList.get(0).Id);
        hed__Program_Enrollment__c programEnrollRecord = testDataFactoryObj.createNewProgramEnrollment(contactRecord.Id, programAccount.Id, CS_Constants.PE_COMPLETE_STATUS);
        
       // Sumanth:31 Aug 2020: Added programEnrollRecordWithRecordType for US # 216780
        Id recordTypeIdPECaretaker  = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get(CS_Constants.PROGRAM_ENROLLMENT_CARETAKER).getRecordTypeId();
        hed__Program_Enrollment__c programEnrollRecordWithRecordType = testDataFactoryObj.createNewProgramEnrollmentWithRecordType(contactRecord.Id, programAccount.Id, CS_Constants.PE_COMPLETE_STATUS,recordTypeIdPECaretaker);
        
        list<hed__Program_Enrollment__c> programEnrollList = testDataFactoryObj.createListOfProgramEnrolls(contactRecord.Id, programAccount.Id, CS_Constants.PE_WITHDRAWN_STATUS, 4);
        
        PermissionSet permsetRecord = testDataFactoryObj.createPermissionSet('PEARSON Academic Union', 'PEARSON_Academic_Union');                
        
        // System Assert Checks for the different instances returned by the different methods in CS_TestDataFactory class.
        system.assertNotEquals(userRoleObj, null);
        system.assertEquals(householdAccList.size(), 3);
        system.assertEquals(LCHouseHold1ConList.size(), 1);
        system.assertNotEquals(LCCommunityProfile, null);
        system.assertNotEquals(portalUsr, null);
        system.assertNotEquals(usrRole, null);
        system.assertNotEquals(userRecord, null);
        system.assertNotEquals(acctRecord, null);
        system.assertNotEquals(pcxAcctsList, null);
        system.assertEquals(pcxAcctsList.size(), 5);
        system.assertNotEquals(contactRecord, null);
        system.assertNotEquals(pcxContactsList, null);
        system.assertEquals(pcxContactsList.size(), 6);
        system.assertNotEquals(relationshipRecord, null);
        system.assertNotEquals(recordTypeIdAP, null);
        system.assertNotEquals(programAccount, null);
        system.assertNotEquals(programEnrollRecord, null);
        system.assertNotEquals(programEnrollList, null);
        system.assertEquals(programEnrollList.size(), 4);
        system.assertNotEquals(permsetRecord, null);   
        system.assertNotEquals(programEnrollRecordWithRecordType, null);
    }
}