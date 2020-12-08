public class StudentEnrollment {
    private static Peak_ApexLog logger = new Peak_ApexLog('DashboardHelper');

     @AuraEnabled
    
    public static list<NES_DashboardUtilities.StudentInformation> getStudentinfo(ID currentstudentID){
         try {
             Id careTakerContactId;
            
             // studentIds.add(currentstudentID);
             system.debug('currentstudentID'+currentstudentID);
                          careTakerContactId=currentstudentID;
             
                 if (careTakerContactId != null) {
                //Retrieve the related student Ids of the careTakerContactId
                Set<Id> studentIds = new Set<Id>();
                Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();

                for (hed__Relationship__c con : [
                        SELECT hed__RelatedContact__c
                        FROM hed__Relationship__c
                        WHERE hed__Contact__c = :careTakerContactId
                        AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
                ]) {
                    studentIds.add(con.hed__RelatedContact__c);
                }

                if (studentIds.size() > 0) {
             
         List<NES_DashboardUtilities.StudentInformation> students = new List<NES_DashboardUtilities.StudentInformation>();
            // NES_DashboardUtilities.StudentInformation student_enroll = new NES_DashboardUtilities.StudentInformation();  

                    List<hed__Program_Enrollment__c> programEnrollments = [
                            SELECT Id, hed__Contact__c, hed__Contact__r.Name,hed__Contact__r.AccountId, Status__c, Final_Grade_Level__c,
                                    hed__Account__r.Registration_Start_Date__c, hed__Account__r.Registration_End_Date__c, hed__Account__r.ParentId,
                            (SELECT Order__c, Enrollment_Component__r.Name, Status__c,Enrollment_Component__r.Order__c,
                                    Program_Enrollment__r.Final_Grade_Level__c, Enrollment_Component__r.RecordType.Name
                                FROM Enrollment_Component_Affiliation__r
                                WHERE Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                                OR Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT)
                            FROM hed__Program_Enrollment__c
                            WHERE hed__Contact__c IN:studentIds
                    ];

                    for (hed__Program_Enrollment__c temp : programEnrollments) {

                        System.debug(temp.Id);
                        if (temp.Enrollment_Component_Affiliation__r != null && temp.Enrollment_Component_Affiliation__r.size() > 0) {
                            List<Enrollment_Component_Affiliation__c> stages = new List<Enrollment_Component_Affiliation__c>();

                            for (Enrollment_Component_Affiliation__c eca : temp.Enrollment_Component_Affiliation__r) {
                                if (eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.STAGE_RT) {
                                    stages.add(eca);
                                }

                            }

                            for (Enrollment_Component_Affiliation__c eca : temp.Enrollment_Component_Affiliation__r) {
                                if (eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.PROCESS_RT) {
                                    String statusString;
                                    if (String.isNotBlank(temp.Status__c)) {
                                        statusString = temp.Status__c;
                                    } else {
                                        statusString = eca.Status__c;
                                    }
                                    students.add(new NES_DashboardUtilities.StudentInformation(temp.Id, temp.hed__Contact__c, statusString, temp.hed__Contact__r.Name, temp.hed__Account__r.ParentId, stages, eca.Enrollment_Component__c, temp.Final_Grade_Level__c, temp.hed__Account__r.Registration_Start_Date__c, temp.hed__Account__r.Registration_End_Date__c));
                                }
                            }
                        }
                    }
                    system.debug('students'+students);
                 return students;
                }
            }

            return null;
        } catch (Exception e) {
            logger.logException('getRelatedStudentsWithId', e);
            logger.saveLogs();
            return null;
        }
    }
}
     //private static Peak_ApexLog logger = new Peak_ApexLog('DashboardHelper');

    /**
     * Created by Ashish Sharma on 12/05/18
     * Parameters: Id
     * Return Type: List<NES_DashboardUtilities.StudentInformation>
     * Purpose : This method is used to retrieve all program enrollments related to the students (based on care taker user's Id passed in the method parameter)
                 and then get all PROCESS_RT
                 type Enrollment components and related ECAs. Return this information after adding
                 in List<NES_DashboardUtilities.StudentInformation>
    */
   /* public static List<NES_DashboardUtilities.StudentInformation> getRelatedStudentsWithId(Id ctUserId) {
        try {
            Id careTakerContactId;

            //Retrieve the care taker contact Id of the current logged in user
            for (User tempUser : [SELECT ContactId FROM User WHERE Id = :ctUserId]) {
                careTakerContactId = tempUser.ContactId;
            }


            if (careTakerContactId != null) {
                //Retrieve the related student Ids of the careTakerContactId
                Set<Id> studentIds = new Set<Id>();
                Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();

                for (hed__Relationship__c con : [
                        SELECT hed__RelatedContact__c
                        FROM hed__Relationship__c
                        WHERE hed__Contact__c = :careTakerContactId
                        AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
                ]) {
                    studentIds.add(con.hed__RelatedContact__c);
                }

                if (studentIds.size() > 0) {
                    /*
                      Retrieve all program enrollments related to the students and then get all PROCESS_RT
                      type Enrollment components and related ECAs. Return this information after adding
                      in List<NES_DashboardUtilities.StudentInformation>
                    */
                   /* List<NES_DashboardUtilities.StudentInformation> students = new List<NES_DashboardUtilities.StudentInformation>();

                    List<hed__Program_Enrollment__c> programEnrollments = [
                            SELECT Id, hed__Contact__c, hed__Contact__r.Name,hed__Contact__r.AccountId, Status__c, Final_Grade_Level__c,
                                    hed__Account__r.Registration_Start_Date__c, hed__Account__r.Registration_End_Date__c, hed__Account__r.ParentId,
                            (SELECT Order__c, Enrollment_Component__r.Name, Status__c,Enrollment_Component__r.Order__c,
                                    Program_Enrollment__r.Final_Grade_Level__c, Enrollment_Component__r.RecordType.Name
                                FROM Enrollment_Component_Affiliation__r
                                WHERE Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                                OR Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT)
                            FROM hed__Program_Enrollment__c
                            WHERE hed__Contact__c IN:studentIds
                    ];

                    for (hed__Program_Enrollment__c temp : programEnrollments) {

                        System.debug(temp.Id);
                        if (temp.Enrollment_Component_Affiliation__r != null && temp.Enrollment_Component_Affiliation__r.size() > 0) {
                            List<Enrollment_Component_Affiliation__c> stages = new List<Enrollment_Component_Affiliation__c>();

                            for (Enrollment_Component_Affiliation__c eca : temp.Enrollment_Component_Affiliation__r) {
                                if (eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.STAGE_RT) {
                                    stages.add(eca);
                                }

                            }

                            for (Enrollment_Component_Affiliation__c eca : temp.Enrollment_Component_Affiliation__r) {
                                if (eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.PROCESS_RT) {
                                    String statusString;
                                    if (String.isNotBlank(temp.Status__c)) {
                                        statusString = temp.Status__c;
                                    } else {
                                        statusString = eca.Status__c;
                                    }
                                    students.add(new NES_DashboardUtilities.StudentInformation(temp.Id, temp.hed__Contact__c, statusString, temp.hed__Contact__r.Name, temp.hed__Account__r.ParentId, stages, eca.Enrollment_Component__c, temp.Final_Grade_Level__c, temp.hed__Account__r.Registration_Start_Date__c, temp.hed__Account__r.Registration_End_Date__c));
                                }
                            }
                        }
                    }
                    return students;
                }
            }
}

            return null;
        } catch (Exception e) {
            logger.logException('getRelatedStudentsWithId', e);
            logger.saveLogs();
            return null;
        }
    }*/