public class DeletingCheckedRowsController {
    public List<WrapperClass> listWrapper {get;set;}
    public Boolean allBool {get;set;}
    
    public DeletingCheckedRowsController() {
        listWrapper = new List<WrapperClass>();
        List<Account> listEmp = [SELECT Id, Name FROM Account];
        if(listEmp.size() > 0) {
            for(Account emp : listEmp) {
                listWrapper.add(new WrapperClass(emp));
            }
        }
    }
    
    public class WrapperClass {
        public Boolean checked {get;set;}
        public Account emp {get;set;}
        public WrapperClass(Account emp) {
            this.emp = emp;
        }
    }
    
    public void del() {
        List<Account> listEmpForDel = new List<Account>();
        List<WrapperClass> listTempWrapper = new List<WrapperClass>();
        for(WrapperClass w : listWrapper) {
            if(w.checked) {
                listEmpForDel.add(w.emp);
            } else {
                listTempWrapper.add(w);
            }
        }
        if(listEmpForDel.size() > 0) {
            delete listEmpForDel;
            listWrapper = listTempWrapper;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one account'));
        }
    }
    
    public void selectAll() {
        if(allBool) {
            for(WrapperClass w : listWrapper) {
                w.checked = false;
            }
        } else {
            for(WrapperClass w : listWrapper) {
                w.checked = true;
            }
        }
    }
}