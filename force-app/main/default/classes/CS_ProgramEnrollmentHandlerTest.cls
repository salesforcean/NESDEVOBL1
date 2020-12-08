/***
* 
    @author: Kamalakar suddala (Ness Tech)
    * Created this test class on 07/04/2020 for [US 162232]
    * Test coverage for 
        =>CS_ProgramEnrollmentHandler

Change Log: 30-Apr-2020 Sumanth B 
			Added PermissionSetAssignment records to increase the code coverage

			2020-May-15 : Sumanth B : Inactivated as its moved to Batch Job as per US # 176990 (Task # 177185)  

*/
@isTest
public class CS_ProgramEnrollmentHandlerTest {
/*    
@TestSetup
    public static void createTestData(){
            Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
            Id recordTypeIdAP  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
          //  Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
            Id recordTypeIdHH  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();                              
      
        UserRole r=[Select Id from UserRole where name ='Pearson Community Role'];
        User u=new User(username='teste123@pearson.com.admin',
                        UserRoleId=r.Id,
                        alias = 'adminn',
                        timezonesidkey='America/Los_Angeles',
                        languagelocalekey='en_US',
                        localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                        profileId=UserInfo.getProfileId(),lastname='admin',email='test123@pearson.com.admin');
        
        insert u;
        System.runAs(u) 
        {
            Account ac = new Account(name ='TNCA',recordtypeId = recordTypeIdEI) ; //School
            insert ac; 
        	Account School1 = new Account(name ='Arizona Connections Academy',recordtypeId = recordTypeIdEI) ; //School
            insert School1; 
            Account ac1 = new Account(name ='TNCA 2019-2020',recordtypeId = recordTypeIdAP,ParentId=ac.id,Too_Young_Cutoff__c=system.today()) ; // Program
            insert ac1;
			Account ap = new Account(name ='ATS 2019-2020',recordtypeId = recordTypeIdAP,ParentId=School1.id,Too_Young_Cutoff__c=system.today()) ; // Program
            insert ap;
        
        	Account ac2 = new Account(name ='HouseHoldAcc',recordtypeId = recordTypeIdHH) ; // Household
            insert ac2;
        
            Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
            Contact CTcon = new Contact(LastName ='CTContact',AccountId = ac2.Id,recordtypeId=recordTypeIdCT); 
            insert CTcon;
        
            Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
            Contact STcon = new Contact(LastName ='StdContact',AccountId = ac2.Id,Caretaker_Id__c=CTcon.id,recordtypeId=recordTypeIdSTD); 
            insert STcon;   
        
            Contact STcon2 = new Contact(LastName ='StdContact2',AccountId = ac2.Id,Caretaker_Id__c=CTcon.id,recordtypeId=recordTypeIdSTD); 
            insert STcon2;   
        
       		Contact STcon3 = new Contact(LastName ='StdContact3',AccountId = ac2.Id,Caretaker_Id__c=CTcon.id,recordtypeId=recordTypeIdSTD); 
            insert STcon3; 	
           
        	PermissionSet CT_PS = [Select id from permissionset Where name ='TNCA_CT'];
            PermissionSet STD_PS = [Select id from permissionset Where name ='TNCA_STD'];
        
        	PermissionSet CT_PS2 = [Select id from permissionset Where name ='ACA_CT'];
        	PermissionSet STD_PS2 = [Select id from permissionset Where name ='ACA_STD'];
        
        
        	//Inserting Caretaker User
        //	Id Role = [Select id, name from UserRole where name ='Pearson Community Role'].id;
            Id p = [select id from profile where name='Caretaker Community User'].id;
            User CTUser=new User(username='CTUser@pearson.com1',
            alias = 'ctusr',//UserRoleId =Role,
            timezonesidkey='America/Los_Angeles',
            languagelocalekey='en_US',
            localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
            profileId=p,lastname='CTUser',email='CTUser@pearson.com1',contactId=CTcon.id);
            insert CTUser;
        	
            CTcon.Commuity_User__c = CTUser.id;
            update CTcon;
       	    system.debug('CTcon--> : '+CTcon.Commuity_User__c +' '+CTcon.Name); 
        
        	List<Contact> conRec = [Select id from Contact where LastName ='StdContact'];
            Id p2 = [select id from profile where name='Student Community User'].id;
            //Inserting Student User
            User STDUser=new User(username='STDUser@pearson.com',
                        alias = 'stUsr',
                        timezonesidkey='America/Los_Angeles',
                        languagelocalekey='en_US',
                        localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                        profileId=p2,lastname='STDUser',email='STDUser@pearson.com',ContactId=conRec.get(0).id);
            insert STDUser;
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = STDUser.id;
            psa.PermissionSetId = STD_PS.id;
            insert psa;
        }
        }*/

      
    public static testMethod void associatePermSetTest(){
        	/*
            List<Contact> conRec = [Select id,Caretaker_Id__c from Contact where LastName in ('StdContact','StdContact2','StdContact3')];
            List<Account> acRec = [Select id,name from Account where name  in ('TNCA 2019-2020','ATS 2019-2020')];
        
            List<hed__Program_Enrollment__c> peAdd=new List<hed__Program_Enrollment__c>();
        	List<hed__Program_Enrollment__c> peAdd2=new List<hed__Program_Enrollment__c>();
            School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());

        	hed__Program_Enrollment__c ProgramEnrollmentTest = new hed__Program_Enrollment__c();
            ProgramEnrollmentTest.School_Id__c = schlYear.Id;
        	ProgramEnrollmentTest.hed__Contact__c = conRec.get(0).Id;
        	ProgramEnrollmentTest.hed__Account__c = acRec.get(0).id;                   	
        	peAdd.add(ProgramEnrollmentTest);
        	Insert peAdd;

        	Test.startTest();
        	for(hed__Program_Enrollment__c peRec : [select hed__Contact__c,hed__Contact__r.Caretaker_Id__c,hed__Contact__r.Caretaker_Id__r.Name,
                                             hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,
                                             hed__Account__r.Parent.Name from hed__Program_Enrollment__c 
                                                    where hed__Contact__r.Caretaker_Id__c =: conRec.get(0).Caretaker_Id__c])
            {
	       // 	peRec.Status__c = 'Complete';
                peAdd2.add(peRec);
            }
            peAdd2.get(0).Status__c = 'Complete';
        	update peAdd2;
             	
        	hed__Program_Enrollment__c ProgramEnrollmentTest2 = new hed__Program_Enrollment__c();
            ProgramEnrollmentTest2.School_Id__c = schlYear.Id;
        	ProgramEnrollmentTest2.hed__Contact__c = conRec.get(1).Id;
        	ProgramEnrollmentTest2.hed__Account__c = acRec.get(0).id;                   	
        	peAdd.add(ProgramEnrollmentTest2);
        
        	hed__Program_Enrollment__c ProgramEnrollmentTest3 = new hed__Program_Enrollment__c();
            ProgramEnrollmentTest3.School_Id__c = schlYear.Id;
        	ProgramEnrollmentTest3.hed__Contact__c = conRec.get(2).Id;
        	ProgramEnrollmentTest3.hed__Account__c = acRec.get(1).id;                   	
        	peAdd.add(ProgramEnrollmentTest3);
        	Upsert peAdd; 
        	
        	List<hed__Program_Enrollment__c> peRemove=new List<hed__Program_Enrollment__c>();                     	              	
            for(hed__Program_Enrollment__c peRecord : [Select id,hed__Contact__c,hed__Contact__r.Caretaker_Id__c,
                                                       hed__Contact__r.Caretaker_Id__r.Name,
                                             		   hed__Contact__r.Caretaker_Id__r.Commuity_User__r.id,
                                            		   hed__Account__r.Parent.Name from 
                                                       hed__Program_Enrollment__c 
                                                       where hed__Contact__r.Caretaker_Id__c =: conRec.get(0).Caretaker_Id__c])
            {    
                peRecord.Status__c='Withdrawn';
                peRemove.add(peRecord);
            }
            Update peRemove;  
            Test.StopTest(); 
       */ }
      
}