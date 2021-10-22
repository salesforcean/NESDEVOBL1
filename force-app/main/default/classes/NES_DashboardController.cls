/**
* Created by Ashish Sharma on 12/05/18.
* Class Name: NES_DashboardController
* Test Class Name: NES_DashboardControllerTest
* Purpose : This class is controller class for NES_Dashboard lightning component
*/
public without sharing class NES_DashboardController{ 
    
  /**
* Created by Jagadishbabu on 12/03/20.
* Parameters: none
* Return Type: List<NES_DashboardUtilities.StudentsInformation>
* Purpose : This method is used to retrieve all program enrollments related to the current logged in user's
students and then get all PROCESS_RT
type Enrollment components and related ECAs. Return this information after adding
    in List<NES_DashboardUtilities.StudentInformation>
    */
    @AuraEnabled
    public static List<NES_DashboardUtilities.StudentsInformation> getAssociatedStudentsInfo(){
        return NES_DashboardHelper.getRelatedStudentsInfoWithId(UserInfo.getUserId());
}


      /**
    * Created by Jagadishbabu on 03/05/21.
    * Purpose : This is to create ITR spectific records.
    */
	@AuraEnabled
    public static NES_ITRUtilities.ITRResults createITRforNextYear(Id studentId, Id programEnrollmentId){
        return NES_ITRUtilities.createReturningStudentPE(studentId, programEnrollmentId);
	}

 /**
    * Created by Sravani on 07/07/21.
    * Purpose : This is to create ITR spectific records.
    */
	/*@AuraEnabled
    public static NES_ReEnrUtilities.ReEnrResults processReEnrasInEnr(Id studentId, Id programEnrollmentId){
        return NES_ReEnrUtilities.reenrollingStudent(studentId, programEnrollmentId);
	} */
    
    
      /*@AuraEnabled
    public static void openApplication(Id programEnrollmentId){ 
     
  	List<Enrollment_Component_Affiliation__c> lsteca  = [Select id, Name, Status__c,Program_Enrollment__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Stage'  AND Enrollment_Component__r.Name = 'Open Application' AND Status__c = 'Not Started' AND Program_Enrollment__c=:programEnrollmentId];
         system.debug('lsteca '+lsteca); 
        for (Enrollment_Component_Affiliation__c eca :lsteca ){
            eca.Status__c = 'In Progress';
        }
        system.debug('lsteca '+lsteca); 
        if (lsteca.size() > 0){
             update lsteca;
        }
    }*/
}