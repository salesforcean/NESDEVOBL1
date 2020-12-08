/**
 * Created by Ashish Sharma on 12/24/18
 * Class Name: NES_IdamUtilities
 * Test Class Name: NES_IdamUtilitiesTest
 * Purpose : Utility class for IDAM integration
 * 
 * Change Log: 
 * 
 * 	Sumanth:20 Aug 2020: Added an If condition for Document Status in 'pushUserInfoToSIS' method for US # 216780
 *  Guravaiah Gunturi: 24 August 2020: Added an "generateGUID" method  for US# 229433
 *  Sumanth:06 Oct 2020: Added docStatusReason,docStatusText in 'pushUserInfoToSIS' method and added docStatusReason,docStatusText variables
 *  in 'pushUserInfoToSISRequest' method as per ADO US # 285971
*/
public class NES_IdamUtilities {
    private static Peak_ApexLog logger = new Peak_ApexLog('IdamUtilities');
    
    // USER STORY #. 216768 and USER STORY #. 216772 
    // Created By: Sumanth Krishna & Rakesh Ramaswamy    
	public pushUserInfoToSISRequest userInfoReq;
        
    /**
     * Created by Ashish Sharma on 12/24/18
     * Parameters: Set<Id>
     * Return Type: N/A
     * Purpose : Method to send message to SIS with Program Enrollment Id to retrieve student information
    */
    @future(callout=true)
    public static void pushToSIS(Set<Id> programEnrollmentIds) {
        //MM 9/18/2020  Making some changes to how we decide which closed Program Enrollments cause a send to SIS.
        //  1. We have not been sending reenrollments for a while but that logic was enforced in the handler, that is now
        //     being enforced here.
        //  2. There is a new requirement to not send California schools to SIS.  For that, we added a new field to the 
        //     Academic Program called 'Restrict_to_SIS__c'. If that is checked on the AP for the PE we were passed, don't
        //     send to SIS, just update the SIS_Integration_Status__c to 'Restricted to SIS'
        set <Id> PEsToSendToSIS = new Set<Id>();  //Program Enrollments that go to SIS
        set <Id> PEsForRestrictedAPs = new Set<Id>(); //Program Enrollments that are tied to an Academic Program that restricts the send.
        for (hed__Program_Enrollment__c pe:[select id, hed__Account__r.Restrict_to_SIS__c, Enrollment_Type__c from hed__Program_Enrollment__c where id in :programEnrollmentIds]) {
            if (pe.Enrollment_Type__c == 'Initial Enrollment') {
                if (!pe.hed__Account__r.Restrict_to_SIS__c) 
               //     PEsForRestrictedAPs.add(pe.id); //Sumanth:25-Oct-20:Commented out as this functionality is being moved to Flow:CS_PushEnrollmentToV2SystemsFlow as part of US # 334984
               // else                               //Sumanth:25-Oct-20:Commented out as this functionality is being moved to Flow:CS_PushEnrollmentToV2SystemsFlow as part of US # 334984
                    PEsToSendToSIS.add(pe.id);
            }
        }

        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>();

        if (PEsToSendToSIS != null && PEsToSendToSIS.size() > 0) {
            idamAccessToken = getIdamAccessToken();

            if (String.isNotBlank(idamAccessToken)) {
                for (Id enrollmentId : PEsToSendToSIS) {
                    hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(Id = enrollmentId, SIS_Integration_Status__c = pushEnrollmentToSIS(enrollmentId));
                    programEnrollments.add(pe);
                }
            }
        }
		//Sumanth:25-Oct-20:Commented out as this functionality is being moved to Flow:CS_PushEnrollmentToV2SystemsFlow as part of US # 334984
     /*   if (PEsForRestrictedAPs != null && PEsForRestrictedAPs.size() > 0) {
            for (Id enrollmentId : PEsForRestrictedAPs) {
                hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c(Id = enrollmentId, SIS_Integration_Status__c = 'Restricted to SIS');
                programEnrollments.add(pe);
            }
        }*/ 

        if (programEnrollments.size() > 0) {
           try {
               logger.logInfo('pushToSIS', 'Updating PEs with SIS Integration Status: '+programEnrollmentIds);
               Database.update(programEnrollments, false);
               logger.saveLogs();
           } catch(Exception e) {
                logger.logException('pushToSIS', e);
                logger.saveLogs();
           }
        }
    }

