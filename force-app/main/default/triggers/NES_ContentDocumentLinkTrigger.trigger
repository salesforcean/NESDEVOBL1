/**
 * Created by Ashish Pandey on 1/8/2019.
 */
trigger NES_ContentDocumentLinkTrigger on ContentDocumentLink(before insert){
    if(trigger.isBefore){
        if(trigger.isInsert){
            NES_ContentDocumentLinkHandler.beforeInsert(trigger.new);
        }       
    }
}