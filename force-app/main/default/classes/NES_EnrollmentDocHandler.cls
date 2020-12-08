/**
 * Created by Anushka on 22-11-2018.
 * Purpose : Handler class for EnrollmentDocumentTrigger.
 * Change Log:
 *         2019-08-14 for #101928 User Story (Chinnamanaidu Neerasa)
 * Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-10
 *          2019-09-27 for #110673 User Story - task # 111017(Chinnamanaidu Neerasa)
 **/

public class NES_EnrollmentDocHandler {
    static final Boolean logicSwitch = NES_TriggerUtility.businessLogicSwitch('EnrollmentDocTrigger');
    static final Boolean whyFlaggedLogicSwitch = NES_TriggerUtility.businessLogicSwitch('Why Flagged');

  public static void handleBeforeUpdate(List<Enrollment_Document__c> newList, Map<Id, Enrollment_Document__c> newMap,Map<Id, Enrollment_Document__c> oldMap){
   
        if(logicSwitch) {
            //To update DateReview Field
            NES_EnrollmentDocBusinessLogic.updateDateReviewed (newMap, oldMap);
             // Task # 118319 - Added new Method. Chinnamanaidu Neerasa November 13,2019.
            NES_EnrollmentDocBusinessLogic.updateDocumentRevStatus(newMap, oldmap);
        }
    }

    public static void handleBeforeInsert(List<Enrollment_Document__c> newList){ 
     
        if(logicSwitch) {
            NES_EnrollmentDocBusinessLogic.reviewDocumentsBefore_Insert(newList);
        }
    }

  //  public static void handleAfterInsert(List<Enrollment_Document__c> newList, Map<Id, Enrollment_Document__c> newMap){ //Swapna-Changed signature
      public static void handleAfterInsert(List<Enrollment_Document__c> newList, Map<Id, Enrollment_Document__c> newMap,List<Enrollment_Document__c> actList, Map<Id, Enrollment_Document__c> actlstnewMap){  
        System.Debug('NES_EnrollmentDocHandler::handleAfterInsert1: ' + logicSwitch);
        if(!logicSwitch) return ;
        NES_EnrollmentDocBusinessLogic.updateLastDocUploadDateOnInsert(newList);
        NES_EnrollmentDocBusinessLogic.updateDocumentStatus(newList,null,null );
        //logicHandler.reviewDocumentsBefore_Insert(newList);
        //START - Task #59999 Raju December 24, 2018
       if(whyFlaggedLogicSwitch){
         NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actList, null);//Swapna:Changed to active list
      //   NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newList, null);
        }
        NES_EnrollmentDocBusinessLogic.insertDocECAStatus(newList);
         //Start-added for #107180 User Story (Task 108660) on 2019-09-10  
         //NES_EnrollmentDocBusinessLogic.updatePAHStatus(newMap);
        //End-added for #107180 User Story (Task 108660) on 2019-09-10  
        System.Debug('NES_EnrollmentDocHandler::handleAfterInsert2');
    }

  //  public static void handleAfterUpdate(Map<Id, Enrollment_Document__c> newMap,Map<Id, Enrollment_Document__c> oldMap){ //Swapna -Changed signature
      public static void handleAfterUpdate(Map<Id, Enrollment_Document__c> newMap,Map<Id, Enrollment_Document__c> oldMap,Map<Id, Enrollment_Document__c> actlstnewMap,Map<Id, Enrollment_Document__c> actlstoldMap){
        
        System.Debug('NES_EnrollmentDocHandler::handleAfterUpdate1: ' + logicSwitch);
        if(!logicSwitch) return ;

        NES_EnrollmentDocBusinessLogic.updateDocumentStatus(null ,newMap,oldMap);

        //START - Task #59999 Raju December 24, 2018
        if(whyFlaggedLogicSwitch){
        NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
         //  NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newMap.values(), oldMap);
        }
        NES_EnrollmentDocBusinessLogic.updateDocECAStatus(newMap);
        // Task # 104355 - Added new Method. Chinnamanaidu Neerasa August 12,2019.
        NES_EnrollmentDocBusinessLogic.updateDocumentECAStatus(newMap, oldmap);
        // Task # 111017 - Added new Method. Chinnamanaidu Neerasa September 27,2019.
        NES_EnrollmentDocBusinessLogic.updateECAStatusToDeferred(newMap, oldmap);
        // END Task # 104355.
     //   NES_EnrollmentDocBusinessLogic.calculatePlacement(newMap.values(), oldMap);
          NES_EnrollmentDocBusinessLogic.calculatePlacement(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
        //END - Task #59999
        //Start-added for #107180 User Story (Task 108660) on 2019-09-10  
         //NES_EnrollmentDocBusinessLogic.updatePAHStatus(newMap);
        //End-added for #107180 User Story (Task 108660) on 2019-09-10  
        System.Debug('NES_EnrollmentDocHandler::handleAfterUpdate2');

    }
}