/*
* Created by:  Swapna
* Created date: 
* User Story : 
* Purpose: 
* Test Class:  DuplicateRecordLogicTest
*
* Change Log: 
*  Sumanth: 21-09-2020: Added the method: dupRecLogicChatTranscriptTest to cover the Lead->Chat Transcripts association to
*     respective Contact record in the case of Lead-Contact Merger for Bug # 222395 
*  Rakesh: 22-03-2021: Added (3) methods namely 'dupRecLogicExceptionTest()', 'dupRecLogicTestWhenLeadOwnerIsUser()' and 'dupRecLogicTestWhenLeadOwnerIsNotUser()' to ensure the scenario
*         around the Queue ID is skipped and only the User ID from Lead Owner field is stamped into the FEC field on the Account object, which is a look-up to the user.
*/

@isTest
public class DuplicateRecordLogicTest{
private static Peak_ApexLog logger = new Peak_ApexLog('DuplicateRecordLogicTest');
// User Story #. 342603    
// Related Defect #. 349734
// Test Method Added By Rakesh Ramaswamy
// Description - The intention behind this method is to code cover the catch-exception block of code present in the DuplicateRecordLogic class' method named dupRecLogic().
 @isTest
 public static void dupRecLogicExceptionTest(){

    // The following custom setting managed record is necessary for ensuring the Peak Apex Log records get created from a test class execution perspective.
    Peak_Apex_Log_Persona_Manager__c personaManager = new Peak_Apex_Log_Persona_Manager__c (Log_Level__c=1);
    insert personaManager;

    DuplicateRecordLogic.dupRecLogic(null);
    // Assert check to determine whether an Apex Exception Log got created or not.
    system.assertNotEquals(0,[SELECT Id, Name FROM Peak_Apex_Log__c].size());
 }

@isTest
public static void dupRecLogicTest(){
Test.startTest();
CS_TestDataFactory testDataFactoryObj = new CS_TestDataFactory();
List<Lead> llst = new List<Lead>();
list<DuplicateRecordSet> dupRecSetList = new list<DuplicateRecordSet>();

// The following custom setting managed record is necessary for ensuring the Peak Apex Log records get created from a test class execution perspective.
Peak_Apex_Log_Persona_Manager__c personaManager = new Peak_Apex_Log_Persona_Manager__c (Log_Level__c=1);
insert personaManager;

for(Integer i = 0;i <= 2;i++)
{
    Lead l1 = new Lead();
    l1.FirstName = 'Test';
    l1.LastName = 'Test';
    l1.Email = 'test@test.com';
    l1.Company = 'Test';
    l1.OwnerId = UserInfo.getUserId();
    l1.Parent_Lead__c = null;
    llst.add(l1);
}
insert llst;
    
Id HHAcctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
Account acct = testDataFactoryObj.createNewAccount('Test Household', HHAcctRecTypeId, null, Date.Today(), null);
acct.Family_Enrollment_Counselor__c = null;
insert acct;

Id CTConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
Contact c = testDataFactoryObj.createNewContact('Test', CTConRecTypeId, acct.Id, null);
c.FirstName ='Test';    
c.Email = 'test@test.com';    
insert c;
    
DuplicateRule duprl =[select Id from DuplicateRule where MasterLabel ='Lead to Lead'];

DuplicateRecordSet d = new DuplicateRecordSet();
d.DuplicateRuleId = duprl.Id;
insert d;

List<DuplicateRecordItem> dris = new List<DuplicateRecordItem>();

for(Lead l:llst)
{
    DuplicateRecordItem dri = new DuplicateRecordItem();
    dri.RecordId = l.Id;
    dri.DuplicateRecordSetId = d.Id;    
    dris.add(dri);
}

upsert dris;

List<Id> drs = new List<Id>();
drs.add(d.Id);

DuplicateRecordLogic.dupRecLogic(drs); 
// Assert check here to determine how many leads exist with the same name in text method context at the end of identifying duplicate leads.
// There should be only one Lead record at the end of the duplicate detection of presence of more leads with same Name, Email, Phone.
system.assertEquals(1, [SELECT Id, Name FROM Lead WHERE Email = 'test@test.com'].size());

// Assert check to determine whether an Apex Exception Log got created or not.
system.assertEquals(0, [SELECT Id, Name FROM Peak_Apex_Log__c].size());
Test.stopTest();
}

// User Story #. 342603    
// Related Defect #. 349734
// Test Method Added By Rakesh Ramaswamy
// Description - To resolve the Contact-Lead Duplicate Merge Logic that was happening due to Queue ID(s) getting stamped onto the FEC Lookup on Account to the User table.
@isTest
public static void dupRecLogicTestWhenLeadOwnerIsUser()
{
    Test.startTest();
    CS_TestDataFactory testDataFactoryObj = new CS_TestDataFactory();

    // The following custom setting managed record is necessary for ensuring the Peak Apex Log records get created from a test class execution perspective.
    Peak_Apex_Log_Persona_Manager__c personaManager = new Peak_Apex_Log_Persona_Manager__c (Log_Level__c=1);
    insert personaManager;

    Lead l = new Lead();
    l.FirstName = 'Test';
    l.LastName = 'Test';
    l.Email = 'test@test.com';    
    l.Company = 'Test';
    l.OwnerId = UserInfo.getUserId();
    insert l;

    Id HHAcctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Account acct = testDataFactoryObj.createNewAccount('Test Household', HHAcctRecTypeId, null, Date.Today(), null);
    insert acct;

    Id CTConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
    Contact c = testDataFactoryObj.createNewContact('Test', CTConRecTypeId, acct.Id, null);
    c.FirstName ='Test';    
    c.Email = 'test@test.com';    
    insert c;
       
    DuplicateRule duprl = [select Id from DuplicateRule where MasterLabel ='Contact to Lead'];
    DuplicateRecordSet d = new DuplicateRecordSet();
    d.DuplicateRuleId = duprl.Id;
    insert d;
    
    DuplicateRecordItem dri = new DuplicateRecordItem();       
    dri.RecordId = l.Id;
    dri.DuplicateRecordSetId = d.Id;    
    insert dri;
    
    DuplicateRecordItem drc = new DuplicateRecordItem();
    drc.RecordId = c.Id;
    drc.DuplicateRecordSetId = d.Id;
    insert drc;
    
    List<DuplicateRecordSet> dr = [select Id from DuplicateRecordSet];
    List<Id> drs = new List<Id>();
    
    for(DuplicaterecordSet rec: dr){
    	drs.add(rec.Id);
    }
    
    DuplicateRecordLogic.dupRecLogic(drs);
    // Assertion to ascertain that FEC Lookup(User) field on the HH Account is same as the User who is the Lead Owner..
    // We need to explicitly query here to fetch the HH Account from the DB based on which we can assert for the FEC value held by it.
    Account accnt = [SELECT Id, Family_Enrollment_Counselor__c, Name FROM Account WHERE Id = :acct.Id];
    system.assertEquals(l.OwnerId, accnt.Family_Enrollment_Counselor__c);
    // Assert check to determine whether an Apex Exception Log got created or not.
    system.assertEquals(0, [SELECT Id, Name FROM Peak_Apex_Log__c].size());
    Test.stopTest();
} 

// User Story #. 342603    
// Related Defect #. 349734
// Test Method Added By Rakesh Ramaswamy
// Description - To resolve the Contact-Lead Duplicate Merge Logic that was happening due to Queue ID(s) getting stamped onto the FEC Lookup on Account to the User table.
@isTest
public static void dupRecLogicTestWhenLeadOwnerIsNotUser()
{    
    Test.startTest();
    CS_TestDataFactory testDataFactoryObj = new CS_TestDataFactory();

    // The following custom setting managed record is necessary for ensuring the Peak Apex Log records get created from a test class execution perspective.
    Peak_Apex_Log_Persona_Manager__c personaManager = new Peak_Apex_Log_Persona_Manager__c (Log_Level__c=1);
    insert personaManager;
  
    Group leadGroup = [SELECT ID, Type, RelatedId, Name FROM Group WHERE DeveloperName LIKE '%Lead%' LIMIT 1];

    DuplicateRule duprl =[select Id from DuplicateRule where MasterLabel ='Contact to Lead'];
    DuplicateRecordSet d = new DuplicateRecordSet();
    d.DuplicateRuleId = duprl.Id;
    insert d;
    
    Id HHAcctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Account account = testDataFactoryObj.createNewAccount('Test Household', HHAcctRecTypeId, null, Date.Today(), null);
    insert account; 
    
    Lead l = new Lead();
    l.FirstName = 'Test';
    l.LastName = 'Test';
    l.Email = 'test@test.com';
    l.Company = 'Test';
    l.OwnerId = leadGroup.Id;
    insert l;

    Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
    Contact c = testDataFactoryObj.createNewContact('Caretaker', recordTypeIdCT, account.Id, null);    
    c.FirstName ='Test';    
    c.Email = 'test@test.com'; 
    insert c;
           
    DuplicateRecordItem dri = new DuplicateRecordItem();       
    dri.RecordId = l.Id;
    dri.DuplicateRecordSetId = d.Id;           
    insert dri;

    DuplicateRecordItem drc = new DuplicateRecordItem();
    drc.RecordId =c.Id;
    drc.DuplicateRecordSetId = d.Id;
    insert drc;
    
    List<DuplicateRecordSet> dr = [select Id from DuplicateRecordSet];
    List<Id> drs = new List<Id>();

    for(DuplicaterecordSet rec: dr){
    	drs.add(rec.Id);
    }
    
    DuplicateRecordLogic.dupRecLogic(drs);  
    // Assertion to ascertain that FEC Lookup(User) field on the HH Account is blank.
    system.assertEquals(null, account.Family_Enrollment_Counselor__c);    
    // Assert check to determine whether an Apex Exception Log got created or not.
    system.assertEquals(0, [SELECT Id, Name FROM Peak_Apex_Log__c].size());
    Test.stopTest();
}


@isTest
public static void dupRecLogicChatTranscriptTest()
    {
        // The following custom setting managed record is necessary for ensuring the Peak Apex Log records get created from a test class execution perspective.
        Peak_Apex_Log_Persona_Manager__c personaManager = new Peak_Apex_Log_Persona_Manager__c (Log_Level__c=1);
        insert personaManager;

        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
        UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        Profile AdminProfile = [select id,name from Profile where name ='System Administrator'];
		Organization OrgDetails = [select name,id from Organization LIMIT 1];
      
        Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CS_Constants.ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION).getRecordTypeId();
        Account TNCASchool = factoryObj.createNewAccount('TNCA',recordTypeIdEI,null,null,null);   
        insert TNCASchool;
        
        Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();
        Contact c = new Contact();
        c.RecordTypeId = recordTypeIdCT;
        c.FirstName ='Test1';
        c.LastName = 'Test2';
        c.Email = 'test1@pearson.com';
        c.Phone = '9876543210';
        c.MobilePhone = '9876543210';
        c.AccountId = TNCASchool.Id;
        insert c;
        
