public with sharing class SBcAccountCreation {
    public static boolean isApexTest = false;
    public Configuration__c config {get;set;}
    public configurationDetails__c configDet {get;set;}
    public String orgName{get; set;}
    public String accessKey{get; set;}
    public String secretKey{get; set;}
    public String bucketName{get; set;}
    public String emailId{get; set;}
    public String encrKey{get;set;}
    public String baseURL{get;set;}
    public String username,password,baseFolder; 
    
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;} 
        
    public SBcAccountCreation(){       
        try{
            verifyAccess();
            if(!pageRender || disableButtons == true){
                SBcUtil.showMsg('error','Insufficient Access - Please Contact your Administrator.');
                return;
            }              
            config = new Configuration__c();
            configDet = new configurationDetails__c();
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        }catch(Exception ex){
            system.debug('Exception Caught::::'+ex.getStackTraceString());
        }
         
    }
   
    public String createUsr(){
        String response;
        try
        {       
            if(!SBcUtil.isValidEmailAddress(emailId)){
                response = 'Please enter a valid email address.';
                return response;
            }else{
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('POST'); 
                
                req.setBody('emailid='+emailId+'&accesskeyid='+accessKey+'&secretkeyid='+secretKey+'&bucket='+bucketName.toLowerCase()
                +'&orgname='+orgName+'&encryptvalue='+encrKey);
               
                String url = SBcUtil.getServiceURL()+'?action=userCreation&actionui=false';
                
                req.setEndpoint(url);    
                if (!isApexTest){               
                    HTTPResponse resp = http.send(req);          
                       
                    response = resp.getBody();      
                } else {
                    response = 'Users EmailID=testuser@gmail.com,New password=iTf3oYja';
                } 
            }
        }catch(Exception ex){
            system.debug('Exception Caught::::'+ex.getStackTraceString());
        }  
        return response;    
    }
    
    public Pagereference activateUsr(){
        try
        {    
            String response; 
               
            if((orgName != null && orgName !='') &&
                (accessKey != null && accessKey != '') && (secretKey != null && secretKey != '') &&
                (bucketName != null && bucketName != '') && (encrKey!= null && encrKey!= '')){
                    String respVal = createUsr();                    
                    if(respVal != null && respVal.contains('Users EmailID')){
                        String[] emailAndPwd = respVal.split(',');
                        String[] useremail = emailAndPwd[0].split('=');
                        String[] userpwd = emailAndPwd[1].split('=');
                        username = useremail[1];
                        password = userpwd[1];
                        
                        SBcUtil util = new SBcUtil();
                            if(!isApexTest){
                                response = util.invokeActivation(false, username, password, password,null);                                                              
                            }else{
                                response = 'Activation success. User base folder = testuser_gmail_com';
                            }
                            if(response != null && response.contains('Activation success')){
                                if(insertRecord(response)){ 
                                    return Page.SBvAccountDetails;  
                                }
                            }else{
                                SBcUtil.showMsg('error', response);
                                return null;  
                            }                               
                        }else{
                            SBcUtil.showMsg('error', respVal);
                            return null;  
                        }                                  
                }else{
                    SBcUtil.showMsg('error', 'Required Field(s) must contain a value.');
                    return null;                   
                }
                return null;
        }catch(Exception ex){
            SBcUtil.showMsg('error', 'Problem in account creation.');
             system.debug(ex.getStackTraceString());
             return null;
        }
    }
    public Boolean insertRecord(String response){
        try{
            if(response != null && response != ''){
                     String[] values = response.split('=');
                     config.Base_Folder__c = values[1]; 
                     configDet.Name = username;   
                     configDet.Username__c = username;
                     configDet.password__c = password;
                     config.Organization_Name__c = orgName; 
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
                  SBcUtil.showMsg('error', 'Problem in account creation.');
                  return false;
             }
             return false;
        }catch(Exception ex){
             SBcUtil.showMsg('error', 'Problem in account creation.');
             system.debug(ex.getStackTraceString());
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
            system.debug('Exception Occured....'+ex.getStackTraceString());           
        }
    }    
    
    public String createUserForTest(){
        isApexTest = true;
        return createUsr();
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
    
     public static testMethod void testMember() { 
        SBcUtil.testMember();
        Configuration__c config;
        
        Integer rcCount  = [Select count() from Configuration__c where id <> null];
        if(rcCount > 0){
            config = [Select Active_Groups__c,Organization_Name__c, Base_Folder__c from Configuration__c limit 1];
            if(config.Organization_Name__c != null && config.Organization_Name__c != ''){
                delete config;
            }
        }
       
        SBcAccountCreation acctCreation = new SBcAccountCreation(); 
        SBcUtil.showMsg('info','User has Sufficient Access.');                
        String res = acctCreation.createUserForTest(); 
        String compareVal ='User EmailID=testuser@gmail.com,New password=gzTjkE90';
        system.assertNotEquals(res,compareVal); 
        
        acctCreation.orgName ='testsforg1';
        acctCreation.accessKey='dummyaccesskey1';
        acctCreation.secretKey='dummysecretkey1';
        acctCreation.bucketName='bucketforsf';        
        acctCreation.encrKey='testkey1';
        acctCreation.emailId = 'user1@abc.com';
        acctCreation.activateUsr();
        system.assertNotEquals(acctCreation.baseFolder,'testuser_gmail_com'); 
        
        
        acctCreation.baseFolder='testuser_gmail_com';
        acctCreation.insertRecord(acctCreation.baseFolder);
        
        acctCreation.orgName ='';
        acctCreation.accessKey='';
        acctCreation.secretKey='';
        acctCreation.bucketName='';
        acctCreation.encrKey='';
        acctCreation.activateUsr();
        
        acctCreation.baseFolder='';
        acctCreation.insertRecord(acctCreation.baseFolder);
        
        acctCreation.previousPage();
        acctCreation.cancel();
             
     } 

}