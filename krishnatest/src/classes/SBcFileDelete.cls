global with sharing class SBcFileDelete {
    public static Boolean isApexTest = false;    
    global static String sessionVal { get; set; }
    global static String baseFolder { get; set; }
    public String successUrl { get; set; }
    public String failureUrl { get; set; }
    public String serviceUrl { get; set; }
    global static String fname{ get; set; }
    global static String fsize{ get; set; }
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}     
    public String hostname { get;set;}
    public String baseURL { get;set;}
    public String objId{ get;set;}
    public String objName { get;set;}
    public String recordName { get;set;}
    global SBcFileDelete(){
          verifyAccess();
         try{            
            serviceUrl = SBcUtil.getServiceURL();           
            if(serviceUrl == null || serviceUrl.length()<=0){
              
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
            }             
            objId = System.currentPagereference().getParameters().get('objId');            
            objName = System.currentPagereference().getParameters().get('objName'); 
              
          
            Configuration__c configValue = [Select Base_Folder__c  from Configuration__c limit 1];
            if(configValue.Base_Folder__c != null || configValue.Base_Folder__c != '')
            baseFolder = configValue.Base_Folder__c;
            
             
            if(this.objId =='' || this.objId  == null) {
                SBcUtil.showMsg('error','Record ID is required');
                pageRender = false;
                return;
            }
            if(this.objName == '' || this.objName == null){             
                SBcUtil.showMsg('error','Object Name is required');
                pageRender = false;
                return;
            }
                  
            if(!pageRender || disableButtons == true){              
                SBcUtil.showMsg('error','Insufficient access - Please contact your system administrator.');
                return;
            }           
            
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
                                  
            failureUrl = baseURL+ '/apex/SBvFailurePage?objId='+objId+'&objName='+objName;
  
            
            sessionVal = getSession();   
        }catch(Exception ex){
            system.debug('inside constructor(SBcFileUpload) exception caught::'+ex.getStackTraceString());
        }   
    }
    ////////////////////////////////////////////////////
        @RemoteAction
    global static List<String> insertFileInfo(String recId,String idStr){
         List<String>  lstFilesnames = new List<String>();
         List<String>  lstFilesId = new List<String>();        
        try{
            List<File_Information__c> insFiles = [select id,name, content_type__c,filesize__c,filepath__c,uploaded_date__c,status__c,OwnerId from file_information__c where record_id__c =: idStr and OwnerId =: UserInfo.getUserId() and  Status__c !='In Progress' ];
            System.debug('insFilesidStr ::: '+idStr);    
                for(File_Information__c insFileList: insFiles){
                    lstFilesnames.add(insFileList.name+'@'+insFileList.id); 
                    //lstFilesId.add(insFileList.id); 
                   }
          }catch(Exception ex){
                
            }
            System.debug('lstFilesnames ::: '+lstFilesnames);  
            return lstFilesnames;
        }
      
    

    
    ////////////////////////////////////////////////////// 
    @RemoteAction
    global static void deleteFileInfo(String recId,String idStr){
        try{
            List<File_Information__c> delFilesList = [select name, content_type__c,filesize__c,filepath__c,uploaded_date__c,status__c,OwnerId from file_information__c where record_id__c =: idStr and OwnerId =: UserInfo.getUserId() and id =: recId];
            if(delFilesList != null && delFilesList.size()>0)
                delete delFilesList;
        }catch(Exception ex){
            
        }
    }
    
    //////////////////////////////////////////////////////
    @RemoteAction
    global static String showFileInfo(String recId,String idStr){
        String retVal = null;
        try{   
            system.debug('FilesId---');               
           if(recId != null && recId != ''){                       
               if(refreshData(recId,idStr)){
                    File_Information__c file = [Select Id, Name, Filesize__c from File_Information__c where Id =: recId];
                    
                    if(file.Name != null || file.Name != ''){
                       fname = file.Name;
                       fsize = file.Filesize__c;
                       retVal = fname+','+fsize;
                    }else{
                        retVal = null;
                    }
               }else{
                    retVal = 'Error in uploading file. Please contact your administrator.';
               }
            }
        }catch(Exception ex){
            system.debug('inside showFileInfo() exception caught::'+ex.getStackTraceString());
        }
        return retVal;
    }
    //////////////////////////////////////////////////////
    global static boolean refreshData(String recId,String idStr){
        try{
            List<File_Information__c> progFilesList = [select name, content_type__c,filesize__c,filepath__c,uploaded_date__c,status__c,OwnerId from file_information__c where record_id__c =: idStr and OwnerId =: UserInfo.getUserId() and status__c =: 'Uploaded' and id =: recId];
       system.debug('progFilesList---'+progFilesList);
            List<File_Information__c> updFileList = new List<File_Information__c>();
            if(GetFileSize(progFilesList))            
                return true;
            else
                return false;
            
        }catch(Exception ex){
           system.debug('inside refreshData() exception caught::'+ex.getStackTraceString());
           return false;
        }
    }
    //////////////////////////////////////////////////////
    global static Boolean GetFileSize(List<File_Information__c> progFilesList){
        try{
            String path;
            List<File_Information__c> updFileList = new List<File_Information__c>();
            List<File_Information__c> delFileList = new List<File_Information__c>();
            Configuration__c configValue = [Select Base_Folder__c  from Configuration__c limit 1];
            baseFolder = configValue.Base_Folder__c; 
           
            for(File_Information__c file: progFilesList){         
                String temp = file.Name;
                temp = temp.replaceAll(' ', '+');
                system.debug('====temp===='+temp);      
               
                path = baseFolder+'/'+file.Filepath__c+'/'+file.Name;
                
                String fileSize, response;
                HttpRequest req = new HttpRequest();
                Http http = new Http();               
                req.setMethod('GET'); 
                String userid;
                String hashPwd;
                configurationDetails__c config;
                Integer rcCount = [Select count() from configurationDetails__c limit 1];
                if(rcCount > 0){
                    config = [Select Username__c,Password__c from configurationDetails__c where username__c <> null];
                    userid = config.Username__c;
                     //Retrieve the password from the Configuration Object and hash it using SHA1 algorithm... 
                    Blob digestPwd = Crypto.generateDigest('SHA1',  Blob.valueOf(config.Password__c)); 
                     //The hashed passowrd is converted to Hexadecimal format... This is how the password is stored in CEG Server...
                    hashPwd = EncodingUtil.convertToHex(digestPwd);
                    
                }           
                 //Get the current time in milliseconds...
                Long ctTime = System.currentTimeMillis();
                String action = 'DELETE';
                //Contruct the auth string with the userid,action,hashed password and current time...    
                String authStr = 'userid='+userid+'password='+hashPwd+'action='+action+'date='+ctTime;
                String algorithmName = 'SHA-256';
                //Now encrypt the auth string with the SHA-256 algorithm...
                Blob digest = Crypto.generateDigest(algorithmName,  Blob.valueOf(authStr)); 
                 //Convert the generated blob to hexadecimal format...        
                String authVal = EncodingUtil.convertToHex(digest);
              
                
                    String encodedPath = EncodingUtil.urlEncode(path, 'UTF-8');
                    String url = SBcUtil.getServiceURL()+'?action='+action;
                    req.setBody('userid='+userid+'&ct='+ctTime+'&authResult='+authVal+'&path='+encodedPath+'&actionui=false');
                    req.setEndpoint(url);
                  system.debug ('-----------REQ=url------------- : ' + url );    
                    if (!isApexTest){
                        // Make a real callout since we are not running a test
                        HTTPResponse resp = http.send(req);             
                        system.debug ('------------------------------- : ' + req);
                        response = resp.getBody(); 
                        system.debug ('-----------response------------- : ' + response );             
                    } else {
                        // A test is running
                        response = '';
                    }
                   // if(response != '' && response != null && (response == 'success' || response == 'File-Size=4838') ){                     
                
                        if(response != '' && response != null && response == 'success'  ){      
                            file.status__c = 'DELETE';
                          updFileList.add(file);
                          //delFileList.add(file);
                       
                    }/*else{
                        delFileList.add(file);
                    }*/
                }
                system.debug ('-----------updFileList1------------- : ' + updFileList ); 
                if(updFileList.size()>0 && updFileList != null){
                	system.debug ('-----------updFileList1------------- : ' + updFileList );    
                    upsert updFileList;
                    return true;
                }
               /* if(delFileList.size()>0 && delFileList != null){
                    delete delFileList;
                    return false;
                }*/
            return false;
        }catch(Exception ex){
            system.debug('inside GetFileSize() exception caught::'+ex.getStackTraceString());
            return false;
        }       
    } 
    
    //////////////////////////////////////////////////////
    global static String getSession() {
        try{
            String sessionVal1;
            String userid;
            String hashPwd;
            configurationDetails__c config;
            Integer rcCount = [Select count() from configurationDetails__c limit 1];
            if(rcCount > 0){
                config = [Select Username__c,Password__c from configurationDetails__c where username__c <> null];
                userid = config.Username__c;
                 //Retrieve the password from the Configuration Object and hash it using SHA1 algorithm... 
                Blob digestPwd = Crypto.generateDigest('SHA1',  Blob.valueOf(config.Password__c)); 
                 //The hashed passowrd is converted to Hexadecimal format... This is how the password is stored in CEG Server...
                hashPwd = EncodingUtil.convertToHex(digestPwd);
                
            }           
             //Get the current time in milliseconds...
            Long ctTime = System.currentTimeMillis();
            String action = 'UPLOAD';
            //Contruct the auth string with the userid,action,hashed password and current time...    
            String authStr = 'userid='+userid+'password='+hashPwd+'action='+action+'date='+ctTime;
            String algorithmName = 'SHA-256';
            //Now encrypt the auth string with the SHA-256 algorithm...
            Blob digest = Crypto.generateDigest(algorithmName,  Blob.valueOf(authStr)); 
             //Convert the generated blob to hexadecimal format...        
            String authVal = EncodingUtil.convertToHex(digest);
            
           
            return userid+','+authVal+','+ctTime;
        }catch(Exception ex){
            system.debug('inside getSessionId() exception caught::'+ex.getStackTraceString());
            return null;
        }
    }  
        //////////////////////////////////////////////////////
    private void verifyAccess(){ 
         try{       
            this.pageRender = true;
            this.disableButtons = false;            
            Configuration__c configObj = new Configuration__c();
            File_Information__c fileInfo = new File_Information__c();
            Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'read'};
            Map<String,String>  fileInfoFields = new Map<String,String>{'Content_Type__c'=>'create','Object_Name__c'=>'create','Record_ID__c'=>'create','Status__c'=>'create','Status__c'=>'edit','Uploaded_Date__c'=>'create','Filesize__c'=>'create','Filesize__c'=>'edit','Filepath__c'=>'create'};                      
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){ 
                pageRender = false;
            }                
            if(!SBcUtil.checkFieldAccessiblity(fileInfo,fileInfoFields)){
                pageRender = false;
                disableButtons = true;
            }                
     
        }catch(Exception ex){ 
            pageRender = false;   
            system.debug('inside verifyAccess() exception caught::'+ex.getStackTraceString());       
        }
    }    
       //////////////////////////////////////////////////////
    public Pagereference redirectPage(){
        string idstr = Apexpages.currentPage().getParameters().get('objId');
        Pagereference pr = new Pagereference(baseURL+'/'+idstr);
        pr.setRedirect(true);
        return pr;
    }
        //////////////////////////////////////////////////////
   
}