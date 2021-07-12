@isTest
public class NES_AddHHMemApexControllerTest {
    
    @TestSetup
    static void setup(){
        CS_TestDataFactory factoryObj = new CS_TestDataFactory();
        UserRole usrRoles = factoryObj.fetchUserRole('Pearson Community Role');
        User STDUsr;
        String orgId = UserInfo.getOrganizationId();
        User usr = factoryObj.createNewUser('BAdmn11'+orgId+'@pearson.com', usrRoles.Id, 'bAdmin', 'America/Los_Angeles', 'en_US', 
                                            'en_US','UTF-8','United States', UserInfo.getProfileId(),'LastName','BAdmn11'+orgId+'@pearson.com');
        insert usr;  
        
        System.runAs(usr){
            
            //Create Educational Institutional Account i.e.., Parent Account
            Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
            
            
            //Insert the School Year record
            School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School', System.today());
            
            //Create Academic Program Account i.e.., Child Account
            Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
            academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
            academicProgram.Registration_End_Date__c = System.today().addDays(10);
            academicProgram.MaxSpecialEdBirthdate__c = Date.today().addMonths(-2);
            update academicProgram;
            
            // Create a Contact with 'Caretaker' record type
            //Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
            
            //Create a care taker user for community
            //User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
            Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Caretaker Community User' LIMIT 1];        
            
            Account account_1 = new Account( Name = 'Community', Too_Young_Cutoff__c = System.today());
            insert account_1;
            Id caretakerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',RecordTypeId=caretakerRecordTypeId);
            insert contact_1;
            System.debug('Student Id'+ contact_1.Id);
            
            hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact_1.Id, schoolYear.Id, false);
            ProgramEnrollmentTest.Final_Grade_Level__c = '1';       
            Insert ProgramEnrollmentTest;
            // UserRole usrRole = [SELECT Id FROM UserRole WHERE Name = 'Pearson Community Role' LIMIT 1];
            User careTaker; 
            careTaker = new User (
                Email = 'userTest@test.com',
                ProfileId = profile_1.Id,
                Username = 'addlHHMemUS@test.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                IsActive = true,
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Testing',
                LastName = 'Portal User',
                //UserRoleId=usrRole.id, 
                contact = contact_1
            );
            insert careTaker;
            
            Id studentRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
            // Create a Contact with 'Students' record type
            Contact student = Peak_TestUtils.createTestContact();
            student.LastName='TestCon';
            student.Phone='8143098909';
            student.Birthdate__c=Date.newInstance(2014, 2, 17);
            student.AccountId=institutionAccount.Id;  
            student.RecordTypeId=studentRecordTypeId;
            update student;        
            
            //Create a relationship between the User Contact and Student Contact
            hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true); 
        } 
    }
    static testMethod void LCTest(){
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'addlHHMemUS@test.com'];	
        Account institutionAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        //Contact careTakerContact=[select id, RecordTypeId from Contact where RecordType.Name='Caretaker' Limit 1];
        Contact careTakerContact=[select id, RecordTypeId from Contact where Id =: careTaker.ContactId Limit 1];
        
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                   WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        
        System.runAs(careTaker) { 
            Test.startTest();
            NES_AddHHMemApexController.AdditionalHouseHoldMembers a = new NES_AddHHMemApexController.AdditionalHouseHoldMembers();
            a.fname = 'fname';
            a.lname = 'lname';
            a.mname = 'M';
            a.email = 'fname@test.com';
            a.phoneType = 'Mobile';
            a.phoneNumber = '1234512345';
            a.accountId = institutionAccount.Id;
            a.suffix = '';
            a.memberRTDeveloperName = 'Learning_Coach:Test';
            
            String cntct = JSON.serialize(a);
            System.debug('NDEBUG:: Final String:::' + cntct);
            
            Boolean StudentExists = NES_AddHHMemApexController.STExistsforCT();
            system.assertEquals(StudentExists, true);
            //System.debug('NDEBUG::: StudentExists' + StudentExists);
            NES_AddHHMemApexController.chkExistCnts(cntct);
            String response = NES_AddHHMemApexController.createAddlHHMemContact(cntct);
            //System.assertEquals('New Contact Created', response);
            
            /*

NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYears[0].Id);

NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle', 'MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null); //added for US116612 
newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
String studentJSON = JSON.serialize(newStudentData);
System.debug('studentJSON++'+studentJSON);

Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Question' LIMIT 1];
List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
q1.order = 1;
q1.componentType = 'Student';
q1.questionGroup = false;
q1.questionPrompt = 'What grade is the student going into?';
q1.questionTarget = 'hed__Program_Enrollment__c.Final_Grade_Level__c';
q1.questionType = 'Picklist';
q1.required = true;
q1.schoolYear = schoolYears[0].Id;
q1.targetField = 'K';
q1.componentType = 'false';
q1.questionId = qComponent.Id;
questionDataList.add(q1);
String questionJSON = JSON.serialize(questionDataList);

Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
*/
            Test.stopTest();   
            
            
        }
        
        //Check whether Case has been created with correct parameters
        List<Case> tickets=[select id,Description,Origin,Status,Subject,Subject_Name__c,System_of_Origin__c,Ticket_Sub_Type__c,Ticket_Type__c,Type
                            from Case where ContactId=: careTakerContact.Id limit 1];
        System.assertEquals(1,tickets.size());
        
        // Check the record type of the contact which has been created
        Id caretakerRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Learning Coach').getRecordTypeId(); 
        List<Contact> contacts=[select id, RecordTypeId from Contact where firstName =: 'fname' and lastName =: 'lname' and email =: 'fname@test.com' limit 1];
        System.assertEquals(1,contacts.size());
        System.assertEquals(caretakerRecordTypeId, contacts[0].RecordTypeId);
    } 
    
    
    
    static testMethod void CTGaurdianest(){
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'addlHHMemUS@test.com'];	
        Account institutionAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        //Contact careTakerContact=[select id, RecordTypeId from Contact where RecordType.Name='Caretaker' Limit 1];
        Contact careTakerContact=[select id, RecordTypeId from Contact where Id =: careTaker.ContactId Limit 1];
        
        System.runAs(careTaker) {  
            Test.startTest();
            NES_AddHHMemApexController.AdditionalHouseHoldMembers a = new NES_AddHHMemApexController.AdditionalHouseHoldMembers();
            a.fname = 'fname';
            a.lname = 'lname';
            a.mname = 'M';
            a.email = 'fname@test.com';
            a.phoneType = 'Work';
            a.phoneNumber = '1234512345';
            a.accountId = institutionAccount.Id;
            a.suffix = '';
            a.memberRTDeveloperName = 'Caretaker_Designated:Test';
            
            String cntct = JSON.serialize(a);
            System.debug('NDEBUG:: Final String:::' + cntct);
            
            Boolean StudentExists = NES_AddHHMemApexController.STExistsforCT();
            system.assertEquals(StudentExists, true);
            NES_AddHHMemApexController.chkExistCnts(cntct);
            String response = NES_AddHHMemApexController.createAddlHHMemContact(cntct);
            System.assertEquals('New Contact Created', response);
            Test.stopTest();
            //Check whether Case has been created with correct parameters
            List<Case> tickets=[select id,Description,Origin,Status,Subject,Subject_Name__c,System_of_Origin__c,Ticket_Sub_Type__c,Ticket_Type__c,Type
                                from Case where ContactId=: careTakerContact.Id limit 1];
            System.assertEquals(1,tickets.size());
            
        }
        // Check the record type of the contact which has been created
        Id caretakerRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId(); 
        List<Contact> contacts=[select id, RecordTypeId from Contact where firstName =: 'fname' and lastName =: 'lname' and email =: 'fname@test.com' limit 1];
        System.assertEquals(1,contacts.size());
        System.assertEquals(caretakerRecordTypeId, contacts[0].RecordTypeId);
    }
    
    static testMethod void CTParentest(){
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'addlHHMemUS@test.com'];	
        Account institutionAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        //Contact careTakerContact=[select id, RecordTypeId from Contact where RecordType.Name='Caretaker' Limit 1];
        Contact careTakerContact=[select id, RecordTypeId from Contact where Id =: careTaker.ContactId Limit 1];
        
        
        System.runAs(careTaker) {
            Test.startTest();
            NES_AddHHMemApexController.AdditionalHouseHoldMembers a = new NES_AddHHMemApexController.AdditionalHouseHoldMembers();
            a.fname = 'fname';
            a.lname = 'lname';
            a.mname = 'M';
            a.email = 'fname@test.com';
            a.phoneType = 'Home';
            a.phoneNumber = '1234512345';
            a.accountId = institutionAccount.Id;
            a.suffix = '';
            a.memberRTDeveloperName = 'Caretaker_Parent:Test';
            String cntct = JSON.serialize(a);
            System.debug('NDEBUG:: Final String:::' + cntct);
            
            Boolean StudentExists = NES_AddHHMemApexController.STExistsforCT();
            system.assertEquals(StudentExists, true);
            NES_AddHHMemApexController.chkExistCnts(cntct);
            String response = NES_AddHHMemApexController.createAddlHHMemContact(cntct);
            System.assertEquals('New Contact Created', response);
            
            Test.stopTest();
            
            //Check whether Case has been created with correct parameters
            List<Case> tickets=[select id,Description,Origin,Status,Subject,Subject_Name__c,System_of_Origin__c,Ticket_Sub_Type__c,Ticket_Type__c,Type
                                from Case where ContactId=: careTakerContact.Id limit 1];
            System.assertEquals(1,tickets.size());
            
            
        }
        // Check the record type of the contact which has been created
        Id caretakerRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId(); 
        List<Contact> contacts=[select id, RecordTypeId from Contact where firstName =: 'fname' and lastName =: 'lname' and email =: 'fname@test.com' limit 1];
        System.assertEquals(1,contacts.size());
        System.assertEquals(caretakerRecordTypeId, contacts[0].RecordTypeId);
    }
    
    
    
}