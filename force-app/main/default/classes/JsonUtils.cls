public with sharing class JsonUtils {
  
  public static String getJsonValue(Object o, String s) {
    return (String) ((Map<String, Object>)o).get(s);
  }
  
}