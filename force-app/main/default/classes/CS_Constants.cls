/***
* 
@author: Rakesh Ramaswamy (Ness Technologies)
* Created this Application wide utility class to store all the string literals.
* This class will act as the string binder come utility for all the Pearson-CS related custom development.
*/

public class CS_Constants {
    public static String PE_WITHDRAWN_STATUS = 'Withdrawn';
    public static String PE_COMPLETE_STATUS = 'Complete';
    public static String PE_IN_PROGRESS_STATUS = 'In Progress';
    public static String LEARNING_COACH_TYPE = 'Learning Coach';
    public static String PARENT_TYPE = 'Parent';
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

    // 2020-06-18 Sumanth/Rakesh: Added 2 String literals for Concatenated Status values used in the Program Enrollment and Relationship batch job's handler.
    // This is related to US # 186957 (Task# 195460, 195459).
    public static String PE_COMPLETE_IN_PROGRESS_STATUS = 'Complete-In Progress';
    public static String PE_COMPLETE_WITHDRAWN_STATUS = 'Complete-Withdrawn'; 
    // 2020-06-25 Rakesh: Added the following Profile name related literals.
    // This is related to US # 186957 (Task# 195460, 195459).
    public static String CARETAKER_COMMUNITY_PROFILE_NAME = 'Caretaker Community User';
    public static String LEARNING_COACH_COMMUNITY_PROFILE_NAME = 'Learning Coach Community User';
    public static String STUDENT_COMMUNITY_PROFILE_NAME = 'Student Community User';
    // The following two static collections are used in the trigger and batch-jobs related to the Relationship object and the Program Enrollment objects is concerned
    // These wrapper map collections are required to track the state of the access to be determined for a given Learning Coach User across different schools.
    public static map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsProvideAccessWrapperMap = new map<String, CS_LCUserCTPermSetsAccessWrapper>();
    public static map<String, CS_LCUserCTPermSetsAccessWrapper> LCUserCTPermSetsRemoveAccessWrapperMap = new map<String, CS_LCUserCTPermSetsAccessWrapper>();
    // 2020-06-24: Added By Rakesh. Related to US#. 164369 and US#. 186957
    // Collection to handle the Program Enrollment and Relationships Batch Jobs Serialization.    
    public static map<Id, PermissionSetAssignment> permsSetAssignFinalDeleteMap = new map<Id, PermissionSetAssignment>();
    
    //31 Aug 2020:Sumanth:Added Program Enrollment Record Types for US # 216780, 216777
    public static String PROGRAM_ENROLLMENT_RECTYPE_STUDENT = 'Student';
    public static String PROGRAM_ENROLLMENT_CARETAKER = 'Caretaker';
    
}