public with sharing class SBcUtil {
static String SERVICE_URL{get;set;}  
  public static boolean isTestRun = false;
  
  public static String getServiceURL(){
    
    for (CEGService__c urls : CEGService__c.getAll().values()){
        SERVICE_URL = urls.CEG_Service_URL__c;
    }
    if(SERVICE_URL != null && SERVICE_URL.length()>0 && !SERVICE_URL.endsWith('/'))
        SERVICE_URL = SERVICE_URL+'/';
    return SERVICE_URL;
  }
  
  public static String field_name;
    public static String action;
    public static Boolean checkFieldAccessiblity(Sobject object_name,Map<String, String> fieldPermissionMap){
        
        Schema.sObjectType sobject_type = object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe;
        Schema.DescribeFieldResult field_describe;
        sobject_describe = sobject_type.getDescribe();
        for(String key:fieldPermissionMap.keySet()){    
          field_name = key;
          action = fieldPermissionMap.get(key);
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
          field_describe = field_map.get(field_name).getDescribe();
      
          if(action == 'read'){
              if(!field_describe.isAccessible()){
                  return false;
              }
          }else if(action == 'create'){
              if(!field_describe.isCreateable()){
                  return false;
              }
          }else if(action == 'edit'){
              if(!field_describe.isUpdateable()){
                  return false;
              }
          }else if(action == 'delete'){
              if(!sobject_describe.isDeletable()){
                  return false;
              }
          }          
      }
      return true;
    }    
    public static String verifyCallout(Boolean isApexTest){
    String response;
    try{                
        isTestRun = isApexTest; 
        HttpRequest req = new HttpRequest();
        Http http = new Http();       
        // set the request method
        req.setMethod('GET'); 
        
        String url;
        url = SBcUtil.getServiceURL();
       
      
         // add the endpoint to the request
        req.setEndpoint(url);
 	
        // create the response object      
       System.debug('isTestRun...'+isTestRun);
        if (!isTestRun){
            // Make a real callout since we are not running a test
                HTTPResponse resp = http.send(req);                            
               
                if(resp.getStatusCode() == 200)                         
                        response = 'Callout Succeeded';
                
        } else {
            // A test is running
            response = 'Test Callout';           
        } 
        }Catch(Exception ex){
            response = 'Callout Failed';
        }
        return response;
        
    }
    public String invokeActivation(Boolean isApexTest,String username,String password,String newPwd,String encrKey){
      String response;
      try{
                  
          isTestRun = isApexTest; 
          HttpRequest req = new HttpRequest();
          Http http = new Http();       
         
          req.setMethod('GET'); 
          
          String url;
          url = SBcUtil.getServiceURL()+'?action=activate';   
             System.debug('url111...'+url);
          if(encrKey != null){
              req.setBody('username='+username 
                  + '&password='+password
                  + '&newpassword='+newPwd+'&encryptvalue='+encrKey+'&actionui=false');
           }else{
              req.setBody('username='+username 
                  + '&password='+password
                  + '&newpassword='+newPwd+'&actionui=false');
           }
   
          // add the endpoint to the request
          req.setEndpoint(url);
   
          // create the response object      
         
          if (!isTestRun){
              // Make a real callout since we are not running a test
                  HTTPResponse resp = http.send(req);                                     
                  
                  if(resp.getStatusCode() == 200)                         
                          response = resp.getBody();
                          
                  
          } else {
              // A test is running
              response = 'Activation success. User base folder = salestest_force_com';           
          } 
      }catch(Exception ex){
        system.debug(ex.getStackTraceString());
      }
      return response;
    }
    
    public static void showMsg(String severity,String msg) 
    {
        ApexPages.Message myMsg;
        if(severity == 'info'){
             myMsg = new ApexPages.Message(ApexPages.Severity.INFO, ''+msg);
        }
        if(severity == 'error'){
             myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ''+msg);
        }
        if(severity == 'warn'){
             myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ''+msg);
        }
        ApexPages.addMessage(myMsg);        
    }
    
   public static String ToString(Long Value)  {    
         /* string representation if a Long value */    
         return Value.format();  
     } 
   
     public static String ToString(Decimal Value)  {   
     /* string representation if a Decimal value */    
     return Value.format();  
   }   
   
   public static String FileSizeToString(Long Value) {     
     /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */     
     if (Value < 1024)       
       return ToString(Value) + ' Bytes';     
     else if (Value >= 1024 && Value < (1024*1024)) { //KB       
       Decimal kb = Decimal.valueOf(Value);       
       kb = kb.divide(1024,2);       
       return ToString(kb) + ' KB';     
     }     
     else if (Value >= (1024*1024) && Value < (1024*1024*1024)) { //MB  
       Decimal mb = Decimal.valueOf(Value);       
       mb = mb.divide((1024*1024),2);       
       return ToString(mb) + ' MB';     
     }     
     else{       //GB       
       Decimal gb = Decimal.valueOf(Value);       
       gb = gb.divide((1024*1024*1024),2);             
       return ToString(gb) + ' GB';     
     }      
   }    
          
    /**
     * Validates the email address 
     * null     => false
     * ''       => false
     * ' '      => false
     * 'x'      => false
     * 'x@'     => false
     * 'x@x'    => false
     * 'x@x.x'  => true  */    
    public static Boolean isValidEmailAddress(String str){
        if(str != null && str.trim() != null && str.trim().length() > 0){
            String[] split = str.split('@');
            if(split != null && split.size() == 2){
                split = split[1].split('\\.');
                if(split != null && split.size() >= 2){
                    return true;
                }
            }
        }
        return false;
    }    
       
    public String invokeActivationForTest(){
        isTestRun = true;
        return invokeActivation(true,'xyz@test.com','passowrd123','password123',null);
    }      
    
    public String invokeActivationForTest1(){
        isTestRun = true;
        return invokeActivation(true,'xyz@test.com','passowrd123','password123','testkey');
    }  
    
    public static testMethod void testMember() { 
        SBcUtil util = new SBcUtil(); 
        Boolean checkAccess = false;
        // Call the invokeActivationForTest wrapper method so we can set the variable indicating that a test is running
        String retVal = util.invokeActivationForTest(); 
        String retVal1 = util.invokeActivationForTest1();        
        
        Configuration__c configObj = new Configuration__c();
        Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'read'};
        checkAccess = SBcUtil.checkFieldAccessiblity(configObj, configFields);
        system.assertEquals(checkAccess,true);
        
        File_Information__c fileInfo = new File_Information__c();
        Map<String,String>  fileInfoFields = new Map<String,String>{'Content_Type__c'=>'read','Object_Name__c'=>'read','Record_ID__c'=>'read','Status__c'=>'read','Uploaded_Date__c'=>'read','Filesize__c'=>'read','Filepath__c'=>'read'};            
        checkAccess = SBcUtil.checkFieldAccessiblity(fileInfo, fileInfoFields);  
        system.assertEquals(checkAccess,true);
        
        Long fileSize = 16536;
        String sizeinkb=SBcUtil.FileSizeToString(fileSize);
        
        fileSize = 300;
        String sizeinbytes=SBcUtil.FileSizeToString(fileSize);    
        String value1 = '300 Bytes';
        System.assertEquals(value1,sizeinbytes);  
        
        fileSize = 5069068;
        String sizeinmb = SBcUtil.FileSizeToString(fileSize);
        
        fileSize = 1083741920;
        String sizeingb = SBcUtil.FileSizeToString(fileSize);
        SBcUtil.showMsg('info','File sixe in GB:'+sizeingb);        
        
        String emailStr = 'testuser@xyz.com';    
        Boolean isValidEmail = SBcUtil.isValidEmailAddress(emailStr);
        system.assertEquals(isValidEmail,true);
        SBcUtil.showMsg('info','Email address is valid');
        
        emailStr = '';  
        isValidEmail = SBcUtil.isValidEmailAddress(emailStr);
        system.assertEquals(isValidEmail,false);
        SBcUtil.showMsg('error','Please enter a valid email address');
        
        String verifyClt = SBcUtil.verifyCallout(true);
       // system.assertEquals(verifyClt,'Test Callout');
        SBcUtil.showMsg('warn','Test Callout made');
       
     }

}