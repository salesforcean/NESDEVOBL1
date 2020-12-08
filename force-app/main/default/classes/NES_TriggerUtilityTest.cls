/**
 * Created by Anushka on 07-01-2019.
 */

@IsTest
private class NES_TriggerUtilityTest {

    static testMethod void testbusinessLogicSwitchPositive() {
    NES_LogicFeatureSwitch__c  logicSwitch = Peak_TestUtils.createNESBusinessLogicSwitch('SpecialEdTrigger', true);
        Boolean flag = NES_TriggerUtility.businessLogicSwitch(logicSwitch.Name);
        System.assertEquals(flag, True);
    }
    
    static testMethod void testbusinessLogicSwitchNegative() {
        Boolean flag = NES_TriggerUtility.businessLogicSwitch('');
        System.assertEquals(flag, false);
    }
   }