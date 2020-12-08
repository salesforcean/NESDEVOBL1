/***************************************************************************************************************************************
* Name: NES_ContactHandler_TEST
****************************************************************************************************************************************
* Author: Ranjit Chaganti
* Purpose: This is a Test class NES_ContactHandler (US#123101, Task # 159001).
* Created Date: 03/27/2020
****************************************************************************************************************************************
* <Modification History>
* <initials> - <date> - <reason for update>
*                     - <what was changed/added>
***************************************************************************************************************************************/

@isTest
private class NES_ContactHandler_TEST {
    
    @TestSetup
    private static void createData(){
        Id p = [select id from profile where name='School Staff Community User'].id;
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Account institutionAccount1 = Peak_TestUtils.createEducationalInstitutionAccount();
        institutionAccount1.name = 'TNCA';
        update institutionAccount1;
        NES_LogicFeatureSwitch__c necLogic = new NES_LogicFeatureSwitch__c(name='ContactTrigger',Active__c=true);
        insert necLogic;
        NES_LogicFeatureSwitch__c necLogic1 = new NES_LogicFeatureSwitch__c(name='Entrance Age Eligibility Calculation',Active__c=true);
        insert necLogic1;
        Contact con = new Contact(FirstName = 'test',LastName = 'test',AccountId = institutionAccount1.Id,Birthdate__c = System.today());        
        con.Gender_Selector__c = 'Male';
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was bullied';
        insert con;
        PermissionSet ps = [Select id from permissionset Where name ='TNCA_SSTF'];
        
        User user = new User(alias = 'SSFT', email='test123@pearson.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='teste123@pearson.com');       
            insert user; 
        system.runAs(user){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =ps.id ,
                                                                                       AssigneeId = user.Id);   
            insert psa;
        }
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
    }
    static TestMethod void updatePS(){
        Account acc= [Select id,Name from account limit 1];
        acc.Name ='ACA';
        update acc;
        Contact con = [Select id,AccountId from contact limit 1];
        con.AccountId =acc.id;
        update con;
    }
    static testMethod void calculatePlacementTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];         
        con.Birthdate__c = System.today();
        con.Gender_Selector__c = 'Male';
        Test.startTest();
        update con;
        Test.stopTest();

    } 
    static testMethod void deleteContactTest(){
        Account institutionAccount1 = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact con = new Contact(FirstName = 'test',LastName = 'test',AccountId = institutionAccount1.Id,Birthdate__c = System.today());   
        insert con;
        delete con;
        undelete con;
    } 
}