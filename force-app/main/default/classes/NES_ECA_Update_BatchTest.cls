/**
* Created by Jagadishbabu on 10/23/20.
* Created for the task #328907. 
*/
@isTest(seeAllData = false)
public class NES_ECA_Update_BatchTest {
    @TestSetup
    static void setup(){
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today()); 
        NES_ECA_Update__mdt testRec= [Select Id, Date_to_be_Updated_On__c,Grade_level__c, Academic_Program__c, Enrollment_Component__c, Status__c,Type__c from NES_ECA_Update__mdt where Grade_level__c = 'All' limit 1];
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        academicProgramAccount.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c = 3000; 
        academicProgramAccount.Fed_Poverty_Elig_Inc_Addl_Per_Person__c = 3000;
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c = 1000;
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c = 2000;
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c = 3000;
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c = 4000; 
        academicProgramAccount.Name = testRec.Academic_Program__c; 
        update academicProgramAccount;
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('1', true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',academicProgramAccount.Id, gradeLevel.Id, System.now(), false);
        programGradeLevel.ActivateWaitlist__c = True;
        programGradeLevel.StartWaitlist__c = System.today();
        programGradeLevel.EndWaitlist__c = System.today();
        insert programGradeLevel;
        RecordType rtypes = [Select Name, Id From RecordType where sObjectType='hed__Program_Enrollment__c' and RecordType.name = 'Student' limit 1];
        
        hed__Program_Enrollment__c pevalues=new hed__Program_Enrollment__c();
        //pevalues.Name='Testing';
        pevalues.Stage__c='Confirmation Of Enrollment';
        pevalues.Status__c='In Progress';
        pevalues.hed__Account__c=academicProgramAccount.Id;
        pevalues.hed__Contact__c=contact.Id;
        pevalues.RecordTypeId=rtypes.id;
        pevalues.Start_Year__c=currentSchoolYear.Id;
        pevalues.Program_Grade_Level__c=programGradeLevel.Id;       
        insert pevalues;
        
        List<hed__Program_Enrollment__c> listPeids=new List<hed__Program_Enrollment__c>();
        listPeids.add(pevalues);
        
        RecordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Form' limit 1];
        RecordType rtypes3 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Section' limit 1];
        RecordType rtypes4 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Flag' limit 1];
        List<Enrollment_Component__c> enCompList2 = new  List<Enrollment_Component__c>();
        
        Enrollment_Component__c ecValues=new Enrollment_Component__c();
        ecValues.RecordTypeId=rtypes3.id;
        ecValues.Name=testRec.Enrollment_Component__c;
        enCompList2.add(ecValues);
        
        Enrollment_Component__c ecValues1=new Enrollment_Component__c();
        ecValues1.RecordTypeId=rtypes4.id;
        ecValues1.Name='Confirmation Hold Flag';
        enCompList2.add(ecValues1);
        insert enCompList2;
        List<Enrollment_Component_Affiliation__c> afflist = new list<Enrollment_Component_Affiliation__c>();
        
        Enrollment_Component_Affiliation__c ecaValues=new Enrollment_Component_Affiliation__c();
        ecaValues.Program_Enrollment__c=pevalues.Id;
        ecaValues.Enrollment_Component__c=ecValues.Id;
        afflist.add(ecaValues);
        
        Enrollment_Component_Affiliation__c ecaValues1=new Enrollment_Component_Affiliation__c();
        ecaValues1.Program_Enrollment__c=pevalues.Id;
        ecaValues1.Enrollment_Component__c=ecValues1.Id;
        afflist.add(ecaValues1);
        insert afflist;
        
    }
    
    static testMethod void ECAUpdateTest(){
        List<hed__program_Enrollment__c> programEnrollments = [SELECT Id,RecordType.Name,hed__Account__c,hed__Account__r.Name,Status__c,Academic_Program_With_Grade__c, (SELECT Id, 
                                                                                                                                                                         Enrollment_Component__r.RecordType.Name,
                                                                                                                                                                         Program_Enrollment__c,Program_Enrollment__r.Academic_Program_With_Grade__c,
                                                                                                                                                                         Enrollment_Component__r.Name
                                                                                                                                                                         FROM Enrollment_Component_Affiliation__r
                                                                                                                                                                        ) FROM hed__Program_Enrollment__c where recordType.Name = 'Student' AND Status__c='In Progress'];
        
        
        test.startTest();
        Database.executeBatch(new NES_ECA_Update_Batch(),200);
        test.stopTest();
    }
    
    static testMethod void ECAUpdateScheduleTest(){
        List<hed__program_Enrollment__c> programEnrollments = [SELECT Id,RecordType.Name,hed__Account__c,hed__Account__r.Name,Status__c,Academic_Program_With_Grade__c, (SELECT Id, 
                                                                                                                                                                         Enrollment_Component__r.RecordType.Name,
                                                                                                                                                                         Program_Enrollment__c,Program_Enrollment__r.Academic_Program_With_Grade__c,
                                                                                                                                                                         Enrollment_Component__r.Name
                                                                                                                                                                         FROM Enrollment_Component_Affiliation__r
                                                                                                                                                                        ) FROM hed__Program_Enrollment__c where recordType.Name = 'Student' AND Status__c='In Progress'];
        
        
        Test.StartTest();
        NES_ECA_Update_Batch testsche = new NES_ECA_Update_Batch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();       
    }
    
    
    
}