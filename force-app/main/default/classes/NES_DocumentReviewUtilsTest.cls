/**
* Purpose : Test class for NES_DocumentReviewUtils class.
* Change Log:
*         2019-10-01 initial #US109913 (Andrew Sim)
*/
@isTest(SeeAllData=false)
public class NES_DocumentReviewUtilsTest {
    
    @TestSetup
    static void setup() {
        
        // insert educational institution 
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        // insert the school year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        
        // insert academic program
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;
        
        // insert grade level(s)
        Grade_Level__c gradeLevelK = new Grade_Level__c(Order__c = 1, External_Id__c = 'GL - K', Name = 'K');
        insert gradeLevelK;
        Grade_Level__c gradeLevel1 = new Grade_Level__c(Order__c = 2, External_Id__c = 'GL - 1', Name = '1');
        insert gradeLevel1;
        
        // insert program grade level(s)
        Program_Grade_Level__c programGradeLevelK = new Program_Grade_Level__c(Name = 'PGL = K', Grade_Level__c = gradeLevelK.id, Academic_Program__c = academicProgram.id);
        insert programGradeLevelK;
        Program_Grade_Level__c programGradeLevel1 = new Program_Grade_Level__c(Name = 'PGL = 1', Grade_Level__c = gradeLevel1.id, Academic_Program__c = academicProgram.id);
        insert programGradeLevel1;
        
        // insert caretaker
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        // insert caretaker user 
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        // insert caretaker program enrollment 
        hed__Program_Enrollment__c caretakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        insert careTakerEnrollment;
        
        // insert student
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        // create relationship between the caretaker and student
        hed__Relationship__c relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        // create student program enrollment
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        studentEnrollment.Program_Grade_Level__c = programGradeLevelK.Id;
        studentEnrollment.Household_Program_Enrollment__c = caretakerEnrollment.Id;
        studentEnrollment.Program_Enrollment__c = caretakerEnrollment.Id;
        studentEnrollment.hed__Account__c  = academicProgram.Id;
        insert studentEnrollment;
        
        //
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        /*
// insert document reference file 
Document_File_References__c dfr;
dfr = new Document_File_References__c ();
dfr.Document_Link__c = 'text document';
dfr.File_Path__c = 'xxx/file.txt';
dfr.Enrollment_Document__c = enrollmentDoc.id;
insert dfr; 
*/
        
        System.debug('gradeLevelK: ' + gradeLevelK);
        System.debug('programGradeLevelK: ' + programGradeLevelK);
        
        System.debug('academicProgram: ' + academicProgram);
        System.debug('careTakerContact: ' + careTakerContact);
        System.debug('careTaker: ' + careTaker);
        System.debug('student: ' + student);
        System.debug('studentEnrollment: ' + studentEnrollment);
        System.debug('caretakerEnrollment: ' + caretakerEnrollment);
        System.debug('institutionalAccount: ' + institutionAccount);
    }
    
