/*Copyright © 2016-2018 7Summits, Inc. All rights reserved.*/

@isTest
global class Peak_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        HttpResponse res;
        if(req.getEndpoint().contains('/services/data/v40.0/connect/communities/null/chatter/users/batch/')){
            System.assertEquals(System.URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v40.0/connect/communities/null/chatter/users/batch/', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().startsWith('https://api.edq.com/capture/address/v2/search?query=')){
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"totalMatches":107,"count":7,"results":[{"suggestion":"1600 Pennsylvania Ave, Apalachin NY 13732","matched":[[18,21],[5,17],[0,4]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=3b56c375-d42b-4fc6-98a3-aeb041b5da9e_U40_24_0_0_0%3D1600%24QL21%24GEO0"}]}');

            res.setStatusCode(200);

        }
        if(req.getEndpoint().startsWith('https://api.edq.com/capture/address/v2/format?country=USA&id=')){
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('"address": [ { "addressLine1": "3D103%24QL8%24GEO0 N Ohio" }, { "addressLine2": "" }, { "addressLine3": "" }, { "locality": "Oxford" }, { "province": "KS" }, { "postalCode": "67119-8105" }, { "country": "UNITED STATES OF AMERICA" } ]');
            res.setStatusCode(200);

        }
        //Addedby Raju ()
        if(req.getEndpoint().startsWith('https://api.experianmarketingservices.com/sync/queryresult/PhoneValidate/1.0/')){
            System.assertEquals('POST', req.getMethod());

            // Create a fake response
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"Number": 56988,  "DefaultCountryCode": "+1"}');
            res.setStatusCode(200);
        }
        //Addedby Anand ()
        if(req.getEndpoint().startsWith('https://alpha-bweber-mdr.search.windows.net/indexes/azuresql-index/docs/search?')){
            System.assertEquals('POST', req.getMethod());

            // Create a fake response
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"@odata.context":"https://alpha-bweber-mdr.search.windows.net/indexes(\''+'azuresql-index'+
                    ')/$metadata#docs(*)","@search.nextPageParameters":{"select":"schoolName,streetAddress,city,districtName,stateAbbr,postalCode,countryAbbr","searchFields":"schoolName,city,stateAbbr,districtName","search":"hebron high mdHanoverMD","skip":50},"value":[{"@search.score":3.5380974,"schoolName":"Alden-Hebron Middle High Sch","districtName":"Alden-Hebron School Dist 19","streetAddress":"9604 Illinois St","city":"Hebron","postalCode":"60034","stateAbbr":"IL","countryAbbr":"USA"}]}');
            res.setStatusCode(200);
        }
        return res;
    }
}