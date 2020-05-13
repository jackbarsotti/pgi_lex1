trigger AttachmentConverter on Attachment (before insert) {
   /* for(Attachment a: Trigger.new) {
        if(a.Name.Startswith('QDV')) {
            a.Body = EncodingUtil.base64Decode(a.Body.toString());
        }
    }*/
}