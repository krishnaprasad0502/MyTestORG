public with sharing class SBcAccountActivation {
    public String username{get; set;}
    public String password{get; set;}
    public String newPwd {get; set;} 
    public String encrKey{get;set;}   
    public Configuration__c config {get;set;} 
    public configurationDetails__c configDet {get;set;} 
    public static boolean isApexTest = false;
    public String baseFolder { get; set;}
    public String baseURL { get; set;}
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}
        
    public SBcAccountActivation(){        
        try{
            verifyAccess();
            if(!pageRender || disableButtons == true){
                SBcUtil.showMsg('error','Insufficient Access - Please Contact your administrator');
                return;
            }
            config = new Configuration__c();
            configDet = new configurationDetails__c();
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();        
        }catch(Exception ex){
                system.debug('Exception Caught::::'+ex.getStackTraceString());
        }
    }    
    
    public Pagereference activateUser(){
        try{
            SBcUtil util = new SBcUtil();   
            String response;
            if(newPwd.length() < 7){
                SBcUtil.showMsg('error','New Password should be atleast greater than 8 characters.');               
            }            
            if((username != null && username !='') && (password != null && password != '') &&
                (newPwd != null && newPwd != '') && (encrKey!= null && encrKey!= '')){
                    if(!isApexTest){
                        response = util.invokeActivation(isApexTest,username,password,newPwd,encrKey);
                    }else{
                        response ='Activation success. User base folder = testuser_csssf_com';
                    }
                    if(response != null && response.contains('Activation success')){
                        if(insertRecord(response)){ 
                            return Page.SBvAccountDetails;  
                        }                       
                    }else{
                        SBcUtil.showMsg('error', response);                       
                    }      
            }else{
                SBcUtil.showMsg('error','Required Field(s) must contain a value.');
            }         
           
        }catch(Exception ex){
            system.debug('Exception Occurred:'+ex.getStackTraceString());            
        } 
        return null;           
    } 
    public boolean insertRecord(String response){
        try{
              if(response != null && response.trim().length()>0){ 
                     String[] values = response.split('=');
                     config.Base_Folder__c = values[1];
                     configDet.Name = username;   
                     configDet.Username__c = username;
                     configDet.password__c = newPwd;
                     config.Organization_Name__c = 'default';
                     configDet.EKey__c = encrKey;                    
                     Database.Upsertresult lsr;
                     Database.Upsertresult lsr1;
                     lsr = Database.upsert(config); 
                     lsr1 = Database.upsert(configDet); 
                     if(lsr.isSuccess() && lsr1.isSuccess()){
                         return true; 
                     }else{
                        SBcUtil.showMsg('error','Failed to insert record.');
                        return false; 
                    }                 
               }else{
                    SBcUtil.showMsg('error','Problem in account activation.');
                    return false; 
               }  
            }catch(Exception ex){
                system.debug('Problem in activating account....'+ex.getStackTraceString());
                return false; 
            }       
    }    
   
    public void verifyAccess(){
        try{        
            this.pageRender = true;
            this.disableButtons = false;                    
            
            Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'create','Organization_name__c'=>'create'};           
            
            Configuration__c configObj = new Configuration__c();
            
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
                pageRender = false;
                disableButtons = false;
            }               
            
        }catch(Exception ex){ 
            pageRender = false;   
            system.debug('Exception Occured:::'+ex.getStackTraceString());           
        }
    }
    
    
    public Pagereference previousPage(){        
        return Page.SBvConfiguration;
    } 
    
    public Pagereference cancel(){         
        String url = baseURL+'/home/home.jsp'; 
        Pagereference pr = new Pagereference(url);
        pr.setRedirect(true);    
        return pr;
    }     
    
    public static testMethod void testMember(){
        SBcUtil.testMember();
        
        SBcAccountActivation acctActivation = new SBcAccountActivation();
        SBcUtil.showMsg('info', 'User has Sufficient access.');
        SBcAccountActivation.isApexTest = true;
        acctActivation.username ='testuser@csssf.com';
        acctActivation.password ='password123';
        acctActivation.newPwd = 'password123';
        acctActivation.encrKey = 'encrkey123';      
        acctActivation.activateUser();
        system.assertNotEquals(acctActivation.baseFolder,'testuser_csssf_com');
         
        Configuration__c config;
        Integer rcCount  = [Select count() from Configuration__c where id <> null];
        if(rcCount > 0){
            config = [Select Active_Groups__c,Organization_Name__c, Base_Folder__c from Configuration__c limit 1];
            if(config.Organization_Name__c != null && config.Organization_Name__c != ''){
                delete config;
            }
        }
        SBcAccountActivation acctActivation1 = new SBcAccountActivation();
        SBcUtil.showMsg('info', 'User has Sufficient access.');
        SBcAccountActivation.isApexTest = true;
        acctActivation1.username ='';
        acctActivation1.password ='';
        acctActivation1.newPwd = '';
        acctActivation1.encrKey = '';
        acctActivation1.activateUser();       
        
        acctActivation1.baseFolder ='';
        acctActivation1.insertRecord(acctActivation.baseFolder);
        
        acctActivation1.previousPage();
        acctActivation1.cancel();   
        
        acctActivation1.username ='testuser@csssf.com';
        acctActivation1.password ='password123';
        acctActivation1.newPwd = 'password123';
        acctActivation1.encrKey = '';      
        acctActivation1.activateUser(); 
        
    }
}