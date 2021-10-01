/**
* Created by Anushka Bansal on 20-12-2018.
* Change Log: Added code by Anitha P for #108697 User Story (Task 109792) on 2019-09-24
* Revision History:
* BUG217915 : Changed to calculate filter from Academic program to program grade level (line 21, 25)
*             Changed the batch size to 8 (line 57)
*/

public with sharing class NES_ProgramGradeLevelBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('ProgramGradeLevelBusinessLogic');
    
    
    
    //Created as part of BUG217915 by Jagadish Babu commented the above method
    public static void waitListCalculator(Map<Id, Program_Grade_Level__c > oldMap, List<Program_Grade_Level__c > newList){
        Set<Id> pglIds = new Set<Id>();
        //Changed the query filter from Acadamic program to program grade level for BUG217915
        for(Program_Grade_Level__c pgl : newList){
            if (oldMap != null) {
                if (pgl.StartWaitlist__c != oldMap.get(pgl.Id).StartWaitlist__c || pgl.EndWaitlist__c != oldMap.get(pgl.Id).EndWaitlist__c || pgl.ActivateWaitlist__c != oldMap.get(pgl.Id).ActivateWaitlist__c){
                        pglIds.add(pgl.Id);
                    }
                //Added for Userstory 451172- DK
                if (pgl.Start_Open_Application__c != oldMap.get(pgl.Id).Start_Open_Application__c || pgl.End_Open_Application__c != oldMap.get(pgl.Id).End_Open_Application__c || pgl.Active_Open_Application__c != oldMap.get(pgl.Id).Active_Open_Application__c){
                        pglIds.add(pgl.Id);
                }
            }
            else if (pgl.StartWaitlist__c != null || pgl.EndWaitlist__c != null || pgl.ActivateWaitlist__c != null){
                pglIds.add(pgl.Id);
            }
            
            //Added for Userstory 451172 -DK
            else if (pgl.Start_Open_Application__c != null || pgl.End_Open_Application__c != null || pgl.Active_Open_Application__c != null){
                pglIds.add(pgl.Id);
            }
            
        }
        Set<Id> programEnrollmentIds = new Set<Id>();
        for(hed__Program_Enrollment__c pgmEnrollment : [Select Id, Program_Grade_Level__c,Program_Grade_Level__r.Name from hed__Program_Enrollment__c where Program_Grade_Level__c IN : pglIds] ){
            programEnrollmentIds.add(pgmEnrollment.Id);
        }
        Set<Id> waitlistedPEIds = new Set<Id>();
        for(Enrollment_Component_Affiliation__c ecaRecord : [SELECT Id, 
                                                                    Enrollment_Component__c, 
                                                                    Program_Enrollment__c, 
                                                                    Status__c ,
                                                                    Program_Enrollment__r.Program_Grade_Level__r.Name
                                                                    FROM Enrollment_Component_Affiliation__c
                                                                    WHERE  
                                                                    Program_Enrollment__c IN: programEnrollmentIds 
                                                                    AND Enrollment_Component__r.RecordType.Name = 'Stage' 
                                                                    AND (Enrollment_Component__r.name = 'Final Confirmation' 
                                                                        OR Enrollment_Component__r.name = 'Confirmation of Enrollment' 
                                                                        OR Enrollment_Component__r.name = 'Intent to Attend' 
                                                                        OR Enrollment_Component__r.name = 'Enrollment Confirmation')
                                                                        AND  Status__c = 'Not Started' ])
        {
            waitlistedPEIds.add(ecaRecord.Program_Enrollment__c);                                                               
        
        }
        if(waitlistedPEIds.size() > 0 ){
            //Changed batch size to 8 from 20 as part of BUG217915 bulk testing
            Database.executeBatch(new NES_WaitListCalculatorBatch(waitlistedPEIds),8); 
        } 
    }
    /**
* Created By Anushka on 12/20/2018
* purpose is to call the waitlistCalculator method in the NES_BusinessLogicUtils class after Update.
*/
    /*public static void waitListCalculator(Map<Id, Program_Grade_Level__c > oldMap, List<Program_Grade_Level__c > newList) {
        System.debug('In Wait List Calc');
        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> academicProgramIds = new Set<Id>();
        for (Program_Grade_Level__c pgl : newList) {
            if (oldMap != null) {
                if (pgl.StartWaitlist__c != oldMap.get(pgl.Id).StartWaitlist__c ||
                    pgl.EndWaitlist__c != oldMap.get(pgl.Id).EndWaitlist__c ||
                    pgl.ActivateWaitlist__c != oldMap.get(pgl.Id).ActivateWaitlist__c)
                    academicProgramIds.add(pgl.Academic_Program__c);
            } else if (pgl.StartWaitlist__c != null ||
                       pgl.EndWaitlist__c != null ||
                       pgl.ActivateWaitlist__c != null)
                academicProgramIds.add(pgl.Academic_Program__c);
        }
        
        for (hed__Program_Enrollment__c programEnrollments : [Select id from hed__Program_Enrollment__c where hed__Account__c in:academicProgramIds]){            
            programEnrollmentIds.add(programEnrollments.Id);
        }
        //Start- added changes for #108697 User Story (Task 109792)  
        Set<Id> updatedPeids = new Set<Id>();
        for( Enrollment_Component_Affiliation__c affiliations :[
            SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c FROM Enrollment_Component_Affiliation__c
            WHERE  Program_Enrollment__c IN: programEnrollmentIds and Enrollment_Component__r.RecordType.Name = 'Stage' and 
            (Enrollment_Component__r.name = 'Final Confirmation' or Enrollment_Component__r.name = 'Confirmation of Enrollment' or Enrollment_Component__r.name = 'Intent to Attend' or Enrollment_Component__r.name = 'Enrollment Confirmation')
            and  Status__c = 'Not Started' ]){
                updatedPeids.add(affiliations.Program_Enrollment__c);
            }          
        //Bug 80271 Changes the logic to Batch
        //if(programEnrollmentIds.size() > 0 ){
        // Database.executeBatch(new NES_WaitListCalculatorBatch(programEnrollmentIds),100);
        system.debug('updatedPeids'+updatedPeids);
        if(updatedPeids.size() > 0 ){ 
            //136077-Reduce the batch size from 100 to 50 as we are getting Too many query rows 50001
            Database.executeBatch(new NES_WaitListCalculatorBatch(updatedPeids),20); 
            //End- added changes for #108697 User Story (Task 109792)      
        }
    }*/
    
   
}