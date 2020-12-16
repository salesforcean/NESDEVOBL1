public without sharing class NES_OtherSchoolEnrollmentHelper {
    
/**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: List<School_Year__c>
* Purpose : This method is used to get list of valid School years for given Institute   
*/
    @AuraEnabled
    public static List<School_Year__c> getSchoolYears(String instituteName) {
        List<School_Year__c> schoolYears = NES_EnrollmentController.getSchoolYears(instituteName);
        return schoolYears;
    }
    
    @AuraEnabled
    public static Peak_Response otherSchoolEnrollment(Id studentId,String instituteNam,String schoolYear,String gradeLevels, String callType, boolean enrollFlag) {
        Peak_Response pr = NES_EnrollmentController.nextYearEnrollment(studentId,instituteNam,schoolYear,gradeLevels,callType,enrollFlag,null);
        return pr;
    }
    
    @AuraEnabled
    public static List<Grade_Level__c> getGradeLevels(String instituteName,string selectedYr) {
        List<Grade_Level__c> gradeLevels = NES_EnrollmentController.getGradeLevels(instituteName,selectedYr);
        return gradeLevels;
    }
    
    @AuraEnabled
    public static List<Account> getSchoolsToAttend(String selectedStudentId) {
        List<Id> schoolsToRemove= new List<Id>();
        List<Account> schoolsToAttend = new List<Account>();
        List<hed__Program_Enrollment__c> studentPEs = [select id, 
                                                       hed__Contact__c,
                                                       hed__Contact__r.Name,
                                                       hed__Account__c,
                                                       hed__Account__r.Name,
                                                       hed__Account__r.ParentId,
                                                       hed__Account__r.Parent.name,
                                                       hed__Account__r.Parent.ShippingState,
                                                       hed__Contact__r.Caretaker_Id__c,
                                                       hed__Contact__r.Caretaker_Id__r.name,
                                                       hed__Contact__r.Caretaker_Id__r.AccountId,
                                                       hed__Contact__r.Caretaker_Id__r.Account.ShippingState,
                                                       hed__Contact__r.Caretaker_Id__r.Account.ShippingPostalCode,
                                                       hed__Contact__r.Caretaker_Id__r.Account.name
                                                       from hed__Program_Enrollment__c 
                                                       where hed__Contact__c=:selectedStudentId 
                                                       order by createddate Desc];
        if(studentPEs[0].hed__Contact__r.Caretaker_Id__r.Account.ShippingState!=null){
            String CTstate= studentPEs[0].hed__Contact__r.Caretaker_Id__r.Account.ShippingState;
            for(hed__Program_Enrollment__c pe:studentPEs){
                if(pe.hed__Account__r.ParentId!=null){
                    schoolsToRemove.add(pe.hed__Account__r.ParentId);
                }
            }
            schoolsToAttend= [SELECT Id,Name,Shippingstate,ShippingPostalCode from account where id NOT IN :schoolsToRemove and shippingstate=:CTstate and recordtype.name='Educational Institution'];
        }
        return schoolsToAttend;
    }
}