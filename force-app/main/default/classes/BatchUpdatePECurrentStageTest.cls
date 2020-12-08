/*
* Created Test Class for the task #171920 for BatchUpdatePECurrentStage on 24-04-2020
*/
@isTest
public class BatchUpdatePECurrentStageTest {
    @TestSetup
    static void setup(){
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today()); 
        
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        academicProgramAccount.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c = 3000; 
        academicProgramAccount.Fed_Poverty_Elig_Inc_Addl_Per_Person__c = 3000;
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c = 1000;
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c = 2000;
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c = 3000;
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c = 4000; 
        update academicProgramAccount;
        
        RecordType rtypes = [Select Name, Id From RecordType where sObjectType='hed__Program_Enrollment__c' and RecordType.name = 'Student' limit 1];
        
        hed__Program_Enrollment__c pevalues=new hed__Program_Enrollment__c();
        //pevalues.Name='Testing';
        pevalues.Status__c='In Progress';
        pevalues.hed__Account__c=academicProgramAccount.Id;
        pevalues.hed__Contact__c=contact.Id;
        pevalues.RecordTypeId=rtypes.id;
        pevalues.Start_Year__c=currentSchoolYear.Id;
        insert pevalues;
        
        List<hed__Program_Enrollment__c> listPeids=new List<hed__Program_Enrollment__c>();
        listPeids.add(pevalues);
        RecordType rtypes1 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Stage' limit 1];
        RecordType rtypes3 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Section' limit 1];
        
        List<Enrollment_Component__c> enCompList2 = new  List<Enrollment_Component__c>();
        
        Enrollment_Component__c ecValues=new Enrollment_Component__c();
        ecValues.RecordTypeId=rtypes1.id;
        ecValues.Name='Confirmation of Enrollment';
        enCompList2.add(ecValues);
        
        Enrollment_Component__c ecValues1=new Enrollment_Component__c();
        ecValues1.RecordTypeId=rtypes3.id;
        ecValues1.Name='Confirmation of Enrollment Notice';
        enCompList2.add(ecValues1);
        insert enCompList2;
        List<Enrollment_Component_Affiliation__c> afflist = new list<Enrollment_Component_Affiliation__c>();
        
        Enrollment_Component_Affiliation__c ecaValues=new Enrollment_Component_Affiliation__c();
        ecaValues.Program_Enrollment__c=pevalues.Id;
        ecaValues.Enrollment_Component__c=ecValues.Id;
        ecaValues.Status__c='In Progress ';
        afflist.add(ecaValues);
        
        Enrollment_Component_Affiliation__c ecaValues1=new Enrollment_Component_Affiliation__c();
        ecaValues1.Program_Enrollment__c=pevalues.Id;
        ecaValues1.Enrollment_Component__c=ecValues1.Id;
        ecaValues.Status__c='In Progress';
        afflist.add(ecaValues1);
        insert afflist; 
    }
     @isTest
    static void testingBatchUpdate(){
        
        Test.startTest();
        BatchUpdatePECurrentStage  c = new BatchUpdatePECurrentStage ();
        Database.executeBatch(c);
        Test.stopTest();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id,Stage__c,Stage_Date__c FROM hed__Program_Enrollment__c WHERE RecordType.Name='Student' LIMIT 1];
        List<Enrollment_Component_Affiliation__c> afflist1=[select id,Status__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c =:programEnrollment.Id AND Enrollment_Component__r.RecordType.Name = 'Stage'];
   
       System.assertEquals('Confirmation Of Enrollment',programEnrollment.Stage__c);
       System.assertEquals('In Progress',afflist1[0].Status__c);
    } 

}