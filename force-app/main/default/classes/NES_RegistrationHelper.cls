/**
 * Created by triciaigoe on 11/29/18.
 * Change Log:
 *         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
 *         019-11-13 #US116612 Additional fields for the Add Student process (Anitha P) 
 */

public without sharing class NES_RegistrationHelper {
    private static Peak_ApexLog logger = new Peak_ApexLog('RegistrationHelper');

    public static Peak_Response createNewRecords(String fName, String lName, String emailString, String uName, String password, String schoolId, string mName, string suffix, string zipCode, string state, string phoneType, string phone, boolean smsOptOut, String gtmHiddenFields) {
        Peak_Response peakResponse = new Peak_Response();
    system.debug(fName+lName+emailString+uName+password+schoolId+mName+suffix+zipCode+state+phoneType+phone);

        String idamAccessToken = NES_IdamUtilities.getIdamAccessToken();
        if (idamAccessToken == null) {
            // unable to retrieve access token, pass to front-end
            peakResponse.success = false;
            // TODO: Move to Label
            peakResponse.messages.add('Unable to register, please contact the administrator.');

            logger.logError('createNewRecords', 'Idam token null');
            logger.saveLogs();

            return peakResponse;
        }


        //if all values are not blank, proceed.  If not, just return the peakResponse 
        if (String.isNotBlank(fName) && String.isNotBlank(lName) && String.isNotBlank(emailString) && string.isNotBlank(uName) && String.isNotBlank(password) && String.isNotBlank(zipCode) && String.isNotBlank(state) && String.isNotBlank(phoneType) && String.isNotBlank(phone)) {
            //2020-02-25 #US140695 Code is moved from the line before NES_RegistrationUtils.createRecords line 86 to here as validation is supposed to 
            // happen first and then the rest of the logic. (Krishna Peddanagammol)
            //2020-02-24 #US140695 First name,Last name and Email Validation (Maddileti) 
            if(NES_RegistrationUtils.checkVaidName(fName)){
                System.debug('in error validation check true---->');
                 peakResponse.messages.add('Invalid FirstName.');
                peakResponse.messages.add('Invalid FirstName.');
                peakResponse.messages.add('Invalid FirstName.');
                peakResponse.success = false;
                return peakResponse;
            }
            if(NES_RegistrationUtils.checkVaidName(lName)){
                System.debug('in error validation check true---->');
                 peakResponse.messages.add('Invalid LastName.');
                peakResponse.messages.add('Invalid LastName.');
                peakResponse.messages.add('Invalid LastName.');
                peakResponse.success = false;
                return peakResponse;
            }
             if(NES_RegistrationUtils.checkVaidemail(emailString)){
                System.debug('in error validation check true---->');
                 peakResponse.messages.add('Invalid Email.');
                peakResponse.messages.add('Invalid Email.');
                peakResponse.messages.add('Invalid Email.');
                peakResponse.success = false;
                return peakResponse;
            }
              // 2020-02-24 #US140695 First name,Last name and Email Validation (Maddileti)

            //Initialize the wrapper object and its properties for request
            NES_RegistrationUtils.IdentityCreate data = new NES_RegistrationUtils.IdentityCreate(fName, lName, emailString, uName, password);
            //Create JSON for HttpRequest
            String payLoad = JSON.serialize(data);
            system.debug('payLoad-'+payLoad);

            logger.logInfo('createNewRecords', 'IdentityCreate payload:  ' + payLoad);

            //Send message to forge rock for creating a new account            
            Map<String, String> headers = new Map<String, String>{
                    'X-Ctx-AccessToken' => idamAccessToken
            };

            HTTPResponse response = NES_RegistrationUtils.createHttpRequest('POST', 'callout:Idam_Credentials/v1/identities', payLoad, headers);
            logger.logInfo('createNewRecords', 'response+++' + response.getBody() + 'Status Code' + response.getStatusCode());

            //Check for the success status code and then create the required objects
            if (response.getStatusCode() == 201) {

                 logger.logInfo('createNewRecords', 'Forge Rock Success' + response.getStatusCode());

                // try to create all associated records, send a false success if it fails
                try {
                    NES_RegistrationUtils.IdentitiesResponse createResult =
                            (NES_RegistrationUtils.IdentitiesResponse) JSON.deserialize(
                                    response.getBody(),
                                    NES_RegistrationUtils.IdentitiesResponse.class);
                    logger.logInfo('createNewRecords', 'Identities response: ' + String.valueOf(createResult));
                   
                    NES_RegistrationUtils.createRecords(fName, lName, emailString, uName, password, schoolId, createResult.data.pearsonConnexusUserId, mName, suffix, zipCode, state, phoneType, phone, smsOptOut, gtmHiddenFields);
                    
                    peakResponse.messages.add('Records are created successfully');
                    peakResponse.success = true;
                    logger.logInfo('createNewRecords', 'User created successfully: ' + uName + ', ' + createResult.data.pearsonConnexusUserId);

                } catch (Exception e) {
                    peakResponse.success = false;
                    peakResponse.messages.add(e.getMessage());
                    logger.logException('createNewRecords', e);
                }
            } else {
                peakResponse.success = false;
                peakResponse.messages.add('Received error status: ' + response.getStatusCode());
                peakResponse.messages.add('Response: ' + String.valueOf(response));
                peakResponse.messages.add(response.getBody());
                if (response.getBody().contains('already exists')) {
                    logger.logWarn('createNewRecords', 'Duplicate Username: ' + response.getStatusCode() + ', ' + response.getBody() + ', '+uName);
                } else {
                    logger.logError('createNewRecords', 'Non-200 status code: ' + response.getStatusCode() + ', ' + response.getBody() + ', '+uName);
                }
            }
        } else {
            logger.logError('createNewRecords', 'Encountered blank data as input');
        }
        logger.saveLogs();
        return peakResponse;
    }

    // Verifies username is available from forge rock
    public static Peak_Response verifyUsername(String userInput) {
        Peak_Response peakResponse = new Peak_Response();
        peakResponse.success = true;

        //if there is input, create and send request, else return
        if (String.isNotBlank(userInput)) {
            String endpoint = 'callout:Open_Id_Credentials/v1/identities/' + userInput;

            //Sends request and receives response
            HTTPResponse response = NES_RegistrationUtils.createHttpRequest('HEAD', endpoint, userInput);
            System.debug('response+++' + response.getBody());

            //if response comes back successful, username is not available
            if (response.getStatusCode() == 200) {
                peakResponse.success = false;
                peakResponse.messages.add('UserName not available');
            }
        }
        return peakResponse;
    }

    //Grabs all the student data for the logged in caretaker
    public static NES_EvaluateUtil.NewStudentData grabStudents() {

        Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Id processId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Process').getRecordTypeId();

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

        List<Account> institutionTempAccounts = [
                SELECT Id, Name, (SELECT Id, Name FROM ChildAccounts)
                FROM Account
                WHERE RecordTypeId = :institutionRecordTypeId
        ];

        System.debug('insti: ' + institutionTempAccounts);
        Set<Account> institutionSet = new Set<Account>();

        //loop through institutions to grab all the ones with valid academic programs
        for (Account institution : institutionTempAccounts) {

            //if they have an academic program, we want to return to the school list
            if (institution.ChildAccounts.size() > 0) {
                for (Account child : institution.ChildAccounts) {
                    if (programIds.contains(child.Id)) {
                        institutionSet.add(institution);
                        System.debug('institutions: ' + institutionSet);
                    }
                }
            }
        }
        List<Account> institutions = new List<Account>();
        institutions.addAll(institutionSet);


        // Create empty lists for return to user
        List<School_Year__c> schoolYears = new List<School_Year__c>();
        List<Grade_Level__c> gradeLevels = [SELECT Id, Name FROM Grade_Level__c];

        Account defaultAcc = new Account();
        List<hed__Program_Enrollment__c> programEnrollmentsList = relatedProgramEnrollments(UserInfo.getUserId());

        // if there are program enrollments for this caretaker
        if (programEnrollmentsList.size() > 0) {
            if (programEnrollmentsList[0].hed__Account__c != null) {
                defaultAcc = [SELECT Id, Name FROM Account WHERE Id = :programEnrollmentsList[0].hed__Account__c LIMIT 1];
            }
        }

        NES_EvaluateUtil.NewStudentData data = new NES_EvaluateUtil.NewStudentData('', '','','', '', '', '', '', defaultAcc, schoolYears, institutions, gradeLevels);//added for US116612 
        return data;
    }

    // Finds all the students related to this caretaker and returns their program enrollments
    public static List<hed__Program_Enrollment__c> relatedProgramEnrollments(Id userId) {
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        User careTaker = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        System.debug('caretaker: ' + careTaker.ContactId);
        List<Id> studentIds = new List<Id>();

        //Grab all the student relationships for this caretaker
        List<hed__Relationship__c> relationships = [
                SELECT hed__RelatedContact__r.Id
                FROM hed__Relationship__c
                WHERE hed__Contact__c = :careTaker.ContactId
                AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
        ];

        for (hed__Relationship__c relationship : relationships) {
            system.debug('student: ' + relationship.hed__RelatedContact__r.Id);
            studentIds.add(relationship.hed__RelatedContact__r.Id);
        }

        //Grab all the program enrollments for these students
        List<hed__Program_Enrollment__c> enrollments = [
                SELECT CreatedById, CreatedDate, hed__Account__c, hed__Admission_Date__c,
                        hed__Affiliation__c, hed__Application_Submitted_Date__c, hed__Class_Standing__c,
                        hed__Contact__c, hed__Credits_Attempted__c, hed__Credits_Earned__c,
                        hed__Eligible_to_Enroll__c, hed__End_Date__c, Status__c,
                        hed__GPA__c, hed__Graduation_Year__c, hed__Program_Plan__c, hed__Start_Date__c,
                        Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate,
                        LastViewedDate, Name, OwnerId, SystemModstamp, Viewed_Final_Confirmation__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :studentIds
                ORDER BY CreatedDate ASC
        ];
        return enrollments;

    }

    //Searches community users for the email and returns true if found, false if there is no user
    public static Boolean doesEmailExist(String emailString) {
        List<User> careTakerUser = new List<User>([SELECT ID, ContactId,Contact.Name FROM User WHERE Profile.Name = 'Caretaker Community User' AND Email = :emailString AND IsActive = TRUE]);

        //if any caretakers exist with that email, return true, otherwise return false
        if (careTakerUser.size() > 0) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: ID, String
     * Return Type: Peak_Response
     * Purpose : Task #66396, this method is used to save the InputParameter__c on the contact record
    */
    public static Peak_Response saveInputParameter(Id contactID, String parameter) {
        Peak_Response peakResponse = new Peak_Response();

        try {
            update new Contact(Id = contactID, InputParameter__c = parameter);
            peakResponse.success = true;
            peakResponse.messages.add('Input parameter saved successfully');
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('saveInputParameter', e);
            logger.saveLogs();
        }

        return peakResponse;
    }

    /**
     * Created by Ashish Sharma on 12/21/18
     * Parameters: ID
     * Return Type: Peak_Response
     * Purpose : Task #66396, this method is used to gey the InputParameter__c from the contact record
    */
    public static Peak_Response getInputParameter(Id contactID) {
        Peak_Response peakResponse = new Peak_Response();

        try {
            if (contactID == null) {
                peakResponse.success = false;
                peakResponse.messages.add('Error: contactID is blank');
            }

            for (Contact contact : [SELECT InputParameter__c FROM Contact WHERE Id = :contactID]) {
                if (String.isNotBlank(contact.InputParameter__c)) {
                    peakResponse.success = true;
                    peakResponse.parameter = contact.InputParameter__c;
                } else {
                    peakResponse.success = false;
                }
            }
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('getInputParameter', e);
            logger.saveLogs();
        }

        return peakResponse;
    }

    
     //added for the US166467 : Jagadeesh
     /** purpose : To verify usename availability **/
    public static Peak_Response verifyUsernameAvailabilty(String userInput) {
        Peak_Response peakResponse = new Peak_Response();

        if (String.isNotBlank(userInput)) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Apigee_Credentials/openidm/endpoint/checkUsernameAvailability/' + userInput);
            req.setMethod('GET');
            req.setHeader('X-OpenIDM-Password', '{!$Credential.Password}');
            req.setHeader('X-OpenIDM-Username', '{!$Credential.Username}');
            HttpResponse response = h.send(req);
            system.debug('res******'+response.getbody());
            resParameter ref = (resParameter)json.deserialize(response.getBody(),resParameter.class);
            if (response.getStatusCode() == 200) {                
                if(ref.isUsernameAvailable == false){
                    peakResponse.success = false;
                   }
                else{
                    peakResponse.success = true;
                     } 
            }
            else{
                logger.logError('verifyUsernameAvailabilty', 'Non-200 status code: ' + response.getStatusCode() + ', ' + response.getBody() + ', '+userInput);
                logger.saveLogs();  
                }
        }        
        return peakResponse;
    } 
    
     //added for the US166467 : Jagadeesh
    public class resParameter{
        public Boolean isUsernameAvailable {get;set;}
    }
    
}