@IsTest
public class NES_OtherSchoolEnrollmentHelperTest {
@TestSetup
    static void setup(){
        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        
        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        // academicProgram.OwnerId=institutionAccount.OwnerId;
        update academicProgram;
        
        
        
        
        
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;
        
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        student.Caretaker_Id__c = careTakerContact.Id;
        update student;
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id; 
        //studentEnrollment.hed__Contact__r.Caretaker_Id__c = careTakerContact.Id;
        insert studentEnrollment;
        
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('Test',true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test', academicProgram.Id, gradeLevel.Id,Datetime.now(), true);
        Opportunity oppToInsert = new Opportunity();
        oppToInsert.Name = 'test opportunity';
        oppToInsert.OwnerId = careTaker.Id;
        oppToInsert.Caretaker_Id__c = careTaker.ContactId;
        oppToInsert.Student_Id__c = student.Id;
        oppToInsert.AccountId = student.AccountId;
        oppToInsert.Program_Enrollment__c = studentEnrollment.Id;
        oppToInsert.StageName = 'Closed Lost';
        oppToInsert.CloseDate = academicProgram.Confirmation_End_Date__c == null ? Date.today() : academicProgram.Confirmation_End_Date__c.date();
        insert oppToInsert;
    }

    static testMethod void unitTesting() {
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];
        Contact studentid=[select id,AccountId,firstName,middleName,lastName from Contact WHERE RecordType.name='Students' limit 1];
        Account institutionalAccount = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                   WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        
        
        Grade_Level__c gradeLevel=[select id,name from Grade_Level__c where name ='test' limit 1];
        
        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id,name FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        
        //Create a student enrollment for the CareTaker Contact
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYears[0].Id, true);
        hed__Program_Enrollment__c progEnrollment2 = [SELECT id,(SELECT Id,StageName FROM Opportunities__r)
                                                        FROM hed__Program_Enrollment__c WHERE Id = :progEnrollment.Id];
        List<Opportunity> oppo = progEnrollment2.Opportunities__r;
        //////////////
        //
        Test.startTest(); 
        NES_OtherSchoolEnrollmentHelper.getSchoolsToAttend(studentid.Id);  
        NES_OtherSchoolEnrollmentHelper.getSchoolYears(institutionalAccount.Name);  
        NES_OtherSchoolEnrollmentHelper.getGradeLevels(institutionalAccount.Name,  schoolYears[0].Name);
        NES_OtherSchoolEnrollmentHelper.otherSchoolEnrollment(studentid.Id,institutionalAccount.Name,  schoolYears[0].Name,gradeLevel.Name,'application',true);  
        Test.stopTest();
        
        
    }
}