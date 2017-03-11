public with sharing class ExamplePageController {
  public Contact MyContact {get; set;}
  public String StringDate {get; set;}
  public String StringDateDOW {get; set;}
  public String BirthdateDOW {get; set;}
 
  // create a temporary contact 
  public ExamplePageController() {
    MyContact = new Contact();
  }
 
  // find the day of the week for Birthdate.  Date.valueOf can be used with Date fields
  public PageReference FindBirthdateDOW() {
    try {
      BirthdateDOW = DateTime.newInstance( Date.valueOf(MyContact.Birthdate), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
    } catch (exception e) {
      BirthdateDOW = '';
    } 
    return null;
  }
 
  // find the day of the week for StringDate.  Date.parse can be used with String fields
  public PageReference FindStringDateDOW() {
    try {
      StringDateDOW = DateTime.newInstance( Date.parse(StringDate), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
    } catch (exception e) {
      StringDateDOW = '';
    } 
    return null;
  }
}