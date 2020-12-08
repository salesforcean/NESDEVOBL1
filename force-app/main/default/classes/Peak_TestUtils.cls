// ===================
// Peak Test Utils
// ===================
@isTest
public class Peak_TestUtils {
    public Peak_TestUtils() {

    }

    public static User createStandardUserNoContact() {
        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :Peak_TestConstants.COMMUNITY_PROFILE];
        User testUser;
        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            testUser = new User(Alias = Peak_TestConstants.STANDARD_ALIAS, Email = Peak_TestConstants.STANDARD_EMAIL, EmailEncodingKey = Peak_TestConstants.ENCODING, FirstName = Peak_TestConstants.FIRSTNAME, LastName = Peak_TestConstants.LASTNAME, LanguageLocaleKey = Peak_TestConstants.LOCALE, LocaleSidKey = Peak_TestConstants.LOCALE, ProfileId = standardProfile.Id, TimeZoneSidKey = Peak_TestConstants.TIMEZONE, UserName = Peak_TestConstants.STANDARD_USERNAME);
        }

        return testUser;
    }

    // Create a standard user
    public static User createStandardUser() {
        Contact contact = createTestContact();
        User testUser;

        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :Peak_TestConstants.COMMUNITY_PROFILE];

        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            testUser = new User(Alias = Peak_TestConstants.STANDARD_ALIAS, Email = Peak_TestConstants.STANDARD_EMAIL, EmailEncodingKey = Peak_TestConstants.ENCODING, FirstName = Peak_TestConstants.FIRSTNAME, LastName = Peak_TestConstants.LASTNAME, LanguageLocaleKey = Peak_TestConstants.LOCALE, LocaleSidKey = Peak_TestConstants.LOCALE, ProfileId = standardProfile.Id, TimeZoneSidKey = Peak_TestConstants.TIMEZONE, UserName = Peak_TestConstants.STANDARD_USERNAME);
            testUser.ContactId = contact.id;
        }




        return testUser;
    }


    // Create a guest user
    public static User createGuestUser() {
        List < Profile > standardProfileList;
        User guestUser;

        try {
            standardProfileList = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        } catch (DmlException e) {
            System.debug(e);
        }

        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            guestUser = new User(Alias = Peak_TestConstants.GUEST_ALIAS, Email = Peak_TestConstants.GUEST_EMAIL, EmailEncodingKey = Peak_TestConstants.ENCODING, FirstName = Peak_TestConstants.FIRSTNAME, LastName = Peak_TestConstants.LASTNAME, LanguageLocaleKey = Peak_TestConstants.LOCALE, LocaleSidKey = Peak_TestConstants.LOCALE, ProfileId = standardProfile.Id, TimeZoneSidKey = Peak_TestConstants.TIMEZONE, UserName = Peak_TestConstants.GUEST_USERNAME);
        }

        return guestUser;
    }

    // Create an account so we can create a Contact
    public static Account createTestAccount() {
        Account account = new Account(name = Peak_TestConstants.ACCOUNT_NAME ,Too_Young_Cutoff__c =System.today() );
        insert account;
        return account;
    }

    // Create a contact associated with an account
    public static Contact createTestContact() {
        Account account = createTestAccount();
        Contact contact = new Contact(firstName = Peak_TestConstants.FIRSTNAME, lastName = Peak_TestConstants.LASTNAME, email = Peak_TestConstants.STANDARD_EMAIL);
        contact.accountId = account.id;
        insert contact;

        return contact;
    }

    // Create an attachment
    public static Attachment createAttachment(Id parentId) {
        Attachment attachment = new Attachment();
        Blob bodyBlob = Blob.valueOf('');
        attachment.ParentId = parentId;
        attachment.body = bodyBlob;
        attachment.Name = Peak_TestConstants.FIRSTNAME;
        return attachment;
    }

    // Fake ID Peak_TestUtils.getFakeId(User.SObjectType));
    public static String getFakeId(Schema.SObjectType sot) {
        Integer s_num = 1;
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    // Internal Chatter Group (No Network Id)
    public static CollaborationGroup createChatterGroup(String groupName, String collaborationType) {
        CollaborationGroup testGroup = new CollaborationGroup(
                Name = groupName,
                CollaborationType = collaborationType
        );
        return testGroup;
    }

    // Community Chatter Group (Has Network Id)
    // Note: Apex does not allow the creation of a Network(Community) within Tests. The Network Id will need to be
    // referenced on the fly within the individual org where a Network(Community) already exists
    public static CollaborationGroup createChatterGroup(String groupName, String collaborationType, String networkId) {
        CollaborationGroup testGroup = new CollaborationGroup(
                Name = groupName,
                CollaborationType = collaborationType,
                NetworkId = networkId
        );
        return testGroup;
    }

    // Chatter Group Membership
    // Note: when adding a group member, if the group is not attached to a Network(community), then the user must be a
    // non-community user (Not a partner profile).
    public static CollaborationGroupMember createGroupMembership(String groupId, Id userId) {
        CollaborationGroupMember groupMembership = new CollaborationGroupMember();
        groupMembership.CollaborationGroupId = groupId;
        groupMembership.MemberId = userId;
        groupMembership.CollaborationRole = 'Standard';
        return groupMembership;
    }

    public static Opportunity createOpportunity(Id userId, String forecastCategoryName) {
        Opportunity newOpportunity = new Opportunity(
                Amount = Peak_TestConstants.AMOUNT,
                OwnerId = userId,
                ForecastCategoryName = forecastCategoryName,
                Name = Peak_TestConstants.OPP_NAME,
                StageName = Peak_TestConstants.STAGE_NAME,
                CloseDate = Peak_TestConstants.TODAY
        );
        return newOpportunity;
    }


    public static List < Topic > createTopics(Integer howMany, Id networkId) {
        List < topic > topicList = new List < topic > ();
        for (Integer i = 0; i < howMany; i++) {
            Topic topicObj = new Topic(Name = 'Test00' + i, Description = 'Test', NetworkId = networkId);
            topicList.add(topicObj);
        }
        return topicList;
    }

    public static TopicAssignment createTopicAssignment(Id strTopicId, Id strEntityId, Id networkId) {
        TopicAssignment topicAssigmnt = new TopicAssignment(EntityId = strEntityId, TopicId = strTopicId, NetworkId = networkId);
        return topicAssigmnt;
    }

    public static List < FeedItem > createFeedItems(Integer howMany, Id networkId, Id parentId) {
        List < FeedItem > feedItems = new List < FeedItem > ();

        for (Integer i = 0; i < howMany; i++) {
            FeedItem feedItem = new FeedItem();
            feedItem.Title = Peak_TestConstants.TEST_MESSAGE;
            feedItem.Body = Peak_TestConstants.TEST_DESCRIPTION;
            feedItem.ParentId = parentId;
            feedItem.NetworkScope = networkId;
            feedItems.add(feedItem);
        }

        return feedItems;
    }

    // -------------------------------------------------------------------------------------------------------------------------------------- //
    /**
    Created by : Anushka Bansal
    Purpose : To create Account of 'Educational Institution' record type.
    Parameters : none
    Return : Account record.
    **/
    public static Account createEducationalInstitutionAccount() {
        Id educationalInstitutionRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Account account = new Account(name = Peak_TestConstants.ACCOUNT_NAME,
                recordTypeId = educationalInstitutionRecType,Too_Young_Cutoff__c = System.today() //Added By Anand 1/5/2018
        );
        insert account;
        return account;
    }


    /**
    Created by : Anushka Bansal
    Purpose : To create Account of 'Academic Program' record type.
    Parameters : Parent Account Id, School Year Id.
    Return : Account record.

    **/
    public static Account createAccountForNewStudentData(String accountId, String schoolYearId) {
        //Account accnt = createEducationalInstitutionAccount();
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account account = new Account(name = Peak_TestConstants.ACCOUNT_NAME,
                recordTypeId = programEnrollmentRecordTypeId,
                ParentId = accountId,
                School_Year__c = schoolYearId,
                Registration_Start_Date__c = system.Today(),
                Registration_End_Date__c = system.Today(),
                Too_Young_Cutoff__c = System.today(), //Added By Anand 1/5/2018
                School_Id__c = accountId);
        insert account;
        return account;
    }

    /**
       Created by : Anushka Bansal
       Purpose : To create Contact records of different record types.
       Parameters : record type name, account id
       Return : Contact record.
       **/
    public static Contact createTestContact(String recordType, String accountId) {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        Contact contact = new Contact(firstName = Peak_TestConstants.FIRSTNAME, lastName = 'test', email = Peak_TestConstants.STANDARD_EMAIL, recordTypeId = contactRecordTypeId);
        contact.accountId = accountId;
        insert contact;

        return contact;
    }

    /**
    Created by : Anushka Bansal
    Purpose : To create a School Year record
    Parameters : Name of School Year, Start Date
    Return : School_Year__c record.
    **/
    public static School_Year__c createSchoolYears(String name, Date startDate) {
        School_Year__c schoolYear = new School_Year__c(Name = name, End_Date__c = startDate.addDays(20), Start_Date__c = startDate);
        insert schoolYear;
        return schoolYear;
    }


    /**
    Created by : Anushka Bansal
    Purpose : To create a Program Enrollment record
    Parameters : 'Academic Program' Account Id, Contact Id, School Year Id, isInsert
    Return : hed__Program_Enrollment__c record.
    **/
    public static hed__Program_Enrollment__c createProgramEnrollment(string accountId, string contactId, String startYear, Boolean isInsert) {
        // List<School_Year__c> schoolYears = createSchoolYears();
        hed__Program_Enrollment__c programEnrollments = new hed__Program_Enrollment__c();
        programEnrollments.hed__Contact__c = contactId;
        programEnrollments.hed__Account__c = accountId;
        programEnrollments.Start_Year__c = startYear;

        if (isInsert)
            insert programEnrollments;

        return programEnrollments;

    }

    /**
     Created by : Anushka Bansal
     Purpose : To create a Enrollment Component record
     Parameters : School Year Id, record type name, isInsert
     Return : Enrollment_Component__c record.
     **/
    public static Enrollment_Component__c createEnrollmentComponent(String schoolId, String recordTypeName, Boolean isInsert) {
        RecordType recordType = [
                Select id, Name
                from RecordType
                where Sobjecttype = 'Enrollment_Component__c'
                and developerName = :recordTypeName
                limit 1
        ];
        Enrollment_Component__c enrollmentComp = new Enrollment_Component__c();
        enrollmentComp.Process_Academic_Program__c = schoolID;
        enrollmentComp.Assignment_Logic__c = '(1 OR 2 OR 3)';
        enrollmentComp.recordTypeId = recordType.Id;
        enrollmentComp.Document_Type__c = '504 Plan';
        enrollmentComp.Document_Submission_End_Date__c = Date.today().addDays(3);
        enrollmentComp.Document_Submission_Start_Date__c = Date.today().addDays(-3);
        
        if(recordType.Name =='Question'){
            enrollmentComp.Question_Type__c = 'Phone'; // if condition Added by Raju
            enrollmentComp.Answer_Target__c = 'Opportunity.notes__c';
        }
        
        if(isInsert)
        insert enrollmentComp;
        return enrollmentComp;
    }

    /**
    Created by : Anushka Bansal
    Purpose : To create a Enrollment Component Relationship record
    Parameters : child Enrollment Component Id, parent Enrollment Component Id
    Return : Enrollment_Component_Relationship__c record.
    **/
    public static Enrollment_Component_Relationship__c createEnrollmentComponentRelationship(String componentId, String parentId) {
        // RecordType recordType = [Select id from RecordType where Sobjecttype='Enrollment_Component__c' and developerName =: recordTypeName limit 1];
        // Enrollment_Component__c enrollmentComp = new Enrollment_Component__c();
        Enrollment_Component_Relationship__c compRelationship = new Enrollment_Component_Relationship__c();
        compRelationship.Child_Enrollment_Component__c = componentId;
        compRelationship.Parent_Enrollment_Component__c = parentId;
        compRelationship.Order__c = 1;
        insert compRelationship;
        return compRelationship;
    }

    /**
    Created by : Anushka Bansal
    Purpose : To create a Enrollment Document record
    Parameters : Program Enrollment Id, status
    Return : Enrollment_Document__c record.
    **/
    public static Enrollment_Document__c createEnrollmentDocument(String progEnrollmentId, String status) {
        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :'Caretaker Community User'];
        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            User u = [
                    Select id, contactId
                    from User
                    where ProfileId = :standardProfile.Id
                    and isActive = True
                    limit 1
            ];
            Enrollment_Document__c doc = new Enrollment_Document__c();
            doc.Program_Enrollment__c = progEnrollmentId;
            doc.Document_Link__c = 'test';
            doc.Document__c = 'Test';
            doc.Type__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_TYPE;
            doc.Status_Reason__c = status;
            doc.Uploader__c = u.Id;
            insert doc;
            return doc;
        }
        return null;

    }

    /**
     Created by : Anushka Bansal
     Purpose : To create Enrollment Component Affiliation records
     Parameters : Program Enrollment Id, Enrollment Component Id, isInsert
     Return : Enrollment_Component_Affiliation__c record.
     **/
    public static Enrollment_Component_Affiliation__c createEnrollmentComponentAffiliation(String programEnrollmentId, String componentId) {

        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'Complete';
        compAffiliation.Date_Completed__c = System.today();
        compAffiliation.Deferral_Date__c = System.today();
        compAffiliation.Program_Enrollment__c = programEnrollmentId;
        compAffiliation.Enrollment_Component__c = componentId;

        try {
            insert compAffiliation;
        } catch (exception ex) {
            System.debug('ex++' + ex);
        }
        return compAffiliation;
    }


    /**
    Created by : Anushka Bansal
    Purpose : To create Enrollment Component Picklist Option records
    Parameters : Enrollment Component Id, isInsert
    Return : Enrollment_Component_Picklist_Option__c record.
    **/
    public static Enrollment_Component_Picklist_Option__c createEnrollmentComponentPicklistOption(String componentId, Boolean isInsert) {
        Enrollment_Component_Picklist_Option__c picklistpOption = new Enrollment_Component_Picklist_Option__c();
        picklistpOption.Enrollment_Component__c = componentId;
        picklistpOption.Option_Label__c = 'K';
        picklistpOption.Option_Value__c = 'K';
        picklistpOption.Order__c = 1.0;

        if (isInsert)
            insert picklistpOption;
        return picklistpOption;
    }


    /**
    Created by : Anushka Bansal
    Purpose : To create Comment records
    Parameters : Program Enrollment Id
    Return : Comment__c record.
    **/
    public static Comment__c createComment(String programEnrollmentId) {

        Comment__c comment = new Comment__c();
        comment.Program_Enrollment__c = programEnrollmentId;
        comment.Comment__c = 'Sample';
        insert comment;
        return comment;
    }


    /**
       Created by : Anushka Bansal
       Purpose : To create/insert Special Education records
       Parameters : Program Enrollment Id, isInsert
       Return : Special_Education__c record.

    **/
    public static Special_Education__c createSpecialEducation(String programEnrollmentId, Boolean isInsert) {
        Special_Education__c specialEducation = new Special_Education__c(
                IEP__c = 'IEP',
                Program_Enrollment__c = programEnrollmentId
        );

        if (isInsert)
            insert specialEducation;
        return specialEducation;
    }


    /**
       Created by : Anushka Bansal
       Purpose : To create/insert Annual Student Information records
       Parameters : Name, Program Enrollment Id, School Year Id, isInsert
       Return : Annual_Student_Information__c record.

    **/
    public static Annual_Student_Information__c createAnnualStudentInformation(String name, String progEnrollmentId, String startYear, Boolean isInsert) {
        Annual_Student_Information__c asi = new Annual_Student_Information__c();
        asi.name = name;
        asi.Program_Enrollment__c = progEnrollmentId;
        asi.School_Year__c = startYear;

        if (isInsert)
            insert asi;

        return asi;
    }


    /**
       Created by : Anushka Bansal
       Purpose : To create/insert Relationship records
       Parameters : Contact Id, Related Contact Id
       Return : hed__Relationship__c record.

    **/
    public static hed__Relationship__c createRelationship(String contactId, String relatedConId, Boolean isInsert) {
        hed__Relationship__c relationship = new hed__Relationship__c();
        relationship.hed__RelatedContact__c = relatedConId;
        relationship.hed__Contact__c = contactId;
        relationship.hed__Status__c = 'Current';
        relationship.hed__Emergency_Contact__c = true;


        if (isInsert)
            insert relationship ;

        return relationship ;
    }

    // Create a standard user for contact with STUDENT Record Type
    public static User createStandardUser(String contactId) {
        User testUser;

        List < Profile > standardProfileList = [SELECT Id FROM Profile WHERE Name = :'Caretaker Community User'];

        if (!Peak_Utils.isNullOrEmpty(standardProfileList)) {
            Profile standardProfile = standardProfileList[0];
            testUser = new User(Alias = Peak_TestConstants.STANDARD_ALIAS, Email = Peak_TestConstants.STANDARD_EMAIL, EmailEncodingKey = Peak_TestConstants.ENCODING, FirstName = Peak_TestConstants.FIRSTNAME, LastName = Peak_TestConstants.LASTNAME, LanguageLocaleKey = Peak_TestConstants.LOCALE, LocaleSidKey = Peak_TestConstants.LOCALE, ProfileId = standardProfile.Id, TimeZoneSidKey = Peak_TestConstants.TIMEZONE, UserName = Peak_TestConstants.STANDARD_USERNAME);
            testUser.ContactId = contactId;
        }

        return testUser;
    }


    // To be deleted
    public static List < School_Year__c > createSchoolYears() {
        List < School_Year__c > schoolYears = new List < School_Year__c > ();
        for (Integer i = 0; i < 5; i++) {
            School_Year__c year = new School_Year__c(name = '2018' + i, End_Date__c = system.Today() + 10, Start_Date__c = system.Today());
            schoolYears.add(year);
        }
        insert schoolYears;
        return schoolYears;
    }

    /**
     * Created by Ashish Sharma on 12/04/18
     * Parameters: String, boolean
     * Return Type: Grade_Level__c
     * Purpose : Method to create Grade Level record for test class
    */
    public static Grade_Level__c createGradeLevel(String name, boolean isInserted) {
        Grade_Level__c gradeLevel = new Grade_Level__c(Name = name);

        if (isInserted) {
            insert gradeLevel;
        }

        return gradeLevel;
    }

    /**
     * Created by Ashish Sharma on 12/04/18
     * Parameters: String, boolean
     * Return Type: Program_Grade_Level__c
     * Purpose : Method to create Program Grade Level record for test class
    */
    public static Program_Grade_Level__c createProgramGradeLevel(String name, Id accountId, Id gradeLevel,
            Datetime pushToSecondSemester, boolean isInserted) {
        Program_Grade_Level__c programGradeLevel = new Program_Grade_Level__c(Name = name, Academic_Program__c = accountId,
                Grade_Level__c = gradeLevel, PushToSecondSemester__c = pushToSecondSemester);

        if (isInserted) {
            insert programGradeLevel;
        }

        return programGradeLevel;
    }

    /**
     * Created by Ritvik on 12/04/18
     * Parameters: String,Id, boolean
     * Return Type: Criteria_Group__c
     * Purpose : Method to create Criteria Group record for test class
    */
    public static Criteria_Group__c createCriteriaGroup(String name, Id enrollCompId, boolean isInserted) {
        Criteria_Group__c criteriaGroup = new Criteria_Group__c(Enrollment_Component__c = enrollCompId);
        if (isInserted) {
            insert criteriaGroup;
        }

        return criteriaGroup;
    }

    /**
     * Created by Ritvik on 12/04/18
     * Parameters: String,Id, boolean
     * Return Type: Enrollment_Component_Criteria__c
     * Purpose : Method to create Enrollment Component Criteria record for test class
    */
    public static Enrollment_Component_Criteria__c createEnrollCompCriteria(String name, Id enrollCompId, boolean isInserted) {
        Enrollment_Component_Criteria__c enrollCompCriteria = new Enrollment_Component_Criteria__c(Enrollment_Component__c = enrollCompId);
        if (isInserted) {
            insert enrollCompCriteria;
        }

        return enrollCompCriteria;
    }

    /**
   * Created by Ritvik on 12/05/18
   * Parameters: Id, boolean
   * Return Type: Enrollment_Document__c
   * Purpose : Method to create test Enrollment Document record for test class
  */
    public static Enrollment_Document__c createEnrollmentDocumentRecord(String programEnrollmentId, String type, String status, boolean isInserted) {
        Enrollment_Document__c testEnrollmentDocument = new Enrollment_Document__c(Program_Enrollment__c = programEnrollmentId, Type__c = type, Status_Reason__c = status);

        if (isInserted) {
            insert testEnrollmentDocument;
        }

        return testEnrollmentDocument;
    }

    /**
   * Created by Ritvik on 12/05/18
   * Parameters: String, String, Boolean
   * Return Type: Enrollment__c
   * Purpose : Method to create test Enrollment record for test class
   */
    public static Enrollment__c createEnrollmentRecord(String programEnrollmentId, String schoolYearId, boolean isInserted) {
        Enrollment__c enrollmentRecord = new Enrollment__c(Program_Enrollment__c = programEnrollmentId, School_Year__c = schoolYearId);

        if (isInserted) {
            insert enrollmentRecord;
        }

        return enrollmentRecord;
    }

    /**
   * Created by Ritvik on 12/17/18
   * Parameters: String, String, boolean
   * Return Type: Home_Language_Survey__c
   * Purpose : Method to create test Home_Language_Survey__c record for test class
   */
    public static Home_Language_Survey__c createHomeLanguageSurveyRecord(String name, String programEnrollmentId, boolean isInserted){
        Home_Language_Survey__c hlsRecord = new Home_Language_Survey__c(Name = name, Program_Enrollment__c = programEnrollmentId);

        if (isInserted) {
            insert hlsRecord;
        }

        return hlsRecord;
    }

    /**
     * Created by Raju on 12/05/18
     * Parameters: String, String
     * Return Type: Account
     * Purpose : Method to create Account record for test class
    */
    public static Account createAccountRecord(String name, String recordTypeName) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Account account = new Account(Name = name, RecordTypeId = recordTypeId, Too_Young_Cutoff__c =System.today());
        insert account;
        return account;
    }

    /**
    * Created by Raju on 12/05/18
    * Parameters: Id,Id boolean
    * Return Type: Document_Review__c
    * Purpose : Method to create Enrollment Document record for test class
   */
    public static Document_Review__c createDocumentReviewRecord(Id academicProgramId, Id householdId) {
        Document_Review__c documentReview = new Document_Review__c(Academic_Program__c = academicProgramId, Household__c = householdId, Status__c = 'In Progress', Queue_Type__c = 'Academic');
        insert documentReview;

        return documentReview;
    }


    /**
    * Created by Raju on 12/05/18
    * Parameters: Id, Id
    * Return Type: Enrollment_Document__c
    * Purpose : Method to create Enrollment Document record for test class
   */
    public static Enrollment_Document__c createEnrollmentDocumentRecord(Id enrollmentComponentAffiliationId, Id programEnrollmentId) {
        Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c(Enrollment_Component_Affiliation__c = enrollmentComponentAffiliationId, Program_Enrollment__c = programEnrollmentId);
        //enrollmentDocument.Reason__c = 'Accepted';
        enrollmentDocument.Type__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_TYPE;
        enrollmentDocument.Status_Reason__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_SUBMITTED;
        //enrollmentDocument.Document_Link__c ='xyz';
        insert enrollmentDocument;

        return enrollmentDocument;
    }

    /**
    * Created by Raju on 12/05/18
    * Parameters: Id, boolean
    * Return Type: Enrollment_Document__c
    * Purpose : Method to create Enrollment Document record for test class
   */
    public static Enrollment_Document__c createEnrollmentDocumentRecord(Id programEnrollmentId) {
        Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c(Program_Enrollment__c = programEnrollmentId);
        insert enrollmentDocument;

        return enrollmentDocument;
    }

    /**
  * Created by Raju on 12/05/18
  * Parameters: Id, boolean
  * Return Type: Enrollment_Document__c
  * Purpose : Method to create Enrollment Document record for test class
 */
    public static Enrollment_Document__c createEnrollmentDocumentRecord(Id programEnrollmentId, Id documentReviewId, Boolean isInserted) {
        Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c(Program_Enrollment__c = programEnrollmentId, Document_Review__c = documentReviewId);
        insert enrollmentDocument;

        return enrollmentDocument;
    }

    /**
  * Created by Raju on 12/05/18
  * Parameters: Id, Id, Id
  * Return Type: Enrollment_Document__c
  * Purpose : Method to create Enrollment Document record for test class
 */
    public static Enrollment_Document__c createEnrollmentDocumentRecord(Id enrollmentComponentAffiliationId, Id programEnrollmentId, Id documentReviewId) {
        Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c(Document_Review__c = documentReviewId, Enrollment_Component_Affiliation__c = enrollmentComponentAffiliationId, Program_Enrollment__c = programEnrollmentId);
        insert enrollmentDocument;

        return enrollmentDocument;
    }

    /**
     Created by : Raju
     Purpose : To create Enrollment Component Affiliation records
     Parameters : Program Enrollment Id
     Return : Enrollment_Component_Affiliation__c record.
     **/
    public static Enrollment_Component_Affiliation__c createEnrollmentComponentAffiliation(String programEnrollmentId) {

        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'Complete';
        compAffiliation.Date_Completed__c = System.today();
        compAffiliation.Deferral_Date__c = System.today();
        compAffiliation.Program_Enrollment__c = programEnrollmentId;
        
        insert compAffiliation;

        return compAffiliation;
    }
    /**
        * Created By Raju on 12/5/2018
        * purpose to Create Opportunity record
      */
    public static Opportunity createOpportunity(Id programEnrollmentId) {
        Opportunity newOpportunity = new Opportunity(
                Program_Enrollment__c = programEnrollmentId,
                Name = Peak_TestConstants.OPP_NAME,
                StageName = Peak_TestConstants.STAGE_NAME,
                CloseDate = Peak_TestConstants.TODAY,
                Notes__c ='56988'
        );
        insert newOpportunity;
        return newOpportunity;
    }
    /**
     * Created By Anand on 12/5/2018
     * purpose to Create address Search custom settings
     * @param keyStroke
     * @param minChar
     *
     * @return Address_Search_Settings__c
     */

    public Static Address_Search_Settings__c createAddressSearchSettings(Decimal keyStroke, Decimal minChar) {
        Address_Search_Settings__c addressSearchRec = new Address_Search_Settings__c();
        addressSearchRec.Keystroke_Delay__c = keyStroke;
        addressSearchRec.Minimum_Characters__c = minChar;
        insert addressSearchRec;
        return addressSearchRec;
    }
    /**
    * Created By Anand 12/5/2018
    * puprose : Method to create opportunity on Before Insert Trigger for Opportunity
    * */
    public static opportunity createOpportunity(String optyName, String accountId, Date closeDate, String stage, Boolean isInsert) {
        Opportunity opty = new Opportunity(
                Name = optyName,
                StageName = stage,
                CloseDate = closeDate,
                AccountId = accountId

        );
        if (isInsert) {
            Insert opty;
        }
        return opty;
    }

    /**
    * Created By Raju 12/7/2018
    * puprose : Method to create case
    * */

    public static Case createCase(Id caretakerId, String status) {
        Case caseRecord = new Case(ContactId = caretakerId, Status = status, Subject = 'Test Case', Description = 'Test Case Created', System_of_Origin__c = 'New Enrollment');
        insert caseRecord;
        return caseRecord;
    }

    /**
    * Created By Raju 12/7/2018
    * puprose : Method to create Account
    * */
    public static Account createAccount(String name, Id schoolYearId, Id ParentAccId) {
        Id academicProgramRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account account = new Account(Name = name,
                recordTypeId = academicProgramRecordTypeId,
                Confirmation_End_Date__c = System.Now().addYears(1),
                ParentId = ParentAccId,
                School_Year__c = schoolYearId,
                Too_Young_Cutoff__c =System.today()
        );
        insert account;
        return account;
    }

    /**
       Created by : Raju
       Purpose : To create Contact records of different record types.
       Parameters : record type name, account id
       Return : Contact record.
       **/
    public static Contact createTestContact(String lastName, String recordType, String accountId) {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        Contact contact = new Contact(firstName = Peak_TestConstants.FIRSTNAME, lastName = lastName, email = Peak_TestConstants.STANDARD_EMAIL, recordTypeId = contactRecordTypeId);
        contact.accountId = accountId;
        insert contact;
        return contact;
    }


    /**
       Created by : Raju
       Purpose : To create an Enrollment Component record
       **/
    public static Enrollment_Component__c createEnrollmentComponent(String name, String recordType) {
        Id ecRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        Enrollment_Component__c ecRecord = new Enrollment_Component__c(Name = name, RecordTypeId = ecRecordTypeId);
        if(recordType=='Question'){
            ecRecord.Question_Type__c = 'Phone';
            ecRecord.Answer_Target__c = 'Opportunity.notes__c';
        }
        if(recordType=='Document'){
            ecRecord.Document_Type__c = Peak_TestConstants.TEST_ENROLLMENT_DOC_TYPE;
        }
        insert ecRecord;
        return ecRecord;
    }
    /**
    Created by : Anand
    Purpose : To create an PriorSchool
    **/
    public static Prior_School__c createPriorSchool(String prEnrollment, String SchoolType, Boolean isInsert) {
        Prior_School__c schl = new Prior_School__c(Program_Enrollment__c = prEnrollment, SchoolType__c = SchoolType);
        if (isInsert) {
            insert schl;
        }
        return schl ;
    }


    /**
    Created by : Anushka Bansal
    Purpose : To create Custom setting data for Trigger logic switch
    **/

    public static NES_LogicFeatureSwitch__c createNESBusinessLogicSwitch(String Name, Boolean isInsert) {
        NES_LogicFeatureSwitch__c logicSwitch = new NES_LogicFeatureSwitch__c(Name = Name, Active__c = true);
        if (isInsert)
            insert logicSwitch ;
        return logicSwitch;
    }
    /**
     * Created by Anand 12/12/2018
     * purpose: Create a Announcment
     * @param AnnouncementtName
     * @param isInsert
     *
     * @return
     */
    public Static Announcement__c createAnnouncement(String AnnouncementtName, Boolean isInsert) {
        Announcement__c announcement = new Announcement__c(Name = AnnouncementtName);
        if (isInsert) {
            Insert announcement;
        }
        return announcement;
    }
    /**
     * Created By Anand 12/12/2018
     *purpose: Create a contact Announcement
     * @param Name
     * @param contactId
     * @param AnnouncmentId
     * @param isInsert
     *
     * @return contact_announcement__c
     */
    public Static contact_announcement__c createContactAnnouncement(String conAnnouncementName, String contactId, String announcementId, Boolean isInsert) {
        contact_announcement__c conAnnouncement = new contact_announcement__c(
                Name = conAnnouncementName,
                Contact__c = contactId,
                Announcement__c = announcementId
        );
        if (isInsert) {
            Insert conAnnouncement;
        }
        return conAnnouncement;
    }
    /**
     * Created By Anand on 12/18/2018
     *purpose: To create user with ContactId
     * @return user
     */


    public static User CreatePortalCaretTakerUser(){
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Caretaker Community User' LIMIT 1];
        UserRole pearsonRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Pearson_Community_Manager' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator'
                AND IsActive = TRUE AND UserRoleId =: pearsonRole.Id LIMIT 1];
        User user_1;

        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community', Too_Young_Cutoff__c = System.today(), OwnerId = admin.Id);
            insert account_1;
            Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();

            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek',RecordTypeId=studentRecordTypeId);
            insert contact_1;
            System.debug('Student Id'+ contact_1.Id);
            user_1 = new User (
                    Email = 'userTest@gmail.com',
                    ProfileId = profile_1.Id,
                    Username = 'portalUser@gmail.com',
                    Alias = 'Test',
                    TimeZoneSidKey = 'America/New_York',
                    EmailEncodingKey = 'ISO-8859-1',
                    LocaleSidKey = 'en_US',
                    IsActive = true,
                    LanguageLocaleKey = 'en_US',
                    ContactId = contact_1.Id,
                    PortalRole = 'Manager',
                    FirstName = 'Testing',
                    LastName = 'Portal User'
            );
            insert user_1;

        }
        System.debug('Useri====>>>'+user_1);
        System.debug('UseriContactId====>>>'+user_1.ContactId);

        return user_1;
    }

    /**
     * Created By Ajith on 02/20/2018
     *purpose: To create user with ContactId passed in
     * @return user
     */


    public static User CreatePortalCaretTakerUser(Id contactId){

        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Caretaker Community User' LIMIT 1];
        UserRole pearsonRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Pearson_Community_Manager' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId =: pearsonRole.Id LIMIT 1];

        User user_1;

        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id =:contactId];
        Account portalAccount = [SELECT Id, OwnerId FROM Account WHERE Id =:con.AccountId];
        portalAccount.OwnerId = admin.Id;
        update portalAccount;

        System.runAs(admin) {
            System.debug('Care Taker Contact Id'+ contactId);
            user_1 = new User (
                    Email = 'userTest@gmail.com',
                    ProfileId = profile_1.Id,
                    UserName = 'portalUser@gmail.com',
                    Alias = 'Test',
                    TimeZoneSidKey = 'America/New_York',
                    EmailEncodingKey = 'ISO-8859-1',
                    LocaleSidKey = 'en_US',
                    isActive = true,
                    LanguageLocaleKey = 'en_US',
                    ContactId = contactId,
                    PortalRole = 'Manager',
                    FirstName = 'Testing',
                    LastName = 'Portal User'
            );
            insert user_1;

        }
        System.debug('Useri====>>>'+user_1);
        System.debug('UseriContactId====>>>'+user_1.ContactId);

        return user_1;
    }

    /**Created By Anand on 12/18/2018
     *
     */
    public Static Contact createContact(String conName,String accId,String recordType,Boolean IsInsert){
    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
    Contact contactTest = new Contact(lastName =conName ,  recordTypeId = contactRecordTypeId,accountId = accId);

    if(isInsert){
    Insert contactTest;
    }
        return contactTest;
    }
    
    /**
       Created by : Raju 
       Purpose : To create/insert Annual Household Information records
       Parameters : Program Enrollment Id, School Year Id, isInsert
       Return : Annual_Household_Information__c record.

    **/
    public static Annual_Household_Information__c createAnnualHouseholdInformation(String progEnrollmentId, String startYear, Boolean isInsert) {
        Annual_Household_Information__c ahi = new Annual_Household_Information__c();
        ahi.Program_Enrollment__c = progEnrollmentId;
        ahi.School_Year__c = startYear;

        if (isInsert)
            insert ahi;

        return ahi;
    }
    /**
       Created by : Raju 
       Purpose : To create/insert  Household Income records
       Parameters : Program Enrollment Id, School Year Id, isInsert
       Return : Annual_Household_Information__c record.

    **/
    public static Household_Income__c createHouseholdIncome(String progEnrollmentId, String startYear, Boolean isInsert) {
        Household_Income__c hi = new Household_Income__c();
        hi.Program_Enrollment__c = progEnrollmentId;
        hi.School_Year__c = startYear;

        if (isInsert)
            insert hi;

        return hi;
    }

    /**
       Created by : Anushka
       Purpose : To create/insert  Placement and Elective records
       Parameters : Program Enrollment Id, isInsert
       Return : Placement_and_Elective__c record.

    **/
    public static Placement_and_Elective__c createPlacementAndElective(String progEnrollmentId, Boolean isInsert) {
        Placement_and_Elective__c pne = new Placement_and_Elective__c();
        pne.Program_Enrollment__c = progEnrollmentId;

        if (isInsert)
            insert pne;

        return pne;
    }

    /**
       Created by : Ritvik
       Purpose : To create/insert criteria records
       Parameters : Criteria name, Criteria field(left), Comparision Operator , isInsert.
       Return : Criteria__c record.

    **/
    public static Criteria__c createCriteriaRecord(String name, String field, String operator, Boolean isInsert){
        Criteria__c criteria = new Criteria__c(Criteria_Field__c = field, Operator__c = operator);

        if (isInsert)
            insert criteria;

        return criteria;
    }
    /**
     * Created By Anand on 12/27/2018
     * Purpose : To create a Academic Account
     * Return  Account
     */
    public static Account createAcademicAccount(String accountName , String accountId, String schoolYearId,Boolean isInsert) {
        //Account accnt = createEducationalInstitutionAccount();
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account account = new Account(name = accountName,
                recordTypeId = programEnrollmentRecordTypeId,
                ParentId = accountId,
                School_Year__c = schoolYearId,
                Too_Young_Cutoff__c =System.today()
                );
        if (isInsert) {
            insert account;
        }
        return account;

    }

    /**
    Created by : Anand
    Purpose : To create Enrollment Component Affiliation records
    Parameters : Program Enrollment Id, Enrollment Component Id, isInsert
    Return : Enrollment_Component_Affiliation__c record.
    **/
    public static Enrollment_Component_Affiliation__c createEnrollmentComponentAffiliation(String programEnrollmentId, String componentId,Boolean isInsert) {

        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'Complete';
        compAffiliation.Date_Completed__c = System.today();
        compAffiliation.Deferral_Date__c = System.today();
        compAffiliation.Program_Enrollment__c = programEnrollmentId;
        compAffiliation.Enrollment_Component__c = componentId;

       if(isInsert){
        try {
            insert compAffiliation;
        } catch (exception ex) {
            System.debug('ex++' + ex);
        }
       }
        return compAffiliation;
    }

    /**
    Created by : Ritvik
    Purpose : To create Records_Request__c records
    Parameters : Name,Program Enrollment Id, isInsert
    Return : Records_Request__c record.
    **/
    public static Records_Request__c createRecordsRequest(String name,String programEnrollmentId, Boolean isInsert){
        Records_Request__c recordsRequest = new Records_Request__c(Name = name, Program_Enrollment__c = programEnrollmentId);

        if (isInsert) {
            insert recordsRequest;
        }
        return recordsRequest;

    }
    /**
     * Created By Anand on 1/9/2019
     * purpose to Create School_Search_Settings__c Search custom settings
     * @param keyStroke
     * @param minChar
     *
     * @return School_Search_Settings__c
     */

      public Static School_Search_Settings__c createSchoolSearchSettings(Decimal keyStroke, Decimal minChar) {
        School_Search_Settings__c schoolSearchRecord = new School_Search_Settings__c();
         schoolSearchRecord.Name = '';
         schoolSearchRecord.Keystroke_Delay_Seconds__c = keyStroke;
         schoolSearchRecord.Minimum_Characters__c = minChar;
         insert schoolSearchRecord;
         return schoolSearchRecord;
    }
    /**
     *
     * Created By Anand To create Account
     * @param accountId
     * @param schoolYearId
     *
     * @return
     */
    public static Account createAccount(String accName,Boolean isInsert) {
        //Account accnt = createEducationalInstitutionAccount();

        Account account = new Account(name = accName);
        if(isInsert)
        insert account;
        
        return account;
    }
    }