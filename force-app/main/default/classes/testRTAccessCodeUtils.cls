@isTest
private class testRTAccessCodeUtils {
    static testMethod void testGetNewAccessCode() {
        String p1 = '(303) 555-1756';
        String p2 = '3035551756';
        String p3 = '(303) 5551756';
        String p4 = '0113035551756';
        String p5 = '555175';
        String p6 = '9999997';
                
        System.assert(RTAccessCodeUtils.getNewAccessCode(p1) == '5551756');        
        System.assert(RTAccessCodeUtils.getNewAccessCode(p2) == '5551756');
        System.assert(RTAccessCodeUtils.getNewAccessCode(p3) == '5551756');
        System.assert(RTAccessCodeUtils.getNewAccessCode(p4) == '5551756');
        System.assert(RTAccessCodeUtils.getNewAccessCode(p5) != '555175');
        System.assert(RTAccessCodeUtils.getNewAccessCode(p6) == '9999997');

        System.assert(!RTAccessCodeUtils.getNewAccessCode('0000000').startsWith('0'));
        System.assert(!RTAccessCodeUtils.getNewAccessCode('0015243').startsWith('0'));
        System.assert(!RTAccessCodeUtils.getNewAccessCode('0295243').startsWith('0'));
        System.assert(!RTAccessCodeUtils.getNewAccessCode('0113030 551756').startsWith('0'));
        System.assert(!RTAccessCodeUtils.getNewAccessCode('300293243').startsWith('0'));
    }
}