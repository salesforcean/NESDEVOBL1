/*
 * Developed By: Rakesh Ramaswamy (NESS TECHNOLOGIES)
 * User Story #. 164369
 * Description - This is a wrapper class used to capture the Learning Coaches access to the KBAs depending on the School that the LC falls under.
                 This wrapper class is used by the respective batch jobs on the Program Enrollment object as well as the Relationship object.
                    1. Batch Job on Program Enrollment - CS_LCUserCTPermSetsAccessProgEnrollBatch.cls
                    2. Batch Job on Relationship - CS_LCUserCTPermSetsAccessRelnshipBatch.cls
                 This wrapper class is also used to maintain LC Users permission-sets access state when the triggers on the Relationship object and the Program Enrollment objects are executed.
 */
 
public class CS_LCUserCTPermSetsAccessWrapper {

   public String schoolId;
   public String schoolName;
   public String studentRecId;
   public String LCRecId;
   public String PEStatus;
   public String PEName;
   public boolean isCTPermSetAccess;
   public String relationshipStatus;
   public String relationshipName;
   public hed__Relationship__c relationshipRecord;
    
    public CS_LCUserCTPermSetsAccessWrapper( String schoolAcctId, String schoolAcctName, String studRecId, String LCRecordId,
                                             String progEnrollStatus, String progEnrollName, boolean provideAccess,                                              
                                             String relationStatus, String relationName, hed__Relationship__c relationRecObj
                                            ){
      
            schoolId = schoolAcctId;
            schoolName = schoolAcctName;
            studentRecId = studRecId;
            LCRecId = LCRecordId;
            PEStatus = progEnrollStatus;
            PEName = progEnrollName;
            isCTPermSetAccess = provideAccess;
            relationshipStatus = relationStatus;
            relationshipName = relationName;
            relationshipRecord = relationRecObj;
    }
}