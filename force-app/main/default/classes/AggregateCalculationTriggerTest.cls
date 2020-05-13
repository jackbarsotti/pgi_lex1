@IsTest
public without sharing class AggregateCalculationTriggerTest {
    @IsTest
    public static void testEvent() {
		Test.startTest();
        List<Aggregate_Calculation_Event__e> listOfagregateEvents = new List<Aggregate_Calculation_Event__e>();
        Aggregate_Calculation_Event__e obj = new Aggregate_Calculation_Event__e(); 
        listOfagregateEvents.add(obj);
        List<Database.SaveResult> results = EventBus.publish(listOfagregateEvents);
        Test.stopTest();
    }
    
}