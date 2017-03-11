global with sharing class SBcFileList implements SBcObjectPaginatorListener{
    public String objName{ get;set;} 
    public String objId{ get;set;} 
    public String recordName{ get;set;} 
    public String cPage{ get;set;}   
    public String showMore{get;set;} 
    public static boolean isApexTest = false;
    public String hasPrivilege { get; set; }     
    public String username { get;set;}  
    public String fileName { get; set; }  
    public String sessionVal {get; set; }
    public String baseFolder { get; set; }
    public String hostName { get; set;}
    public String baseURL { get; set;}
    public String serviceUrl{ get; set;}
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}
    public boolean renderBtn{get;set;}
    public Integer pgNum{get;set;}
    
    global List<FileInfoWrapper> files   {get;private set;}
    global SBcObjectPaginator paginator  {get;private set;} 
    global Integer pageNumber {get;set;}
    global List<File_Information__c> fileList {get;set;}
    global Integer pageSizes {get;set;}
    global Integer pageSize {get;set;}
   
    global SBcFileList(){   
        try{  
        	  
            integer afterNamespace;
            integer beforeNamespace;
            string urlForm;
            verifyAccess();        
            if(!pageRender || disableButtons == true){              
                SBcUtil.showMsg('error','Insufficient access - Please contact your system administrator.');
                return;
            }            
            boolean hasAccess = verifyUserPrivilege();
            if(hasAccess){
                hasPrivilege = 'true';           
            }else{
                hasPrivilege = 'false';
                SBcUtil.showMsg('error','You do not have the required permission to access Cloud Storage. Please contact your Administrator.');                     
                return;
            }          
            this.showMore = 'false';
            renderBtn = true;
            Integer rcCount = [Select count() from Configuration__c where id<> null];
            if(rcCount > 0){
                Configuration__c configValue = [Select Base_Folder__c from Configuration__c limit 1];
                if(configValue != null){
                    baseFolder = configValue.Base_Folder__c;  
                }  
            }    
            
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            /*
            To use the custom component in the installed package env ,the access for the component is Global
            if access is Global ,then that page wont  be come under namespace .
            It will create issue in custom object and Std object VF page (URL formation of attach file)
            So we will hardcode  namespace if its not that in the url
                        
            */
           
            afterNamespace = baseURL.indexOf('//',0);
            beforeNamespace = baseURL.indexOf('.',0);
            urlForm = baseURL.substring(afterNamespace+2,beforeNamespace);
            baseURL = baseURL.replaceFirst(urlForm,'c');
            system.debug('baseURL:::'+baseURL);
           
            serviceUrl=SBcUtil.getServiceURL();
            if(serviceUrl == null || serviceUrl.length()<=0){
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
            } 
           
            if(Apexpages.currentPage().getParameters().get('pg') != null){
                    cPage = Apexpages.currentPage().getParameters().get('pg');
                    //cPage = HTMLENCODE(cPage);
            }   
                     
          
          loadData(); 
        }catch(Exception ex){
            system.debug('inside constructor(SBcFileList) exception caught::'+ex.getStackTraceString());
        }
    }
  
    private Pagereference loadData(){ 
         
        try
        {
               String idStr; 
               if(Apexpages.currentPage().getParameters().get('objId') != null){
                    idStr = Apexpages.currentPage().getParameters().get('objId'); 
                     system.debug('idStr:::1'+idStr);              
               }else{
                    idStr = Apexpages.currentPage().getParameters().get('id');
                     system.debug('idStr:::2'+idStr);
               }
               
           system.debug('idStrlength:::3'+idStr.length());
                  if(idStr.length() == 18){
               	 idStr = idStr.substring(0,(idStr.length()-3));
               	  system.debug('idStr:::3'+idStr);
               	
               }else{
               	 idStr = idStr;
               	  system.debug('idStr:::4'+idStr);   
                
               }
                
               system.debug('idStr:::'+idStr);
               this.files = new List<FileInfoWrapper>();         
              fileList = [select f.id,f.name,f.filepath__c,f.Object_Name__c, f.uploaded_date__c,f.Record_ID__c,f.OwnerId, f.CreatedBy.Alias, f.CreatedBy.Name, f.CreatedById from file_information__c f where f.record_id__c =: idStr and f.OwnerId =: UserInfo.getUserId() and f.Status__c =: 'Uploaded' order by f.Name];
               system.debug('fileList:::---'+fileList);
               if(fileList.size() <= 0){
                    renderBtn = false;
               } else{
                    renderBtn = true;
               }              
               if(cPage == 'viewall'){
                    this.paginator = new SBcObjectPaginator(fileList.size(),this);                    
               }else{
                    this.paginator = new SBcObjectPaginator(10,this);                    
               }   
               
               this.paginator.setRecords(fileList);  
             
               if(Apexpages.currentPage().getParameters().get('pgNum') != null){
                    pgNum = Integer.valueOf(Apexpages.currentPage().getParameters().get('pgNum'));  
                     if(pgNum!=0){
                        if(Apexpages.currentPage().getParameters().get('showMore') != null){
                            showMore = Apexpages.currentPage().getParameters().get('showMore');
                            if(showMore != null && showMore == 'false')
                                this.files.clear();
                            this.paginator.skipToPage(pgNum);                               
                        }
                     }                                  
               } 
               
               
        }catch(Exception ex){
                system.debug(ex.getStackTraceString());
        }    
      
            return null;
       
    }
    
    global void handlePageChange(List<Object> newPage){
        try{            
            if(cPage == 'viewall' || showMore == 'false'){
                this.files.clear();
            }
           if(newPage != null && newPage.size() > 0){
                for(Integer i = 0; i < newPage.size(); i++){
                    this.files.add(
                        new FileInfoWrapper(
                            (File_Information__c)newPage.get(i))
                    );
                }
            }        
       }catch(Exception ex){
           system.debug(ex.getStackTraceString());
       } 
    }


    global class FileInfoWrapper{
              private File_Information__c fileInfo;        
    global String name {get{return fileInfo == null ? null : fileInfo.name;}}         
           global String cdate {get{return fileInfo == null ? null : fileInfo.Uploaded_Date__c;}}
           global String username{get{return fileInfo == null ? null : fileInfo.CreatedBy.Name;}}
            global Id userid{get{return fileInfo == null ? null : fileInfo.CreatedBy.Id;}}
            global String owneralias{get{return fileInfo == null ? null : fileInfo.CreatedBy.Alias;}}
            global String objName{get{return fileInfo == null ? null : fileInfo.Object_Name__c;}}
             global Id fileId{get{return fileInfo == null ? null : fileInfo.id;}}
             global string recId{get{return fileInfo == null ? null : fileInfo.Record_ID__c;}}
             global string filePath{get{return fileInfo == null ? null : fileInfo.filepath__c;}}
        global FileInfoWrapper(File_Information__c fileInfo){
            this.fileInfo = fileInfo;
        }
    }   
    
    public void verifyAccess(){
        try{        
            this.pageRender = true;
            this.disableButtons = false;                    
            
            Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'read'};
            Map<String,String>  fileInfoFields = new Map<String,String>{'Content_Type__c'=>'read','Object_Name__c'=>'read','Record_ID__c'=>'read','Status__c'=>'read','Uploaded_Date__c'=>'read','Filesize__c'=>'read','Filepath__c'=>'read'};
            
            Configuration__c configObj = new Configuration__c();
            File_Information__c fileInfo = new File_Information__c();
           
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
                pageRender = false;
            }               
                         
            if(!SBcUtil.checkFieldAccessiblity(fileInfo,fileInfoFields)){
                pageRender = false;
              disableButtons = true;                      
            }
        
        }catch(Exception ex){ 
            pageRender = false;   
            SBcUtil.showMsg('error','Exception Occured');           
        }
    }
    
    @RemoteAction
    global static String getSessionId() {
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
            String action = 'DOWNLOAD';
            
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
   
    public boolean verifyUserPrivilege(){
        try{
                      boolean hasAccess = false;       
           String userId = UserInfo.getUserId();
           system.debug('userId---'+userId);    
           String userroleid = UserInfo.getUserRoleId();           
           String ProfileId = UserInfo.getProfileId();           
           Boolean testMember=false;
           Boolean testProfileMember=false;
           List<String> profileName= new List<String>();   
          // User users=[select userroleid,ProfileId from user where id =:userId];  
   List<profile> profileMember = [select Id,Name from profile where id=:ProfileId limit 1];       
           if(profileMember!=NULL && profileMember.size()>0){
               //for(profile newprofileMember :profileMember){
                     profileName.add(profileMember[0].Name);
              // }
               testProfileMember = isActiveGroup(profileName);
           }else{
                hasAccess = false;
           }
           if(testProfileMember==true){
               hasAccess = true;
           }else{       
                    
               List<Group> groups = [select id from Group where relatedid=:userroleid];
               List<String> groupName= new List<String>();   
               if(groups.size()>0){
                    for(Group newGroup:groups){
                        List<GroupMember> groupMember = [select id,groupid,Group.Name, userorGroupid from GroupMember where userorGroupid =: userId];                            
                        if(groupMember.size()>0){
                            for(GroupMember newGroupMember :groupMember){                               
                                    groupName.add(newGroupMember.group.name);                     
                            }
                            testMember = isActiveGroup(groupName);
                             system.debug('testMember---'+testMember);  
                        }
                   }
            if(testMember==true){
                hasAccess = true;                                
            }
            else{
                hasAccess = false;               
            }
          }
        else{
            hasAccess = false;            
        }
           }
           return hasAccess;
        }catch(Exception ex){
            return false;
        }
          
    }
    
    private boolean isActiveGroup(List<String> groupName){
        try{
            boolean isActive = false;
            Configuration__c configValue = [Select Active_Groups__c  from Configuration__c limit 1];                    
            if(configValue.Active_Groups__c!=null){
                String valueOptions = configValue.Active_Groups__c;
                String[] splitedOptions=valueOptions.split(',');
                Boolean b = false;
                for(integer i=0;i<splitedOptions.size();i++){
                    for(String a:groupName){
                        if(a==splitedOptions[i]){
                            b=true;
                        }
                    }
                }
                if(b==true){
                    isActive= true;
                }
                else{
                    isActive = false;
                }
            }
            else{
                isActive = false;
            }
            return isActive;
        }catch(Exception ex){
            return false;
        }
    }
    public Pagereference cancel(){
        String redirectId = Apexpages.currentPage().getParameters().get('objId');
        String url = baseURL+'/'+redirectId;
      Pagereference pr = new Pagereference(url);
        pr.setRedirect(true);
        return pr;
    }   
    public static testMethod void testMember(){
        SBcUtil.testMember();
        
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
        conf.Active_Groups__c = 'Admin Group,User Group';
        
        insert conf;   
        
        configurationDetails__c conf1 = new configurationDetails__c ();
        conf1.Name='test12345';
        conf1.Username__c = 'testuser@xyz.com';
        conf1.Password__c = 'password!23';
        conf1.EKey__c = 't#st!23';
        insert conf1;
             
        Configuration__c insertedConf  = [select Base_Folder__c from Configuration__c where Organization_Name__c =: 'testorg123'];
        system.assertEquals('testbf123',insertedConf.Base_Folder__c);        
        
        Account objAccount=new Account();
        objAccount.Name='TestAccount';
        insert objAccount;
        
        Account insertedAcct = [Select id,name from Account where name =: 'TestAccount'];
        system.assertEquals('TestAccount',insertedAcct.Name);
        
        SBcFileList flst = new SBcFileList();
        SBcUtil.showMsg('info','Permission Available');
        SBcFileList.isApexTest = true;
        SBcFileList.getSessionId();
        
        flst.objId = '';
        SBcUtil.showMsg('error','Record Id must contain a value.');
        
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);
        
        SBcFileList flst1 = new SBcFileList();
        
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);
        flst1.cancel();
        
        List<File_Information__c> fileslist = new List<File_Information__c>();
        fileslist = [select id,name from File_Information__c where id<> null];
        if(fileslist.size()>0){
            delete fileslist;
         }
         
         List<File_Information__c> insertFiles = new List<File_Information__c>();
         for(Integer i=0;i<30;i++){
             File_Information__c f = new File_Information__c();
             f.Name = 'testfile'+i+'.txt';
             f.Filesize__c = '10 KB';
             f.Filepath__c = 'testbf123/Account/'+insertedAcct.id;
             f.Content_type__c = 'txt';
             f.Object_Name__c = 'Account';
             f.Record_Id__c = insertedAcct.id;
             insertFiles.add(f);
         }
        
        insert insertFiles;
        
        flst1.showMore = 'false';
        
        SBcObjectPaginatorListenerTest pglistener = new SBcObjectPaginatorListenerTest();
        pglistener.handlePageChangeInvoked = false;
        pglistener.handlePageChange(null);
        
        List<FileInfoWrapper> files = new List<FileInfoWrapper>();
        SBcObjectPaginator paginator = new SBcObjectPaginator(10,flst1);     
        List<File_Information__c> fileList = [select f.name, f.uploaded_date__c,f.OwnerId, f.CreatedBy.Alias, f.CreatedBy.Name, f.CreatedById from file_information__c f where f.record_id__c =: insertedAcct.id and f.OwnerId =: UserInfo.getUserId() order by f.Name];
        paginator.setRecords(fileList); 
        
        
        if(paginator.hasNext){
            paginator.next();
        }
       
        if(paginator.hasPrevious){
            paginator.previous();
        }
        
        paginator.skipToPage(1);
        
        if(paginator.hasNext){
            paginator.next();
        }
        
        paginator.getPageSize();
        
        paginator.first();
        paginator.last();
        
        Integer stPos = paginator.pageStartPositionDisplayFriendly;
        Integer endPos = paginator.pageEndPositionDisplayFriendly;
        
        List<Integer> preSkipNos = paginator.previousSkipPageNumbers;
        List<Integer> nextSkipNos = paginator.nextSkipPageNumbers;
        
        paginator.getPageSizeOptions();
        
        
        ApexPages.currentPage().getParameters().put('pg','viewall');
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);  
        SBcFileList flst2 = new SBcFileList();
      
        flst2.loadData(); 
        
        ApexPages.currentPage().getParameters().put('pg','list');
        ApexPages.currentPage().getParameters().put('pgNum','1');
        ApexPages.currentPage().getParameters().put('showMore','false');
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);  
        SBcFileList flst3 = new SBcFileList();
      
        flst3.loadData(); 
       
    }
}