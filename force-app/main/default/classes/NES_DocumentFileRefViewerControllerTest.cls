/*
* Purpose: Test class for NES_DocumentFileRefViewerController 
* Change Log:
*         2019-08-14 initial for #101928 User Story (Andrew Sim)
*          2019-08-14 initial for #102150 User Story (Chinnamanaidu Neerasa).Bug 106220 removed TIF file support as per business.  
*/
@isTest(SeeAllData=false)
public class NES_DocumentFileRefViewerControllerTest {
    
    @TestSetup
    static void setup() {
        
        // Create Program Enrollment Document Record.
        Account institutionAccount = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));
        Contact caretaker = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c();
        programEnrollment.Start_Year__c = previousSchoolYear.Id;
        insert programEnrollment;
        
        // Create Enrollment Document Record
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c ();
        enrollmentDoc.Program_Enrollment__c = programEnrollment.id;
        insert enrollmentDoc;
        
        // Create Document Reference File Records
        Document_File_References__c dfr;
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'text document';
        dfr.File_Path__c = 'xxx/file.txt';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'jpg document';
        dfr.File_Path__c = 'xxx/file.jpg';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'jpeg document';
        dfr.File_Path__c = 'xxx/file.jpeg';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'tif document';
        dfr.File_Path__c = 'xxx/file.tif';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'gif document';
        dfr.File_Path__c = 'xxx/file.gif';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'png document';
        dfr.File_Path__c = 'xxx/file.png';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'JPG document';
        dfr.File_Path__c = 'xxx/file.JPG';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
        dfr = new Document_File_References__c ();
        dfr.Document_Link__c = 'pdf document';
        dfr.File_Path__c = 'xxx/file.pdf';
        dfr.Enrollment_Document__c = enrollmentDoc.id;
        insert dfr; 
        
    }
    
    // public static testMethod void test_isAuthenticated(){
    //     NES_DocumentFileRefViewerController controller = new NES_DocumentFileRefViewerController();
        
    //     Test.startTest();
    //     // check initialized value
    //     System.assertEquals(controller.isAuthenticated, false);
        
    //     // check if setting auth token sets isAuthenticated = true
    //     ApexPages.currentPage().getParameters().put('authToken', 'x');
    //     PageReference page = controller.setAuthToken();
    //     Test.stopTest();
    //     System.assertEquals(controller.isAuthenticated, true);
    // }
    
    public static testMethod void test_checkExtensions(){
        
        Document_File_References__c dfr;
        NES_DocumentFileRefViewerController controller;
        
        Test.startTest();
        // check txt
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'text document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, true);
        System.assertEquals(controller.isImage, false);
        System.assertEquals(controller.isPDF, false);
        
        // check jpg
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'jpg document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, true);
        System.assertEquals(controller.isPDF, false);
        
        // check jpeg
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'jpeg document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, true);
        System.assertEquals(controller.isPDF, false);
        
        // check gif
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'gif document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, true);
        System.assertEquals(controller.isPDF, false);
        
        // check tif. Commented code as per Bug 106220.
        //dfr = [select Id from Document_File_References__c where Document_Link__c = 'tif document' limit 1];
        //ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        //controller = new NES_DocumentFileRefViewerController();
        //System.assertEquals(controller.isText, false);
       // System.assertEquals(controller.isImage, true);
        //System.assertEquals(controller.isPDF, false);
        
        // check png
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'png document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, true);
        System.assertEquals(controller.isPDF, false);
        
        // check lowercase
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'JPG document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, true);
        System.assertEquals(controller.isPDF, false);
        
        // check pdf
        dfr = [select Id from Document_File_References__c where Document_Link__c = 'pdf document' limit 1];
        ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
        controller = new NES_DocumentFileRefViewerController();
        System.assertEquals(controller.isText, false);
        System.assertEquals(controller.isImage, false);
        System.assertEquals(controller.isPDF, true);
        Test.stopTest();
        
    }
    
    // public static testMethod void test_getResponse() {
        
    //     Document_File_References__c dfr;
    //     NES_DocumentFileRefViewerController controller;
        
    //     Test.setMock(HttpCalloutMock.class, new httpCalloutMock200());
    //     Test.startTest();
        
    //     // check pdf response
    //     dfr = [select Id from Document_File_References__c where Document_Link__c = 'pdf document' limit 1];
    //     ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
    //     controller = new NES_DocumentFileRefViewerController();
    //     System.assertEquals(controller.getResponse(),EncodingUtil.base64Encode(System.Blob.valueOf('x')));
        
    //     // check text response
    //     dfr = [select Id from Document_File_References__c where Document_Link__c = 'text document' limit 1];
    //     ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
    //     controller = new NES_DocumentFileRefViewerController();
    //     System.assertEquals(controller.getResponse(),'x');
        
    //     Test.stopTest();
    // }
    
    // public static testMethod void test_getResponseError() {
        
    //     Document_File_References__c dfr;
    //     NES_DocumentFileRefViewerController controller;
        
    //     Test.setMock(HttpCalloutMock.class, new httpCalloutMock404());
    //     Test.startTest();
        
    //     // check error response
    //     dfr = [select Id from Document_File_References__c where Document_Link__c = 'text document' limit 1];
    //     ApexPages.currentPage().getParameters().put('c__dfrId', dfr.Id);
    //     controller = new NES_DocumentFileRefViewerController();
    //     System.debug(controller.getResponse());
        
    //     Test.stopTest();
    // }
    
    // public class httpCalloutMock200 implements HttpCalloutMock {
    //     public HttpResponse respond(HTTPRequest req) {
    //         // Create a fake response
    //         HttpResponse response = new HttpResponse();
    //         response.setBody('x');
    //         response.setBodyAsBlob(System.Blob.valueOf('x'));
    //         response.setStatusCode(200);
    //         return response;
    //     }
    // }
    
    // public class httpCalloutMock404 implements HttpCalloutMock {
    //     public HttpResponse respond(HTTPRequest req) {
    //         // Create a fake response
    //         HttpResponse response = new HttpResponse();
    //         throw new CalloutException();
    //     }
    // }
    
    
}