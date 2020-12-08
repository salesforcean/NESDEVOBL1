/**
 * Created by Ritvik on 25-10-2018.
 */

trigger NES_AccountTrigger on Account(before insert, before update, after insert, after update) {
	//Swapna:COmmented as the respective functionality is deprecated
	if (Trigger.isAfter && Trigger.isUpdate) {

		Map<Id, Account> actlstoldMap = new Map<Id, Account> ();
		Map<Id, Account> actlstnewMap = new Map<Id, Account> ();
		for (Account asi : Trigger.new) {
			actlstnewMap.put(asi.id, Trigger.newMap.get(asi.id));
			actlstoldMap.put(asi.id, Trigger.oldMap.get(asi.id));
		}
		NES_AccountHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap, actlstoldMap, actlstnewMap);
	}

	if (Trigger.isAfter && Trigger.isInsert) {
		List<Account> actlst = new List<Account> ();

		for (Account asi : Trigger.new) {
			actlst.add(asi);
		}
		NES_AccountHandler.handleAfterInsert(Trigger.new, Trigger.oldMap, actlst);
	}
}