    // matching educational institution no years no grades queue match
    static testMethod void getNextTest1() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = '';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('1-nextId: ' + obj.nextId);
            System.debug('1-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 1);
        }
        Test.stopTest();
    }
    
    // matching educational institution no years no grades no queue match
    static testMethod void getNextTest2() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = academicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = '';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('2-nextId: ' + obj.nextId);
            System.debug('2-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 0);
        }
        Test.stopTest();
    }    
    
    // no matching educational institution no years no grades 
    static testMethod void getNextTest3() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = academicProgram.id;
        request.schoolYears = '';
        request.gradeLevels = '';
        requestList.add(request);
                
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('3-nextId: ' + obj.nextId);
            System.debug('3-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 0);
        }
        Test.stopTest();
    }    
    
    // matching educational institution with one or more years 
    static testMethod void getNextTest4() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = schoolYears.id + '; ';
        request.gradeLevels = '';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('4-nextId: ' + obj.nextId);
            System.debug('4-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 1);
        }
        Test.stopTest();
    }    
    
    // matching educational institution with no year match
    static testMethod void getNextTest5() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
		Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '; ';
        request.gradeLevels = '';
        requestList.add(request);
               
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('5-nextId: ' + obj.nextId);
            System.debug('5-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 0);
        }
        Test.stopTest();
    }    
    
    // matching educational institution with one or more grades
    static testMethod void getNextTest6() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Grade_Level__c gradeLevelK = [SELECT Id, Name FROM Grade_Level__c WHERE Name = 'K' LIMIT 1];
        Grade_Level__c gradeLevel1 = [SELECT Id, Name FROM Grade_Level__c WHERE Name = '1' LIMIT 1];
        Program_Grade_Level__c programGradeLevelK = [SELECT Id, Name FROM Program_Grade_Level__c WHERE Name = 'PGL = K' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = gradeLevelK.Id + '; ';
        requestList.add(request);
        
        System.debug('6-gradeLevelK: ' + gradeLevelK);
        System.debug('6-programGradeLevelK: ' + programGradeLevelK);

        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('6-nextId: ' + obj.nextId);
            System.debug('6-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 1);
        }
        Test.stopTest();
    }    
    
    // matching educational institution with no grade match
    static testMethod void getNextTest7() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Grade_Level__c gradeLevelK = [SELECT Id, Name FROM Grade_Level__c WHERE Name = 'K' LIMIT 1];
        Grade_Level__c gradeLevel1 = [SELECT Id, Name FROM Grade_Level__c WHERE Name = '1' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = '; ';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('7-nextId: ' + obj.nextId);
            System.debug('7-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 0);
        }
        Test.stopTest();
    }    
    
    // matching educational institution get earliest pending document
    static testMethod void getNextTest8() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        System.debug('8-docReview: ' + docReview.Id);
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        // insert document review
        Document_Review__c docReview2 = new Document_Review__c();
        docReview2.Queue_Type__c = 'Non-Academic';
        docReview2.OwnerId = nonacademicGroup.Id;
        docReview2.Pending_Review_Date__c = Date.parse('11/16/2017');
        docReview2.Status__c = 'In Progress';
        insert docReview2;
        System.debug('8-docReview2: ' + docReview2.Id);
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc2 = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc2.Document_Review__c = docReview2.id;
        insert enrollmentDoc2;

        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = '';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('8-nextId: ' + obj.nextId);
            System.debug('8-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 2);
            System.assertEquals(obj.nextId, docReview2.id);
        }
        Test.stopTest();
    }    
    
    // matching educational institution no program enrollments
    static testMethod void getNextTest9() {
        Account institutionAccount = [SELECT Id, Name, RecordTypeId, CreatedDate FROM Account WHERE RecordType.Name = 'Educational Institution' AND Name = 'Test Account' LIMIT 1];
        School_Year__c schoolYears = [SELECT Id, Name, CreatedDate FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];
        Grade_Level__c gradeLevelK = [SELECT Id, Name FROM Grade_Level__c WHERE Name = 'K' LIMIT 1];
        Grade_Level__c gradeLevel1 = [SELECT Id, Name FROM Grade_Level__c WHERE Name = '1' LIMIT 1];
        Account academicProgram = [SELECT Id, Name, RecordTypeId, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c, CreatedDate 
                                   FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = 'Test Account' LIMIT 1];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, Name, CreatedDate FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Group nonacademicGroup = [SELECT Id, Name from GROUP where Name='Non-Academic Documents' AND Type='Queue' LIMIT 1];
        Group academicGroup = [SELECT Id, Name from GROUP where Name='Academic Documents' AND Type='Queue' LIMIT 1];
        
        // insert document review
        Document_Review__c docReview = new Document_Review__c();
        docReview.Queue_Type__c = 'Non-Academic';
        docReview.OwnerId = nonacademicGroup.Id;
        docReview.Pending_Review_Date__c = Date.parse('11/17/2017');
        docReview.Status__c = 'In Progress';
        insert docReview;
        
        // insert enrollment document 
        Enrollment_Document__c enrollmentDoc = new Enrollment_Document__c(Program_Enrollment__c = studentEnrollment.id);
        enrollmentDoc.Document_Review__c = docReview.id;
        insert enrollmentDoc;
        
        List<NES_DocumentReviewUtils.DocumentReviewRequest> requestList = new List<NES_DocumentReviewUtils.DocumentReviewRequest>();
        NES_DocumentReviewUtils.DocumentReviewRequest request = new NES_DocumentReviewUtils.DocumentReviewRequest();
        request.queue = nonacademicGroup.id;
        request.educationalInstitution = institutionAccount.id;
        request.schoolYears = '';
        request.gradeLevels = gradeLevel1.id + '; ';
        requestList.add(request);
        
        Test.startTest();
        List<NES_DocumentReviewUtils.DocumentReviewResponse> responseList = NES_DocumentReviewUtils.getNextDocumentReviews(requestList);
        for (NES_DocumentReviewUtils.DocumentReviewResponse obj : responseList) {
            System.debug('9-nextId: ' + obj.nextId);
            System.debug('9-statusReason: ' + obj.statusReason);
            System.assertEquals(obj.size, 0);
        }
        Test.stopTest();
    }    
    
}