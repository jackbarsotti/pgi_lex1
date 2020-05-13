global class iGlooConferenceRESTCalloutScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        iGlooConferenceRESTCallout.makeGETCallout();
    }  
}