/**
 * Created by Ashish Sharma on 12/03/18
 * Class Name: NES_Batch_SecondSemester
 * Test Class Name: NES_Batch_SecondSemesterTest
 * Purpose : This batch/scheduler class is used to set Final_Semester_Indicator__c on opportunities to second semester
*/
global class NES_Batch_SecondSemester implements DataBase.Batchable<sObject>, Schedulable {
    private static Peak_ApexLog logger = new Peak_ApexLog('SecondSemester');

    //Constants
    static final String ACCOUNT_OBJECT = 'Account';
    static final String PROGRAM_GRADE_LEVEL_OBJECT = 'Program_Grade_Level__c';
    static final String FIRST_SEMESTER_INDICATOR = 'First';
    static final String SECOND_SEMESTER_INDICATOR = 'Second';
    static final String CRITICAL_ALERT_TYPE = 'Critical';

    //Variables to store the object's Name and push date for second semester after which records need to be processed
    String objectName;
    Datetime secondSemesterPushDate;

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: N/A
     * Return Type: N/A
     * Purpose : Constructor method
    */
    global NES_Batch_SecondSemester() {

    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: String, Datetime
     * Return Type: N/A
     * Purpose : Constructor method that accept object name and second semester push date for filter in query
    */
    global NES_Batch_SecondSemester(String objectName, Datetime secondSemesterPushDate) {
        this.objectName = objectName;
        this.secondSemesterPushDate = secondSemesterPushDate;
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: Database.BatchableContext
     * Return Type: Database.QueryLocator
     * Purpose : Batch class start method to query the Account or related account on Program_Grade_Level__c
     *           based on the objectName passed in the constructor
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        Set<Id> accountIds = new Set<Id>();
        //build query based on the parameters passed in the constructor
        if (objectName == ACCOUNT_OBJECT) {
            for (Account acct : [SELECT Id FROM Account WHERE PushToSecondSemester__c <: secondSemesterPushDate]) {
                accountIds.add(acct.Id);
            }
        } else if (objectName == PROGRAM_GRADE_LEVEL_OBJECT) {
            for (Program_Grade_Level__c pgl : [SELECT Academic_Program__c FROM Program_Grade_Level__c WHERE PushToSecondSemester__c <: secondSemesterPushDate]) {
                accountIds.add(pgl.Academic_Program__c);
            }
        }

        return Database.getQueryLocator([
                SELECT Id, Student_Id__r.Name, Caretaker_Id__c, Program_Enrollment__r.hed__Account__c, Program_Enrollment__r.hed__Account__r.Name, Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c
                FROM Opportunity
                WHERE Program_Enrollment__r.hed__Account__c IN :accountIds AND Semester_Indicator__c = : FIRST_SEMESTER_INDICATOR AND StageName =: 'Open'
        ]);
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: Database.BatchableContext, List<sObject>
     * Return Type: void
     * Purpose : Batch class execute method to process the collect the account Ids and process
     *           further in pushSecondSemester method
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        pushSecondSemester(scope);
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: Set<Id>
     * Return Type: void
     * Purpose : Method to process the Opportunities related to accountIds and set Final_Semester_Indicator__c
     *           to Second semester
    */
    void pushSecondSemester(List<Opportunity> opportunities) {

        System.debug('Opportunities returned: ' + opportunities);

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        //collections to store notification related records
        // The code related to the announcement is commented for the Defect 312723 on 10/14/2020  
       /* List<Announcement__c> announcements = new List<Announcement__c>();
        List<Contact_Announcement__c> contactAnnouncements = new List<Contact_Announcement__c>(); */

        for (Opportunity opportunity : opportunities) {

           /* String bodyMessage = 'We have moved ' + opportunity.Student_Id__r.Name +
                    '\'s enrollment in ' +
                    (opportunity.Program_Enrollment__r.hed__Account__r != null && String.isNotBlank(opportunity.Program_Enrollment__r.hed__Account__r.Name) ?
                            opportunity.Program_Enrollment__r.hed__Account__r.Name : '') + ' to the second semester'; */

            System.debug('Creating an op');
            opportunitiesToUpdate.add(new Opportunity(Id = opportunity.Id,
                    Semester_Indicator__c = SECOND_SEMESTER_INDICATOR));

          /*  if (opportunity.Caretaker_Id__c != null) {
                announcements.add(new Announcement__c(Dismissable__c = true, Alert_Type__c = CRITICAL_ALERT_TYPE,
                        Name = 'Moved to Second Semester',
                        Account__c = opportunity.Program_Enrollment__r.hed__Account__c,
                        Body__c = 'We have moved ' + opportunity.Student_Id__r.Name +
                                '\'s enrollment in ' +
                                (opportunity.Program_Enrollment__r.hed__Account__r != null && String.isNotBlank(opportunity.Program_Enrollment__r.hed__Account__r.Name) ?
                                        opportunity.Program_Enrollment__r.hed__Account__r.Name : '') + ' to the second semester',
                        Date_On__c = Datetime.now(),
                        Date_Off__c = (opportunity.Program_Enrollment__r.hed__Account__r != null ?
                                opportunity.Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c : null)));

                contactAnnouncements.add(new Contact_Announcement__c(Contact__c = opportunity.Caretaker_Id__c, Dismissed__c = false,
                        Name = 'Moved to Second Semester'));
            } */


        }

        NES_Constants.runAssignment = false;

        //update opportunitiesToUpdate if not empty
        if (opportunitiesToUpdate.size() > 0) {
            Database.update(opportunitiesToUpdate, false);
        }

        //insert announcements and related contact announcements records
     /*   if (announcements.size() > 0) {
            try {
                insert announcements;

                for (Integer i = 0; i < announcements.size(); i++) {
                    contactAnnouncements[i].Announcement__c = announcements[i].Id;
                }

                insert contactAnnouncements;
            } catch (Exception e) {
                System.debug('Exception in NES_Batch_SecondSemester>> ' + e.getMessage());
                logger.logException('pushSecondSemester', e);
                logger.saveLogs();
            }
        } */
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: Database.BatchableContext
     * Return Type: void
     * Purpose : Batch class finish method
    */
    global void finish(Database.BatchableContext BC) {

    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: SchedulableContext
     * Return Type: void
     * Purpose : Method to schedule the batch apex job
    */
    global void execute(SchedulableContext sc) {
        database.executebatch(new NES_Batch_SecondSemester(ACCOUNT_OBJECT, Datetime.now()));
        database.executebatch(new NES_Batch_SecondSemester(PROGRAM_GRADE_LEVEL_OBJECT, Datetime.now()));
    }
}