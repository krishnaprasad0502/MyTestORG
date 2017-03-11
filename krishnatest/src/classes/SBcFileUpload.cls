global with sharing class SBcFileUpload {
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
    
    global SBcFileUpload(){
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
            List<File_Information__c> insFiles = [select id,name, content_type__c,filesize__c,filepath__c,uploaded_date__c,status__c,OwnerId from file_information__c where record_id__c =: idStr and OwnerId =: UserInfo.getUserId() and  Status__c !='In Progress' and  Status__c !='Delete' ];
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


    @RemoteAction
    global static String showFileInfo(String recId,String idStr){
        String retVal = null;


        try{                  
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

    
    global static boolean refreshData(String recId,String idStr){
        try{
            List<File_Information__c> progFilesList = [select name, content_type__c,filesize__c,filepath__c,uploaded_date__c,status__c,OwnerId from file_information__c where record_id__c =: idStr and OwnerId =: UserInfo.getUserId() and status__c =: 'In Progress' and id =: recId];

       
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
                String action = 'FILESIZE';
                //Contruct the auth string with the userid,action,hashed password and current time...    
                String authStr = 'userid='+userid+'password='+hashPwd+'action='+action+'date='+ctTime;
                String algorithmName = 'SHA-256';
                //Now encrypt the auth string with the SHA-256 algorithm...
                Blob digest = Crypto.generateDigest(algorithmName,  Blob.valueOf(authStr)); 
                 //Convert the generated blob to hexadecimal format...        
                String authVal = EncodingUtil.convertToHex(digest);
              
                 system.debug ('--------FDG----------------------- : ');
                    String encodedPath = EncodingUtil.urlEncode(path, 'UTF-8');
                    String url = SBcUtil.getServiceURL()+'?action='+action;
                    req.setBody('userid='+userid+'&ct='+ctTime+'&authResult='+authVal+'&path='+encodedPath+'&actionui=false');
                    req.setEndpoint(url);
               system.debug ('----------req.setBody--------------- : ' + 'userid='+userid+'&ct='+ctTime+'&authResult='+authVal+'&path='+encodedPath+'&actionui=false');
                    system.debug ('----------urlurl--------------------- : ' + url);
       
                    if (!isApexTest){
                    	system.debug ('----------reqreq--------------------- : ' + req);
                        // Make a real callout since we are not running a test
                        HTTPResponse resp = http.send(req);             
                        system.debug ('------------------------------- : ' + req);
                        response = resp.getBody();              
                    } else {
                        // A test is running
                        response = 'File-Size=4838';
                    }
                    if(response != '' && response != null && response.contains('File-Size')){
                        String[] val = response.split('=');
                        Long size = long.valueOf(val[1]);
                        fileSize = SBcUtil.FileSizeToString(size);
                        if(fileSize != null || fileSize != ''){
                            file.filesize__c = fileSize;
                            file.status__c = 'Uploaded';
                            updFileList.add(file);
                        }
                    }/*else{
                        delFileList.add(file);
                    }*/
                }
                if(updFileList.size()>0 && updFileList != null){
                    upsert updFileList;
                    return true;
                }
                /*if(delFileList.size()>0 && delFileList != null){
                    delete delFileList;
                    return false;
                }*/
            return false;
        }catch(Exception ex){
            system.debug('inside GetFileSize() exception caught::'+ex.getStackTraceString());
            return false;
        }       
    } 
    


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

   
    public Pagereference redirectPage(){
        string idstr = Apexpages.currentPage().getParameters().get('objId');
        Pagereference pr = new Pagereference(baseURL+'/'+idstr);
        pr.setRedirect(true);
        return pr;
    }

    
    public static testmethod void testMember(){         
        SBcUtil.testMember();
       
        String idStr;
        List<Account> accts = [select id from Account limit 1];
        if(accts.size() > 0){
                for(Account acct:accts){
                        idStr = acct.id;
                }
        }else{
                SBcUtil.showMsg('error','Invalid record id');
        }
        
        ApexPages.currentPage().getParameters().put('objId', '');        
        ApexPages.currentPage().getParameters().put('objName','');
        
        SBcFileUpload fileUpload1 = new SBcFileUpload();
        SBcFileUpload.isApexTest = true;
        
        ApexPages.currentPage().getParameters().put('objId', idStr);        
        ApexPages.currentPage().getParameters().put('objName','');
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
        CEGService__c c = new CEGService__c();
        c.Name = 'CEG_ Service_URL';
    c.CEG_Service_URL__c ='http://54.241.25.182:8080/cbe/';
        insert c;
       
        List<CEGService__c> cs = [Select Id from   CEGService__c Where Name = 'CEG_ Service_URL']; 
        System.assert(cs.size() == 1);
        
        c = CEGService__c.getInstance('CEG_ Service_URL');
        System.assert(c != null); //this fails.  It doesn't find the custom setting, even though I just inserted it above!!!
        SBcFileUpload fileUpload2 = new SBcFileUpload();
         ApexPages.currentPage().getParameters().put('objId', null);        
        ApexPages.currentPage().getParameters().put('objName',null);
        SBcFileUpload.isApexTest = true;
        //ApexPages.currentPage().setParameters().put(key, value);
        ApexPages.currentPage().getParameters().put('objId', idStr);        
        ApexPages.currentPage().getParameters().put('objName','Account');
        String idStr1;
        List<File_Information__c> f = [select id,name from File_Information__c where id<> null];
        if(f != null && f.size() > 0){
            delete f;      
        }
         File_Information__c f1 = new File_Information__c();
         f1.Name = 'testfile.txt';
         f1.Filesize__c = '10 KB';
         f1.Filepath__c = 'testbf123/Account/'+idStr;
         f1.Content_type__c = 'txt';
         f1.Object_Name__c = 'Account';
         f1.Record_Id__c = idStr;
         f1.Status__c = 'In Progress';
         insert f1;
        File_Information__c f2 = new File_Information__c();
         f2.Name = 'testfile1.txt';
         f2.Filesize__c = '';
         f2.Filepath__c = 'testbf123/Account/'+idStr;
         f2.Content_type__c = 'txt';
         f2.Object_Name__c = 'Account';
         f2.Record_Id__c = idStr;
         f2.Status__c = 'In Progress';
         insert f2;
         
         File_Information__c insertedFile = [select id, name from File_Information__c where name =: 'testfile.txt'];
          ApexPages.currentPage().getParameters().put('recId',insertedFile.id);
        File_Information__c insertedFile1 = [select id, name from File_Information__c where name =: 'testfile1.txt'];
          ApexPages.currentPage().getParameters().put('recId',insertedFile1.id);
         
        SBcFileUpload fileUpload = new SBcFileUpload();
        SBcFileUpload.isApexTest=true;
        SBcUtil.showMsg('info','User has Sufficient access.');
        SBcUtil utilTest = new SBcUtil();
       

       SBcFileUpload.sessionVal = SBcFileUpload.getSession();
        //String sessionValue = fileUpload.sessionVal;
       System.assertNotEquals(SBcFileUpload.sessionVal, 'xyz'); 
        SBcUtil.showMsg('error','The sessionValue is not equal with the provided value.');       
        
        
        SBcFileUpload.showFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage();
        SBcFileUpload.showFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();
        SBcFileUpload.insertFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage();
        SBcFileUpload.insertFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();
        
        SBcFileUpload.deleteFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage();
        SBcFileUpload.deleteFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();
    }
}