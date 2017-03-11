global with sharing class  SBcTreeViewController {
  
  public Boolean selectable {get; set;}
  
  public String selectNodeKeys {get; set;}

  {
    selectable = true;
    selectNodeKeys = 'No value selected';
  }
    public static List<String> lstAssestProducts{get;set;}   
   global String ObjName { get;set;}
    public String filePath  { get;set;}    
    global String objId{ get;set;} 
    public String recordName{ get;set;} 
    public String cPage{ get;set;}   
    public String showMore{get;set;} 
    public static boolean isApexTest = false;
    public String hasPrivilege { get; set; }
    public String hasPrivileges ;   
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
    public String JsonData {get; set;}
    public String JsonData2 {get; set;}
    public String docId {get; set;}  
    public String roleOrUserId {get; set;}  
   public SBcTreeViewController(){
    try{   
            integer afterNamespace;
            integer beforeNamespace;
            string urlForm;
            verifyAccess();        
            if(!pageRender || disableButtons == true){              
                SBcUtil.showMsg('error','Insufficient access - Please contact your system administrator.');
                hasPrivilege  = 'false';
                return;
            }            
            boolean hasAccess = verifyUserPrivilege();
            if(hasAccess){
                
                hasPrivilege = 'true';              
            }else {
                 hasPrivilege = 'false';
                SBcUtil.showMsg('error','You do not have the required permission to access Cloud Storage. Please contact your Administrator.');                     
                return; 
                
            }
           lstAssestProducts = new List<String>();
       List<User> lstUser = [Select id, Name, ContactId, AccountId From User Where id=:UserInfo.getUserId() Limit 1];
        system.debug('lstUser:::---'+lstUser);
       List<Asset> lstAcc = [SELECT AccountId,Id,Name,Product2Id,status FROM Asset Where AccountId=:lstUser[0].AccountId  and Product2Id <> null and status='Active'];
        system.debug('lstAcc:::---'+lstAcc);
         if(lstAcc.size() ==0)
         {
         hasPrivilege = 'false';
                SBcUtil.showMsg('error','No Assets is Active.');                     
                return; 
          }               
            
     for(Asset ass: lstAcc){
        lstAssestProducts.add(ass.Product2Id); 
       }
       
       System.debug('lstAssestProducts ::: '+lstAssestProducts);
    List<product2> lstProd= [SELECT id,Name,IsActive,Product_Group_Name__c FROM product2 Where id IN: lstAssestProducts and IsActive = true and Product_Group_Name__c <> null];
    if(lstProd.size() ==0)
         {
         hasPrivilege = 'false';
                SBcUtil.showMsg('error','No products is Active.');                      
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
           
            serviceUrl=SBcUtil.getServiceURL();
            if(serviceUrl == null || serviceUrl.length()<=0){
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
            } 
           
            if(Apexpages.currentPage().getParameters().get('pg') != null){
                    cPage = Apexpages.currentPage().getParameters().get('pg');
            }   
                     
    
           
        }catch(Exception ex){
            system.debug('inside constructor(SBcFileList) exception caught::'+ex.getStackTraceString());
        }
  }
  ///////////////////////////////////////////////////////////////////////////////////
   
///////////////////////////////////////////////////////////////////////////////////
 private boolean isActiveGroup(List<String> groupName){
        try{
      
            
            boolean isActive = false;
            Configuration__c configValue = [Select Active_Groups__c  from Configuration__c  limit 1];  
            system.debug('configValue---'+configValue);                     
            if(configValue.Active_Groups__c!=null){
                String valueOptions = configValue.Active_Groups__c;
                
                String[] splitedOptions=valueOptions.split(',');
                Boolean b = false;
                for(integer i=0;i<splitedOptions.size();i++){
                    system.debug('groupName:::'+groupName);
                    for(String a:groupName){
                        if(a==splitedOptions[i]){
                        
                            b=true;
                        }
                    }
                }
                if(b==true){
                    isActive= true;
                      system.debug('isActiveIF---'+isActive);  
                }
                else{
                    isActive = false;
                      system.debug('isActiveELSE---'+isActive);  
                }
            }
            else{
                isActive = false;
                 system.debug('elseisActiveELSE---'+isActive);
            }
            return isActive;
        }catch(Exception ex){
            return false;
        }
    }
///////////////////////////////////////////////////////////////////////////////////
 
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
                system.debug('sessionid ::'+userid+','+authVal+','+ctTime);
            return userid+','+authVal+','+ctTime;
        }catch(Exception ex){
            system.debug('inside getSessionId() exception caught::'+ex.getStackTraceString());
            return null;
        }
    }  
   
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

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

        system.debug('groups  ---'+groups  );

               List<String> groupName= new List<String>();   
               if(groups.size()>0){
                    for(Group newGroup:groups){
                        List<GroupMember> groupMember = [select id,groupid,Group.Name, userorGroupid from GroupMember where userorGroupid =: userId];                                        system.debug('groupMember ---'+groupMember ); 
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
    
//////////////////////////////////////////////////////////////////////////////////
    public void verifyAccess(){
        try{    

           
            
            
       

        
            this.pageRender = true;
            this.disableButtons = false;                    
            
            Map<String,String>  configFields = new Map<String,String>{'Base_Folder__c'=>'read'};
            Map<String,String>  fileInfoFields = new Map<String,String>{'Content_Type__c'=>'read','Object_Name__c'=>'read','Record_ID__c'=>'read','Status__c'=>'read','Uploaded_Date__c'=>'read','Filesize__c'=>'read','Filepath__c'=>'read'};
            Map<String,String>  genDocFields = new Map<String,String>{'Product_Group_Name__c'=>'read','Order_id__c'=>'read','versoins__c'=>'read'};
          Map<String,String>  proFields = new Map<String,String>{'Product_Group_Name__c'=>'read','IsActive'=>'read'};
           Map<String,String>  assetFields = new Map<String,String>{'AccountId'=>'read','ContactId'=>'read','Name'=>'read','Status'=>'read'};

            
            Configuration__c configObj = new Configuration__c();
            File_Information__c fileInfo = new File_Information__c();
            General_Dcouments__c genDocInfo = new General_Dcouments__c();
             Product2 proInfo = new Product2();
             Asset assetInfo = new Asset();
           
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
                pageRender = false;
            }               
                         
            if(!SBcUtil.checkFieldAccessiblity(fileInfo,fileInfoFields)){
                pageRender = false;
                disableButtons = true;                      
            }
             if(!SBcUtil.checkFieldAccessiblity(genDocInfo ,genDocFields )){
              pageRender = false;
               disableButtons = true;                      
           }
             if(!SBcUtil.checkFieldAccessiblity(proInfo ,proFields )){
              pageRender = false;
               disableButtons = true;                      
           }
             if(!SBcUtil.checkFieldAccessiblity(assetInfo ,assetFields )){
              pageRender = false;
               disableButtons = true;                      
           }
            
         
        
        }catch(Exception ex){ 
            pageRender = false;   
            SBcUtil.showMsg('error','Exception Occured');           
        }
    }
    
    
//////////////////////////////////////////////////////////////////////////////////
SBcDocumentUtil  objForCls = new SBcDocumentUtil ();
//objForCls.getTreeJSON();
    public String getJsonString() {
        if (JsonData == null){
            if(hasPrivilege == 'false' ){    
                JsonData = '------------------------JsonData';
             }else{
                 JsonData = objForCls.getTreeJSON();
          }
        }
        return JsonData;
    }
}