//Swapna:Created for Dup logic
public class FieldUtils {
    
  public static string getFields(string objName) {

        String fieldnames = '';
        sObject obj;
        String qry;
        try {
            Map < String, Schema.SObjectType > m = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();

            //get fields
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            for (string field: fields.keySet()) {
              if(field != 'LeadSource' && field != 'Channel_Type__c' && field != 'OwnerId' && field != 'Lead_Eligible_for_Call_DateTime__c' && field != 'First_Call_Completed_Date_Time__c'){
                       if (fieldnames == '') {
                    fieldnames = field;
                } else {
                    fieldnames += ',' + field;
                }
             }
            }

              qry  = 'SELECT ' + fieldnames + ' FROM ' + objName+ '';
       

        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
      
       return qry;
    }
}