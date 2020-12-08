/**
Created for NES_ProgramGradeLevelBusinessLogic class (Jagadish Babu)
**/
@isTest
public class NES_ProgramGradeLevelBusinessLogicTest {
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


        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;


        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
		
        //Create Grade Level
         Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('TestGrade', true);
        
        //Create Program Grade Level
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',academicProgram.Id, gradeLevel.Id, System.now(), false);
        insert programGradeLevel;
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.Program_Grade_Level__c = programGradeLevel.Id;
        insert studentEnrollment;
		
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Name = 'Confirmation of Enrollment';
        componentList.add(processComponent);        
        componentList.add(stageComponent);
        insert componentList;
        
        
         // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        
        
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c stageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        stageAffiliation.Status__c = 'Not Started';
        enrollmentComponentAffiliations.add(stageAffiliation);
        Enrollment_Component_Affiliation__c processAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, processComponent.Id, false);
        enrollmentComponentAffiliations.add(processAffiliation);
        insert enrollmentComponentAffiliations;
	}
    
    
    static testMethod void testWaitListTest(){        
        Program_Grade_Level__c oldPGL = [Select id, ActivateWaitlist__c,StartWaitlist__c,EndWaitlist__c from Program_Grade_Level__c limit 1];
        hed__Program_Enrollment__c programEnrollment = [Select Id,WaitlistFlag__c, Program_Grade_Level__c,Program_Grade_Level__r.Name from hed__Program_Enrollment__c where Program_Grade_Level__c =:oldPGL.Id and recordType.Name='Student' limit 1];
        Map<id, Program_Grade_Level__c> oldMapPGL = new Map<id, Program_Grade_Level__c>{oldPGL.Id=>oldPGL};
        Program_Grade_Level__c newPGL = new Program_Grade_Level__c();
        newPGL.Id = oldPGL.Id;
        newPGL.ActivateWaitlist__c = true;
        newPGL.StartWaitlist__c = system.today().addDays(-2);
        newPGL.EndWaitlist__c = system.today().addDays(3);
        try{
            update newPGL; 
        }catch(Exception e){}
        
        test.startTest();
        	NES_ProgramGradeLevelBusinessLogic.waitListCalculator(oldMapPGL,new List<Program_Grade_Level__c> {newPGL});
        test.stopTest();
        system.assertEquals(true, newPGL.ActivateWaitlist__c);        
    }
    
    static testMethod void testWaitListNewTest(){ 
        Account academicProgram = [Select Id from Account where recordType.Name = 'Academic Program' limit 1];
        Grade_Level__c gradeLevel = [Select Id from Grade_Level__c limit 1];
        Program_Grade_Level__c newPGL = Peak_TestUtils.createProgramGradeLevel('Test one',academicProgram.Id, gradeLevel.Id, System.now(), false);
        newPGL.ActivateWaitlist__c = true;
        newPGL.StartWaitlist__c = system.today().addDays(-2);
        newPGL.EndWaitlist__c = system.today().addDays(3);
        try{
            insert newPGL;  
        }catch(Exception e){}
        
        test.startTest();
           NES_ProgramGradeLevelBusinessLogic.waitListCalculator(null,new List<Program_Grade_Level__c> {newPGL}); 
       	test.stopTest();
        system.assertEquals(true, newPGL.ActivateWaitlist__c); 
    }
    
     static testMethod void testWaitListNegativeTest(){ 
        Account academicProgram = [Select Id from Account where recordType.Name = 'Academic Program' limit 1];
        Grade_Level__c gradeLevel = [Select Id from Grade_Level__c limit 1];
        Program_Grade_Level__c newPGL = Peak_TestUtils.createProgramGradeLevel('Test one',academicProgram.Id, gradeLevel.Id, System.now(), false);
        newPGL.ActivateWaitlist__c = false;
        newPGL.StartWaitlist__c = null;
        newPGL.EndWaitlist__c = null;
         try{
            insert newPGL; 
        }catch(Exception e){}
        
        test.startTest();
       	 NES_ProgramGradeLevelBusinessLogic.waitListCalculator(null,new List<Program_Grade_Level__c> {newPGL}); 
        test.stopTest();
         system.assertEquals(false, newPGL.ActivateWaitlist__c); 
    }   
}