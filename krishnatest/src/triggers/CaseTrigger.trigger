trigger CaseTrigger on Case (after insert) {
  if(RecursiveControl.firstRun) {
    SAPServices.CreateServiceNotification(Trigger.New[0].Id);
    RecursiveControl.firstRun = false;
  }
}