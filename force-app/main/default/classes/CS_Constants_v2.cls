/***
* 
@author: Rakesh Ramaswamy (Ness Technologies)
* Created this Application wide utility class to store all the string literals.
* This class will act as the string binder come utility for all the Pearson-CS related custom development.
*/

public class CS_Constants_v2 {

    public static String PE_WITHDRAWN_STATUS = 'Withdrawn';
    public static String PE_COMPLETE_STATUS = 'Complete';
    public static String PE_IN_PROGRESS_STATUS = 'In Progress';
    public static String LEARNING_COACH_TYPE = 'Learning Coach';
    public static String RELATIONSHIP_FORMER_STATUS = 'Former';
    public static String RELATIONSHIP_CURRENT_STATUS = 'Current';
    public static String ACCOUNT_RECTYPE_EDUCATIONAL_INSTITUTION = 'Educational Institution';
    public static String ACCOUNT_RECTYPE_ACADEMIC_PROGRAM = 'Academic Program';
    public static String ACCOUNT_RECTYPE_HOUSEHOLD_ACCOUNT = 'Household';
    public static String CONTACT_RECTYPE_STUDENTS = 'Students';
    public static String CONTACT_RECTYPE_CARETAKER = 'Caretaker';
    public static String SCHOOL_RECTYPE_STAFF ='School_Staff';
    public static String CONTACT_RECTYPE_LEARNING_COACH = 'Learning Coach';  
    public static String PROGENROLL_PERMSET_ACCESS_BATCH_SCHEDULE = 'ProgEnroll_PermSet_Access_Batch_Schedule';  
    public static String RELNSHIP_PERMSET_ACCESS_BATCH_SCHEDULE = 'Relnship_PermSet_Access_Batch_Schedule';
    public static String LC_KBA_ACCESS_RELNSHIP_RECS_PROCESS_INTERVAL = 'LC_KBA_Access_Reln_Recs_Process_Interval';
    public static String LC_KBA_ACCESS_PROGENROLL_RECS_PROCESS = 'LC_KBA_Access_Prog_Enroll_Recs_Process';
    public static String CTSTD_KBA_ACCESS_RECS_PROCESS = 'CTSTD_KBA_Access_Process';
    public static String SSTF_PERMISSION_ACCESS_PROCESS ='SSTF_Permission_Access_Process';
    public static String SSTF_PUBLIC_GROUP_USER_PERMISSION_ACCESS_PROCESS ='SSTF_Public_Group_User_Permission_Access';
    // The following two static collections are used in the trigger and batch-jobs related to the Relationship object and the Program Enrollment objects is concerned
    // These wrapper map collections are required to track the state of the access to be determined for a given Learning Coach User across different schools.
    public static map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsProvideAccessWrapperMap = new map<String, CS_LCUserCTPermSetsAccessWrapper>();
    public static map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsRemoveAccessWrapperMap = new map<String, CS_LCUserCTPermSetsAccessWrapper>();
    // collections to handle the Program Enrollment and Relationships Batch Jobs Serialization.
    public static list<PermissionSetAssignment> permsSetAssignFinalInsertList = new list<PermissionSetAssignment>();
    public static map<Id, PermissionSetAssignment> permsSetAssignFinalDeleteMap = new map<Id, PermissionSetAssignment>();
}