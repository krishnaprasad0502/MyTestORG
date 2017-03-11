global with sharing class SBcFolderDelete  {
    public static Boolean isApexTest = false;

    public String successUrl { get; set; }
    public String failureUrl { get; set; }
    public String serviceUrl { get; set; }
  
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}     
    public String hostname { get;set;}
    public String baseURL { get;set;}
    public String objId{ get;set;}
    public String objName { get;set;}
    public String recordName { get;set;}  
    public String idstr { get;set;}
    global static String retVal{ get; set; }
    global static Boolean isDelTest = false;
    public String statusFolder {get; set;}
    global SBcFolderDelete (){  
         idstr = Apexpages.currentPage().getParameters().get('param1');       
      }      
    @RemoteAction
    global static String showFileInfo(String idStr){
        system.debug('dfsds:::::::');
         retVal = null;
        list<General_Dcouments__c > lstFolderInfo = new  list<General_Dcouments__c >();
        list<File_Information__c > lstFileInfo = new list<File_Information__c >();
        lstFolderInfo =   [Select id  From General_Dcouments__c where id =: idstr ];
        lstFileInfo =   [Select id,Record_ID__c  From File_Information__c where Status__c = 'Uploaded' and Record_ID__c  =: idstr ];    
        try{                     
            if(lstFileInfo != null && lstFileInfo.size() > 0){
                retVal = 'Error in Deleting Folder. Please Delete Files in attachments.';
                isDelTest = true;
                 system.debug('isDelTest2222::---::'+isDelTest);
            }else{
                //delete lstFolderInfo;  
               retVal = 'SucessFully  Deletes Folder. ';
               isDelTest = false;
            }
        }catch(Exception ex){
            system.debug('inside showFileInfo() exception caught::'+ex.getStackTraceString());
        }
        return retVal;
    }      
   public Pagereference redirectPage(){ 
    statusFolder = Apexpages.currentPage().getParameters().get('statusFolder'); 
    system.debug('statusFolder:::'+statusFolder);
    if(statusFolder == 'SucessFully  Deletes Folder. '){
        system.debug('SucessFully:::');
         baseURL = URL.getSalesforceBaseUrl().toExternalForm();      
         Pagereference pr = new Pagereference(baseURL+'/a04/o');           
         pr.setRedirect(true);
         return pr;  
    }else{
        system.debug('NOT SucessFully');
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();       
         Pagereference pr = new Pagereference(baseURL+'/'+idstr);          
         pr.setRedirect(true);
         return pr; 
    } 
  }   
  
}