/**
* Created by Anushka on 19-12-2018.
* Purpose : BusinessLogic class for PlacementAndElectiveTrigger called by PlacementAndElectiveHandler.
*/

public class NES_PlacementAndElectiveBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('PlacementAndElectiveBusinessLogic');
    
    /**
* Created By Anushka on 12/18/2018
* purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Update.
*/
    
    public static void calculateLTS_Update(Map<Id, Placement_and_Elective__c> oldMap, Map<Id, Placement_and_Elective__c> newMap) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        for (Placement_and_Elective__c pne : newMap.values()) {
            if (pne.Level_Requested__c != oldMap.get(pne.Id).Level_Requested__c ||
                pne.Course_Requested__c != oldMap.get(pne.Id).Course_Requested__c)
                programEnrollmentIds.add(pne.Program_Enrollment__c);
        }
        
        List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentIds);
        try {
            update programEnrollments;
        } catch(Exception e) {
            logger.logException('calculateLTS_Update', e);
            logger.saveLogs();
            throw e;
        }
    }
    
    /**
* Created By Anushka on 12/18/2018
* purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Insert.
*/
    
    public static void calculateLTS_Insert(List<Placement_and_Elective__c> newList) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        for (Placement_and_Elective__c pne : newList) {
            if (pne.Level_Requested__c != null || pne.Course_Requested__c != null) {
                programEnrollmentIds.add(pne.Program_Enrollment__c);
            }
        }
        
        List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentIds);
        try {
            update programEnrollments;
        } catch(Exception e) {
            logger.logException('calculateLTS_Insert', e);
            logger.saveLogs();
            throw e;
        }
    }
  /* commented as this is commented in handler too by Alex   
    public static void shouldRunPlacement(List<Placement_and_Elective__c> newList, Map<Id, Placement_and_Elective__c> oldMap) {
        
        List<Id> programEnrollmentIds = new List<Id>();
        for(Placement_and_Elective__c pe : newList) {
            Placement_and_Elective__c oldPe = oldMap.get(pe.Id);
            if(pe.Level_Requested__c != oldPe.Level_Requested__c) {
                programEnrollmentIds.add(pe.Program_Enrollment__c);
            }
        }
        
        if(programEnrollmentIds.size() > 0) {
            
            List<Annual_Student_Information__c> asis = [SELECT Id, Program_Enrollment__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN : programEnrollmentIds];
            NES_AnnualStudentInfoBusinessLogic.verifyAffiliationsComplete(asis);
        }
    }*/
    
/* Start -Added by anitha p for US 117571 (Task # 118636) on 15/11/2019
* Purpose : Added exclude auto course logic for ASI record for US 117571 (Task # 118636)
*/
    public static void excludeAutoCourseFromASI(List<Placement_and_Elective__c> newList) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        map<id,string> placementandElec = new map<id,string>();
        map<id,id> placmenttope = new map<id,id>();
        //get Placement and Elective ID's
        for (Placement_and_Elective__c pne : newList) {
            if (pne.Course_Requested__c != null) {
                programEnrollmentIds.add(pne.Program_Enrollment__c);
                placementandElec.put(pne.id, pne.Course_Requested__c );
                placmenttope.put( pne.Program_Enrollment__c,pne.id);
            }
        }

        
        //Update ASI records Exclude_AutoCourse__c comparing Account's Electives_Exclude_from_Auto_Course_Sel__c values with Placement and electives's Course_Requested__c
        List<Annual_Student_Information__c> asiList = new List<Annual_Student_Information__c>();
        
        list<string> pickValues = new list<string> ();
        for (Annual_Student_Information__c asi:[select ID ,Program_Enrollment__c,Exclude_AutoCourse__c,Program_Enrollment__r.hed__Account__r.Electives_Exclude_from_Auto_Course_Sel__c from Annual_Student_Information__c
                                                where Program_Enrollment__c in :programEnrollmentIds ]){
                                                    if ( asi.Exclude_AutoCourse__c!= true){
                                                        if(!placementandElec.isEmpty()&&!placmenttope.isEmpty()){
                                                            if(placmenttope.containskey(asi.Program_Enrollment__c) && asi.Program_Enrollment__r.hed__Account__r.Electives_Exclude_from_Auto_Course_Sel__c != null)		{
                                                                pickValues = asi.Program_Enrollment__r.hed__Account__r.Electives_Exclude_from_Auto_Course_Sel__c.split(';');
                                                                if(pickValues.size()>0 && pickValues.contains(placementandElec.get(placmenttope.get(asi.Program_Enrollment__c)))){ 
                                                                    asi.Exclude_AutoCourse__c = true;
                                                                    asiList.add(asi);
                                                                    pickValues.clear();
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
        
        try {
            update asiList;
        } catch(Exception e) {
            logger.logException('exclude_AutoCourse_Insert', e);
            logger.saveLogs();
            throw e;
        }
    }           
    // End -added by anitha p for US 117571 (Task # 118636)
}