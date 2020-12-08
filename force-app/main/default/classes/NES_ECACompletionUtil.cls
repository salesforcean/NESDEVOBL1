@SuppressWarnings('ApexUnresolvableReference')
public without sharing class NES_ECACompletionUtil {
    // public NES_ECACompletionUtil() {
    // }

    private static Peak_ApexLog logger = new Peak_ApexLog('ECABusinessLogic');

    /**
    * @author: Ali KM on 01-20-2020 for US# [122106]
    * @purpose : This method run the ECA Completion logic to re-evaluate 'Complete' sections/forms.
    * @parms: List of ECAs that need to be re-evaluated.
    * @usage: NES_ECACompletionUtil.runECACompletion(List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations, String programEnrollmentID);
    */
    public static void runECACompletion(List<Enrollment_Component_Affiliation__c> naECAs) {
        
        // get list of ECAs with Status='Not Applicable';
        
        // Approach #1: 
        // build the params list
        // call the method: NES_ECACompletion.evaluate();
        // NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);//added by anitha p
        // END

        System.debug('inside NES_ECACompletionUtil.runECACompletion() ');

        // Approach #2: 
        Boolean origCompletion = NES_ECACompletion.shouldRunCompletion;
        Boolean origAssignment = NES_Constants.runAssignment;
        Boolean origRunAssignment = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        // NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;

        // get the PE.Id
        // PL NOTE, as of not this is not bulkified to handle multiple PEs, as they underlying code needs to be bulkified first.
        String programEnrollmentId = naECAs[0].Program_Enrollment__c;
                
        if (origRunAssignment) {
            System.debug('inside NES_ECACompletionUtil.runECACompletion().origRunAssignment...');
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.hed__Program_Enrollment__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            // for (hed__Program_Enrollment__c programEnrollment : actlstnewMap.values()) {
            //     hed__Program_Enrollment__c oldPE = actlstoldMap.get(programEnrollment.Id); 
            //     List<String> changedFields = new List<String>();
            //     for (String str : mapFields.keySet()) {
            //         try {
            //             if (programEnrollment.get(str) != oldPE.get(str)) {
            //                 System.debug('changed field: ' + str);
            //                 changedFields.add(str);
            //             }
            //         } catch (Exception e) {
            //             System.debug('Error: ' + e);
            //             logger.logException('handleAfterUpdate', e);
            //             logger.saveLogs();
            //         }
            //     }
            //     changedFieldsMap.put(programEnrollmentID, new List<String> {'Status__c'}); // changedFields); 
            // }
            changedFieldsMap.put(programEnrollmentId, new List<String> {'Status__c'}); // changedFields);
            NES_ECACompletion.programEnrollmentCompletion(changedFieldsMap, 'Enrollment_Component_Affiliation__c');
        }
        // END

    }

    public static void runECACompletion_approach2(Enrollment_Component_Affiliation__c naECA) { // List<Enrollment_Component_Affiliation__c> naECAs

        Id programEnrollmentId = naECA.Program_Enrollment__c;
        // Id processId = NES_ECACompletion.grabProcessId(programEnrollmentId);
        Id sectionECRecTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Section').getRecordTypeId();
        Id sectionId = null;
        // refresh the eca
        naECA = [Select Id, Program_Enrollment__c, Enrollment_Component__c, Enrollment_Component__r.RecordTypeId from Enrollment_Component_Affiliation__c where Id = : naECA.Id];

        if (naECA.Enrollment_Component__r.RecordTypeId == sectionECRecTypeId) {
            sectionId = naECA.Enrollment_Component__c;
        }

        // if sectionId is null, don't proceed
        if (sectionId == null) {
            return ;
        }
         
        List<Enrollment_Component_Affiliation__c> newAffiliations = [
                    SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
                            Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
                    FROM Enrollment_Component_Affiliation__c
                    WHERE Program_Enrollment__c = :programEnrollmentId
            ];
        Map<Id, Enrollment_Component_Affiliation__c> newAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
        list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();//added by anitha p

        for (Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
            newAffiliationMap.put(newAffiliation.Enrollment_Component__c, newAffiliation);
            thisStudentsECAs.add(newAffiliation);//added by anitha p
        }
        
        hed__Program_Enrollment__c  studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :programEnrollmentId
        ];

        Id processId = NES_ECACompletion.grabProcessId(studentEnrollment);

        // print the params
        System.debug(naECA + ':::' + JSON.serialize(naECA));
        System.debug(programEnrollmentId + ':::' + JSON.serialize(programEnrollmentId));
        System.debug(processId + ':::' + JSON.serialize(processId));
        System.debug(sectionECRecTypeId + ':::' + JSON.serialize(sectionECRecTypeId));
        System.debug(sectionId + ':::' + JSON.serialize(sectionId));
        System.debug(newAffiliations + ':::' + JSON.serialize(newAffiliations));
        System.debug(thisStudentsECAs + ':::' + JSON.serialize(thisStudentsECAs));
        System.debug(studentEnrollment + ':::' + JSON.serialize(studentEnrollment));

        NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);//added by anitha p
    }

    // public static void printCollection(String sticker, List<sObject> objList) {

    //     System.debug(sticker + ':::' + JSON.serialize(objList));

    // }

}




    // // Approach #2: 
   
    // NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);//added by anitha p

    // // @Params: 
    // 1. programEnrollmentId => ECA.Enrollment_Component__c
    // 2. processId => NES_ECACompletion.grabProcessId(hed__Program_Enrollment__c programEnrollmentId)
    //     Ex: 
    //         if (String.isBlank(processId)) {
    //             processId = grabProcessId(studentEnrollment);
    //         }
    // 3. sectionId: 
    //     // Query the ECAs.EC.ID & EC.REcordTypeId
    //     List<Id> sectionIds = new List<Id>();
    //     for eca in ECAs :
    //         if eca.ec.recordType = 'Section': 
    //             sectionIds.add(eca.ec.Id); 


    // 4. newAffiliationMap & thisStudentsECAs, Use below code: 
    //     List<Enrollment_Component_Affiliation__c> newAffiliations = [
    //                 SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
    //                         Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
    //                 FROM Enrollment_Component_Affiliation__c
    //                 WHERE Program_Enrollment__c = :programEnrollmentId
    //         ];
    //         Map<Id, Enrollment_Component_Affiliation__c> newAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
    //         list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();//added by anitha p

    //         for (Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
    //             newAffiliationMap.put(newAffiliation.Enrollment_Component__c, newAffiliation);
    //             thisStudentsECAs.add(newAffiliation);//added by anitha p
    //         }

    // 5. studentEnrollment, use below code: 
    //     hed__Program_Enrollment__c  studentEnrollment = [
    //             SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
    //             FROM hed__Program_Enrollment__c
    //             WHERE Id = :programEnrollmentId
    //     ];