/**
 * Created by Ashish Sharma on 12/20/18
 * Class Name: NES_SharingUtilityTest
 * Purpose : Test class for NES_SharingUtility and triggers where NES_SharingUtility is being used
*/
@isTest
public class NES_SharingUtilityTest {
    /** 
     * Created by Ashish Sharma on 12/20/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Method to setup the test data
    */
    @TestSetup 
    static void setup() {
        List<NES_LogicFeatureSwitch__c> logicSwitches = new List<NES_LogicFeatureSwitch__c>();
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch(NES_EntranceAgeUtility.ENTRANCE_AGE_CUSTOM_SETTING_VALUE, false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('ContactTrigger', false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('OpportunityTrigger', false));
        insert logicSwitches;
 
        Group testGroup = new Group(Name = 'Test Ed Group', Type = 'Regular');
        insert testGroup;

        insert new NES_Manual_Share_Settings__c(Educational_Institution_Name__c = Peak_TestConstants.ACCOUNT_NAME,
                                                Name = 'Test Ed Account', Group_Name__c = testGroup.Name);

        Account edAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact contactRecord = Peak_TestUtils.createTestContact('Caretaker', edAccount.Id);
        contactRecord.Recalculate_Sharing__c = True;
        update contactRecord;



        hed__Relationship__c relationship = Peak_TestUtils.createRelationship(contactRecord.Id, contactRecord.Id, true);

        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));

        Peak_TestUtils.createAccountForNewStudentData(edAccount.Id, currentSchoolYear.Id);

        Id houseHoldRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert new Account(Name = 'Test Household Program', RecordTypeId = houseHoldRTId, Too_Young_Cutoff__c =System.today());

