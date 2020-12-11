/***************************************************************************************************************************************
* Name: CS_SSTFPermissionBatchTest
****************************************************************************************************************************************
* Author: Sai rakesh Puli
* Description: This is a Test class for CS_SSTFPermissionBatch .
* User Story # 176990 
* Task # 177183 
* Created Date: 05/9/2020
****************************************************************************************************************************************
* <Modification History>
* <initials> - <date> - <reason for update>
*                     - <what was changed/added>
***************************************************************************************************************************************/

@isTest
private class CS_SSTFPermissionBatchTest {
    
  
     static testmethod void insertpermissiontest(){
        Id p = [select id from profile where name='School Staff Community User'].id;
        Id SchoolstaffrecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('School Staff').getRecordTypeId();
        
        Account institutionAccount1 = Peak_TestUtils.createEducationalInstitutionAccount();
        institutionAccount1.name = 'TNCA';
        update institutionAccount1;
        NES_LogicFeatureSwitch__c necLogic = new NES_LogicFeatureSwitch__c(name='ContactTrigger',Active__c=true);
        insert necLogic;
        NES_LogicFeatureSwitch__c necLogic1 = new NES_LogicFeatureSwitch__c(name='Entrance Age Eligibility Calculation',Active__c=true);
        insert necLogic1;
        Contact con = new Contact(FirstName = 'test',LastName = 'testGoal',AccountId = institutionAccount1.Id,Birthdate__c = System.today(),recordtypeid = SchoolstaffrecId);        
        con.Gender_Selector__c = 'Male';
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was bullied';
        insert con;
        PermissionSet ps = [Select id from permissionset Where name ='TNCA_SSTF' AND IsOwnedByProfile =false Limit 1];
        
        User user = new User(alias = 'SSFT', email='test123@pearson.com',
                                 emailencodingkey='UTF-8', lastname='TestingGoal', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='testgoal123@pearson.com');       
            insert user; 
        
        Contact cont = [Select id,AccountId from contact where id=:con.Id];
        cont.Commuity_User__c = user.id;
        update cont;
        
        system.runAs(user){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id ,
                                                                                       AssigneeId = user.Id);   
            insert psa;
        }
        
         Test.startTest();
        Database.executeBatch(new CS_SSTFPermissionBatch());
        Test.stopTest();
        PermissionSetAssignment psassign =[Select id,AssigneeId,PermissionSetId  from PermissionSetAssignment 
                                      WHERE AssigneeId =:user.id AND PermissionSetId IN (SELECT Id  FROM PermissionSet WHERE IsOwnedByProfile =false) Limit 1];
        //TNCA Permissionset must be assigned to this user 
        System.assertEquals(psassign.permissionsetId, ps.Id);
       }
    
    Static testMethod void SSTFpermissionBatchScheduleTest(){
         
            test.startTest();
            
            String chron = '0 0 23 * * ?';
            CS_SSTF_BatchSchedule sch = new CS_SSTF_BatchSchedule();   
            String jobid = system.schedule('Schoolstaffschedule', chron, sch);
            CronTrigger ct =[Select id,CronJobDetailId,CronExpression,TimesTriggered  from CronTrigger where Id=:jobId  Limit 1];
            System.assertEquals(chron, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
  
    
           

    
}