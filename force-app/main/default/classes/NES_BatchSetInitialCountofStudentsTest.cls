@isTest
public class NES_BatchSetInitialCountofStudentsTest 
{
    static testMethod void NES_BatchSetInitialCoun() 
    {
   Account Objacc = Peak_TestUtils.createTestAccount(); 
   Contact con = Peak_TestUtils.createTestContact();
        Test.startTest();
            NES_BatchSetInitialCountofStudents  obj = new NES_BatchSetInitialCountofStudents ();
            DataBase.executeBatch(obj); 
             String chron = '0 0 23 * * ?';        
             String jobid = System.schedule('testScheduledApex', chron, new NES_BatchSetInitialCountofStudents());
        Test.stopTest();
        Account[] acc = [SELECT Id,Name,Number_of_Students__c FROM Account limit 1];
   System.assertEquals(acc[0].Number_of_Students__c , 0);
    }
}