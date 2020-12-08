/**********************************************************************************************************************
* @Author           : SumaPriyanka
* @ Class           : ChangePasswordController                                                           
* @ Description     : OOB apex page controller that exposes the change password functionality.
                      Customized to append registered schoolid and navigates to community enrollment tab after login.                                                                                                                      
***********************************************************************************************************************/

    public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;} 
    public String userid{get;set;}
    public PageReference changePassword() {        
        Pattern regexPattern = Pattern.compile('^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$');
        Matcher regexMatcher = regexPattern.matcher(newPassword);    
        if (!regexMatcher.matches()) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No matches found'));
         return null;
        } else {
        // fetch current user id
        userid = Userinfo.getUserId();
        // fetch username of current user
        String usrString = [SELECT username FROM User WHERE id =: userid].username; 
        // to fetch schoolid of the current user      
        usrString = usrString.right(7);
        usrString = usrString.touppercase();
        PageReference returnToPage;
        returnToPage = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        // to navigate the user to enrollment tab after clicking ChangePassword button
        returnToPage = new PageReference('/customerService/s/enrollment?schoolid='+usrString);        
        return returnToPage;
        }
    }       
    public ChangePasswordController() {}
}