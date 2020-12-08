/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class ChangePasswordControllerTest {
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = 'Hqwertn1!';
        controller.newPassword = 'Hqwertn12!'; 
        controller.verifyNewPassword = 'Hqwertn12!';                
        
        System.assertNotEquals(controller.changePassword(), null);                           
    }    
    @IsTest(SeeAllData=true) public static void testChangePasswordController1() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = 'test!';
        controller.newPassword = 'test'; 
        controller.verifyNewPassword = 'test';                
        
        System.assertEquals(controller.changePassword(), null);                           
    } 
}