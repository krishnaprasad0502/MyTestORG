public with sharing class ExportToExcelMultipleSheets {
    public Datetime startDate{get; set;}
    public Datetime endDate{get; set;}
    public string Status {get; set;}
    public case caseObj {get;set;}
    public  list<SelectOption> options = new list<SelectOption>();
    public List<Case> CaseList= new List<Case>();
    String serial;     
    public List<Case> getCaseList(){
        return CaseList;
    } 
    public void setCaseList(){
    }
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '';
            strHeader += '';
            return strHeader;
        }
    }
    public ExportToExcelMultipleSheets() {
  
    }
    public Pagereference exportAll(){
    
    system.debug('serial2--***'+serial);
    system.debug('startDate--***'+startDate);
    CaseList = [select CaseNumber,Id,CreatedDate,status   from case where Status =:Status ];
    system.debug('CaseList --***'+CaseList );
    return new Pagereference('/apex/ExportToall');
    }
}