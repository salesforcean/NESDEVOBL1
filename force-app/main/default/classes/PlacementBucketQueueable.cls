public with sharing class PlacementBucketQueueable implements Queueable {
    private List<ID> peIds;

    public void execute(QueueableContext context) {
        
        /*Grab the PE records we need to work with*/
       List<hed__program_enrollment__c> pes = new list<hed__program_enrollment__c>([
            SELECT ID, start_year__c, EvaluatePlacementBucket__c
            FROM hed__program_enrollment__c
            WHERE ID IN: peIDs]);
        
        /* Create a map out of the PEs so that we can reference them easily*/
        Map<ID, hed__program_enrollment__c> peMap = new Map<ID, hed__program_enrollment__c>();
        for(hed__program_enrollment__c pe : pes){
            peMap.put(pe.ID, pe);
            pe.EvaluatePlacementBucket__c = false;
        }     
        
        /* Get the ASIS */
        List<Annual_Student_Information__c> allasis = new list<annual_student_information__c>([
            SELECT Id, Program_Enrollment__c,Academic_Documentation_Summary__c,School_Year__r.Start_Date__c,
                LA_Placement_Level__c, HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c,
                Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c, AutomatedPlacementScore__c, AutomatedPlacementExclude__c,
                Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c,Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c,
                School_Year__c, Program_Enrollment__r.Start_Year__r.Current_Year__c, APS_PlacedTimeStamp__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN: peIds
        ]);
        
        /* Create a list out of the same year ASIs so that we send them to the bucket method*/
        list<annual_student_information__c> asis = new list<annual_student_information__c>();
        for(annual_student_information__c asi : allasis){
            if (asi.school_year__c == peMap.get(asi.Program_Enrollment__c).start_Year__c){
                asis.add(asi);
            }
        }
        
        //commented for the bug 127565
        /* Update the PEs to clear the bucket evaluation flag */
        try {
            System.debug('Updating PEs');
            update pes;
        } 
        catch (Exception ex) {
            System.debug('Exception Thrown : ' + ex.getMessage());
        }
        
        /* Initiate the placement bucket recalculation for the list of ASIs */
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asis, true);
    }

    public PlacementBucketQueueable(List<Id> runBucketPEs) {
        this.peIDs = runBucketPEs;
    }
}