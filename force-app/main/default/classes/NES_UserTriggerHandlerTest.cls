/*
* Created by: Chinnamanaidu Neerasa 
* Created date: 2019-08-01
* Purpose: Test class for NES_UserTriggerHandler
* Change Log:
*         2019-08-01 initial Chinnamanaidu Neerasa for #102150 User Story
*/

@isTest(SeeAllData=false)
private with sharing class NES_UserTriggerHandlerTest {
    
    static testMethod void updateUserTest() {
        
        // create user and run as the same User.
        User testUser = createTestUser('testuser3');
        
        Test.startTest();
        system.runAs(testUser){ 
            
            User obj = [SELECT Id, Document_Download__c FROM User WHERE Id = :testUser.Id];
            obj.Document_Download__c = true;
            update obj;
            
            // force completion of any async processing
            Test.stopTest();

            // retrieve values and assert
            Utility_Settings__c objUser = [select Id, SetupOwnerId, Document_Download__c from Utility_Settings__c where SetupOwnerId = :testUser.Id];  
            system.assertEquals(true, objuser.Document_Download__c);
        }
    } 
    
    public static user createTestUser(String userName){
        Profile testProfile = [select Id from profile where name='System Administrator'];
        UserRole testRole = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert testRole;
        User testUser = new User(emailencodingkey = 'UTF-8',
                                    languagelocalekey = 'en_US',
                                    localesidkey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',
                                    alias = 'test', 
                                    lastname = userName,
                                    email = userName + '@pearson.com.test',
                                    profileid = testProfile.Id, 
                                    //userRoleId = testRole.Id,
                                    username = userName + '@pearson.com.test');
        return testUser;
    }
}