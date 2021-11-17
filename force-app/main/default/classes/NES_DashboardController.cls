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
    
    
   
    
// Added for DEFECT 494868- DK    
    @AuraEnabled
    public static string refreshOPenAppPortal(Id programEnrollmentId){ 
	string refreshPortal;     
  	hed__Program_Enrollment__c hpe  = [Select id, Name, Stage__c,Open_Application__c from hed__Program_Enrollment__c where Id =:programEnrollmentId AND CreatedDate=today AND Recordtype.Name='Student'];
        System.debug('Printing Program Enrollment Id from Refreshopenappportal'+hpe.Id);
        if(hpe.Stage__c == 'Open Application'){
            refreshPortal = 'Refresh';
        }
        //system.debug('===>refreshPortal '+refreshPortal);
        return refreshPortal;
    }
   // End for DEFECT 494868- DK 
   
  // Added for DEFECT 495363- DK    
   @AuraEnabled
    public static list<Enrollment_Component_Affiliation__c> nonOpenAppUpdate(Id peId){
        list<Enrollment_Component_Affiliation__c> ecAffLst = new list<Enrollment_Component_Affiliation__c>();
        list<Enrollment_Component_Affiliation__c> ecalst = [select id,Enrollment_Component__c,Enrollment_Component__r.Name,Program_Enrollment__c,Order__c,EC_Record_Type__c, Program_Enrollment__r.Open_Application__c,Program_Enrollment__r.Open_Application_Period_status__c, Program_Enrollment__r.Program_Grade_Level__r.Open_Application__c,status__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c=:peId AND Enrollment_Component__r.Name ='Open Application'];
        if(ecalst.size() > 0){
            if(ecalst[0].EC_Record_Type__c == 'Stage' && ecalst[0].Program_Enrollment__r.Open_Application__c == null && ecalst[0].Program_Enrollment__r.Open_Application_Period_status__c == 'Inactive' && ecalst[0].Program_Enrollment__r.Program_Grade_Level__r.Open_Application__c == null){
                ecalst[0].status__c = 'Not Applicable';
                ecAffLst.add(ecalst[0]);
            }
            
            if(ecAffLst.size() > 0){
                update ecAffLst;
            }
        }
        
        return ecAffLst;
    }
	// End for DEFECT 495363- DK  
}