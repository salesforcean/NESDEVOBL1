//Swapna:For US 113260
Public class SISUpdates{
 private static Peak_ApexLog logger = new Peak_ApexLog('SISUpdates');
@invocableMethod(label='Push Document Updates to SIS' description='Updates Document Status to SIS')
   

public static void pushDocUpdatetoSIS(List<Id> enrlDocId)
{

//  PE_ContactID__c
  List<Enrollment_Document__c> Ed = [select Name,Type__c,Program_Enrollment__c,Program_Enrollment_AccountId__c,PE_ContactID__c,SchoolId__c,SchoolYear__c,Status_Reason__c,Reason__c from Enrollment_Document__c where Id=:enrlDocId LIMIT 1];
  List<Document_Central_Status_Mapping__mdt> status = [select id,MasterLabel,Status_Level__c,Status__c from Document_Central_Status_Mapping__mdt where Status__c=:Ed[0].Status_Reason__c Limit 1]; 
  String EdStatus ;
   if(status.size() >0)
   EdStatus = status[0].Status_Level__c;
   else
   EdStatus = Ed[0].Status_Reason__c;
  String EnrolDocId = Ed[0].Name;
  String docType = Ed[0].Type__c;
  String HshldId = Ed[0].Program_Enrollment_AccountId__c;
  String StdId =Ed[0].PE_ContactID__c;
  String SchoolYr = Ed[0].SchoolYear__c;
  String SchoolId = Ed[0].SchoolId__c;

  String Rsn =Ed[0].Reason__c;
  pushDocInfo(EnrlDocId,HshldId,StdId,docType,SchoolYr,SchoolId,EdStatus,Rsn);
  
system.debug(enrlDocId);
}
@future(callout=true)
public static void  pushDocInfo(List<Id> EnrlDocId,String HshldId,String StdId,String docType,String SchoolYr,String SchoolId,String EdStatus,String Rsn)
{
      try
      {
           String idamAccessToken =  NES_IdamUtilities.getIdamAccessToken();
           String jsonBody = '{"correlationId": "' + EnrlDocId + '","ApplicationName": "nes","Action":"u","Entity":"Document",' +
                    '"actioncontext": "document_update_status","AdditionalProperties":{"houseHoldId":"' + HshldId + '","studentId":"'+ StdId +'","docType":"'+ docType + '","schoolYear":"'+ SchoolYr + '","schoolId":"'+ SchoolId + '","status":"'+ EdStatus +'","Reason":"' + Rsn + '"}}';
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:Event_Emitter/v1/eventemitter');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('cache-control', 'no-cache');
            request.setHeader('x-ctx-accesstoken', idamAccessToken);
            request.setBody(jsonBody);

            Http http = new Http();
            HttpResponse response = http.send(request);
            
            }
            catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('SISDocStatusupdateError', e);
                        logger.saveLogs();
                    }

}
}