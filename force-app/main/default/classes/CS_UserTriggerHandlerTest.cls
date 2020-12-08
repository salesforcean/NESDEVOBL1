/***
* 
    @author: Mohammed Shaik (Ness Tech)
    * Created this test class on 26/03/2020 for [US 123096]
    * Test coverage for 
        => CS_UserTriggerHandler
 
  2020-May-15 : Sumanth B : Inactivated as its moved to Batch Job as per US # 176990 (Task # 177184)

*/

@isTest
public class CS_UserTriggerHandlerTest {
 /*   
    @TestSetup
    public static void createTestData(){
            Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
            Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
            Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();  
            
            Account ac = new Account(name ='TNCA',recordtypeId = recordTypeIdEI) ; //School
            insert ac; 
            Account ac1 = new Account(name ='TNCA 2019-2020',recordtypeId = recordTypeIdAP,ParentId=ac.id,Too_Young_Cutoff__c=system.today()) ; // Program
            insert ac1;
            Account ac2 = new Account(name ='HouseHoldAcc',recordtypeId = recordTypeIdHH) ; // Household
            insert ac2;
        
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
            Contact CTcon = new Contact(LastName ='CTContact',AccountId = ac2.Id,recordtypeId=recordTypeIdCT); 
            insert CTcon;
        
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
            Contact STcon = new Contact(LastName ='StdContact',AccountId = ac2.Id,Caretaker_Id__c=CTcon.id,recordtypeId=recordTypeIdSTD); 
            insert STcon;
        	
        	School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        	hed__Program_Enrollment__c ProgramEnrollmentTest = new hed__Program_Enrollment__c();
        	ProgramEnrollmentTest.School_Id__c = schlYear.Id;
        	ProgramEnrollmentTest.hed__Contact__c = STcon.Id;
        	ProgramEnrollmentTest.hed__Account__c = ac1.id;
        	ProgramEnrollmentTest.Status__c = 'Complete';
        	Insert ProgramEnrollmentTest;
            System.debug('PE Rec:' + ProgramEnrollmentTest);
        
            PermissionSet CT_PS = [Select id from permissionset Where name ='TNCA_CT'];
            PermissionSet STD_PS = [Select id from permissionset Where name ='TNCA_STD'];
            Id p = [select id from profile where name='Caretaker Community User'].id;
                        User CTUser=new User(username='CTUser@pearson.com',
                        alias = 'ctusr',
                        timezonesidkey='America/Los_Angeles',
                        languagelocalekey='en_US',
                        localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                        profileId=p,lastname='CTUser',email='CTUser@pearson.com',contactId=CTcon.id);
            insert CTUser;
       		 System.debug('CTUser Rec:' + CTUser);
        }*/
        Public static testMethod void associatePermSetTest(){
        /*	List<User> usr=new List<User>();
            List<Contact> conRec = [Select id from Contact where LastName ='StdContact'];
            Id p = [select id from profile where name='Student Community User'].id;
            System.debug('contact Rec:' + conRec);
            
            UserRole r=[Select Id from UserRole where name ='Pearson Community Role'];
        	User u=new User(username='testAdmin@pearson.com.admin',
                        UserRoleId=r.Id,
                        alias = 'adminn',
                        timezonesidkey='America/Los_Angeles',
                        languagelocalekey='en_US',
                        localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                        profileId=UserInfo.getProfileId(),lastname='admin',email='testAdmin@pearson.com.admin');
        
       		insert u;
            System.runAs(u) 
            {
                User STDUser=new User(username='STDUser@pearson.com',
                            alias = 'stUsr',
                            timezonesidkey='America/Los_Angeles',
                            languagelocalekey='en_US',
                            localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                            profileId=p,lastname='STDUser',email='STDUser@pearson.com',ContactId=conRec.get(0).id);
                usr.add(STDUser);
                Test.startTest();
                     insert usr;
                	 system.assertNotEquals(null, usr.get(0).id);
                Test.StopTest();
            }*/
        }
}