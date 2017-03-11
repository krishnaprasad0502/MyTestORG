public with sharing class Pagination_min {
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                string queryString = 'Select id from Case';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Case> getCase(){
        List<Case> CaseList = new List<Case>();
        for(Case c: (List<Case>)setCon.getRecords())
            CaseList.add(c);
        return CaseList ;
    }
     
    public pageReference refresh() {
        setCon = null;
        getCase();
        setCon.setPageNumber(1);
        return null;
    }
}