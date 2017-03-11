@isTest

    private class TestAPPScQuickConvertLead1{

        static testMethod void TestAPPScQuickConvertLead1() {
            
        test.startTest();
            
    
            Account a = new Account(Name ='Golden State Warriors');
insert a;
            Account a1 = new Account(Name ='Golden State Warriors1');
insert a1;
            Account a3 = new Account(Name ='test123');
insert a3;

             Contact c = new Contact(FirstName ='Steph',LastName= 'Curry',Accountid=a.Id);
insert c;
            Contact c1 = new Contact(FirstName ='Steph1',LastName= 'Curry1',Accountid=a1.Id);
insert c1;
            Contact c2 = new Contact(FirstName ='kush1',LastName= 'ribben1',Accountid=a3.Id);
insert c2;
             Contact c3 = new Contact(FirstName ='kush21',LastName= 'ribben21',Accountid=a3.Id);
insert c3;
            
            
        Lead dupeLead      = new Lead();
       dupeLead.FirstName = 'Steph';
       dupeLead.LastName  = 'Curry';
       dupeLead.Company   = 'Golden State Warriors';
       dupeLead.Email     = 'stephcurry@gsw.com';
        
        insert dupeLead;
PageReference pageRef = Page.leadConvertion;

system.debug('dupeLead.id---'+dupeLead.id);
            pageRef.getParameters().put('param1',dupeLead.id);
            Test.setCurrentPage(pageRef);


 APPScQuickConvertLead1 ec = new APPScQuickConvertLead1();      
    ec.doProcessSelection();
    ec.backToLead();
           
          



        

          
            
            
        
        System.debug('Created and inserted lead');
        
         Database.LeadConvert lc = new database.LeadConvert();
     lc.setLeadId(dupeLead.Id);

     LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
     lc.setConvertedStatus(convertStatus.MasterLabel);
            
            
            
            
     //Database.LeadConvertResult lcr = Database.convertLead(lc);

     // Make sure conversion was successful
     //System.assert(lcr.isSuccess()); 

     test.stopTest();
        
        
            
    } 
}