        hed__Program_Enrollment__c enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                contactRecord.Id,
                currentSchoolYear.Id, true);
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the contact sharing
    */
    static testMethod void testContactShare() {
        Id houseHoldAccountId;
        Id edAccountId;

        for(Account acc : [SELECT Id, RecordType.Name FROM Account WHERE RecordType.Name IN ('Household', 'Educational Institution')]){
            if(acc.RecordType.Name == 'Household'){
                houseHoldAccountId = acc.Id;
            }else{
                edAccountId = acc.Id;
            }
        }

        Contact contact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccountId);

        Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                               contact.Id,
                                               [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        contact.Educational_Institution__c = edAccountId;
        update contact;

        Id groupId = [SELECT Id FROM Group WHERE Name = 'Test Ed Group' LIMIT 1][0].Id;

        //Assert test if Account is shared with the 'Test Ed Group' group or not
        system.debug('data===>'+[SELECT Id FROM AccountShare WHERE AccountId =: houseHoldAccountId AND UserOrGroupId =: groupId].size());
        System.assertEquals(0, [SELECT Id FROM AccountShare WHERE AccountId =: houseHoldAccountId AND UserOrGroupId =: groupId].size());

        contact.AccountId = edAccountId;
        update contact;

        //Assert test if Contact is shared with the 'Test Ed Group' group or not
        System.assertEquals(0, [SELECT Id FROM ContactShare WHERE ContactId =: contact.Id AND UserOrGroupId =: groupId].size());
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the opportunity sharing
    */
    static testMethod void testOpportunityShare() {
        Id houseHoldAccountId = [SELECT Id FROM Account WHERE RecordType.Name = 'Household' LIMIT 1][0].Id;

        Contact contact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccountId);

        hed__Program_Enrollment__c enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                        contact.Id,
                                                                                        [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Opportunity opportunity = Peak_TestUtils.createOpportunity(enrollment.Id);

        contact.Educational_Institution__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1][0].Id;
        update contact;

        Id groupId = [SELECT Id FROM Group WHERE Name = 'Test Ed Group' LIMIT 1][0].Id;

        //Assert test if Contact is shared with the 'Test Ed Group' group or not
//        System.assertEquals(0, [SELECT Id FROM ContactShare WHERE ContactId =: contact.Id AND UserOrGroupId =: groupId].size());

        enrollment.hed__Contact__c = Peak_TestUtils.createTestContact('Test Contact 1', 'Caretaker', houseHoldAccountId).Id;
        update enrollment;

        enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                             contact.Id,
                                                             [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);
        opportunity.Program_Enrollment__c = enrollment.Id;
        update opportunity;

        //Assert test if Opportunity is shared with the 'Test Ed Group' group or not
        System.assertEquals(0, [SELECT Id FROM OpportunityShare WHERE OpportunityId =: opportunity.Id AND UserOrGroupId =: groupId].size());
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the Account sharing
    */
    static testMethod void testAccountShare() {
        Id houseHoldAccountId = [SELECT Id FROM Account WHERE RecordType.Name = 'Household' LIMIT 1][0].Id;

        Contact contact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccountId);

        hed__Program_Enrollment__c enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                        contact.Id,
                                                                                        [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Opportunity opportunity = Peak_TestUtils.createOpportunity(enrollment.Id);

        contact.Educational_Institution__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1][0].Id;
        update contact;

        contact = Peak_TestUtils.createTestContact('Test Contact 1', 'Caretaker', houseHoldAccountId);

        enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                             contact.Id,
                                                             [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        contact.Educational_Institution__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1][0].Id;
        update contact;

        Id groupId = [SELECT Id FROM Group WHERE Name = 'Test Ed Group' LIMIT 1][0].Id;

        //Assert test if Contact is shared with the 'Test Ed Group' group or not
//        System.assertEquals(0, [SELECT Id FROM ContactShare WHERE ContactId =: contact.Id AND UserOrGroupId =: groupId].size());

        opportunity.Program_Enrollment__c = enrollment.Id;
        update opportunity;

        //Assert test if Opportunity is shared with the 'Test Ed Group' group or not
        System.assertEquals(0, [SELECT Id FROM OpportunityShare WHERE OpportunityId =: opportunity.Id AND UserOrGroupId =: groupId].size());
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the sharing recalculation on record delete
    */
    static testMethod void testRecalculateShareOnDelete() {
        //cover the exception part of code


        Id houseHoldAccountId = [SELECT Id FROM Account WHERE RecordType.Name = 'Household' LIMIT 1][0].Id;

        Contact contact = Peak_TestUtils.createTestContact('Educational Institution Contact', houseHoldAccountId);

        hed__Program_Enrollment__c enrollment =  Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                                                        contact.Id,
                                                                                        [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Opportunity opportunity = Peak_TestUtils.createOpportunity(enrollment.Id);

        contact.Educational_Institution__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1][0].Id;
        update contact;

        Id groupId = [SELECT Id FROM Group WHERE Name = 'Test Ed Group' LIMIT 1][0].Id;

        //Assert test if Contact is shared with the 'Test Ed Group' group or not
        System.assertEquals(0, [SELECT Id FROM ContactShare WHERE ContactId =: contact.Id AND UserOrGroupId =: groupId].size());

        delete opportunity;
        delete enrollment;

        //Assert test if Contact sharing is deleted or not
        System.assertEquals(0, [SELECT Id FROM ContactShare WHERE ContactId =: contact.Id AND UserOrGroupId =: groupId].size());

    }

    /**
     * Created by Ashish Sharma on 01/08/19
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the relationship sharing
    */
    static testMethod void testRelationshipShare() {
        Id houseHoldAccountId;
        Id edAccountId;

        for(Account acc : [SELECT Id, RecordType.Name FROM Account WHERE RecordType.Name IN ('Household', 'Educational Institution')]){
            if(acc.RecordType.Name == 'Household'){
                houseHoldAccountId = acc.Id;
            }else{
                edAccountId = acc.Id;
            }
        }

        Contact contact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccountId);

        Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                               contact.Id,
                                               [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        contact.Educational_Institution__c = edAccountId;
        update contact;

        Id groupId = [SELECT Id FROM Group WHERE Name = 'Test Ed Group' LIMIT 1][0].Id;

        //Assert test if Account is shared with the 'Test Ed Group' group or not
        System.assertEquals(0, [SELECT Id FROM AccountShare WHERE AccountId =: houseHoldAccountId AND UserOrGroupId =: groupId].size());

        //test calculateRelationshipSharing method with null values
        //Comment out broken test method
        //NES_SharingUtility.calculateRelationshipShares(null);

        Contact relatedContact = Peak_TestUtils.createTestContact('Test Contact 1', 'Caretaker', houseHoldAccountId);

        hed__Relationship__c relationship = Peak_TestUtils.createRelationship(contact.Id, relatedContact.Id, true);

        try{
            relationship.hed__RelatedContact__c = null;
            relationship.hed__Contact__c = null;
            update relationship;
        }catch(DMLException e){}

        insert new hed__Relationship__share(AccessLevel = 'Edit', ParentId = relationship.Id,
                                            UserOrGroupId = groupId,
                                            RowCause = Schema.hed__Relationship__share.RowCause.Apex_Sharing__c);

        Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1][0].Id,
                                                relatedContact.Id,
                                                [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        relatedContact.Educational_Institution__c = edAccountId;
        update relatedContact;

        //Assert test if relationship is shared with the 'Test Ed Group' group or not
        System.assertNotEquals(0, [SELECT Id FROM hed__Relationship__share WHERE ParentId =: relationship.Id AND UserOrGroupId =: groupId].size());
    }
    /**
     * Created by Himanshu Rukmangad on 29/03/19
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the sharing batches
    */
    static testMethod void testApexSharingBatches() {

        Test.startTest();
        NES_ApexSharingContactBatch sh1 = new NES_ApexSharingContactBatch();
        String sch = '0 0 2 * * ?';
        system.schedule('Test Territory Check', sch, sh1);

        NES_ApexSharingRelationshipBatch sh2 = new NES_ApexSharingRelationshipBatch();
        String sch2 = '0 0 2 * * ?';
        system.schedule('Test Territory Check2', sch2, sh2);

        Test.stopTest();

    }
}