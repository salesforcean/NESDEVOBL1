public class SAML_Bearer_POC {

    private String subject;
    private String issuer = '3MVG9y6x0357HlefuPJYJs5i7W3xONzPT6oaKQrUtZnhE6u3.oILkJQEdMsV94QitOE8TENTetwB34gWqqcYD';
    private String audience = 'https://login.salesforce.com';
    private String action = 'https://login.salesforce.com/services/oauth2/token'; 
    
    private string notBefore;
    private String notOnOrAfter;

    private String assertionId; 
    private string digest1;
    private string signature1;
    
    private String encodedKey = 'MIIEowIBAAKCAQEArkUPyr6To5sWo+gMxxww3siR0dvLFXF7CRydyk29T4fOVPIgHzOZZfYWLdTXHt9an0xNoY3ObZpZj57393YkRo0YGsSHskei2NOSvS4RiK54aYrv6LXMd42X3bGrUaOYkLbJ69WmvaCNwJQI1JA7KzjsmREbuqbfFSu1XZFcmh56TTzU0vss7ygbrWJWcxbDvy0eSEhhIzRkxNimrcXsWwgWIGxEOdVqHWCoojzYdS6SNmKrkF8dRtBcRJdFEDRrLM4wFdd2vI5ts+dAvz0CgyUhwMJ/Wm5xjVpJZ9I5NKWnSyZ1ftMwetSqezVb9uTHNNaUzYwqeZsD4VYZt+wQIDAQABAoIBACUbnLtSUzmDUK3bNhwvbTpgSLKaJK7+BNHio+kct26o15GhM0zGpYjp4L3YU9AeJtJdsuYIm6rO7iI5hV/fAQlIEBotRwbYUlhCQwSdtHaCx3GuU+1P/1VulOmbx4DUeBUwfeJPm3sZ5IBmewHoFFhZQatyeRYRpKZ(8nU6PtRIlESFXPTwykD/CBH2a9UQ4cF5I0nHZ/ePrY7mJmTSxW/GpNRNvnqyU0blYHNUtlmn9B/1G12UUg9arhHJI9Xevu5K8GKmshE2YYSVmfHgfeaj7JwFdduvJ2xy8AeosZMu46pHnxBsoFx2ock2CBSWilpE224aYXgxn+OOE/z2N1ECgYEA/ykPUQUhgC0d0lYw3I8mUvTlK7jhQ3SqkigU1gRxc7unhNXPrQ7t3IaPiHgz4vD1IzQuvkL+RzL31JtVU39rxT00qlbbH9loPxOxax/Rmvm2DmQQDJ7361M3l20+HFot+6+MU6yjiWYCFkZP+ZSDWggwNkpeiNEwFV1ff4GmLDsCgYEArtS2gHcPmS8Wb1JhlizgQf2h+LfRG6qddwccAGI4Ulu5WCdhKQ6K1uAzoGW0XFVNLsEvu+MKEYRLza0k+HgvxmtWryzapyFFTeXQ/0oOxGtJgVXVFJKC2TpSJ++4LmGjG98ppdPN1gX6ZViUKWGUu9Y3ZIyEg/28ohd5aW2aHTMCgYEA4CtJmougcASzI3y3tr5JFC61PCFUPrg7tuZhz9jdd6kQtqJFryvji4/ogCPiqem55DDPNDaVQSYlF3NUlmPm4cUxBMoD/0o4zNnXUF8G/lmOObxtYTk0ZFmbCH1gSPZtWaZT6ZtNncOx57HkR0fT0oBJIxlZTmhCDzMWWGYmAMsCgYBzW6GsNGNTdTF9dMM1Xxj+EggM3+UXN0W9YzCDxEtbdHBgjWNbvt+3lqoZ/OG8RwCtiAUiGVXsZvnJlaSeWldTukGxRoxj2N0s4CY+PLRvwEb5ExSNBXtXMFdDSLajzALfAiot5AqeXMVyl7bzcxK7ukZEjz9lBEiyP4D6Irqc5wKBgBSmQ/giQvXWd2hYgDYO7Im+4ls0VMgEHKcvXt38B7LUB02ul5xyOEyYVq6z+A7/WPsgtCOgLDO36b356qeb5c/EyhVgh4fqGHIWs3FRKsdl42rOOmis7aaO1KG3r3E2BqNvNJRSI1nXPgRmMXrMyuh4kBQqiXlM1lMLXo/lWyYI';

private String preCannonicalizedResponse = '<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="ASSERTION_ID" IssueInstant="NOT_BEFORE" Version="2.0"><saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">ISSUER</saml:Issuer><saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified">SUBJECT</saml:NameID><saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData NotOnOrAfter="NOT_ON_OR_AFTER" Recipient="RECIPIENT"></saml:SubjectConfirmationData></saml:SubjectConfirmation></saml:Subject><saml:Conditions NotBefore="NOT_BEFORE" NotOnOrAfter="NOT_ON_OR_AFTER"><saml:AudienceRestriction><saml:Audience>AUDIENCE</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AuthnStatement AuthnInstant="NOT_BEFORE"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef></saml:AuthnContext></saml:AuthnStatement></saml:Assertion>';
    private String preCannonicalizedSignedInfo = '<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:CanonicalizationMethod><ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod><ds:Reference URI="#ASSERTION_ID"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></ds:Transform></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod><ds:DigestValue>DIGEST</ds:DigestValue></ds:Reference></ds:SignedInfo>';
    private String signatureBlock = '<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">SIGNED_INFO<ds:SignatureValue>SIGNATURE_VALUE</ds:SignatureValue></ds:Signature><saml:Subject>';
    
    
    public SAML_Bearer_POC() {
        subject = 'connectapp@example.com';
        
        datetime nowDt = datetime.now();
        Long nowLong = nowDt.getTime();
        datetime notBeforeDt = datetime.newInstance(nowLong - 120000);
        
        notBefore = notBeforeDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z';
        datetime notOnOrAfterDt = nowDt.addMinutes(5);
        notOnOrAfter = notOnOrAfterDt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z';
        
        Double random = Math.random();
        assertionId = EncodingUtil.convertToHex(Crypto.generateDigest('SHA256',  Blob.valueOf('assertion' + random)));
        
    }

    public String getResult(){
              
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('ASSERTION_ID',assertionId);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('ISSUER',issuer);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('AUDIENCE',audience);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('RECIPIENT',action);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('SUBJECT',subject);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('NOT_BEFORE',notBefore);
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('NOT_ON_OR_AFTER',notOnOrAfter);
        
        //Prepare the Digest
        Blob digest = Crypto.generateDigest('SHA1',  Blob.valueOf(preCannonicalizedResponse));
        String digestString = EncodingUtil.base64Encode(digest);

        //Prepare the SignedInfo
        preCannonicalizedSignedInfo = preCannonicalizedSignedInfo.replaceAll('ASSERTION_ID',assertionId);
        preCannonicalizedSignedInfo = preCannonicalizedSignedInfo.replaceAll('DIGEST',digestString);
                
        //Sign the SignedInfo
        Blob privateKey = EncodingUtil.base64Decode(encodedKey);
        Blob input = Blob.valueOf(preCannonicalizedSignedInfo);
                
        Blob signature = Crypto.sign('RSA', input, privateKey);
        //Blob signature = Blob.valueOf('foo');
        String signatureString = EncodingUtil.base64Encode(signature);
        
        //Prepare the signature block
        signatureBlock = signatureBlock.replaceAll('SIGNED_INFO',preCannonicalizedSignedInfo);
        signatureBlock = signatureBlock.replaceAll('SIGNATURE_VALUE',signatureString);
        
        //cheap trick for enveloping the signature by swapping out last element with sig + last elements of whole message
        preCannonicalizedResponse = preCannonicalizedResponse.replaceAll('<saml:Subject>', signatureBlock );
        
        //return the prefix + our prepped message
        System.debug('ASSERTION:' + preCannonicalizedResponse);
        return preCannonicalizedResponse;
  
    }
    
     public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
   }
   
    public void postSAML()
   {
        String saml = getResult();
        System.debug('\n===============SAML==============\n: ' + saml);
        http h = new http();
        httpRequest req = new httpRequest();
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        String param = 'grant_type=' + encodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:saml2-bearer','UTF-8')+'&assertion=' + base64URLencode(blob.valueOf(saml)); 
        req.setBody(param);
        
        req.setEndpoint(action);
   httpResponse res = h.send(req);
        System.debug('\n\nRESPONSE: ' + res.getBody());
        System.debug('\n\nRESPONSE: ' + res.getStatusCode() + '  ' + res.getStatus()); 
   }
   
}