    /**
     * Created by Ashish Sharma on 12/24/18
     * Parameters: Id
     * Return Type: N/A
     * Purpose : Method to callout for push enrollment Id to SIS
    */
    private static String pushEnrollmentToSIS(Id enrollmentId) {

        /* Updated 5/1/2019 - Alex Chisholm*/
        List<Enrollment__c> enrollments = new List<Enrollment__c>([SELECT ID From enrollment__c where Program_Enrollment__c =: enrollmentID ORDER BY CreatedDate DESC]);
        String error = '';

        if(enrollments.size() > 0) {            
            String jsonBody = '{"correlationId": "' + enrollments[0].ID + '","ApplicationName": "nes","Action":"c","Entity":"enrollment",' +
                    '"ActionContext": "finalconfirmation","AdditionalProperties":{"enrollmentId":"' + enrollments[0].ID + '"}}';
            /* End of update */

            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:Event_Emitter/v1/eventemitter');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('cache-control', 'no-cache');
            request.setHeader('x-ctx-accesstoken', idamAccessToken);
            request.setTimeout(60000);          
            request.setBody(jsonBody);

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                logger.logInfo('pushEnrollmentToSIS', 'PE pushed to SIS: '+enrollmentId);
                logger.saveLogs();
                return 'Successfully Sent to SIS';
            }

            if (response != null && response.getStatusCode() != null ) {
                logger.logError('pushEnrollmentToSIS', 'PE error in pushing to SIS: '+response.getStatusCode()+': '+response.getStatus());
                logger.saveLogs();
                error = response.getStatusCode() + (response.getStatus() != null ? ' : ' + response.getStatusCode() + ': ' + response.getStatus() : '');
            }
        }

