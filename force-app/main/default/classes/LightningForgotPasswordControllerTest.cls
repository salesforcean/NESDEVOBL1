@isTest
public class LightningForgotPasswordControllerTest {
    static TestMethod void forgotPassword_Test() {
    
    String userid = UserInfo.getUserId();
        User activeUser = [Select Email From User where id = : userid limit 1];
        String userEmail = activeUser.Email;
        string currenUMail = Userinfo.getUserEmail();
          
        LightningForgotPasswordController lfpc= new LightningForgotPasswordController();
     
        LightningForgotPasswordController.forgotPassword('test','test');
       
    
    
    }
    }