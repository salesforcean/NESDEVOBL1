/**
* Created by Ashish Sharma on 12/05/18.
* Class Name:  NES_DashboardHelper
* Test Class Name: NES_DashboardControllerTest
* Purpose : This class is helper class for NES_DashboardController
*/
public without sharing class NES_DashboardHelper {
    private static Peak_ApexLog logger = new Peak_ApexLog('DashboardHelper');
    
    
    
    /**
    * Created By : Jagadish Babu
    * Created Date : 03/12/2020
    * Parameter : CareTaker User Id
    * Purpose : This method is used get the students under care taker with respect to program enrollment and prepare the JSON to care taker dashboard (US 338596)
    **/
    public static List<NES_DashboardUtilities.StudentsInformation> getRelatedStudentsInfoWithId(Id ctUserId) {
        try{
            Id careTakerContactId;
            
            //Retrieve the care taker contact Id of the current logged in user
            for (User tempUser : [SELECT ContactId FROM User WHERE Id = :ctUserId]) {
                careTakerContactId = tempUser.ContactId;
            }
            List<NES_DashboardUtilities.studentsInformation> studentsInformation = new List<NES_DashboardUtilities.studentsInformation>();
            if (careTakerContactId != null) {
                Set<Id> studentIds = new Set<Id>();
                //Student Record Type Id
                Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();
                //Get all the available academic programs as Registration dates
                Map<Id, List<Account>> mapOfAvailableSchoolYrs = getAvailableAcademicPrograms();
                
                //Get the relation ship records under Care Taker
                for (hed__Relationship__c con : [
                    SELECT hed__RelatedContact__c
                    FROM hed__Relationship__c
                    WHERE hed__Contact__c = :careTakerContactId
                    AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
                ]) 
                {
                    studentIds.add(con.hed__RelatedContact__c);
                }
                
                //Creating the map of Program enrollment Ids with process ECA ids
                Map<Id, Enrollment_Component_Affiliation__c> mapProcessECAWithPEId = new Map<Id,Enrollment_Component_Affiliation__c>();
                for(Enrollment_Component_Affiliation__c eca : [Select Id, Enrollment_Component__c,Enrollment_Component__r.RecordType.Name,Status__c,Program_Enrollment__c, Program_Enrollment__r.hed__Contact__c from Enrollment_Component_Affiliation__c where Program_Enrollment__r.hed__Contact__c IN: studentIds and Enrollment_Component__r.RecordType.Name =: NES_DashboardUtilities.PROCESS_RT]){
                    mapProcessECAWithPEId.put(eca.Program_Enrollment__c, eca);
                }
                
                //Below if condition has the preparation of JSON for students along with latest PEs for schools
                //"WithdrawalCategory__c" field Added by Shravaniin Contact query for US#389103 on 5/25/21
                if (studentIds.size() > 0) {
                    Date todayDate = date.today();
                    /// shravani new update 1 
                       Map<Id,hed__Program_Enrollment__c> PEmap = new  Map<Id,hed__Program_Enrollment__c>([Select Id, WithdrawalCategory__c, Program_Grade_Level__c,Program_Grade_Level__r.Grade_Level__r.Name,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.Registration_End_Date__c,hed__Account__r.ITR_Start_Date__c,hed__Account__r.ITR_End_Date__c,hed__Account__r.Registration_Start_Date__c,Status__c,hed__Account__r.name, Final_Grade_Level__c, hed__Account__c, hed__Account__r.ParentId,hed__Account__r.Parent.Name,Start_Year__r.Name,(select id,Withdrawal_Category__c from Enrollments__r order by createddate desc)  from hed__Program_Enrollment__c where hed__Contact__c IN:studentIds order by createddate desc]);
                    /// shravani new update 1 end
                    for(Contact con : [Select Id, firstName, LastName, RecordType.Name, (Select Id, WithdrawalCategory__c, Program_Grade_Level__c,Program_Grade_Level__r.Grade_Level__r.Name,ITR_Exception_Date_NY__c,ITR_Eligibility_NY__c,hed__Account__r.Registration_End_Date__c,hed__Account__r.ITR_Start_Date__c,hed__Account__r.ITR_End_Date__c,hed__Account__r.Registration_Start_Date__c,Status__c,hed__Account__r.name, Final_Grade_Level__c, hed__Account__c, hed__Account__r.ParentId,hed__Account__r.Parent.Name,Start_Year__r.Name  from hed__Program_Enrollments__r order by createddate desc) from Contact where Id IN: studentIds]){                    
                        Set<String> instituationSet = new Set<String>();
                        if(con.hed__Program_Enrollments__r.size() > 0){
                            NES_DashboardUtilities.studentsInformation studentInfo = new NES_DashboardUtilities.studentsInformation();
                            studentInfo.studentFName = con.FirstName;
                            studentInfo.studentLName = con.LastName;
                            studentInfo.studentId = con.Id;
                            studentInfo.academicPrograms = new List<NES_DashboardUtilities.AcademicProgramsWrapper>();
                            for(hed__Program_Enrollment__c peRec : con.hed__Program_Enrollments__r){                            
                                if(!instituationSet.contains(peRec.hed__Account__r.ParentId)){                              
                                    String buttonLabel = '';
                                    String buttonTarget = '';    
                                    List<Account> availablePrograms = mapOfAvailableSchoolYrs.containsKey(peRec.hed__Account__r.ParentId) ? mapOfAvailableSchoolYrs.get(peRec.hed__Account__r.ParentId): null;
                                    ///// shravani new update 2
                                    buttonLabel = getButtonLabelName(PEmap.get(peRec.id),availablePrograms);
                                    //buttonLabel = getButtonLabelName(peRec,availablePrograms);
                                    ///// shravani new update 2 end
                                    if(buttonLabel == 'Continue')
                                        buttonTarget = '/enrollment';
                                    if(buttonLabel == 'Contact Us')
                                        buttonTarget ='/tickets';
                                    String processECId = mapProcessECAWithPEId.containsKey(peRec.Id) ? mapProcessECAWithPEId.get(peRec.Id).Enrollment_Component__c : null;  
                                    String processECAStatus = mapProcessECAWithPEId.containsKey(peRec.Id) ? mapProcessECAWithPEId.get(peRec.Id).Status__c : null;
                                    String statusString;
                                    if (String.isNotBlank(peRec.Status__c)) {
                                        statusString = peRec.Status__c;
                                    } else {
                                        statusString = processECAStatus;
                                    }
                                    String StudentGradeLevel = getGradeLevel(peRec.Program_Grade_Level__r.Grade_Level__r.Name);
                                    
                                    
                                    studentInfo.academicPrograms.add(new NES_DashboardUtilities.AcademicProgramsWrapper(peRec.hed__Account__r.name, peRec.Id, processECId,statusString,peRec.Status__c,peRec.hed__Account__r.ParentId,peRec.Program_Grade_Level__c,StudentGradeLevel,peRec.hed__Account__r.Registration_Start_Date__c,peRec.hed__Account__r.Registration_End_Date__c,peRec.hed__Account__r.Parent.Name,peRec.Start_Year__r.Name, buttonLabel, buttonTarget));
                                    instituationSet.add(peRec.hed__Account__r.ParentId);
                                }                                                                                                        
                            }
                            studentsInformation.add(studentInfo);
                        }
                        
                    }
                }
                system.debug(JSON.Serialize(studentsInformation));
                return studentsInformation;
            }
            return null;
        }
        catch (Exception e) {
            logger.logException('getRelatedStudentsInfoWithId', e);
            logger.saveLogs();
            return null;
        }              
    }
    
    //Returns button label as per the program enrollment status/ITR Dates and available academic programs as per today's date
    public static String getButtonLabelName(hed__Program_Enrollment__c peRecord, List<Account> availableAcademicPrograms){
        
        try{
        String resultString = 'Contact Us';  
        Date todayDate = date.today();
        
        //Added by Shravani for US#389103 on 7/04/21 "Button display logic 1"
        //if(!peRecord.Enrollments__r.isEmpty() && !availableAcademicPrograms.isEmpty() && (peRecord.hed__Account__c != availableAcademicPrograms[0].Id || ((peRecord.hed__Account__c == availableAcademicPrograms[0].Id) && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'Not Returning' )) && (peRecord.Status__c == NES_DashboardUtilities.COMPLETE_STATUS)){
        
        //1)PE Status = Complete and latest Enrollment record's Withdrawal category ='Not Returning' -->Re-enroll is to be displayed.
        if(!peRecord.Enrollments__r.isEmpty() && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'Not Returning' && peRecord.Status__c == NES_DashboardUtilities.COMPLETE_STATUS){
            resultString = NES_DashboardUtilities.REENROLL_BTN_LABEL;  
        } else  
        //Added by Shravani for US#389103 on 7/04/21 "Button display logic 2"
        if(!peRecord.Enrollments__r.isEmpty() &&  !availableAcademicPrograms.isEmpty() && (peRecord.hed__Account__c != availableAcademicPrograms[0].Id || ((peRecord.hed__Account__c == availableAcademicPrograms[0].Id) && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'No Show' )) && (peRecord.Status__c == NES_DashboardUtilities.WITHDRAWN_STATUS)){
            //else if(!peRecord.Enrollments__r.isEmpty() && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'No Show' && peRecord.Status__c == NES_DashboardUtilities.WITHDRAWN_STATUS){
            resultString = NES_DashboardUtilities.REENROLL_BTN_LABEL;            
        }
        // 
        if(peRecord.Status__c == NES_DashboardUtilities.COMPLETE_STATUS && ((peRecord.Program_Grade_Level__r.Grade_Level__r.Name == Label.NES_Twelth_Grade && peRecord.ITR_Eligibility_NY__c == 'Yes') || (peRecord.Program_Grade_Level__r.Grade_Level__r.Name != Label.NES_Twelth_Grade && peRecord.ITR_Eligibility_NY__c != 'No')) && ((todayDate >= peRecord.hed__Account__r.ITR_Start_Date__c && todayDate <=peRecord.hed__Account__r.ITR_End_Date__c) || (peRecord.ITR_Exception_Date_NY__c != null && todayDate <= peRecord.ITR_Exception_Date_NY__c))){
            resultString = NES_DashboardUtilities.ITR_BTN_LABEL;           
        } 
        else if(peRecord.Status__c == NES_DashboardUtilities.COMPLETE_STATUS){
            resultString = NES_DashboardUtilities.COMPLETE_STATUS;            
        }
        else if(peRecord.Status__c == NES_DashboardUtilities.INPROGRESS_STATUS){
            resultString = 'Continue';            
        }
        else if(peRecord.Status__c == NES_DashboardUtilities.INACTIVE_STATUS){
            //added by Sravani for BUG#367727 
            //if(availableAcademicPrograms.size() > 0){
            if(availableAcademicPrograms!=null){
                if((!availableAcademicPrograms.isEmpty())&&(availableAcademicPrograms.size() > 0)){
                    resultString = NES_DashboardUtilities.REACTIVATE_BTN_LABEL;                
                }    
            }
            
            
        }
            // Added by Shravani for US#389103 on 5/25/21
            //else if(peRecord.Status__c == NES_DashboardUtilities.WITHDRAWN_STATUS &&  (peRecord.WithdrawalCategory__c=='Prior to Engagement' || peRecord.WithdrawalCategory__c=='Withdrawal During School Year')){
                 //resultString = 'Contact Us';     
            //}
            
            // End by Shravani for US#389103 on 7/04/21      
            
        else if(peRecord.Status__c == NES_DashboardUtilities.WITHDRAWN_STATUS){
            //added by Sravani for BUG#367727 
            //if(availableAcademicPrograms.size() > 0){
            if(availableAcademicPrograms!=null){
                if((!availableAcademicPrograms.isEmpty())&& (availableAcademicPrograms.size() > 0)){
                    if(peRecord.hed__Account__c != availableAcademicPrograms[0].Id){
                        resultString = NES_DashboardUtilities.REENROLL_BTN_LABEL;                   
                    }                                            
                }
            }
        }      
            
        return resultString;
       }
        catch (Exception e) {
            logger.logException('getButtonLabelName', e);
            logger.saveLogs();
            return null;
        } 
    }
    
    //Returns available academic programs as per the academic program registration dates
    public static Map<Id,List<Account>> getAvailableAcademicPrograms(){
        Map<Id, List<Account>> resultMap =  new Map<Id, List<Account>>();
        Date todayDate = Date.today(); 
        Id academicProgramRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        for(Account academicProgram : [Select Id, Name, ParentId, Registration_Start_Date__c,recordType.Name, Registration_End_Date__c from Account where  Registration_Start_Date__c <= :todayDate AND Registration_End_Date__c >= :todayDate AND recordTypeId =: academicProgramRTId order by createddate DESC]){
            if(resultMap.containsKey(academicProgram.ParentId)){
                resultMap.get(academicProgram.ParentId).add(academicProgram);
            }
            else{
                resultMap.put(academicProgram.ParentId,new List<Account>{academicProgram});
            }                
        }
        return resultMap;
    }  
    
    //Returns Grade Level Names per the grade Names
    public static String getGradeLevel(String gradeName){
        String resultGradeName = '';
        if(gradeName != null){
            if(gradeName == 'K')
                resultGradeName = 'Kindergarten';
            else if(gradeName == '1')
                resultGradeName = '1st Grade';
            else if(gradeName == '2')
                resultGradeName = '2nd Grade';
            else if(gradeName == '3')
                resultGradeName = '3rd Grade';
            else
                resultGradeName = gradeName + 'th Grade';
        }        
        return resultGradeName;        
    }   
    
}