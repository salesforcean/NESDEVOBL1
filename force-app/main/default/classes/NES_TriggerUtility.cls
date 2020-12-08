public class NES_TriggerUtility{

    public static Boolean businessLogicSwitch(String name){
       if(String.isNotBlank(name)){
           NES_LogicFeatureSwitch__c logicSwitch = NES_LogicFeatureSwitch__c.getInstance(Name);
           return (logicSwitch == null) ? false : logicSwitch.Active__c;
       }

        return false;
    }
}