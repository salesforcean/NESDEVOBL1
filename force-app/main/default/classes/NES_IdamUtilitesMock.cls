@isTest
global class NES_IdamUtilitesMock implements HttpCalloutMock {
        String accessToken;
        Integer statusCode;
        String status;
        boolean isError;
        boolean isThrowException;
    Global NES_IdamUtilitesMock(String accessToken, Integer statusCode, String status, boolean isError, boolean isThrowException){
            this.accessToken = accessToken;
            this.statusCode = statusCode;
            this.status = status;
            this.isError = isError;
            this.isThrowException = isThrowException;
        }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"tokenId":"dummyToken","successUrl":"dummyClientId","realm":"test"}');
        res.setStatusCode(200);
        return res;
    }
}