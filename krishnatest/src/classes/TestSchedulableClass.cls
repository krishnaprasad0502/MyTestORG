@isTest
private class TestSchedulableClass {

   // CRON expression: midnight on March 15. 
    
   // Because this is a test, job executes 
    
   // immediately after Test.stopTest(). 
    
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
      Test.startTest();

      // Schedule the test job 
    
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ApexScheduledClass());
         
      // Get the information from the CronTrigger API object 
    
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same 
    
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run 
    
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.


      
        
       Account objAccount=new Account();
        objAccount.Name='TestAccount';       
        insert objAccount;
        Account insertedAcct = [Select id,name from Account where name =: 'TestAccount'];
        system.assertEquals('TestAccount',insertedAcct.Name);
           File_Information__c f1 = new File_Information__c();
         f1.Name = 'testfile.txt';
         f1.Filesize__c = '10 KB';
         f1.Filepath__c = 'testbf123/Account/'+insertedAcct.id;
         f1.Content_type__c = 'txt';
         f1.Object_Name__c = 'Account';
         f1.Status__c = 'Uploaded';
         insert f1;
         File_Information__c f2 = new File_Information__c();
         f2.Name = 'testfile1.txt';
         f2.Filesize__c = '';
         f2.Filepath__c = 'testbf123/Account/'+insertedAcct.id;
         f2.Content_type__c = 'txt';
         f2.Object_Name__c = 'Account';
         f2.Status__c = 'In Progress';
         insert f2;
         File_Information__c f3 = new File_Information__c();
         f3.Name = 'testfile1.txt';
         f3.Filesize__c = '';
         f3.Filepath__c = 'testbf123/Account/'+insertedAcct.id;
         f3.Content_type__c = 'txt';
         f3.Object_Name__c = 'Account';
         f3.Status__c = 'DELETE';
         insert f3;
         
       
    List<File_Information__c> delFilesList = [select name,status__c , id ,LastModifiedDate from file_information__c where (status__c = 'In Progress' or  status__c = 'DELETE') and  name =: 'testfile.txt' and LastModifiedDate
< Yesterday  ];
      System.assertEquals(delFilesList .size(),0);
          if(delFilesList != null && delFilesList.size()>0){
                delete delFilesList;
              }
      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(), 
    
      //   fetch the new merchandise that got added. 
    
  

   }
}