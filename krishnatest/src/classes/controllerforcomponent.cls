public  class controllerforcomponent {
     public String objectname{get;set;}
     public LIst<sobject> lstData{get;set;}
     public String sQuery;
     public List<Sobject> getrecords(){
      System.debug('--@@Check the received parameters in constructor@@--'+ objectname);
         sQuery ='';
         sQuery = sQuery + 'select id,firstname,lastname from ' + objectname;
         system.debug('squery:'+squery);
         lstdata = new LIst<Sobject>();
         lstdata = database.query(sQuery);
         if(lstData.size() != null && lstdata.size()>0)
             return lstdata;
         else
             return null;
     }
        
}