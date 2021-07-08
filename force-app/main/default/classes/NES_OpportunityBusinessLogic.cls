/**
 * Created by Anand on 12/4/2018.
 */

public without sharing class NES_OpportunityBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('OpportunityBusinessLogic');

    /**
    * created By Raju 12/5/2018
    * purpose: Trigger Fires when Opportunity Status = Closed-won it Sets Opportunity Confirmation_Date__c to Today.
    *
    * @param oldMap
    * @param newList
    */
    public static void updateOpportunityConfirmationDate(Map<Id, opportunity>oldMap, List<opportunity>newList) {
        for (Opportunity opportunityRecord : newList) {
            // Lavanya Fix fro Ticket 380682
            if ((opportunityRecord.StageName == 'Closed Won') && (oldMap.get(opportunityRecord.Id).StageName != 'Closed Won')){
                opportunityRecord.Confirmation_Date__c = Date.today();
            }
        }
    }
    /**
     * created By Anand 12/5/2018
     * purpose: If opportunity  Final_Semester_Indicator__c is blank Copy Semester_Indicator__c
     *          to Final_Semester_Indicator__c
     *
     * @param opportunites
     */

    public static void populateFinal_SemesterIndicator(List<opportunity> opportunites) {
        for (Opportunity opp : opportunites) {
            if (opp.Semester_Indicator__c != null && opp.Semester_Indicator__c != '' && (opp.Final_Semester_Indicator__c == null || opp.Final_Semester_Indicator__c == '')) {
                opp.Final_Semester_Indicator__c = opp.Semester_Indicator__c;
            }
        }
    }
    /**
     * created By Anand 12/5/2018
     * purpose:When opportunity Semester_Indicator__c is updated and  Final_Semester_Indicator__c is null populate  Final_Semester_Indicator__c
     *  with  Semester_Indicator__c  AND  When Final_Semester_Indicator__c updated
     *  update Earliest_Final_Confirmation_Date__c fields based on requirement
     * @param oldMap
     * @param newMap
     */
    public Static void updateFinalSemesterIndicator(Map<Id, opportunity>oldMap, Map<Id, opportunity>newMap) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        set<Id> programEnrollmentIds = new Set<Id>();
        // Added code(or condition) by Maddileti for defect #312723 on 10/14/2020
        for (Id oppId : oldMap.keySet()) {

            if (oldMap.get(oppId).Semester_Indicator__c != newMap.get(oppId).Semester_Indicator__c
                    && ((newMap.get(oppId).Final_Semester_Indicator__c == null || newMap.get(oppId).Final_Semester_Indicator__c == '') || (newMap.get(oppId).Final_Semester_Indicator__c != newMap.get(oppId).Semester_Indicator__c))) {
                // Populate blank Final_Semester_Indicator__c with Semester_Indicator__c
                newMap.get(oppId).Final_Semester_Indicator__c = newMap.get(oppId).Semester_Indicator__c;

            }
            // Ftech programEnrollmentIds and Opportunities Ids of updated opportunities
            if (oldMap.get(oppId).Final_Semester_Indicator__c != newMap.get(oppId).Final_Semester_Indicator__c) {
                programEnrollmentIds.add(newMap.get(oppId).Program_Enrollment__c);
                opportunitiesToUpdate.add(newMap.get(oppId));
            }

        }

        Map<Id, hed__Program_Enrollment__c> progEnrollments = new Map<Id, hed__Program_Enrollment__c>([
                select
                        id,
                        hed__Account__r.Second_Semester_Confirmation_Date__c,
                        hed__Account__r.Confirmation_End_Date__c
                FROM hed__Program_Enrollment__c
                where Id in:programEnrollmentIds
        ]);

        System.debug('progEnrollments' + progEnrollments);

        for (Opportunity opp : opportunitiesToUpdate) {
            if (progEnrollments.containsKey(opp.Program_Enrollment__c)) {
                // If Final_Semester_Indicator__c is first then  Earliest_Final_Confirmation_Date__c should be Account__r.Confirmation_End_Date__c
                if (newMap.get(opp.Id).Final_Semester_Indicator__c == 'First')
                    newMap.get(opp.Id).Earliest_Final_Confirmation_Date__c = progEnrollments.get(opp.Program_Enrollment__c).hed__Account__r.Confirmation_End_Date__c;
                System.debug('Date' + newMap.get(opp.Id).Earliest_Final_Confirmation_Date__c);
                // If Final_Semester_Indicator__c is second then  Earliest_Final_Confirmation_Date__c should be Account__r.Second_Semester_Confirmation_Date__c
                if (newMap.get(opp.Id).Final_Semester_Indicator__c == 'Second')
                    newMap.get(opp.Id).Earliest_Final_Confirmation_Date__c = progEnrollments.get(opp.Program_Enrollment__c).hed__Account__r.Second_Semester_Confirmation_Date__c;
                System.debug('Date1' + newMap.get(opp.Id).Earliest_Final_Confirmation_Date__c);
            }
        }

    }

    /**
 * Created by Ritvik on 12/6/2018.
 * Purpose : Whenever an Opportunity is updated to a Closed-Won status, check to see if there is an existing Enrollment record for that Opportunity. If there is an existing
   * record that has a non-null enrollment date do nothing.  If there is not a record, insert one. If either a record was inserted or the existing record had a null enrollment
   * date, set the value of enrollment date field.
   *
   * Param : oldMap & newMap which has key as oppportunity id & value as new & old records of opportunity which are updated.
   * Return Type : void
 */
    public static void populateEnrollmentDate_Update(Map<Id, opportunity> oldMap, Map<Id, opportunity> newMap) {
        System.debug('In populateEnrollmentDate_Update');
        //Map to store opportunity record whose stage changed to 'Closed Won' as it key & program enrollment Id as value.
        Map<Opportunity, Id> opportunityProgEnrollIdMap = new Map<Opportunity, Id>();
        //Map stores program enrollment id as key & list of enrollment record related to that program enrollment as value.
        Map<Id, List<Enrollment__c>> progEnrollMap = new Map<Id, List<Enrollment__c>>();
        //List stores the enrollment record to be inserted or updated on after update opportunity trigger functionality.
        List<Enrollment__c> enrollmentRecordList = new List<Enrollment__c>();

        //Iterating on updated opportunity record.
        for (Opportunity opportunityRecord : [
                SELECT Id,StageName, Program_Enrollment__c,PreferredStartDate__c,Semester_Indicator__c,Program_Enrollment__r.Enrollment_Type__c,Program_Enrollment__r.hed__Account__r.PushToSecondSemester__c,
                        Program_Enrollment__r.hed__Account__r.FirstDaySecondSemester__c,Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c,
                        Program_Enrollment__r.Start_Year__c
                FROM Opportunity
                WHERE Id IN:newMap.keySet()
        ]) {
            if (opportunityRecord.StageName == 'Closed Won' && oldMap.get(opportunityRecord.Id).StageName != 'Closed Won') {
                opportunityProgEnrollIdMap.put(opportunityRecord, opportunityRecord.Program_Enrollment__c);
            }
        }

        System.debug('opportunityProgEnrollIdMap>>>>' + opportunityProgEnrollIdMap);
         // Added where condition in sub query by Maddileti for User Story #244263 on 21-09-2020
        //Iterating over program enrollment records associated with updated opportunity.
        for (hed__Program_Enrollment__c programEnrollment : [
                SELECT Id, Start_Year__c, (SELECT Id,Enrollment_Date__c FROM Enrollments__r where Enrollment_Date__c =null)
                FROM hed__Program_Enrollment__c
                WHERE Id IN :opportunityProgEnrollIdMap.values()
        ]) {
            System.debug('programEnrollment>>>>' + programEnrollment);
            if (progEnrollMap.containsKey(programEnrollment.Id)) {
                System.debug('In contains if');
                progEnrollMap.get(programEnrollment.Id).addAll(programEnrollment.Enrollments__r);
            } else {
                System.debug('In contains else');
                List<Enrollment__c> enrollmentList = new List<Enrollment__c>();
                enrollmentList.addAll(programEnrollment.Enrollments__r);
                progEnrollMap.put(programEnrollment.Id, enrollmentList);
            }
        }
        System.debug('progEnrollMap>>>>>>' + progEnrollMap);

        //Iterating over updated opportunity record whose stage updated to Closed Won.
        for (Opportunity opportunityRecord : opportunityProgEnrollIdMap.keySet()) {

            Date earliestStartDate;
            if ((opportunityRecord.Program_Enrollment__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__r.PushToSecondSemester__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__r.PushToSecondSemester__c.date() != null &&
                    System.today() > opportunityRecord.Program_Enrollment__r.hed__Account__r.PushToSecondSemester__c.date()) || (opportunityRecord.Semester_Indicator__c <> null && opportunityRecord.Semester_Indicator__c == 'Second')) {
                System.debug('<<<PushToSecondSemester__c Test pass');
                if (opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDaySecondSemester__c > System.today().addDays(1)) {
                    earliestStartDate = opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDaySecondSemester__c;
                    System.debug('FirstDaySecondSemester__c earliestStartDate:' + earliestStartDate);
                } else {
                    earliestStartDate = System.today().addDays(1);
                    System.debug('System.today() earliestStartDate:' + earliestStartDate);
                }
            } else {
                if (opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c > System.today().addDays(1)) {
                    earliestStartDate = opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c;
                    System.debug('FirstDayforStudents__c earliestStartDate:' + earliestStartDate);
                } else {
                    earliestStartDate = System.today().addDays(1);
                    System.debug('System.today() earliestStartDate:' + earliestStartDate);
                }
            }

            System.debug('progEnrollMap.get(opportunityRecord.Program_Enrollment__c)' + progEnrollMap.get(opportunityRecord.Program_Enrollment__c));

            //Checking if Program enrollment has any enrollment record associated, if not here we create one enrollment record for that program enrollment & logic for poppulating enrollment Date field is defined in if condition
            //But if enrollment record is present for program enrollment then it check if enrollment's enrollment date field is empty or not,if empty then logic for populating the same is defined in else condition.
            //But if enrollment record with populated enrollment date for program enrollment is present then do nothing.
            if (progEnrollMap.get(opportunityRecord.Program_Enrollment__c).size() == 0) {
                System.debug('Insert of the enrollment Record');
                //Added Enrollment_Type__c population for enrrollment record by Jagadish Babu as part of ITR events US
                Enrollment__c enrollmentRecord = new Enrollment__c(Program_Enrollment__c = opportunityRecord.Program_Enrollment__c,Enrollment_Type__c= opportunityRecord.Program_Enrollment__r.Enrollment_Type__c, School_Year__c = opportunityRecord.Program_Enrollment__r.Start_Year__c);
                //Checking for program enrollment associated account FirstDayforStudents__c field greater than opportunity PreferredStartDate__c field & populating Enrollment_Date__c field on basis of whichever is greater.
                if (opportunityRecord.Program_Enrollment__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c > opportunityRecord.PreferredStartDate__c) {
                    //Checking between program enrollment associated account FirstDayforStudents__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                    if (opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c > earliestStartDate) {
                        enrollmentRecord.Enrollment_Date__c = opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c;
                    } else {
                        enrollmentRecord.Enrollment_Date__c = earliestStartDate;
                    }
                } else {
                    //Checking between opportunity PreferredStartDate__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                    if (opportunityRecord.PreferredStartDate__c > earliestStartDate) {
                        enrollmentRecord.Enrollment_Date__c = opportunityRecord.PreferredStartDate__c;
                    } else {
                        enrollmentRecord.Enrollment_Date__c = earliestStartDate;
                    }
                }
                enrollmentRecordList.add(enrollmentRecord);
            } else {
                System.debug('In Existing Enrollment Record else');
                //Iterating over enrollment record related to program enrollment.
                for (Enrollment__c enrollmentRecord : progEnrollMap.get(opportunityRecord.Program_Enrollment__c)) {
                    //Checking if enrollment's enrollment date is empty or not, if empty logic to populating it is defined below.If not doing nothing.
                    if (enrollmentRecord.Enrollment_Date__c == null) {
                        //Checking for program enrollment associated account FirstDayforStudents__c field greater than opportunity PreferredStartDate__c field & populating Enrollment_Date__c field on basis of whichever is greater.
                        if (opportunityRecord.Program_Enrollment__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__c <> null && opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c > opportunityRecord.PreferredStartDate__c) {
                            //Checking between program enrollment associated account FirstDayforStudents__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                            if (opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c > earliestStartDate) {
                                enrollmentRecord.Enrollment_Date__c = opportunityRecord.Program_Enrollment__r.hed__Account__r.FirstDayforStudents__c;
                            } else {
                                enrollmentRecord.Enrollment_Date__c = earliestStartDate;
                            }
                        } else {
                            //Checking between opportunity PreferredStartDate__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                            if (opportunityRecord.PreferredStartDate__c > earliestStartDate) {
                                enrollmentRecord.Enrollment_Date__c = opportunityRecord.PreferredStartDate__c;
                            } else {
                                enrollmentRecord.Enrollment_Date__c = earliestStartDate;
                            }
                        }
                        enrollmentRecordList.add(enrollmentRecord);
                    }
                }
            }
        }
        //Upserting the list of new & updated enrollment record.
        System.debug('enrollmentRecordList' + enrollmentRecordList);
        try {
            integer i=0;
                do{
                    try{
                       i++;
                       upsert enrollmentRecordList;                
                       break;//Breaking the loop as the DML executed and no exceptions
                }
                    catch(Exception e){
                        logger.logException('Retrying a timed out insert', e);
                        logger.saveLogs();                        
                    }
                }while(i<10);
            //upsert enrollmentRecordList;
        } catch(Exception e) {
            logger.logException('populateEnrollmentDate_Update', e);
            logger.saveLogs();
            throw e;
        }
    }
    /**
     * Created By Anand on 12/17/2018
     * purpose is to call the calcaulate reactivationDate Function in BusinessLogic Utils method .
     * @param oldMap
     * @param newMap
     */
    public static void reactivationDateUpdate(List<Opportunity> opportunities) {
        List<Opportunity> optyList = new List<Opportunity>();
        for (Opportunity opty : opportunities) {
            if (NES_LogicFeatureSwitch__c.getValues('Reactivation Date') <> NULL
                    && NES_LogicFeatureSwitch__c.getValues('Reactivation Date').Active__c == True) {

                optyList.add(opty);
            }
        }
        if (!optyList.isEmpty()) {
            NES_BusinessLogicUtils.calculateReactivationDate(optyList);
        }
    }

    // Used to mark the PE if there is an open opportunity
    public static void markOpenOpportunity(List<Opportunity> opportunities) {

        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> allEnrollmentIds = new Set<Id>();
        Set<Id> nonOpenOppEnrollmentIds = new Set<Id>();
        for(Opportunity singleOpportunity : opportunities) {
            allEnrollmentIds.add(singleOpportunity.Program_Enrollment__c);
            if(!singleOpportunity.StageName.contains('Closed')) {
                programEnrollmentIds.add(singleOpportunity.Program_Enrollment__c);
            }
        }

        for(Id programEnrollmentId : allEnrollmentIds) {

            if(!programEnrollmentIds.contains(programEnrollmentId)) {
                nonOpenOppEnrollmentIds.add(programEnrollmentId);
            }
        }

        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();

        if(programEnrollmentIds.size() > 0) {
            programEnrollments = [SELECT Id FROM hed__Program_Enrollment__c WHERE Id IN : programEnrollmentIds AND Has_Open_Opportunity__c = FALSE];

            for(hed__Program_Enrollment__c programEnrollment : programEnrollments) {
                programEnrollment.Has_Open_Opportunity__c = true;
            }


        }
        if(nonOpenOppEnrollmentIds.size() > 0) {
            List<hed__Program_Enrollment__c> noOppEnrollments = [SELECT Id FROM hed__Program_Enrollment__c WHERE Id IN : nonOpenOppEnrollmentIds AND Has_Open_Opportunity__c = TRUE];

            for(hed__Program_Enrollment__c programEnrollment : noOppEnrollments) {
                programEnrollment.Has_Open_Opportunity__c = false;
                programEnrollments.add(programEnrollment);
            }
        }
        if(programEnrollments.size() > 0) {
            update programEnrollments;
        }
    }
    /**
     * Created By Anand on 12/17/2018
     * purpose is to call the calcaulate HouseholdEnrollmentDate Function in BusinessLogic Utils method
     * @param oldMap
     * @param newMap
     */
    public static void householdDateUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        System.debug('In HouseHoldDateUpdate');
        List<Opportunity> optyList = new List<Opportunity>();
        for (Id oppId : oldMap.KeySet()) {
            if (NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date') <> NULL && oldMap.get(oppId).StageName != newMap.get(oppId).StageName &&
                    NES_LogicFeatureSwitch__c.getValues('Household Enrollment Date').Active__c == True && newMap.get(oppId).StageName == 'Closed Won') {

                optyList.add(newMap.get(oppId));
            }
        }
        if (!optyList.isEmpty()) {
            NES_BusinessLogicUtils.calculateHouseholdEnrollmentDate(optyList);
        }
    }

    /**
    * Created By Anushka on 12/18/2018
    * purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Update.
    */

    public static void calculateLTS(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        System.debug('In calculateLTS+++');
        Set<Id> programEnrollmentIds = new Set<Id>();
        for (Opportunity opp : newList) {
            if (oldMap != null) {
                if ((opp.SFDC_Informed__c != oldMap.get(opp.Id).SFDC_Informed__c ||
                        opp.SFDC_Engaged_Grassroots_User__c != oldMap.get(opp.Id).SFDC_Engaged_Grassroots_User__c)
                        && (!opp.StageName.contains('Closed') || (opp.stageName != oldMap.get(opp.Id).StageName && opp.StageName != 'Closed-Won')))
                    programEnrollmentIds.add(opp.Program_Enrollment__c);

            } else if ((opp.SFDC_Informed__c != null || opp.SFDC_Engaged_Grassroots_User__c != null) && !opp.StageName.contains('Closed')) {

                programEnrollmentIds.add(opp.Program_Enrollment__c);
            }
        }

        List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentIds);
        try {
            update programEnrollments;
        } catch(Exception e) {
            logger.logException('calculateLTS', e);
            logger.saveLogs();
            throw e;
        } 
    }

}