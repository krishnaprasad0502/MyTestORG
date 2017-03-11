public with sharing class SBcAccountDetails {
    public String uname{get;set;}
    public String oldPwd{get; set;}     
    public String newPwd {get; set;} 
    public String confirmPwd {get; set;}    
    public String accessKey {get; set;} 
    public String secretKey {get; set;}
    public Boolean displayPanel { get; set;}
    public Boolean pageRender { get; set;}
    public Boolean disableButtons { get; set;}
    public Configuration__c configVal {get;set;} 
    public configurationDetails__c configDetails {get;set;} 
    public static boolean isApexTest = false;
    public String orgName { get; set;}
     
    public SBcAccountDetails(){        
        try{            
            verifyAccess();
            if(!pageRender || disableButtons == true){
                SBcUtil.showMsg('error','Insufficient Access - Please Contact your administrator.');
                return;
            }
            String serviceURL = SBcUtil.getServiceURL();
             System.debug('line24...'+serviceURL);
            if(serviceURL == null || serviceURL.length()<=0){
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
                  
            } 
            if(!isApexTest){
                String resp = SBcUtil.verifyCallout(isApexTest);
                System.debug('verifyCallout...'+resp);
                if(resp != null && resp.contains('Failed')){
                    SBcUtil.showMsg('error','Please verify the Service URL under Custom Settings and Remote Site Settings.');
                    return;
                }
            }  
            this.displayPanel=false; 
            
            configDetails = [Select username__c,password__c from configurationDetails__c limit 1];
           
                           
            configVal = [Select Organization_Name__c from Configuration__c limit 1];
            if(configVal.Organization_Name__c != null || configVal.Organization_Name__c != ''){
                if(configVal.Organization_Name__c == 'default'){
                    displayPanel = false;
                }else{
                    displayPanel = true;
                }
            }
            if(configDetails.username__c != null || configDetails.Username__c !=''){
                    uname = configDetails.Username__c;
            }
            if(configDetails.password__c != null || configDetails.password__c !=''){                       
                oldPwd=configDetails.password__c;                                         
            }
            if(configVal.Organization_Name__c != null || configVal.Organization_Name__c !=''){                       
                orgName=configVal.Organization_Name__c;                                         
            }
        }catch(Exception ex){
                system.debug('inside constructor(SBcAccountDetails) exception caught::'+ex.getStackTraceString());
        }
      }    
      
      private void verifyAccess(){
         try{ 
            this.pageRender= true;
            this.disableButtons = false;
            Configuration__c configObj = new Configuration__c();            
            Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'read','Organization_Name__c'=>'read'};
                  
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){ 
                pageRender = false;
                disableButtons = true;
            }
        }catch(Exception ex){ 
            pageRender = false;   
            system.debug('inside verifyAccess() exception caught::'+ex.getStackTraceString());        
        }
      }
      
      private String retrieveSession(String action){
        try{
            String sessionVal;
            String sessionVal1;
            String userid;
            String hashPwd;
            configurationDetails__c config;
            Integer rcCount = [Select count() from configurationDetails__c limit 1];
            if(rcCount > 0){
                //config = [Select Username__c,Password__c from Configuration__c limit 1];
                config = [Select username__c,password__c from configurationDetails__c where username__c <> null];
                userid = config.Username__c;
                 //Retrieve the password from the Configuration Object and hash it using SHA1 algorithm... 
                Blob digestPwd = Crypto.generateDigest('SHA1',  Blob.valueOf(config.Password__c)); 
                 //The hashed passowrd is converted to Hexadecimal format... This is how the password is stored in CEG Server...
                hashPwd = EncodingUtil.convertToHex(digestPwd);
                
            }           
             //Get the current time in milliseconds...
            Long ctTime = System.currentTimeMillis();
            //Contruct the auth string with the userid,action,hashed password and current time...    
            String authStr = 'userid='+userid+'password='+hashPwd+'action='+action+'date='+ctTime;
            String algorithmName = 'SHA-256';
            //Now encrypt the auth string with the SHA-256 algorithm...
            Blob digest = Crypto.generateDigest(algorithmName,  Blob.valueOf(authStr)); 
            //Convert the generated blob to hexadecimal format...        
            String authVal = EncodingUtil.convertToHex(digest);
                     
           
            return userid+','+authVal+','+ctTime;
        }catch(Exception ex){
            system.debug('inside retrieveSessionId() exception caught::'+ex.getStackTraceString());
            return null;
        }
       }
       
       public Pagereference resetPwd() {
        //Password has been successfully changed - SUCCESS
        //Failed to change your password - FAILURE
            try{
                String response;   
                
                if(newPwd.trim().length() == 0){
                    SBcUtil.showMsg('error','Please enter New Password.');
                    return null;
                }
                
                if(confirmPwd.trim().length() == 0){
                    SBcUtil.showMsg('error','Please enter Confirm New Password.');
                    return null;
                }
                           
                if(newPwd.length() < 7 || confirmPwd.length() < 7){
                    SBcUtil.showMsg('error','Password(s) should be atleast greater than 8 characters.');
                    return null;
                }
                
                if(newPwd != confirmPwd){
                    SBcUtil.showMsg('error','Both New Password and Confirm New Password should match exactly.');
                    return null;
                }
                
                if((oldPwd != null && oldPwd != '') && (confirmPwd != null && confirmPwd != '')){
                    
                    String session = retrieveSession('CHGPWD');
                    String[] resVal = session.split(',');
                    String userid = resVal[0];
                    String ctTime = resVal[2];
                    String authVal = resVal[1];
                    
                    HttpRequest req = new HttpRequest();
                    Http http = new Http();
                   
                    // set the request method
                    req.setMethod('GET'); 
                   
                    String url = SBcUtil.getServiceURL()+'?action=CHGPWD&actionui=false';
                    //String url='http://50.18.106.113/cbe/?action=CHGPWD';
                    req.setBody('userid='+userid+'&ct='+ctTime+'&authResult='+authVal+'&opwd='+oldPwd+'&npwd='+confirmPwd);
                    // add the endpoint to the request
                    req.setEndpoint(url);
             
                    // create the response object                  
                    if (!isApexTest){
                        // Make a real callout since we are not running a test
                        HTTPResponse resp = http.send(req);
                        
                        response=resp.getBody();                
                    } else {
                        // A test is running
                        response = 'Password has been successfully changed';
                    }
                    
                    if(response != null && response.length() > 0 && response.contains('success')){                     
                        SBcUtil.showMsg('info',response);
                        configDetails.Password__c = confirmPwd;
                        update configDetails;                         
                    }else{
                        SBcUtil.showMsg('error','Failed to change your password');
                    } 
                }
            }catch(Exception ex){
                SBcUtil.showMsg('error','Failed to change your password');
                system.debug('inside resetPwd() exception caught::'+ex.getStackTraceString());
            }
         return null;
    } 
    
     public Pagereference updateKeys() {
        //Password has been successfully changed - SUCCESS
        //Failed to change your password - FAILURE
        
            try{
                String response; 
                
                if(accessKey.trim().length() == 0){
                    SBcUtil.showMsg('error','Please enter Access Key.');
                    return null;
                }
                
                if(secretKey.trim().length() == 0){
                    SBcUtil.showMsg('error','Please enter Secret Key.');
                    return null;
                }
                
                if(accessKey.trim().length() < 19){
                    SBcUtil.showMsg('error','Please enter a valid Access Key.');
                    return null;
                }
                if(secretKey.trim().length() < 39){
                    SBcUtil.showMsg('error','Please enter a valid Secret Key.');
                    return null;
                }
                
                if((accessKey != null && accessKey != '') && (secretKey != null && secretKey != '') && (orgName != null && orgName != '')){
                     String session = retrieveSession('UPDKEYS');
                     String[] resVal = session.split(',');
                    String userid = resVal[0];
                    String ctTime = resVal[2];
                    String authVal = resVal[1];
                    
                    HttpRequest req = new HttpRequest();
                    Http http = new Http();
                   
                    // set the request method
                    req.setMethod('POST'); 
                    req.setBody('userid='+userid+'&accesskeyid='+accessKey+'&secretkeyid='+secretKey+'&orgname='+orgName+'&ct='+ctTime+'&authResult='+authVal);
                    String url = SBcUtil.getServiceURL()+'?action=UPDKEYS&actionui=false';
                    //String url='http://50.18.106.113/cbe/?userid='+userid+'&action=UPDKEYS&ct='+ctTime+'&authResult='+authVal;
                    //req.setBody('')
                    // add the endpoint to the request
                    req.setEndpoint(url);
             
                    // create the response object      
                   
                    if (!isApexTest){
                        // Make a real callout since we are not running a test
                        HTTPResponse resp = http.send(req);
                        
                        response=resp.getBody();                
                    } else {
                        // A test is running
                        response = 'Amazon Credentials Updated Successfully.';
                    }
                    if(response != null && response.length() > 0 && response.contains('updated')){                      
                         SBcUtil.showMsg('info',response);                        
                    }else{
                         SBcUtil.showMsg('error','Failed to update the credentials');
                    }  
                }
            }catch(Exception ex){
                SBcUtil.showMsg('error','Failed to update the credentials');
                system.debug('inside updateKeys() exception caught::'+ex.getStackTraceString());
            }
         return null;
    } 
    
    public static testmethod void testMember(){
        SBcUtil.testMember();
       
        SBcAccountDetails.isApexTest = true;
        
        Configuration__c config;
        
        Integer rcCount  = [Select count() from Configuration__c where id <> null];
        if(rcCount > 0){
            config = [Select Active_Groups__c,Organization_Name__c, Base_Folder__c from Configuration__c limit 1];
            if(config.Organization_Name__c != null && config.Organization_Name__c != ''){
                delete config;
            }
        }       
        
        Configuration__c conf = new Configuration__c();
        conf.Organization_Name__c = 'testorg123';
        conf.Base_Folder__c = 'testbf123';
        //conf.Username__c = 'testuser@xyz.com';
        //conf.Password__c = 'password!23';
        //conf.Encryption_Key__c = 't#st!23';
        conf.Active_Groups__c = 'grp1,grp2';
        
        insert conf;   
             
        Configuration__c insertedConf  = [select Base_Folder__c from Configuration__c where Organization_Name__c =: 'testorg123'];
        system.assertEquals('testbf123',insertedConf.Base_Folder__c);    
        
        SBcAccountDetails acctDet1 = new SBcAccountDetails();
        
        insertedConf  = [select Base_Folder__c, Organization_Name__c from Configuration__c where Base_Folder__c =: 'testbf123'];                 
        insertedConf.Organization_Name__c = 'testorg1234';
        update insertedConf;
        
        insertedConf  = [select Base_Folder__c, Organization_Name__c from Configuration__c where Base_Folder__c =: 'testbf123'];
        system.assertEquals('testorg1234',insertedConf.Organization_Name__c); 
        
        
        SBcAccountDetails acctDet = new SBcAccountDetails();
        SBcUtil.showMsg('info','User has Sufficient Access.');
        
        acctDet.oldPwd ='p@ssw0rd!23';
        acctDet.newPwd = 'p@ssw0rd!2345';
        acctDet.confirmPwd ='p@ssw0rd!2345';
        acctDet.resetPwd();
        
        acctDet.oldPwd ='p@ssw0rd!23';
        acctDet.newPwd = 'p@ssw0rd!2345';
        acctDet.confirmPwd ='';
        acctDet.resetPwd();
        
        acctDet.oldPwd ='p@ssw0rd!23';
        acctDet.newPwd = 'p@ssw0';
        acctDet.confirmPwd ='p@ssw0';
        acctDet.resetPwd();
        
        acctDet.oldPwd ='';
        acctDet.newPwd = '';
        acctDet.confirmPwd ='';
        acctDet.resetPwd();
       
        acctDet.accessKey='';
        acctDet.secretKey='';
        acctDet.orgName='';        
        acctDet.updateKeys();
        
        acctDet.accessKey='acvsv1234242';
        acctDet.secretKey='';
        acctDet.orgName='';        
        acctDet.updateKeys();
        
        acctDet.accessKey='acvsv1234242';
        acctDet.secretKey='';
        acctDet.orgName='';        
        acctDet.updateKeys();
        
        acctDet.accessKey='acvsv1234242acvsv123';
        acctDet.secretKey='acvsv123424';
        acctDet.orgName='';        
        acctDet.updateKeys();
        
        acctDet.accessKey='accesskey123445acvsv';
        acctDet.secretKey='secretkey123455acvsvsecretkey123445acvsv';
        acctDet.orgName='testorg123';                
        acctDet.updateKeys();        
        
        SBcAccountDetails acctDet2 = new SBcAccountDetails();
        acctDet2.newPwd ='p@ssw0rd!234';
        acctDet2.confirmPwd ='p@ssw0rd!2345';
        acctDet2.resetPwd(); 
        
        CEGService__c c = new CEGService__c();
        c.Name = 'CEG_ Service_URL';
		c.CEG_Service_URL__c ='http://54.241.25.182:8080/cbe/';
        insert c;
       
        List<CEGService__c> cs = [Select Id from   CEGService__c Where Name = 'CEG_ Service_URL']; 
        System.assert(cs.size() == 1);
        
        c = CEGService__c.getInstance('CEG_ Service_URL');
        System.assert(c != null); //this fails.  It doesn't find the custom setting, even though I just inserted it above!!!
        
    }
}