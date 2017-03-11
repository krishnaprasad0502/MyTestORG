global with sharing class wMcallout21{
   
    @Future(callout=true)    
    webservice static void createOPP(String name,string bcity) {       
        
         //gssusnj37GlobalsoftsolutionsNetProvid.SFDCACCINS ACC= new gssusnj37GlobalsoftsolutionsNetProvid.SFDCACCINS();
         ACCNetProvid.Provider_ACCSFDCINSPROVIDER_Port ACC = new  ACCNetProvid.Provider_ACCSFDCINSPROVIDER_Port ();
 
        // this doesn't exist because Employee doesn't extend Person
        //ACC.Name= 'Fernando AlonsotEST'; 
         
        //ACC.BillingCity = 'us';
         
        // this also doesn't work for the same reason
        string res = ACC.SFDCACCINS('A','B');
        
        }
        }