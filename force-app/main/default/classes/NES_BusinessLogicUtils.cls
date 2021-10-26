/**
* Created by Anand on 12/10/2018.
* purpose:to be used to hold the logic for business logic methods that work on multiple trigger objects
* Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
* Added Fields and logic for HHFedPovertyEligibility & HHFARMEligCalculate US117580 (Jagadeesh) on 11/13/2019
*/

public without sharing class NES_BusinessLogicUtils {
    private static Peak_ApexLog logger = new Peak_ApexLog('BusinessLogicUtils');
    
    //Static variable to check calculateHighSchoolLTS method does call recursively on after update or insert call by program enrollment trigger.
    static Boolean isProgEnrollLTSFire = true;
    public static Boolean runWhyFlagged = true;
    static final String ANNUAL_STUDENT_INFORMATION_OBJECT = 'Annual_Student_Information__c';
    static final String ENROLLMENT_DOCUMENT_OBJECT = 'Enrollment_Document__c';
    static final String PROGRAM_ENROLLMENT_OBJECT = 'hed__Program_Enrollment__c';
    static final String SPECIAL_EDUCATION_OBJECT = 'Special_Education__c';
    static final String PROGRAM_GRADE_LEVEL_OBJECT = 'Program_Grade_Level__c';
    /**
* Created by Ritvik on 18/12/18.
* Purpose : Method to check if field contains or equals to a certain string.
* Params : @actualText - takes string field value.
*          @expectedText - takes string which we want to check against.
*          @isExactMatch - True for equals condition & False for contains condition.
*/
    private static Boolean isMatch(String actualText, String expectedText, boolean isExactMatch) {
        if (String.isNotBlank(actualText)) {
            if ((isExactMatch && actualText.equals(expectedText)) ||
                ((!isExactMatch) && actualText.contains(expectedText))) {
                    return true;
                }
        }
        return false;
        
    }
    
    public List<Hed__Program_Enrollment__c> proEnrollmentList = new List<Hed__Program_Enrollment__c>();
    /**
*  Create By Anand on 12/10/2018
* Purpose : To update ELLFlag field whenever home language,AnnualStudentInfo,ProgramEnrollment triggers are used base don the condition
* @param hlsInsertList
* @param studentInfoList
* @param progEnrollmentList
*/
    public void calculateELLFlag(List<Home_Language_Survey__c> hlsInsertList, List<Annual_Student_Information__c> studentInfoList, List<Hed__Program_Enrollment__c> progEnrollmentList) {
        Set<Id> enrollmentIds = new Set<Id>();
        Set<Id> enrollmentsToUpdateNull = new Set<Id>();
        Set<Id> enrollmentIdsH = new Set<Id>();
        if (!studentInfoList.isEmpty() && studentInfoList != Null) {
            // This method is called only when a annualStudent Info Trigger is fired
            for (Annual_Student_Information__c studInfo : studentInfoList) {
                // If StudentIsELL__c is true then add  programEnrollmentId to enrollmentIds
                if (studInfo.StudentIsELL__c == True) {
                    enrollmentIds.add(studInfo.Program_Enrollment__c);
                    
                } else { // if StudentIsELL__c false then add to programEnrollmentId to enrollmentsToUpdateNull
                    enrollmentsToUpdateNull.add(studInfo.Program_Enrollment__c);
                    
                }
            }
            if (!enrollmentIds.isEmpty()) { // fetchProgramEnrollments method is called to update the ELLFlag
                fetchProgramEnrollments(enrollmentIds, 'EL Student');
            }
            
        } 
        else if (!hlsInsertList.isEmpty() && hlsInsertList <> Null) { // This method is called only when a HomeLangSurvey Trigger is fired
            for (Home_Language_Survey__c homeLangSurvey : hlsInsertList) {
                if (homeLangSurvey.Program_Enrollment__c != Null && homeLangSurvey.HLS_Date_Completed__c == Null) {
                    enrollmentIds.add(homeLangSurvey.Program_Enrollment__c);
                    
                } else {
                    //Swapna: ELL Flag issue fix
                    if (homeLangSurvey.Program_Enrollment__c != Null && homeLangSurvey.HLS_Student_Flag__c == true && homeLangSurvey.HLS_Date_Completed__c != Null) 
                    { 
                        enrollmentIdsH.add(homeLangSurvey.Program_Enrollment__c);}
                    else
                        enrollmentsToUpdateNull.add(homeLangSurvey.Program_Enrollment__c);
                    
                }
                
            }
            if (!enrollmentIds.isEmpty()) {
                fetchProgramEnrollments(enrollmentIds, Null);
            }
            //Swapna: ELL Flag issue fix
            if (!enrollmentIdsH.isEmpty()) {
                fetchProgramEnrollments(enrollmentIdsH, 'Potential EL');
            }
            
        }
        else if (!progEnrollmentList.isEmpty() && progEnrollmentList <> Null) { // This method is called only when a programEnrollment Trigger is fired
            for (Hed__Program_Enrollment__c progEnrollment : progEnrollmentList) {
                // if (progEnrollment.HLSStudentFlag__c == True) 
                // Swapna ELL Flag Update
                if (progEnrollment.HLSStudentFlag__c == True &&  progEnrollment.HLS_Date_Completed__c != Null)   
                {
                    enrollmentIds.add(progEnrollment.Id);
                    
                } else {
                    enrollmentsToUpdateNull.add(progEnrollment.Id);
                    
                }
            }
            if (!enrollmentIds.isEmpty()) {
                fetchProgramEnrollments(enrollmentIds, 'Potential EL');
                
            }
        }
        if (!enrollmentsToUpdateNull.isEmpty()) { // This method update ELLFlag to Null
            fetchProgramEnrollments(enrollmentsToUpdateNull, Null);
            
        }
        try {
            update proEnrollmentList;
        } catch (DmlException e) {logger.logException('calculateELLFlag', e);logger.saveLogs();}
        
    }
    /**
* Created By Anand
*purpose : To update program Enrollment Based on the parameters passed
* @param progEnrollmentIds
* @param ellFlag
*/
    public void fetchProgramEnrollments(Set<Id> progEnrollmentIds, String ellFlag) {
        
      
        
        for (Hed__Program_Enrollment__c progEnrollment : [
            SELECT
            Id,
            ELLFlag__c
            FROM Hed__Program_Enrollment__c
            Where Id in:progEnrollmentIds
        ]) {
            progEnrollment.ELLFlag__c = ellFlag;
            proEnrollmentList.add(progEnrollment);
        }
    }
    /**
* Created by Anand 12/11/2018
* purpose: To upload the Status of document.
*/
    public static void calculateHHPORStatus(Set<Id> enrollmentDocIds) {
        system.debug('in calculateHHPORStatus');
        List<hed__Program_Enrollment__c> peToUpdate = new List<hed__Program_Enrollment__c>();
        Map<id, string> pePORValueMap = new Map<id, string>();
        Set<id> peIds = new Set<Id>();
        // update Status of document to program enrollment HHPORStatus__c
        for (Enrollment_Document__c enDoc : [
            select Id,Program_Enrollment__c,Program_Enrollment__r.HHPORStatus__c,
            Status_Reason__c
            FROM Enrollment_Document__c
            WHERE ID IN:enrollmentDocIds
        ]) {
            
            if (String.isNotBlank(enDoc.Status_Reason__c) && enDoc.Program_Enrollment__c != null) {
                System.debug('In Ifff++');
                pePORValueMap.put(enDoc.Program_Enrollment__c, enDoc.Status_Reason__c);
                peIds.add(enDoc.Program_Enrollment__c);
            }
            
        }
        
        //SOQL replaced by a call to GenericSOQLQueries for 430196 on 2021-08-03 by Krishna Peddanagammol
        //for (hed__Program_Enrollment__c currentPE : [SELECT id, HHPORStatus__c FROM hed__Program_Enrollment__c WHERE ID IN :peIds]) {
        for (hed__Program_Enrollment__c currentPE : GenericSOQLQueries.programEnrollmentDetails(peIds)) {   
            if (pePORValueMap.containsKey(currentPE.id)) {
                System.debug('pePORValueMap.get(currentPE.id)++++' + pePORValueMap.get(currentPE.id));
                currentPE.HHPORStatus__c = pePORValueMap.get(currentPE.id);
                peToUpdate.add(currentPE);
            }
        }
        try {
            if(peToUpdate.size()>0) {
                update peToUpdate;
            }
        } catch (exception e) {System.debug('exception is ' + e.getMessage());logger.logException('calculateHHPORStatus', e);logger.saveLogs();}
        
    }
    
    
    /**
* Created by Anushka Bansal on 11/12/18.
* Purpose : Method to calculate Entrance Age Eligibility Override on Program Enrollment.
*/
    
    public static List<Hed__Program_Enrollment__c> calculateEntranceAgeEligibilityOverrideReview(List<Hed__Program_Enrollment__c> programEnrollmentList) {
        /*
* 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {

String oldEntranceAgeEligibilityOverride = progEnrollment.EntranceAgeEligibilityOverride__c ;

if (progEnrollment.EntranceAgeEligibilityOverride__c != null && progEnrollment.EntranceAgeEligibility__c == 'Eligible')
progEnrollment.EntranceAgeEligibilityOverride__c = null;

else if (progEnrollment.EntranceAgeEligibilityOverride__c == null) {

if (progEnrollment.EntranceAgeEligibility__c == 'Too young' || progEnrollment.EntranceAgeEligibility__c == 'Too old')
progEnrollment.EntranceAgeEligibilityOverride__c = 'Ineligible'; else if (progEnrollment.EntranceAgeEligibility__c == 'Too young - other options' || progEnrollment.EntranceAgeEligibility__c == 'Too old - other options')
progEnrollment.EntranceAgeEligibilityOverride__c = 'Ineligible- Other options'; else
progEnrollment.EntranceAgeEligibilityOverride__c = 'Pending Review';
}

if (oldEntranceAgeEligibilityOverride != progEnrollment.EntranceAgeEligibilityOverride__c)
progEnrollment.EntAgeEliOvrDate__c = system.today();
}
*/
        return programEnrollmentList;
    }
    
    // test data: 
    // PE with hed__Account__c & hed__Contact__c
    // Program_PostalCode__c records for hed__Account__c
    // Account.shippingstate == hed__Contact__c.account.shippingstate
    
    // Test On: 
    // Assert on 'AddressEligibilitySystem__c' is Eligible OR Ineligible
    
    
    // Trigger point: 
    // 1. PE creation
    // 2. Account Address Change
    
    /**
* Created by Mark Membrino on 10/24/19.
* Purpose : Method to calculate Address Eligibility Story 113910`.
*/
    public static List<Hed__Program_Enrollment__c> calculateAddressEligibility(List<Hed__Program_Enrollment__c> programEnrollmentList) {
        
        Set<Id> academicProgramsReferenced = new set <Id> ();
        Set<Id> contactsReferenced = new Set<Id>();
        System.debug('*****programEnrollmentList:' + programEnrollmentList);
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            academicProgramsReferenced.add(progEnrollment.hed__Account__c);
            contactsReferenced.add(progEnrollment.hed__Contact__c);
        }
        
        Map<Id, Account> academicProgramMap = new Map<Id, Account> ();
        Map<Id, Set<String>> academicProgramPostals = new Map<Id, Set<String> > ();
        
        //Start- Added for the bug 130516
        for (account AP : [Select Id, parentid, parent.shippingstate from account where id in :academicProgramsReferenced] )
        {
            academicProgramMap.put(AP.Id, AP);
            
        }
        Map<string,Boolean> postalCodes=new Map<string, Boolean>();// Added code for the User Story #154114 on 06/04/2020
        for(Program_PostalCode__c ppc: [select id, Potentially_Ineligible__c, PostalCode__c,Academic_Program__c from Program_PostalCode__c where Academic_Program__c = :academicProgramMap.keyset()]){
            Set<String> thisAPsPostals;
            string value ;
           //value  = ppc.PostalCode__c + ppc.Potentially_Ineligible__c;
            if(!academicProgramPostals.containsKey(ppc.Academic_Program__c))
                thisAPsPostals = new set<String>();
            else
                thisAPsPostals = academicProgramPostals.get(ppc.Academic_Program__c);
            
            thisAPsPostals.add(ppc.PostalCode__c);
            academicProgramPostals.put(ppc.Academic_Program__c, thisAPsPostals);    
            postalCodes.put( ppc.PostalCode__c,ppc.Potentially_Ineligible__c);  // Added code for the User Story #154114 on 06/04/2020       
        }
        //End-Added for the bug 130516
        
        
        //Get the students data.
        map<Id, contact> progEnrollStudentDataMap = new map<Id, contact> ();
        for (contact con : [select id, account.shippingstreet,account.shippingstate, account.ShippingPostalCode, account.ShippingAddress,account.shippingcity,account.shippingcountry from contact where id in :contactsReferenced])
        {
            progEnrollStudentDataMap.put (con.Id, con);
        }
        
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            //If the Academic program associated to the Program Enrollment has any associated postal codes
            //then we need to validate the address by postal, if there are no postals for this academic program
            //then validate by state.
            
            
            if (academicProgramPostals.containsKey(progEnrollment.hed__Account__c)) {
                //Use the postal code rules.
                Set<string> thisAPsPostals = academicProgramPostals.get(progEnrollment.hed__Account__c);
                string thisStudentsPostal = progEnrollStudentDataMap.get(progEnrollment.hed__Contact__c).account.ShippingPostalCode.left(5);
                // Added code for the User Story #154114 on 06/04/2020
                
                if(thisAPsPostals.contains(thisStudentsPostal) && postalCodes.get(thisStudentsPostal) ==true){
                    progEnrollment.AddressEligibilitySystem__c = 'Pending';  
                }
                // End code for the User Story #154114 on 06/04/2020
                else if (thisAPsPostals.contains(thisStudentsPostal))
                    progEnrollment.AddressEligibilitySystem__c = 'Eligible';
                else
                    progEnrollment.AddressEligibilitySystem__c = 'Ineligible';
            } else {
                //Use the state eligibility
                if ( progEnrollStudentDataMap.containsKey(progEnrollment.hed__Contact__c) && progEnrollStudentDataMap.get(progEnrollment.hed__Contact__c).account.shippingstate == academicProgramMap.get(progEnrollment.hed__Account__c).parent.shippingstate )
                    progEnrollment.AddressEligibilitySystem__c = 'Eligible';
                else
                    progEnrollment.AddressEligibilitySystem__c = 'Ineligible';
            }
        }
        
        return programEnrollmentList;
    }
    
    /**
* Created by Mark Membrino on 10/28/19.
* Purpose : Method to calculate the Disciplinary Flag Story 113960.
*/
    public static List<Hed__Program_Enrollment__c> flagDisciplinaryAction(List<Hed__Program_Enrollment__c> programEnrollmentList) {
        System.debug ('*****In flagDisciplinaryAction records:' + programEnrollmentList);
        Set<Id> academicProgramsReferenced = new set <Id> ();
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            academicProgramsReferenced.add(progEnrollment.hed__Account__c);
        }
        
        Map<Id, Account> academicProgramMap = new Map<Id, Account> ();
        
        //Get the Academic program data.
        for (account AP : [Select Id, School_Start_Date__c, Disciplinary_Action_Currently_Expelled__c, Disciplinary_Action_Currently_Suspended__c, Disciplinary_Action_Ever_Expelled__c, Disciplinary_Action_Ever_Suspended__c from account where id in :academicProgramsReferenced] ) {
            academicProgramMap.put(AP.Id, AP);
        }
        
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            //If there are no past actions on this PE, there will be no updates to make so 
            //just skip the record.
            if (progEnrollment == null || progEnrollment.DisciplinaryPastActions__c == null)
                continue;
            
            //For each PE, calculate if the student is expelled or suspended and if that is current.
            boolean currentlyExpelled = false;
            boolean everExpelled = false;
            boolean currentlySuspended = false;
            boolean everSuspendend = false;
            
            //When figuring out if the suspension or expulsion is still have, use todays day or the start of school whichever is later.
            date dateForComparison = System.today();
            if (academicProgramMap.containsKey(progEnrollment.hed__Account__c) && academicProgramMap.get(progEnrollment.hed__Account__c).School_Start_Date__c > dateForComparison)
                dateForComparison = academicProgramMap.get(progEnrollment.hed__Account__c).School_Start_Date__c;
            
            //Calculate the students current status
            if (progEnrollment.DisciplinaryPastActions__c.containsIgnoreCase('suspended')) {
                everSuspendend = true;
                if (progEnrollment.End_Date_of_Disciplinary_Action__c >= dateForComparison)
                    currentlySuspended = true;
            }
            if (progEnrollment.DisciplinaryPastActions__c.containsIgnoreCase('expelled')) {
                everExpelled = true;
                if (progEnrollment.End_Date_of_Disciplinary_Action__c >= dateForComparison)
                    currentlyExpelled = true;
            }
            
            //Use the students current status and what the institution does for each and determine what the DisciplinaryFlagOverride__c should be set to.
            string ever_exp_status;
            string cur_exp_status;
            string ever_susp_status;
            string cur_susp_status;
            
            if (everExpelled && academicProgramMap.containsKey(progEnrollment.hed__Account__c) && !String.isBlank(academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Ever_Expelled__c))
                ever_exp_status = academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Ever_Expelled__c;
            if (currentlyExpelled && academicProgramMap.containsKey(progEnrollment.hed__Account__c) && !String.isBlank(academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Currently_Expelled__c))
                cur_exp_status = academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Currently_Expelled__c;
            if (everSuspendend && academicProgramMap.containsKey(progEnrollment.hed__Account__c) && !String.isBlank(academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Ever_Suspended__c))
                ever_susp_status = academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Ever_Suspended__c;
            if (currentlySuspended && academicProgramMap.containsKey(progEnrollment.hed__Account__c) && !String.isBlank(academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Currently_Suspended__c))
                cur_susp_status = academicProgramMap.get(progEnrollment.hed__Account__c).Disciplinary_Action_Currently_Suspended__c;
            
            if ( ever_exp_status == 'Withdraw' || cur_exp_status == 'Withdraw' || ever_susp_status == 'Withdraw' || cur_susp_status == 'Withdraw' )
                progEnrollment.DisciplinaryFlagOverride__c = 'Withdraw';
            else if ( ever_exp_status == 'Pending Review' || cur_exp_status == 'Pending Review' || ever_susp_status == 'Pending Review' || cur_susp_status == 'Pending Review' )
                progEnrollment.DisciplinaryFlagOverride__c = 'Pending Review';
        }
        
        return programEnrollmentList;
    }
    
    /**
* Created by Mark Membrino on 10/29/19.
* Purpose : Method to calculate the Technology Flag Story 114150.
*/
    //Commented Deprecate Technology flag logic for US 476956
    /*public static List<Hed__Program_Enrollment__c> flagTechnologyAction(List<Hed__Program_Enrollment__c> programEnrollmentList) {
        Set<Id> academicProgramsReferenced = new set <Id> ();
        Set<Id> contactsReferenced = new Set<Id>();
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            academicProgramsReferenced.add(progEnrollment.hed__Account__c);
            contactsReferenced.add(progEnrollment.hed__Contact__c);
        }
        
        Map<Id, Account> academicProgramMap = new Map<Id, Account> ();
        
        //Get the Academic program data.
        for (account AP : [Select Id, TechnologyFlagAction__c from account where id in :academicProgramsReferenced] ) {
            academicProgramMap.put(AP.Id, AP);
        }
        
        //Get the students data.
        map<Id, contact> progEnrollStudentDataMap = new map<Id, contact> ();
        for (contact con : [select id, account.Computer_in_Home__c from contact where id in :contactsReferenced])
        {
            progEnrollStudentDataMap.put (con.Id, con);
        }
        
        for (Hed__Program_Enrollment__c progEnrollment : programEnrollmentList) {
            
            if (progEnrollStudentDataMap.containsKey(progEnrollment.hed__Contact__c) && progEnrollStudentDataMap.get(progEnrollment.hed__Contact__c).account.Computer_in_Home__c == 'No'  && academicProgramMap.containsKey(progEnrollment.hed__Account__c) && !String.isBlank(academicProgramMap.get(progEnrollment.hed__Account__c).TechnologyFlagAction__c))
                progEnrollment.UserTechnologyFlag__c = academicProgramMap.get(progEnrollment.hed__Account__c).TechnologyFlagAction__c;
        }
        
        return programEnrollmentList;
    }*/
    
    /**
* Created by Mark Membrino on 11/11/19.
* Purpose : Method to move the program start year from a new PE to the associated contact Story 117569.
*/
    //Mark Membrino 2/24/2020 Since this is called from a queable now, it can't be @future. 
    //@future
    public static void updateContactStartYear(Set<string> programEnrollments) {
        Set<Id> contactsReferenced = new Set<Id>();
        Map<Id, Id> contactToPEStartYear = new Map<Id, Id> ();
        for (Hed__Program_Enrollment__c progEnrollment : [ SELECT Id, Start_Year__c, hed__Contact__c, hed__Contact__r.CA_StartYear__c
                                                          FROM Hed__Program_Enrollment__c  Where Id in :programEnrollments ]) {
         
                                                              
                                                              //Be sure we don't add the same contact twice and that the contact doesn't already have a date set.
                                                              if (!contactsReferenced.contains(progEnrollment.hed__Contact__c) && progEnrollment.Start_Year__c != null && progEnrollment.hed__Contact__r.CA_StartYear__c == null)
                                                              {
                                                                  contactsReferenced.add(progEnrollment.hed__Contact__c);
                                                                  contactToPEStartYear.put(progEnrollment.hed__Contact__c, progEnrollment.Start_Year__c);
                                                              }
                                                          }
        
        List<Contact> contactsToUpdate = new List<Contact> ();
        for (id i:contactsReferenced){
            id newStartYear = contactToPEStartYear.get(i);
            contactsToUpdate.add(new contact(Id=i, CA_StartYear__c=contactToPEStartYear.get(i)));
        }
        
        if (contactsToUpdate.size() > 0)
            update contactsToUpdate;
    }
    
    
    /**
* Created by Anushka Bansal on 11/12/18.
* Purpose : Method to update the Immunization current Status on the Health and Immunization record.
*/
    
    public static List<Health_and_Immunization__c> updateImmunizationStatusCurrent(List<Health_and_Immunization__c> healthAndImmunizationList) {
        for (Health_and_Immunization__c hni : healthAndImmunizationList) {
            system.debug('business utils');
            if (hni.Immunization_Status_FollowUp__c != null)
                hni.Immunization_Status_Current__c = hni.Immunization_Status_FollowUp__c; else if (hni.Immunization_Status__c != null)
                    hni.Immunization_Status_Current__c = hni.Immunization_Status__c ; else
                        hni.Immunization_Status_Current__c = null;
        }
        
        return healthAndImmunizationList;
        
    }
    /**
* Created by Raju on 11/12/18.
* Purpose : Method is used to Set Program_Enrollment__c.DocumentUploadDate__c to Enrollment_Document__c.CreatedDate
*/
    public static void updateLastDocUploadDate(List<Enrollment_Document__c> enrollmentDocList) {
        //Get the set of Program Enrollment ids related to Enrollment Document
        Set<Id> peIdset = new Set<Id>();
        for (Enrollment_Document__c ecDocument : enrollmentDocList) {
            if (ecDocument.Program_Enrollment__c != null) {
                peIdset.add(ecDocument.Program_Enrollment__c);
            }
        }
        
        Map<Id, Datetime> perelatedEDFirstcreatedRecordMap = new Map<Id, Datetime>();
        
        if (peIdset.size() > 0) {
            
            for (Enrollment_Document__c ecDocument : [
                SELECT Id,
                Program_Enrollment__c,
                CreatedDate
                FROM Enrollment_Document__c
                WHERE Program_Enrollment__c IN:peIdset
                ORDER BY CreatedDate ASC
            ]) {
                System.debug('ecDocument id:: ' + ecDocument.Id);
                if (!perelatedEDFirstcreatedRecordMap.containsKey(ecDocument.Program_Enrollment__c)) {
                    perelatedEDFirstcreatedRecordMap.put(ecDocument.Program_Enrollment__c, ecDocument.CreatedDate);
                }
            }
            
            List<hed__Program_Enrollment__c> updatePEList = new List<hed__Program_Enrollment__c>();
            for (Id peecordId : peIdset) {
                if (perelatedEDFirstcreatedRecordMap != null && perelatedEDFirstcreatedRecordMap.containsKey(peecordId) && perelatedEDFirstcreatedRecordMap.get(peecordId) != null) {
                    
                    hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c();
                    programEnrollment.DocumentUploadDate__c = perelatedEDFirstcreatedRecordMap.get(peecordId);
                    programEnrollment.Id = peecordId;
                    updatePEList.add(programEnrollment);
                }
                
            }
            
            if (updatePEList.size() > 0) {
                try {
                    update updatePEList;
                } catch (exception e) {System.debug('Exception Thrown+' + e.getMessage());logger.logException('updateLastDocUploadDate', e);logger.saveLogs();}
            }
        }
    }
    
    /**
* Created by Ajith on 12/12/18.
* Purpose : Method to Update the Last School Type and Last School State
* Params : newList and oldMap from the Prior School trigger handler
*/
    public static void updateLastSchoolStateandType(List<Prior_School__c> newList, Map<Id, Prior_School__c> oldMap) {
        List<Id> validPriorSchoolsList = new List<Id>();
        List<Id> programEnrollmentIds = new List<Id>();
        List<hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
        //Loop through the Prior Schools and check for the fields null condition and add them to the lists accordingly
        for (Prior_School__c school : newList) {
            if (oldMap != null) {
                if (oldMap.get(school.Id) != null && (oldMap.get(school.Id).State__c != school.State__c ||
                                                      oldMap.get(school.Id).SchoolType__c != school.SchoolType__c)) {
                                                          validPriorSchoolsList.add(school.Id);
                                                          programEnrollmentIds.add(school.Program_Enrollment__c);
                                                      }
            } else if (school.SchoolType__c != null || school.State__c != null) {
                validPriorSchoolsList.add(school.Id);
                programEnrollmentIds.add(school.Program_Enrollment__c);
            }
        }
        
        System.debug('validPriorSchoolsList++' + validPriorSchoolsList);
        System.debug('programEnrollmentIds+++' + programEnrollmentIds);
        //Loop through the Prior Schools matching out criteria and update the Program enrollments fields accordingly
        if (validPriorSchoolsList.size() > 0) {
            for (hed__Program_Enrollment__c rec : [
                SELECT Id, LastSchoolState__c, LastSchoolType__c, (
                    SELECT Id, State__c, SchoolType__c
                    FROM Prior_Schools__r
                )
                FROM hed__Program_Enrollment__c
                WHERE Id IN:programEnrollmentIds
            ]) {
                if (rec.Prior_Schools__r != null) {
                    for (Prior_School__c sch : rec.Prior_Schools__r) {
                        if (validPriorSchoolsList.contains(sch.Id)) {
                            System.debug('In Final If');
                            if (sch.SchoolType__c != null) {
                                rec.LastSchoolType__c = sch.SchoolType__c;
                            }
                            if (sch.State__c != null) {
                                rec.LastSchoolState__c = sch.State__c;
                            }
                            programEnrollmentsToUpdate.add(rec);
                        }
                    }
                }
            }
            System.debug('programEnrollmentsToUpdate++' + programEnrollmentsToUpdate);
            //Check the list size and Update the Program Enrollments
            if (programEnrollmentsToUpdate.size() > 0) {
                try {
                    update programEnrollmentsToUpdate;
                } catch (Exception ex) {System.debug('Error Message:::' + ex.getMessage());logger.logException('updateLastSchoolStateandType', ex);logger.saveLogs();}
            }
        }
    }
    /**
* Created by Raju on 12/13/18.
* Purpose : Method is used to Set set Program_Enrollment__c.HomelessRiskFlag__c to “Potential Homeless”
*/
    
    public static void calculateHomelessRiskFlag(Set<Id> accountIdSet) {
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        List<hed__Program_Enrollment__c> updatePEList = new List<hed__Program_Enrollment__c>();
        for (hed__Program_Enrollment__c peRecord : [
            SELECT Id,
            HomelessRiskFlag__c
            FROM hed__Program_Enrollment__c
            WHERE hed__Contact__r.AccountId IN:accountIdSet
            AND hed__Contact__r.RecordTypeId = :studentRecordTypeId
        ]) {
            
            if (peRecord.HomelessRiskFlag__c == null) {
                peRecord.HomelessRiskFlag__c = 'Potential Homeless';
                updatePEList.add(peRecord);
            }
        }
        
        if (updatePEList.size() > 0) {
            try {
                update updatePEList;
            } catch (exception e) {logger.logException('calculateHomelessRiskFlag', e);logger.saveLogs();}
        }
    }
    
    /**
* Created by Ritvik on 13/12/18.
* Purpose : Populating HLS_Language_Spoken_By_Adults__c field on after Insert or update of Home_Language_Survey__c record.
* Params : List of Home_Language_Survey__c Record Ids.
*/
    public static void calculateHLSLanguageSpokenByAdults(Set<Id> hlsIds) {
        //String to store comma seperated language list.
        String languageList = '';
        
        //Map to store id as program enrollment id & value as home language survey id.
        Map<Id, Id> progEnrollHlsMap = new Map<Id, Id>();
        
        //List to store home language survey records.
        List<Home_Language_Survey__c> updateHLSList = new List<Home_Language_Survey__c>();
        
        //Map to store id as program enrollment id & value as oppportunity related to it.
        Map<Id, Opportunity> progEnrollOpportunity = new Map<Id, Opportunity>();
        List<Home_Language_Survey__c> homeLanguageSurveys = new List<Home_Language_Survey__c>();
        for (Home_Language_Survey__c homeLanguageSurvey : [SELECT Id,Program_Enrollment__c,HLS2_Spoken_To_Child__c,Language_spoken__c,HLS_Student_At_Home__c,HLS_Home_Often_Spoken__c,HLS2_Home_Language__c,
                                                           HLS2_Home_Language_Many__c,HLS2_Home_Language_NE__c,HLS_Speak_Understand_NE_YN__c,HLS_Language_Spoken_By_Adults__c FROM Home_Language_Survey__c WHERE Id IN :hlsIds]) {
                                                               
                                                               progEnrollHlsMap.put(homeLanguageSurvey.Id, homeLanguageSurvey.Program_Enrollment__c);
                                                               homeLanguageSurveys.add(homeLanguageSurvey);
                                                           }
        //Start : Removed Reactivation_Date__c from loop query as it is been deleted by Ritvik on 01/16/2019.
        for (Opportunity opportunity : [
            SELECT Program_Enrollment__c,CreatedDate, Reactivation__c
            FROM Opportunity
            WHERE Program_Enrollment__c IN :progEnrollHlsMap.values() AND
            (NOT StageName LIKE 'Closed%')
            Order By CreatedDate DESC
            Limit 1
        ]) {
            progEnrollOpportunity.put(opportunity.Program_Enrollment__c, opportunity);
        }
        
        //Iterating over inserted or updated hls records.
        for (Home_Language_Survey__c homeLanguageSurvey : homeLanguageSurveys) {
            //Logic to get comma seperated list for HLS_Language_Spoken_By_Adults__c field on hls.
            //Start : Commented that condition in if as Reactivation_Date__c is removed by Ritvik on 01/16/2019.
            //Modified the if condition to check the reactivation check box on the Opportunity related to the PE
            if (homeLanguageSurvey.HLS2_Spoken_To_Child__c == null && !progEnrollOpportunity.get(homeLanguageSurvey.Program_Enrollment__c).Reactivation__c) {
                
                if (homeLanguageSurvey.Language_spoken__c <> null)
                    languageList += homeLanguageSurvey.Language_spoken__c + ',';
                
                if (homeLanguageSurvey.HLS2_Home_Language__c <> null)
                    languageList += homeLanguageSurvey.HLS2_Home_Language__c + ',';
                
                if (homeLanguageSurvey.HLS_Student_At_Home__c <> null)
                    languageList += homeLanguageSurvey.HLS_Student_At_Home__c + ',';
                
                if (homeLanguageSurvey.HLS_Home_Often_Spoken__c <> null)
                    languageList += homeLanguageSurvey.HLS_Home_Often_Spoken__c + ',';
                
                if (homeLanguageSurvey.HLS2_Home_Language_Many__c <> null)
                    languageList += homeLanguageSurvey.HLS2_Home_Language_Many__c + ',';
                
                if (homeLanguageSurvey.HLS2_Home_Language_NE__c <> null && homeLanguageSurvey.HLS2_Home_Language_NE__c <> 'Not Applicable')
                    languageList += homeLanguageSurvey.HLS2_Home_Language_NE__c + ',';
                
                if (homeLanguageSurvey.HLS_Speak_Understand_NE_YN__c == false)
                    languageList += 'English' + ',';
                
                languageList = languageList != '' ? languageList.substring(0, languageList.length() - 1) : '';
                languageList = languageList.replace(';', ',');
                homeLanguageSurvey.HLS_Language_Spoken_By_Adults__c = languageList;
                updateHLSList.add(homeLanguageSurvey);
            } else {
                homeLanguageSurvey.HLS_Language_Spoken_By_Adults__c = homeLanguageSurvey.HLS2_Spoken_To_Child__c;
                updateHLSList.add(homeLanguageSurvey);
            }
        }
        //Check the list size and Update the home language survey records in list.
        if (updateHLSList.size() > 0) {
            try {
                update updateHLSList;
            } catch (Exception ex) {System.debug('Error Message:' + ex);logger.logException('calculateHLSLanguageSpokenByAdults', ex);logger.saveLogs();}
            
        }
        
    }
    
    /**
* Created by Ritvik on 13/12/18.
* Purpose : Populating HS_LTS_Group__c field on program enrollment on after Insert or update of Annual_Student_Information__c record.
* Params : List Annual_Student_Information__c Ids.
*/
    public static void calculateHighSchoolLTSGroup(Set<Id> annualStudentIds) {
        System.debug('In calculateHighSchoolLTSGroup');
        //List to store program enrollment records.
        List<hed__Program_Enrollment__c> programEnrollmentsList = new List<hed__Program_Enrollment__c>();
        //Iterating over Asi inserted or updated.
        for (Annual_Student_Information__c annualStudentInformation : [SELECT School_Year__c,School_Year__r.Start_Date__c,Grade_Level_Requested__c,HS_LTS__c,Program_Enrollment__r.Start_Year__c,Program_Enrollment__c,
                                                                       Program_Enrollment__r.hed__Account__r.School_Year__c, Program_Enrollment__r.Start_Year__r.Start_Date__c,
                                                                       Program_Enrollment__r.hed__Account__r.Registration_Start_Date__c
                                                                       FROM Annual_Student_Information__c WHERE Id IN:annualStudentIds]) {
                                                                           
                                                                           hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(Id = annualStudentInformation.Program_Enrollment__c);
                                                                           //Modified the Below if condition by Ajith for the #77106 Bug
                                                                           // get 4 months prior to the PE's school year start date
                                                                           //Mark Membrino 11/12/2019 Updated the comparison date as part of the gap analysis.  Story 117581
                                                                           //Date fourMonthsBeforeStart =  annualStudentInformation.Program_Enrollment__r.Start_Year__r.Start_Date__c.addMonths(-4);
                                                                           //System.debug('fourMonthsBeforeStart'+fourMonthsBeforeStart);
                                                                           if (Date.today() < annualStudentInformation.Program_Enrollment__r.hed__Account__r.Registration_Start_Date__c) {
                                                                               //System.debug('In Four month');
                                                                               programEnrollment.HS_LTS_Group__c = null;
                                                                           } else if ((annualStudentInformation.Grade_Level_Requested__c == '9' || annualStudentInformation.Grade_Level_Requested__c == '10' ||
                                                                                       annualStudentInformation.Grade_Level_Requested__c == '11' || annualStudentInformation.Grade_Level_Requested__c == '12') &&
                                                                                      annualStudentInformation.Program_Enrollment__r.Start_Year__c == annualStudentInformation.School_Year__c &&
                                                                                      annualStudentInformation.HS_LTS__c != null ) {
                                                                                          
                                                                                          if (Integer.valueOf(annualStudentInformation.HS_LTS__c) <= -10) {
                                                                                              System.debug('In Low HS LTS');
                                                                                              programEnrollment.HS_LTS_Group__c = 'Low HS LTS';
                                                                                          } else if (Integer.valueOf(annualStudentInformation.HS_LTS__c) >= -9 && Integer.valueOf(annualStudentInformation.HS_LTS__c) <= 10) {
                                                                                              System.debug('Medium  HS LTS');
                                                                                              programEnrollment.HS_LTS_Group__c = 'Medium HS LTS';
                                                                                          } else if (Integer.valueOf(annualStudentInformation.HS_LTS__c) >= 11) {
                                                                                              System.debug('High  HS LTS');
                                                                                              programEnrollment.HS_LTS_Group__c = 'High HS LTS';
                                                                                          }else{
                                                                                              programEnrollment.HS_LTS_Group__c = null;
                                                                                          }
                                                                                          
                                                                                      }else if(annualStudentInformation.Program_Enrollment__r.Start_Year__c == annualStudentInformation.School_Year__c && annualStudentInformation.Grade_Level_Requested__c < '9'){
                                                                                          system.debug('GLR: ' + annualStudentInformation.Grade_Level_Requested__c + ' AP School Year: ' + annualStudentInformation.Program_Enrollment__r.hed__Account__r.School_Year__c + ' ASI School Year: ' + annualStudentInformation.School_Year__c + ' ASI.LTS: ' + annualStudentInformation.HS_LTS__c);
                                                                                          //programEnrollment.HS_LTS_Group__c = String.valueOf(annualStudentInformation.HS_LTS__c);
                                                                                          programEnrollment.HS_LTS_Group__c = null;
                                                                                      }
                                                                           else if(annualStudentInformation.Program_Enrollment__r.Start_Year__r.Start_Date__c != null &&
                                                                                   annualStudentInformation.School_Year__r.Start_Date__c == annualStudentInformation.Program_Enrollment__r.Start_Year__r.Start_Date__c.addYears(-1)){
                                                                                       programEnrollment.HS_LTS_Group__c = String.valueOf(annualStudentInformation.HS_LTS__c);
                                                                                   }
                                                                           
                                                                           programEnrollmentsList.add(programEnrollment);
                                                                       }
        //Check the list size and Update the program enrollment in list.
        if (!programEnrollmentsList.isEmpty()) {
            try {
                NES_Constants.runAssignment = false;
                NES_ProgramEnrollmentHandler.runCBL = false;
                update programEnrollmentsList;
            } catch (Exception ex) {
                System.debug('Error Message:' + ex);logger.logException('calculateHighSchoolLTSGroup', ex);logger.saveLogs();throw ex;}
            
        }
    }
    
    
    /**
* Created by Anushka on 14/12/18.
* Purpose : To calculate Income Foster Child on Household Income record.
**/
    
    //MM
    //  HLS2_Home_Language__c
    //  HLS2_School_Communications__c
    //  HLS2_School_Communications_Spoke__c
    //  HLS2_Home_Language_Many__c
    //  HLS2_Other_Adults_Language__c
    
    
    public static void calculateHLSStudentFlag(List<Home_Language_Survey__c> homeLangSurveyList) {
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();
        for (Home_Language_Survey__c hls : homeLangSurveyList) {
            if ((hls.HLS2_ChildLanguage__c != null && hls.HLS2_ChildLanguage__c != 'English')
                || (hls.HLS2_FirstLanguage__c != null && hls.HLS2_FirstLanguage__c != 'English')
                || (hls.HLS2_Spoken_To_Child__c != null && hls.HLS2_Spoken_To_Child__c != 'English')
                || (hls.HLS2_Home_Language__c != null && hls.HLS2_Home_Language__c != 'English')
                || (hls.HLS2_School_Communications__c != null && hls.HLS2_School_Communications__c != 'English')
                || (hls.HLS2_School_Communications_Spoke__c != null && hls.HLS2_School_Communications_Spoke__c != 'English')
                || (hls.HLS2_Home_Language_Many__c != null && hls.HLS2_Home_Language_Many__c != 'English')
                || (hls.HLS2_Other_Adults_Language__c != null && hls.HLS2_Other_Adults_Language__c != 'English')
               )
                //programEnrollments.add(new hed__Program_Enrollment__c(Id = hls.Program_Enrollment__c, HLSStudentFlag__c = True)); 
                //Swapna:ELL Flag issue fix
                programEnrollments.add(new hed__Program_Enrollment__c(Id = hls.Program_Enrollment__c, HLSStudentFlag__c = True, HLS_Date_Completed__c = hls.HLS_Date_Completed__c));  
            else
            {
                //Swapna:ELL Flag issue fix
                //programEnrollments.add(new hed__Program_Enrollment__c(Id = hls.Program_Enrollment__c, HLSStudentFlag__c = False));
                programEnrollments.add(new hed__Program_Enrollment__c(Id = hls.Program_Enrollment__c, HLSStudentFlag__c = False, HLS_Date_Completed__c = hls.HLS_Date_Completed__c));
            }
            system.debug('programEnrollments' + programEnrollments);
        }
        try {
            update programEnrollments;
        } catch (exception e) {logger.logException('calculateHLSStudentFlag', e);logger.saveLogs();}
        system.debug('programEnrollments' + programEnrollments);
    }
    
    /**
* Created by Anushka on 14/12/18.
* Purpose : To calculate Income Foster Child on Household Income record.
**/
    public static void calculateHHIncomeFosterChild(List<Household_Income__c> householdIncomeList) {
        system.debug('in calculateHHIncomeFosterChild');
        system.debug('householdIncomeList');
        List<Id> progEnrollmentIds = new List<Id>();
        List<Id> schoolYearIds = new List<Id>();
        Map<ID, ID> peSchoolYearMap = new Map<ID, ID>();
        Map<String, Annual_Household_Information__c> mapOfAHI = new Map<String, Annual_Household_Information__c>();
        Map<Id, Annual_Household_Information__c> ahiListToUpdate = new Map<Id, Annual_Household_Information__c>();
        List<Annual_Household_Information__c> ahiUpdate = new List<Annual_Household_Information__c>();
        
        for (Household_Income__c income : householdIncomeList) {
            system.debug('adding householdIncomeList PE: ' + income.Program_Enrollment__c + ' and school year: ' + income.School_Year__c);
            progEnrollmentIds.add(income.Program_Enrollment__c);
            schoolYearIds.add(income.School_Year__c);
        }
        
        //Start : Added by Ritvik on 01/15/2019 as part code revamp.
        //if either PE or school year list is empty, do not calculate
        if (progEnrollmentIds.isEmpty() || schoolYearIds.isEmpty()) {
            system.debug('something is empty, returning');
            return;
        }
        
        
        //for each household income, gather PE and 
        List<Annual_Household_Information__c> AHIList = [Select id, Program_Enrollment__c, School_Year__c, HH_Income_Foster_Child__c, Name from Annual_Household_Information__c where Program_Enrollment__c in:progEnrollmentIds AND School_Year__c in :schoolYearIds];
        
        for (Annual_Household_Information__c ahi : AHIList) {
            mapOfAHI.put(ahi.Program_Enrollment__c + '-' + ahi.School_Year__c, ahi);
            system.debug('ahi.pe: ' + ahi.Program_Enrollment__c + ' ahi.sy: ' + ahi.School_Year__c + ' ahi: ' + ahi + ' ahi name:  ' + ahi.Name);
        }
        
        system.debug('checking householdIncomeList');
        for (Household_Income__c income : householdIncomeList) {
            String key = income.Program_Enrollment__c + '-' + income.School_Year__c;
            if (mapOfAHI.get(key) != null) {
                system.debug('updating fosterchild');
                if (income.HHFosterChild__c == 'Yes') {
                    mapOfAHI.get(key).HH_Income_Foster_Child__c = True;
                } else {
                    mapOfAHI.get(key).HH_Income_Foster_Child__c = False;
                }
                ahiListToUpdate.put(mapOfAHI.get(key).Id, mapOfAHI.get(key));
            }
            
        }
        
        //Start : If condition added by Ritvik on 01/15/2019.
        if (!ahiListToUpdate.isEmpty()) {
            try {
                List<Annual_Household_Information__c> ahis = ahiListToUpdate.values();
                update ahis;
            } catch (exception e) {logger.logException('calculateHHIncomeFosterChild', e);logger.saveLogs();}
        }
        
        //End
    }
    
    /*
*   Created By: Ashish Sharma
*   Created Date: 12/14/2018
*   Parameters: List<sObject>
*   Return Type: void
*   Purpose: Method to calculate Entrance Age Eligiblity
*/
    public static void calculateEntranceAgeEligibility(List<sObject> records) {
        NES_EntranceAgeUtility.calculateEntranceAgeEligibility(records);
    }
    
    /**
* Created by Ritvik on 12/14/18.
* Purpose : Populating HS_LTS__c field on ASI on after Insert or update of Annual Student Information & Program enrollment record.
* Params : List Annual_Student_Information__c Ids.
*/
    public static void calculateHighSchoolLTS(Set<Id> programEnrollId) {
        system.debug('In calculateHighSchoolLTS' + programEnrollId);
        
        //Map in which id as program enrollment id & values as program enrollment records.
        Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>();
        
        //Map in which id as program enrollment & value as current ASI record.
        Map<Id, Annual_Student_Information__c> progEnrollCurrentAsiMap = new Map<Id, Annual_Student_Information__c>();
        
        //Map in which id as account id associated to program enrollment & values as list of program enrollment record related to it.
        Map<Id, List<hed__Program_Enrollment__c>> programEnrollmentAccountId = new Map<Id, List<hed__Program_Enrollment__c>>();
        
        //Map in which id as acoount id & value as account record.
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        //Map in which id as ASI date & value as ASI record associated to it.
        Map<Date, Annual_Student_Information__c> PreviousAsi = new Map<Date, Annual_Student_Information__c>();
        
        //Querying program enrollment.
        for (hed__Program_Enrollment__c programEnrollment : [
            SELECT LTS__c,hed__Contact__c,DisciplinaryPastActions__c, Start_Year__r.Start_Date__c,
            Academic_Doc_Performance__c, Post_High_School_Plans_2__c,
            First_Yr_Complete_HS_Coursework__c,SIFStudentRetained__c,hed__Account__c, (
                SELECT CreatedDate,StageName
                FROM Opportunities__r
                WHERE StageName = 'Open' OR StageName = 'Closed Won'
            )
            FROM hed__Program_Enrollment__c
            WHERE Id IN :programEnrollId
        ]) {
            programEnrollmentMap.put(programEnrollment.Id, programEnrollment);
            
            if (programEnrollmentAccountId.containsKey(programEnrollment.hed__Account__c)) {
                programEnrollmentAccountId.get(programEnrollment.hed__Account__c).add(programEnrollment);
            } else {
                programEnrollmentAccountId.put(programEnrollment.hed__Account__c, new List<hed__Program_Enrollment__c>{
                    programEnrollment
                        });
            }
        }
        
        //Querying Account.
        for (Account account : [SELECT Id,FirstDayforStudents__c, Student_Last_Day__c FROM Account WHERE Id IN :programEnrollmentAccountId.keySet()]) {
            accountMap.put(account.Id, account);
        }
        
        //Querying ASI.
        //Modified the below query by ajith and code in the if block as part of reducing queries
        for (Annual_Student_Information__c asiRecord : [
            SELECT Id, Program_Enrollment__c, Grade_Level_Requested__c, School_Year__c, School_Year__r.Start_Date__c,
            Program_Enrollment__r.Start_Year__r.Start_Date__c, HS_LTS__c, School_Year__r.Current_Year__c
            FROM Annual_Student_Information__c
            WHERE Program_Enrollment__c IN :programEnrollId
        ]) {
            
            if(asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c != null){
                if (asiRecord.School_Year__r.Start_Date__c == asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c.addYears(-1)) {
                    PreviousAsi.put(asiRecord.School_Year__r.Start_Date__c, asiRecord);
                }
            }
            if(asiRecord.School_Year__r.Current_Year__c){
                progEnrollCurrentAsiMap.put(asiRecord.Program_Enrollment__c, asiRecord);
            }
        }
        
        //List of the ASI to update
        List<Annual_Student_Information__c> asiListToUpdate = new List<Annual_Student_Information__c>();
        
        //Iterating over program enrollment.
        //Modified by Ajith as part of reducing queries
        for (hed__Program_Enrollment__c programEnrollment : programEnrollmentMap.values()) {
            
            //Logic for program enrollment LTS__c field.
            System.debug('programEnrollment.Opportunities__r:' + programEnrollment.Opportunities__r);
            
            //check whether there is an Current Year ASI record for the Program Enrollment
            if (progEnrollCurrentAsiMap.get(programEnrollment.Id) != null) {
                System.debug('progEnrollCurrentAsiMap+++++' + progEnrollCurrentAsiMap.get(programEnrollment.Id));
                Annual_Student_Information__c currentASIRecord = progEnrollCurrentAsiMap.get(programEnrollment.Id);
                
                if (programEnrollment.Opportunities__r.size() == 0 || ( progEnrollCurrentAsiMap.containsKey(programEnrollment.Id) &&
                                                                       (progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '8' ||
                                                                       progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '7' || progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '6' ||
                                                                       progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '5' || progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '4' ||
                                                                       progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '3' || progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '2' ||
                                                                        progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '1' || progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == 'K'))) {
                                                                           currentASIRecord.HS_LTS__c = null;
                                                                           asiListToUpdate.add(currentASIRecord);
                                                                           System.debug('First If');
                                                                       } else {
                                                                           System.debug('First Else ++' + programEnrollment.LTS__c);
                                                                           //Commenting this line and setting it to zero every time the logic is fired according to the Bug #77940
                                                                           //currentASIRecord.HS_LTS__c = currentASIRecord.HS_LTS__c == null ? 0 : currentASIRecord.HS_LTS__c;
                                                                           currentASIRecord.HS_LTS__c = 0;
                                                                           if (programEnrollment.LTS__c >= -8 && programEnrollment.LTS__c <= 0) {
                                                                               currentASIRecord.HS_LTS__c += -10;
                                                                           } else if (programEnrollment.LTS__c <= 6) {
                                                                               currentASIRecord.HS_LTS__c += -7;
                                                                           } else if (programEnrollment.LTS__c <= 8) {
                                                                               currentASIRecord.HS_LTS__c += -2;
                                                                           } else if (programEnrollment.LTS__c == 9) {
                                                                               currentASIRecord.HS_LTS__c += 0;
                                                                           } else if (programEnrollment.LTS__c == 10) {
                                                                               currentASIRecord.HS_LTS__c += 1;
                                                                           } else if (programEnrollment.LTS__c <= 12) {
                                                                               currentASIRecord.HS_LTS__c += 5;
                                                                           } else if (programEnrollment.LTS__c == 13) {
                                                                               currentASIRecord.HS_LTS__c += 7;
                                                                           } else if (programEnrollment.LTS__c == 14) {
                                                                               currentASIRecord.HS_LTS__c += 10;
                                                                           } else if (programEnrollment.LTS__c == 15) {
                                                                               currentASIRecord.HS_LTS__c += 11;
                                                                           } else if (programEnrollment.LTS__c == 16) {
                                                                               currentASIRecord.HS_LTS__c += 12;
                                                                           } else if (programEnrollment.LTS__c == 17) {
                                                                               currentASIRecord.HS_LTS__c += 13;
                                                                           } else if (programEnrollment.LTS__c == 18) {
                                                                               currentASIRecord.HS_LTS__c += 14;
                                                                           } else if (programEnrollment.LTS__c == 19) {
                                                                               currentASIRecord.HS_LTS__c += 15;
                                                                           } else if (programEnrollment.LTS__c == 20) {
                                                                               currentASIRecord.HS_LTS__c += 16;
                                                                           } else if (programEnrollment.LTS__c == 22) {
                                                                               currentASIRecord.HS_LTS__c += 17;
                                                                           } else if (programEnrollment.LTS__c == 23) {
                                                                               currentASIRecord.HS_LTS__c += 18;
                                                                           }
                                                                           
                                                                           if (programEnrollment.DisciplinaryPastActions__c == 'No') {
                                                                               currentASIRecord.HS_LTS__c += 1;
                                                                           } else if (isMatch(programEnrollment.DisciplinaryPastActions__c, 'Yes', false)) {
                                                                               currentASIRecord.HS_LTS__c += -4;
                                                                           }
                                                                           
                                                                           if (programEnrollment.Academic_Doc_Performance__c == 'Yes') {
                                                                               currentASIRecord.HS_LTS__c += 1;
                                                                           } else if (programEnrollment.Academic_Doc_Performance__c == 'No') {
                                                                               currentASIRecord.HS_LTS__c += -4;
                                                                           }
                                                                           
                                                                           if (programEnrollment.Post_High_School_Plans_2__c == 'To enroll in a trade or vocational school' || programEnrollment.Post_High_School_Plans_2__c == 'Undecided') {
                                                                               System.debug('In If -3'+currentASIRecord.HS_LTS__c);
                                                                               currentASIRecord.HS_LTS__c += -3;
                                                                               System.debug('currentASIRecord.HS_LTS__c'+currentASIRecord.HS_LTS__c);
                                                                           } else if (programEnrollment.Post_High_School_Plans_2__c == 'To enroll in a two-year or community college') {
                                                                               currentASIRecord.HS_LTS__c += -1;
                                                                           } else if (programEnrollment.Post_High_School_Plans_2__c == 'To enter the military') {
                                                                               currentASIRecord.HS_LTS__c += -5;
                                                                           } else if (programEnrollment.Post_High_School_Plans_2__c == 'To enter the workforce') {
                                                                               currentASIRecord.HS_LTS__c += -4;
                                                                           } else if (programEnrollment.Post_High_School_Plans_2__c == 'To enroll in a four-year college or university') {
                                                                               currentASIRecord.HS_LTS__c += 3;
                                                                           }
                                                                           
                                                                           /*System.debug('accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c>>>'+accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c);
System.debug('programEnrollment.Opportunities__r.get(0).CreatedDate>>>'+programEnrollment.Opportunities__r.get(0).CreatedDate);*/
                                                                           if (
                                                                               (programEnrollment.Opportunities__r.size() != 0 && accountMap.size() != 0) &&
                                                                               (
                                                                                   (accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c != null && programEnrollment.Opportunities__r.get(0).CreatedDate.date().daysBetween(accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c) > 30) ||
                                                                                   programEnrollment.Opportunities__r.get(0).CreatedDate < accountMap.get(programEnrollment.hed__Account__c).Student_Last_Day__c
                                                                               )
                                                                           ) {
                                                                               currentASIRecord.HS_LTS__c += 2;
                                                                           } else if ((programEnrollment.Opportunities__r.size() != 0 && accountMap.size() != 0) && accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c != null && programEnrollment.Opportunities__r.get(0).CreatedDate.date().daysBetween(accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c) > 14) {
                                                                               currentASIRecord.HS_LTS__c += 1;
                                                                           } else if ((programEnrollment.Opportunities__r.size() != 0 && accountMap.size() != 0) && accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c != null && programEnrollment.Opportunities__r.get(0).CreatedDate.date().daysBetween(accountMap.get(programEnrollment.hed__Account__c).FirstDayforStudents__c) <= 6) {
                                                                               currentASIRecord.HS_LTS__c += -2;
                                                                           }
                                                                           
                                                                           if (progEnrollCurrentAsiMap.size() != 0 && PreviousAsi.size() != 0) {
                                                                               if ((
                                                                               progEnrollCurrentAsiMap.containsKey(programEnrollment.Id) &&
                                                                               (programEnrollment.Start_Year__c != null) && 
                                                                               (programEnrollment.Start_Year__r.Start_Date__c != null) &&
                                                                               PreviousAsi.containsKey(programEnrollment.Start_Year__r.Start_Date__c.addYears(-1)) &&        
                                                                               isMatch(progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c, PreviousAsi.get(programEnrollment.Start_Year__r.Start_Date__c.addYears(-1)).Grade_Level_Requested__c, true)) ||
                                                                                   (progEnrollCurrentAsiMap.get(programEnrollment.Id).Grade_Level_Requested__c == '9' && programEnrollment.First_Yr_Complete_HS_Coursework__c == 'No')) {
                                                                                       currentASIRecord.HS_LTS__c += -6;
                                                                                   }
                                                                           }
                                                                           
                                                                           if (programEnrollment.SIFStudentRetained__c == 'Yes') {
                                                                               currentASIRecord.HS_LTS__c += -6;
                                                                           } else if (programEnrollment.SIFStudentRetained__c == 'No') {
                                                                               currentASIRecord.HS_LTS__c += 1;
                                                                           }
                                                                           asiListToUpdate.add(currentASIRecord);
                                                                       }
            }
        }
        
        //Check the list size and Update the ASI in list.
        if (!asiListToUpdate.isEmpty()) {
            try {
                update asiListToUpdate;
            } catch (exception e) {System.debug('Expection Thrown' + e.getMessage());logger.logException('calculateHighSchoolLTS', e);logger.saveLogs();}
        }
    }
    
    /***************
* Created by Raymond 2/5/19
* purpose: to determine whether a newly opened opportunity is a reactivation or not
* input: List<Opportunities> opps -- list of opportunities changed in trigger call
**************/
    public static void calculateReactivationDate(List<Opportunity> opps) {
        system.debug('in reactivation');
        
        system.debug('opps: ' + opps);
        
        Map<ID, Opportunity> peOpps = new Map<Id, Opportunity>();
        Map<ID, List<Opportunity>> peOppClosedWon = new Map<ID, List<Opportunity>>();
        Map<ID, List<Opportunity>> peOppNOTClosedWon = new Map<ID, List<Opportunity>>();
        List<ID> peList = new List<ID>();
        List<Opportunity> toUpdate = new List<Opportunity>();
        
        for (Opportunity current : [SELECT Program_Enrollment__c, Reactivation__c FROM Opportunity WHERE ID IN :opps]) {
            system.debug('checking for PEs');
            if (current.Program_Enrollment__c != null) {
                system.debug('adding effected pe: ' + current.Program_Enrollment__c);
                //add program enrollments to list so we can gather all opps related to PEs effected
                peList.add(current.Program_Enrollment__c);
                //add opp to map based on program enrollment so we can edit the reactivation date later
                peOpps.put(current.Program_Enrollment__c, current);
            }
        }
        
        //populate map of PEs effected and their opportunities associated that ARE NOT the triggering opps
        for (Opportunity current : [SELECT Name, Program_Enrollment__c, StageName FROM Opportunity WHERE Program_Enrollment__c IN :peList AND ID NOT IN :opps]) {
            List<Opportunity> temp = new List<Opportunity>();
            system.debug('checking opportunity: ' + current.name + '(' + current.id + ')' + ' for pe: ' + current.Program_Enrollment__c);
            if (current.StageName == 'Closed Won') {
                if (peOppClosedWon.containskey(current.Program_Enrollment__c))
                    temp = peOppClosedWon.get(current.Program_Enrollment__c);
                temp.add(current);
                peOppClosedWon.put(current.Program_Enrollment__c, temp);
            } else {
                if (peOppNOTClosedWon.containskey(current.Program_Enrollment__c))
                    temp = peOppNOTClosedWon.get(current.Program_Enrollment__c);
                temp.add(current);
                peOppNOTClosedWon.put(current.Program_Enrollment__c, temp);
            }
        }
        
        //for each of the effected PEs, check if there are any opps associated, then that none of those opps are closed won, then update reactivation if both are true
        for (ID current : peList) {
            if (peOppNotClosedWon.containskey(current)) {
                //do not update if there is an opportunity associated with PE that is closed won
                if (!peOppClosedWon.containskey(current)) {
                    //update reactivation, add to list to update
                    Opportunity reactivatedOpp = peOpps.get(current);
                    if (reactivatedOpp != null) {
                        reactivatedOpp.Reactivation__c = true;
                        toUpdate.add(reactivatedOpp);
                    }
                } else
                    system.debug('not updating, closed won opportunity exists');
            }
        }
        
        //update changed opportunities
        if (!toUpdate.isEmpty()) {
            try {
                system.debug('list to reactivate: ' + toUpdate);
                update toUpdate;
            } catch (exception e) {System.debug('Dml exception' + e.getMessage());logger.logException('calculateReactivationDate', e);logger.saveLogs();}
        }
    }
    
    /**
* Created By Raju 12/15/2018
* purpose : This method used to Calucalute Federal Poverty Eligibilty On Annual Household Information Object
* Parameters :Set<Id> peIdSet,List<Annual_Household_Information__c> ahiList
*/
    public static void calculateFederalPovertyEligibility(Set<Id> peIdSet, List<Annual_Household_Information__c> ahiList) {
        system.debug('in calculateFederalPovertyEligibility');
        Map<Id, hed__Program_Enrollment__c> peMap = new Map<Id, hed__Program_Enrollment__c>();
        
        //Map<Id, Account> accMap = new Map<Id, Account>(); //Added by Jagadeesh
        //Map<id,id> pEntoAHH = new Map<id,id>();//Added by Jagadeesh
        set<id > accset = new set<id>();
        for (hed__Program_Enrollment__c hpe : [SELECT Id,Start_year__c,Start_Year__r.id, 
                                               hed__Account__c, 
                                               hed__Account__r.School_Year__c 
                                               FROM hed__Program_Enrollment__c WHERE Id IN:peIdSet]) {
                                                   peMap.put(hpe.Id, hpe);   
                                                   //  pEntoAHH.put(hpe.id , hpe.hed__Account__c);//Added by Jagadeesh
                                                   //accset.add(hpe.hed__Account__c); //added by jagadeesh
                                               }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //Added by Jagadeesh
        /*for(Account acc : [SELECT 
Id,
name,
Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c,
Fed_Poverty_Elig_Inc_Addl_Per_Person__c,
FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c,
FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c,
FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c,
FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c FROM Account WHERE Id IN: accset]){
accMap.put(acc.Id, acc);//Added by Jagadeesh

}

system.debug('pEntoAHH: ' +pEntoAHH);//Added by Jagadeesh  */
        
        System.debug('peMap++++' + peMap);
        //check the value of school year on annual house hold information will be match with start year of it's program enrollment.
        List<Annual_Household_Information__c> ahiListFilteredFromPE = new List<Annual_Household_Information__c>();
        
        
        for (Annual_Household_Information__c ahi : ahiList) {
            if (peMap != null && peMap.containsKey(ahi.Program_Enrollment__c)) {
                hed__Program_Enrollment__c peRecord = peMap.get(ahi.Program_Enrollment__c);
                if (peRecord.hed__Account__r.School_Year__c == ahi.School_Year__c) {
                    ahiListFilteredFromPE.add(ahi);
                }
                
            }
            
        }
        
        System.debug('ahiListFilteredFromPE++++' + ahiListFilteredFromPE);
        
        Map<Id, List<Household_Income__c>> peIdToHIRecordsMap = new Map<Id, List<Household_Income__c>>();
        
        for (Household_Income__c hiRecord : [
            SELECT Id,HHFosterChild__c,
            Program_Enrollment__c,
            School_Year__c
            FROM Household_Income__c
            WHERE Program_Enrollment__c IN:peIdSet
        ]) {
            if (!peIdToHIRecordsMap.containsKey(hiRecord.Program_Enrollment__c)) {
                peIdToHIRecordsMap.put(hiRecord.Program_Enrollment__c, new List<Household_Income__c>());
            }
            
            List<Household_Income__c> hiList = peIdToHIRecordsMap.get(hiRecord.Program_Enrollment__c);
            hiList.add(hiRecord);
            peIdToHIRecordsMap.put(hiRecord.Program_Enrollment__c, hiList);
            
        }
        
        System.debug('-------------->im here');
        //MM This will change for story 1175580
        if (ahiListFilteredFromPE.size() > 0) {
            System.debug('IN ahiListFilteredFromPE');
            List<Annual_Household_Information__c> ahiFinalUpdateList = new List<Annual_Household_Information__c>();
            for (Annual_Household_Information__c annualHHInfoRecord : ahiListFilteredFromPE) {
                //Added by Jagadeesh - - User story : 117580
                Decimal FedEligIncFreeMlsHHSize1 = annualHHInfoRecord.Program_Enrollment__r.hed__Account__r.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c;//accMap.get(pEntoAHH.get(annualHHInfoRecord.Program_Enrollment__c)).Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c
                Decimal FedPvrtEligIncAddlPerPrsn = annualHHInfoRecord.Program_Enrollment__r.hed__Account__r.Fed_Poverty_Elig_Inc_Addl_Per_Person__c; //accMap.get(pEntoAHH.get(annualHHInfoRecord.Program_Enrollment__c)).Fed_Poverty_Elig_Inc_Addl_Per_Person__c;
                //Decimal FedEligIncRedMlsPerPrsn = accMap.get(pEntoAHH.get(annualHHInfoRecord.Program_Enrollment__c)).FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c;
                
                // system.debug('FedPvrtEligIncAddlPrsn: ' +FedPvrtEligIncAddlPrsn);//Added by Jagadeesh
                if (peIdToHIRecordsMap != null && annualHHInfoRecord != null) {
                    String validateHHFARMEligCalculated = HHFarmEligCalculated(peIdToHIRecordsMap, annualHHInfoRecord);
                    System.debug('validateHHFARMEligCalculated+++'+validateHHFARMEligCalculated);
                    if (validateHHFARMEligCalculated != null){ // added for bug 122880
                        annualHHInfoRecord.Household_FARM_Eligibility__c = validateHHFARMEligCalculated;
                    }
                    
                    //Added By Guru for US# 334259

                    if (annualHHInfoRecord.Total_Gross_HH_Income__c == null ||
                        annualHHInfoRecord.Total_Gross_HH_Income__c == 0 ||
                        annualHHInfoRecord.Number_HH_Children__c == null ||
                         annualHHInfoRecord.Number_HH_Adults__c == null) {

                             annualHHInfoRecord.Federal_Poverty_Eligibility__c = 'Not enough information';

                         } else if (validateHHFARMEligCalculated != null && validateHHFARMEligCalculated.contains('Qualifies') && Integer.valueof(FedEligIncFreeMlsHHSize1)>0 && Integer.valueof(FedPvrtEligIncAddlPerPrsn)>0 &&
                                    (annualHHInfoRecord.Total_Gross_HH_Income__c <= (FedEligIncFreeMlsHHSize1 + (annualHHInfoRecord.Number_HH_Children__c + annualHHInfoRecord.Number_HH_Adults__c - 1) *FedPvrtEligIncAddlPerPrsn))) {
                                        /* else if (validateHHFARMEligCalculated.contains('Qualifies') &&
(annualHHInfoRecord.Total_Gross_HH_Income__c <= (12140 + (annualHHInfoRecord.Number_HH_Children__c + annualHHInfoRecord.Number_HH_Adults__c - 1) * 4320))){*/
                                        
                                        annualHHInfoRecord.Federal_Poverty_Eligibility__c = 'Qualifies at Federal Poverty Level';
                                    } else {
                                        annualHHInfoRecord.Federal_Poverty_Eligibility__c = 'Does not qualify at Federal Poverty Level';
                                    }
                    system.debug('updating AHI record: ' + annualHHInfoRecord.id + ' poverty eligibility: ' + annualHHInfoRecord.Federal_Poverty_Eligibility__c);
                    ahiFinalUpdateList.add(annualHHInfoRecord);
                }
            }
            
            if (ahiFinalUpdateList.size() > 0) {
                try {
                    update ahiFinalUpdateList;
                } catch (Exception ex) {system.debug('Error:: ' + ex.getMessage());logger.logException('calculateFederalPovertyEligibility', ex);logger.saveLogs();}
            }
        }
    }
    
    /**
* Created By Raju 12/15/2018
* purpose : This method is used to Calucalute Federal Poverty Eligibilty On Annual Household Information Object
* Parameters :Map<Id,List<Household_Income__c>> peIdToHIRecordsMap,Annual_Household_Information__c ahiRecord
* Return type : String.
*/
    public static String HHFarmEligCalculated(Map<Id, List<Household_Income__c>> peIdToHIRecordsMap, Annual_Household_Information__c ahiRecord) {
        String returnString;
        if (ahiRecord != null && ahiRecord.Program_Enrollment__c != null) {
            Boolean isHHFosterChild = false;
            if (peIdToHIRecordsMap != null && peIdToHIRecordsMap.containsKey(ahiRecord.Program_Enrollment__c)) {
                for (Household_Income__c hiRecord : peIdToHIRecordsMap.get(ahiRecord.Program_Enrollment__c)) {
                    if (hiRecord.HHFosterChild__c == 'Yes') {
                        isHHFosterChild = true;
                        break;
                    }
                }
            }
            //FedEligIncFreeMlsHHSize1
            
            if (ahiRecord.HH_Has_Food_Stamp_Recipient__c == 'Yes' || ahiRecord.HH_Has_Foster_Children__c == 'Yes' || isHHFosterChild == true) {
                returnString = 'Qualifies for free';
            } else if (ahiRecord.Income_Opt_Out_Options__c == system.label.NES_AHI_Income_Opt_Out) {
                returnString = 'Family Reported-Does not qualify';
            } else if (ahiRecord.Income_Opt_Out_Options__c == system.label.NES_AHI_IncomeOptOut_Value) {
                returnString = 'Refused to report';
            } else if (ahiRecord.Income_Opt_Out_Options__c == system.label.NES_AHI_Income_Opt) {
                Integer totalGrossHHIncome = ahiRecord.Total_Gross_HH_Income__c != null ? Integer.valueOf(ahiRecord.Total_Gross_HH_Income__c) : 0;
                Integer numberHHChildren = ahiRecord.Number_HH_Children__c != null ? Integer.valueOf(ahiRecord.Number_HH_Children__c) : 0;
                Integer numberHHAdults = ahiRecord.Number_HH_Adults__c != null ? Integer.valueOf(ahiRecord.Number_HH_Adults__c) : 0;
                System.debug('Value::' + 15782 + ((numberHHChildren + numberHHAdults) - 1) * 5616);
                //if (totalGrossHHIncome <= (15782 + ((numberHHChildren + numberHHAdults) - 1) * 5616)) {
                //    returnString = 'Qualifies for free';
                //} else if (totalGrossHHIncome <= (22459 + ((numberHHChildren + numberHHAdults) - 1) * 7992)) {
                //    returnString = 'Qualifies for reduced';
                if(Integer.valueOf(ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c) > 0 && Integer.valueOf(ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c)> 0 ){
                    if (totalGrossHHIncome <= (ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c + ((numberHHChildren + numberHHAdults) - 1) * ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c)){  //Added by Jagadeesh - User story : 117580
                        returnString = 'Qualifies for free';
                    } else if (totalGrossHHIncome <= (ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c + ((numberHHChildren + numberHHAdults) - 1) * ahiRecord.Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c)) {   //Added by Jagadeesh - User story : 117580
                        returnString = 'Qualifies for reduced';
                    } else {
                        returnString = 'Applied-Does not qualify';
                    }
                }
                else {
                returnString = 'Family Income Form Incomplete';
            }
        }
        }
        return returnString;
    }
    /**
* Created By Anand on 12/17/18
*Purpose : To Update HouseHold EnrollmentDate on ProgramEnrollments
* @param optyList
*/
    
    public static void calculateHouseholdEnrollmentDate(List<Opportunity> optyList) {
        system.debug('checking enrollment date');
        Set<Id> programEnrollmentIds = new Set<Id>();
        Map<Id, Hed__Program_Enrollment__c> progEnrollmentsMapCT = new Map<Id, Hed__Program_Enrollment__c>();
        List<Id> careTakerIds = new List<Id>();
        Set<Id> progEnrollmentIds = new Set<Id>();
        Map<ID, ID> caretakerStudentPEMap = new Map<id, id>();
        Map<ID, Set<hed__Program_Enrollment__c>> caretakerPEs = new Map<id, Set<hed__Program_Enrollment__c>>();
        Set<Hed__Program_Enrollment__c> progEnrollmentsToUpdate = new Set<Hed__Program_Enrollment__c>();
        Set<hed__Program_Enrollment__c> ctEnrollments = new Set<hed__Program_Enrollment__c>();
        
        for (Opportunity opty : optyList) {
            //track student program enrollments that are affected by change
            programEnrollmentIds.add(opty.Program_Enrollment__c);
            
            //track caretaker ids to later map to caretaker program enrollments
            careTakerIds.add(opty.Caretaker_Id__c);
            caretakerPEs.Put(opty.Caretaker_Id__c, new set<Hed__Program_Enrollment__c>());
        }
        // populate Enrollment Date Map with caretaker programEnrollment Id and HouseholdEnrollmentDate__c of the caretaker's program enrollment
        for (Hed__Program_Enrollment__c progEn : [
            SELECT ID,HouseholdEnrollmentDate__c, hed__Account__c, hed__Contact__c
            FROM Hed__Program_Enrollment__c
            WHERE hed__Contact__c IN :careTakerIds
        ]) {
            //save program enrollment object that belong to a caretkaer affected by change
            progEnrollmentsMapCT.Put(progEn.Id, progEn);
            
            //get any program enrollments related to the current caretaker
            ctEnrollments = caretakerPEs.get(progEn.hed__Contact__c);
            //add new program enrollment to the caretakers list
            ctEnrollments.add(progEn);
            caretakerPEs.Put(progEn.hed__Contact__c, ctEnrollments);
        }
        
        // Fetch the related students programEnrollments and their corresponding latest Enrollment
        for (hed__Program_Enrollment__c progEnrollment : [
            Select Id,HouseholdEnrollmentDate__c, hed__Account__c,hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.Account.hed__Primary_Contact__c, hed__Contact__r.Account.hed__Primary_Contact__r.Name, hed__Contact__r.AccountId, (Select Id,Enrollment_Date__c,Program_Enrollment__c FROM Enrollments__r ORDER BY CreatedDate Desc LIMIT 1)
            FROM hed__Program_Enrollment__c
            Where ID IN :getStudentsWithProgramEnrollments(careTakerIds)
        ]) {
            System.debug('progEnrollment++++' + progEnrollment);
            //Make sure there are enrollments for the related students, and program enrollments for the caretaker
            if (progEnrollment.Enrollments__r <> Null && progEnrollment.Enrollments__r.size() > 0 && caretakerPEs.containsKey(progEnrollment.hed__Contact__r.Account.hed__Primary_Contact__c)) {
                System.debug('Has An Enrollment Record+++' + progEnrollment.Enrollments__r);
                //find the correct caretaker program enrollment
                for (hed__Program_Enrollment__c currentCTPE : caretakerPEs.get(progEnrollment.hed__Contact__r.Account.hed__Primary_Contact__c)) {
                    system.debug('checking caretaker pe: ' + currentCTPE);
                    //student and caretaker PE match Academic programs
                    if (progEnrollment.hed__Account__c == currentCTPE.hed__Account__c) {
                        //if the latest enrollment date is less than the last saved enrollment date on the CT PE, overwrite
                        if (currentCTPE.HouseholdEnrollmentDate__c == null || (currentCTPE.HouseholdEnrollmentDate__c != null && progEnrollment.Enrollments__r[0].Enrollment_Date__c < currentCTPE.HouseholdEnrollmentDate__c)) {
                            system.debug('updating enrollment date');
                            currentCTPE.HouseholdEnrollmentDate__c = progEnrollment.Enrollments__r[0].Enrollment_Date__c;
                            progEnrollmentsToUpdate.add(currentCTPE);
                        } else
                            system.debug('null or not earliest date ST: ' + progEnrollment.Enrollments__r[0].Enrollment_Date__c + ' CT : ' + currentCTPE.HouseholdEnrollmentDate__c);
                    } else
                        system.debug('accounts not equal, st: ' + progEnrollment.id + '(' + progEnrollment.hed__Account__c + ')' + ' ct: ' + currentCTPE.id + '(' + currentCTPE.hed__Account__c + ')');
                }
            }
            system.debug('did not update. account: ' + progEnrollment.hed__Contact__r.AccountId + ' primary contact: ' + progEnrollment.hed__Contact__r.Account.hed__Primary_Contact__c + '(' + progEnrollment.hed__Contact__r.Account.hed__Primary_Contact__r.Name + ')' + ' student: ' + progEnrollment.hed__Contact__c + '(' + progEnrollment.hed__Contact__r.Name + ')');
            
        }
        if (!progEnrollmentsToUpdate.isEmpty()) {
            try {
                system.debug('to add: ' + progEnrollmentsToUpdate);
                update new List<Hed__Program_Enrollment__c>(progEnrollmentsToUpdate);
            } catch (exception e) {System.debug('Exception ==>>' + e.getMessage());logger.logException('calculateHouseholdEnrollmentDate', e);logger.saveLogs();}
        }
    }
    /**
* Create By Anand 12/17/2018

*Purpose: Util Method Which return PorgramEnrollmentIds of Students related to caretaker
* @param careTakerIds
*
* @return
*/
    public static List<Id> getStudentsWithProgramEnrollments(List<Id> careTakerIds) {
        List<Id> progEnrollmentIds = new List<Id>();
        if (!careTakerIds.isEmpty()) {
            //Retrieve the related student Ids of the careTakerContactId
            Set<Id> studentIds = new Set<Id>();
            Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();
            
            for (hed__Relationship__c con : [
                SELECT hed__RelatedContact__c
                FROM hed__Relationship__c
                WHERE hed__Contact__c IN :careTakerIds
                AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
            ]) {
                studentIds.add(con.hed__RelatedContact__c);
            }
            
            
            if (studentIds.size() > 0) {
                /*
Retrieve all program enrollments related to the students and then get all PROCESS_RT
type Enrollment components and related ECAs. Return this information after adding
in List<NES_DashboardUtilities.StudentInformation>
*/
                List<NES_DashboardUtilities.StudentInformation> students = new List<NES_DashboardUtilities.StudentInformation>();
                
                for (hed__Program_Enrollment__c progEnrollment : [
                    SELECT Id, hed__Contact__c, hed__Contact__r.Name
                    FROM hed__Program_Enrollment__c
                    WHERE hed__Contact__c IN:studentIds
                ]) {
                    
                    progEnrollmentIds.add(progEnrollment.Id);
                }
            }
        }
        return progEnrollmentIds;
    }
    
    /**
* Created By Ajith on 19-12-2018.
* purpose : This method is for TotalGrossHHIncome calculation of the House Hold Income records
* Params : List of HouseholdIncome records
*/
    public static void calculateTotalGrossHHIncome(List<Household_Income__c> householdIncomesList) {
        System.debug('Method Entry Cal+++' + householdIncomesList);
        //Build a map of Program Enrollment Id to list of House Hold Income Records
        Map<Id, List<Household_Income__c>> programEnrollmentToHIMap = new Map<Id, List<Household_Income__c>>();
        
        Set<Id> idsOfHouseholdIncomesWeAlreadyHave = new Set<Id>();
        
        for (Household_Income__c hIncome : householdIncomesList) {
            
            idsOfHouseholdIncomesWeAlreadyHave.add(hIncome.Id);
            
            if (programEnrollmentToHIMap.containsKey(hIncome.Program_Enrollment__c)) {
                programEnrollmentToHIMap.get(hIncome.Program_Enrollment__c).add(hIncome);
            } else {
                programEnrollmentToHIMap.put(hIncome.Program_Enrollment__c, new List<Household_Income__c>{
                    hIncome
                        });
            }
        }
        
        List<Household_Income__c>allHouseholdIncomesForPE = [SELECT
                                                             Id, Adult_Income_Received_1__c, Adult_Income_Received_2__c, Adult_Income_Received_3__c,
                                                             Adult_Income_Rec_Other__c, HHAdultIncomeRecSup__c, Adult_Income_Sup__c, HHAdultIncomeRecWork__c,
                                                             HHAdultIncomeWork__c, HHChildIncomeReceived__c, HHChildIncome__c, Program_Enrollment__c, School_Year__c,
                                                             HHAdultIncome_1__c, HHAdultIncome_2__c, HHAdultIncome_3__c, Adult_Income_Other__c
                                                             FROM Household_Income__c
                                                             WHERE Program_Enrollment__c =: householdIncomesList.get(0).Program_Enrollment__c AND Id NOT IN :idsOfHouseholdIncomesWeAlreadyHave];
        
        //Grab all household incomes for calculation to make sure we have them all
        
        allHouseholdIncomesForPE.addAll(householdIncomesList);
        
        System.debug('programEnrollmentToHIMap++' + programEnrollmentToHIMap);
        List<Id> matchingProgramEnrollmentIds = new List<Id>();
        Set<Annual_Household_Information__c> ahiListToUpsert = new Set<Annual_Household_Information__c>();
        
        //Query for thr AHI records matching the Program Enrollment and School Year on the House Income records passed in
        for (Annual_Household_Information__c ahiInfo : [
            SELECT Id, Program_Enrollment__c, School_Year__c, Total_Gross_HH_Income__c
            FROM Annual_Household_Information__c
            WHERE Program_Enrollment__c IN :programEnrollmentToHIMap.keySet()
        ]) {
            
            matchingProgramEnrollmentIds.add(ahiInfo.Program_Enrollment__c);
            //Check whether a House Hold Income record exists with program enrollment Id that Match's Annual House Hold Information record's Program Enrollment Id
            if (programEnrollmentToHIMap.containsKey(ahiInfo.Program_Enrollment__c)) {
                //If yes check for the Annual House Hold Information record that match's the School year on the House Hold Income records. If the record is found update
                //else create a new Annual House Hold Information record for that House Hold Income record.
                System.debug('Doing the Total Gross Calculation');
                ahiInfo.Total_Gross_HH_Income__c = 0;
                for (Household_Income__c incomeRec : allHouseholdIncomesForPE) {
                    if (incomeRec.School_Year__c == ahiInfo.School_Year__c) {
                        System.debug(ahiInfo.Total_Gross_HH_Income__c + getTotalGrossHHIncome(incomeRec));
                        System.debug('Above is what we set as the total gross');
                        if(ahiListToUpsert.contains(ahiInfo)) {
                            ahiListToUpsert.remove(ahiInfo);
                        }
                        ahiInfo.Total_Gross_HH_Income__c = ahiInfo.Total_Gross_HH_Income__c + getTotalGrossHHIncome(incomeRec);
                        ahiListToUpsert.add(ahiInfo);
                    } else {
                        System.debug('In Insert of School Year' + incomeRec);
                        ahiListToUpsert.add(getAHIRecord(incomeRec));
                    }
                }
            }
        }
        
        //Check the matching ProgramEnrollments List with program Enrollment Map to
        //find out if there are any if there are no records create new AHI record
        List<Household_Income__c> householdIncomesWithOutAHIRecords = new List<Household_Income__c>();
        for (Id pEnrollmentId : programEnrollmentToHIMap.keySet()) {
            if (matchingProgramEnrollmentIds.size() > 0) {
                if (!matchingProgramEnrollmentIds.contains(pEnrollmentId)) {
                    householdIncomesWithOutAHIRecords.addAll(programEnrollmentToHIMap.get(pEnrollmentId));
                }
            } else if (matchingProgramEnrollmentIds.size() == 0) {
                householdIncomesWithOutAHIRecords.addAll(programEnrollmentToHIMap.get(pEnrollmentId));
            }
        }
        
        //If there are any new AHI records to create
        if (householdIncomesWithOutAHIRecords.size() > 0) {
            System.debug('householdIncomesWithOutAHIRecords++' + householdIncomesWithOutAHIRecords);
            for (Household_Income__c income : householdIncomesWithOutAHIRecords) {
                ahiListToUpsert.add(getAHIRecord(income));
            }
        }
        System.debug('ahiListToUpsert::'+ahiListToUpsert);
        //Upsert the records
        if (ahiListToUpsert.size() > 0) {
            try {
                List<Annual_Household_Information__c> insertList = new List<Annual_Household_Information__c>();
                insertList.addAll(ahiListToUpsert);
                upsert insertList;
                
            } catch (Exception ex) {System.debug('In Exception' + ex.getMessage());logger.logException('calculateTotalGrossHHIncome', ex);logger.saveLogs();}
        }
    }
    
    
    public static Map<String, Double> getMultiplierByValue =
        new Map<String, Double>{
            '2 times per month' => 24,
                'bi-weekly (every two weeks)' => 26.07,
                'monthly' => 12,
                'weekly' => 52.14,
                'yearly' => 1,
                'no income' => 0
                };
                    /**
* Created By Ajith on 19-12-2018.
* purpose : This method is for TotalGrossHHIncome calculation
* Params : HouseholdIncome record
*/
                    
                    public static Double getTotalGrossHHIncome(Household_Income__c income) {
                        Double totalHHIncome = 0;
                        if (income.HHAdultIncome_1__c != null && income.Adult_Income_Received_1__c != null)
                            totalHHIncome = Integer.valueOf((income.HHAdultIncome_1__c)) * getMultiplierByValue.get(income.Adult_Income_Received_1__c);
                        if (income.HHAdultIncome_2__c != null && income.Adult_Income_Received_2__c != null)
                            totalHHIncome += Integer.valueOf((income.HHAdultIncome_2__c)) * getMultiplierByValue.get(income.Adult_Income_Received_2__c);
                        if (income.HHAdultIncome_3__c != null && income.Adult_Income_Received_3__c != null)
                            totalHHIncome += Integer.valueOf((income.HHAdultIncome_3__c)) * getMultiplierByValue.get(income.Adult_Income_Received_3__c);
                        if (income.Adult_Income_Other__c != null && income.Adult_Income_Rec_Other__c != null)
                            totalHHIncome += Integer.valueOf((income.Adult_Income_Other__c)) * getMultiplierByValue.get(income.Adult_Income_Rec_Other__c);
                        if (income.Adult_Income_Sup__c != null && income.HHAdultIncomeRecSup__c != null)
                            totalHHIncome += Integer.valueOf((income.Adult_Income_Sup__c)) * getMultiplierByValue.get(income.HHAdultIncomeRecSup__c);
                        if (income.HHAdultIncomeWork__c != null && income.HHAdultIncomeRecWork__c != null)
                            totalHHIncome += Integer.valueOf((income.HHAdultIncomeWork__c)) * getMultiplierByValue.get(income.HHAdultIncomeRecWork__c);
                        if (income.HHChildIncome__c != null && income.HHChildIncomeReceived__c != null)
                            totalHHIncome += Integer.valueOf((income.HHChildIncome__c)) * getMultiplierByValue.get(income.HHChildIncomeReceived__c);
                        
                        
                        System.debug('totalHHIncome+++' + totalHHIncome);
                        System.debug('Calculating...');
                        return totalHHIncome;
                    }
    
    /**
* Created By Ajith on 20-12-2018.
* purpose : This method is for initializing new Annual_Household_Information__c record
* Params : HouseholdIncome record
*/
    public static Annual_Household_Information__c getAHIRecord(Household_Income__c incomeRec) {
        
        Annual_Household_Information__c newAHIRecord = new Annual_Household_Information__c();
        newAHIRecord.Program_Enrollment__c = incomeRec.Program_Enrollment__c;
        newAHIRecord.School_Year__c = incomeRec.School_Year__c;
        newAHIRecord.Total_Gross_HH_Income__c = getTotalGrossHHIncome(incomeRec);
        return newAHIRecord;
    }
    
    /**
* Created By Ritvik on 21-12-2018.
* purpose :This logic will be required to support grade level determination
* Params :List of program enrollment Ids
*/
    public static List<Annual_Student_Information__c> calculateAutomatedPlacementProcess(Set<Id> progEnrollIds, List<Annual_Student_Information__c> asis) {
        //Set to store Annual Student Information record Ids.
        Set<Id> asiIds = new Set<Id>();
        //List to store all object record which needs to be updated.
        List<SObject> allObjectsUpdateList = new List<SObject>();
        //List to Store Program Enrollment record that is to be updated.
        List<hed__Program_Enrollment__c> programEnrollUpdateList = new List<hed__Program_Enrollment__c>();
        //Map which have Id as program enrollment Ids & value as Opportunity related to it.
        Map<Id, Opportunity> progEnrollIdsOpportunity = new Map<Id, Opportunity>();
        //Map which have Id as program enrollment Id & value as List of Records_Request__c record related to it.
        Map<Id, Set<Records_Request__c>> progEnrollIdsRecordsRequest_Map = new Map<Id, Set<Records_Request__c>>();
        
        //Iterating over Records_Request__c record & populate progEnrollIdsRecordsRequest_Map map.
        for (Records_Request__c recordsRequest : [SELECT Id,Secondary_Academic_Doc_Request__c,Program_Enrollment__c FROM Records_Request__c WHERE Program_Enrollment__c IN :progEnrollIds]) {
            if (!progEnrollIdsRecordsRequest_Map.containsKey(recordsRequest.Program_Enrollment__c)) {
                progEnrollIdsRecordsRequest_Map.put(recordsRequest.Program_Enrollment__c, new Set<Records_Request__c>{
                    recordsRequest
                        });
            }
            progEnrollIdsRecordsRequest_Map.get(recordsRequest.Program_Enrollment__c).add(recordsRequest);
        }
        
        for (Opportunity opportunityRecord : [SELECT Lottery_Selection__c,Lottery_Selection_Date__c,Program_Enrollment__c FROM Opportunity WHERE Program_Enrollment__c IN :progEnrollIds]) {
            progEnrollIdsOpportunity.put(opportunityRecord.Program_Enrollment__c, opportunityRecord);
        }
        System.debug('asis:'+asis);
        
        //Iterating over the Annual student information record with program enrollment id as passes in this method's parameter.
        for (Annual_Student_Information__c asiRecord : asis ) {
            System.debug('asis pe:'+asiRecord.School_Year__c );
            System.debug('asis pe1:'+asiRecord.Program_Enrollment__r.Start_Year__c);  
            if (asiRecord.School_Year__c == asiRecord.Program_Enrollment__r.Start_Year__c) {
                hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(Id = asiRecord.Program_Enrollment__c);
                
                if (asiRecord.AutomatedPlacementExclude__c) {
                    continue;
                } else if (asiRecord.AutomatedPlacementScore__c != null && asiRecord.AutomatedPlacementExclude__c == false &&
                           asiRecord.AutomatedPlacementScore__c <= asiRecord.Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c && asiRecord.LA_Placement_Level__c == null &&
                           asiRecord.Science_Placement_Level__c == null && asiRecord.Final_Grade_Level__c == null && asiRecord.Math_Placement_Level__c == null &&
                           (asiRecord.Grade_Level_Requested__c == '8' || asiRecord.Grade_Level_Requested__c == '7' || asiRecord.Grade_Level_Requested__c == '6' ||
                            asiRecord.Grade_Level_Requested__c == '5' || asiRecord.Grade_Level_Requested__c == '4' || asiRecord.Grade_Level_Requested__c == '3' ||
                            asiRecord.Grade_Level_Requested__c == '2' || asiRecord.Grade_Level_Requested__c == '1' || asiRecord.Grade_Level_Requested__c == 'K' || asiRecord.Grade_Level_Requested__c == 'Kindergarten')) {
                                
                                if (asiRecord.Grade_Level_Requested__c == 'K' || asiRecord.Grade_Level_Requested__c == 'Kindergarten') {
                                    asiRecord.LA_Placement_Level__c = 'K';
                                    asiRecord.Final_Grade_Level__c = 'K';
                                    asiRecord.Math_Placement_Level__c = 'K';
                                    asiRecord.Science_Placement_Level__c = 'K';
                                } else if (asiRecord.Grade_Level_Requested__c == '8') {
                                    asiRecord.Math_Placement_Level__c = 'Algebra Readiness';
                                    asiRecord.Final_Grade_Level__c = '8';
                                    asiRecord.LA_Placement_Level__c = '8';
                                    asiRecord.Science_Placement_Level__c = '8';
                                } else {
                                    asiRecord.LA_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                                    asiRecord.Science_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                                    asiRecord.Final_Grade_Level__c = asiRecord.Grade_Level_Requested__c;
                                    asiRecord.Math_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                                }
                                
                                //asiRecord.Program_Enrollment__r.PlacementFlag__c = '';
                                programEnrollment = asiRecord.Program_Enrollment__r;
                                programEnrollment.PlacementFlag__c = null;
                                
                                //Records_Request__c - populating Secondary_Academic_Doc_Request__c field
                                if (!progEnrollIdsRecordsRequest_Map.isEmpty() && progEnrollIdsRecordsRequest_Map.containsKey(asiRecord.Program_Enrollment__c)) {
                                    for (Records_Request__c recordsRequest : progEnrollIdsRecordsRequest_Map.get(asiRecord.Program_Enrollment__c)) {
                                        recordsRequest.Secondary_Academic_Doc_Request__c = null;
                                        allObjectsUpdateList.add(recordsRequest);
                                    }
                                }
                                
                                asiRecord.CoursesFinalized__c = 'Yes';
                                asiRecord.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
                                
                                //Calculate Program_Enrollment__c .StudentFlag__c
                                //MM                    //Mark Membrino  All this logic for student flag goes away.  117688
                                /*  if (!isMatch(asiRecord.Program_Enrollment__r.WaitlistFlag__c, 'Active', false) &&
!isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Eligibility', false) &&
!isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Disciplinary History', false) &&
!isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Special Education', false) &&
!isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Placement', false)) {
programEnrollment.StudentFlag__c = null;
} else if (asiRecord.Program_Enrollment__r.WhyFlagged__c == null) {
programEnrollment.StudentFlag__c = 'Released';
} else {
programEnrollment.StudentFlag__c = 'On-Hold';
}  */
                                
                                // Calculate Opportunity.Lottery_Selection__c
                                if (!progEnrollIdsOpportunity.isEmpty() && progEnrollIdsOpportunity.containsKey(asiRecord.Program_Enrollment__c)) {
                                    if (progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection_Date__c != null) {
                                        progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection__c = 'Selected';
                                    } else {
                                        progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection__c = 'Not Selected';
                                    }
                                }
                                
                                // Calculate Annual_Student_Information__c.APS_PlacedTimeStamp__c
                                if (asiRecord.Program_Enrollment__r.Start_Year__r.Current_Year__c == true &&
                                    asiRecord.APS_PlacedTimeStamp__c == null && asiRecord.CoursesFinalized__c == 'Yes') {
                                        asiRecord.APS_PlacedTimeStamp__c = System.now();
                                    }
                                
                                if (!programEnrollUpdateList.contains(programEnrollment)) {
                                    allObjectsUpdateList.add(programEnrollment);
                                }
                                
                                asiIds.add(asiRecord.Id);
                                allObjectsUpdateList.add(progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c));
                            }
            }
            
        }
        //Checking for sObject List that is to be updated is empty or not.
        if (!allObjectsUpdateList.isEmpty()) {
            try {
                update allObjectsUpdateList;
            } catch (Exception e) {System.debug('Exception :::' + e.getMessage());logger.logException('calculateAutomatedPlacementProcess', e);logger.saveLogs();}
        }
        return asis;
    }
    
    /**
* Created by Anushka on 18/12/18.
* Purpose : Method to calculate Waitlist Flag on Program Enrollment.
*/
    //Start: Ritvik/Ashish 12/02/2019 Code refactor for SOQL queries
  public static List<Hed__Program_Enrollment__c> waitListCalculator(Set<Id> programEnrollmentList) {
        System.debug('waitlistCalculator+++++');
        Map<Id, Annual_Student_Information__c> annualStudentInformationMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, List<Program_Grade_Level__c>> programGradeLevelMap = new Map<Id, List<Program_Grade_Level__c>>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        Map<Id, Id> programEnrollmentIdToAccountIds = new Map<Id, Id>();
        //Commented Below line and added generic soql line for #430196

        List<hed__Program_Enrollment__c> programEnrollments = [Select id, Open_Application__c, Open_Application_Period_status__c,hed__Account__c, WaitlistFlag__c, Program_Grade_Level__c from hed__Program_Enrollment__c where id in:programEnrollmentList];
        //Commenting the below line and uncommenting above line as we're getting an issue - Krishna Peddanagammol on 2021-08-27
        //List<hed__Program_Enrollment__c> programEnrollments = GenericSOQLQueries.programEnrollmentDetails(programEnrollmentList);

        List<hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
        
        for (Opportunity opp : [
            Select id, Program_Enrollment__c
            from Opportunity
            where Program_Enrollment__c in:programEnrollmentList
            AND StageName = 'Open'
        ]) {
            opportunityMap.put(opp.Program_Enrollment__c, opp);
        }
        
        if (opportunityMap.isEmpty()) {
            return programEnrollmentsToUpdate;
        }
        
        for (Annual_Student_Information__c asi : [
            Select id, Program_Enrollment__c
            from Annual_Student_Information__c
            where Program_Enrollment__c in:programEnrollmentList
            AND (Final_Grade_Level__c != null OR Grade_Level_Requested__c != null)
        ]) {
            annualStudentInformationMap.put(asi.Program_Enrollment__c, asi);
        }
        
        if (annualStudentInformationMap.isEmpty()) {
            return programEnrollmentsToUpdate;
        }
        
        for (hed__Program_Enrollment__c pe : programEnrollments) {
            programEnrollmentIdToAccountIds.put(pe.Id, pe.hed__Account__c);
            // accountIds.add(pe.hed__Account__c);
        }
        
        if (programEnrollmentIdToAccountIds.isEmpty()) {
            return programEnrollmentsToUpdate;
        }
        
        for (Program_Grade_Level__c pgl : [
            SELECT Id, Academic_Program__c, ActivateWaitlist__c, StartWaitlist__c, EndWaitlist__c, Open_Application__c,Start_Open_Application__c,End_Open_Application__c
            FROM Program_Grade_Level__c
            WHERE Academic_Program__c IN:programEnrollmentIdToAccountIds.values()
        ]) {
            List<Program_Grade_Level__c> tempGradeLevels = new List<Program_Grade_Level__c>();
            if(programGradeLevelMap.containsKey(pgl.Academic_Program__c)) {
                tempGradeLevels = programGradeLevelMap.get(pgl.Academic_Program__c);
            }
            tempGradeLevels.add(pgl);
            programGradeLevelMap.put(pgl.Academic_Program__c, tempGradeLevels);
        }
        System.debug('programGradeLevelMap+++'+programGradeLevelMap);
        if (programGradeLevelMap.isEmpty()) {
            return programEnrollmentsToUpdate;
        }
        
       //list<hed__Program_Enrollment__c> openAppPE = New list<hed__Program_Enrollment__c>();
      	//boolean openAppFlag = true;
        Boolean resetPEFlag = false;
        for (hed__Program_Enrollment__c pe : programEnrollments) {
            if (opportunityMap.get(pe.Id) != null && annualStudentInformationMap.get(pe.Id) != null
                && programEnrollmentIdToAccountIds.get(pe.Id) != null
                && programGradeLevelMap.get(programEnrollmentIdToAccountIds.get(pe.Id)) != null) {
                    
                    List<Program_Grade_Level__c> pgls = programGradeLevelMap.get(pe.hed__Account__c);
                    
                    for(Program_Grade_Level__c pgl : pgls) {
                        System.debug('pgl.Id='+pgl.Id+', pe.Program_Grade_Level__c='+pe.Program_Grade_Level__c);
                        System.debug('pgl.ActivateWaitlist__c='+pgl.ActivateWaitlist__c);
                        System.debug('pgl.StartWaitlist__c='+pgl.StartWaitlist__c+', pgl.EndWaitlist__c='+pgl.EndWaitlist__c);  
                        //Added for Userstory 451172- DK
                        if(pgl.Id == pe.Program_Grade_Level__c && ((pgl.ActivateWaitlist__c == TRUE && pgl.StartWaitlist__c <= System.now() && pgl.EndWaitlist__c >= System.now()) || (pgl.Open_Application__c == 'Active' && pgl.Start_Open_Application__c <= System.now() && pgl.End_Open_Application__c >= System.now() ))) { 
                                                      
                            if(pgl.ActivateWaitlist__c == TRUE && pe.WaitlistFlag__c!= 'Released'){
                                pe.WaitlistFlag__c = 'Active';
                            }
                            
                            if(pgl.Open_Application__c == 'Active' && pe.Open_Application__c!= 'Released'){
                                pe.Open_Application__c = 'Active';
                            }
                          
                            // End for Userstory 451172- DK
                            programEnrollmentsToUpdate.add(pe);
                            resetPEFlag = false;
                            break;
                        }
                        else {
                            resetPEFlag = true;
                            
                        }                                                   
      
                    }
                    
                    if(resetPEFlag) {
                        pe.WaitlistFlag__c = null;
                        programEnrollmentsToUpdate.add(pe);
                    }
                    
                    
                }
            
        }
      	
        return programEnrollmentsToUpdate;
    }
    
    
	public static void openApplicationflag(list<Program_Grade_Level__c> pglList) {   
        set<id> peIds = new set<id>();
        for(Program_Grade_Level__c pg: pglList){
            peIds.add(pg.Id);
            system.debug('peIds'+peIds);
        }
        list<hed__Program_Enrollment__c> peUpdate = new list<hed__Program_Enrollment__c>();
        Map<Id,hed__Program_Enrollment__c> peList = new Map<Id,hed__Program_Enrollment__c>([select id,Program_Grade_Level__c,Open_Application__c from hed__Program_Enrollment__c where Program_Grade_Level__c IN:peIds AND Open_Application__c != null]);
        system.debug('peList'+peList);
        for(Program_Grade_Level__c pg: pglList){
             system.debug('pglList'+pglList);
            for(hed__Program_Enrollment__c penroll : peList.values()){
                system.debug('penroll'+penroll);
                if(pg.Id == penroll.Program_Grade_Level__c){
                    if(pg.Open_Application__c == 'Active' && pg.Start_Open_Application__c <= System.now() && pg.End_Open_Application__c >= System.now()){
                        penroll.Open_Application__c = pg.Open_Application__c;
                        peUpdate.add(penroll);
                        system.debug('peUpdate'+peUpdate);
                    }else if(pg.Open_Application__c == 'Inactive' || pg.Start_Open_Application__c > System.now() || pg.End_Open_Application__c < System.now()){
                        penroll.Open_Application__c = pg.Open_Application__c;
                        peUpdate.add(penroll);
                        system.debug('peUpdate'+peUpdate);
                    }
                }
            }
        }
        if(peUpdate.size() > 0){
            update peUpdate;
            system.debug('peUpdate'+peUpdate);
        }        
    }
    
    /**
* Created by Raju on 24/12/18.
* Purpose : Method to invoke by different triggers
*/
    public static void invokeCalculateWhyFlagMethod(List<SObject> records, Map<Id, SObject> oldMap) {
        try {
            
            if (records==null || records.isEmpty()) { // [US 125001 :: ALI KM :: 1/13] - adding null check.
                return;
            }
            
            
            System.debug('Ok we did get here');
            //check the type of object on which trigger is executing
            String sObjectType = (oldMap == null ? String.valueOf(records[0].getSObjectType()) :
                                  String.valueOf(oldMap.values()[0].getSObjectType()));
            Boolean isInsert = (oldMap == null ? true : false);
            Set<Id> progEnrollmentIds = new Set<Id>();
            // if trigger is fired from Annual Student Information  then this logic gets all the programEnrollment Ids
            if (sObjectType == ANNUAL_STUDENT_INFORMATION_OBJECT) {
                if (records != null) {//logic if trigger is on insert and update events
                    for (Annual_Student_Information__c asiRecord : (List<Annual_Student_Information__c>) records) {
                        // logic for on update on AnnualInfo Trigger
                        if ((isInsert && (asiRecord.HowStudentPlacementCompleted__c != null || asiRecord.Final_Grade_Level__c != null)) ||
                            (!isInsert && (asiRecord.HowStudentPlacementCompleted__c != ((Annual_Student_Information__c) oldMap.get(asiRecord.Id)).HowStudentPlacementCompleted__c ||
                                           asiRecord.Final_Grade_Level__c != ((Annual_Student_Information__c) oldMap.get(asiRecord.Id)).Final_Grade_Level__c))) {
                                               // logic for On Insert on Annual Student Info logic
                                               if (asiRecord.Program_Enrollment__c != null) {
                                                   progEnrollmentIds.add(asiRecord.Program_Enrollment__c);
                                               }
                                           }
                    }
                }
            } else if (sObjectType == ENROLLMENT_DOCUMENT_OBJECT) {
                if (records != null) {//logic if trigger is on insert and update events
                    for (Enrollment_Document__c edRecord : (List<Enrollment_Document__c>) records) {
                        if ((isInsert && (edRecord.Status_Reason__c != null) ||
                             (!isInsert && (edRecord.Status_Reason__c != ((Enrollment_Document__c) oldMap.get(edRecord.Id)).Status_Reason__c)))) {
                                 
                                 if (edRecord.Program_Enrollment__c != null) {
                                     progEnrollmentIds.add(edRecord.Program_Enrollment__c);
                                 }
                                 
                             }
                    }
                }
            }
            
            
            else if (sObjectType == SPECIAL_EDUCATION_OBJECT) {
                if (records != null) {//logic if trigger is on insert and update events
                    for (Special_Education__c seRecord : (List<Special_Education__c>) records) {
                        System.debug('seRecord==' + seRecord);
                        if ((isInsert && (seRecord.Plan504__c != null || seRecord.IEP__c != null)) ||
                            (!isInsert && (seRecord.Plan504__c != ((Special_Education__c) oldMap.get(seRecord.Id)).Plan504__c ||
                                           seRecord.IEP__c != ((Special_Education__c) oldMap.get(seRecord.Id)).IEP__c ||
                                           seRecord.FormallyExitedIEP__c != ((Special_Education__c) oldMap.get(seRecord.Id)).FormallyExitedIEP__c))) {
                                               
                                               if (seRecord.Program_Enrollment__c != null) {
                                                   progEnrollmentIds.add(seRecord.Program_Enrollment__c);
                                               }
                                               
                                               
                                           }
                    }
                }
                
                
            } else if (sObjectType == PROGRAM_GRADE_LEVEL_OBJECT) {
                if (records != null) {//logic if trigger is on insert and update events
                    for (Program_Grade_Level__c pglRecord : (List<Program_Grade_Level__c>) records) {
                        if ((isInsert && (pglRecord.AutoPlacement_Special_EdExclude__c != null)) ||
                            (!isInsert && (pglRecord.AutoPlacement_Special_EdExclude__c != ((Program_Grade_Level__c) oldMap.get(pglRecord.Id)).AutoPlacement_Special_EdExclude__c))) {
                                
                                //validContacts.add(contactRecord);
                                
                                
                            }
                    }
                }
                
            } else if (sObjectType == PROGRAM_ENROLLMENT_OBJECT) {
                System.debug('PROGRAM_ENROLLMENT_OBJECT'+PROGRAM_ENROLLMENT_OBJECT);
                if (records != null) {//logic if trigger is on insert and update events
                    
                    for (hed__Program_Enrollment__c peRecord : (List<hed__Program_Enrollment__c>) records) {
                        System.debug('isInsert' + isInsert + '==>>>peRecord' + peRecord);
                        if ((isInsert && (peRecord.HHPORFlag__c != null ||
                                          peRecord.PORFlag__c != null ||
                                          peRecord.PlacementFlag__c != null ||
                                          peRecord.CounselingFlag__c != null ||
                                          peRecord.Start_Year__c != null ||
                                          peRecord.PriorWithdrawalFlag__c != null ||
                                          peRecord.WaitlistFlag__c != null ||
                                          //Added user story for US 476964
                                          peRecord.Foster_Flag__c == 'Pending Review' ||
                                          //Commented Deprecate Technology flag logic for US 476956
                                          //peRecord.UserTechnologyFlag__c != null ||
                                          peRecord.GradeLevelEligibility__c != null ||
                                          peRecord.EntranceAgeEligibilityFinal__c != null ||
                                          peRecord.DisciplinaryFlagOverride__c != null ||
                                          peRecord.HomelessRiskFlag__c != null ||
                                          peRecord.EligibilityFlag__c != null ||
                                          peRecord.AcademicPerformanceEligibility__c != null ||
                                          peRecord.PrincipalGeneralFlag__c != null)) ||
                            (!isInsert && (peRecord.HHPORFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).HHPORFlag__c ||
                                           //Added user story for US 476964
                                           peRecord.Foster_Flag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).Foster_Flag__c ||
                                           peRecord.PORFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).PORFlag__c ||
                                           peRecord.PlacementFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).PlacementFlag__c ||
                                           peRecord.CounselingFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).CounselingFlag__c ||
                                           peRecord.Start_Year__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).Start_Year__c ||
                                           peRecord.PriorWithdrawalFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).PriorWithdrawalFlag__c ||
                                           peRecord.WaitlistFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).WaitlistFlag__c ||
                                           //Commented Deprecate Technology flag logic for US 476956
                                           //peRecord.UserTechnologyFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).UserTechnologyFlag__c ||
                                           peRecord.GradeLevelEligibility__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).GradeLevelEligibility__c ||
                                           peRecord.EntranceAgeEligibilitySystem__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).EntranceAgeEligibilitySystem__c ||
                                           peRecord.EntranceAgeEligibilityOverride__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).EntranceAgeEligibilityOverride__c ||
                                           peRecord.AddressEligibilitySystem__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).AddressEligibilitySystem__c ||
                                           peRecord.AddressEligibilityOverride__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).AddressEligibilityOverride__c ||
                                           peRecord.DisciplinaryFlagOverride__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).DisciplinaryFlagOverride__c ||
                                           peRecord.HomelessRiskFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).HomelessRiskFlag__c ||
                                           peRecord.EligibilityFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).EligibilityFlag__c ||
                                           peRecord.Status__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).Status__c ||
                                           peRecord.AcademicPerformanceEligibility__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).AcademicPerformanceEligibility__c ||
                                           peRecord.PrincipalGeneralFlag__c != ((hed__Program_Enrollment__c) oldMap.get(peRecord.Id)).PrincipalGeneralFlag__c))) {
                                               
                                               if (peRecord.Id != null) {
                                                   progEnrollmentIds.add(peRecord.Id);
                                               }
                                               
                                               
                                           }
                    }
                }
                
            }
            system.debug('==>progEnrollmentIds '+progEnrollmentIds);
            system.debug('==>runWhyFlagged '+runWhyFlagged);
            if (!progEnrollmentIds.isEmpty() && runWhyFlagged) {
                // calculateWhyFlagged Method is Called from here When progEnrollmentIds
                System.debug('calculating why flagged');
                List<hed__Program_Enrollment__c> programEnrollments = calculateWhyFlagged(progEnrollmentIds);
                Boolean origRunCBL = NES_ProgramEnrollmentHandler.runCBL;
                NES_ProgramEnrollmentHandler.runCBL = false;
                update programEnrollments;
                NES_ProgramEnrollmentHandler.runCBL = origRunCBL;
            }
        } catch (Exception ex) {System.debug('Error: ' + ex.getMessage());logger.logException('invokeCalculateWhyFlagMethod', ex);logger.saveLogs();}
        
    }
    
    // For each of the ECAs attached to this PE, if they have the "form needed to be complete" checkbox, then
    // Either that ECA itself needs to be Complete, or all of its non-Document children (via ECR) need to be Complete
    // If the above does not evaluate to true, we are not sufficiently complete to calculate any requisite information
    public static Set<Id> getPEsWithRequisiteEcasComplete(Set<Id> programEnrollmentIds, Boolean studentEnrollment, Boolean householdEnrollment, Boolean autoPlacement) {
        Set<Id> pesWithRequisiteEcasComplete = programEnrollmentIds.clone();
        System.debug('checking getPEsWithRequisiteEcasComplete');
        
        Map<Id, Enrollment_Component__c> ecMap = new Map<Id, Enrollment_Component__c>([
            select Id, RecordType.Name, Student_Enrollment_Information__c, Household_Enrollment_Information__c, Required_to_Complete_for_Auto_Placement__c,
            (select Id, Child_Enrollment_Component__c from Enrollment_Component_Relationships__r where Child_Enrollment_Component__r.RecordType.Name != 'Document'),
            (select Id, Status__c, Program_Enrollment__c from Enrollment_Component_Affiliation__r where Program_Enrollment__c in :programEnrollmentIds)
            from Enrollment_Component__c
            where Id in (select enrollment_component__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c in :programEnrollmentIds)]);
        
        for (Enrollment_Component__c ec : ecMap.values()) {
            // find all ECAs for with the requisite checkboxes
            if (studentEnrollment && ec.Student_Enrollment_Information__c == false) {
                continue;
            }
            if (householdEnrollment && ec.Household_Enrollment_Information__c == false) {
                continue;
            }
            if (autoPlacement && ec.Required_to_Complete_for_Auto_Placement__c == false) {
                continue;
            }
            // if the ECA is incomplete, and there exists a child that is not complete, then do not process
            
            // only one ECA for each EC
            Enrollment_Component_Affiliation__c eca = ec.Enrollment_Component_Affiliation__r.isEmpty() ? null : ec.Enrollment_Component_Affiliation__r.get(0);
            if (eca == null) {
                // this should never happen by nature of what we're querying
                logger.logError('getPEsWithRequisiteEcasComplete', 'Received an ECA without actually being present');
            } else if (eca.Status__c != 'Complete') {
                //look at all non-document children
                for (Enrollment_Component_Relationship__c ecr : ec.Enrollment_Component_Relationships__r) {
                    // find the ECA for them, if status is not Complete, remove this from ready to calculate status
                    Enrollment_Component__c childEc = ecMap.containsKey(ecr.Child_Enrollment_Component__c) ? ecMap.get(ecr.Child_Enrollment_Component__c) : null;
                    
                    // only one ECA for each ECA
                    Enrollment_Component_Affiliation__c childEca = (childEc == null || childEc.Enrollment_Component_Affiliation__r == null || childEc.Enrollment_Component_Affiliation__r.isEmpty()) ? null : childEc.Enrollment_Component_Affiliation__r.get(0);
                    if (childEca != null && childEca.Status__c != 'Complete') {
                        logger.logInfo('getPEsWithRequisiteEcasComplete', 'Removing '+childEca.Program_Enrollment__c+' from PEs to calculate because found a child that was not Complete');
                        pesWithRequisiteEcasComplete.remove(childEca.Program_Enrollment__c);
                    }
                }
            }
        }
        
        logger.saveLogs();
        return pesWithRequisiteEcasComplete;
    }
    
    public static List<Annual_Student_Information__c> placementWhyFlagged(Set<Id> progEnrollmentIds, List<Annual_Student_Information__c> asis) {
        
        Map<Id, Annual_Student_Information__c> programEnrollmentToStudentInfoMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, List<Enrollment_Document__c>> enrollmentDocumentMap = new Map<Id, List<Enrollment_Document__c>>();
        Map<Id, Program_Grade_Level__c> programEnrollmentToProgramGradesMap = new Map<Id, Program_Grade_Level__c>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();
        List<hed__Program_Enrollment__c> progEnrollmentList = new List<hed__Program_Enrollment__c>();
        Map<Id, List<Program_Grade_Level__c>> progGradesMap = new Map<Id, List<Program_Grade_Level__c>> ();
        
        //Query for ProgramGrade for Related programEnrollment Ids
        for (Program_Grade_Level__c progGrade : [
            SELECT Id,Grade_Level__c,Academic_Program__c,AutoPlacement_Special_EdExclude__c,Grade_Level__r.Name
            FROM Program_Grade_Level__c
            WHERE AutoPlacement_Special_EdExclude__c = FALSE AND
            Academic_Program__c IN (SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id IN:progEnrollmentIds) AND Grade_Level__c <> null
        ]) {
            if (progGradesMap.containsKey(progGrade.Academic_Program__c)) {
                progGradesMap.get(progGrade.Academic_Program__c).add(progGrade);
            } else {
                progGradesMap.put(progGrade.Academic_Program__c, new List<Program_Grade_Level__c>{
                    progGrade
                        });
            }
            
        }
        
        List<hed__Program_Enrollment__c> progEnrollments = [
            SELECT Id,
            hed__Account__c,
            WhyFlagged__c,
            HHPORFlag__c,
            Status__c,
            PORFlag__c,
            PlacementFlag__c,
            CounselingFlag__c,
            Start_Year__c,
            PriorWithdrawalFlag__c,
            GradeLevelEligibility__c,
            EntranceAgeEligibilitySystem__c,
            EntranceAgeEligibilityOverride__c,
            EntranceAgeEligibilityFinal__c,
            WaitlistFlag__c,
            //Commented Deprecate Technology flag logic for US 476956
            //UserTechnologyFlag__c,
            DisciplinaryFlagOverride__c,
            HomelessRiskFlag__c,
            EligibilityFlag__c,
            PrincipalGeneralFlag__c,
            hed__Contact__c,
            Start_Year__r.Current_Year__c,
            (SELECT Id, StageName
             FROM Opportunities__r
             WHERE StageName = 'Closed Won'),
            (SELECT Id, Status_Reason__c, Type__c, Program_Enrollment__c
             FROM Enrollment_Documents__r),
            (SELECT Id, IEP__c, Plan504__c, Program_Enrollment__c
             FROM Special_Educations__r)
            FROM hed__Program_Enrollment__c
            WHERE Id IN :progEnrollmentIds
        ];
        
        for (hed__Program_Enrollment__c progEnrollment : progEnrollments) {
            for (Annual_Student_Information__c studentInfo : asis) {
                if ((!String.IsBlank(studentInfo.School_Year__c) && studentInfo.School_Year__c == studentInfo.Program_Enrollment__r.Start_Year__c) &&
                    !String.IsBlank(studentInfo.HowStudentPlacementCompleted__c) && studentInfo.HowStudentPlacementCompleted__c.contains('Auto-Placement')) {
                        programEnrollmentToStudentInfoMap.put(studentInfo.Program_Enrollment__c, studentInfo);
                        
                    }
            }
            for (Enrollment_Document__c document : progEnrollment.Enrollment_Documents__r) {
                if (enrollmentDocumentMap.containsKey(document.Program_Enrollment__c)) {
                    enrollmentDocumentMap.get(document.Program_Enrollment__c).add(document);
                } else {
                    enrollmentDocumentMap.put(document.Program_Enrollment__c, new List<Enrollment_Document__c>{
                        document
                            });
                }
            }
            for (Special_Education__c specialEducation : progEnrollment.Special_Educations__r) {
                specialEducationMap.put(specialEducation.Program_Enrollment__c, specialEducation);
            }
            
        }
        System.debug('programEnrollmentToStudentInfoMap ::' + programEnrollmentToStudentInfoMap);
        System.debug('enrollmentDocumentMap ::' + enrollmentDocumentMap);
        System.debug('specialEducationMap ::' + specialEducationMap);
        
        
        // logic to be implement concatenate the string based on conditions
        for (hed__Program_Enrollment__c progEnrollment : progEnrollments) {
            String returnString = '';
            System.debug('progEnrollment=====>>>' + progEnrollment);
            if (!progEnrollmentIds.contains(progEnrollment.Id)) {
                logger.logInfo('calculateWhyFlagged', 'Not calculating WhyFlagged for '+progEnrollment.Id+' because not all requisite ECAs are complete');
                continue;
            }
            // programEnrollment's  condition based on PORFlag__c and  HHPORFlag__c values to add [Proof of Residency]- to return String
            //MM 11/7/2019  Removed as part of the Gap Analysis
            /*          if (progEnrollment.Status__c == 'Complete' && (
progEnrollment.HHPORFlag__c != null && (progEnrollment.HHPORFlag__c.contains('Pending') ||
progEnrollment.HHPORFlag__c.contains('Undeliverable Address')) || (
progEnrollment.PORFlag__c != null && (
progEnrollment.PORFlag__c.contains('Pending') ||
progEnrollment.PORFlag__c.contains('Undeliverable Address'))))) {
System.debug('[Proof of Residency]- Condition');
returnString += '[Proof of Residency]-';
} 
// programEnrollment's  condition based on Status__c and  Opportunities__r values to add  '' to return String
elseif ((!String.isBlank(progEnrollment.Status__c) && progEnrollment.Status__c == 'Complete') &&
progEnrollment.Opportunities__r.size() > 0) {
returnString += '';
} */
            
            // programEnrollment's  condition based on progEnrollment.Id and  add ''
            else if (programEnrollmentToStudentInfoMap.containsKey(progEnrollment.Id) && programEnrollmentToStudentInfoMap.get(progEnrollment.Id) <> null) {
                returnString += '';
            }
            // programEnrollment's  condition based on PlacementFlag__c and  add '{Placement}-'  to return String
            else if ((!String.isBlank(progEnrollment.PlacementFlag__c) && progEnrollment.PlacementFlag__c <> 'Released')) {
                returnString += '{Placement}-';
            }
            
            
            
            
            Boolean shouldPass = false;
            // AnnualStudentInfo and program Grades condition based on Final_Grade_Level__c and Grade_Level__r.Name add '' to return String
            if (programEnrollmentToStudentInfoMap.containsKey(progEnrollment.Id) &&
                progGradesMap.containsKey(progEnrollment.hed__Account__c)) {
                    
                    System.debug('If GradeMap');
                    for (Program_Grade_Level__c progGrades : progGradesMap.get(progEnrollment.hed__Account__c)) {
                        if (programEnrollmentToStudentInfoMap.get(progEnrollment.Id).Final_Grade_Level__c == progGrades.Grade_Level__r.Name) {
                            returnString += '';
                            shouldPass = true;
                            break;
                        }
                    }
                }
            
            // only enter here if the ASI HowStudentPlacementCompleted does not contain Auto-Placement or
            // the PGL's AutoPlacement_SpecialEdExclude__c is true
            if (!shouldPass) {
                Boolean shouldIncludeSpecialEd = false;
                if (specialEducationMap.containsKey(progEnrollment.Id) && specialEducationMap.get(progEnrollment.Id).IEP__c != null && specialEducationMap.get(progEnrollment.Id).IEP__c != 'IEP') {
                    shouldIncludeSpecialEd = true;
                } else if (specialEducationMap.containsKey(progEnrollment.Id) && specialEducationMap.get(progEnrollment.Id).FormallyExitedIEP__c == 'Yes' ){
                    shouldIncludeSpecialEd = true;
                    if (!progEnrollment.Enrollment_Documents__r.isEmpty()) {
                        for (Enrollment_Document__c ed : progEnrollment.Enrollment_Documents__r) {
                            if ((ed.Type__c == 'IEP Exit Documentation' && ed.Status_Reason__c != null && 
                                 (new Set<String>{'Verified', 'Not Applicable', 'Verified-No Documentation Available'}).contains(ed.Status_Reason__c))  
                               ) {
                                   shouldIncludeSpecialEd = false;
                                   break;
                               }
                        }
                    }
                }
                
                if (shouldIncludeSpecialEd) {
                    returnString += '{Special Education}-';
                }
            }
            
            Set<String> statusList = new Set<String> {'504 Missing', 'Received', 'Received-No Documentation', 'Illegible'};
                if (specialEducationMap.containsKey(progEnrollment.Id) && statusList.contains(specialEducationMap.get(progEnrollment.Id).Plan504__c)) {
                    returnString += '{504 Plan}~';
                }
            
            // Condition for progEnrollment based on CounselingFlag__c field to add Program Fit~
            if (!String.isBlank(progEnrollment.CounselingFlag__c) && progEnrollment.CounselingFlag__c == 'Stop') {
                returnString += 'Program Fit-';
            }
            if (progEnrollment.EligibilityFlag__c != null && (new Set<String> {'Pending', 'Ineligible'}).contains(progEnrollment.EligibilityFlag__c)) {
                returnString += '[Eligibility]-';
            }
            // Condition for progEnrollment based on PriorWithdrawalFlag__c field to add [Prior Withdrawal]-
            if (progEnrollment.Start_Year__r.Current_Year__c == true && progEnrollment.PriorWithdrawalFlag__c == 'Hold') {
                returnString += '[Prior Withdrawal]-';
            }
            if (!String.isBlank(progEnrollment.WaitlistFlag__c) && new List<String>{
                'Active', 'In Review', 'Active-Reset'
                    } .contains(progEnrollment.WaitlistFlag__c)) {
                        returnString += '[Waitlisted]-';
                    }
            //Commented Deprecate Technology flag logic for US 476956
            /*if (!String.isBlank(progEnrollment.UserTechnologyFlag__c) && progEnrollment.UserTechnologyFlag__c == 'Technology Flag') {
                returnString += '[Technology]-';
            }*/
            if (!String.isBlank(progEnrollment.DisciplinaryFlagOverride__c) &&
                (progEnrollment.DisciplinaryFlagOverride__c == 'Pending Review' || progEnrollment.DisciplinaryFlagOverride__c == 'Withdraw')) {
                    returnString += '[Disciplinary History]-';
                }
            if (!String.isBlank(progEnrollment.HomelessRiskFlag__c) && progEnrollment.HomelessRiskFlag__c == 'Potential Homeless') {
                returnString += '[Potential Homeless]-';
            }
            if (String.isBlank(progEnrollment.PrincipalGeneralFlag__c) || progEnrollment.PrincipalGeneralFlag__c == 'Released' ||
                progEnrollment.PrincipalGeneralFlag__c == 'Student requesting 12th grade after 1/1/19') {
                    returnString += '';
                } else {
                    returnString += progEnrollment.PrincipalGeneralFlag__c;
                }
            if (!String.isBlank(progEnrollment.GradeLevelEligibility__c) && progEnrollment.GradeLevelEligibility__c != 'Allowed to Enroll') {
                returnString += '{Grade Level Eligibility}-';
            }
            if (!String.isBlank(progEnrollment.EntranceAgeEligibilityFinal__c) && progEnrollment.EntranceAgeEligibilityFinal__c <> 'Eligible') { 
                returnString += '{Age Eligibility}-';
            }
            System.debug('returnString===>>>' + returnString);
            // Append return String to WhyFlagged__c field
            progEnrollment.WhyFlagged__c = returnString;
            progEnrollmentList.add(progEnrollment);
        }
        //update the progEnrollmentList with WhyFlagged__c field
        if (!progEnrollmentList.isEmpty()) {
            try {
                System.debug('Attempting to update');
                update progEnrollmentList;
                System.debug('After updating that list');
                
            } catch (exception e) {System.debug('***Exception***');System.debug('Exception:' + e.getMessage());logger.logException('calculateWhyFlagged', e);}
        }
        
        System.debug('Returning enrollment list');
        logger.saveLogs();
        return asis;
    }
    
    /**
* Created by Anand on 26/12/18.
* Purpose : This Method is related to Task59999 To calculate Why Flag
* @param :  Set<Id>progEnrollmentIds
*/
    public static List<hed__Program_Enrollment__c> calculateWhyFlagged(Set<Id> progEnrollmentIds) {
        System.debug('programEnrollmentIds=====>>>>' + progEnrollmentIds);
        
        Set<Id> progEnrollmentsToCalculate = getPEsWithRequisiteEcasComplete(progEnrollmentIds, true, true, false);
        System.debug('progEnrollmentsToCalculate++'+progEnrollmentsToCalculate);
        //PE to Annual Student Information map
        Map<Id, Annual_Student_Information__c> programEnrollmentToStudentInfoMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, List<Enrollment_Document__c>> enrollmentDocumentMap = new Map<Id, List<Enrollment_Document__c>>();
        Map<Id, Program_Grade_Level__c> programEnrollmentToProgramGradesMap = new Map<Id, Program_Grade_Level__c>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();
        List<hed__Program_Enrollment__c> progEnrollmentList = new List<hed__Program_Enrollment__c>();
        Map<Id, List<Program_Grade_Level__c>> progGradesMap = new Map<Id, List<Program_Grade_Level__c>> ();
        
        //Query for ProgramGrade for Related programEnrollment Ids
        for (Program_Grade_Level__c progGrade : [
            SELECT Id,Grade_Level__c,Academic_Program__c,AutoPlacement_Special_EdExclude__c,Grade_Level__r.Name
            FROM Program_Grade_Level__c
            WHERE AutoPlacement_Special_EdExclude__c = FALSE AND
            Academic_Program__c IN (SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id IN:progEnrollmentIds) AND Grade_Level__c <> null
        ]) {
            if (progGradesMap.containsKey(progGrade.Academic_Program__c)) {
                progGradesMap.get(progGrade.Academic_Program__c).add(progGrade);
            } else {
                progGradesMap.put(progGrade.Academic_Program__c, new List<Program_Grade_Level__c>{
                    progGrade
                        });
            }
        }
        
        List<hed__Program_Enrollment__c> progEnrollments = [
            SELECT Id,
            hed__Account__c,
            WhyFlagged__c,
            HHPORFlag__c,
            Status__c,
            PORFlag__c,
            PlacementFlag__c,
            CounselingFlag__c,
            Start_Year__c,
            PriorWithdrawalFlag__c,
            GradeLevelEligibility__c,
            EntranceAgeEligibilitySystem__c,
            EntranceAgeEligibilityOverride__c,
            EntranceAgeEligibilityFinal__c,
            WaitlistFlag__c,
            //Added user story for US 476964
            Foster_Flag__c,
            //Commented Deprecate Technology flag logic for US 476956
            //UserTechnologyFlag__c,
            DisciplinaryFlagOverride__c,
            HomelessRiskFlag__c,
            EligibilityFlag__c,
            PrincipalGeneralFlag__c,
            hed__Contact__c,
            Start_Year__r.Current_Year__c, AddressEligibility__c,AcademicPerformanceEligibility__c,
            hed__Account__r.Requires_Special_Education_Review__c,
            (SELECT Id, StageName
             FROM Opportunities__r
             WHERE StageName = 'Closed Won'),
            (SELECT Id, Status_Reason__c, Type__c, Program_Enrollment__c
             FROM Enrollment_Documents__r),
            (SELECT Id,Program_Enrollment__c,Program_Enrollment__r.Start_Year__c,
             Final_Grade_Level__c,School_Year__c, HowStudentPlacementCompleted__c
             FROM Annual_Student_Information__r
             WHERE Final_Grade_Level__c <> Null),
            (SELECT Id, IEP__c, Plan504__c, Program_Enrollment__c, FormallyExitedIEP__c
             FROM Special_Educations__r)
            FROM hed__Program_Enrollment__c
            WHERE Id IN :progEnrollmentIds
        ];
        
        for (hed__Program_Enrollment__c progEnrollment : progEnrollments) {
            for (Annual_Student_Information__c studentInfo : progEnrollment.Annual_Student_Information__r) {
                if ((!String.IsBlank(studentInfo.School_Year__c) && !String.IsBlank(studentInfo.Program_Enrollment__r.Start_Year__c) &&
                     studentInfo.School_Year__c == studentInfo.Program_Enrollment__r.Start_Year__c) && !String.IsBlank(studentInfo.HowStudentPlacementCompleted__c)
                    && studentInfo.HowStudentPlacementCompleted__c.contains('Auto-Placement')) {
                        programEnrollmentToStudentInfoMap.put(studentInfo.Program_Enrollment__c, studentInfo);
                        
                    }
            }
            for (Enrollment_Document__c document : progEnrollment.Enrollment_Documents__r) {
                if (enrollmentDocumentMap.containsKey(document.Program_Enrollment__c)) {
                    enrollmentDocumentMap.get(document.Program_Enrollment__c).add(document);
                } else {
                    enrollmentDocumentMap.put(document.Program_Enrollment__c, new List<Enrollment_Document__c>{
                        document
                            });
                }
            }
            for (Special_Education__c specialEducation : progEnrollment.Special_Educations__r) {
                specialEducationMap.put(specialEducation.Program_Enrollment__c, specialEducation);
            }
            
        }
        System.debug('programEnrollmentToStudentInfoMap ::' + programEnrollmentToStudentInfoMap);
        System.debug('enrollmentDocumentMap ::' + enrollmentDocumentMap);
        System.debug('specialEducationMap ::' + specialEducationMap);
        
        
        // logic to be implement concatenate the string based on conditions
        for (hed__Program_Enrollment__c progEnrollment : progEnrollments) {
            String returnString = '';
            System.debug('progEnrollment=====>>>' + progEnrollment);
            if (!progEnrollmentsToCalculate.contains(progEnrollment.Id)) {
                logger.logInfo('calculateWhyFlagged', 'Not calculating WhyFlagged for '+progEnrollment.Id+' because not all requisite ECAs are complete');
                continue;
            }
            // programEnrollment's  condition based on PORFlag__c and  HHPORFlag__c values to add [Proof of Residency]- to return String
            //Mark Membrino 11/13/2019 Gap analysis Story 117691. 
            /*
if (progEnrollment.Status__c == 'Complete' && (
progEnrollment.HHPORFlag__c != null && (progEnrollment.HHPORFlag__c.contains('Pending') ||
progEnrollment.HHPORFlag__c.contains('Undeliverable Address')) || (
progEnrollment.PORFlag__c != null && (
progEnrollment.PORFlag__c.contains('Pending') ||
progEnrollment.PORFlag__c.contains('Undeliverable Address'))))) {
System.debug('[Proof of Residency]- Condition');
returnString += '[Proof of Residency]-';
}*/
            // programEnrollment's  condition based on Status__c and  Opportunities__r values to add  '' to return String
            else if ((!String.isBlank(progEnrollment.Status__c) && progEnrollment.Status__c == 'Complete') &&
                     progEnrollment.Opportunities__r.size() > 0) {
                         returnString += '';
                     }
            
            // programEnrollment's  condition based on progEnrollment.Id and  add ''
            else if (programEnrollmentToStudentInfoMap.containsKey(progEnrollment.Id) && programEnrollmentToStudentInfoMap.get(progEnrollment.Id) <> null) {
                returnString += '';
            }
            // programEnrollment's  condition based on PlacementFlag__c and  add '{Placement}-'  to return String
            else if ((!String.isBlank(progEnrollment.PlacementFlag__c) && progEnrollment.PlacementFlag__c <> 'Released')) {
                returnString += '{Placement}-';
            }
            Boolean shouldPass = false;
            // AnnualStudentInfo and program Grades condition based on Final_Grade_Level__c and Grade_Level__r.Name add '' to return String
            if (programEnrollmentToStudentInfoMap.containsKey(progEnrollment.Id) &&
                progGradesMap.containsKey(progEnrollment.hed__Account__c)) {
                    
                    System.debug('If GradeMap');
                    for (Program_Grade_Level__c progGrades : progGradesMap.get(progEnrollment.hed__Account__c)) {
                        if (programEnrollmentToStudentInfoMap.get(progEnrollment.Id).Final_Grade_Level__c == progGrades.Grade_Level__r.Name) {
                            returnString += '';
                            shouldPass = true;
                            break;
                        }
                    }
                }
            
            // only enter here if the ASI HowStudentPlacementCompleted does not contain Auto-Placement or
            // the PGL's AutoPlacement_SpecialEdExclude__c is true
            if (!shouldPass) {
                Boolean shouldIncludeSpecialEd = false;
                if (progEnrollment.hed__Account__r.Requires_Special_Education_Review__c == true && specialEducationMap.containsKey(progEnrollment.Id) && specialEducationMap.get(progEnrollment.Id).IEP__c != null && specialEducationMap.get(progEnrollment.Id).IEP__c != 'IEP') {
                    shouldIncludeSpecialEd = true;
                } else if (specialEducationMap.containsKey(progEnrollment.Id) && specialEducationMap.get(progEnrollment.Id).FormallyExitedIEP__c == 'Yes' ) {
                    shouldIncludeSpecialEd = true;  //If there is a spec ed rec and they formally exited, they have to have provided documentation
                    if (!progEnrollment.Enrollment_Documents__r.isEmpty()) {
                        for (Enrollment_Document__c ed : progEnrollment.Enrollment_Documents__r) {
                            if ((ed.Type__c == 'IEP Exit Documentation' 
                                 && ed.Status_Reason__c != null 
                                 && (new Set<String>{'Verified', 'Not Applicable', 'Verified-No Documentation Available'}).contains(ed.Status_Reason__c))
                                || (ed.Type__c == 'Re Eval Conference Form' 
                                    && ed.Status_Reason__c != null 
                                    && (new Set<String>{'Verified', 'Not Applicable'}).contains(ed.Status_Reason__c))) 
                            {//Documentation has been provided so they should not be flagged for spec ed.
                                shouldIncludeSpecialEd = false;
                                break;
                            }
                        }
                    }
                }
                
                
                if (shouldIncludeSpecialEd) {
                    returnString += '{Special Education}-';
                }
              
            }
            
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.  504 plan is no longer needed.
            //Set<String> statusList = new Set<String> {'504 Missing', 'Received', 'Received-No Documentation', 'Illegible'};
            //if (specialEducationMap.containsKey(progEnrollment.Id) && statusList.contains(specialEducationMap.get(progEnrollment.Id).Plan504__c)) {
            //    returnString += '{504 Plan}~';
            //}
            
            // Condition for progEnrollment based on CounselingFlag__c field to add Program Fit~
            if (!String.isBlank(progEnrollment.CounselingFlag__c) && progEnrollment.CounselingFlag__c == 'Stop') {
                returnString += '{Program Fit}-';
            }
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.  Eligibility is no longer needed.
            /*if (progEnrollment.EligibilityFlag__c != null && (new Set<String> {'Pending', 'Ineligible'}).contains(progEnrollment.EligibilityFlag__c)) {
returnString += '[Eligibility]-';
}*/
            // Condition for progEnrollment based on PriorWithdrawalFlag__c field to add [Prior Withdrawal]-
            //Mark Membrino 11/13/2019 Gap analysis Story 117691. 
            /*if (progEnrollment.Start_Year__r.Current_Year__c == true && progEnrollment.PriorWithdrawalFlag__c == 'Hold') {
returnString += '[Prior Withdrawal]-';
} */
            if (!String.isBlank(progEnrollment.WaitlistFlag__c) && new List<String>{
                'Active', 'In Review', 'Active-Reset'
                    } .contains(progEnrollment.WaitlistFlag__c)) {
                        returnString += '[Waitlisted]-';
                    }
            
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.
            //Commented Deprecate Technology flag logic for US 476956 
            /*if (!String.isBlank(progEnrollment.UserTechnologyFlag__c) && 
                (progEnrollment.UserTechnologyFlag__c == 'Pending Review' || progEnrollment.UserTechnologyFlag__c == 'Withdraw')) {
                    returnString += '[Technology]-';
                }*/
            //Added user story for US 476964
            if (!String.isBlank(progEnrollment.Foster_Flag__c) && progEnrollment.Foster_Flag__c == 'Pending Review') {
                returnString += '{Foster Flag}-';
            }else if (String.isBlank(progEnrollment.Foster_Flag__c) || progEnrollment.Foster_Flag__c == 'Released') {
                returnString += '';
            }
            //Ended user story for US 476964
            if (!String.isBlank(progEnrollment.DisciplinaryFlagOverride__c) &&
                (progEnrollment.DisciplinaryFlagOverride__c == 'Pending Review' || progEnrollment.DisciplinaryFlagOverride__c == 'Withdraw')) {
                    returnString += '[Disciplinary History]-';
                }
            if (!String.isBlank(progEnrollment.HomelessRiskFlag__c) && progEnrollment.HomelessRiskFlag__c == 'Potential Homeless') {
                returnString += '[Potential Homeless]-';
            }
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.
            if (!String.isBlank(progEnrollment.AddressEligibility__c) && progEnrollment.AddressEligibility__c <> 'Eligible')
                returnString += '[Address Eligibility]-';
            
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.
            /*if (String.isBlank(progEnrollment.PrincipalGeneralFlag__c) || progEnrollment.PrincipalGeneralFlag__c == 'Released' ||
progEnrollment.PrincipalGeneralFlag__c == 'Student requesting 12th grade after 1/1/19') {
returnString += '';
} else {
returnString += progEnrollment.PrincipalGeneralFlag__c;
}*/
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.
            /*if (!String.isBlank(progEnrollment.GradeLevelEligibility__c) && progEnrollment.GradeLevelEligibility__c != 'Allowed to Enroll') {
returnString += '{Grade Level Eligibility}-';
}*/
            if (!String.isBlank(progEnrollment.EntranceAgeEligibilityFinal__c) && progEnrollment.EntranceAgeEligibilityFinal__c <> 'Eligible')
                returnString += '{Age Eligibility}-';
            //Mark Membrino 11/13/2019 Gap analysis Story 117691.
            if (!String.isBlank(progEnrollment.AcademicPerformanceEligibility__c) && progEnrollment.AcademicPerformanceEligibility__c <> 'Allowed to Enroll')
                returnString += '{Academic Performance Eligibility}-';
            
            System.debug('returnString===>>>' + returnString);
            // Append return String to WhyFlagged__c field
            progEnrollment.WhyFlagged__c = returnString;
            progEnrollmentList.add(progEnrollment);
        }
        /*update the progEnrollmentList with WhyFlagged__c field
if (!progEnrollmentList.isEmpty()) {
try {
System.debug('Attempting to update');
update progEnrollmentList;
System.debug('After updating that list');

} catch (exception e) {
System.debug('***Exception***');
System.debug('Exception:' + e.getMessage());
logger.logException('calculateWhyFlagged', e);
}
}*/
        
        System.debug('Returning enrollment list');
        logger.saveLogs();
        return progEnrollmentList;
    }
    
    //137647 -Swapna For ReActivation Case
    public static void reActivationCase(Set<Id> ReactivationPEList){
        List<Case> caselist = new List<Case>();
       // Case c = new Case();  // Commented and added below for defect 433373
        //SOQL replaced by a call to GenericSOQLQueries for 430196 on 2021-08-04 by Ravichandra Amirshetty
        //            RecordType r = [select Id from RecordType where Name ='Enrollment Support'];
        // for(hed__Program_Enrollment__c pe : [SELECT hed__Contact__c,hed__Contact__r.Name,hed__Contact__r.Account.hed__Primary_Contact__c from hed__Program_Enrollment__c where Id IN : ReactivationPEList]){
        for(hed__Program_Enrollment__c pe : GenericSOQLQueries.programEnrollmentDetails(ReactivationPEList)){     
            // c.AccountId = pe.hed__Contact__r.AccountId;
            Case c = new Case(); // Added by Maddileti for defect 433373
            c.ContactId = pe.hed__Contact__r.Account.hed__Primary_Contact__c; 
            c.Type = 'Enrollment Assistance';
            c.Ticket_Type__c='Account Review';
            c.Ticket_Sub_Type__c='Reactivation';
            c.Platform__c = 'Pearson Connexus';
            c.Description = 'ReActivation Case';
            c.Subject = 'ReActivation Case'+ ' ' + '-' + pe.hed__Contact__r.Name;
            // c.RecordTypeId = r.Id;
            c.Origin = 'Enrollment Community'; //Mohammad Shaik-Based on picklist value api name change for US : 183731
            caselist.add(c);
            
        }
        insert caselist;
        
    }
    
    
    //476964 - Niranjan for Foster Flag
    public static void calculateFosterFlag(list<Student_Custody__c> custodyList){
        system.debug('==>custodyList '+custodyList);
        set<Id> peIds = new set<Id>();
        set<Id> fosterPEIds = new set<Id>();
        list<string> fosterFlgVal = new list<string>();
        
        for(Student_Custody__c custRel : custodyList){
            if(custRel.Custody_Relationship__c == null || !custRel.Custody_Relationship__c.contains('Foster')){
                peIds.add(custRel.Program_Enrollment__c);
            }else if(custRel.Custody_Relationship__c.contains('Foster')){
                fosterPEIds.add(custRel.Program_Enrollment__c);
                fosterFlgVal.add(custRel.Custody_Relationship__c);
            }
        }
	    
       list<hed__Program_Enrollment__c> pgrmEnrollList = new list<hed__Program_Enrollment__c>();
       Map<Id,hed__Program_Enrollment__c> peEnrollMapRec = new Map<Id,hed__Program_Enrollment__c>([SELECT id,Foster_Flag__c from hed__Program_Enrollment__c where Id IN:fosterPEIds]);
       
        if(peIds.size() > 0 && fosterFlgVal.size() == 0){
            list<hed__Program_Enrollment__c> lstPE = [SELECT id,Foster_Flag__c from hed__Program_Enrollment__c where Id IN:peIds];
            for(hed__Program_Enrollment__c pe : lstPE){
                pe.Foster_Flag__c = '';
                pgrmEnrollList.add(pe);
            }
        }
        
        for(hed__Program_Enrollment__c pe : peEnrollMapRec.values()){
            if(!peEnrollMapRec.isEmpty()){
                if(pe.Foster_Flag__c != 'Pending Review' && fosterFlgVal.size() >= 1){
                    pe.Foster_Flag__c = 'Pending Review';
                    pgrmEnrollList.add(pe);
                }
            }
        }
        
        if(pgrmEnrollList.size() > 0){
            update pgrmEnrollList;
        }
    }
    
}