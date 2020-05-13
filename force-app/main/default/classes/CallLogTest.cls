@IsTest
public class CallLogTest {
    @IsTest
    public static void testTaskUpdate() {
        PGI_Client__c client = new PGI_Client__c();
        insert client;
        Call_Log__c cl = new Call_Log__c();
        insert cl;
        Task t = new Task(WhatId = cl.Id, Subject = 'test');
        insert t;
        cl.PGI_Client__c = client.Id;
        update cl;
        t = [SELECT PGi_Client__c FROM Task];
        System.assertEquals(t.Pgi_Client__c, client.Id);
    }
}