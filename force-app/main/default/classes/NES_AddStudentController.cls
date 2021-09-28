/**
 * Created by triciaigoe on 12/26/18.
 */
public without sharing class NES_AddStudentController {

    /**
     * Created by ajith on 15/10/18.
     * Purpose : This method would initialize and pass new student data to the FED.
    */
    @AuraEnabled
    public static NES_EvaluateUtil.NewStudentData getNewStudentData() {
        NES_EvaluateUtil.NewStudentData data = NES_AddStudentHelper.grabStudents();
        System.debug(data);
        return data;
    }

    @AuraEnabled
    public static Peak_Response getSchoolYears(Id schoolId) {
        Peak_Response data = NES_AddStudentHelper.grabSchoolYears(schoolId);
        return data;
    }

    /**
     * Created by ajith on 15/10/18.
     * Purpose : This method would return a object which would contain the Enrollment Component Records of Question Type based on the account Id
     *           that is passed from the FED. This method looks into the different types of the Enrollment Component records before returning the actual object.
    */
    @AuraEnabled
    public static List<NES_EvaluateUtil.Question> getComponentsByAcademicProgram(String schoolId, String schoolYearId) {
        List<NES_EvaluateUtil.Question> returnObjList = NES_AddStudentHelper.grabQuestionsBySchool(schoolId, schoolYearId);
        return returnObjList;
        
    }

    /**
     * Created by ajith on 15/10/18.
     * Purpose : This method would create the New Student and care taker relation ship
     *           Also would create Program enrollments for the academic program account
     *           Stores question responses from the user Input from the FED.
     * params : This method would take two params which are of the JSON String of object type of the same class.
    */
    @AuraEnabled
    public static Peak_Response createStudent(String studentJSON, String questionJSON) {
        Peak_Response peakResponse = NES_AddStudentHelper.insertingStudent(studentJSON, questionJSON);
        return peakResponse;
    }
 /**
     * Created by AnithaP on 08/11/18 for US116612
     * Purpose : This method would create picklist values for Suffix
    */
   @AuraEnabled
    public static List<String> getSuffixValuesIntoList(){
		List<String> pickListValuesList = new List<String>();
		List<Suffix__mdt> stateList = [Select label from Suffix__mdt order by label ];
		for(Suffix__mdt obj: stateList) {
		   pickListValuesList.add(obj.label);
		}
        return pickListValuesList;
    }
}