/**
 * Created by Raju on 01/17/2019.
 */
public with sharing class NES_ContentDocumentLinkHandler {
     public Static void beforeInsert(List<ContentDocumentLink> contentdocumentList){
      NES_ContentDocumentLinkBusinessLogic.updateContentDocumentLinkVisibilityOnInsert(contentdocumentList);
        
    }
}