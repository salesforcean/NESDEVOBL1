/***
 * Created by Jagadish Babu on 6 June 2020 for US 148923
 * Class Name : NES_RegisterDoubleOptInCls
 * Test Class Name :
 * Purpose : Register double OptIn for to send SMS to Care Taker user during registration process
**/
public class NES_RegisterDoubleOptInCls {

    private static Peak_ApexLog logger = new Peak_ApexLog('RegisterDoubleOptIn');
    @TestVisible private static String apigeeAccessToken = null;
    
    //Check whether Sandbox or Production
    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }
    
    //Service details stored in custom meta data
    public static Double_OptIn_Settings__mdt getServiceDetails(){       
        Map<Boolean, Double_OptIn_Settings__mdt> tempMap = new Map<Boolean, Double_OptIn_Settings__mdt>();
       for(Double_OptIn_Settings__mdt tempSetting : [Select Id,IsSandBox__c,API_Key_Header_Tag__c,Session_Header_Tag__c,Username_Header_Tag__c,Password_Header_Tag__c,MasterLabel,DeveloperName,Keyword__c,ShortCode__c,API_Key__c,MC_Service_URL__c from Double_OptIn_Settings__mdt]){
            tempMap.put(tempSetting.IsSandBox__c, tempSetting);
        }           
        if(runningInASandbox)
            return tempMap.get(runningInASandbox);             
        else 
            return tempMap.get(!runningInASandbox);            
    }
    
    //Call to Apigee to enable double OptIn in Marketing cloud
    //This is called from NES_IdamUtilities class to after Care taker is registered
    //Apigee will send the details and Marketing cloud will send SMS to Care taker to phone which is given when registering
    public static void enableSMSService(List<String> mobileNums){
        
        Double_OptIn_Settings__mdt doubleOptInSetting = getServiceDetails();
        
        if(mobileNums.size() > 0){
            //Code if we have to get access Token
            if(apigeeAccessToken == null)
                apigeeAccessToken = getApigeeAccessToken(doubleOptInSetting.Username_Header_Tag__c,doubleOptInSetting.Password_Header_Tag__c);          
            //Callout to Apigee with access token to enable double OptIn with the parameters given by Apigee Team
            if(String.isNotBlank(apigeeAccessToken)){
                //Preparing Request body
                RequestDetail data = new RequestDetail();
                data.mobileNumbers = mobileNums;
                data.messageText = doubleOptInSetting.Keyword__c;
                data.shortCode = doubleOptInSetting.Shortcode__c;
                String requestBody = JSON.serialize(data);
                system.debug('requestBody****'+requestBody);
                //Adding Header details
                Map<String, String> formData = new Map<String, String>();
                formData.put(doubleOptInSetting.API_Key_Header_Tag__c,doubleOptInSetting.API_Key__c);
                formData.put(doubleOptInSetting.Session_Header_Tag__c,apigeeAccessToken);
                
                HttpResponse response= getResponse(requestBody,doubleOptInSetting.MC_Service_URL__c,'POST',formData);
                if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                    system.debug('enableSMSService success'+response.getBody());
                    logger.logInfo('enableSMSService', 'Double OptIn enabled for '+string.join(mobileNums,',')+' Response from MC '+response.getStatusCode());                     
                }
                else{
                    system.debug('enableSMSService failed'+response.getBody());
                    logger.logInfo('enableSMSService', 'Double OptIn not enabled for '+string.join(mobileNums,',')+' Response from MC '+response.getStatusCode());                    
                }             
            }
                        
        }
    }
    
    
    //This method will be invoked when the access token is required from apigee team to invoke service
    @TestVisible

    private static String getApigeeAccessToken(String uNameHeader, String pNameHeader){
        //Http Callout to get response and token value
        Map<String, String> formData = new Map<String, String>();
        formData.put(uNameHeader, '{!$Credential.Username}');
        formData.put(pNameHeader, '{!$Credential.Password}');
        HttpResponse response = getResponse('','callout:Apigee_Credentials/auth/json/pearson/authenticate','POST',formData); 
        if(response.getStatusCode() == 200){
            try{
                //Parse response and get access token from response
                NES_RegisterDoubleOptInCls.ApigeeTokenDetail jsonResponse = (NES_RegisterDoubleOptInCls.ApigeeTokenDetail) JSON.deserialize(response.getBody(), NES_RegisterDoubleOptInCls.ApigeeTokenDetail.class);

                apigeeAccessToken = jsonResponse.tokenId;
                system.debug('apigeeAccessToken--->'+apigeeAccessToken);
                logger.logInfo('getApigeeAccessToken', 'token retrieved successfully: '+apigeeAccessToken);
                return apigeeAccessToken;
            }
            catch(Exception e){
                System.debug('Exception******'+e);
                logger.logException('getApigeeAccessToken', e);
                logger.saveLogs();
                return null;

            }
        }       
        return null;
    }
    
    //Call out to Agigee system which will make callout to Marketing Cloud to provide double OptIn for Care taker user

    private static HttpResponse getResponse(String reqBody, String endPointUrl, String methodName,Map<String, String> formData ){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointUrl);
        //Set timeout
        req.setTimeout(60000);
        //Set method type
        req.setMethod(methodName);
        //Set header value for access token
        if (reqBody == '') {
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');                 
        }  
        else{
            req.setHeader('Content-Type', 'application/json');            
        }
        for (String key : formData.keySet()) {
                req.setHeader(key, formData.get(key));  
        }
        //Set request body
        req.setBody(reqBody);       
        HTTPResponse res = http.send(req);
        return res;      
    }
    
    
    
    //Request body parameters wraper
    public class RequestDetail{
        //Mobile Number to send 
        public List<String> mobileNumbers{get;set;}
        //Short code for Market Cloud through Apigee
        public String shortCode{get;set;}
        //Keyword for Market Cloud through Apigee
        public String messageText{get;set;} 
    }
    
    
    //Response body parameters wraper for Apigee Token
    public class ApigeeTokenDetail{
        public String tokenId{get;set;}
        public String successUrl{get;set;}
        public String realm{get;set;}
    }
    
    
}