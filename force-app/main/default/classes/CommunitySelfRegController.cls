public class CommunitySelfRegController {
    @AuraEnabled
    public static String createExternalUser(
        String username, String password, String startUrl, String fname, 
        String lname, Boolean hasOptedTracking, Boolean hasOptedSolicit) {
            Savepoint sp = null;
            try {
                sp = Database.setsavepoint();
                system.debug(sp);
                
                // Creating a user object. 
                User u = new User();
                u.Username = username;
                u.Email = username;
                u.FirstName = fname;
                u.LastName = lname;

                // Default UI for mobile is set to S1 for user created using site object. 
                // Enable this perm to change it to community (Experience Cloud).
                u.UserPreferencesHideS1BrowserUI = true;
                
                // Generating unique value for Experience Cloud nickname. 
                String nickname = ((fname != null && fname.length() > 0) ? fname.substring(0,1) : '' ) + lname.substring(0,1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                u.CommunityNickname = nickname;
                
                System.debug('creating user');
                
                // Creating portal user. 
                // Passing in null account ID forces the system to read this from the network setting (set using Experience Workspaces).
                String userId = Site.createPortalUser(u, null, password);
                
                // Setting consent selection values. 
                // For this, GDPR (Individual and Consent Management) needs to be enabled in the org. 
                Individual ind = new Individual();
                ind.LastName = lname;
                ind.HasOptedOutSolicit = !hasOptedSolicit;
                ind.HasOptedOutTracking = !hasOptedTracking;
                insert(ind);
                
                // Other contact information can be updated here. 
                Contact contact = new Contact();
                contact.Id = u.ContactId;
                contact.IndividualId = ind.Id;
                update(contact);       
                
                // return login url. 
                if (userId != null && password != null && password.length() > 1) {  
                    ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                    return lgn.getUrl();
                }
            }
            catch (Exception ex) {
                Database.rollback(sp);
                System.debug(ex.getMessage());
                return null;
            }
            return null; 
        }   
}