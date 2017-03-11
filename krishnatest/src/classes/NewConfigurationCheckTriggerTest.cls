@isTest
private class NewConfigurationCheckTriggerTest { 
    static testMethod void newConfigurationCheckTriggerTest() {

        List <Configuration__c> lists = [Select Organization_Name__c from Configuration__c where id <> null];
        if (lists != null)
            delete lists;   
       
        Configuration__c conf = new Configuration__c();
        conf.Organization_Name__c = 'testorg123';
        conf.Base_Folder__c = 'testbf123';
        //conf.Username__c = 'testuser@xyz.com';
        //conf.Password__c = 'password!23';
        //conf.Encryption_Key__c = 't#st!23';
        conf.Active_Groups__c = 'grp1,grp2';
        
        insert conf;   

        List<Configuration__c> getCon = new List<Configuration__c>([Select Organization_Name__c from Configuration__c where Organization_Name__c='testorg123']);
        for(Configuration__c a : getCon){
            System.assertEquals('testorg123',a.Organization_Name__c);
        }
    }
}