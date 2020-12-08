/**
 * Created by Anand on 12/10/2018.
 * purpose: business logic for NES_HomeLanguageSurveyHandler
 */


public with sharing class NES_HomeLanguageSurveyBusinessLogic {

    /**
    * Created By Anand 12/10/2018
    *Purpose:To call calculateELLFlag function of NES_BusinessLOgicUtils on After Insert/Update
    * @param oldMap
    * @param newList
    */
    public Static void calculateELLFlag(List<Home_Language_Survey__c> newList,Map<Id,Home_Language_Survey__c> oldMap){
        List<Home_Language_Survey__c> homeLangSurvey=new List<Home_Language_Survey__c>();
        for(Home_Language_Survey__c homLangSurvey : newList){
            if (oldMap != null ) {
                if (oldMap.get(homLangSurvey.Id).HLS_Date_Completed__c != homLangSurvey.HLS_Date_Completed__c) {
                    homeLangSurvey.add(homLangSurvey);
                }
            } else {
                homeLangSurvey.add(homLangSurvey);
            }
        }
        if(!homeLangSurvey.isEmpty()){
            NES_BusinessLogicUtils bussLogicUtils=new NES_BusinessLogicUtils();
            bussLogicUtils.calculateELLFlag(homeLangSurvey,new List<Annual_Student_Information__c>(),new List<Hed__Program_Enrollment__c>());
        }
    }

    /**
    * Created by Anushka on 14-12-2018.
    * Purpose : This method calculates the HLS Student flag on Update/Insert
    */
    public static void calculateHLSStudentFlag(List<Home_Language_Survey__c> newList, Map<Id, Home_Language_Survey__c> oldMap){
      List<Home_Language_Survey__c> homeLangSurveyList = new List<Home_Language_Survey__c>();
        for(Home_Language_Survey__c hls : newList){
        if (oldMap != null) {
            if (hls.HLS2_FirstLanguage__c != oldMap.get(hls.Id).HLS2_FirstLanguage__c || 
			    hls.HLS2_ChildLanguage__c != oldMap.get(hls.Id).HLS2_ChildLanguage__c || 
				hls.HLS2_Spoken_To_Child__c != oldMap.get(hls.Id).HLS2_Spoken_To_Child__c ||
				hls.HLS2_Home_Language__c != oldMap.get(hls.Id).HLS2_Home_Language__c ||
				hls.HLS2_School_Communications__c != oldMap.get(hls.Id).HLS2_School_Communications__c ||
				hls.HLS2_School_Communications_Spoke__c != oldMap.get(hls.Id).HLS2_School_Communications_Spoke__c ||
				hls.HLS2_Home_Language_Many__c != oldMap.get(hls.Id).HLS2_Home_Language_Many__c ||
				hls.HLS2_Other_Adults_Language__c != oldMap.get(hls.Id).HLS2_Other_Adults_Language__c )
					homeLangSurveyList.add(hls);
        }
        else if(hls.HLS2_FirstLanguage__c != null || hls.HLS2_ChildLanguage__c != null || hls.HLS2_Spoken_To_Child__c != null ||
		        hls.HLS2_Home_Language__c != null || hls.HLS2_School_Communications__c != null || hls.HLS2_School_Communications_Spoke__c != null ||
				hls.HLS2_Home_Language_Many__c != null || hls.HLS2_Other_Adults_Language__c != null )
            homeLangSurveyList.add(hls);
        }  
        if(homeLangSurveyList.size() > 0)
            NES_BusinessLogicUtils.calculateHLSStudentFlag(homeLangSurveyList);
    }

    /**
    * Created By Ritvik 12/14/2018
    *Purpose:To call calculateHLSLanguageSpokenByAdults function of NES_BusinessLOgicUtils
    * @param newList of updated new record.
    * @param oldMap of updated old record.
    *
    */
    public static void calculateHLSLanguageSpokenByAdults(List<Home_Language_Survey__c> newList, Map<Id, Home_Language_Survey__c> oldMap){
        Set<Id> hlsIds = new Set<Id>();
        for (Home_Language_Survey__c homeLanguageSurvey: newList){
            if (oldMap != null) {
                if (homeLanguageSurvey.HLS_Language_Spoken_By_Adults__c != oldMap.get(homeLanguageSurvey.Id).HLS_Language_Spoken_By_Adults__c ||
                        homeLanguageSurvey.HLS2_Home_Language_Many__c != oldMap.get(homeLanguageSurvey.Id).HLS2_Home_Language_Many__c ||
                        homeLanguageSurvey.HLS_Home_Often_Spoken__c != oldMap.get(homeLanguageSurvey.Id).HLS_Home_Often_Spoken__c ||
                        homeLanguageSurvey.HLS_Student_At_Home__c != oldMap.get(homeLanguageSurvey.Id).HLS_Student_At_Home__c ||
                        homeLanguageSurvey.HLS2_Home_Language__c != oldMap.get(homeLanguageSurvey.Id).HLS2_Home_Language__c ||
                        homeLanguageSurvey.Language_spoken__c != oldMap.get(homeLanguageSurvey.Id).Language_spoken__c ||
                        homeLanguageSurvey.HLS2_Home_Language_NE__c != oldMap.get(homeLanguageSurvey.Id).HLS2_Home_Language_NE__c ||
                        homeLanguageSurvey.HLS_Speak_Understand_NE_YN__c != oldMap.get(homeLanguageSurvey.Id).HLS_Speak_Understand_NE_YN__c ||
                        homeLanguageSurvey.HLS2_Spoken_To_Child__c != oldMap.get(homeLanguageSurvey.Id).HLS2_Spoken_To_Child__c) {
                    hlsIds.add(homeLanguageSurvey.Id);
                }
            } else if(homeLanguageSurvey.HLS_Language_Spoken_By_Adults__c != null || homeLanguageSurvey.HLS2_Home_Language_Many__c != null ||
                    homeLanguageSurvey.HLS_Home_Often_Spoken__c != null || homeLanguageSurvey.HLS_Student_At_Home__c != null ||
                    homeLanguageSurvey.HLS2_Home_Language__c != null || homeLanguageSurvey.Language_spoken__c != null ||
                    homeLanguageSurvey.HLS2_Home_Language_NE__c != null || homeLanguageSurvey.HLS_Speak_Understand_NE_YN__c != false ||
                    homeLanguageSurvey.HLS2_Spoken_To_Child__c != null){
                hlsIds.add(homeLanguageSurvey.Id);
            }
        }
        if(!hlsIds.isEmpty()){
            NES_BusinessLogicUtils.calculateHLSLanguageSpokenByAdults(hlsIds);
        }
    }
}