/**
* Created by Anushka Bansal on 27-11-2018.
*/

@IsTest
public with sharing class NES_ContactBusinessLogicTest {
    @TestSetup static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('ContactTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Peak_TestUtils.createNESBusinessLogicSwitch(NES_EntranceAgeUtility.ENTRANCE_AGE_CUSTOM_SETTING_VALUE, true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('12/27/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);
        Comment__c comment =  Peak_TestUtils.createComment(progEnrollment.Id);
        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', progEnrollment.Id, currentSchoolYear.Id, false);
        currentASI.CoursesFinalized__c = 'Yes';
        insert currentASI;
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        //Insert the School Year record 
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        
        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        
        
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Required_to_Complete_for_Auto_Placement__c = true;
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Assignment_Logic__c = null;
        
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Assignment_Logic__c = null;
        
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;
        
        
        componentList.add(processComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(formComponent_With_No_Logic);
        componentList.add(sectionComponent);
        componentList.add(sectionComponent_With_No_Logic);
        componentList.add(questionGroupComponent);
        componentList.add(questionGroupComponent_With_No_Logic);
        componentList.add(questionComponent);
        componentList.add(questionComponent_With_No_Logic);
        
        insert componentList;
        
        Enrollment_Component_Affiliation__c affiliation1 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id, true);
        
        //Added : Begin - for the US 203078 by Jagadeesh
        //Insert House Hold Account
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Test House Hold Account', 'Household');  
        
        //Inserting Contact with Student record type
        Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        Contact con = new Contact();
        con.FirstName = 'testName';
        con.LastName = 'test';
        con.AccountId = houseHoldAccount.Id;
        con.Birthdate__c = System.today();
        con.Gender_Selector__c = 'Male';
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was bullied';
        con.RecordTypeId = studentRTId;
        insert con;
        //Added : End - for the US 203078 by Jagadeesh
        
    }
    
    static testMethod void calculatePlacementTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        hed__Program_Enrollment__c progEnrollment1= [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        progEnrollment1.hed__Contact__c = con.Id;
        update progEnrollment1;
        
        Enrollment_Component__c cmp1 = [SELECT Id, RecordType.Name FROM Enrollment_Component__c WHERE RecordType.Name = 'Stage'];
        cmp1.Required_to_Complete_for_Auto_Placement__c = true;
        update cmp1;
        
        Enrollment_Component_Affiliation__c affiliation1 = [SELECT Id FROM Enrollment_Component_Affiliation__c LIMIT 1];
        affiliation1.Status__c = 'Complete';
        update affiliation1;
        
        con.Birthdate__c = System.today();
        con.Gender_Selector__c = 'Male';
        
        Test.startTest();
        update con;
        Test.stopTest();
        
    }
    
    static testMethod void testContactInsert(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'test';
        con.AccountId = acc.Id;
        con.Birthdate__c = System.today();
        con.Gender_Selector__c = 'Male';
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was bullied';
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = 'test'];
        System.assertEquals(contacts.size(), 1);
    }
    //added -- for the US 185603 by Jagadish babu
    static testMethod void testStudentCountonAccount_Insert(){
       
        Test.startTest();
        Account houseHoldAccount = [SELECT Id, Number_of_Students__c FROM account where RecordType.Name = 'Household' limit 1];
        contact con = [select FirstName, LastName,AccountId,Birthdate__c,Gender_Selector__c,Why_Is_Your_Child_Attending_CA__c,RecordTypeId from contact where AccountId = :houseHoldAccount.id limit 1];
        Test.stopTest();
        List<account> accountAfter = [SELECT Id, Number_of_Students__c FROM account WHERE id = :houseHoldAccount.Id];
        System.assertEquals(accountAfter[0].Number_of_Students__c, 1);  
     
    }
    //Ended -- for the US 185603 by Jagadish babu
    //Added : Begin - for the US 203078 by Jagadeesh
    static testMethod void testStudentCountonAccount_Delete(){

        Account houseHoldAccount = [SELECT Id, Number_of_Students__c FROM account where RecordType.Name = 'Household' limit 1];
        contact con = [select FirstName, LastName,AccountId,Birthdate__c,Gender_Selector__c,Why_Is_Your_Child_Attending_CA__c,RecordTypeId from contact where AccountId = :houseHoldAccount.id limit 1];
        Test.startTest();
        delete con;
        Test.stopTest();
        List<account> accountNoCon = [SELECT Id, Number_of_Students__c FROM account WHERE id = :houseHoldAccount.Id];
        //Assertion for checking the Number Of Students Field after Delete
        System.assertEquals(accountNoCon[0].Number_of_Students__c, 0); 
        
    }
    static testMethod void testStudentCountonAccount_UnDelete(){
   
        Account houseHoldAccount = [SELECT Id, Number_of_Students__c FROM account where RecordType.Name = 'Household' limit 1];
        contact con = [select FirstName, LastName,AccountId,Birthdate__c,Gender_Selector__c,Why_Is_Your_Child_Attending_CA__c,RecordTypeId from contact where AccountId = :houseHoldAccount.id limit 1];
        delete con;
        Test.startTest();
        undelete con;
        Test.stopTest();
        List<account> accountunDel = [SELECT Id, Number_of_Students__c FROM account WHERE id = :houseHoldAccount.Id];
        //Assertion for checking the Number Of Students Field after UnDelete
        System.assertEquals(accountunDel[0].Number_of_Students__c, 1); 
           
    }
    //Added : End - for the US 203078 by Jagadeesh
}