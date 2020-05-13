trigger AggregateCalculationTrigger on Aggregate_Calculation_Event__e (after insert) {
    new AggregateCalculationTriggerHandler().run();
}