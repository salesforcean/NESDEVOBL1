/**
* Created by Jagadishbabu on 12/21/20.
* Created for the US343498. 
* Description : This is test class for NES_ProgramGradeLevelUpdateOnPEBatch
*/
@isTest
public class NES_ProgramGradeLevelUpdateOnPEBatchTest {
    @TestSetup
    static void setup(){
        //Create Educational Institutional Account i.e.., Parent Account
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
        
        //Create Grade Level
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('1', true);
        
        //Create Program Grade Level
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',academicProgram.Id, gradeLevel.Id, System.now(), false);
        insert programGradeLevel;
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        insert studentEnrollment;
        
        Annual_Student_Information__c asi1 = Peak_TestUtils.createAnnualStudentInformation('Test ASI1', studentEnrollment.Id, schoolYear.Id, false);
        insert asi1;
    }
    //Test for if ASI record exist and it has final grade level
    static testMethod void ASIRecTest(){
        Id StudentrecTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id,Final_Grade_Level__c,hed__Contact__r.CA_StartYear__r.Name,Program_Grade_Level__c,hed__Account__c,V2_External_ID__c,RecordType.Name,(Select Id,School_Year__r.Name, Final_Grade_Level__c from Annual_Student_Information__r ) FROM hed__Program_Enrollment__c WHERE RecordTypeId=:StudentrecTypeId AND Program_Grade_Level__c = null AND hed__Account__c !=null];
        List<Annual_Student_Information__c> ASIList = new List<Annual_Student_Information__c>();
        if(programEnrollments[0].Annual_Student_Information__r.size() > 0){
            programEnrollments[0].Annual_Student_Information__r[0].Final_Grade_Level__c = '1';
            ASIList.add(programEnrollments[0].Annual_Student_Information__r[0]);
        }
        update ASIList;
        List<Grade_Level__c> grades = [Select Id, Name from Grade_Level__c];
        List<Program_Grade_Level__c> PGL = [Select Id, Academic_Program__c,Grade_Level__r.Name from Program_Grade_Level__c];
        test.startTest();
        Database.executeBatch(new NES_ProgramGradeLevelUpdateOnPEBatch(), 200);
        test.stopTest();
    }  
    //Test for No ASI record exist and PE has final grade level
    static testMethod void NoASIRecTest(){
        Id StudentrecTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        delete [Select Id from Annual_Student_Information__c];
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id,Final_Grade_Level__c,hed__Contact__r.CA_StartYear__r.Name,Program_Grade_Level__c,hed__Account__c,V2_External_ID__c,RecordType.Name FROM hed__Program_Enrollment__c WHERE RecordTypeId=:StudentrecTypeId AND Program_Grade_Level__c = null AND hed__Account__c !=null];
        List<hed__Program_Enrollment__c> PEList = new List<hed__Program_Enrollment__c>();
        if(programEnrollments.size() > 0){
            programEnrollments[0].Final_Grade_Level__c = '1';
            PEList.add(programEnrollments[0]);
        }
        update PEList;
        List<Grade_Level__c> grades = [Select Id, Name from Grade_Level__c];
        List<Program_Grade_Level__c> PGL = [Select Id, Academic_Program__c,Grade_Level__r.Name from Program_Grade_Level__c];
        test.startTest();
        Database.executeBatch(new NES_ProgramGradeLevelUpdateOnPEBatch(), 200);
        test.stopTest();
    } 
    //Test for if ASI record exist and no final grade in ASI but PE has final grade level
    static testMethod void PERecTest(){
        Id StudentrecTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id,Final_Grade_Level__c,hed__Contact__r.CA_StartYear__r.Name,Program_Grade_Level__c,hed__Account__c,V2_External_ID__c,RecordType.Name FROM hed__Program_Enrollment__c WHERE RecordTypeId=:StudentrecTypeId AND Program_Grade_Level__c = null AND hed__Account__c !=null];
        List<hed__Program_Enrollment__c> PEList = new List<hed__Program_Enrollment__c>();
        if(programEnrollments.size() > 0){
            programEnrollments[0].Final_Grade_Level__c = '1';
            PEList.add(programEnrollments[0]);
        }
        update PEList;
        List<Grade_Level__c> grades = [Select Id, Name from Grade_Level__c];
        List<Program_Grade_Level__c> PGL = [Select Id, Academic_Program__c,Grade_Level__r.Name from Program_Grade_Level__c];
        test.startTest();
        Database.executeBatch(new NES_ProgramGradeLevelUpdateOnPEBatch(), 200);
        test.stopTest();
    } 
    //Test for scheduler batch
    static testMethod void testschedule() {        
        Test.StartTest();        
        NES_ProgramGradeLevelUpdateOnPEBatch sh1 = new NES_ProgramGradeLevelUpdateOnPEBatch();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    } 
}