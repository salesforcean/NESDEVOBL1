@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('GET', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"totalMatches":107,"count":7,"results":[{"suggestion":"1600 Pennsylvania Ave, Apalachin NY 13732","matched":[[18,21],[5,17],[0,4]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=3b56c375-d42b-4fc6-98a3-aeb041b5da9e_U40_24_0_0_0%3D1600%24QL21%24GEO0"}]}');

        res.setStatusCode(200);
        return res;
    }
}