/***************************************************************************************************************************************
* Name: SSTFUserPermissionBatch_TEST
****************************************************************************************************************************************
* Author: Ranjit Chaganti
* Purpose: This is a Test class for SSTFUserPermissionBatch (US#123101, Task # 159001).
* Created Date: 03/24/2020
****************************************************************************************************************************************
* <Modification History>
* <initials> - <date> - <reason for update>
*                     - <what was changed/added>
***************************************************************************************************************************************/

@isTest
public class SSTFUserPermissionBatch_TEST {
    
    @TestSetup
    public static void createTestData(){
        UserRole r=[Select Id from UserRole where PortalType ='none' limit 1];
        User u=new User(username='teste123@pearson.com.admin',
                        UserRoleId=r.Id,
                        alias = 'adminn',
                        timezonesidkey='America/Los_Angeles',
                        languagelocalekey='en_US',
                        localesidkey='en_US',emailencodingkey='UTF-8',country='United States',
                        profileId=UserInfo.getProfileId(),lastname='admin',email='test123@pearson.com.admin');
        insert u;
        System.runAs(u) {
            Id p = [select id from profile where name='School Staff Community User'].id;
            Id recordTypeIdEI  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
            Account ac = new Account(name ='TNCA',recordtypeId = recordTypeIdEI) ;
            insert ac; 
            
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;  
            
            
            
            User user = new User(alias = 'SSFT', email='test123@pearson.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='teste123@pearson.com');       
           insert user;        
        }
    }
    
    private static TestMethod void runBatch(){
        
        User u=new User(Id=UserInfo.getUserId());
        Group groupRecord = [Select Id from Group where Name='TNCA'];
        insert new groupmember(groupId=groupRecord.Id,UserOrGroupId=u.Id);
        System.runAs(u) {            
            test.starttest();
            Database.executeBatch(new SSTFUserPermissionBatch());
            /*SSTFPublicGroupUserPermissionBatch groupUserPermission = new SSTFPublicGroupUserPermissionBatch();
            groupUserPermission.EISSTFMappingList=[SELECT MasterLabel,Permission_Set_Name__c,User_Profile__c,Group_Name__c
                                                   FROM Educational_Institution_SSTF_Mapping__mdt where Group_Name__c='TNCA'];
           
            Database.executeBatch(groupUserPermission,1);*/
            String chron = '0 0 23 * * ?';        
            //system.schedule('Assign PermissionSet 1', chron, groupUserPermission);
            SSTFUserPermissionBatch sch = new SSTFUserPermissionBatch ();   
            system.schedule('Assign PermissionSet 2', chron, sch);
            test.stopTest();
        }
    }
}