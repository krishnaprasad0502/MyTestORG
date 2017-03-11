//This is class for Displaying All objects in picklist
public class AllObjDynamicDisplayClass{

   /* public PageReference fields() {
        return null;
    }*/


    //public String objectName { get; set; }

    public String ren { get; set; }
    public PageReference Fields() {
         Schema.SObjectType gd;
          Schema.DescribeSobjectResult a11;
        if(selectedObj!=null){
              gd = Schema.getGlobalDescribe().get(selectedObj);
              a11=gd.getDescribe();
        }
        pagereference pg;
      //here we are comparing the selected object is creatable or not
        if(a11.isCreateable() && a11.isAccessible() && a11.isDeprecatedAndHidden()==false && a11.isQueryable() && a11.isSearchable())
        pg=new Pagereference('/'+a11.getKeyPrefix()+'/e?');
        return pg;
    }
//we are returning the fields from selected object if it is not creatable
   public List<Schema.SObjectField> getFields(){
    List<Schema.SObjectField> sss=new list<Schema.SObjectField>();
    if(selectedObj!=null){
    sss.clear();
    Schema.SObjectType gd = Schema.getGlobalDescribe().get(selectedObj);
    Schema.DescribeSobjectResult a11=gd.getDescribe();  
    Map<String, Schema.SObjectField> M = a11.fields.getMap();
    for(Schema.SObjectField s1:m.values()){
        system.debug('----'+s1+'\n');
        sss.add(s1);
    }
   }
    return sss; 
}
    public List<SelectOption> items { get; set; }
    public String selectedObj { get; set; }
    public AllObjDynamicDisplayClass(){
        List<Schema.sObjecttype> lst= Schema.getGlobalDescribe().values();//this is used for getting all the objects from org
        items= new List<SelectOption>();
        items.add(new SelectOption('','--None--'));
        for(Schema.sobjecttype s:lst){
       // if(String.valueOf(s).contains('__c'))
            items.add(new SelectOption(string.valueOf(s),String.valueOf(s)));
        }
    }
}