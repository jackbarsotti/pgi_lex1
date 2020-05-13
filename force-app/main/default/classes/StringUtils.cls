public with sharing class StringUtils {

  public static Decimal decimalValueOf(String s) {
    try {
      Decimal d = Decimal.valueOf(s);
      d.setScale(4);
      return d;
    }
    catch(Exception e) {
      return null;
    }
  }
  
  public static String nullIfEmpty(String s) {
    if(s==null)
      return null;
    else if(s=='null')
      return null;
    else
      return s.trim().length() == 0 ? null : s.trim();
  }
  
  public static boolean equals(String s1, String s2) {
    if(s1==null && s2==null)
      return true;
    
    if (s1==null || s2==null)
      return false;
    
    return s1.equals(s2);
  }

}