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
        /**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: Peak_Response
* Purpose : This method is used to enroll for new school   
*/
    @AuraEnabled
    public static Peak_Response otherSchoolEnrollment(Id studentId,String instituteNam,String schoolYear,String gradeLevels, String callType, boolean enrollFlag) {
        Peak_Response pr = NES_EnrollmentController.nextYearEnrollment(studentId,instituteNam,schoolYear,gradeLevels,callType,enrollFlag,null);
        return pr;
    }
    
 /**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: List<Grade_Level__c>
* Purpose : This method is used to get related grades levels   
*/    
    @AuraEnabled
    public static List<Grade_Level__c> getGradeLevels(String instituteName,string selectedYr) {
        List<Grade_Level__c> gradeLevels = NES_EnrollmentController.getGradeLevels(instituteName,selectedYr);
        return gradeLevels;
    }
    
 /**
* Created by Sravani Pendyala on 12/01/2020.
* Return Type: List<Account>
* Purpose : This method is used to get valid schools to enroll   
*/     
    @AuraEnabled
    public static List<Account> getSchoolsToAttend(String selectedStudentId) {
        
        // getting PEs related student
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
/*
        List<Id> schoolsToRemove= new List<Id>();
        //List<Account> schoolsToAttend = new List<Account>();
        //String CTstate = '';
        //String CTZipCode = '';
        if(studentPEs[0].hed__Contact__r.Caretaker_Id__r.Account.ShippingState!=null){
            //CTstate= studentPEs[0].hed__Contact__r.Caretaker_Id__r.Account.ShippingState;
            for(hed__Program_Enrollment__c pe:studentPEs){
                if(pe.hed__Account__r.ParentId!=null){
                    schoolsToRemove.add(pe.hed__Account__r.ParentId);
                }
            }
            //schoolsToAttend= [SELECT Id,Name,Shippingstate,ShippingPostalCode from account where id NOT IN :schoolsToRemove and shippingstate=:CTstate and recordtype.name='Educational Institution'];
        }
    */    
        
        // getting related Caretaker
        User caretaker = [SELECT Contact.inputParameter__c,contact.account.Family_Enrollment_Counselor__c,Contact.Account.ShippingState, Contact.Account.ShippingPostalCode  FROM User 
                          WHERE Contactid = :studentPEs[0].hed__Contact__r.Caretaker_Id__c];
        string CTshippingCode = caretaker.Contact.Account.ShippingPostalCode; // getting ZipCode related to Caretaker
        Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId(); // getting 'Educational Institution' RecordTypeId
        Id processId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Process').getRecordTypeId(); // getting 'Process' RecordTypeId
        
        
        // Grab the process enrollment components to find valid schools
        List<Enrollment_Component__c> processes = [
            SELECT Id, Process_Academic_Program__c
            FROM Enrollment_Component__c
            WHERE RecordTypeId = :processId AND Process_Academic_Program__c != NULL
            AND Process_Academic_Program__r.School_Year__c != NULL
            AND Process_Academic_Program__r.Registration_Start_Date__c <= TODAY
            AND Process_Academic_Program__r.Registration_End_Date__c >= TODAY
        ];
        
        List<Id> programIds = new List<Id>();
        
        //grab all Ids of Academic Programs
        for (Enrollment_Component__c process : processes) {
            programIds.add(process.Process_Academic_Program__c);
        }
        
        System.debug('programIds: ' + programIds);
        
        // only want to show institutions that match on zip if that institution has any zips set up.
        Map<Id, set<String>> institutionToZipListMap = new Map<Id, set<String>> ();
        Set<Id> institutionsInState = new Set<Id>();
        
        //getting schools within the Caretaker state
        List<Account> institutionTempAccounts = [
            SELECT Id, Name, (SELECT Id, Name FROM ChildAccounts)
            FROM Account
            WHERE RecordTypeId = :institutionRecordTypeId
            AND ShippingState = :caretaker.Contact.Account.ShippingState
        ];
        
        for (Account institution : institutionTempAccounts) {
            institutionsInState.add(institution.id);
        }
        
        // loop over postal codes of related Academic Program to get 'institutionToZipListMap'
        for (Program_PostalCode__c ppc :  [SELECT Academic_Program__c,PostalCode__c FROM Program_PostalCode__c where Academic_Program__c in :programIds]) {
            set<string> thisAPZips;
            if (!institutionToZipListMap.containsKey(ppc.Academic_Program__c)) { thisAPZips = new set<String>(); }
            else{thisAPZips = institutionToZipListMap.get(ppc.Academic_Program__c);            }
            thisAPZips.add(ppc.PostalCode__c); institutionToZipListMap.put(ppc.Academic_Program__c, thisAPZips);
        }
        
        System.debug('insti: ' + institutionTempAccounts);
        Set<Account> institutionSet = new Set<Account>();
        
        //loop through institutions to grab all the ones with valid academic programs
        for (Account institution : institutionTempAccounts) {
            //if they have an academic program, we want to return to the school list
            if (institution.ChildAccounts.size() > 0 ) {
                for (Account child : institution.ChildAccounts) {
                    //This if this institution even has zips assigned.
                    boolean meetsZipCriteria = true;
                    if (institutionToZipListMap.containsKey(child.Id)) { //If this institution has no zips, they won't be in the map at all.
                        set<string> thisAPZips = institutionToZipListMap.get(child.Id);
                        if (!thisAPZips.contains(caretaker.Contact.Account.ShippingPostalCode.substring(0,5))){ meetsZipCriteria = false;}
                            
                    }
                    if (programIds.contains(child.Id) && meetsZipCriteria) {
                        institutionSet.add(institution);
                        System.debug('institutions: ' + institutionSet);
                    }
                }
            }
        }
        List<Account> institutions = new List<Account>();
        institutions.addAll(institutionSet);        
        
        return institutions;
    }
}