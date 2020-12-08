/**
 * Created by melindagrad on 12/17/18.
 *
 * Controller for NES_Announcements lightning component
 */

public without sharing class NES_AnnouncementsHelper {
    private static Peak_ApexLog logger = new Peak_ApexLog('AnnouncementsHelper');

    /* Method to return all Announcements Global Announcements, Program Announcements, School Announcements and Grade Level Announcements
        for the current User.
     */
    public static Peak_Response getAnnouncements() {
        Peak_Response peakResponse = new Peak_Response();

        //Get Caretaker Record Type ID
        Id careTakerId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        Id contactId;

        //Get contact record for logged in User
        try {
            List<Contact> contacts = [SELECT Id FROM Contact WHERE ID IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()) AND RecordTypeId = :careTakerId FOR UPDATE];
            if (!contacts.isEmpty()) {
                contactId = contacts.get(0).Id;
            } else {
                peakResponse.messages.add('User does not have a related Contact');
                peakResponse.success = FALSE;
                return peakResponse;
            }
        } catch (exception e) {
            peakResponse.success = FALSE;
            peakResponse.messages.add(e.getMessage());
            System.debug('Exception' + e.getMessage());
            logger.logException('getAnnouncements', e);
            logger.saveLogs();
        }


        //Get List of Program Enrollments for Caretaker and their Students
        List<hed__Program_Enrollment__c> programEnrollmentList = getProgramEnrollments(contactId);


        //For each PE, add Account Id and Parent Account Id to set
        Set<Id> programEnrollmentAccountSet = new Set<Id>();
        for (hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            programEnrollmentAccountSet.add(progEnrollment.hed__Account__c);
            programEnrollmentAccountSet.add(progEnrollment.hed__Account__r.Parent.Id);
        }

        //Query all Announcements where there already exists a Contact Announcement for this contact -- so we have a list of existing Contact Announcements
        Set<Id> announcementsWithContactAnnouncements = getAnnouncementsWithContactAnnouncements(contactId);


        //Get all Announcements where Account matches Caretaker's Program Enrollment OR  both Account AND Grade Level are null (Global), OR Caretaker has PE for Grade Level Account
        List<Announcement__c> allProgramEnrollmentAnnouncements = [
                SELECT Id, Name, Alert_Type__c,Body__c, Date_On__c, Date_Off__c,
                        Dismissable__c,Order__c, Program_Grade_Level__c, Program_Grade_Level__r.Grade_Level__r.Name,
                        Program_Grade_Level__r.Academic_Program__c, Account__c
                FROM Announcement__c
                WHERE (Account__c IN :programEnrollmentAccountSet) OR (Account__c = '' AND Program_Grade_Level__c = '') OR (Program_Grade_Level__r.Academic_Program__c IN :programEnrollmentAccountSet)
        ];


        List<Announcement__c> announcementsToKeep = getGradeLevelAnnouncements(programEnrollmentList, allProgramEnrollmentAnnouncements);


        //For each of the Program Enrollment Announcements, add Parent Announcement Id to list, if there does not exist a Contact Announcement...create one
        List<Contact_Announcement__c> conAnnouncements = new List<Contact_Announcement__c>();
        Set<Id> announcements = new Set<Id>();

        announcements.addAll(announcementsWithContactAnnouncements);

        for (Announcement__c theAnnouncement : announcementsToKeep) {
            if (!announcementsWithContactAnnouncements.contains(theAnnouncement.Id)) {
                announcements.add(theAnnouncement.Id);
                Contact_Announcement__c conAnnouncement = new Contact_Announcement__c(
                        Name = theAnnouncement.Name,
                        Dismissed__c = false,
                        Date_On__c = theAnnouncement.Date_On__c,
                        Date_Off__c = theAnnouncement.Date_Off__c,
                        Announcement__c = theAnnouncement.Id,
                        Contact__c = contactId
                ) ;
                conAnnouncements.add(conAnnouncement);
            }
        }
        try {
            insert conAnnouncements;

            //Now query and return all the Contact Announcements -- the ones we created and the ones that already existed
            List<Contact_Announcement__c> conAnnouncementsToReturn = [
                    SELECT Id,Name,Dismissed__c,Announcement__c, Announcement__r.Order__c, Announcement__r.Dismissable__c,Announcement__r.Alert_Type__c,
                            Announcement__r.Body__c,Announcement__r.Date_On__c, Announcement__r.Date_Off__c
                    FROM Contact_Announcement__c
                    WHERE Dismissed__c = FALSE
                    AND Announcement__c IN :announcements
                    AND Announcement__r.Date_On__c <= :System.Now()
                    AND Announcement__r.Date_Off__c >= :System.Now()
                    AND Contact__c = :contactId
                    ORDER BY Announcement__r.Order__c ASC NULLS LAST
            ];


            if (!Peak_Utils.isNullOrEmpty(conAnnouncementsToReturn)) {
                peakResponse.results = conAnnouncementsToReturn;
                peakResponse.messages.add(conAnnouncementsToReturn.size() + ' Contact Announcement Records Found');
                peakResponse.success = TRUE;
            } else {
                peakResponse.messages.add('No Contact Announcements Found');
            }
        } catch (Exception e) {
            peakResponse.messages.add(e.getMessage());
            peakResponse.success = FALSE;
            logger.logException('getAnnouncements', e);
            logger.saveLogs();
        }

        return peakResponse;

    }

    /**
    *  Created By Anand 12/12/2018
    *  purpose :  allow front end to "dismiss" announcements, update (dismiss) field on announcement junction
    *
    * @param contactAnnouncement
    */
    public static Peak_Response dismissAnnouncement(Id contactAnnouncement) {
        Peak_Response peakResponse = new Peak_Response();
        List<Contact_Announcement__c> conAnnouncements = new List<Contact_Announcement__c>();
        List<Contact_Announcement__c> announcementsToUpdate = [SELECT id,Dismissed__c FROM Contact_Announcement__c WHERE Id = :contactAnnouncement];
        for (Contact_Announcement__c theAnnouncement : announcementsToUpdate) {
            theAnnouncement.Dismissed__c = TRUE;
            conAnnouncements.add(theAnnouncement);
        }
        try {
            update conAnnouncements;
            peakResponse.success = TRUE;
        } catch (exception e) {
            peakResponse.messages.add(e.getMessage());
            peakResponse.success = FALSE;
            logger.logException('dismissAnnouncement', e);
            logger.saveLogs();
        }
        return peakResponse;

    }

    /**
     *  Created By Anand on 12/18/2018
     *  Purpose: util Method for Retrieve Announcements to return programEnrollmentIds
     *
     * @param careTakerIds
     *
     * @return
     */
    public static List<hed__Program_Enrollment__c> getProgramEnrollments(String careTakerId) {

        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();


        if (careTakerId != '' && careTakerId != NUll) {
            //Retrieve the related student Ids of the careTakerContactId
            Set<Id> studentIds = new Set<Id>();
            Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();

            for (hed__Relationship__c con : [
                    SELECT hed__RelatedContact__c
                    FROM hed__Relationship__c
                    WHERE hed__Contact__c = :careTakerId
                    AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
            ]) {
                studentIds.add(con.hed__RelatedContact__c);
            }

            if (studentIds.size() > 0) {

                //Query all Program Enrollments for Caretaker's Students AND Caretaker
                programEnrollmentList = [
                        SELECT Id, hed__Contact__c, hed__Contact__r.Name, hed__Account__c, hed__Account__r.Parent.Id,Final_Grade_Level__c
                        FROM hed__Program_Enrollment__c
                        WHERE hed__Contact__c IN:studentIds OR hed__Contact__c = :careTakerId
                ];

            }
        }

        return programEnrollmentList;
    }

    /* Helper method which queries Contact Announcements, and creates a list of the related Announcement ID */
    public static Set<Id> getAnnouncementsWithContactAnnouncements(String contactId) {

        Set<Id> announcementsWithContactAnnouncements = new Set<Id>();

        //Get all the User's Contact Announcement records, and add the Parent Announcement ID to a list
        List<Contact_Announcement__c> usersContactAnnouncements = [
                SELECT Id, Date_On__c, Date_Off__c, Announcement__c,Dismissed__c
                FROM Contact_Announcement__c
                WHERE Contact__c = :contactId
        ];

        for (Contact_Announcement__c conAnnouncement : usersContactAnnouncements) {
            announcementsWithContactAnnouncements.add(conAnnouncement.Announcement__c);
        }

        return announcementsWithContactAnnouncements;
    }

    /* Helper method that checks all Caretaker's Announcements and if the Grade_Level is populated, it verifies that CAretaker has a PE is for the Grade_Level
           if so, keep the Announcement
     */
    public static List<Announcement__c> getGradeLevelAnnouncements(List<hed__Program_Enrollment__c> programEnrollmentList, List<Announcement__c> allProgramEnrollmentAnnouncements) {

        System.debug('gradeLevelAccountAnnouncements' + allProgramEnrollmentAnnouncements);

        List<Announcement__c> announcementsToKeep = new List<Announcement__c>();

        //Loop through Announcements the Caretaker (or Caretaker's students) have program enrollments for
        for (Announcement__c theAnnouncement : allProgramEnrollmentAnnouncements) {

            //If the Announcement has a Grade level
            if (String.valueOf(theAnnouncement.Program_Grade_Level__c) != '' && String.valueOf(theAnnouncement.Program_Grade_Level__c) != NULL) {

                //Check that PE exists not only for Account but also for the Grade_Level__c
                for (hed__Program_Enrollment__c theProgramEnrollment : programEnrollmentList) {

                    //TODO: Verify that the Program Enrollment Final_Grade_Level__c should match Grade_Level__c.Name
                    if (theProgramEnrollment.Final_Grade_Level__c == theAnnouncement.Program_Grade_Level__r.Grade_Level__r.Name
                            && theProgramEnrollment.hed__Account__c == theAnnouncement.Program_Grade_Level__r.Academic_Program__c) {

                        Boolean alreadyExists = false;

                        for(Announcement__c keptAnnouncement : announcementsToKeep) {
                            if(keptAnnouncement.Body__c == theAnnouncement.Body__c){
                                alreadyExists = true;
                            }
                        }

                        if(!alreadyExists) {
                            announcementsToKeep.add(theAnnouncement);
                        }

                    }
                }
            } else {
                if(theAnnouncement.Name != 'Moved to Second Semester'){
                    announcementsToKeep.add(theAnnouncement);
                }

            }
        }
        return announcementsToKeep;

    }
}