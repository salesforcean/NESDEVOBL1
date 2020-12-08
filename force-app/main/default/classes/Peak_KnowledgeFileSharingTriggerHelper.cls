/* Copyright © 2016-2017 7Summits, Inc. All rights reserved. */

public with sharing class Peak_KnowledgeFileSharingTriggerHelper {
        public static void handleBeforeInsert(List<ContentDocumentLink> newList){
            for(ContentDocumentLink contentLink : newList) {
                Schema.SObjectType sobjectType = contentLink.LinkedEntityId.getSObjectType();
                String sobjectName = sobjectType.getDescribe().getName();
                if(sobjectName == 'Knowledge__kav'){
                    contentLink.Visibility='AllUsers';
                }
            }
        }
}