        return error;
    }    

    //Start: Moved this code from NES_RegistrationUtils (Created By Tricia)
    @TestVisible private static String idamAccessToken = null;

    public static String getIdamAccessToken() {
        if (idamAccessToken != null) {
            logger.logInfo('getIdamAccessToken', 'cached token retrieved successfully: '+idamAccessToken);
            logger.saveLogs();
            return idamAccessToken;
        }

        Map<String, String> formData = new Map<String, String>();
        formData.put('client_id', '{!HTMLENCODE($Credential.Username)}');
        formData.put('grant_type', 'client_credentials');
        formData.put('client_secret', '{!HTMLENCODE($Credential.Password)}');
        

        HTTPResponse response = createHttpRequestFormData('POST', 'callout:Idam_Credentials/v1/authenticate/client', formData);
        if (response.getStatusCode() == 200) {
            try {
                ClientResponse jsonResponse = (ClientResponse) JSON.deserialize(response.getBody(), ClientResponse.class);
                idamAccessToken = jsonResponse.data.access_token;
                logger.logInfo('getIdamAccessToken', 'token retrieved successfully: '+idamAccessToken);
                return idamAccessToken;
            } catch (Exception e) {
                // XXX surface error correctly                
                logger.logException('getIdamAccessToken', e);
                logger.saveLogs();
                return null;
            }
        }
        return null;
    }

    public static HttpResponse createHttpRequestFormData(String method, String endpoint, Map<String, String> formData) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        request.setTimeout(60000);

        if (method == 'POST') {
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String body = '';
            for (String key : formData.keySet()) {
                if (body != '') {
                    body += '&';
                }
                body += key + '=' + formData.get(key);
            }
            request.setBody(body);
        }

        //Send the request
        HttpResponse response;
        Http http = new Http();
        try {
            response = http.send(request);
        } catch (Exception e) {
            //Retry if we fail to get the token.
            response = http.send(request);
        }

        return response;
    }        
    
     
    // USER STORY #. 216768, USER STORY #. 216772, US #. 216780, US #. 216777
    // Developed By: Sumanth Krishna & Rakesh Ramaswamy
	@InvocableMethod	
	public static void pushUserInfoToSIS(list<pushUserInfoToSISRequest> userInfoUpdtRequests){		                		      		        
        NES_IdamUtilities nesIdamUtilObj = new NES_IdamUtilities();
        nesIdamUtilObj.userInfoReq = userInfoUpdtRequests.get(0);         
        String jsonBody=' ', eventTriggeredFieldLabel = ' ', eventTriggeredFieldValue = ' ',GUID=' ';
        String callOutToSISAppName = (System.Label.Application_Name_For_SIS_CallOut == 'nes') ? 'nes' : '';
  		if(nesIdamUtilObj.userInfoReq.eventType == 'UserInfo Update'){                
                
            	eventTriggeredFieldLabel = nesIdamUtilObj.userInfoReq.eventTriggeredFieldLabel;            	
            	eventTriggeredFieldValue = nesIdamUtilObj.userInfoReq.eventTriggeredFieldValue;                
                GUID = nesIdamUtilObj.userInfoReq.contactId+generateGUID();
            	jsonBody = '{'+
				'"correlationId":"'+GUID+'",'+
                '"ApplicationName":"'+callOutToSISAppName+'",'+
                '"Entity":"User",'+
                '"Action":"u",'+
                '"actionContext":"user_u_userProfile",'+
                '"AdditionalProperties":{'+
                '"contact":"'+nesIdamUtilObj.userInfoReq.contactId+'",'+
                '"contactType":"'+nesIdamUtilObj.userInfoReq.contactRecType+'",'+
                '"userId":"'+nesIdamUtilObj.userInfoReq.userId+'"'+
                '}'+
                '}';  
                                              
        	if(jsonBody <> null)
               NES_IdamUtilities.calloutToSIS(jsonBody, nesIdamUtilObj.userInfoReq.contactId, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);
         }
         // Rakesh: Added the below code for US # 216774
         else
         if(nesIdamUtilObj.userInfoReq.eventType == 'Additional Household Member'){                
            
            eventTriggeredFieldLabel = nesIdamUtilObj.userInfoReq.eventTriggeredFieldLabel;            	
            eventTriggeredFieldValue = nesIdamUtilObj.userInfoReq.eventTriggeredFieldValue;                
            GUID = nesIdamUtilObj.userInfoReq.contactId+generateGUID();
            jsonBody = '{'+
            '"correlationId":"'+GUID+'",'+
            '"ApplicationName":"'+callOutToSISAppName+'",'+
            '"Entity":"User",'+
            '"Action":"c",'+
            '"actionContext":"User_c_household",'+
            '"AdditionalProperties":{'+
            '"contactId":"'+nesIdamUtilObj.userInfoReq.contactId+'",'+
            '"contactType":"'+nesIdamUtilObj.userInfoReq.contactRecType+'",'+
            '"userId":"'+nesIdamUtilObj.userInfoReq.userId+'",'+
            '"householdId":"'+nesIdamUtilObj.userInfoReq.householdId+'"'+
            '}'+
            '}';  
                                            
            if(jsonBody <> null)
            NES_IdamUtilities.calloutToSIS(jsonBody, nesIdamUtilObj.userInfoReq.contactId, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);
         }
         else
         if(nesIdamUtilObj.userInfoReq.eventType == 'Address Change'){                
				
             	eventTriggeredFieldLabel = nesIdamUtilObj.userInfoReq.eventTriggeredFieldLabel;
            	eventTriggeredFieldValue = nesIdamUtilObj.userInfoReq.eventTriggeredFieldValue;
             	GUID = nesIdamUtilObj.userInfoReq.householdId+generateGUID();
             	jsonBody = '{'+
				'"correlationId":"'+GUID+'",'+
                '"ApplicationName":"'+callOutToSISAppName+'",'+
                '"Entity":"User",'+
                '"Action":"u",'+
                '"actionContext":"User_u_HouseholdAddressChange",'+
                '"AdditionalProperties":{'+
                '"householdId":"'+nesIdamUtilObj.userInfoReq.householdId+'",'+
                '}'+
                '}'; 
                         
        	if(jsonBody <>  null)
               NES_IdamUtilities.calloutToSIS(jsonBody, nesIdamUtilObj.userInfoReq.householdId, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);
         }
        //Sumanth: Added the below code for US # 216780
        else
        if(nesIdamUtilObj.userInfoReq.eventType == 'Document Status'){                
              
         	eventTriggeredFieldLabel = nesIdamUtilObj.userInfoReq.eventTriggeredFieldLabel;
            eventTriggeredFieldValue = nesIdamUtilObj.userInfoReq.eventTriggeredFieldValue;
            GUID = nesIdamUtilObj.userInfoReq.docId+generateGUID();
            jsonBody = '{'+
                '"correlationId":"'+GUID+'",'+
                '"ApplicationName":"'+callOutToSISAppName+'",'+
                '"Entity":"Documents",'+
                '"Action":"u",'+
                '"actionContext":"documents_u_Status",'+
                '"AdditionalProperties":{'+
                '"documentId":"'+nesIdamUtilObj.userInfoReq.docId+'",'+
                '"documentType":"'+nesIdamUtilObj.userInfoReq.docType+'",'+
                '"documentStatus":"'+nesIdamUtilObj.userInfoReq.docStatus+'",'+
                '"householdId":"'+nesIdamUtilObj.userInfoReq.householdId+'",'+
                '"contact":"'+nesIdamUtilObj.userInfoReq.contactId+'",'+
                '"contactType":"'+nesIdamUtilObj.userInfoReq.contactRecType+'",'+
                '"userId":"'+nesIdamUtilObj.userInfoReq.userId+'",'+
                '"documentStatusText":"'+nesIdamUtilObj.userInfoReq.docStatusText+'",'+
                '"documentStatusReason":"'+nesIdamUtilObj.userInfoReq.docStatusReason+'"'+
                '}'+
                '}';  
                                           
        	if(jsonBody <> null)
               NES_IdamUtilities.calloutToSIS(jsonBody, nesIdamUtilObj.userInfoReq.docId, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);
         }
        //Rakesh: Added the below code for US # 216777
        else
        if(nesIdamUtilObj.userInfoReq.eventType == 'Ordering Hold Flag'){                
              
         	eventTriggeredFieldLabel = nesIdamUtilObj.userInfoReq.eventTriggeredFieldLabel;
            eventTriggeredFieldValue = nesIdamUtilObj.userInfoReq.eventTriggeredFieldValue;
            GUID = nesIdamUtilObj.userInfoReq.progEnrollmentId+generateGUID();
            jsonBody = '{'+
                '"correlationId":"'+GUID+'",'+
                '"ApplicationName":"'+callOutToSISAppName+'",'+
                '"Entity":"User",'+
                '"Action":"u",'+
                '"actionContext":"User_u_OrderHoldStatus",'+
                '"AdditionalProperties":{'+
                '"householdId":"'+nesIdamUtilObj.userInfoReq.householdId+'",'+
                '"programEnrollmentId":"'+nesIdamUtilObj.userInfoReq.progEnrollmentId+'",'+
                '"orderingHoldStatus":"'+nesIdamUtilObj.userInfoReq.orderingHoldStatus+'",'+                                
                '}'+
                '}';  
                                              
        	if(jsonBody <> null)
               NES_IdamUtilities.calloutToSIS(jsonBody, nesIdamUtilObj.userInfoReq.progEnrollmentId, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);
         }
	}
    
    // USER STORY #. 216768, USER STORY #. 216772, US #. 216780, US #. 216777
    // Developed By: Sumanth Krishna & Rakesh Ramaswamy
    @future(callout=true)
    public static void calloutToSIS(string jsonString, String objectRecId, String eventTriggeredFieldLabel, String eventTriggeredFieldValue,String GUID){
        NES_IdamUtilities nesIdamUtilObj = new NES_IdamUtilities();
        idamAccessToken = getIdamAccessToken();		        
		string error = ' ', responseStatus; 
                
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
            request.setMethod('POST');
            request.setEndpoint('callout:Event_Emitter/v1/eventemitter');    
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('cache-control', 'no-cache');
            request.setHeader('x-ctx-accesstoken', idamAccessToken);
            request.setTimeout(60000);                        
            request.setBody(jsonString);                        
        	
            try {
                	Http http = new Http();
                	response = http.send(request);                		                	
                	NES_IdamUtilities.pushPCxInfoToSIS(objectRecId, response, null, eventTriggeredFieldLabel, eventTriggeredFieldValue,GUID);                           
              }
           catch(Exception ex){                 
                 NES_IdamUtilities.pushPCxInfoToSIS(objectRecId, response, ex, eventTriggeredFieldLabel, eventTriggeredFieldValue, GUID);                             
           }          
    }       
    
    // USER STORY #. 216768, USER STORY #. 216772, US #. 216780, US #. 216777
    // Developed By: Sumanth Krishna & Rakesh Ramaswamy
    public static void pushPCxInfoToSIS(Id objectRecId, HttpResponse response, Exception exp, String eventTriggeredFieldLabel, String eventTriggeredFieldValue,String GUID){          	   
       Schema.sObjectType entityType = objectRecId.getSObjectType();
       String responseStatus = '';
       String error = '';
       list<sObject> sObjectList = new list<sObject>();
      
       if((response.getStatus() == null)){          
           responseStatus = eventTriggeredFieldLabel+':  '+ eventTriggeredFieldValue +' - EXCEPTION OCCURED: '+String.valueOf(response.getStatusCode()+' - GUID: '+GUID);     
           logger.logException('pushPCxInfoToSIS - EXCEPTION OCCURED - '+eventTriggeredFieldLabel+': '+eventTriggeredFieldValue+' - GUID: '+GUID, exp);
           logger.saveLogs();           
        } 
       if(response.getStatusCode() >= 200 && response.getStatusCode() < 300 && (exp == null)) {
           if((entityType != null) && String.valueOf(entityType).equals('Contact') && (eventTriggeredFieldLabel == 'Request Type') && (eventTriggeredFieldValue == 'UserInfo Update')){
               logger.logInfo('pushPcxInfoToSIS', 'UserInfo Update pushed to SIS: '+objectRecId+' - GUID: '+GUID);
           }
           else if((entityType != null) && String.valueOf(entityType).equals('Contact') && (eventTriggeredFieldLabel == 'Request Type') && (eventTriggeredFieldValue == 'Additional Household Member')){
                logger.logInfo('pushPcxInfoToSIS', 'Additional Household Member pushed to SIS: '+objectRecId+' - GUID: '+GUID);
           }
           else if((entityType != null) && String.valueOf(entityType).equals('Account')){
               logger.logInfo('pushPcxInfoToSIS', 'Address Change pushed to SIS: '+objectRecId+' - GUID: '+GUID);   
           }
           else if((entityType != null) && String.valueOf(entityType).equals('Enrollment_Document__c')){
               logger.logInfo('pushPcxInfoToSIS', 'Enrollment Document Changes pushed to SIS: '+objectRecId+' - GUID: '+GUID);   
           }
           else if((entityType != null) && String.valueOf(entityType).equals('hed__Program_Enrollment__c')){
               logger.logInfo('pushPcxInfoToSIS', 'Program Enrollment Changes pushed to SIS: '+objectRecId+' - GUID: '+GUID);   
           }
           logger.saveLogs();                                                                                    
           responseStatus = eventTriggeredFieldLabel+': '+ eventTriggeredFieldValue +' - SUCCESS: '+String.valueOf(response.getStatusCode()+' - GUID: '+GUID);           
       }                                   
	   else {
            if((response != null) && (response.getStatusCode() != null) && (exp == null)) {
               if((entityType != null) && String.valueOf(entityType).equals('Contact') && (eventTriggeredFieldLabel == 'Request Type') && (eventTriggeredFieldValue == 'UserInfo Update')){
                   logger.logError('pushPcxInfoToSIS', 'User Info error while pushing to SIS: '+response.getStatus()+': '+response.getStatusCode()+' - GUID: '+GUID);
               }
               else if((entityType != null) && String.valueOf(entityType).equals('Contact') && (eventTriggeredFieldLabel == 'Request Type') && (eventTriggeredFieldValue == 'Additional Household Member')){
                   logger.logError('pushPcxInfoToSIS', 'Additional Household Member error while pushing to SIS: '+response.getStatus()+': '+response.getStatusCode()+' - GUID: '+GUID);
               }
               else if((entityType != null) && String.valueOf(entityType).equals('Account')){
                    logger.logError('pushPcxInfoToSIS', 'Address Change error while pushing to SIS: '+response.getStatus()+': '+response.getStatusCode()+' - GUID: '+GUID);
               }
               else if((entityType != null) && String.valueOf(entityType).equals('Enrollment_Document__c')){
                    logger.logError('pushPcxInfoToSIS', 'Enrollment Document error while pushing to SIS: '+response.getStatus()+': '+response.getStatusCode()+' - GUID: '+GUID);
               } 
               else if((entityType != null) && String.valueOf(entityType).equals('hed__Program_Enrollment__c')){
                    logger.logError('pushPcxInfoToSIS', 'Program Enrollment error while pushing to SIS: '+response.getStatus()+': '+response.getStatusCode()+' - GUID: '+GUID);
               } 
                logger.saveLogs(); 
                error = response.getStatusCode() + (response.getStatus() != null ? ' : ' + response.getStatusCode() + ': ' + response.getStatus() : '');                               
                responseStatus = eventTriggeredFieldLabel+': '+ eventTriggeredFieldValue +' - FAILED: '+String.valueOf(response.getStatusCode())+' - GUID: '+GUID;     
   			}
         } 
        
       if((entityType != null) && String.valueOf(entityType).equals('Contact')){
           sObjectList.add(new Contact(id = objectRecId,Request_Type__c = null, SIS_Integration_Status__c =  responseStatus, SIS_Update_Requested__c = system.now()));                             
        }    
       else if((entityType != null) && String.valueOf(entityType).equals('Account')){
           sObjectList.add(new Account(id = objectRecId,Request_Type__c = null, SIS_Integration_Status__c =  responseStatus, SIS_Update_Requested__c = system.now()));           
       }  
       else if((entityType != null) && String.valueOf(entityType).equals('Enrollment_Document__c')){
           sObjectList.add(new Enrollment_Document__c(id = objectRecId, SIS_Integration_Status__c =  responseStatus, SIS_Update_Requested__c = system.now()));           
       }
       else if((entityType != null) && String.valueOf(entityType).equals('hed__Program_Enrollment__c')){
           sObjectList.add(new hed__Program_Enrollment__c(id = objectRecId, SIS_Integration_Status__c =  responseStatus, SIS_Update_Requested__c = system.now()));           
       }
       List<Database.SaveResult> srList = Database.update(sObjectList, false);    	   
      
       if (!srList.get(0).isSuccess()) { 
            Database.SaveResult sr = srList.get(0);
            Database.Error errObj = sr.getErrors().get(0);
            if(String.valueOf(entityType).equals('Contact'))
            	logger.logError('Method:pushPCxInfoToSIS-Failed to Update Contact Record :'+sObjectList.get(0).id+' - GUID: '+GUID, errObj.getMessage());          
            else
            if(String.valueOf(entityType).equals('Account'))
            	logger.logError('Method:pushPCxInfoToSIS-Failed to Update Account Record :'+sObjectList.get(0).id+' - GUID: '+GUID, errObj.getMessage());
            else
            if(String.valueOf(entityType).equals('Enrollment_Document__c'))
            	logger.logError('Method:pushPCxInfoToSIS-Failed to Update Enrollment Document Record :'+sObjectList.get(0).id+' - GUID: '+GUID, errObj.getMessage());
            else
            if(String.valueOf(entityType).equals('hed__Program_Enrollment__c'))
            	logger.logError('Method:pushPCxInfoToSIS-Failed to Update Program Enrollment Record :'+sObjectList.get(0).id+' - GUID: '+GUID, errObj.getMessage());
            
            logger.saveLogs();
        }
   }
    // Guruvaiah Gunturi::Added the below code for US # 229433
    // The below method used to return the GUID unique number based on Timestamp function and will appending to CorrelationId
    public static String generateGUID(){
         Datetime dt = Datetime.now();
         Long TimeStamp = dt.getTime();
         return String.valueOf(TimeStamp);
    }  
   

    //Sending Details to Marketing cloud for SMS double Opt in Functionality
    //This is called when a new care taker registers and asks to receive text
    //Marketing cloud responsible for confirming they want text
    //This call goes to apigee which flows to Marketing cloud
    @future(callOut = true)
    public static void optInSMS(Id conId){ 

        List<Contact> conListForOptIn = [Select Id, SMS_Phone_Number__c from Contact where Id=:conId];
        if(String.isNotBlank(conListForOptIn[0].SMS_Phone_Number__c)){
            List<String> mobileNumbers = new List<String>{conListForOptIn[0].SMS_Phone_Number__c};
            NES_RegisterDoubleOptInCls.enableSMSService(mobileNumbers);  
        }   
    }
    
    public class ClientResponse {
        public ClientResponseData data { get; set; }
    }

    public class ClientResponseData {
        public String client_id { get; set; }
        public String access_token { get; set; }
        public String expires_in { get; set; }
    }
    
    /*
     *  USER STORY #. 216768 and USER STORY #. 216772
     *  Developed By: Sumanth Krishna & Rakesh Ramaswamy
     *  Sumanth:06 Oct 2020: Added docStatusReason,docStatusText as per ADO US # 285971
     */
    public class pushUserInfoToSISRequest {
    @InvocableVariable   
    public string contactId;

    @InvocableVariable
    public String contactRecType;

    @InvocableVariable    
    public string userId;

    @InvocableVariable    
    public string householdId;
	
	@InvocableVariable	
 	 public String docId;

    @InvocableVariable
    public String docType;
	
	@InvocableVariable
    public String docStatus;
	
	@InvocableVariable    
    public String progEnrollmentId;
	
	@InvocableVariable
    public String orderingHoldStatus;
	
	@InvocableVariable
    public String eventType;  
    
    @InvocableVariable
    public String eventTriggeredFieldLabel;
    
    @InvocableVariable
    public String eventTriggeredFieldValue;
    
    @InvocableVariable
    public String docStatusReason;
    
    @InvocableVariable
    public String docStatusText;
 } 
}