//Swapna:Webservice to update Post Enrollment documents from SIS to NES
@RestResource(urlMapping='/DocsInfo/*')
global class DocumentsUpdateService {

global class DocumentsUpdateRequest{
//global String enrollId{get;set;}
global Id contactId{get;set;}
global Id schoolId{get;set;}
global String schoolYearId{get;set;}
global String docType{get;set;}
global List<String> filePaths{get;set;}
}

@HttpPost
global static void updateDocRef()
{
//try
//{
//String enrollId;
String contactId;
String schoolId;
String schoolYearId;
String docType;
List<String> filePaths;
DocumentsUpdateRequest reqBody = (DocumentsUpdateRequest)JSON.deserialize(RestContext.request.requestBody.toString(), DocumentsUpdateRequest.class);
//enrollId = reqBody.enrollId;
contactId = reqBody.contactId;
schoolId = reqBody.schoolId;
schoolYearId = reqBody.schoolYearId;
docType = reqBody.docType;
filePaths = reqBody.filePaths;


//hed__Program_Enrollment__c[]  peId = [select Id from hed__Program_Enrollment__c where Name = :enrollId LIMIT 1];
//Enrollment_Document__c[] enrlDoc = [select Id, Name,Program_Enrollment__c,Type__c,Status_Reason__c,Uploader__c,Submission_Time__c from Enrollment_Document__c where Program_Enrollment__c IN (select Id from hed__Program_Enrollment__c where Name = :enrollId) and Type__c = :docType LIMIT 1];
//hed__Program_Enrollment__c[]  peId = [select Id from hed__Program_Enrollment__c where Id IN ( select Program_Enrollment__c from Enrollment__c where Name = :enrollId) LIMIT 1];
hed__Program_Enrollment__c[]  peId = [select Id from hed__Program_Enrollment__c where hed__Contact__c = :contactId and hed__Account__r.ParentId =:schoolId and Start_Year__r.Name = :schoolYearId LIMIT 1];
//hed__Program_Enrollment__c[]  peId = [select Id from hed__Program_Enrollment__c where hed__Contact__r.Contact_Id__c  = :contactId and Start_Year__r.Name = :schoolYearId LIMIT 1];

Enrollment_Document__c[] enrlDoc = [select Id, Name,Program_Enrollment__c,Type__c,Status_Reason__c,Uploader__c,Submission_Time__c from Enrollment_Document__c where Program_Enrollment__c =:peId[0].Id and Type__c = :docType LIMIT 1];
List<Document_File_References__c> docRefall = new List<Document_File_References__c>();
Integer fileCnt = 0;
Id enrlDocId;
system.debug(peId + ':'+ docRefall);
if(enrlDoc.size() > 0)
{
fileCnt= [SELECT count() FROM Document_File_References__c WHERE Enrollment_Document__c = :enrlDoc[0].Id];
enrlDoc[0].Status_Reason__c = 'Submitted';
enrlDoc[0].SISDoc__c = true;
update enrlDoc;
enrlDocId = enrlDoc[0].Id;
}
else
{
//hed__Program_Enrollment__c  peId = new hed__Program_Enrollment__c();
//peId = [select Id from hed__Program_Enrollment__c where Name = :enrollId];
Enrollment_Document__c newenrlDoc = new Enrollment_Document__c();
newenrlDoc.Program_Enrollment__c = peId[0].Id;
newenrlDoc.Type__c = docType;
newenrlDoc.Status_Reason__c = 'Submitted';
newenrlDoc.Uploader__c = UserInfo.getUserId();
newenrlDoc.Submission_Time__c = system.now();
newenrlDoc.SISDoc__c = true;
insert newenrlDoc;
enrlDocId =newenrlDoc.Id;
}

for(String filePath:filePaths)
{

Document_File_References__c docRef = new Document_File_References__c();
docRef.Enrollment_Document__c = enrlDocId;
docRef.Version__c = fileCnt + 1;
docRef.File_Path__c = filePath;
docRef.Date_Uploaded__c = system.now();
fileCnt = fileCnt + 1;
docRefall.add(docRef);
}
insert docRefall;

//RestContext.response.responseBody =Blob.valueOf('Success:Record created with ID:'+ docRef.Name);
//
/*}
catch(Exception e)
{
RestContext.response.responseBody = Blob.valueOf('Error: ' + e.getMessage());
}
*/

}


}