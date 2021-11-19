@IsTest
private class Peak_FileUploadControllerTest {
    public static Account testAccount = new Account();
    public static Attachment testAttachment = new Attachment();
    public static Enrollment_Component_Affiliation__c  eca = new Enrollment_Component_Affiliation__c();
    public static Enrollment_Component_Affiliation__c  eca1 = new Enrollment_Component_Affiliation__c();
    Public static Enrollment_Document__c ed1 = new Enrollment_Document__c();
    public static hed__Program_Enrollment__c ProgramEnrollmentTest = new hed__Program_Enrollment__c();
    Public static Enrollment_Component__c ecp = new Enrollment_Component__c();

    static void testSetup() {
        testAccount = Peak_TestUtils.createTestAccount();


        String base64Data = EncodingUtil.urlDecode(Peak_TestConstants.BASE64FILE, 'UTF-8');
        testAttachment.parentId = testAccount.Id;

        testAttachment.Body = EncodingUtil.base64Decode(base64Data);
        testAttachment.Name = Peak_TestConstants.FILENAME;
        testAttachment.ContentType = Peak_TestConstants.FILETYPE;


        insert testAttachment;
        
        //Swapna: test coverage
                Account houseHoldAccount = Peak_TestUtils.createAccountRecord('Testy5', 'Household'); 
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
        String conId = TestContact.Id;
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, true);
         ecp = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Form', true);
        Enrollment_Component__c ecc = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Question', true);
        Enrollment_Component__c ecp1 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Form', true);
        Enrollment_Component__c ecd = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', true);
        Enrollment_Component_Relationship__c ecr = Peak_TestUtils.createEnrollmentComponentRelationship(ecc.id,ecp.id);
        Enrollment_Component_Relationship__c ecr1 = Peak_TestUtils.createEnrollmentComponentRelationship(ecd.id,ecp1.id);
         eca = Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id, ecc.Id);
         eca1 = Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id, ecd.Id);
         ed1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        ed1.Type__c = '504 Plan';
        ed1.Status_Reason__c = 'Submitted';
        update ed1;
    }
    @isTest
    public static void testGetFileRestrictions() {
        Network testNetwork;
        List<Network> testNetworkList = [SELECT Id, MaxFileSizeKb, AllowedExtensions FROM Network];
        System.debug('testNetworkList ======  ' + testNetworkList);
        if (!Peak_Utils.isNullOrEmpty(testNetworkList)) {
            testNetwork = testNetworkList[0];
            if(testNetwork.MaxFileSizeKb == null || testNetwork.MaxFileSizeKb == 0 || testNetwork.MaxFileSizeKb > 4248){
                testNetwork.MaxFileSizeKb = 4248;
                //If the heap issue ever gets fixed then set the max size to the Salesforce max file size of 2GB.
                //curNetwork.MaxFileSizeKb = 2097152;
            }
        }
        Network testResults = (Network)Peak_FileUploadController.getFileRestrictions().results[0];
        String testString = testResults.AllowedExtensions + testResults.MaxFileSizeKb;
        String assertString = testNetwork.AllowedExtensions + testNetwork.MaxFileSizeKb;

        System.assertEquals(assertString, testString);
    }
    @isTest
    public static void saveChunkSaveTest() {
        testSetup();
        Peak_Response testResults = Peak_FileUploadController.saveChunk(testAccount.Id, Peak_TestConstants.FILENAME, Peak_TestConstants.BASE64FILE, Peak_TestConstants.FILETYPE, null);
        Peak_ContentObject testPeakResults = (Peak_ContentObject)testResults.peakResults[0];
        System.assertEquals(testResults.success, true);
        System.assertNotEquals(testPeakResults.contentID, null);
     
    }
    @isTest
    public static void saveChunkAppendTest() {
        testSetup();
        Peak_Response testResults = Peak_FileUploadController.saveChunk(testAccount.Id, Peak_TestConstants.FILENAME, Peak_TestConstants.BASE64FILE, Peak_TestConstants.FILETYPE, testAttachment.Id);
        Peak_ContentObject testPeakResults = (Peak_ContentObject)testResults.peakResults[0];

        System.assertEquals(testResults.success, true);
        System.assertNotEquals(testPeakResults.contentID, null);
       
    }
    @isTest
    public static void saveTheFileTest() {
        testSetup();

        Attachment testAttachment = Peak_FileUploadController.saveTheFile(testAccount.Id, Peak_TestConstants.FILENAME, Peak_TestConstants.BASE64FILE, Peak_TestConstants.FILETYPE);
        String testString = testAttachment.Name + testAttachment.ContentType;
        String assertString = Peak_TestConstants.FILENAME + Peak_TestConstants.FILETYPE;

        System.assertEquals(assertString, testString);
        System.assertNotEquals(null, testAttachment.Id);
    }
    @isTest
    public static void appendToFileTest() {
        testSetup();

        Attachment testResults = Peak_FileUploadController.appendToFile(testAttachment.Id, Peak_TestConstants.BASE64FILE);
        String testString = testResults.Id + testResults.Name + testResults.ContentType;
        String assertString = testAttachment.Id + Peak_TestConstants.FILENAME + Peak_TestConstants.FILETYPE;

        System.assertEquals(assertString, testString);
    }
    @isTest
    public static void deleteAttachmentTest() {
        testSetup();

        Peak_Response testResults = Peak_FileUploadController.deleteAttachment(testAttachment.Name, testAttachment.parentId);
        Attachment deletedAttachment = [SELECT Id, IsDeleted FROM Attachment WHERE Id = :testAttachment.Id ALL ROWS];

        System.assertEquals(true, testResults.success);
        System.assertEquals(true, deletedAttachment.IsDeleted);
        //Swapna:for test coverage
         Peak_Response testResults1 = Peak_FileUploadController.deleteAttachment(testAttachment.Name, '');
    }
    //Swapna:for GTM + test coverage
    @isTest
    public static void getFormTest() {
       testSetup();
     String frmname = Peak_FileUploadController.getFormName(eca.Id);
    }
     @isTest
    public static void getECATest() {
       testSetup();
     Peak_Response feca = Peak_FileUploadController.getECA(eca1.Id,ed1.Id);
         Peak_Response feca1 = Peak_FileUploadController.getECA('',ed1.Id);
        
    }
     @isTest
    public static void createEnrollmentDocumentTest() {
       testSetup();
        List<String> doclink = new List<String>{'test.jpg','test1.jpg'};
       
            Peak_Response ec = Peak_FileUploadController.createEnrollmentDocuments(eca1.Id,ed1.Id,doclink);
           
        
    }
    
     @isTest
    public static void grabURLredirectTest() {
       testSetup();
        
       Peak_Response ec = Peak_FileUploadController.grabURLredirect(ProgramEnrollmentTest.Id,eca.Id,ecp.Id);
         
      
    }
}