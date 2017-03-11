global class ApexScheduledClass Implements Schedulable{
   public static String CRON_EXP = '0 0 0 3 9 ? 2022';
            
                       global void execute(SchedulableContext sc)
                        {
                          try
          { 
                      List<File_Information__c> delFilesList = [select name,status__c , id ,LastModifiedDate from file_information__c where (status__c = 'In Progress' or  status__c = 'DELETE') and LastModifiedDate
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