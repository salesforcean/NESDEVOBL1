//Swapna:Test class for Documents Update service
@isTest
public class DocumentsUpdateService_Test{
       
    @isTest
    Public static void DocumentsUpdateRequestTest()
    {
        DocumentsUpdateService.DocumentsUpdateRequest Docreq = new DocumentsUpdateService.DocumentsUpdateRequest();
        Docreq.contactId ='0030n00000i6VQQAA2';
        Docreq.docType = '504 Plan';
        Docreq.schoolId = '0010n000010QglXAAS';
        Docreq.schoolYearId = '2019-2020';
        Docreq.filePaths = new List<String>();
        Docreq.filePaths.add('123.jpg');
        Docreq.filePaths.add('456.jpg');
    }
    
   @isTest
    Public static void updateDocRefTest()
    {
         Test.startTest();
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Testy5', 'Household'); 
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
      //  Contact c = [select contact_Id__c from Contact where Id =:TestContact.Id];
        String conId = TestContact.Id;
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, true);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = '504 Plan';
        enrollmentDocument1.Status_Reason__c = 'Submitted';
        update enrollmentDocument1;
        DocumentsUpdateService.DocumentsUpdateRequest Docreq = new DocumentsUpdateService.DocumentsUpdateRequest();
        Docreq.contactId =TestContact.Id;
        Docreq.docType = '504 Plan';
        Docreq.schoolId = parentAccount.Id;
        Docreq.schoolYearId = '2018-2019';
        Docreq.filePaths = new List<String>();
        Docreq.filePaths.add('123.jpg');
        Docreq.filePaths.add('456.jpg');
        String jsonBody = JSON.serialize(Docreq);
       // String JsonBody = '{"contactId":"C-00040","schoolYearId":"2018-2019","schoolId":"0550","docType":"504 Plan","filePaths":["123.jpg","456.jpg"]}';
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI ='/services/apexrest/DocsInfo/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        DocumentsUpdateService.updateDocRef();
               Test.stopTest();
    }    
    
    @isTest
    Public static void updateDocRefTest2()
    {
         Test.startTest();
        Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Testy5', 'Household'); 
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
       // Contact c = [select contact_Id__c from Contact where Id =:TestContact.Id];
      //  String conId = TestContact.Id;
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, true);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = '504 Plan';
        enrollmentDocument1.Status_Reason__c = 'Submitted';
        update enrollmentDocument1;
        DocumentsUpdateService.DocumentsUpdateRequest Docreq = new DocumentsUpdateService.DocumentsUpdateRequest();
        Docreq.contactId =TestContact.Id;
        Docreq.docType = 'Choice Transfer Form';
        Docreq.schoolId = parentAccount.Id;
        Docreq.schoolYearId = '2018-2019';
        Docreq.filePaths = new List<String>();
        Docreq.filePaths.add('123.jpg');
        Docreq.filePaths.add('456.jpg');
        String jsonBody = JSON.serialize(Docreq);
       // String JsonBody = '{"contactId":"C-00040","schoolYearId":"2018-2019","schoolId":"0550","docType":"504 Plan","filePaths":["123.jpg","456.jpg"]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI ='/services/apexrest/DocsInfo/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        DocumentsUpdateService.updateDocRef();
        Test.stopTest();
    }    
    
      
      

}