trigger AccountCallout on Account (after insert, after update) {
    for (Account a : Trigger.new) {
        // make the asynchronous web service callout
        
    }
 
}