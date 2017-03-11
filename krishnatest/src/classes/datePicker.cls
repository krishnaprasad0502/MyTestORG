public with sharing class datePicker {

   public String outputdate { get; set; }
    public date datename {get; set;}
   
    public void displayDate()
    {
        String formattedDate = outputdate + ' 00:00:00';
        datename = Date.valueOf(formattedDate.replaceAll('/', '-'));
    }

}