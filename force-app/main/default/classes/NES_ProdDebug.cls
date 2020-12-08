global class NES_ProdDebug {
    
    /**
 * 	@ALIKM 20/apr/2020- commenting out changes
    
    public static NES_EnrollmentCompentBuilder allECData {get; private set;}
    public static NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData {get; private set;}

    public NES_ProdDebug(String processId) {
        allECData = NES_EnrollmentCompentBuilder.getInstance();
        thisProcessData = allECData.getSpecificProcessECData(processId);
    }

    
    public static void testOne() {

        String programEnrollmentId = 'a090n000002uHifAAE';
        String processId = 'a0f0n0000003dhAAAQ';
        String sectionId = 'a0f0n0000003dmIAAQ';

        hed__Program_Enrollment__c  studentEnrollment = [
            SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
            FROM hed__Program_Enrollment__c
            WHERE Id = :programEnrollmentId
        ];

        list<Enrollment_Component_Affiliation__c> thisStudentsECAs =
            [SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
            Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c = :programEnrollmentId];

        Map<Id, Enrollment_Component_Affiliation__c> newAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>(thisStudentsECAs);
            

        // list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();
        // thisStudentsECAs.addAll(newAffiliationMap.values());

        NES_ECACompletion.evaluateCompletion(
            programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);

    }

*/
    
}