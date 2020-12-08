/*
* Created by:  Swapna
* Created date: 
* User Story : 
* Purpose: 
* Test Class:  DuplicateRecordLogicTest
*
* Change Log: 
*  Sumanth:21-09-2020: Added the method: dupRecLogicChatTranscriptTest to cover the Lead->Chat Transcripts association to
*     respective Contact record in the case of Lead-Contact Merger for Bug # 222395 
*/

@isTest
public class DuplicateRecordLogicTest{

@isTest
public static void dupRecLogicTest(){
Test.startTest();
//Lead l1 = new Lead();
//List<Lead> llst = new List<Lead>();
for(Integer i =0;i<=2;i++)
{
    Lead l1 = new Lead();
l1.FirstName = 'Test';
l1.LastName = 'Test';
l1.Email = 'test@test.com';
l1.Company = 'Test';
    insert l1;
//llst.add(l1);
}
//insert llst;
Account account = Peak_TestUtils.createTestAccount();
Contact c = Peak_TestUtils.createTestContact('Students', account.Id);

c.FirstName ='Test';
c.LastName = 'Test';
c.Email = 'test@test.com';

update c;
List<Lead> ls = [select Id from Lead where FirstName='Test'];
DuplicateRule duprl =[select Id from DuplicateRule where MasterLabel ='Lead to Lead'];
DuplicateRecordSet d = new DuplicateRecordSet();
d.DuplicateRuleId = duprl.Id;
insert d;
//DuplicateRecordItem dri = new DuplicateRecordItem();
//List<DuplicateRecordItem> dris = new List<DuplicateRecordItem>();
for(Lead l:ls)
{
DuplicateRecordItem dri = new DuplicateRecordItem();
dri.RecordId =l.Id;
dri.DuplicateRecordSetId = d.Id;
    insert dri;
//dris.add(dri);
}
//insert dris;
List<DuplicateRecordSet> dr = [select Id from DuplicateRecordSet];
List<Id> drs = new List<Id>();
for(DuplicaterecordSet rec: dr){
drs.add(rec.Id);
}

DuplicateRecordLogic.dupRecLogic(drs);



Test.stopTest();
}

@isTest
Public static void dupRecLogicTest1()
{
Test.startTest();
//for(Integer i =0;i<=2;i++)
//{
Lead l = new Lead();
l.FirstName = 'Test';
l.LastName = 'Test';
l.Email = 'test@test.com';
l.Company = 'Test';
insert l;
//}
Account account = Peak_TestUtils.createTestAccount();
Contact c = Peak_TestUtils.createTestContact('Caretaker', account.Id);

c.FirstName ='Test';
c.LastName = 'Test';
c.Email = 'test@test.com';

update c;
List<Lead> ls = [select Id from Lead where FirstName='Test'];
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
    insert dris;
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




Test.stopTest();

}

    @isTest
    public static void dupRecLogicChatTranscriptTest()
    {
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
        UserRole usrRole = factoryObj.fetchUserRole('Pearson Community Role');
        Profile AdminProfile = [select id,name from Profile where name ='System Administrator'];
		Organization OrgDetails = [select name,id from Organization LIMIT 1];
        User AdminUsr = factoryObj.createNewUser('Admn11'+OrgDetails.Id+'@pearson.com', usrRole.Id, 'bAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', AdminProfile.id,'LastName','Admn11'+OrgDetails.Id+'@pearson.com');
        insert AdminUsr;  
        
        System.runAs(AdminUsr)
        {
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
            Test.stopTest();
		}
    }
}