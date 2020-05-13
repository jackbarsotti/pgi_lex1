trigger CaseCalculationTrigger on Case (after insert, after update) {
    new CaseCalculationTriggerHandler().run();
}