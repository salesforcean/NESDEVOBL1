//Created for Bulk Data load for Testing as part of Regression Testing - Sumanth B
public class CS_BulkDataCreation4CTSTD {

     public UserRole fetchUserRole(String roleName){        
       return [Select Id from UserRole where name = :roleName];
    }

    public User createnewPortalUser(String userName, String aliasName, String timeZoneKey, String langLocaleKey, String localeKey,
                         String emailEncodeKey, String userCountry, Id usrProfileId, String usrLastName, String userEmail,Id ContId){
        
       return new User(username= userName,
                        alias = aliasName,
                        timezonesidkey = timeZoneKey,
                        languagelocalekey = langLocaleKey,
                        localesidkey=localeKey,emailencodingkey=emailEncodeKey,country=userCountry,
                        profileId=usrProfileId,lastname=usrLastName,email=userEmail,ContactId = ContId);
    }
    
    public User createNewUser(String userName, Id userRoleId, String aliasName, String timeZoneKey, String langLocaleKey, String localeKey,
                         String emailEncodeKey, String userCountry, Id usrProfileId, String usrLastName, String userEmail){
        
       return new User(username= userName,
                        UserRoleId = userRoleId,
                        alias = aliasName,
                        timezonesidkey = timeZoneKey,
                        languagelocalekey = langLocaleKey,
                        localesidkey=localeKey,emailencodingkey=emailEncodeKey,country=userCountry,
                        profileId=usrProfileId,lastname=usrLastName,email=userEmail);
    }
    
    public School_Year__c createSchoolYear(boolean currentYear, Date endDate, Date startDate, String externalId){

        return new School_Year__c(Current_Year__c = currentYear, End_Date__c = endDate, Start_Date__c = startDate, External_Id__c = externalId);
    }
    
    public Account createNewAccount(String acctName, String acctRecTypeId, Id parentAccountId, Date youngCutOffDate, String schoolYearId){
        
        return new Account( Name = acctName, RecordTypeId = acctRecTypeId, ParentId = parentAccountId, Too_Young_Cutoff__c = youngCutOffDate, School_Year__c = schoolYearId);
    }
    
    
    public list<Account> createListOfAccounts(String acctName, String acctRecTypeId, String parentAcctId, Date youngCutOffDate, String schoolYearId, Integer count){
        list<Account> accountList = new list<Account>();
        
        for(Integer x = 0; x < count; x++){
            Account acctTempObj = createNewAccount(acctName+String.valueOf(x+1), acctRecTypeId, parentAcctId, youngCutOffDate, schoolYearId);
            accountList.add(acctTempObj);
        }
        
        return accountList;
    }
    
    public Contact createNewContact(String lastName, Id contactRecTypeId, Id parentAcctId, Id careTakerRecId){
        
        return new Contact(LastName = lastName, Caretaker_Id__c = careTakerRecId, AccountId = parentAcctId, RecordTypeId = contactRecTypeId);
    }
    
    public list<Contact> createListOfContacts(String lastName, Id contactRecTypeId, Id parentAcctId, Id careTakerRecId, Integer count){
        list<Contact> contactList = new list<Contact>();
        
        for(Integer x = 0; x < count; x++){
            Contact contactObj = createNewContact(lastName+String.valueOf(x), contactRecTypeId, parentAcctId, careTakerRecId);
            contactList.add(contactObj);
        }
        
        return contactList;
    }
    
    public hed__Relationship__c createNewRelationship(String Status, Id studContactId, Id LCContactId, String Type){
        return new hed__Relationship__c(
            hed__Status__c = Status,
            hed__Contact__c = studContactId,
            hed__RelatedContact__c = LCContactId,
            hed__Type__c = Type
        );
    }        
    
    public hed__Program_Enrollment__c createNewProgramEnrollment(Id studContactId, Id programAcctId, String Status){
        return new hed__Program_Enrollment__c(
            hed__Contact__c = studContactId,
            hed__Account__c = programAcctId,
            Status__c = Status
        );
    }
   
    public list<hed__Program_Enrollment__c> createListOfProgramEnrolls(Id studContactId, Id programAcctId, String Status, Integer count){
        list<hed__Program_Enrollment__c> programEnrollList = new list<hed__Program_Enrollment__c>();
        
        for(Integer x=0; x < count; x++){
            hed__Program_Enrollment__c programEnrollObj = createNewProgramEnrollment(studContactId, programAcctId, Status);
            programEnrollList.add(programEnrollObj);
        }
        
        return programEnrollList;
    } 
    
    public PermissionSet createPermissionSet(String permSetLabel, String permSetName){
        return new PermissionSet(Label = permSetLabel, Name = permSetName);
    } 
}