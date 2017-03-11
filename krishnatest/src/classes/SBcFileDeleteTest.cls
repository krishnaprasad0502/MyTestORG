@isTest
    private class SBcFileDeleteTest{    
    static testMethod void testSBcFileDelete(){ 
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
        SBcFileDelete fileUpload1 = new SBcFileDelete();
        SBcFileDelete.isApexTest = true;        
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
         f1.Status__c = 'Uploaded';
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
         
        SBcFileDelete fileUpload = new SBcFileDelete();
        SBcFileDelete.isApexTest=true;
        SBcUtil.showMsg('info','User has Sufficient access.');
        SBcUtil utilTest = new SBcUtil();
       

       SBcFileDelete.sessionVal = SBcFileDelete.getSession();
       //String sessionValue = fileUpload.sessionVal;
       System.assertNotEquals(SBcFileUpload.sessionVal, 'xyz'); 
       SBcUtil.showMsg('error','The sessionValue is not equal with the provided value.');       
        
        
        SBcFileDelete.showFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage();
        SBcFileDelete.showFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();
        
        SBcFileDelete.deleteFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage(); 
        SBcFileDelete.deleteFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();  
        
        SBcFileDelete.insertFileInfo(insertedFile.id,idStr);
        fileUpload.redirectPage();
        SBcFileDelete.insertFileInfo(insertedFile1.id,idStr);
        fileUpload.redirectPage();

      }  
}