public with sharing class DataRetentionScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
		DataRetentionBatch b = new DataRetentionBatch();
		Database.executeBatch(b, 50);
	}
}