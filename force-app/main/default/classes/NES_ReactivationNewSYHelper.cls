/**
* Created by Sravani Pendyala on 12/01/2020.
* Created for the task #335376.
* Test Class : NES_ReactivationNewSYHelperTEST
* Description : This class acts as controller for the lightning component "NES_ReactivationNewSY" 
* which is used for "Reactivation - New SY" quick action on PE record detail page.
*                        
*/




public class NES_ReactivationNewSYHelper {
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: List<Grade_Level__c>
* Purpose : This method is used to get the related Grade levels for selected year and institute name.
*/
    @AuraEnabled
    public static List<Grade_Level__c> getGradeLevels(string selectedYr,String instituteName) {
        List<Grade_Level__c> gradeLevels = NES_EnrollmentController.getGradeLevels(instituteName,selectedYr);
        /*
        hed__Program_Enrollment__c programEnrollment =[Select id,hed__Account__r.ParentId,Start_Year__c from hed__Program_Enrollment__c where id=:programEnrollmentId];
        List<Grade_Level__c> gradeLevels = [SELECT Id, Name FROM Grade_Level__c where Id in (Select Grade_Level__c from Program_Grade_Level__c where Academic_Program__r.ParentId=:programEnrollment.hed__Account__r.ParentId) order by Name];
        */
        return gradeLevels;
    }
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: Peak_Response
* Purpose : This method is used to Reactive the PE for new School year.
*/
    @AuraEnabled
    public static Peak_Response newYearReactivate(Id studentId,String instituteNam,String schoolYear,String gradeLevels, String callType, boolean enrollFlag, Id programEnrollmentId) {
        Peak_Response pr = NES_EnrollmentController.nextYearEnrollment(studentId,instituteNam,schoolYear,gradeLevels,callType,enrollFlag,programEnrollmentId);
        return pr;
    }
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Purpose : Wrapper class used for validatePE method
*/
    public class validatePEwrapper{
        @AuraEnabled
        public hed__Program_Enrollment__c programEnrollment{get;set;}
        @AuraEnabled
        public string isValid{get;set;}
        public validatePEwrapper(hed__Program_Enrollment__c pe, string isvalid){
            this.programEnrollment = pe;
            this.isvalid = isvalid;
        }
    }
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: validatePEwrapper
* Purpose : This method is used to validate given PE for New Year Reactivation  
*/
    @AuraEnabled
    public static validatePEwrapper validatePE(ID programEnrollmentId) {
        String PE_status_Inactive = 'Inactive';

        String PE_status_Withdrawn = 'Withdrawn';// Updated by sravani #361444
        String PE_status_Complete = 'Complete';
        string isValid = 'valid';
        hed__Program_Enrollment__c programEnrollment = [SELECT id, Start_Year__c,Start_Year__r.Name,hed__Contact__c,hed__Contact__r.Contact_Record_Type_Text__c,hed__Account__r.Parent.Name,Status__c,
                                                        (select id,Withdrawal_Category__c from Enrollments__r order by createddate desc) FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
        
       
        if(!(PE_status_Inactive.containsIgnoreCase(programEnrollment.Status__c) 
             || PE_status_Withdrawn.containsIgnoreCase(programEnrollment.Status__c)
            || (PE_status_Complete.containsIgnoreCase(programEnrollment.Status__c) && (!programEnrollment.Enrollments__r.isEmpty()) && (programEnrollment.Enrollments__r[0].Withdrawal_Category__c == 'Not Returning' ) ) )){           
               isValid = 'PE Status is not valid for the process.';} 
     
        validatePEwrapper  vPEw = new validatePEwrapper(programEnrollment,isValid);
        return vPEw;
    }
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: List<School_Year__c>
* Purpose : This method is used to get list of valid School years for given Institute   
*/
    @AuraEnabled
    public static List<School_Year__c> getSchoolYears(String instituteName, String omitPEYearId) {
        List<School_Year__c> schoolYears = NES_EnrollmentController.getSchoolYears(instituteName);
        List<School_Year__c> validSchoolYears = New List<School_Year__c>();
        for(School_Year__c SY : schoolYears){
            
            if(SY.Id!=omitPEYearId){
                validSchoolYears.add(SY);
           	}
          
            
        }
        /*
        List<String> schoolYearIds = new List<String>();
        new List<School_Year__c>();
        hed__Program_Enrollment__c programEnrollment =[Select id,hed__Account__r.ParentId,Start_Year__c from hed__Program_Enrollment__c where id=:programEnrollmentId];
        List<School_Year__c> schoolYears = [Select id,name,Current_Year__c from School_Year__c where Id in (Select School_Year__c from Account where parentid=:programEnrollment.hed__Account__r.ParentId) and Current_Year__c!=true and id!=:programEnrollment.Start_Year__c ];
        */        
        return validSchoolYears;
    }
}