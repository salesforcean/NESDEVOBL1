/*
* Purpose: Controller for NES_DocumentFileRefViewer VF Page
* Change Log:
*         2019-08-14 initial for #101928 User Story (Andrew Sim)
*         2019-09-11 fix to handle spaces in file names #102150/106220 (Andrew Sim)
*         2019-09-13 added method to support html responses and handle line breaks #102150/106220 (Andrew Sim)
*         2019-09-17 added method to improve decoding ISO 8859-1 and remove support for TIF #102150/106220 (Andrew Sim)
*         2020-06-19 removed methods no longer used (Mark Membrino)
*/
public with sharing class NES_DocumentFileRefViewerController {
    
    public Boolean isImage { get { return (extension=='png' || extension=='gif' || extension=='jpg' || extension=='jpeg') ? true : false; } set; }    
    public Boolean isPDF { get { return (extension=='pdf') ? true : false; } set; }    
    public Boolean isText { get { return (extension=='txt') ? true : false; } set; }
    public Boolean isAuthenticated { get { return (authToken!='') ? true : false; } set; }
    
    public Id dfrId { get; set; }    
    public Id accountId { get; set; } 
    public String extension { get; set; } 
    public String url { get; set; } 
    public String authToken { get; set; }
    
    // constructor to set the Document File Reference Id when passed by URL
    public NES_DocumentFileRefViewerController() {
        
        // extract the document file reference id
        dfrId = apexpages.currentpage().getparameters().get('c__dfrId');
        System.assertNotEquals(null, dfrId, 'Missing parameter: c__dfrId');

        // initialize 
        url = System.Label.NES_FileUploadEndpoint;
        authToken = '';
        extension = '';
        accountId = null;
        
        // determine the file type
        List<Document_File_References__c> dfrList = [select Id, Name, File_Path__c, Enrollment_Document__c from Document_File_References__c where id = :dfrId limit 1];

        System.assertNotEquals(0, dfrList.size(), 'No records found!');
        
        if (dfrList.size()>0) {
            Document_File_References__c dfr = [select Id, Name, File_Path__c, Enrollment_Document__c from Document_File_References__c where id = :dfrId limit 1];
            extension = dfr.File_Path__c.substring(dfr.File_Path__c.lastIndexOf('.')+1, dfr.File_Path__c.length()).toLowerCase();
            
            // generate the target url 
            url = url + '/' + dfr.File_Path__c;
            
            // obtain the account id
            Enrollment_Document__c ed = [select Id, Program_Enrollment_AccountId__c from Enrollment_Document__c where id = :dfr.Enrollment_Document__c limit 1];
            accountId = ed.Program_Enrollment_AccountId__c;
            
            system.debug('accountId:' + accountId);
            system.debug('extension:' + extension);
            system.debug('url: ' + url);
        }
    }
    
    // allows vfp to set authToken
    // public PageReference setAuthToken() {
    //     authToken = Apexpages.currentPage().getParameters().get('authToken');
    //     return null;
    // }
    
    // returns the data for rendering
    // public String getResponse() {
        
    //     HttpRequest request = new HttpRequest();
    //     HttpResponse result;
        
    //     request.setMethod('GET');
    //     // asim replace space with correct encoding us/bug #102150/106220
    //     request.setEndpoint(url.replace(' ', '%20'));
    //     request.setHeader('x-ctx-currentapplication', 'enrollment');
    //     request.setHeader('x-ctx-authentication', authToken);
    //     if (accountId!=null) request.setHeader('x-ctx-locationid', accountId);        
    //     try {
    //         Http http = new Http();
    //         result = http.send(request);
    //     } catch(System.CalloutException e) {
    //         System.debug('Exception: '+ e);
    //         return e.getMessage();
    //     }
        
    //     if (isText) {
    //         return blobToString(result.getBodyAsBlob(), 'ISO 8859-1');
    //     } else {
    //         return EncodingUtil.base64Encode(result.getBodyAsBlob());
    //     }
        
    // }

    // decode blob to a charset
    // public static String blobToString(Blob input, String inCharset){
    //     String hex = EncodingUtil.convertToHex(input);
    //     final Integer bytesCount = hex.length() >> 1;
    //     String[] bytes = new String[bytesCount];
    //     for(Integer i = 0; i < bytesCount; ++i)
    //         bytes[i] =  hex.mid(i << 1, 2);
    //     return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    // }
    
    // // returns the data for rendering with line breaks US/BUG #102150/106220 
    // public String getResponseHTML() {        
    //     return getResponse().replaceAll('\\n', '<br/>');
    // }
    
}