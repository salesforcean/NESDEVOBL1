/**
 * Created by: Alex Chisholm on 05/06/2019
 * Class Name: NES_CreateTestStudent
 * Purpose : Service class for creating enrolled student test records
*/
@RestResource(urlMapping='/CreateTestStudent/*')
global with sharing class NES_CreateTestStudent {
 @httppost
    global static void doPost() {
        //instantiate rest response and request
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        //get parameters from the request
        String firstName = req.params.get('firstName');
        String lastName = req.params.get('lastName');
        String schoolID = req.params.get('schoolID');
        String schoolYear = req.params.get('schoolYear');
        String gradeLevel = req.params.get('gradeLevel');
        String householdID = req.params.get('householdID');
        String caretakerID = req.params.get('caretakerID');

        if (!String.isBlank(firstName)&& !String.isBlank(lastName) && !String.isblank(schoolID) && !String.isblank(schoolYear) && !String.isblank(gradeLevel)
        && !String.isblank(householdID)) {
        
            /* Create Student Contact and add them to the household account */
            Account[] HH = new List<Account>([SELECT ID FROM Account WHERE ID =: householdID]);
            Contact student = new Contact(
                firstName = firstName,
                lastName = lastName,
                Account = HH[0]);
            
            /* Determine the caretaker */
            Contact[] caretaker = new List<Contact>([SELECT ID FROM CONTACT WHERE ID =: caretakerID]);
            
            /* Create relationship record */
            hed__relationship__c rel = new hed__relationship__c(
                hed__Contact__r = student,
                hed__RelatedContact__r = caretaker[0],
                hed__type__c = 'Parent'
            );
                
            /* Determine the Academic Program */
            Account[] AP = new List<Account>([SELECT ID, School_Year__c FROM Account WHERE ParentID =: schoolID AND School_Year__r.External_ID__c =: schoolYear]);
            
            /* Create the caretaker program enrollment */
            hed__program_enrollment__c caretakerPE = new hed__program_enrollment__c(
                Start_Year__c = AP[0].School_Year__c,
                hed__Account__r = AP[0],
                hed__Contact__r = caretaker[0]
            );
                        
            /* Create the student program enrollment */
            hed__program_enrollment__c studentPE = new hed__program_enrollment__c(
                Start_Year__c = AP[0].School_Year__c,
                hed__Account__r = AP[0],
                hed__Contact__r = student,
                Household_Program_Enrollment__r = caretakerPE
            );
            
            /* Create ASI */
            
            /* Create Enrollment */
        }
    }
}