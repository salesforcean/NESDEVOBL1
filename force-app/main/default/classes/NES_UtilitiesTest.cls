/**
 * Created by Anushka Bansal on 09-01-2019.
 */

@IsTest
public with sharing class NES_UtilitiesTest {

    static testMethod void testRetrieveLogo() {
        Account account = Peak_TestUtils.createTestAccount();
        
        ContentVersion contentVersion = new ContentVersion(
                Title = '---logo',
                PathOnClient = 'test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );

        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('document ' + documents);
     
        // create a document link between the contentDocument and the knowledge article
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = documents[0].Id,
                LinkedEntityId = account.Id,
                ShareType = 'I'
        );
        insert contentDocumentLink;

        NES_Utilities.retrieveLogo(account.Id);
    }

    static testMethod void testBatchUpdateTimeConstraint(){
        Test.startTest();
        NES_Utilities.callBatchUpdateTimeConstraint();
        Test.stopTest();
    }

    static  testMethod  void testGetCommunityNetworkId(){
        Test.startTest();
        Id id = NES_Utilities2.getCommunityNetworkId();
        System.debug('id -- ' + id);
        Test.stopTest();
    }

    static testMethod void testCreateDefaultNickName(){
        Test.startTest();
        User u = [SELECT Id, CommunityNickname FROM User where isActive = true and CommunityNickname != null limit 1];
        system.debug('user '  + u.CommunityNickname);
        String nickeName = NES_Utilities2.createDefaultNickname(u.CommunityNickname);
        System.assertNotEquals(nickeName,null);
        Test.stopTest();
    }
    static testMethod void testCreateDefaultNickName2(){
        Test.startTest();
       String nickName = NES_Utilities2.createDefaultNickname('');
        System.assertNotEquals(nickName,null);
        Test.stopTest();
    }

    static  testMethod void testbBuildSOQL(){
        Test.startTest();
        String value = NES_Utilities2.buildSOQL('Contact', true, 'Id, firstName, LastName', 'firstName != null' , 'asc');
        System.assertNotEquals(value, null);
        Test.stopTest();
    }

    static  testMethod void testGenerateRandomString(){
        Test.startTest();
        String randStr = NES_Utilities2.generateRandomString(5);
        System.debug('randStr ' + randStr);
        System.assertNotEquals(randStr, null);
        Test.stopTest();
    }
}