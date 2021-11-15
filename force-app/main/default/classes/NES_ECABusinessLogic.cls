/**
* Change Log: Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-06
* Purpose   : This method is used to Set status of PEs based on enrollment document statuses
* Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
* Added logic for Waitlist for the bug 119931 (Anitha P) on 11/22/19
* Change Log: 2019-11-21 modified for #119349 User Story by Anitha P
* Added logic for Waitlist for the bug 119931 (Anitha P) on 12/09/19
* Added logic for Waitlist for the bug 122591 (Anitha P) on 12/12/19
* Created method handleHouseHoldECAsInProgress for Bug #141724 (Krishna Peddanagammol) on 2020-03-06 
Hello World!
**/
@SuppressWarnings('ApexUnresolvableReference')
public without sharing class NES_ECABusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('ECABusinessLogic'); 
    
    //Code commented for this US 121803 for Task 121870   
    /* public static List<Annual_Student_Information__c> calculatePlacementScore(List<Id> programEnrollmentIds, List<Annual_Student_Information__c> asis){

// Get all AnnualStudentInformation,Academic Information form programEnrollment
Map<Id, hed__Program_Enrollment__c> ProgramEnrollments = new Map<Id, hed__Program_Enrollment__c>([
SELECT
Start_Year__r.Start_Date__c,
PlacementFlag__c,
EntranceAgeEligibilitySystem__c,
EntranceAgeEligibilityOverride__c,
EntranceAgeEligibilityFinal__c,
WhyFlagged__c,
First_Yr_Complete_HS_Coursework__c,
hed__Credits_Attempted__c,
hed__Contact__c,
hed__Contact__r.Birthdate__c,
Credit_for_HS_Coursework__c,
SIF_AcademicSupportNeeds__c,
SIFStudentRetained__c,
Academic_Doc_Performance__c,
SIF_SummerSchoolCourses__c,
hed__Account__r.AutomatedPlacementExclude__c,
hed__Account__c, (
SELECT
Id,
School_Year__c,
SchoolType__c,
Program_Enrollment__c
FROM Prior_Schools__r
ORDER BY CreatedDate DESC
), (
SELECT
Id,
IEPHistory__c,
Plan504Exit__c,
Plan504History__c,
EvaluatedWithInLastYear__c
FROM Special_Educations__r
ORDER BY CreatedDate DESC
LIMIT 1
)
FROM hed__Program_Enrollment__c
WHERE Id IN:programEnrollmentIds
]);

/* if Annual Student Information school Start Date is equal to programEnrollment school Start Date then
populate studentInformationMap with Enrollment Id and Student Information object */
    
    /*      Map<Id, Annual_Student_Information__c> studentInformationMap = new Map<Id, Annual_Student_Information__c>();
if (!ProgramEnrollments.isEmpty()) {

for (hed__Program_Enrollment__c prEn : ProgramEnrollments.values()) {
System.debug(prEn);
System.debug(asis);
if (asis != null && asis.size() > 0) {
for (Annual_Student_Information__c studInfo : asis) {
if (studInfo.School_Year__c == prEN.Start_Year__c && studInfo.Program_Enrollment__c == prEn.Id) {
studentInformationMap.put(prEn.Id, studInfo);

}
}
} else {
for (Annual_Student_Information__c studInfo : prEn.Annual_Student_Information__r) {
if (studInfo.School_Year__c == prEN.Start_Year__c) {
studentInformationMap.put(prEn.Id, studInfo);

}
}
}
}
}

List<Annual_Student_Information__c> studentInfoList = new List<Annual_Student_Information__c>();
System.debug('studentInformationMap###' + studentInformationMap);
// AutoPlacement Conditional Check for Each EnrollmentId
for (Id EnrollmentId : ProgramEnrollments.keySet()) {
Integer returnValue = 0;

Integer GradeLevelRequested = 0;
List<String> academicSupportValues = new List<String>();
if (ProgramEnrollments.get(EnrollmentId).SIF_AcademicSupportNeeds__c != null) {
academicSupportValues.addAll(ProgramEnrollments.get(EnrollmentId).SIF_AcademicSupportNeeds__c.split(';'));
}
if (studentInformationMap.containsKey(EnrollmentId) && studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null) {
if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c == 'K' || studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c == 'Kindergarten') {
GradeLevelRequested = 0;
} else {
GradeLevelRequested = Integer.valueOf(studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c);
}

}

if(ProgramEnrollments.get(EnrollmentId) != null && studentInformationMap.get(EnrollmentId) != null) {
if (ProgramEnrollments.get(EnrollmentId).hed__Contact__r.Birthdate__c != null && !String.isBlank(studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c)) {
Integer age = NES_AnnualStudentInformationUtilities.calculateAge(ProgramEnrollments.get(EnrollmentId).hed__Contact__r.Birthdate__c);
if(age - GradeLevelRequested <= 4 || age - GradeLevelRequested >= 6){
returnValue += 4;
}
}
}

if (!academicSupportValues.contains('None') && academicSupportValues.size() > 2 && academicSupportValues != null) {
returnValue += 5;
}
if (!academicSupportValues.contains('None') && academicSupportValues.size() <= 2 && academicSupportValues.size() > 0 &&
academicSupportValues != null) {
returnValue += 2;
}
if (ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c != null &&
(ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c == 'Yes' || ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c == 'Unsure')) {
returnValue += 1;
}
if (ProgramEnrollments.get(EnrollmentId).SIFStudentRetained__c == 'Yes') {
returnValue += 3;
}
if (ProgramEnrollments.get(EnrollmentId).Academic_Doc_Performance__c != 'Yes') {
returnValue += 1;
}
if (!ProgramEnrollments.get(EnrollmentId).Prior_Schools__r.isEmpty()) {

for(Prior_School__c ps : ProgramEnrollments.get(EnrollmentId).Prior_Schools__r) {
if(ps.SchoolType__c == 'Homeschool') {
returnValue += 1;
break;
}
}
}
if (!ProgramEnrollments.get(EnrollmentId).Special_Educations__r.isEmpty() &&
(ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].IEPHistory__c == 'Yes' ||
ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].Plan504History__c == 'Yes' ||
ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].Plan504Exit__c == 'Yes' ||
ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].EvaluatedWithInLastYear__c == 'Yes')) {
returnValue += 2;
}
if(studentInformationMap.containsKey(EnrollmentId)) {
if ( (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c != '') &&
GradeLevelRequested == 7) {
returnValue += 2;
} else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && (GradeLevelRequested == 8 || GradeLevelRequested == 9)) {
returnValue += 3;
} else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && GradeLevelRequested > 2 && GradeLevelRequested < 7) {
returnValue += 1;
} else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && GradeLevelRequested < 3) {
returnValue -= 20;
}
studentInformationMap.get(EnrollmentId).AutomatedPlacementScore__c = returnValue;
System.debug('Final ASI' + studentInformationMap.get(EnrollmentId));
studentInfoList.add(studentInformationMap.get(EnrollmentId));
}
}
return studentInfoList;
}*/
    
    //Code commented for this US 121803 for Task 121870
    /**
* Created By Raju on 20-12-2018.
* purpose :This method is used to update the WaitList_Added_Time__c field on the Opportunity when ECA fired on after Update
* Params :List<Enrollment_Component_Affiliation__c> newList,, Map<Id, Enrollment_Component_Affiliation__c> oldMap
*/
    
    public static void filterWaitListECARecords(List<Enrollment_Component_Affiliation__c> newList, Map<Id, Enrollment_Component_Affiliation__c> oldMap) {
        
        Set<Id> ecaIdSet = new Set<Id>();
        for (Enrollment_Component_Affiliation__c ecaRecord : newList) {
            
            if (oldMap == null) {
                if (ecaRecord.Status__c == 'In Progress') {
                    
                    ecaIdSet.add(ecaRecord.Id);
                }
            } else {
                if (oldMap.get(ecaRecord.Id) != null && ecaRecord.Status__c != oldMap.get(ecaRecord.Id).Status__c && ecaRecord.Status__c == 'In Progress') {
                    ecaIdSet.add(ecaRecord.Id);
                }
            }
        }
        
        
        if (ecaIdSet.size() > 0) {
            updateWaitListAddedTimeOnOpportunity(ecaIdSet);
        }
    }
    
    /**
* Created By Raju on 20-12-2018.
* purpose :This method is used to update the WaitList_Added_Time__c field on the Opportunity when ECA fired on after insert and after Update
* Params :Set<Id> ecaIdSet
*/
    public static void updateWaitListAddedTimeOnOpportunity(Set<Id> ecaIdSet) {
        Set<Id> peIdSet = new Set<Id>();
        //SOQL replaced by a call to GenericSOQLQueries for 430196 on 2021-08-09 by Krishna Peddanagammol
        /*for (Enrollment_Component_Affiliation__c ecaRecord : [
            SELECT Id,
            Enrollment_Component__r.Waitlist__c,
            Enrollment_Component__r.RecordType.Name,
            Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Id IN:ecaIdSet
        ])*/
        for (Enrollment_Component_Affiliation__c ecaRecord : GenericSOQLQueries.ecaDetails(ecaIdSet)) 
        {
            if (ecaRecord.Enrollment_Component__c != null &&
                ecaRecord.Enrollment_Component__r.RecordType.Name == 'Stage' &&
                ecaRecord.Enrollment_Component__r.Waitlist__c == true) {
                    peIdSet.add(ecaRecord.Program_Enrollment__c);
                }
            
        }
        
        
        if (peIdSet.size() > 0) {
            List<Opportunity> oppList = new List<Opportunity>();
            for (Opportunity oppRecord : [SELECT Id,WaitList_Added_Time__c FROM Opportunity WHERE StageName = 'Open' AND Program_Enrollment__c = :peIdSet]) {
                oppRecord.WaitList_Added_Time__c = System.now();
                oppList.add(oppRecord);
            }
            
            if (oppList.size() > 0) {
                try {
                    update oppList;
                } catch (Exception ex) {
                    System.debug('Error: ' + ex.getMessage());
                    logger.logException('updateWaitListAddedTimeOnOpportunity', ex);
                    logger.saveLogs();
                }
                
            }
        }
    }
    
    /**
* @author: Ali KM created on 01-21-2020 for [US 122106]
* @purpose : This method runs the ECA Completion logic to re-evaluate 'Complete' sections/forms when an ECA.Status = 'Not Applicable'
* @parms: ECA that needs to be re-evaluated.
*/
    public static void runECACompletionForNAStatus(Enrollment_Component_Affiliation__c naECA) { // List<Enrollment_Component_Affiliation__c> naECAs
        
        Id programEnrollmentId = naECA.Program_Enrollment__c;
        Id sectionECRecTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Section').getRecordTypeId();
        //Bug #227705 Date: 9/22/2020 Krishna Peddanagammol : Store EC Document Record Type Id in documentECRecTypeId 
        Id documentECRecTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Document').getRecordTypeId();
            
        Id sectionId = null;
        // refresh the eca
        naECA = [Select Id, Program_Enrollment__c, Enrollment_Component__c, Enrollment_Component__r.RecordTypeId from Enrollment_Component_Affiliation__c where Id = : naECA.Id];
        //Bug #227705 Date: 9/22/2020 Krishna Peddanagammol Added else if condition to fetch Document Record Type Id           
        if (naECA.Enrollment_Component__r.RecordTypeId == sectionECRecTypeId) {
            sectionId = naECA.Enrollment_Component__c;
        }else if(naECA.Enrollment_Component__r.RecordTypeId == documentECRecTypeId){
            sectionId = naECA.Enrollment_Component__c;
        }
        
        // if sectionId is null, don't proceed
        if (sectionId == null) {
            return ;
        }
        
        List<Enrollment_Component_Affiliation__c> newAffiliations = [
            SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
            Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c = :programEnrollmentId
        ];
        Map<Id, Enrollment_Component_Affiliation__c> newAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
        list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();//added by anitha p
        
        for (Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
            newAffiliationMap.put(newAffiliation.Enrollment_Component__c, newAffiliation);
            thisStudentsECAs.add(newAffiliation);//added by anitha p
        }
        
        hed__Program_Enrollment__c  studentEnrollment = [
            SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
            FROM hed__Program_Enrollment__c
            WHERE Id = :programEnrollmentId
        ];
        
        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);
        
        // print the params
        System.debug(naECA + ':::' + JSON.serialize(naECA));
        System.debug(programEnrollmentId + ':::' + JSON.serialize(programEnrollmentId));
        System.debug(processId + ':::' + JSON.serialize(processId));
        System.debug(sectionECRecTypeId + ':::' + JSON.serialize(sectionECRecTypeId));
        System.debug(sectionId + ':::' + JSON.serialize(sectionId));
        System.debug(newAffiliations + ':::' + JSON.serialize(newAffiliations));
        System.debug(thisStudentsECAs + ':::' + JSON.serialize(thisStudentsECAs));
        System.debug(studentEnrollment + ':::' + JSON.serialize(studentEnrollment));
        
        NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);//added by anitha p
    }    
    
    
    /**
* Created By Ritvik on 21-12-2018.
* Update by Alex Chisholm on 11/9/2019
* Purpose : Determines if the student has provided enough information to be placed and updates hed__program_enrollment__c.isPlacementReady__c if they have
* Params : List<Enrollment_Component_Affiliation__c> of updated ECA record.
* Return type : @void
*/
    public static void runPlacementProcess(List<Enrollment_Component_Affiliation__c> newList) {
        system.debug('in ECA runPlacementProcess evaluation');
        Set<Id> progEnrollIds = new Set<Id>();            
        
        /* Build a list of PE ids where the status is Complete and the related EC was required for placement. 
** We only need to evalaute whether the student is Placement Ready when a relevant  section is submitted.*/
        for(Enrollment_Component_Affiliation__c affiliation : newList) {
            if(affiliation.status__c == 'Complete'){
                progEnrollIds.add(affiliation.Program_Enrollment__c);
            }
        }
        
        /* Continue evaluating the updates if there are Completed PEs*/
        if(!progEnrollIds.isEmpty()){
            
            system.debug('there are completed ECAs');
            
            /* Find all assigned ECAs that are required to complete for AutoPlacement*/
            List<Enrollment_Component_Affiliation__c> affiliations = [
                SELECT Id,Enrollment_Component__c, Status__c, Program_Enrollment__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = TRUE
                and Status__c <> 'Not Applicable'
                AND Program_Enrollment__c IN : progEnrollIds
            ];   
            
            system.debug('ECAs required for autoplacement' + affiliations);    
            
            /* Determine if all assigned ECAs are complete */
            Map<Id, boolean> completionMap = new Map<Id, boolean>();
            for(Enrollment_Component_Affiliation__c affiliation : affiliations) {
                if(affiliation.status__c != 'Complete'){
                    completionMap.put(affiliation.Program_Enrollment__c,false);
                }
                
            }
            
            /*Build a set of the ids where all of their ECAs were complete*/
            Set<Id> pesProcess = new Set<Id>();
            for (Id programEnrollmentId : progEnrollIds) {
                if(!completionMap.containsKey(programEnrollmentID)){
                    pesProcess.add(programEnrollmentID);
                }
            }
            
            /*Select the PEs and mark them ready for placement*/
            list<hed__program_enrollment__c> updatedPEs = new list<hed__program_enrollment__c>([
                SELECT Id, isPlacementReady__c 
                FROM hed__program_enrollment__c 
                WHERE id in: pesProcess]);
            
            for(hed__program_enrollment__c pe : updatedPEs){
                pe.isPlacementReady__c = true;
            }
            
            try {
                update updatedPEs;
            } 
            catch (Exception ex) {
                System.debug('Exception Thrown : ' + ex.getMessage());
                logger.logException('updateisPlacementReady', ex);
                logger.saveLogs();
            }
            
            /*
Removed 11/9/2019 - Alex
Map<Id, List<Enrollment_Component_Affiliation__c>> affiliationMap = new Map<Id, List<Enrollment_Component_Affiliation__c>>();
for(Enrollment_Component_Affiliation__c affiliation : affiliations) {
List<Enrollment_Component_Affiliation__c> tempAffiliations = new List<Enrollment_Component_Affiliation__c>();
if(affiliationMap.containsKey(affiliation.Program_Enrollment__c)) {
tempAffiliations = affiliationMap.get(affiliation.Program_Enrollment__c);
}
tempAffiliations.add(affiliation);
affiliationMap.put(affiliation.Program_Enrollment__c, tempAffiliations);
}
Set<Id> pesProcess = new Set<Id>();
for (Id programEnrollmentId : affiliationMap.keySet()) {
Boolean isComplete = true;
for(Enrollment_Component_Affiliation__c affiliation : affiliationMap.get(programEnrollmentId)) {

if(affiliation.Status__c != 'Complete') {
isComplete = false;
break;
}
}
if(isComplete) {
pesProcess.add(programEnrollmentId);
}
}

if (!pesProcess.isEmpty()) {
List<Annual_Student_Information__c> asis = [
SELECT Id, Program_Enrollment__c,Academic_Documentation_Summary__c,School_Year__r.Start_Date__c,
LA_Placement_Level__c, HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c,
Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c, Final_Grade_Level__c,
GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c, School_Year__c
FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN: pesProcess];
List<Id> asiIds = new List<Id>();
for(Annual_Student_Information__c asi : asis) {
asiIds.add(asi.Id);
}
if(asiIds.size() > 0) {
System.enqueueJob(new NES_PlacementQueueable(asiIds));
}
}*/
        }
    }
 
    
    /**
* Created By Ajith on 28-12-2018.
* purpose : Validate Phone Number type Field by using a callout to external service and store the values accordingly
*           in the Phone Number Validated Field on the Enrollment Component record.
* Params : newList of updated ECA record.
*/
    public static void validatePhoneType(List<Enrollment_Component_Affiliation__c> ecaList) {
        
        List<Id> validECAIds = new List<Id>();
        for (Enrollment_Component_Affiliation__c eca : ecaList) {
            if (eca.Enrollment_Component__r.Phone_Type_Field__c != null && eca.Enrollment_Component__r.Phone_Number_Validated_Field__c != null
                && eca.Enrollment_Component__r.Answer_Target__c != null && eca.Status__c == 'Complete') {
                    if (eca.Enrollment_Component__r.Question_Type__c == 'Phone') {
                        validECAIds.add(eca.Id);
                    }
                }
        }
        
        if (validECAIds.size() > 0) {
            validatePhone(validECAIds);
        }
    }
    
    
    /**
* Created By Ajith on 31-12-2018.
* purpose : Expose this method for Global Phone Validate API callout purpose
*           Based on the response values put the values in the phone validated fields on the EC
*/
    
    @Future(Callout=true)
    public static void validatePhone(List<Id> ecaIds) {
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : [
            SELECT Id, Status__c, Enrollment_Component__c, Enrollment_Component__r.Phone_Type_Field__c,
            Enrollment_Component__r.Phone_Number_Validated_Field__c, Enrollment_Component__r.Question_Type__c,
            Enrollment_Component__r.Question_Target__c, Enrollment_Component__r.Answer_Target__c,
            Program_Enrollment__r.hed__Contact__r.AccountId, Program_Enrollment__r.hed__Contact__c, Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Id IN :ecaIds
        ]) {
            
            if (eca.Enrollment_Component__r.Phone_Type_Field__c != null && eca.Enrollment_Component__r.Phone_Number_Validated_Field__c != null
                && eca.Enrollment_Component__r.Answer_Target__c != null && eca.Status__c == 'Complete') {
                    if (eca.Enrollment_Component__r.Question_Type__c == 'Phone') {
                        enrollmentComponentAffiliations.add(eca);
                    }
                }
            
        }
        
        Map<Long, Enrollment_Component_Affiliation__c> phoneToECAMap = new Map<Long, Enrollment_Component_Affiliation__c>();
        if (enrollmentComponentAffiliations.size() > 0) {
            phoneToECAMap = NES_ECUtilities.configureQuery(enrollmentComponentAffiliations);
        }
        
        if (!phoneToECAMap.keySet().isEmpty()) {
            
            List<NES_ECUtilities.phoneValidatorWrap> phoneWrapList = new List<NES_ECUtilities.phoneValidatorWrap>();
            Map<Enrollment_Component_Affiliation__c, NES_ECUtilities.GlobalPhoneInfo> ecaToResponseMap = new Map<Enrollment_Component_Affiliation__c, NES_ECUtilities.GlobalPhoneInfo>();
            for (Long phoneNo : phoneToECAMap.keySet()) {
                phoneWrapList.add(new NES_ECUtilities.phoneValidatorWrap(phoneNo, '+1'));
                
                String requestBody = JSON.serialize(new NES_ECUtilities.phoneValidatorWrap(phoneNo, '+1')).replaceAll('NumberKey', 'Number');
                try {
                    
                    HttpResponse response = NES_ECUtilities.createHttpRequestForPhoneData('POST', 'https://api.experianmarketingservices.com/sync/queryresult/PhoneValidate/1.0/',
                                                                                          '0fef8f0d-e5d7-4f6b-a74c-8c9ad6516750', requestBody);
                    
                    String clientResponse = response.getBody().replaceAll('Number', 'phoneKey');
                    
                    System.debug('sysresponse' + clientResponse);
                    
                    NES_ECUtilities.GlobalPhoneInfo globalInfoRec = (NES_ECUtilities.GlobalPhoneInfo) JSON.deserialize(clientResponse, NES_ECUtilities.GlobalPhoneInfo.class);
                    
                    if (phoneToECAMap.get(globalInfoRec.phoneKey) != null) {
                        ecaToResponseMap.put(phoneToECAMap.get(globalInfoRec.phoneKey), globalInfoRec);
                    }
                } catch (System.CalloutException e) {
                    System.debug('Callout error: ' + e);
                    logger.logException('validatePhone', e);
                    logger.saveLogs();
                }
            }
            
            if (!ecaToResponseMap.isEmpty()) {
                updateSObjects(ecaToResponseMap);
            }
        }
    }
    
    /**
* Created By Ajith on 01-16-2018.
* purpose : This method is called to update the SObject and fields based on the Phone Type and Phone Number
*           fields from the ECA based on the Integration responses.
*/
    
    public static void updateSObjects(Map<Enrollment_Component_Affiliation__c, NES_ECUtilities.GlobalPhoneInfo> ecaToResponseMap) {
        List<SObject> sObjectsToUpdate = new List<SObject>();
        if (!ecaToResponseMap.isEmpty()) {
            for (Enrollment_Component_Affiliation__c eca : ecaToResponseMap.keySet()) {
                if (eca.Enrollment_Component__r.Phone_Number_Validated_Field__c != null && eca.Enrollment_Component__r.Phone_Type_Field__c != null) {
                    
                    String phoneNumberData = eca.Enrollment_Component__r.Phone_Number_Validated_Field__c;
                    String phoneTypeData = eca.Enrollment_Component__r.Phone_Type_Field__c;
                    //Split the Target field to get the Object and Field API Names
                    String phoneNumber_ObjectApiName = phoneNumberData.substring(0, phoneNumberData.indexOf('.'));
                    String phoneNumber_FieldApiName = phoneNumberData.substring(phoneNumberData.indexOf('.') + 1, phoneNumberData.length());
                    
                    String phoneType_ObjectApiName = phoneTypeData.substring(0, phoneTypeData.indexOf('.'));
                    String phoneType_FieldApiName = phoneTypeData.substring(phoneTypeData.indexOf('.') + 1, phoneTypeData.length());
                    
                    if (phoneNumber_ObjectApiName == phoneType_ObjectApiName) {
                        String objectApiName = phoneNumber_ObjectApiName;
                        String query;
                        if (objectApiName == 'Account') {
                            query = 'SELECT Id, ' + phoneNumber_FieldApiName + ',' + phoneType_FieldApiName + ' FROM Account WHERE Id = \'' + eca.Program_Enrollment__r.hed__Contact__r.AccountId + '\' ';
                        } else if (objectApiName == 'Contact') {
                            query = 'SELECT Id, ' + phoneNumber_FieldApiName + ',' + phoneType_FieldApiName + ' FROM Contact WHERE Id = \'' + eca.Program_Enrollment__r.hed__Contact__c + '\' ';
                        } else if (objectApiName == 'hed__Program_Enrollment__c') {
                            query = 'SELECT Id, ' + phoneNumber_FieldApiName + ',' + phoneType_FieldApiName + ' FROM hed__Program_Enrollment__c WHERE Id = \'' + eca.Program_Enrollment__c + '\' ';
                        } else {
                            query = 'SELECT Id, ' + phoneNumber_FieldApiName + ',' + phoneType_FieldApiName + ' FROM ' + objectApiName + ' WHERE Program_Enrollment__c = \'' + eca.Program_Enrollment__c + '\' ';
                        }
                        if (String.isNotBlank(query)) {
                            query += ' LIMIT 1 ';
                            List<SObject> childRecords = new List<SObject>();
                            System.debug(query);
                            query.remove('(');
                            query.remove(')');
                            
                            //Query the Records
                            childRecords = Database.query(query);
                            if (!childRecords.isEmpty()) {
                                SObject childRecord = childRecords[0];
                                childRecord.put(phoneNumber_FieldApiName, ecaToResponseMap.get(eca).PhoneType);
                                childRecord.put(phoneType_FieldApiName, ecaToResponseMap.get(eca).Certainty);
                                sObjectsToUpdate.add(childRecord);
                            }
                        }
                    }
                }
            }
            
            if (sObjectsToUpdate.size() > 0) {
                try {
                    update sObjectsToUpdate;
                } catch (Exception ex) {
                    System.debug('Exception Thrown : ' + ex.getMessage());
                    logger.logException('updateSObjects', ex);
                    logger.saveLogs();
                }
            }
        }
        
    }
    
    /**
* Change Log: 2019-08-13 modified for #101935 User Story ,Task 104310 by Anitha P 
* Purpose   : This method is used to Set status of Parent ECA and repective ECA stage,  when the ECA status of child component 
*             changed from 'Completed' to 'In progress' or 'Not started'.
**/
    public static void updateAllParentECAsStatus(List<Enrollment_Component_Affiliation__c> newList) {
        system.debug('newList'+newList);
        system.debug('executed once');
        //Call  UpdateAllECAS method  and pass all the ECAS's whose status is changed 
        list<Enrollment_Component_Affiliation__c> updatedlist =   updateAllECAS( newList );
        
        list<Enrollment_Component_Affiliation__c> changedECAs =   new  list<Enrollment_Component_Affiliation__c>();
        list<Id> householdprogEnrollIds = new list<Id>();
        list<Id> accountIds = new list<Id>();
        list<Id> householdEnrollIds = new list<Id>();
        list<Id> studentEnrollIds = new list<Id>();
        set<id> studentprogramIds = new set<id>();
        if (updatedlist.size()>0){
            for (Enrollment_Component_Affiliation__c updatedlistrecord : updatedlist){
                HouseholdEnrollIDs.add(updatedlistrecord.Enrollment_Component__c);
                HouseholdprogEnrollIds.add(updatedlistrecord.Program_Enrollment__r.Household_Program_Enrollment__r.id);
                AccountIds.add(updatedlistrecord.Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id);
                
            }
            //Fetch all the other Program enrollments who share same Household_Program_Enrollment__c of changed ECA
            for ( hed__Program_Enrollment__c studentProgramid : [SELECT hed__Account__c,hed__Contact__c,Status__c ,hed__Enrollment_Status__c,Household_Program_Enrollment__c,
                                                                 Id,IEP__c,RecordTypeId ,Program_Enrollment__c,Household_Program_Enrollment__r.hed__Account__r.recordtype.Name,recordtype.name 
                                                                 FROM hed__Program_Enrollment__c where Household_Program_Enrollment__c IN :HouseholdprogEnrollIds and 
                                                                 hed__Account__c IN :AccountIds and
                                                                 Status__c = 'In Progress' and
                                                                 Program_Enrollment__c NOT IN : StudentprogramIds and
                                                                 Household_Program_Enrollment__r.hed__Account__r.recordtype.Name = 'Academic Program'])
            {
                StudentEnrollIds.add(studentProgramid.ID);
                
            }
            
            //Fetch ECA"s of the PE's who share same Household_Program_Enrollment__c of changed ECA
            //Added Program_Enrollment__r.Status__c field in SOQL query for the bug 328454 on 10/30/2020
            for (Enrollment_Component_Affiliation__c affiliationRecord :[
                SELECT Id,Enrollment_Component__c,
                Status__c, Order__c,Program_Enrollment__c,Program_Enrollment__r.Status__c,Program_Enrollment__r.Household_Program_Enrollment__r.id,
                Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id,
                Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.recordtype.Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Enrollment_Component__c IN : HouseholdEnrollIDs and
                Program_Enrollment__c IN : StudentEnrollIds
            ]) {
                for (Enrollment_Component_Affiliation__c updatedlistrecord : updatedlist){
                    //Check all relevant conditions to change the respective PE'S ECA 
                    if(affiliationRecord.Program_Enrollment__R.Household_Program_Enrollment__r.id == updatedlistrecord.Program_Enrollment__r.Household_Program_Enrollment__r.id && 
                       affiliationRecord.Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id == updatedlistrecord.Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id &&
                       affiliationRecord.Enrollment_Component__c == updatedlistrecord.Enrollment_Component__c)  {
                           if ( affiliationRecord.Program_Enrollment__c != updatedlistrecord.Program_Enrollment__c ){
                               changedECAs.add(affiliationRecord);                          
                           }
                       }                
                }
            }
            //Call  UpdateAllECAS method  and pass all the ECAS's of PE's who share same  Household_Program_Enrollment__c of changed ECA
            if (changedECAs.size()>0){
                list<Enrollment_Component_Affiliation__c> finalupdatedlist =   updateAllECAS( changedECAs );
            }
        }  
    }
    
    /**
* Change Log: 2019-11-21 modified for #119349 User Story by Mark Membrino
* Change Log: 2020-03-17 modified for #141724 User Story by Krishna Peddanagammol
* Purpose   : This method is used to Set status of a new ECA to complete/In Progress if the same household component has already completed/In Progress for a sibling respectively.
**/
    public static void completeHouseHoldECAsAlreadyClosed(List<Enrollment_Component_Affiliation__c> newList) {
        set<Id> householdprogEnrollIds = new set<Id>();
        set<Id> householdEnrollIds = new set<Id>();
        set<Id> studentEnrollIds = new set<Id>();
        set<Id> progEnrollIds = new set<Id>();
        set<id> hhEcsList = new set<id>();
        map<id,Enrollment_Component_Affiliation__c> ectoecamap = new  map<id,Enrollment_Component_Affiliation__c>();
        list<Enrollment_Component_Affiliation__c> hhecalist = new list<Enrollment_Component_Affiliation__c>();
        System.debug('newList=>'+newList);
        System.debug('newList.size()=>'+newList.size());
        // get PE's of the all ECA's
        if (newList.size()>0){
            for (Enrollment_Component_Affiliation__c affiliation:newList){
                //if (affiliation.Status__c !='Complete' && affiliation.Status__c !='In Progress'){
                    progEnrollIds.add(affiliation.Program_Enrollment__c);                                                            
                //}
                HouseholdEnrollIDs.add(affiliation.Enrollment_Component__c);                                                  
            }
            System.debug('progEnrollIds=>'+progEnrollIds);
            System.debug('HouseholdEnrollIDs=>'+HouseholdEnrollIDs);
            System.debug('HouseholdEnrollIDs.size()=>'+HouseholdEnrollIDs.size());
            //Fetch House Hold of the Student PEs
            for(hed__Program_Enrollment__c progId : [SELECT Household_Program_Enrollment__c,Id                                                            
                                                     FROM hed__Program_Enrollment__c where ID IN :progEnrollIds 
                                                     and RecordType.Name = 'Student']) {
                                                         HouseholdprogEnrollIds.add(progId.Household_Program_Enrollment__c);
                                                     }
            System.debug('HouseholdprogEnrollIds=>'+HouseholdprogEnrollIds);
            //Get the HouseHold EC of the PEs
            for(Enrollment_Component__c ecList: [SELECT Id FROM Enrollment_Component__c where ID IN : HouseholdEnrollIDs
                                                 and Component_Type__c= 'Household']) {
                                                     hhEcsList.add(ecList.Id);
                                                 }          
            System.debug('hhEcsList=>'+hhEcsList);
            System.debug('hhEcsList.size()=>'+hhEcsList.size());
            //Fetch all the other Program enrollments who share same Household_Program_Enrollment__c of changed ECA
            if (HouseholdprogEnrollIds.size()>0){
                for ( hed__Program_Enrollment__c studentProgramid : [SELECT id FROM hed__Program_Enrollment__c where Household_Program_Enrollment__c IN :HouseholdprogEnrollIds 
                                                                     and RecordType.Name = 'Student']){
                    studentEnrollIds.add(studentProgramid.ID);
                }
            }
            System.debug('studentEnrollIds=>'+studentEnrollIds);
            System.debug('studentEnrollIds.size()=>'+studentEnrollIds.size());
            //Fecth ECA's of PE's who are in the same house hold and having same ECs       
            if (StudentEnrollIds.size()>0 && hhEcsList.size()>0){    
                for(Enrollment_Component_Affiliation__c affiliationRecord :[SELECT Id,Enrollment_Component__c,
                                                                            Status__c, Program_Enrollment__r.Household_Program_Enrollment__r.id
                                                                            FROM Enrollment_Component_Affiliation__c                                                          
                                                                            WHERE Program_Enrollment__r.Household_Program_Enrollment__r.id IN : HouseholdprogEnrollIds and
                                                                            Program_Enrollment__c IN : StudentEnrollIds and
                                                                            Enrollment_Component__c IN :hhEcsList  and                                                     
                                                                            (Status__c = 'In Progress' or Status__c = 'Complete')]){
                                                                                ectoecamap.put(affiliationRecord.Enrollment_Component__c,affiliationRecord);
                                                                            }
            }
            System.debug('ectoecamap=>'+ectoecamap);
            System.debug('ectoecamap.size()=>'+ectoecamap.size());
            //loop to through the new student ECA's and Update the status comparing with the completed/in progress ECAs of other students who are in the same HouseHold  
            set<id> parentIds = new set<id>();
            map<id,id> petoecmap = new map<id,id>();     
            for(Enrollment_Component_Affiliation__c hhaffiliation : newlist) { 
                if (hhEcsList.contains(hhaffiliation.Enrollment_Component__c)){
                    if(!ectoecamap.isempty()){
                        if(ectoecamap.containskey(hhaffiliation.Enrollment_Component__c))
                        {
                            if(ectoecamap.get(hhaffiliation.Enrollment_Component__c).Status__c != 'Not Started'){
                                hhaffiliation.Status__c = ectoecamap.get(hhaffiliation.Enrollment_Component__c).Status__c;
                            }                            
                            /*parentIds.add(hhaffiliation.Enrollment_Component__c);
                            petoecmap.put(hhaffiliation.Enrollment_Component__c, hhaffiliation.Program_Enrollment__c);*/
                            
                        }
                    }
                }
            }
            /*System.debug('parentIds=>'+parentIds);
            System.debug('petoecmap=>'+petoecmap);
            System.debug('parentIds.size()=>'+parentIds.size());
            //Start- added for bug 122591
            map<id,id> childandParent = new map<id,id>();
            //Fetch changed ECA's Parents ECs,Ex:From ECA's section changes get EC's Forms related to chnaged ECA section
            if (parentIds.size()>0){
                for (Enrollment_Component_Relationship__c ECARelationship:[
                    SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :parentIds]){
                        childandParent.put(ecaRelationship.Child_Enrollment_Component__c,ecaRelationship.Parent_Enrollment_Component__c);
                    }
                System.debug('childandParent=>'+childandParent);
                System.debug('childandParent.size()=>'+childandParent.size());
                if (!childandParent.isempty()){
                    for (Enrollment_Component_Affiliation__c affiliationRecord :newlist){
                        if(childandParent.containskey(affiliationRecord.Enrollment_Component__c)&&affiliationRecord.Program_Enrollment__c == petoecmap.get(childandParent.get(affiliationRecord.Enrollment_Component__c))){
                            if(!ectoecamap.isempty()){
                                if(ectoecamap.containskey(affiliationRecord.Enrollment_Component__c))
                                {
                                    if(ectoecamap.get(affiliationRecord.Enrollment_Component__c).Status__c == 'In Progress') { //Typo "In Progresss" corrected for Defect #207719 on 2020-07-01 (Krishna Peddanagammol)
                                        affiliationRecord.Status__c = 'In Progress';
                                    } else if(ectoecamap.get(affiliationRecord.Enrollment_Component__c).Status__c == 'Complete') {
                                        affiliationRecord.Status__c = 'Complete'; 
                                    } else {    
                                        //System.debug('affiliationRecord.Status__c::'+affiliationRecord.Status__c);
                                    }
                                }
                            }     
                        }                                                              
                    }
                }
            }*/
            //End-added for the bug 122591
        }
    }
    
    /**
* Change Log: 2019-08-13 modified for #101935 User Story ,Task 104310 by Anitha P 
* Purpose   : This method is used to Set status of Parent ECA and repective ECA stage,  when the ECA status of child component 
* changed from 'Completed' to 'In progress' or 'Not started'.
* Added logic for Waitlist for the bug 119931 (Anitha P) on 11/22/19
**/
    public static list<Enrollment_Component_Affiliation__c> updateAllECAS(List<Enrollment_Component_Affiliation__c> newList) {
        
        list<Id> progEnrollIds = new list<Id>();
        list<ID> componentIds = new list<id>();
        set<Id> progIdsForWaitlist = new set<Id>();//added
        set<Id> wailistEcIds = new set<Id>();
        list<Enrollment_Component_Affiliation__c> updatedHousehold = new list<Enrollment_Component_Affiliation__c>();
        //Collect Changed ECA's PE's and EC's in list
        // Added if condition for the bug 328454 on 10/30/2020 
        for(Enrollment_Component_Affiliation__c affiliation : newList) {
             if(affiliation.Program_Enrollment__r.Status__c != 'Complete'){
            progEnrollIds.add(affiliation.Program_Enrollment__c);
            componentIds.add(affiliation.Enrollment_Component__c);
             }
        }
        if (progEnrollIds.size()>0){
            map<Id,id> parentFormIds = new map<Id,id>();
            //Fetch changed ECA's Parents ECs,Ex:From ECA's section changes get EC's Forms related to chnaged ECA section
            for (Enrollment_Component_Relationship__c ECARelationship:[
                SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Child_Enrollment_Component__c IN :componentIds]){
                    parentFormIds.put(ecaRelationship.Child_Enrollment_Component__c,ecaRelationship.Parent_Enrollment_Component__c);
                }
            map<Id,id> parentParentFormIds = new map<Id,id>();
            //Fetch changed ECA's Parents Parents,Ex:From EC's Form's get EC's Stages related to chnaged ECA section
            for (Enrollment_Component_Relationship__c ecaRelationship:[
                SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Child_Enrollment_Component__c IN :parentFormIds.values()]){
                    parentParentFormIds.put(ecaRelationship.Child_Enrollment_Component__c,ecaRelationship.Parent_Enrollment_Component__c);               
                }
            system.debug('parentParentFormIds'+parentParentFormIds);
            //Fetch changed ECA's Parents GrantParents,Ex:From EC's stages's get EC's Process related to chnaged ECA section 
            map<Id,id> grantparentFormIds = new map<Id,id>();
            for (Enrollment_Component_Relationship__c ecaRelationship:[
                SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Child_Enrollment_Component__c IN :parentParentFormIds.values()]){
                    grantparentFormIds.put(ecaRelationship.Child_Enrollment_Component__c,ecaRelationship.Parent_Enrollment_Component__c);
                } 
            system.debug('GrantparentFormIds'+GrantparentFormIds);
            map<Id,id> grantchildsFormIds = new map<Id,id>();
            //Fetch changed ECA's Parents GrantParents Childs,Ex:From EC's Process get EC's of all stages in same Process related to chnaged ECA section 
            for (Enrollment_Component_Relationship__c ecaRelationship:[
                SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN : grantparentFormIds.values()]){
                    grantchildsFormIds.put(ecaRelationship.Child_Enrollment_Component__c,ecaRelationship.Parent_Enrollment_Component__c);
                }
            system.debug('GrantchildsFormIds'+GrantchildsFormIds);
            //Start -added for the bug 150375 on 03/18/2020
            //list<Enrollment_Component_Affiliation__c> updatedECAlist = new list<Enrollment_Component_Affiliation__c>();
            //set<Enrollment_Component_Affiliation__c> updatedECAlist = new set<Enrollment_Component_Affiliation__c>(); //commented for US169322 by Jagadeesh
            map<id,Enrollment_Component_Affiliation__c> updatedECAMap = new map<id,Enrollment_Component_Affiliation__c>();//added for US169322 by Jagadeesh
            //End -added for the bug 150375 on 03/18/2020
            list<Enrollment_Component_Affiliation__c> childECAlist = new list<Enrollment_Component_Affiliation__c>();
            
            //Fetch ECA"s of Parents whose status changed
            for (Enrollment_Component_Affiliation__c affiliationRecord :[
                SELECT Id,Enrollment_Component__c,Enrollment_Component__r.Component_Type__c,
                Status__c, Order__c,Program_Enrollment__c,Program_Enrollment__r.Household_Program_Enrollment__r.id,
                Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id,
                Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.recordtype.Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Enrollment_Component__c IN : parentFormIds.values() and
                Program_Enrollment__c IN : progEnrollIds
            ]) {
                //Loop through the changed ECA's and comparing relevant condition for EC's Component typ 'Student' and 'HouseHold'
                for(Enrollment_Component_Affiliation__c affiliation : newList){
                    if ( affiliationrecord.Program_Enrollment__c == affiliation.Program_Enrollment__c && affiliationrecord.Enrollment_Component__c == parentFormIds.get(affiliation.Enrollment_Component__c)
                        && affiliationRecord.Status__c == 'Complete' && ( affiliationRecord.Enrollment_Component__r.Component_Type__c == 'Student'|| affiliationRecord.Enrollment_Component__r.Component_Type__c == null)){                      
                            affiliationRecord.Status__c = 'In Progress';
                            //UpdatedECAlist.add(affiliationRecord);// commented for US169322 by Jagadeesh 
                            updatedECAMap.put(affiliationRecord.id, affiliationRecord);//added for US169322 by Jagadeesh
                        }else{
                            if ( affiliationrecord.Program_Enrollment__c == affiliation.Program_Enrollment__c && affiliationrecord.Enrollment_Component__c == parentFormIds.get(affiliation.Enrollment_Component__c)
                                && affiliationRecord.Status__c == 'Complete' && ( affiliationRecord.Enrollment_Component__r.Component_Type__c == 'Household'&& affiliationRecord.Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.recordtype.Name == 'Academic Program')){
                                    affiliationRecord.Status__c = 'In Progress';
                                   // UpdatedECAlist.add(affiliationRecord); //commented for US169322 by Jagadeesh
                                    UpdatedHousehold.add(affiliation);
                                    updatedECAMap.put(affiliationRecord.id, affiliationRecord);//added for US169322 by Jagadeesh
                                }
                        }               
                }
                childECAlist.add(affiliationRecord);
            }        
            system.debug('childECAlist'+childECAlist);
            //Fetch ECA records of GrandChilds,Ex: process childs(stages) ECA records
            list<Enrollment_Component_Affiliation__c> associatedStageRecords = [
                SELECT Id,Enrollment_Component__c,
                Status__c, Order__c,Program_Enrollment__c,Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.recordtype.Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Enrollment_Component__c IN : GrantchildsFormIds.keyset() and
                Program_Enrollment__c IN : progEnrollIds and 
                Enrollment_Component__r.recordtype.name = 'Stage' and Status__c IN  ('Complete' ,'In Progress' )];
            system.debug((associatedStageRecords));
            system.debug('associatedStageRecords'+associatedStageRecords.size());
            map<id,decimal> orderIdByProgramEnrommlent = new map<id,decimal>();
            //Loop through the Grandchild ECA's and get the order of the stage where ECA got changed
            for(Enrollment_Component_Affiliation__c ecachildaffiliation : childECAlist){
                for( Enrollment_Component_Affiliation__c parentchildECARecord : associatedStageRecords){
                    if ( ECAchildaffiliation.Program_Enrollment__c == parentchildECARecord.Program_Enrollment__c && parentparentFormIds.get(ecachildaffiliation.Enrollment_Component__c) ==  parentchildECARecord.Enrollment_Component__c){
                        orderIdByProgramEnrommlent.put( ecachildaffiliation.Program_Enrollment__c,parentchildECARecord.Order__c );
                    }
                }
            }
            system.debug('orderIdByProgramEnrommlent'+orderIdByProgramEnrommlent);
            list<Enrollment_Component_Affiliation__c> waitlistECA = new List<Enrollment_Component_Affiliation__c>();
            //Loop through the Grandchild ECA's and check if changed ECA stage is preceding to the current stage of PE ,then make in between stages from chnaged ECA's stage to current stage of PE to 'Not started'
            for(Enrollment_Component_Affiliation__c ecachildaffiliation : childECAlist){
                for( Enrollment_Component_Affiliation__c parentchildECARecord : associatedStageRecords){
                    if ( ECAchildaffiliation.Program_Enrollment__c == parentchildECARecord.Program_Enrollment__c && orderIdByProgramEnrommlent.get(parentchildECARecord.Program_Enrollment__c)!= null)
                    {
                        if (( parentchildECARecord.status__C == 'Complete'|| parentchildECARecord.status__C == 'In Progress') && orderIdByProgramEnrommlent.get(parentchildECARecord.Program_Enrollment__c) <= parentchildECARecord.Order__c){
                            
                            parentchildECARecord.Status__c = orderIdByProgramEnrommlent.get(parentchildECARecord.Program_Enrollment__c) < parentchildECARecord.Order__c? 'Not Started': 'In Progress';
                           // updatedECAlist.add(parentchildECARecord);  //commented for US169322 by Jagadeesh
                            //added for US169322 by Jagadeesh -Begin
                            //
                            if(!updatedECAMap.isEmpty()&& updatedECAMap.containskey(parentchildECARecord.id)){
                                updatedECAMap.get(parentchildECARecord.id).Status__c = parentchildECARecord.Status__c;
                            }
                            else{
                               updatedECAMap.put(parentchildECARecord.id,parentchildECARecord);
                            } 
                            
                            //added for US169322 by Jagadeesh -End
                            
                            if (parentchildECARecord.Order__c == 3 && parentchildECARecord.Status__c == 'Not Started' ){
                                // wailistEcIds.add(parentchildECARecord.Enrollment_Component__c);
                                progIdsForWaitlist.add(parentchildECARecord.Program_Enrollment__c);//added for bug 119931 on 11/19/2019
                                waitlistECA.add(parentchildECARecord);
                            }
                            
                        }
                    }  
                }
            }
            //Start-added logic for the bug 119931 on 12/09/2019
            List<hed__Program_Enrollment__c> finalListToUpdate  = new List<hed__Program_Enrollment__c>();
            if (progIdsForWaitlist.size()>0){
                List<hed__Program_Enrollment__c> listOfProgramEnrollmentsToUpdate = NES_BusinessLogicUtils.waitListCalculator(progIdsForWaitlist);
                for (hed__Program_Enrollment__c waitlistpeIds : listOfProgramEnrollmentsToUpdate){
                    if(waitlistpeIds.WaitlistFlag__c == 'Active'){
                        for(Enrollment_Component_Affiliation__c wailistecaid : waitlistECA){
                            if(wailistecaid.Program_Enrollment__c == waitlistpeIds.id){
                                finalListToUpdate.add(waitlistpeIds);
                                wailistEcIds.add(wailistecaid.Enrollment_Component__c);
                            }
                        }
                    }
                }
                finalListToUpdate = listOfProgramEnrollmentsToUpdate ;
            }
            //End-added logic for the bug 119931 on 12/09/2019
            
            //Start-added logic for the bug 119931 on 11/19/2019
            //Fetch Waitlist stage records
            map<Id,id> waitlistFormIds = new map<Id,id>();
            map<Id,id> waitlistSectionIds = new map<Id,id>();
            map<Id,id> waitlistTextIds = new map<Id,id>();
            set<id> allEcIds = new set<id>();
            if (wailistEcIds.size()>0){
                //fetch wailist stage children
                for (Enrollment_Component_Relationship__c waitlistFormRel:[
                    SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :wailistEcIds and Child_Component_Type__c = 'Form']){
                        waitlistFormIds.put(waitlistFormRel.Child_Enrollment_Component__c,waitlistFormRel.Parent_Enrollment_Component__c);
                        allEcIds.add(waitlistFormRel.Child_Enrollment_Component__c);
                    } 
                //fetch wailist Form children
                for (Enrollment_Component_Relationship__c waitlistSecRel:[
                    SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :waitlistFormIds.keyset() and Child_Component_Type__c = 'Section']){
                        waitlistSectionIds.put(waitlistSecRel.Child_Enrollment_Component__c,waitlistSecRel.Parent_Enrollment_Component__c);
                        allEcIds.add(waitlistSecRel.Child_Enrollment_Component__c);
                    }
                //fetch wailist section children
                for (Enrollment_Component_Relationship__c waitlistTextRel:[
                    SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :waitlistSectionIds.keyset() and Child_Component_Type__c = 'Text']){
                        waitlistTextIds.put(waitlistTextRel.Child_Enrollment_Component__c,waitlistTextRel.Parent_Enrollment_Component__c);
                        allEcIds.add(waitlistTextRel.Child_Enrollment_Component__c);
                    } 
                //fetch wailist ECAs
                for (Enrollment_Component_Affiliation__c waitlistaffiliation :[
                    SELECT Id,Enrollment_Component__c,Enrollment_Component__r.Component_Type__c,
                    Status__c, Order__c,Program_Enrollment__c FROM Enrollment_Component_Affiliation__c
                    WHERE Enrollment_Component__c IN : allEcIds and
                    Program_Enrollment__c IN : progIdsForWaitlist]){
                        waitlistaffiliation.Status__c = 'Not Started';
                       // updatedECAlist.add(waitlistaffiliation); //commented for US169322 by Jagadeesh
                        //added for US169322 by Jagadeesh :Begin
                        //To avoid duplicate records and updating with the latest status :
                        if(!updatedECAMap.isEmpty()&& updatedECAMap.containskey(waitlistaffiliation.id)){
                            updatedECAMap.get(waitlistaffiliation.id).Status__c = waitlistaffiliation.Status__c;
                        }  
                        //
                        else{
                            updatedECAMap.put(waitlistaffiliation.id,waitlistaffiliation);
                        }
                        //added for US169322 by Jagadeesh :End
                    }
            }
            //End-added logic for the bug 119931 on 11/19/2019 
            //Update the Changed ECA's statuses   
            //check if the record id is duplicated  (new list with unique eca's)     
           // if (updatedECAlist.size() > 0) {
                 if (!updatedECAMap.isEmpty() ){
                try {
                    //Start -added for the bug 150375 on 03/18/2020
                    //update updatedECAlist;
                   // update new List<Enrollment_Component_Affiliation__c> (updatedECAlist); // commented for US169322 by Jagadeesh
                
                  //  if(!updatedECAMap.isEmpty()){ commented for US169322 by Jagadeesh
                        update updatedECAMap.values(); //added for US169322 by Jagadeesh
                   // }
                   
                    //End -added for the bug 150375 on 03/18/2020
                    //Start- added logic for the bug 119931 on 11/19/2019
                    if (finalListToUpdate.size()>0){
                        update finalListToUpdate;
                    }
                    //End- added logic for the bug 119931 on 11/19/2019
                } catch (Exception ex) {
                    System.debug('Exception Thrown : ' + ex.getMessage());
                    logger.logException('updateSObjects', ex);
                    logger.saveLogs();
                }
            }
        }
        return updatedHousehold;
        
    }
    
    //Start-added for #107180 User Story (Task 108660) on 2019-09-06  commented below code for 107180 as this is removed
    /* public static void updatePAHStatus(Map<Id, Enrollment_Component_Affiliation__c> newmap ,Map<Id, Enrollment_Component_Affiliation__c> oldmap){
map<Id, id>  peAndEcaids = new Map<Id, Id>();
list<hed__Program_Enrollment__c> updatePesList =  new list<hed__Program_Enrollment__c>();
hed__Program_Enrollment__c updatePes = new hed__Program_Enrollment__c();
//Fetch ECA's whose EC name is 'Homeschool Prior Academic History' and update PAH status of corresponding PE
for(Enrollment_Component_Affiliation__c ecaStatus : [SELECT Id, Status__c,Enrollment_Component__c,Enrollment_Component__r.Component_Type__c,
Enrollment_Component__r.name,Program_Enrollment__c,Program_Enrollment__r.PAHStatus__c 
FROM Enrollment_Component_Affiliation__c WHERE Id IN : newMap.keySet() and
Enrollment_Component__r.Name = 'Homeschool Prior Academic History' and 
Enrollment_Component__r.PAH__c = true and Status__c = 'Complete']){                            
peAndEcaids.put( ecaStatus.Program_Enrollment__c,ecaStatus.id) ;
updatePes.id = ecaStatus.Program_Enrollment__c;
updatePes.PAHStatus__c ='Received';       
updatePesList.add(updatePes);
}
//Update the Changed PE's statuses           
if (updatePesList.size() > 0) {
try {
update updatePesList;               
} catch (Exception ex) {
System.debug('Exception Thrown : ' + ex.getMessage());
logger.logException('updateSObjects', ex);
logger.saveLogs();
}
}
} */ 
    //End-added for #107180 User Story (Task 108660) on 2019-09-06
    
    
}