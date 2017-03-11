global class SBcObjectPaginatorListenerTest implements SBcObjectPaginatorListener{
  global Boolean handlePageChangeInvoked {get;set;}
  
  global SBcObjectPaginatorListenerTest(){
    handlePageChangeInvoked = false;
  }
  
  global void handlePageChange(List<Object> newPage){
    handlePageChangeInvoked = true;
  }
  
}