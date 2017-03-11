public with sharing class SBcUserPrivileges {
    public boolean pageRender{get;set;}
    public boolean disableButtons{get;set;}
    static String PROFILE_NAME{get;set;}    
    public static boolean isApexTest = false;
    private String allGroups; 
    public static list<String> splitedProfile;   
    private String[] publicGroups1;    
    private List<String> publicGroups = new List<String>();    
    public List<String> getPublicGroups() {
        return this.publicGroups;
    }

    public String[] getPublicGroups1() {
        return this.publicGroups1;
    }
    
    public SBcUserPrivileges(){
        try{
            verifyAccess();          
            if(!pageRender || disableButtons == true){
                SBcUtil.showMsg('error','Insufficient Access - Please Contact your Administrator.');
                return;
            }
            String serviceURL = SBcUtil.getServiceURL();
            if(serviceURL == null || serviceURL.length()<=0){
                 SBcUtil.showMsg('error','Please configure the Service URL under Custom Settings.');
                 return;
            }            
        }Catch(Exception ex){
            system.debug(ex.getStackTraceString());
        }
    }
     
    
    public static List<SelectOption> getItems() {
            Configuration__c configValue;
            List<SelectOption> options = new List<SelectOption>();
            List<Group> newGroup = [Select Id, Group.Name  from Group where Group.Type = 'Regular'];
            Integer rcCount = [Select count() from Configuration__c limit 1];
            if(rcCount > 0){
                configValue = [Select Active_Groups__c  from Configuration__c limit 1];                  
            }  else{
                configValue = new Configuration__c();
            } 
            if(newGroup.size()>0){            
                for(Group newGroup1 : newGroup){
                    if(configValue.Active_Groups__c!=null){                    
                        String valueOptions = configValue.Active_Groups__c;
                        String[] splitedOptions=valueOptions.split(',');
                        Boolean b = false;
                        for(integer i=0;i<splitedOptions.size();i++){
                            if(newGroup1.Name==splitedOptions[i]){
                                b=true;
                            }                            
                        }
                        if(b==false){                            
                            options.add(new SelectOption(newGroup1.Name,newGroup1.Name));
                        }
                    }else{
                        options.add(new SelectOption(newGroup1.Name,newGroup1.Name));
                    }
                    
                }
                Boolean isActiveConfig = false;
                List<String> opTvalues = new  List<String> ();
                set<String> opTvaluesSet = new  set<String> ();
                if(configValue.Active_Groups__c != null){
                    splitedProfile = new list<String>();
                    String opTVal = configValue.Active_Groups__c;
                    opTvalues = opTVal.split(',');
                    isActiveConfig = true;
                }
                opTvaluesSet.addAll(opTvalues);
                for (ProfileName__c ProName : ProfileName__c.getAll().values()){
                    String profileName = ProName.Profile_Name__c;
                    if(isActiveConfig){ 
                        Boolean isAdded = false;
                   /*    for(integer i=0;i<opTvalues.size();i++){
                            if(profileName == opTvalues[i]){
                                isAdded = true;
                            }                            
                      }*/
                      isAdded = opTvaluesSet.contains(profileName);
                      
                        if(isAdded == false){                            
                            options.add(new SelectOption(profileName,profileName));
                        }
                    }else{
                        options.add(new SelectOption(profileName,profileName));
                    }
                }  
            }          
            return options;
        }
        public PageReference save() {
            try{
                Configuration__c newConfig = new Configuration__c();
                integer countRecord= [Select count() from Configuration__c limit 1];
                if(allGroups!=null){
                    if(countRecord >0 ){  
                         Configuration__c configValue = [Select id,Active_Groups__c  from Configuration__c limit 1];
                        String valueOptions = configValue.Active_Groups__c;      
                         configValue.Active_Groups__c = allGroups;
                        update(configValue);    
                    }                
                } 
                SBcUtil.showMsg('info','Saved successfully');        
                return null;
            }catch(Exception ex){
            SBcUtil.showMsg('error','Problem in setting user privileges');        
            return null;
            }
        }
        public static List<SelectOption> getItems1() {
            List<SelectOption> options = new List<SelectOption>();
            Configuration__c configValue;
            Integer rcCount = [Select count() from Configuration__c limit 1];
            if(rcCount > 0){
                configValue = [Select Active_Groups__c  from Configuration__c limit 1];                  
            }  else{
                configValue = new Configuration__c();
            } 
            if(configValue.Active_Groups__c!=null){
                String valueOptions = configValue.Active_Groups__c;
                String[] splitedOptions=valueOptions.split(',');
                if(splitedOptions.size()>0){               
                    for(integer i=0;i<splitedOptions.size();i++){
                        options.add(new SelectOption(splitedOptions[i],splitedOptions[i]));
                    }
                }
            }      
            return options;
        }
        public String getAllGroups() {
            return allGroups;
        }    
        public void setAllGroups(String allGroups) {
            this.allGroups= allGroups;
        }
        public void setPublicGroups(List<String> publicGroups) {
            this.publicGroups = publicGroups;
        }
        public void setPublicGroups1(String[] publicGroups1) {
            this.publicGroups1 = publicGroups1;
        }
        
        public void verifyAccess(){
            try{        
                this.pageRender = true;
                this.disableButtons = false;                    
                
                Map<String,String>  configFields = new Map<String,String>{'Active_Groups__c'=>'read','Active_Groups__c'=>'create','Active_Groups__c'=>'edit','Organization_Name__c'=>'read'};          
                
                Configuration__c configObj = new Configuration__c();
                                  
                if(!SBcUtil.checkFieldAccessiblity(configObj,configFields)){
                    pageRender = false;
                }            
                
            }catch(Exception ex){ 
                pageRender = false;   
                system.debug('Exception Occured...'+ex.getStackTraceString());           
            }
        }

  
        
   public static testmethod void testMember(){
        SBcUserPrivileges userPrivileges; 
        SBcUserPrivileges.isApexTest = true;
        String allGroups;   
        String[] publicGroups1;    
        List<String> publicGroups = new List<String>();
        List<SelectOption> options = SBcUserPrivileges.getItems();
        List<SelectOption> options1 = SBcUserPrivileges.getItems1();
        
        SBcUtil.testMember();
        userPrivileges = new SBcUserPrivileges();        
        allGroups = 'grp1,grp2,grp3';
        userPrivileges.setAllGroups(allGroups);
        allGroups = userPrivileges.getAllGroups();
        publicGroups1 = userPrivileges.getPublicGroups1();
        publicGroups = userPrivileges.getPublicGroups();  
        
        
        userPrivileges.setPublicGroups1(publicGroups1);
        userPrivileges.setPublicGroups(publicGroups);
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
        Configuration__c newConfig = new Configuration__c();
        Integer rcCount1  = [Select count() from Configuration__c where id <> null];
        if(rcCount1 > 0){
            newConfig = [Select id,Active_Groups__c  from Configuration__c limit 1];
            newConfig.Active_Groups__c = allGroups;
            userPrivileges.save();
            SBcUtil.showMsg('info', 'Groups Added Successfully.');
        }
        options = SBcUserPrivileges.getItems();
         options1 = SBcUserPrivileges.getItems1();
        rcCount  = [Select count() from Configuration__c where id <> null];
        if(rcCount > 0){                    
            newConfig = [Select id,Active_Groups__c  from Configuration__c limit 1];
            String activeGrps = newConfig.Active_Groups__c;
            System.assertEquals(activeGrps, 'grp1,grp2,grp3');
        }
        
        SBcUtil.showMsg('error', 'Groups Already Enabled.');
   }

}