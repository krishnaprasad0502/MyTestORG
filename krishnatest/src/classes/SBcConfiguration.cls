public with sharing class SBcConfiguration {
    String acctType;
    public static Boolean isApexTest = false;
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}  
    public String baseURL { get; set;}
    
    public String getAcctType() {
        return acctType;
    }
                    
    public void setAcctType(String acctType) { this.acctType = acctType; }
    
    public SBcConfiguration(){
        try{            
            verifyAccess();        
            if(!pageRender || disableButtons == true){              
                 SBcUtil.showMsg('error','Insufficient access - Please contact your system administrator.');
                 return;
            } 
            String serviceURL = SBcUtil.getServiceURL();
            if(serviceURL == null || serviceURL.length()<=0){
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
            } 
              
            if(!isApexTest){
                String resp = SBcUtil.verifyCallout(isApexTest);
             
                if(resp != null && resp.contains('Failed')){
                    SBcUtil.showMsg('error','Please verify the Service URL under Custom Settings and Remote Site Settings.');
                    return;
                }
            }
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();      
        }catch(Exception ex){
            system.debug('Exception Occured....'+ex.getStackTraceString());  
        }
    }
    
    public void verifyAccess(){
        try{        
            this.pageRender = true;
            this.disableButtons = false;                    
            
            Map<String,String>  configFields = new Map<String,String>{'Organization_Name__c'=>'read'};
            
            Configuration__c configObj = new Configuration__c();
            
            if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
                pageRender = false;
                disableButtons = true;
            }            
            
        }catch(Exception ex){ 
            pageRender = false;   
            system.debug('Exception Occured....'+ex.getStackTraceString());           
        }
    }
    public Pagereference isAccountExists(){
        try{
            Configuration__c config = [Select Organization_Name__c from Configuration__c limit 1];
            if(config.Organization_Name__c != null || config.Organization_Name__c !=''){
                return Page.SBvAccountDetails; 
            }else{
                return null;
            }
        }catch(Exception ex){
            system.debug('Exception Occured.'+ex.getStackTraceString());
            return null;
        }
    }
    
    public Pagereference nextPage(){
        if(acctType == '' || acctType == null){
            SBcUtil.showMsg('warn','Please Select an Account Type');
            return null;            
        }
        else if(acctType=='default'){
            return Page.SBvAccountActivation;
        }
        else if(acctType=='own'){
            return Page.SBvAccountCreation;
        }
        else{
            return null;
        }
    }
    
    public Pagereference cancel(){   
        String url = baseURL+'/home/home.jsp'; 
        Pagereference pr = new Pagereference(url);
        pr.setRedirect(true);    
        return pr;
    } 
    
    
    
    public static testMethod void testMember(){
        SBcConfiguration config = new SBcConfiguration();
        SBcConfiguration.isApexTest = true;
        config.setAcctType(''); 
        config.nextPage();
        SBcUtil.showMsg('warn', 'Please Select an Account Type');
        
        config = new SBcConfiguration();
        config.setAcctType(null); 
        config.nextPage();
        SBcUtil.showMsg('warn', 'Please Select an Account Type');
        
        config.setAcctType('default');
        system.assertEquals(config.acctType,'default');     
        config.nextPage();
        SBcUtil.showMsg('info', 'You have chosen CSS Account');
        
        config.setAcctType('own');
        system.assertEquals(config.acctType,'own');     
        config.nextPage();
        SBcUtil.showMsg('info', 'You have chosen your Own Account');
        config.getAcctType();
        
        config.isAccountExists();
        Configuration__c config1;
        Integer rcCount  = [Select count() from Configuration__c where id <> null];
        if(rcCount > 0){
            config1 = [Select Active_Groups__c,Organization_Name__c, Base_Folder__c from Configuration__c limit 1];
            if(config1.Organization_Name__c != null && config1.Organization_Name__c != ''){
                delete config1;
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
        
        
        config.isAccountExists(); 
        Configuration__c insertedConf  = [select Base_Folder__c from Configuration__c where Organization_Name__c =: 'testorg123'];
        if(insertedConf.Base_Folder__c != null && insertedConf.Base_Folder__c != ''){
            System.assertEquals(insertedConf.Base_Folder__c,'testbf123');
            delete insertedConf;
        }
       
        config.isAccountExists();
        SBcUtil.showMsg('error', 'No Account Exists');
         
        config.cancel();
        
    }
}