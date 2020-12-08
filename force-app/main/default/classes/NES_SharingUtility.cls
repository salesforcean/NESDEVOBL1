/**
 * Created by Ashish Sharma on 12/18/18
 * Class Name: NES_SharingUtility
 * Test Class Name: NES_SharingUtilityTest
 * Purpose : Utility class for Apex Managed Sharing of Contact, Account, Opportunity related to program enrollments
*/
public without sharing class NES_SharingUtility {
    //Constants
    static final String EDIT_ACCESS = 'Edit';
    static final String REGULAR_GROUP = 'Regular';
    static final String HOUSEHOLD_RT = 'Household';
 
    //Instantiate Apex Logger
    private static Peak_ApexLog logger = new Peak_ApexLog('ApexSharing');

    /*
        Method to mark Contact records which need to be shared via Apex sharing
    */
    public static void markForRecalculation(List<SObject> records, Map<Id, SObject> oldMap){

        try{

            //Check the type of object on which trigger is executing
            String sObjectType = (records != null ? String.valueOf(records[0].getSObjectType()) :
                                                    String.valueOf(oldMap.values()[0].getSObjectType()));

            List<Contact> contactsToUpdate = new List<Contact>();

            //If Contact Trigger
            if(sObjectType == 'Contact') {
                if (records != null) {

                    List<String> contactIdsToUpdate = new List<String>();

                    // If Trigger is Insert or Update
                    for (Contact theContact : (List<Contact>) records) {

                        //If this is INSERT or UPDATE where the Contact's Account OR EI was changed \
                        if (oldMap == null ||
                                (oldMap != null && (theContact.Educational_Institution__c != ((Contact) oldMap.get(theContact.Id)).Educational_Institution__c ||
                                        theContact.AccountId != ((Contact) oldMap.get(theContact.Id)).AccountId))) {


                            //Mark for recalculation
                            contactIdsToUpdate.add(theContact.Id);
                        }
                    }

                    //Loop through Contact records and mark for recalculation
                    List<Contact> contactsFromIds = [SELECT Id, Recalculate_Sharing__c FROM Contact WHERE Id IN: contactIdsToUpdate];
                    for(Contact theContact : contactsFromIds){
                        theContact.Recalculate_Sharing__c = TRUE;
                        contactsToUpdate.add(theContact);
                    }

                    update contactsToUpdate;
                    logger.logInfo('markForRecalculation', 'Contact Updates Successful');
                }
            }

            //Commenting the below code by Ajith since we are not using sharing for the PE and Coverage Purpose
            /*else if(sObjectType == 'hed__Program_Enrollment__c'){
                if(records != null){

                    List<String> peContactIds = new List<String>();
                    for (hed__Program_Enrollment__c enrollment : (List<hed__Program_Enrollment__c>) records) {

                        //If Insert OR (Update AND Either Contact OR Account is changed)
                        if ((oldMap == null && enrollment.hed__Contact__c != null && enrollment.hed__Account__c != null) ||
                            (oldMap != null && ((((hed__Program_Enrollment__c) oldMap.get(enrollment.Id)).hed__Contact__c != enrollment.hed__Contact__c) ||
                                               (((hed__Program_Enrollment__c) oldMap.get(enrollment.Id)).hed__Account__c != enrollment.hed__Account__c)))) {

                            //Make a list of Contact Ids -- this is so we can query the Contact and update
                            peContactIds.add(enrollment.hed__Contact__c);

                        }
                    }

                    //Loop through all the PE's Contacts and mark for recalculation
                    List<Contact> peContacts = [SELECT Id, Recalculate_Sharing__c FROM Contact WHERE Id IN: peContactIds];
                    for(Contact theContact : peContacts){
                        theContact.Recalculate_Sharing__c = TRUE;
                        contactsToUpdate.add(theContact);
                    }

                    update contactsToUpdate;
                    logger.logInfo('markForRecalculation', 'Contact Updates Successful');
                }
            }*/
            else if (sObjectType == 'hed__Relationship__c'){

                if(records != NULL){

                    List<hed__Relationship__c> relationshipRecordsToUpdate = new List<hed__Relationship__c>();

                    List<Id> relationshipIds = new List<Id>();
                    for(hed__Relationship__c theRelationship: (List<hed__Relationship__c>)records){
                        relationshipIds.add(theRelationship.Id);
                    }

                    List<hed__Relationship__c> relationships = [SELECT Id, Recalculate_Sharing__c FROM hed__Relationship__c WHERE Id IN: relationshipIds ];
                    for(hed__Relationship__c theRelationship: relationships){
                        theRelationship.Recalculate_Sharing__c = TRUE;
                        relationshipRecordsToUpdate.add(theRelationship);
                    }
                    update relationshipRecordsToUpdate;
                }
            }

        }catch(Exception e){
            logger.logException('markForRecalculation', e);
        }
    }

    public static void calculateSharing(List<Contact> contacts){

        try{
            if(!Peak_Utils.isNullOrEmpty(contacts)){
                createShareRecordsForContactsAndHouseholds(contacts);

                //Mark recalculation false
                for(Contact theContact : contacts) {
                    theContact.Recalculate_Sharing__c = FALSE;
                    NES_Constants.runAssignment = false;
                }
                update contacts;
            }

        }catch(Exception e){
            System.debug('EXCEPTION THROWN Calc Sharing' + e.getMessage());
        }
    }

    /* Method to create share records for Contacts and their related Accounts */
    public static void createShareRecordsForContactsAndHouseholds(List<Contact> contacts){

        List<hed__Program_Enrollment__c> contactProgramEnrollments = getContactProgramEnrollments(contacts);

        List<sObject> contactShareRecordsToInsert = new List<sObject>(); //Share records being returned
        List<sObject> accountShareRecordsToInsert = new List<sObject>(); //Share records being returned

        Map<Id, List<Id>> contactToEducationalInstitutionMap = new Map<Id, List<Id>>(); //To Map Contact with EI
        Set<Id> contactEdInstitutionIdSet = new Set<Id>(); //Set of EIs to get Custom Settings for

        Map<Id,Id> contactToHouseholdMap = new Map<Id, Id>(); //Map to hold ContactIds and their Households


        for(hed__Program_Enrollment__c theProgramEnrollment : contactProgramEnrollments){

            //Create a set of all EI's the contacts have PEs for
            contactEdInstitutionIdSet.add(theProgramEnrollment.hed__Account__r.ParentId);

            //Create a Map of Contacts and their EIs
            if(contactToEducationalInstitutionMap.containsKey(theProgramEnrollment.hed__Contact__c)){
                contactToEducationalInstitutionMap.get(theProgramEnrollment.hed__Contact__c).add(theProgramEnrollment.hed__Account__r.ParentId);
            }else{
                contactToEducationalInstitutionMap.put(theProgramEnrollment.hed__Contact__c, new List<Id>());
                contactToEducationalInstitutionMap.get(theProgramEnrollment.hed__Contact__c).add(theProgramEnrollment.hed__Account__r.ParentId);
            }

            //If the Contact with the PE has a Household, add it to a map -- will use this to create a sharing record
            if(theProgramEnrollment.hed__Contact__r.Account.RecordType.Name == HOUSEHOLD_RT){
                if(!contactToHouseholdMap.containsKey(theProgramEnrollment.hed__Contact__c) && !contactToHouseholdMap.values().contains(theProgramEnrollment.hed__Contact__r.AccountId)){
                    contactToHouseholdMap.put(theProgramEnrollment.hed__Contact__c, theProgramEnrollment.hed__Contact__r.AccountId);
                    system.debug('HH added to map' + theProgramEnrollment.hed__Contact__r.AccountId);
                }
            }
        }

        if(!Peak_Utils.isNullOrEmpty(contactProgramEnrollments)) {

            //Get the Custom Setting records for the Contact's EI
            Map<Id, Id> edInstituteGroupIdMap = getEdInstituteGroupIdMap(contactEdInstitutionIdSet);

            //Create a Map of existing contactShare records for the contacts
            Map<Id, list<Id>> ShareMap = new Map<Id, list<Id>>();
            List<contactShare> contactShareList = new List<contactShare>([Select ContactID, UserOrGroupID from ContactShare where contactID in: contactToEducationalInstitutionMap.keyset()]);
            for(ContactShare sharedContact : contactShareList){
                if(ShareMap.containsKey(sharedContact.ContactId)){
                    ShareMap.get(sharedContact.ContactID).add(sharedContact.UserOrGroupID);
                    system.debug('adding contactShareMap value2+: ' +sharedContact.ContactID +' '+sharedContact.userorgroupID);
                }
                else{
                    ShareMap.put(sharedContact.ContactID,  new List<Id>());
                    ShareMap.get(sharedContact.ContactID).add(sharedContact.UserOrGroupID);
                    system.debug('adding contactShareMap value1: '+ sharedContact.ContactID +' '+sharedContact.userorgroupID);
                }
            }
            
            //Create a Map of existing accountShare records for the households
            List<accountShare> accountShareList = new List<accountShare>([Select AccountID, UserOrGroupID from AccountShare where AccountID in: contactToHouseholdMap.values()]);
            for(AccountShare sharedAccount : AccountShareList){
                if(ShareMap.containsKey(sharedAccount.AccountId)){
                    ShareMap.get(sharedAccount.AccountID).add(sharedAccount.UserOrGroupID);
                    system.debug('adding accountShareMap value2+: ' + sharedAccount.AccountID + ' ' +sharedAccount.UserOrGroupID);
                }
                else{
                    ShareMap.put(sharedAccount.AccountID,  new List<Id>());
                    ShareMap.get(sharedAccount.AccountID).add(sharedAccount.UserOrGroupID);
                    system.debug('adding accountShareMap value1: ' + sharedAccount.AccountID + ' ' +sharedAccount.UserOrGroupID);
                }
            }

            //Create sharing record if Contact has PE for EI in list of custom settings
            for (Id contactId : contactToEducationalInstitutionMap.keySet()) {
                for (Id customSettingEI : edInstituteGroupIdMap.keySet()) {
                    system.debug('Custom Setting ID: '+customSettingEI);
                    if (contactToEducationalInstitutionMap.get(contactId).contains(customSettingEI)) {
                        if(!ShareMap.get(contactID).contains(edInstituteGroupIdMap.get(customSettingEI))){
                            //Create sharing record for Contact
                            contactShareRecordsToInsert.add(new ContactShare(ContactAccessLevel = EDIT_ACCESS, ContactId = contactId,
                                    UserOrGroupId = edInstituteGroupIdMap.get(customSettingEI)));
                            
                            system.debug('Contact Added: '+ contactID +' ' +edInstituteGroupIdMap.get(customSettingEI));
                        }
                       
                        //Create sharing record for Contact's Household
                        if (contactToHouseholdMap.containskey(contactId)) {
                            system.debug(ShareMap.get(contactToHouseholdMap.get(contactId)));
                            if(!ShareMap.get(contactToHouseholdMap.get(contactId)).contains(edInstituteGroupIdMap.get(customSettingEI))){
                                accountShareRecordsToInsert.add(new AccountShare(AccountAccessLevel = EDIT_ACCESS, OpportunityAccessLevel=EDIT_ACCESS, AccountId = contactToHouseholdMap.get(contactId),
                                        UserOrGroupId = edInstituteGroupIdMap.get(customSettingEI)));
                                system.debug('Account Added: '+ contactToHouseholdMap.get(contactId) +' ' + edInstituteGroupIdMap.get(customSettingEI));
                            }
                        }
                    }
                }
            }
        }

        //Need two separate DMLs or else we get an error
        system.debug('attempting accountShare insert');
        insert accountShareRecordsToInsert;
        system.debug('attempting contactShare insert');        
        insert contactShareRecordsToInsert;

    }

    /*Helper method to get Program Enrollments for a list of contacts */
    public static List<hed__Program_Enrollment__c> getContactProgramEnrollments(List<Contact> contactList){

        //Get Contact's Program Enrollments and compile lists to create share records
        List<hed__Program_Enrollment__c> contactProgramEnrollments = [SELECT hed__Contact__c, hed__Contact__r.AccountId,
                hed__Contact__r.Account.RecordType.Name,
                hed__Account__r.ParentId, IsDeleted
        FROM hed__Program_Enrollment__c
        WHERE hed__Contact__c IN: contactList];

        return contactProgramEnrollments;

    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: Set<Id>
     * Return Type: Map<Id, Id>
     * Purpose : Method to get the map of Educational Institute and GroupId map
    */
    private static Map<Id, Id> getEdInstituteGroupIdMap(Set<Id> educationalInstitutionIds){
        Map<Id, String> edInstituteGroupNameMap = new Map<Id, String>();

        //Create a Map of EI Ids and their Names
        Map<String, Id> accountNameIdMap = new Map<String, Id>();
        for(Account temp : [SELECT Id, Name FROM Account WHERE Id IN: educationalInstitutionIds]){
            accountNameIdMap.put(temp.Name, temp.Id);
        }

        //Get Custom Setting/Sharing Setting for the EI
        for(NES_Manual_Share_Settings__c shareSetting : NES_Manual_Share_Settings__c.getall().values()){
            if(shareSetting.Educational_Institution_Name__c != null && shareSetting.Group_Name__c != null &&
               accountNameIdMap.keySet().contains(shareSetting.Educational_Institution_Name__c)){

                edInstituteGroupNameMap.put(accountNameIdMap.get(shareSetting.Educational_Institution_Name__c.trim()),
                                                                 shareSetting.Group_Name__c.trim());
            }
        }

        Map<String, Id> groupNameIdMap = new Map<String, Id>();

        for(Group temp : [SELECT Id, Name FROM Group WHERE Name IN: edInstituteGroupNameMap.values()
                          AND Type =: REGULAR_GROUP]){

            groupNameIdMap.put(temp.Name, temp.Id);
        }

        Map<Id, Id> edInstituteGroupIdMap = new Map<Id, Id>();

        for(Id accountId : edInstituteGroupNameMap.keySet()){
            if(groupNameIdMap.containsKey(edInstituteGroupNameMap.get(accountId))){
                edInstituteGroupIdMap.put(accountId, groupNameIdMap.get(edInstituteGroupNameMap.get(accountId)));
            }
        }

        return edInstituteGroupIdMap;
    }

    public static void calculateRelationshipShares(List<hed__Relationship__c> relationshipsToRecalculate){
        System.debug('relationshipsToRecalculate++'+relationshipsToRecalculate);
        try{
            if(!Peak_Utils.isNullOrEmpty(relationshipsToRecalculate)){

                Set<Id> relationshipIds = new Set<Id>();
                for(hed__Relationship__c theRelationship : relationshipsToRecalculate){
                    relationshipIds.add(theRelationship.Id);
                }

                createShareRecordsForRelationships(relationshipIds);

                //Mark recalculation false
                for(hed__Relationship__c theRelationship : relationshipsToRecalculate) {
                    theRelationship.Recalculate_Sharing__c = FALSE;
                }
                update relationshipsToRecalculate;
            }
        }catch(Exception e){
            System.debug('EXCEPTION THROWN Calc Rel Sharing' + e.getMessage());
        }
    }

    /**
     * Created by Ajith on 12/03/19
     * Parameters: Set<Id> of relationship records
     * Return Type: void
     * Purpose : Method to insert the relationship records sharing
    */
    public static void createShareRecordsForRelationships(Set<Id> relationshipIds ){
        System.debug('In createShareRecordsForRelationships++++');
        //share the hed__Relationship__c record with the group if both the related contacts are shared with that public group
        List<hed__Relationship__share> toInsertShareRecords = new List<hed__Relationship__share>();


        //get the hed__Relationship__c records those are related to relationshipIds and have both the contact lookups non-empty
        Set<Id> contactIds = new Set<Id>();

        Map<Id, Id> relationshipMap = new Map<Id, Id>();
        for (hed__Relationship__c relationship : [
                SELECT Id, hed__Contact__c, hed__RelatedContact__c
                FROM hed__Relationship__c
                WHERE Id IN:relationshipIds AND hed__Contact__c != null
                AND hed__RelatedContact__c != null AND hed__Contact__r.RecordType.Name = 'Caretaker'
        ]) {
            contactIds.add(relationship.hed__Contact__c);
            relationshipMap.put(relationship.hed__Contact__c, relationship.Id);
        }
        System.debug('contactIds'+contactIds+'contactIds.size'+contactIds.size());

        if(contactIds.size() > 0){

            Map<Id, List<Id>> contactToEdMap = new Map<Id, List<Id>>();
            Set<Id> educationalInstitutionIdSet = new Set<Id>();
            for(hed__Program_Enrollment__c enroll : [SELECT hed__Contact__c, hed__Contact__r.AccountId, hed__Contact__r.Account.RecordType.Name, hed__Account__r.ParentId, IsDeleted
                                                            FROM hed__Program_Enrollment__c
                                                            WHERE hed__Contact__c IN: contactIds]){

                if(!educationalInstitutionIdSet.contains(enroll.hed__Account__r.ParentId)){
                    educationalInstitutionIdSet.add(enroll.hed__Account__r.ParentId);
                }

                if(contactToEdMap.containsKey(enroll.hed__Contact__c)){
                  contactToEdMap.get(enroll.hed__Contact__c).add(enroll.hed__Account__r.ParentId);
                }else{
                    contactToEdMap.put(enroll.hed__Contact__c, new List<Id>{enroll.hed__Account__r.ParentId});
                }
            }

            if(educationalInstitutionIdSet.size() > 0){
                //Get the Custom Setting records for the Contact's EI
                Map<Id, Id> edInstituteGroupIdMap = getEdInstituteGroupIdMap(educationalInstitutionIdSet);

                for (Id contactId : contactToEdMap.keySet()) {
                    for(Id eduId : edInstituteGroupIdMap.keySet()){
                        if(contactToEdMap.get(contactId).contains(eduId)){
                            if(relationshipMap.containsKey(contactId)){
                                toInsertShareRecords.add(new hed__Relationship__share(AccessLevel = EDIT_ACCESS, ParentId = relationshipMap.get(contactId), UserOrGroupId = edInstituteGroupIdMap.get(eduId)));
                            }
                        }
                    }
                }
            }
        }

        if(toInsertShareRecords.size() > 0){
            try {
               insert toInsertShareRecords;
            }catch(Exception e){
                System.debug('EXCEPTION THROWN ===' + e.getMessage());
            }
        }
    }
}