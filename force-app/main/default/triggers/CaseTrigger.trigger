trigger CaseTrigger on Case (before update,after update) {
    system.debug('@@@@'+trigger.new);
    system.debug('@@@@'+trigger.old);
}