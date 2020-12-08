/**
 * Created by Anushka on 11-12-2018.
 * Purpose : BusinessLogic class for HealthAndImmunizationTrigger called by HealthAndImmunizationHandler.
 */

public class NES_HealthAndImmunizationBusinessLogic {
  /**
   * Created by Anushka on 22-11-2018.
   * Purpose : This method updates the Immunization current Status on the Health and Immunization record.
   */
  public static void updateImmunizationStatusCurrent(Map < Id, Health_and_Immunization__c > newMap, Map < Id, Health_and_Immunization__c > oldMap) {
   system.debug('business logic - HNI');
   List < Health_and_Immunization__c > healthAndImmunizationList = new List < Health_and_Immunization__c > ();
   for (Health_and_Immunization__c hni: newMap.values()) {
    if (hni.Immunization_Status_FollowUp__c != oldMap.get(hni.Id).Immunization_Status_FollowUp__c ||
     hni.Immunization_Status__c != oldMap.get(hni.Id).Immunization_Status__c)
     healthAndImmunizationList.add(hni);
   }

   NES_BusinessLogicUtils.updateImmunizationStatusCurrent(healthAndImmunizationList);
   system.debug('list --' + NES_BusinessLogicUtils.updateImmunizationStatusCurrent(healthAndImmunizationList));
  }
}