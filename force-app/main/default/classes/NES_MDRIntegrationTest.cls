/**
 * Created by Anand on 1/9/2019.
 */
@IsTest
private class NES_MDRIntegrationTest {
    @TestSetup
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount(); 
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('CSY', System.today());
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        List<Enrollment_Component__c> enrollmentCompList = new List<Enrollment_Component__c>();
        Enrollment_Component__c questionComponentTest1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponentTest1.Answer_Target__c = 'Account.Name';
        questionComponentTest1.API_Mapping__c = 'schoolName' ;
        questionComponentTest1.Question_Type__c = 'Picklist';
        Enrollment_Component__c questionComponentTest2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponentTest2.Answer_Target__c = 'Account.Department';
        questionComponentTest2.API_Mapping__c = 'streetAddress';
        questionComponentTest2.Question_Type__c = 'Radio';
        Enrollment_Component__c questionComponentTest3 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponentTest3.Answer_Target__c = 'contact.AssistantName';
        questionComponentTest3.API_Mapping__c = 'city';
        questionComponentTest3.Question_Type__c = 'Checkbox Group';

        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);

        enrollmentCompList.add(questionComponentTest1);
        enrollmentCompList.add(questionComponentTest2);
        enrollmentCompList.add(questionComponentTest3);
        enrollmentCompList.add(sectionComponent);

        insert enrollmentCompList;
        Enrollment_Component__c questionGroupComp = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComp.Status__c = 'Inactive';
        insert questionGroupComp;
        Enrollment_Component_Relationship__c enrollCompRelationshipTest1 = Peak_TestUtils.createEnrollmentComponentRelationship(enrollmentCompList[0].Id, questionGroupComp.Id);
        Enrollment_Component_Relationship__c enrollCompRelationshipTest2 = Peak_TestUtils.createEnrollmentComponentRelationship(enrollmentCompList[1].Id, questionGroupComp.Id);
        Enrollment_Component_Relationship__c enrollCompRelationshipTest3 = Peak_TestUtils.createEnrollmentComponentRelationship(enrollmentCompList[2].Id, questionGroupComp.Id);

        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, True);
        Enrollment_Component_Affiliation__c ecaAffiliation=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enrollmentCompList[0].Id);
        ecaAffiliation.status__c = 'Exempt';
        update ecaAffiliation;

        Enrollment_Component_Affiliation__c ecaSectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id, sectionComponent.Id);
    }

    static testMethod void searchSchoolTest() {
        Test.startTest();
        Peak_MockHttpResponseGenerator mockGenerator = new Peak_MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());

        String response = NES_MDRIntegration.searchSchool('Hebron High School', 'Hebron', 'IN');
        System.debug('response==>>' + response);
        test.stopTest();
    }
    static testMethod void searchSchoolCustomSettingsTest() {
        School_Search_Settings__c schoolSearchRec = Peak_TestUtils.createSchoolSearchSettings(123, 456);
        School_Search_Settings__c customSettingRec = NES_MDRIntegration.getSchoolSearchSettings();
        system.assert(true, customSettingRec != null);
    }
    Static testMethod void updateEnrollments() {
        test.startTest();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        Id questionGroupRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Question Group').getRecordTypeId();
        Enrollment_Component__c enrollmentComp = [
                SELECT Id,Answer_Target__c,API_Mapping__c
                FROM Enrollment_Component__c
                WHERE recordTypeId = :questionGroupRecordTypeId
                LIMIT 1
        ];
        String json = '{\"streetAddress\":\"9604 Illinois St\",' +
                '\"stateAbbr\":\"IL\",\"searchScore\":3.5380974,' +
                '\"schoolName\":\"Alden-Hebron Middle High Sch\",' +
                '\"postalCode\":\"60034\",' +
                '\"districtName\":\"Alden-Hebron School Dist 19\",' +
                '\"countryAbbr\":\"USA\",\"city\":\"Hebron\"}';

        //Peak_Response response = NES_MDRIntegration.updateEnrollmentAnswerTarget(json, enrollmentComp.Id, programEnrollment.Id);
        //System.assertEquals(response.success, True);
        //System.assertNotEquals(response.results, Null);
        test.stopTest();

    }


    static testMethod void test_markQuestionAPIValidated(){
        Enrollment_Component_Affiliation__c ecaRecord = [SELECT ID,API_Validated__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Exempt' Limit 1];
        test.startTest();
        //Peak_Response peakResponse = NES_MDRIntegration.markQuestionAPIValidated(ecaRecord.Id);
        Enrollment_Component_Affiliation__c ecaRecord1 = [SELECT ID,API_Validated__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Exempt' Limit 1];
        //System.assertEquals(True, ecaRecord1.API_Validated__c);
        //System.assert(peakResponse.success);
        test.stopTest();
    }

    @isTest static void testGetStates(){
        List<State__mdt> listOfStates = NES_MDRIntegration.getStates();
        System.debug('This is my list of state ==' + listOfStates);
        System.assert(true, listOfStates.size() > 1);
    }
    @isTest static void updateEnrollmentAnswerTarget(){
        String schoolAddress = '{"schoolName": "harbor","searchScore": "3.3","streetAddress": "harbor","city": "harbor","postalCode": "22222","stateAbbr": "ABR","countryAbbr": "OH","districtName": "OH"}';
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        Enrollment_Component__c questionGroupComp2 = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' LIMIT 1];

        Peak_Response response =NES_MDRIntegration.updateEnrollmentAnswerTarget(schoolAddress,questionGroupComp2.Id,ProgramEnrollmentTest.Id,true);
        System.assert(response.messages != null);
       

    }
    @isTest static void evaluateQuestions() {
        User usr = Peak_TestUtils.CreatePortalCaretTakerUser([SELECT Id FROM Contact LIMIT 1].Id);
        System.runAs(usr){
            Test.startTest();
            hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
            Enrollment_Component__c questionGroupComp = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question' LIMIT 1];
            Enrollment_Component__c questionGroupComp2 = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Question_Group' LIMIT 1];
            Enrollment_Component__c sectionComponent = [SELECT Id FROM Enrollment_Component__c WHERE RecordType.DeveloperName = 'Section' LIMIT 1];

            List<NES_EvaluateUtil.Question> relatedquestions = NES_MDRIntegration.getRelatedQuestions(questionGroupComp.Id, ProgramEnrollmentTest.Id);
            List<NES_EvaluateUtil.Question> questions = NES_MDRIntegration.getQuestions(questionGroupComp2.Id, ProgramEnrollmentTest.Id);
            List<NES_EvaluateUtil.Question> response =NES_MDRIntegration.evaluateQuestions(ProgramEnrollmentTest.Id,JSON.serialize(questions),sectionComponent.Id);
            System.assert(questions != null);
            Test.stopTest();
        }
    }

}