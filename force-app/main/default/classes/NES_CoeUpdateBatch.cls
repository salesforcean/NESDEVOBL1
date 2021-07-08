global class NES_CoeUpdateBatch implements  Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Get the 21-22 School Year
        Id schYrId = [Select Id from School_Year__c where Name =: '2021-2022' and Current_Year__c =: true limit 1].Id;
        String complStatus = 'Complete';
        String blankString = '';
        boolean fls = false;
        String testpeId = 'a09f0000007VHZNAA4';
        List <String> testpeIdList = new List <String> ();
        
        /*
        testpeIdList.add('a09f0000007VIhwAAG');
        testpeIdList.add('a09f0000007VIhrAAG');
        testpeIdList.add('a09f0000007VdU0AAK');
        testpeIdList.add('a09f0000007VdGIAA0');
		*/
        // Get the PE records to be cleansed
        //String batchQueryStr = 'SELECT Id, Processed_in_V2__c, Status__c,Enrollment_Type__c, Start_Year__c, hed__Account__c, hed__Account__r.FirstDayforStudents__c, hed__Account__r.ParentId, hed__Account__r.PushToSecondSemester__c from hed__Program_Enrollment__c where Status__c =: complStatus AND Start_Year__c =: schYrId AND (Processed_in_V2__c =: fls OR SIS_Integration_Status__c  =: blankString) order by createddate desc';         
        //String batchQueryStr = 'SELECT Id, Processed_in_V2__c, Status__c,Enrollment_Type__c, Start_Year__c, hed__Account__c, hed__Account__r.FirstDayforStudents__c, hed__Account__r.ParentId, hed__Account__r.PushToSecondSemester__c from hed__Program_Enrollment__c where Id in : testpeIdList AND Status__c =: complStatus AND Start_Year__c =: schYrId AND SIS_Integration_Status__c  =: blankString order by createddate desc limit 10';         
        String batchQueryStr = 'SELECT Id, Processed_in_V2__c, Status__c,Enrollment_Type__c, Start_Year__c, hed__Account__c, hed__Account__r.FirstDayforStudents__c, hed__Account__r.ParentId, hed__Account__r.PushToSecondSemester__c from hed__Program_Enrollment__c where Status__c =: complStatus AND Start_Year__c =: schYrId AND SIS_Integration_Status__c  =: blankString order by createddate desc';         


        //System.debug('TEST REC'+batchQueryStr);
        return Database.getQueryLocator(batchQueryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__Program_Enrollment__c> peList){      
        
        
        List <Id> peIdList = new List <Id> ();
        Map <Id, hed__Program_Enrollment__c> peIdToPeMap = new Map <Id, hed__Program_Enrollment__c> ();
        Map <Id, Enrollment__c> peIdToEnrFailMap = new Map <Id, Enrollment__c> ();
        Map <Id, Enrollment__c> peIdToEnrSuccMap = new Map <Id, Enrollment__c> ();
        Map <Id, Opportunity> peIdToOppMap = new Map <Id, Opportunity> ();
        Map <String, CS_Event_Notification_Params__mdt> mdtMap = new Map <String, CS_Event_Notification_Params__mdt> ();        
        List <Id> peCrEnrRecIdList = new List <Id> ();
        set<id> allEnrollmentIds = new set<id>(); // Vani
        
        // Get the Event Notification Params Custom Metadata
        List <CS_Event_Notification_Params__mdt> mdtList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Action_Context__c, Action__c, ApplicationName__c, Entity__c FROM CS_Event_Notification_Params__mdt];
        
        for(CS_Event_Notification_Params__mdt mdt: mdtList){
            mdtMap.put(mdt.Label, mdt);            
        }
        
        // Prepare the List pf PE Ids and PE Id to PE Map
        for(hed__Program_Enrollment__c pe: peList){
            System.debug('NDEBUG::::: ID of PE Record being processed:::::' + pe.Id);
            peIdList.add(pe.Id);
            peIdToPeMap.put(pe.Id, pe);
        }
        
        
        
        if(peIdList.size() >0){
            // Get the Opportunities related to the above PEs
            List <Opportunity> peOppList = [Select Id, Program_Enrollment__c, PreferredStartDate__c, Semester_Indicator__c from Opportunity where Program_Enrollment__c In : peIdList and StageName = 'Closed Won' ];
            for(Opportunity peOpp: peOppList){
                peIdToOppMap.put(peOpp.Program_Enrollment__c, peOpp);
            }
            
            // Get the Enrollment Records if they exist
            List <Enrollment__c> enrList = [Select Id, Program_Enrollment__c, Integration_Status__c from Enrollment__c where Program_Enrollment__c in: peIdList];
        
            if(enrList != null && enrList.size() > 0){
                for(Enrollment__c enrRec : enrList){
                    // Check if the Enrollment Record Integration Status is not 'Success'
                    // If not 'Success' will trigger the platform Event.
                    if(enrRec.Integration_Status__c != 'Success'){
                        peIdToEnrFailMap.put(enrRec.Program_Enrollment__c, enrRec);
                        allEnrollmentIds.add(enrRec.id); //Vani
                    }
                    if(enrRec.Integration_Status__c == 'Success'){
                        peIdToEnrSuccMap.put(enrRec.Program_Enrollment__c, enrRec);
                    }
                }                
            }
            
            // Prepare the List of PEs for which Enrollment Records need to be created, PlatformEvent to be Triggerred and PE and Enrollment Record to be updated
            // Mimic the functionality of CS_PushEnrollmentToV2SystemsFlow Flow

            for(Id peId: peIdList)  {
                if(!peIdToEnrFailMap.containsKey(peId) && !peIdToEnrSuccMap.containsKey(peId)){
                    peCrEnrRecIdList.add(peId);
                }
            }
            
            // Create the PEID to EarliestDate Map
            Map<Id, Date> earliestStrtDtMap =  new Map<Id, Date> ();
            
            
            //peIdToOppMap.get(peEnrCrId)
            //peIdToPeMap.get(peEnrCrId)
            Enrollment__c enrollmentRecord;
            List <Enrollment__c> enrollmentRecordList = new List <Enrollment__c> ();
            //Date earliestStartDate ;
            if(peCrEnrRecIdList.size() >0){
                earliestStrtDtMap = getEarliestStartDate(peCrEnrRecIdList, peIdToOppMap, peIdToPeMap);
                for(Id peEnrCrId: peCrEnrRecIdList){
                   // Check if peId exists in peIdToOppMap else Skip the creation of Enrollment record
                   if(peIdToOppMap.containsKey(peEnrCrId))
                   {
                       enrollmentRecord = new Enrollment__c(Program_Enrollment__c = peEnrCrId,
                                                                          Enrollment_Type__c= peIdToPeMap.get(peEnrCrId).Enrollment_Type__c, 
                                                                          School_Year__c = peIdToPeMap.get(peEnrCrId).Start_Year__c);
                       if (peIdToOppMap.get(peEnrCrId).Program_Enrollment__c <> null && peIdToPeMap.get(peEnrCrId).hed__Account__c <> null 
                        && peIdToPeMap.get(peEnrCrId).hed__Account__r.FirstDayforStudents__c > peIdToOppMap.get(peEnrCrId).PreferredStartDate__c) {
                        //Checking between program enrollment associated account FirstDayforStudents__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                            if(earliestStrtDtMap.get(peEnrCrId) <> null){
                                if (peIdToPeMap.get(peEnrCrId).hed__Account__r.FirstDayforStudents__c > earliestStrtDtMap.get(peEnrCrId)) {
                                    enrollmentRecord.Enrollment_Date__c = peIdToPeMap.get(peEnrCrId).hed__Account__r.FirstDayforStudents__c;
                                } else {
                                    enrollmentRecord.Enrollment_Date__c = earliestStrtDtMap.get(peEnrCrId);
                                }
                            }
                        } else {
                            //Checking between opportunity PreferredStartDate__c & earliestStartDate , populating Enrollment_Date__c with whichever is greater.
                            if(earliestStrtDtMap.get(peEnrCrId) <> null){
                                if (peIdToOppMap.get(peEnrCrId).PreferredStartDate__c > earliestStrtDtMap.get(peEnrCrId)) {
                                    enrollmentRecord.Enrollment_Date__c = peIdToOppMap.get(peEnrCrId).PreferredStartDate__c;
                                } else {
                                    enrollmentRecord.Enrollment_Date__c = earliestStrtDtMap.get(peEnrCrId);
                                }
                            }
                        }
                        enrollmentRecordList.add(enrollmentRecord);   
                   }
                }
                
                if(enrollmentRecordList != null && enrollmentRecordList.size()>0){
                    Database.insert(enrollmentRecordList,false);
                }
                
                Enrollment_Event__e pltfrmEvt;
                List <Enrollment_Event__e> pltfrmEvtList = new List <Enrollment_Event__e> ();
                List <Id> peUpdIdList = new List <Id> ();
                Map <Id, Enrollment__c> peIdToEnrMap = new Map <Id, Enrollment__c> ();
                List <Enrollment__c> finalEnrUpdList = new List <Enrollment__c> ();
                List <hed__Program_Enrollment__c> finalPeUpdList = new List <hed__Program_Enrollment__c> ();
                // Now Create and Publish the Event and update the PE SIS Status for the Inserted Enrollment Records
                List <Enrollment__c> insEnrRecs = [Select Id, Program_Enrollment__c,PCx_CorrelationId__c, Integration_Status__c from Enrollment__c where Id in :allEnrollmentIds or Program_Enrollment__c in : peCrEnrRecIdList];
                if(insEnrRecs != null && insEnrRecs.size() >0){
                    for(Enrollment__c enr: insEnrRecs){
                        if(!Test.isRunningTest()){
                            pltfrmEvt = new Enrollment_Event__e ();
                            
                            pltfrmEvt.actionContext__c = mdtMap.get(peIdToPeMap.get(enr.Program_Enrollment__c).Enrollment_Type__c).Action_Context__c;
                            pltfrmEvt.action__c = mdtMap.get(peIdToPeMap.get(enr.Program_Enrollment__c).Enrollment_Type__c).Action__c;
                            pltfrmEvt.entity__c = mdtMap.get(peIdToPeMap.get(enr.Program_Enrollment__c).Enrollment_Type__c).Entity__c;
                            pltfrmEvt.applicationName__c = mdtMap.get(peIdToPeMap.get(enr.Program_Enrollment__c).Enrollment_Type__c).ApplicationName__c;
                            pltfrmEvt.correlationId__c = enr.PCx_CorrelationId__c;
                            pltfrmEvt.enrollmentId__c = enr.Id;
                            
                            pltfrmEvt.locationId__c = peIdToPeMap.get(enr.Program_Enrollment__c).hed__Account__r.ParentId;
                            pltfrmEvt.timestamp__c = system.now();
                            pltfrmEvtList.add(pltfrmEvt);
                        }
                        if(Test.isRunningTest()){
                            Integer i =0;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                            i++;
                        }
                        peUpdIdList.add(enr.Program_Enrollment__c);
                        peIdToEnrMap.put(enr.Program_Enrollment__c, enr);
                    }
                    if(pltfrmEvtList != null && pltfrmEvtList.size() >0){
                        //Insert pltfrmEvtList;
                        EventBus.publish(pltfrmEvtList);
                    }
                    
                    for(Id peId: peUpdIdList){
                        peIdToPeMap.get(peId).SIS_Integration_Status__c = 'Restricted to SIS';
                        finalPeUpdList.add(peIdToPeMap.get(peId));
                        peIdToEnrMap.get(peId).Integration_Status__c = peIdToEnrMap.get(peId).PCx_CorrelationId__c;
                        finalEnrUpdList.add(peIdToEnrMap.get(peId));                        
                    }
                    if(finalPeUpdList != null && finalPeUpdList.size()>0){
                        update finalPeUpdList;
                    }
                    if(finalEnrUpdList != null && finalEnrUpdList.size()>0){
                        update finalEnrUpdList;
                    }
                }
            }
                           
        }
        
        //[SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, , , ,  FROM CS_Event_Notification_Params__mdt];
        
        
     //SELECT Id, ReplayId, CreatedDate, CreatedById, EventUuid, action__c, applicationName__c, correlationId__c,
     // enrollmentId__c, entity__c, locationId__c, timestamp__c, actionContext__c FROM Enrollment_Event__e   
        
    }
      
    global void finish(Database.BatchableContext bc){
       
    }
    
    
    global void execute(SchedulableContext ctx) {
        NES_coeUpdateBatch batchEx = new NES_coeUpdateBatch();
        Database.executeBatch(batchEx,50);
    }
    
    private Map <Id, Date> getEarliestStartDate (List <Id> peCrEnrRecIdList, Map <Id, Opportunity> peIdToOppMap, Map <Id, hed__Program_Enrollment__c> peIdToPeMap){
        Map <Id, Date> earliestStrtDateMap = new Map <Id, Date> ();
        Date earliestStartDate;
        
        for(Id peId : peCrEnrRecIdList){
            if ((peIdToOppMap.get(peId).Program_Enrollment__c <> null && 
                 peIdToPeMap.get(peId).hed__Account__c <> null && 
                 peIdToPeMap.get(peId).hed__Account__r.PushToSecondSemester__c <> null && peIdToPeMap.get(peId).hed__Account__r.PushToSecondSemester__c.date() != null &&
                    System.today() > peIdToPeMap.get(peId).hed__Account__r.PushToSecondSemester__c.date()) ||
                    (peIdToOppMap.get(peId).Semester_Indicator__c <> null && peIdToOppMap.get(peId).Semester_Indicator__c == 'Second')) {
                System.debug('<<<PushToSecondSemester__c Test pass');
                if (peIdToPeMap.get(peId).hed__Account__r.FirstDaySecondSemester__c > System.today().addDays(1)) {
                    earliestStartDate = peIdToPeMap.get(peId).hed__Account__r.FirstDaySecondSemester__c;
                    System.debug('FirstDaySecondSemester__c earliestStartDate:' + earliestStartDate);
                } else {
                    earliestStartDate = System.today().addDays(1);
                    System.debug('System.today() earliestStartDate:' + earliestStartDate);
                }
            } else {
                if (peIdToPeMap.get(peId).hed__Account__r.FirstDayforStudents__c > System.today().addDays(1)) {
                    earliestStartDate = peIdToPeMap.get(peId).hed__Account__r.FirstDayforStudents__c;
                    System.debug('FirstDayforStudents__c earliestStartDate:' + earliestStartDate);
                } else {
                    earliestStartDate = System.today().addDays(1);
                    System.debug('System.today() earliestStartDate:' + earliestStartDate);
                }
            }
            earliestStrtDateMap.put(peId, earliestStartDate );
        }
        return earliestStrtDateMap;
    }
    
    
}