/**
 * Created by Raju on 01/17/2019.
 */
public with sharing class NES_ContentDocumentLinkBusinessLogic {
     public static void updateContentDocumentLinkVisibilityOnInsert(List<ContentDocumentLink>newList){
        for(ContentDocumentLink link : newList){
            System.debug('link.ContentDocument.Title>>'+link.ContentDocument.Title);
            link.Visibility = 'AllUsers';
        }
    }

}