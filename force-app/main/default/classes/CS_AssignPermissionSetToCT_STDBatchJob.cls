/*
* Created by:  Sumanth B
* Created date: 2020-Apr-21
* User Story : 130549
* Purpose: This Batch Job handles the association of Student's School Permission Sets (SchoolName_CT & SchoolName_STD) 
           to existing Caretakers and Students Users based on Program Enrollment Status = Complete 

*
* Test Class:  CS_AssignPermissionSetToCT_STDBatchTest
* Change Log: 
*
*/
global class CS_AssignPermissionSetToCT_STDBatchJob implements Database.Batchable<sObject>
{
        global String CTProfileName = system.Label.NES_CS_CT_Profile;
        global String STDProfileName = system.Label.NES_CS_Std_Profile;
        global Database.QueryLocator start(Database.BatchableContext bc) {


             Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.CTSTD_KBA_ACCESS_RECS_PROCESS];
             DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));
             String QueryString;
            if(Test.isRunningTest()){
            // QueryString = 'select id,ContactId,ProfileId,Profile.Name from User where (Profile.Name =\'' + CTProfileName + '\' OR Profile.Name =\'' + STDProfileName + '\') AND LastModifiedDate >=: dateTimeInterval  LIMIT 200';
               QueryString = 'select id,ContactId,ProfileId,Profile.Name from User where (Profile.Name =\'' + CTProfileName + '\' OR Profile.Name =\'' + STDProfileName + '\') AND LastModifiedDate >= TODAY LIMIT 100';
             System.debug('QueryString-->'+QueryString);
            }else{
             QueryString = 'select id,ContactId,ProfileId,Profile.Name from User where (Profile.Name =\'' + CTProfileName + '\' OR Profile.Name =\'' + STDProfileName + '\') AND LastModifiedDate >=: dateTimeInterval';
             System.debug('QueryString-->'+QueryString);
            }
             return Database.getQueryLocator(QueryString);
                
                
        }
        

        global void execute(Database.BatchableContext bc, List<User> UserRecs){

            Set<Id> ctIds = new Set<Id>();
            Set<Id> studentIds = new Set<Id>();
            for(User userRec : UserRecs){
                    if(userRec.Profile.Name == CTProfileName)
                        ctIds.add(userRec.ContactId);

                    else
                    if(userRec.Profile.Name == STDProfileName)
                        studentIds.add(userRec.ContactId);
            }

            system.debug('ctIds-->'+ctIds);
            system.debug('studentIds-->'+studentIds);
            if(ctIds.size() > 0 || studentIds.size() > 0)    
            {
                system.debug('Invoking Handler-->');
                CS_AssignPermissionSetToCT_STDHandler handlerObj = new CS_AssignPermissionSetToCT_STDHandler();
                 handlerObj.associatePermissionSets(ctIds,studentIds);
            }
        }

        global void finish(Database.BatchableContext bc){
        }
}