global class SBcApexScheduler implements Schedulable {

  //  public static String CRON_EXP = ' 0 0 23 * * ?';  //Class runs every one hour
  
    global void execute(SchedulableContext ctx) {
        try
          { 
                      List<File_Information__c> delFilesList = [select name, id from file_information__c where status__c = 'In Progress' and  status__c = 'DELETE' and LastModifiedDate
< Yesterday  ];
            if(delFilesList != null && delFilesList.size()>0){
                delete delFilesList;
              }
             
          }
          catch (exception ex)
          {
              system.debug(ex.getcause());
          }
     
     
     }

}