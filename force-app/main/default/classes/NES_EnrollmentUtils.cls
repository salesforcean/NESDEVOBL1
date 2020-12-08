/**
 * Created by raydehler on 2019-03-13.
 */
public without sharing class NES_EnrollmentUtils {

    private static Peak_ApexLog logger = new Peak_ApexLog('EnrollmentUtils');

    // Maps to prevent multiple queries
    private static Map<Id, Map<String, DateTime>> accountGradeStartMap = new Map<Id, Map<String, DateTime>>();
    private static Map<Id, Map<String, DateTime>> accountGradeEndMap = new Map<Id, Map<String, DateTime>>();

    /*
     * Build Maps for Document Submission Start and End
     * Program Grade Level overrides the value set on the Academic Program, if set
     */
    private static void buildAccountGradeMaps(Id accountId) {
        if (!accountGradeStartMap.containsKey(accountId) && !accountGradeEndMap.containsKey(accountId))  {
            accountGradeStartMap.put(accountId, new Map<String, DateTime>());
            accountGradeEndMap.put(accountId, new Map<String, DateTime>());
            logger.logInfo('buildAccountGradeMaps', 'building account map for '+accountId);
        }  else  {
            return;
        }
        for (Program_Grade_Level__c pgl : [
                SELECT Grade_Level__r.Name,
                        Document_Submission_Start_Date__c,
                        Document_Submission_End_Date__c,
                        Academic_Program__r.Document_Start_Date__c,
                        Academic_Program__r.Document_End_Date__c
                FROM Program_Grade_Level__c
                WHERE Academic_Program__c = :accountId]) {

            accountGradeStartMap.get(accountId).put(pgl.Grade_Level__r.Name,
                    pgl.Document_Submission_Start_Date__c != null ? pgl.Document_Submission_Start_Date__c : pgl.Academic_Program__r.Document_Start_Date__c);
            accountGradeEndMap.get(accountId).put(pgl.Grade_Level__r.Name,
                    pgl.Document_Submission_End_Date__c != null ? pgl.Document_Submission_End_Date__c : pgl.Academic_Program__r.Document_End_Date__c);
        }

        logger.logInfo('buildAccountGradeMaps', 'start map: '+accountGradeStartMap);
        logger.logInfo('buildAccountGradeMaps', 'end map: '+accountGradeEndMap);
        logger.saveLogs();
    }

    public static Datetime getDocumentStartDate(Id accountId, String gradeLevel) {
        if (!accountGradeStartMap.containsKey(accountId)) {
            buildAccountGradeMaps(accountId);
        }

        return accountGradeStartMap.get(accountId).get(gradeLevel);
    }

    public static Datetime getDocumentEndDate(Id accountId, String gradeLevel) {
        if (!accountGradeEndMap.containsKey(accountId)) {
            buildAccountGradeMaps(accountId);
        }

        return accountGradeEndMap.get(accountId).get(gradeLevel);
    }

    public static String getStudentName(Id studentId, Id programEnrollmentId) {

        String studentName = '';
        if(String.isNotBlank(studentId)) {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId = currentUser.ContactId;
            if (String.isNotBlank(contactId)) {

                List<hed__Relationship__c> relationships = [
                        SELECT Id, hed__Contact__c, hed__RelatedContact__c
                        FROM hed__Relationship__c
                        WHERE hed__Contact__c = :contactId
                        AND hed__RelatedContact__c =: studentId
                ];
                if (relationships.size() > 0) {
                    List<Contact> students = [SELECT Name FROM Contact WHERE Id = :studentId];
                    if (students.size() > 0) {
                        studentName = students[0].Name;
                    } else {
                        studentName = 'InvalidUser';
                    }
                } else {
                    studentName = 'InvalidUser';
                }
            }
        } 

        return studentName;
    }
}