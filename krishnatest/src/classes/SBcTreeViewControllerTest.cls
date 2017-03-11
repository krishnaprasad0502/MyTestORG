@isTest
    private class SBcTreeViewControllerTest{
    
    static testMethod void testSBcTreeViewController(){ 
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
        conf.Active_Groups__c = 'System Administrator';        
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
       
        ///////////////////////////////////////////////////////--start
          
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Customer';
        insert acc;  
     
        Contact c = new Contact();
        c.FirstName = 'usrFName';
        c.LastName = 'usrLName';
        c.email = 'krishnaprasad0502@gmail.com';
        c.AccountId = acc.id;
        insert c;
        
        Product2 Pro = new Product2();       
           Pro.Name = 'NewProduct';           
           Pro.ProductCode = '98765';
           Pro.Product_Group_Name__c= 'Energy';
           Pro.IsActive = true;   
        insert pro; 
              
        Asset ass = new Asset();
          ass.Name = 'nclusive';
          ass.AccountId = acc.id;
          ass.Product2Id = pro.id;     
          ass.Price = 300;     
          ass.Status = 'Active';
          ass.Description = 'Allocated Spaces';
        insert ass;
      
         General_Dcouments__c genDoc = new General_Dcouments__c();
             genDoc.Name = 'softDoc';
             genDoc.Type__c = 'Document';            
             genDoc.versoins__c = genDoc.id;
             genDoc.Order_id__c = '1';
             genDoc.Product_Group_Name__c = 'Energy';
        insert genDoc;        
        String keyV = String.valueOf(genDoc.id).substring(0, (String.valueOf(genDoc.id).length()-3));    
           File_Information__c f = new File_Information__c();
             f.Name = 'testfile.txt';
             f.Filesize__c = '10 KB';
             f.Filepath__c = 'testbf123/Account/'+acc.id;
             f.Content_type__c = 'txt';
             f.Object_Name__c = 'Account';
             f.Record_Id__c = keyV;
             insert f;
             
        Group gro = new Group();
        gro.DeveloperName = 'testgroup123';
        gro.DoesIncludeBosses = true;
        gro.DoesSendEmailToMembers = false;
        gro.Name = 'testgroup123';
        gro.Type  = 'Regular';     
        insert gro; 
        
       
     Profile p = [SELECT Id FROM Profile WHERE Name='Customer Portal Manager Custom New']; 
      User userInstance = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id,ContactId=c.id,
      TimeZoneSidKey='America/Los_Angeles', UserName='standardTestuser@testorg.com');          
           insert  userInstance; 
           system.runAs(userInstance){
            system.debug('userInstance'+userInstance);
            SBcDocumentUtil controllers = new SBcDocumentUtil ();
          controllers.getTreeJSON();  
            SBcTreeViewController flst= new SBcTreeViewController();
        SBcUtil.showMsg('info','Permission Available');
        SBcTreeViewController.isApexTest = true;
        SBcTreeViewController.getSessionId();
        flst.getJsonString();        
        flst.objId = '';
        SBcUtil.showMsg('error','Record Id must contain a value.');           
      }
     SBcUtil.showMsg('error','Record Id must contain a value.');
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);
        SBcTreeViewController flst1 = new SBcTreeViewController();
        
        ApexPages.currentPage().getParameters().put('pg','viewall');
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);  
        SBcTreeViewController flst2 = new SBcTreeViewController();
        
        ApexPages.currentPage().getParameters().put('pg','list');
        ApexPages.currentPage().getParameters().put('pgNum','1');
        ApexPages.currentPage().getParameters().put('showMore','false');
        ApexPages.currentPage().getParameters().put('objId',insertedAcct.id);
        ApexPages.currentPage().getParameters().put('objName','Account');
        ApexPages.currentPage().getParameters().put('recordName',insertedAcct.Name);  
       SBcTreeViewController flst3 = new SBcTreeViewController(); 
      }  
}