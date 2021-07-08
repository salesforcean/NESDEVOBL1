/*
* Created by:  Swapna
* Created date: 
* User Story : 
* Purpose: 
* Test Class:  DuplicateRecordLogicTest
*
* Change Log: 
*  Sumanth:21-09-2020: Added the code to associate the Lead->Chat Transcripts to the respective Contact record 
*   in the case of Lead-Contact Merger for Bug # 222395 
*  Rakesh: 22-03-2021: Added the code for fixing the defect #. 349734 that was associated with the 
*   User Story #. 342603 which was related to the Duplicate detection issue and failure of the Lead Conversion.
*/

//Swapna:Leads Merge logic
Public class DuplicateRecordLogic
{
  private static Peak_ApexLog logger = new Peak_ApexLog('DuplicateRecordLogic');
  
  @InvocableMethod
  public static void dupRecLogic(List<Id> drs){
        try {
              //Fetching the duplicate recordsets
              List<DuplicateRecordItem> dr = new List<DuplicateRecordItem>();
              dr = [select DuplicateRecordSetId,RecordId from DuplicateRecordItem where DuplicateRecordSetId = :drs[0]];
              String lcSrc;
              String lcType;
              Id lcOwner;

              List<Id> leadLst = new List<Id>();
              List<Id> conLst = new List<Id>();
              Contact conrec = new Contact();
              Account acc = new Account();
              String lstatus;   
              List<Lead> llst = new List<Lead>();

              for(DuplicateRecordItem rec:dr){    
                  if((rec.RecordId).getSObjectType().getDescribe().getName() == 'Lead')
                    leadLst.add(rec.RecordId);        
                  if((rec.RecordId).getSObjectType().getDescribe().getName() == 'Contact')  
                    conLst.add(rec.RecordId);          
              }

              //Merge leads with Contact - Associate the lead tasks with the respective Contact record
              if(conLst.size() > 0){
                    conrec = [select Id,LeadSource,AccountId,Channel_Type__c,LeadConOwnerId__c from Contact where Id IN :conLst order by CreatedDate ASC LIMIT 1]; //342603 added the LeadConOwnerID
                    List<Task> tsk = [ Select Id,whoId from Task where whoId IN:leadLst or whoId IN:conLst ];

                    for(Task tsrec: tsk){
                      tsrec.whoId =conrec.Id;
                    }

                  update tsk; 

                    // Sumanth:21-09-2020: Added the below code to associate the Lead->Chat Transcripts to the respective Contact record 
                    // in the case of Lead-Contact Merger for Bug # 222395 
                    List<LiveChatTranscript> ChatTranscriptList = [Select Id,LeadId,ContactId from LiveChatTranscript where LeadId IN:leadLst or ContactId IN:conLst];
                    for(LiveChatTranscript transcriptRec: ChatTranscriptList){
                      transcriptRec.ContactId =conrec.Id;
                      transcriptRec.LeadId = null;
                    }
                    update ChatTranscriptList; 

                  String conAccId = conrec.AccountId;
                  String conId = conrec.Id;
                  String LeadConOwnerId = conrec.LeadConOwnerId__c; //342603 added the LeadConOwnerID
                  List<Lead> lclst =[select Id,LeadSource,Channel_Type__c,OwnerId from Lead where Id in: leadLst order by CreatedDate ASC];

                    if(lclst.size()>0)
                      {
                        lcSrc = lclst[0].LeadSource;
                        lcType = lclst[0].Channel_Type__c;            
                        lcOwner = lclst[0].OwnerId;             
                      }
                      
                      if(conAccId != null)
                        acc = [select Id,Family_Enrollment_Counselor__c from Account where Id =:conAccId];

                      LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                      List<LeadConvert> convLs =new List<LeadConvert>();

                      for(Lead lrec:lclst){
                            Database.LeadConvert lcrec = new Database.LeadConvert();
                            lcrec.setLeadId(lrec.id);
                            lcrec.setConvertedStatus(convertStatus.MasterLabel);
                            lcrec.setAccountId(conAccId);
                            lcrec.setOwnerId(LeadConOwnerId);//342603 added the LeadConOwnerID
                            lcrec.setContactId(conId);
                            lcrec.setDoNotCreateOpportunity(true);
                            Database.LeadConvertResult lcr = Database.convertLead(lcrec);
                        }

                  //FEC assignment on Account and leadsource,channeltype updates on contact
                  if(conrec.LeadSource == null || conrec.Channel_Type__c == null || (conAccId!= null && acc.Family_Enrollment_Counselor__c == null))
                  {
                      conrec.LeadSource = lcSrc;
                      conrec.Channel_Type__c = lcType;
                      update conrec;
                       
                      // Code related changes for Defect #. 349734 begins here...
                      // Logic added by Rakesh based on technical discussions with Swapna.
                      if( (conAccId != null) && 
                          (acc.Family_Enrollment_Counselor__c == null) && (lcOwner != null) &&
                          lcOwner.getSobjectType().getDescribe().getName().equals('User')
                          ){                              
                              acc.Family_Enrollment_Counselor__c = lcOwner;                              
                              update acc;                             
                          }
                      // Code related changes for Defect #. 349734 ends here...
                  }   
              }

              //Lead Merge logic and associate the related lead tasks to the merged lead  
              if((leadLst.size() > 0) && (conLst.size() <= 0)){
                  string Lquery = FieldUtils.getFields('Lead');
                  String q = Lquery + ' where Id in :leadLst Order by CreatedDate ASC';
                  llst = Database.query(q);
                      
                  List<Task> tsk = [Select Id,whoId from Task where whoId IN:leadLst];
                  
                  for(Task tsrec: tsk){
                      tsrec.whoId =llst[0].Id;
                  }
                  update tsk;
                    
                  if (llst[0].Status == 'Closed' || llst[0].Status == 'Recycled'){
                      lstatus = 'Reinquired';              
                  }
                  else
                      lstatus = llst[0].Status;

                  String lId = llst[0].Id;

                  //Copy the latest lead info to the oldest lead
                  for(Lead l:llst){
                    if((l.Id != lId) && l.Parent_Lead__c == null){
                          l.Parent_Lead__c = lId;                          
                          l.Status = lstatus;                      
                        }  
                  }
                  
                  update llst;
                  
                  //Deleting the duplicate leads
                  List<Lead> dellst = [SELECT Id FROM Lead WHERE Id IN: leadLst AND Id != :lId];              
                  delete dellst;
              }
          }
          catch(Exception exp){
              System.debug('Error: ' + exp);
              system.debug('Exception At Line No. '+ exp.getLineNumber());
              logger.logException('dupRecLogic', exp);
              logger.saveLogs();              
          }        
     }  
}