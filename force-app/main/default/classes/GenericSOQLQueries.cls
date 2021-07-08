/* SOQL Queries
Author- Vani
*/

public class GenericSOQLQueries{

public static Set<Id> receivedContactID;
public static list<contact> returnContacts;
    
public static Integer i=0;    

public static Set<Id> enrollmentComIds = new set<id>();
public static list<Enrollment_Component__c> enrollmentComps;// = new list<Enrollment_Component__c>();

public static Set<Id> programEnrollmentIds = new set<id>();
public static list<hed__Program_Enrollment__c> ProgramEnrollmets;

public static Set<Id> criteriaIds;
public static list<Criteria__c> criteriaList; 


    public static list<contact> contactDetails(set<id> contactIdSet){
      //  if(string.isBlank(receivedContactID) || !receivedContactID.equalsIgnoreCase(contactIdSet)){        
       // receivedContactID = new set<Id>();
        if(i==0 || !receivedContactID.containsALL(contactIdSet)){
            i = i+1;
            system.debug('*** Inside IF contactDetails() contactIdSet ==> '+contactIdSet);
            returnContacts= new list<contact>();
            receivedContactID = contactIdSet;
            returnContacts= [select Id, Birthdate__C, Why_Is_Your_Child_Attending_CA__c, accountId, account.LC_HighestLevelofEducation__c, account.Mktg_Customer_Loyalty__c, account.Internet_Connection_Type__c, account.Computer_in_Home__c FROM Contact where id=:contactIdSet];
            System.debug('In If block of -contactDetails');
            return returnContacts;
        }else 
        {
           System.debug('In Else block of -contactDetails');
            return returnContacts;
        }    
    }
    
    public static list<Enrollment_Component__c> enrollmentDetails(set<id> receivedEnroCompID){
            if(enrollmentComIds.isempty() || !enrollmentComIds.containsALL(receivedEnroCompID)){          
                System.debug('inside EC Lists');
                //enrollmentComps = new list<Enrollment_Component__c>();
                enrollmentComIds.addall(receivedEnroCompID);
                enrollmentComps=[SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :receivedEnroCompID];
                return enrollmentComps;
            }else{
                 System.debug('Outside EC Lists');
                 return enrollmentComps;
            } 
            
        }
    
    
    public static list<hed__Program_Enrollment__c> programEnrollmentDetails(set<id> receivedProgramEnrollments){
      if(programEnrollmentIds.isempty() || !programEnrollmentIds.containsALL(receivedProgramEnrollments)){
           programEnrollmentIds.addall(receivedProgramEnrollments);   
           //ProgramEnrollmets=[SELECT Id, hed__Account__c,ELLFlag__c,hed__Account__r.ParentId, hed__Account__r.Use_Updated_ECA_Process__c,Enrollment_Type__c,hed__Contact__r.RecordType.Name, hed__Contact__r.AccountId,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,recordtype.name, hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :receivedProgramEnrollments];
           ProgramEnrollmets=[SELECT Id, hed__Account__c,ELLFlag__c,hed__Account__r.ParentId, hed__Account__r.Use_Updated_ECA_Process__c,Enrollment_Type__c,hed__Contact__r.RecordType.Name, hed__Contact__r.AccountId,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,recordtype.name, hed__Contact__c,hed__Contact__r.Name,Program_Grade_Level__r.Grade_Level__r.Name,V2_External_ID__c FROM hed__Program_Enrollment__c WHERE Id = :receivedProgramEnrollments];
           return ProgramEnrollmets;
            }else return ProgramEnrollmets;     
          }   
    
}