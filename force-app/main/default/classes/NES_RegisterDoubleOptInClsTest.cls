@isTest
public with sharing class NES_RegisterDoubleOptInClsTest {
    @TestSetup
    static void setUpData(){
        //Create Instituation Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();

        //Create School Year 
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create academic program 
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

    }

    @IsTest
    static void testAccessToken(){
        Test.setMock(HttpCalloutMock.class, new MockAgigeeAccessToken());
        Test.startTest();

        NES_RegisterDoubleOptInCls.getApigeeAccessToken('test','test');
        system.assertEquals('dummyToken',NES_RegisterDoubleOptInCls.apigeeAccessToken);
        NES_RegisterDoubleOptInCls.ApigeeTokenDetail wrap = new  NES_RegisterDoubleOptInCls.ApigeeTokenDetail();
        wrap.tokenId = 'test';
        wrap.successUrl = 'test';
        wrap.realm = 'test';
        Test.stopTest();      
    }

     @IsTest
     static void enableDoubleOptInTest(){  
         Test.setMock(HttpCalloutMock.class, new MockResponseEnableOptIn());  
         Id careTakerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Caretaker').getRecordTypeId();
         Contact careTaker = [Select Id, SMS_Phone_Number__c,RecordTypeId from Contact where RecordTypeId=:careTakerRTId];    
         try {
             careTaker.Phone = '1234567890';  
             careTaker.SMS_Phone_Number__c = '1234567890';
             update careTaker;                          
         } catch (Exception e) {             
         }
         Test.startTest();
         NES_RegisterDoubleOptInCls.apigeeAccessToken = 'dummy';

        List<String> phoneNumbers = new List<String>{careTaker.SMS_Phone_Number__c};
        NES_RegisterDoubleOptInCls.enableSMSService(phoneNumbers);
           system.assertEquals('dummy',NES_RegisterDoubleOptInCls.apigeeAccessToken);
         Test.stopTest();         
     }


    @IsTest
    static void enableDoubleOptInNegativeTest(){  
        Test.setMock(HttpCalloutMock.class, new MockResponseEnableOptFailedResponse());  
        Id careTakerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Caretaker').getRecordTypeId();
        Contact careTaker = [Select Id, SMS_Phone_Number__c,RecordTypeId from Contact where RecordTypeId=:careTakerRTId];    
        try {
            careTaker.Phone = '1234567890';  
            careTaker.SMS_Phone_Number__c = '1234567890';
            update careTaker;                          
        } catch (Exception e) {             
        }
        Test.startTest();
        NES_RegisterDoubleOptInCls.apigeeAccessToken = 'dummy';
        List<String> phoneNumers = new List<String>{careTaker.SMS_Phone_Number__c};
        NES_RegisterDoubleOptInCls.enableSMSService(phoneNumers);
        system.assertEquals('dummy',NES_RegisterDoubleOptInCls.apigeeAccessToken);
        Test.stopTest();         
    }
    
    public class MockResponseEnableOptIn implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example": "test"}');
            res.setStatusCode(202);
            return res;
        }
    }
    
    
    private class MockResponseEnableOptFailedResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example": "test"}');
            res.setStatusCode(200);
            return res;
        }
     }
     
     private class MockAgigeeAccessToken implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            res.setBody('{"tokenId":"dummyToken","successUrl":"dummyClientId","realm":"test"}');
            res.setStatusCode(200);
            return res;
        }
     }
}