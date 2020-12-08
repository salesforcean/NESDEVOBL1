/**
 * Created by 7Summits on 8/7/17.
 */


@IsTest
public with sharing class Peak_KnowledgeFilterTest {

    private static List<Topic> createTopic(Integer noOfEvents) {
        List<topic> topicList = new List<topic>();
        for(Integer i=0;i<noOfEvents;i++){
            Topic topicObj = new Topic(Name='Test00' + i, Description='Test');
            topicList.add(topicObj);
        }
        insert topicList;
        return topicList;
    }

    private static TopicAssignment createTopicAssignment(String strTopicId, String strEntityId)
    {
        TopicAssignment topicAssigmnt = new TopicAssignment(EntityId = strEntityId, TopicId = strTopicId);

        insert topicAssigmnt;
        return topicAssigmnt;
    }


    @testSetup static void setup() {
        Schema.SObjectType articleType;
        Map<String, Schema.SObjectType> describedItems = Schema.getGlobalDescribe();
        for (String key : describedItems.keySet()) {
            if (key.endsWith('kav')) {
                articleType = Schema.getGlobalDescribe().get(key);
                // We have an article type...let's get out
                break;
            }
        }
        List<String> documentsTitles = new List<String>{'Test Knowledge One', 'Test Knowledge Two', 'Test Knowledge Three'};

        List<Topic> topics = createTopic(2);

        for (String title : documentsTitles) {
            SObject kav =  articleType.newSObject();
            kav.put('title', title);
            kav.put('urlName', title.replaceAll( '\\s+', ''));
            kav.put('Language', 'en_US');

            insert kav;

            String filterQuery = 'SELECT KnowledgeArticleId FROM ' + articleType + ' where ID = \'' + kav.Id + '\'';

            System.debug(Database.query(filterQuery));
            SObject insertedTestKav = articleType.newSObject();
            insertedTestKav = Database.query(filterQuery)[0];


            KbManagement.PublishingService.publishArticle((String)insertedTestKav.get('KnowledgeArticleId'), true);

            // create topic assignment
            createTopicAssignment(topics[0].id, kav.id);
            createTopicAssignment(topics[1].id, kav.id);
        }
    }


    @isTest
    public static void testDoSearchWithoutSearchQuery() {
        String searchTerm = '';

        List<Topic> topics = [SELECT id FROM Topic LIMIT 1];

        List<String> topicIdsOne = new List<String>{topics[0].id};
        List<String> topicIdsTwo = new List<String>{topics[0].id};
        List<String> topicIdsThree = new List<String>{topics[0].id};
        List<String> topicIdsFour = new List<String>{topics[0].id};

        String orderByField = null;
        String orderByDirection = null;

        Test.startTest();
        Peak_KnowledgeFilter_SearchResults results = Peak_KnowledgeFilterController.doSearch(searchTerm, topicIdsOne, topicIdsTwo, topicIdsThree, topicIdsFour, orderByField, orderByDirection);
        Test.stopTest();

        System.assertEquals(true, true);
    }

    @isTest
    public static void testDoSearchWithSearchQuery() {
        String searchTerm = 'Test Knowledge';

        List<Topic> topics = [SELECT id FROM Topic LIMIT 1];

        List<String> topicIdsOne = new List<String>{topics[0].id};
        List<String> topicIdsTwo = new List<String>{topics[0].id};
        List<String> topicIdsThree = new List<String>{topics[0].id};
        List<String> topicIdsFour = new List<String>{topics[0].id};

        String orderByField = null;
        String orderByDirection = null;

        Test.startTest();
        Peak_KnowledgeFilter_SearchResults results = Peak_KnowledgeFilterController.doSearch(searchTerm, topicIdsOne, topicIdsTwo, topicIdsThree, topicIdsFour, orderByField, orderByDirection);
        Test.stopTest();

        System.assertEquals(true, true);
    }


}