        Lead l = new Lead();
        l.FirstName = 'Test1';
        l.LastName = 'Test2';
        l.Email = 'test1@pearson.com';
        l.Phone = '9876543210';
        l.Company = 'TestCompany';
        insert l;
        
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        
        LiveChatTranscript Chat = new LiveChatTranscript();
        Chat.LeadId = l.id;
        Chat.StartTime = system.now();
        Chat.EndTime = system.now();
        Chat.LiveChatVisitorId = chatVisitor.id;
        insert Chat;
        
        Test.startTest();
        List<Lead> ls = [select Id from Lead where FirstName='Test1' and LastName = 'Test2'];
        DuplicateRule duprl =[select Id from DuplicateRule where MasterLabel ='Contact to Lead'];
        DuplicateRecordSet d = new DuplicateRecordSet();
        d.DuplicateRuleId = duprl.Id;
        insert d;
        
        DuplicateRecordItem dri = new DuplicateRecordItem();
        List<DuplicateRecordItem> dris = new List<DuplicateRecordItem>();
        for(Lead ld:ls)
        {
            dri.RecordId =ld.Id;
            dri.DuplicateRecordSetId = d.Id;
            dris.add(dri);
        }
        
        DuplicateRecordItem drc = new DuplicateRecordItem();
        drc.RecordId =c.Id;
        drc.DuplicateRecordSetId = d.Id;
        dris.add(drc);
        insert dris;
        
        List<DuplicateRecordSet> dr = [select Id from DuplicateRecordSet order by CreatedDate desc];
        List<Id> drs = new List<Id>();
        for(DuplicaterecordSet rec: dr){
            drs.add(rec.Id);
        }
        DuplicateRecordLogic.dupRecLogic(drs);
        LiveChatTranscript ChatTrans = [select id,name,ContactId,LeadId from LiveChatTranscript where id =: Chat.id];
        system.assertEquals(c.id, ChatTrans.ContactId);
        // Assert check to determine whether an Apex Exception Log got created or not.
        system.assertEquals(0, [SELECT Id, Name FROM Peak_Apex_Log__c].size());
        Test.stopTest();
    } 
}