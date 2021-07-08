/**
 * Created by triciaigoe on 11/29/18.
 * Change Log:
 *         2019-08-27 modified for Task #106070 on createRecords Method(from line 62 to 72)(Maddileti Boya) 
 *         2019-10-02 #US102165 (Andrew Sim) 
 *         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
 */
public without sharing class NES_RegistrationUtils {
    public static Peak_ApexLog logger = new Peak_ApexLog('Registration');

    public static HttpResponse createHttpRequestJson(String method, String endpoint, String body, Map<String, String> headers) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
		request.setTimeout(120000);

        if (method == 'POST') {
            request.setHeader('Content-Type', 'application/json');
            if (headers != null) { 
                for (String key : headers.keySet()) { 
                    request.setHeader(key, headers.get(key));
                }
            }
            request.setBody(body);
        }
        //Send the request
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    public static HttpResponse createHttpRequest(String method, String endpoint, String body) {
        return createHttpRequestJson(method, endpoint, body, null);
    }

    public static HttpResponse createHttpRequest(String method, String endpoint, String body, Map<String, String> headers) {
        return createHttpRequestJson(method, endpoint, body, headers);
    } 


    //Create all the records associated with the registration
    public static void createRecords(String fName, String lName, String emailString, String uName, String password, String schoolId, String userId, string mName, string suffix, string zipCode, string state, string phoneType, string phone, boolean smsOptOut, String gtmHiddenFields) {

        Id houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id careTakerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();

        //Insert the Account of record type Household
        Account newAccount = new Account();
        // #US102165 (Andrew Sim)
        newAccount.Name = lName + ' Household';
        newAccount.RecordTypeId = houseHoldRecordTypeId;
        newAccount.OwnerId = System.Label.NES_Household_OwnerId;
        newAccount.Email__c = emailString;
		newAccount.ShippingState  = state;
		newAccount.ShippingPostalCode = zipCode;
        try {
            insert newAccount;
        } catch(Exception e) {logger.logException('createRecords', e); logger.saveLogs();throw e;
        }

        //Insert Contact record for the using the user input
        System.debug(newAccount.Id + '/' + careTakerRecordTypeId + '/' + fName + '/' + lName);
        Contact careTaker = createContact(newAccount.Id, careTakerRecordTypeId, fName, lName, '', '', emailString, mName, suffix, phoneType, phone, smsOptOut, gtmHiddenFields);
         //Bug #106070 - New functionality -  first name, last name, and the same email address used in new registration was added.
         Integer len = 3;
         String str = string.valueof(Math.abs(Crypto.getRandomLong()));
         String randomNumber = str.substring(0, len);
         
        //Insert User record with community profile
        Profile communityProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Caretaker Community User'];
          
        User newUser = new User();
        newUser.FirstName = fName;
        newUser.LastName = lName;
        newUser.MiddleName = mName; /* Added by Alex Chisholm for BUG 124603 */
        newUser.Username = emailString + '.' + Label.NES_Username_suffix+''+randomNumber;
        newUser.Alias = (fName.length() >2 ? fName.substring(0, 2) : fName) + (lName.length() > 2 ? lName.substring(0, 2) : lName);
        newUser.Email = emailString;
        newUser.CommunityNickname = uName;
        newUser.ProfileId = communityProfile.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        //newUser.FederationIdentifier = userId;
     //   Swapna: Changed for US 110616
        newUser.FederationIdentifier = uName;
        newUser.PearsonUID__c = userId;
        newUser.ContactId = careTaker.Id;
        newUser.Document_Authorization__c = NES_Constants.DOCUMENT_AUTHORIZATION_CT;
        
        try {
            insert newUser;
            System.debug('The creation of user here:'+newUser);
        } catch(Exception e) { logger.logException('createRecords', e); logger.saveLogs();  throw e;  }

        //Jagadish Babu : Invoke Double OptIn Apigee Service to Marketing Cloud 
        //to send SMS to Care Take on Registration for US 148923
        system.debug('---SMS OptIN functionality Entered---'+smsOptOut);
        if(!smsOptOut){
            system.debug('---SMS OptIN functionality Entered---');
            NES_IdamUtilities.optInSMS(careTaker.Id);
        }

        //Check for school id parameter and insert the Enrollment accordingly.
        if (String.isNotBlank(schoolId)) {

            //Query the Account Based on the School Id Parameter
            List<Account> schools = [SELECT Id, School_Id__c FROM Account WHERE School_Id__c = :schoolId LIMIT 1];
            if (schools.size() > 0) {
                careTaker.inputParameter__c = schools[0].Id;
               careTaker.Commuity_User__c = newUser.Id;    //Swapna:Added to set the community user info
                try {
                    update careTaker;
                } catch(Exception e) { logger.logException('createRecords', e); logger.saveLogs(); throw e;  }
            }
          
            //Swapna:Added to set the community user info
            else{
            careTaker.Commuity_User__c = newUser.Id;
                try {
                    update careTaker;
                } catch(Exception e) { logger.logException('createRecords', e); logger.saveLogs();  throw e;   }
            
        }

        }
       
        //Swapna:Added to set the community user info
        else{
            careTaker.Commuity_User__c = newUser.Id;
                try {
                    update careTaker;
                } catch(Exception e) { logger.logException('createRecords', e);  logger.saveLogs();  throw e;  }
            
        }
        
    }

    public static Contact createContact(String accountId, String recordTypeId, String fName, String lName, String relationshipId, String caretakerId, String emailString, string mName, string suffix, string phoneType, string phone, boolean smsOptOut, String gtmHiddenFields) {
        Contact newContact = new Contact();
        newContact.AccountId = accountId;
        newContact.FirstName = fName;
        newContact.LastName = lName;
        newContact.Email = emailString;

        newContact.MiddleName = mName;
		newContact.Suffix = suffix;
		newContact.hed__PreferredPhone__c = phoneType;
		if (phoneType == 'Home')
			newContact.HomePhone = phone;
		else if (phoneType == 'Work')
			newContact.hed__WorkPhone__c = phone;
		else if (phoneType == 'Mobile')
			newContact.MobilePhone = phone;
		else
			newContact.OtherPhone = phone;

		newContact.HasOptedOutOfSMS__c = smsOptOut;
        
        if (recordTypeId != null && recordTypeId != '') {
            newContact.RecordTypeId = recordTypeId;
        }
        newContact.OwnerId = System.Label.NES_Household_OwnerId;
        System.debug(newContact);
        List<Contact> caretakers = new List<Contact>();
        if (caretakerId != '' && caretakerId != null) {
            newContact.Caretaker_Id__c = caretakerId;
            caretakers = [SELECT Id FROM Contact WHERE Id = : caretakerId];
            for(Contact caretaker : caretakers) {
                caretaker.Recalculate_Sharing__c = true;
            }
        }
        //pupulate GTM values to Care taker contact for US 200242
        if(String.isNotBlank(gtmHiddenFields)){
            Map<String, String> GTMHiddenFieldsMap = (Map<String,String>) JSON.deserialize(gtmHiddenFields, Map<String,String>.class);
            newContact.GA_ClientID__c = GTMHiddenFieldsMap.get('clientID');
            newContact.GA_Device_Type__c = GTMHiddenFieldsMap.get('device_type');
            newContact.GA_Keyword__c = GTMHiddenFieldsMap.get('keyword');
            newContact.GA_Campaign_Name__c = GTMHiddenFieldsMap.get('campaignName');
            newContact.GA_UTM_Source__c = GTMHiddenFieldsMap.get('utm_source');
            newContact.GA_UTM_Medium__c = GTMHiddenFieldsMap.get('utm_medium');
            newContact.GA_ExperimentID__c = GTMHiddenFieldsMap.get('experimentID');
            newContact.GA_Timestamp__c = GTMHiddenFieldsMap.get('timestamp');
            newContact.GA_gclickid__c = GTMHiddenFieldsMap.get('gclickid');            
        }
        System.debug(newContact);
        try {
            insert newContact;
            update caretakers;
        } catch(Exception e) { logger.logException('createContact', e);  logger.saveLogs();  throw e;  }

        return newContact;
    }

    public class IdentityCreate {
        @AuraEnabled public IdentityCreateProfile profile { get; set; }
        @AuraEnabled public IdentityCreateCredential credential { get; set; }
        @AuraEnabled public String redirectUrl { get; set; }

        public IdentityCreate(String firstNameString, String lastNameString, String emailString, String usernameString, String passwordString) {
            this.profile = new IdentityCreateProfile();
            this.profile.firstName = firstNameString;
            this.profile.lastName = lastNameString;
            this.profile.email = emailString;

            this.credential = new IdentityCreateCredential();
            this.credential.pearsonConnexusUsername = usernameString;
            this.credential.password = passwordString;
            if (!Test.isRunningTest())
                this.redirectUrl = ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl + System.label.NES_Initial_Community_Start_Page;
        }
    }

    public class IdentityCreateProfile {
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String homeCountryCode = 'US';
    }

    public class IdentityCreateCredential {
        @AuraEnabled public String pearsonConnexusUsername { get; set; }
        @AuraENabled public String password { get; set; }
    }

    public class IdentitiesResponse {
        public IdentitiesResponseData data { get; set; }
    }
    public class IdentitiesResponseData {
        public String pearsonConnexusUserId { get; set; }
        public String pearsonConnexusUsername { get; set; }
    }
    //2020-02-24 #US140695 First name,Last name and Email Validation (Maddileti) 
    public static Boolean checkVaidName(String name){
        list<String> checkChars = new list<String>{'<', '>', '&' ,'?','"'};
        for(String sInd:checkChars){
            if(name.contains(sInd)){ 
                return true;
            }
        }
        return false;
    }
     public static Boolean checkVaidemail(String emailAddress){
       if(!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))', emailAddress))
        {
            //handle the error
            //emailValidationMessage = 'Please provide a valid email address';
            return true;
        }
        return false;
    }
}