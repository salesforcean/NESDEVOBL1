public without sharing class NES_OtherSchoolEnrollmentHelper {
    @AuraEnabled
    public static List<Account> getSchoolsToAttend(String selectedStudentId) {
    List<Id> schoolsToRemove;
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
                                                       hed__Contact__r.Caretaker_Id__r.Account.name
                                                       from hed__Program_Enrollment__c 
                                                       where hed__Contact__c=:selectedStudentId ];
        String CTstate= studentPEs[0].hed__Contact__r.Caretaker_Id__r.Account.ShippingState;
        for(hed__Program_Enrollment__c pe:studentPEs){
            schoolsToRemove.add(pe.hed__Account__r.ParentId);
        }
        List<Account> schoolsToAttend= [SELECT id,name,shippingstate from account where id NOT IN :schoolsToRemove and shippingstate=:CTstate and recordtype.name='Educational Institution'];
        
        return schoolsToAttend;
    }
}