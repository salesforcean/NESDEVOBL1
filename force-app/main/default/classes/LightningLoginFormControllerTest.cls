@isTest
public class LightningLoginFormControllerTest {
   static TestMethod void login_Test() {
    String userid = UserInfo.getUserId();
        User activeUser = [Select Email From User where id = : userid limit 1];
        String userEmail = activeUser.Email;
        string currenUMail = Userinfo.getUserEmail();
    
    LightningLoginFormController llfc = new LightningLoginFormController();
    LightningLoginFormController.login('test','Test','test');
  LightningLoginFormController.getIsUsernamePasswordEnabled();
  LightningLoginFormController.getIsSelfRegistrationEnabled();
  LightningLoginFormController.getSelfRegistrationUrl();
       
  //LightningLoginFormController.getForgotPasswordUrl();
  //LightningLoginFormController.getAuthConfig();
    }
    }