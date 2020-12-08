global with sharing class NES_Batch_TimeCriteria_Debug {

    public static void DebugThis() {
        
        List<SObject> scope = [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' and id = 'a0921000003ZKZwAAO'];
        
        List<Id> programEnrollmentIds = new List<Id>();
        for(SObject programEnrollment : scope) {
            programEnrollmentIds.add(programEnrollment.Id);
        }
        
        //Collect the data you need.
        Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap = new Map<Id,List<Enrollment_Component_Affiliation__c>> ();
        for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                 FROM Enrollment_Component_Affiliation__c
                                                                 WHERE Program_Enrollment__c in :programEnrollmentIds]) {
                                                                     if (!progEnrollECAListMap.containsKey(affiliation.Program_Enrollment__c)){
                                                                         list <Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
                                                                         ecas.add(affiliation);
                                                                         progEnrollECAListMap.put(affiliation.Program_Enrollment__c, ecas);
                                                                     } else
                                                                         progEnrollECAListMap.get(affiliation.Program_Enrollment__c).add(affiliation);
                                                                 }
        
        map<Id,hed__Program_Enrollment__c> EnrollmentsMap = new map<Id,hed__Program_Enrollment__c>();
        Set<Id> acedemicProgramsReferenced = new Set<Id> ();
        
        for (hed__Program_Enrollment__c pe : [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name,
                                              Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                                              FROM hed__Program_Enrollment__c WHERE Id IN :programEnrollmentIds] ) {
                                                  EnrollmentsMap.put(pe.Id, pe);
                                                  acedemicProgramsReferenced.add(pe.hed__Account__c);
                                              }
        
        //Build a map between Academic Programs and Process ids.
        map <Id, Id> academicProgramProcessIdMap = new Map<Id,Id>();
        Set<Id> processIdSet = new Set<Id>();
        for (Enrollment_Component__c e : [SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :acedemicProgramsReferenced  AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT])
        {
            academicProgramProcessIdMap.put(e.Process_Academic_Program__c, e.id);
            processIdSet.add(e.id);
        }
        
        //Build a list of all the enrollment components that have time based criteria and pass
        //those to runAssignment as a list of all the ids of the possibly impacted components.
        map<Id, List<Id>> processIdTimeBasedComponentsMap = new Map<Id, List<Id>> ();
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        
        for (id pId : processIdSet) {
            NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(pId);
            
            for (Enrollment_Component_Criteria__c ECC : [ SELECT Enrollment_Component__c
                                                         FROM Enrollment_Component_Criteria__c
                                                         WHERE Enrollment_Component__c IN :thisProcessData.allIds
                                                         AND Criteria_Type__c = 'Assignment'
                                                         AND Criteria__r.criteria_field__c = 'hed__program_enrollment__c.date_today__c' ] ) {
                                                             
                                                             List<Id> componentList;
                                                             if (processIdTimeBasedComponentsMap.containsKey(pid))
                                                                 componentList = processIdTimeBasedComponentsMap.get(pid);
                                                             else 
                                                                 componentList = new List<Id> ();
                                                             
                                                             componentList.add(ECC.Enrollment_Component__c);
                                                             processIdTimeBasedComponentsMap.put(pId, componentList);
                                                             
                                                         }
        }
        
        
        for(SObject programEnrollment : scope) {
            hed__Program_Enrollment__c thisEnrollment = EnrollmentsMap.get(programEnrollment.id);
            id processId = academicProgramProcessIdMap.get(thisEnrollment.hed__Account__c);
            List<Id> thisProcessTimeBasedComponents = processIdTimeBasedComponentsMap.get(processId);
            NES_ECAEvaluation.runAssignment(programEnrollment.Id, thisProcessTimeBasedComponents, thisEnrollment, progEnrollECAListMap.get(programEnrollment.id), processId );
        }
        
        List<Enrollment_Component_Affiliation__c> affiliations = [
            SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Enrollment_Component__r.RecordType.Name, Status__c, Order__c,
            Enrollment_Component__r.Assignment_Logic__c, Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c IN : programEnrollmentIds];
        
        Map<Id, Map<Id, Enrollment_Component_Affiliation__c>> enrollmentAffiliationMap = new Map<Id, Map<Id, Enrollment_Component_Affiliation__c>>();
        
        //Loop through affiliations and grab EC Ids and create map of PE Id to map of EC Id to Affiliation
        
        for(Id enrollmentId : programEnrollmentIds) {
            
            Map<Id, Enrollment_Component_Affiliation__c> tempAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
            
            for(Enrollment_Component_Affiliation__c affiliation : affiliations) {
                
                if(enrollmentId == affiliation.Program_Enrollment__c) {
                    
                    if(enrollmentAffiliationMap.keySet().contains(enrollmentId)) {
                        tempAffiliationMap = enrollmentAffiliationMap.get(enrollmentId);
                    }
                    
                    tempAffiliationMap.put(affiliation.Enrollment_Component__c, affiliation);
                    System.debug(tempAffiliationMap);
                }
                
            }
            enrollmentAffiliationMap.put(enrollmentId, tempAffiliationMap);
        }
        
        for(Id enrollmentId : programEnrollmentIds) {
            
            Map<Id, Enrollment_Component_Affiliation__c> tempAffiliationMap = enrollmentAffiliationMap.get(enrollmentId);
            if(tempAffiliationMap.size() > 0) {
                hed__Program_Enrollment__c thisEnrollment = EnrollmentsMap.get(enrollmentId);
                id processId = academicProgramProcessIdMap.get(thisEnrollment.hed__Account__c);
                
                NES_ECACompletion.evaluateCompletion(enrollmentId, processId, null, tempAffiliationMap, affiliations, thisEnrollment);
            }
            
        }
    }
    
}