/**
* Created by Ashish Sharma on 12/05/18.
* Class Name: NES_DashboardController
* Test Class Name: NES_DashboardControllerTest
* Purpose : This class is controller class for NES_Dashboard lightning component
*/
public without sharing class NES_DashboardController{ 
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: none
* Return Type: List<NES_DashboardUtilities.StudentInformation>
* Purpose : This method is used to retrieve all program enrollments related to the current logged in user's
students and then get all PROCESS_RT
type Enrollment components and related ECAs. Return this information after adding
    in List<NES_DashboardUtilities.StudentInformation>
    */
   /* @AuraEnabled
    public static List<NES_DashboardUtilities.StudentInformation> getAssociatedStudents(){
        return NES_DashboardHelper.getRelatedStudentsWithId(UserInfo.getUserId());
}*/
    
    
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
* Created by Ashish Sharma on 11/14/18.
* Parameters: Id
* Return Type: List<NES_DashboardUtilities.StudentInformation>
* Purpose : This method is used to retrieve all program enrollments related to the students (based on care taker user's Id passed in the method parameter)
and then get all PROCESS_RT
type Enrollment components and related ECAs. Return this information after adding
in List<NES_DashboardUtilities.StudentInformation>
*/
    /*@AuraEnabled
    public static List<NES_DashboardUtilities.StudentInformation> getRelatedStudents(Id ctUserId){
        return NES_DashboardHelper.getRelatedStudentsWithId(ctUserId);
    }*/

}