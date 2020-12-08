/**
* Created by Jagadeesh on 10/23/20.
* Created for the task #329761. 
*/

@isTest(seeAllData = false)

public class NES_BatchTimeCriteriaAssignmentOnlyTest {
    @TestSetup
    static void setup(){
        List<NES_ECA_Assign_TimeCriteria_AcademicProg__mdt> LstMeta = [select Academic_Programs__c from NES_ECA_Assign_TimeCriteria_AcademicProg__mdt];
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());      
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        academicProgramAccount.Name = LstMeta[0].Academic_Programs__c;
        academicProgramAccount.Use_Updated_ECA_Process__c = true;
        update academicProgramAccount;
        RecordType rtypes = [Select Name, Id From RecordType where sObjectType='hed__Program_Enrollment__c' and RecordType.name = 'Student' limit 1];
        hed__Program_Enrollment__c pevalues=new hed__Program_Enrollment__c();
        pevalues.Status__c='In Progress';
        pevalues.hed__Account__c=academicProgramAccount.Id;
        pevalues.hed__Contact__c=contact.Id;
        
        pevalues.RecordTypeId=rtypes.id;
        pevalues.Start_Year__c=currentSchoolYear.Id;
        pevalues.Initial_ECA_Creation_Complete__c = true;
        insert pevalues;
        
        RecordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Form' limit 1];
        RecordType rtypes3 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Section' limit 1];
        RecordType rtypes4 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Flag' limit 1];
        List<Enrollment_Component__c> enCompList2 = new  List<Enrollment_Component__c>();
        
        Enrollment_Component__c ecValues=new Enrollment_Component__c();
        ecValues.RecordTypeId=rtypes3.id;
        //  ecValues.Name=testRec.Enrollment_Component__c;
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
    
    static testMethod void Test(){
        test.startTest();
        Database.executeBatch(new NES_BatchTimeCriteriaAssignmentOnly(),200);
        NES_BatchTimeCriteriaAssignmentOnly testsche = new NES_BatchTimeCriteriaAssignmentOnly();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        test.stopTest();
    }
    
    
    
    static testMethod void Test1(){
        
        Account academicProgramAccount  = [ select name from Account where name = 'ACA 2020-2021' limit 1];  
        academicProgramAccount.Use_Updated_ECA_Process__c = false;
        update academicProgramAccount;
        
        test.startTest();
        Database.executeBatch(new NES_BatchTimeCriteriaAssignmentOnly(),200);
        NES_BatchTimeCriteriaAssignmentOnly testsche = new NES_BatchTimeCriteriaAssignmentOnly();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        test.stopTest();
    }
    
}