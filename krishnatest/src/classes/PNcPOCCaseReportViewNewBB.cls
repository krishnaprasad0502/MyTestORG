public with sharing class PNcPOCCaseReportViewNewBB implements ObjectPaginatorListener{
  public List<Case> caseList{get;set;}
  public List<Case> lstCase{get;set;}
  public Date eDate { get; set; }
    public Date sDate { get; set; }
    /*public DateTime eDate { get; set; }
    public DateTime sDate { get; set; }*/
    public Case casVal { get; set; }
    public Integer pageNumber {get;set;}
  public ObjectPaginator paginator {get;private set;}
  public List<SelectOption> lstSelectOption{get;set;}
  public String selectedCaseStatus{get;set;}
   public List<String> distinctInterval{get;set;}
    
  public PNcPOCCaseReportViewNewBB(){
    caseList = new List<Case>();
    lstCase = new List<Case>();
    casVal = new Case();
    caseList = [Select  CaseNumber, Account.Name, AccountId From Case ORDER BY Account.Name limit 40000];
    paginator = new ObjectPaginator(20,this);
        paginator.setRecords(caseList);
        
        lstSelectOption = new List<SelectOption>();
        list<Schema.PicklistEntry> typeValues = Case.Status.getDescribe().getPicklistValues();
        if(typeValues != null && typeValues.size() > 0){
          lstSelectOption.add(new SelectOption('All','All'));
            for(Schema.PicklistEntry pic : typeValues){
              SelectOption sOption = new SelectOption(pic.getLabel(), pic.getValue());
              lstSelectOption.add(sOption);
            }
        }
  }
  public void handlePageChange(List<Object> newPage){
    lstCase.clear();
        if(newPage != null){
            for(Object caseVal : newPage){
                lstCase.add((Case)caseVal);
            }
        }
  }
  public void searchCases(){
    system.debug('selectedCaseStatus ::'+selectedCaseStatus);
    system.debug('eDate ::'+eDate);
    system.debug('sDate ::'+sDate);
    
    /*Date StartD = date.valueOf(sDate);
        Time endTime = Time.newInstance(0, 0, 0, 0);         
        sDate = DateTime.newInstanceGmt(StartD ,endTime); 
        
        Date EndD = date.valueOf(sDate);
        Time endTime = Time.newInstance(0, 0, 0, 0);         
        eDate = DateTime.newInstanceGmt(StartD ,endTime); */
        
       
        Integer monthDiff = sDate.daysBetween(eDate);
        Integer i;
        system.debug('monthDiff ::::'+monthDiff );
        if(distinctInterval==null){
            for(i=0;i<monthDiff ;i++){
            string ColDate = sDate.addDays(i).format();
            system.debug('ColDate ::::'+ColDate);
            distinctInterval.add(ColDate);            
            }
        }
        system.debug('distinctInterval::::'+distinctInterval);
        
    
    if(selectedCaseStatus != null && selectedCaseStatus != '' && eDate != null && sDate != null){
      caseList = [Select  CaseNumber, Account.Name, AccountId From Case Where Status =: casVal.Status AND CreatedDate >=:sDate and CreatedDate <=:eDate ORDER BY Account.Name limit 40000];
    }else if(selectedCaseStatus != null && selectedCaseStatus != '' && eDate == null && sDate == null){
      caseList = [Select  CaseNumber, Account.Name, AccountId From Case Where Status =: casVal.Status ORDER BY Account.Name limit 40000];
    }else if(eDate != null && sDate != null){
      caseList = [Select  CaseNumber, Account.Name, AccountId From Case Where CreatedDate >= :sDate and CreatedDate <= :eDate ORDER BY Account.Name limit 40000];
    }else{
      caseList = [Select  CaseNumber, Account.Name, AccountId From Case ORDER BY Account.Name limit 40000];
    }
    paginator = new ObjectPaginator(20,this);
        paginator.setRecords(caseList);
        
  }
  public PageReference skipToPage(){
        this.paginator.skipToPage(pageNumber);
        return null;
    }
    

    
    
}