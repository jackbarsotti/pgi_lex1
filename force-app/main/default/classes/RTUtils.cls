public with sharing class RTUtils {
  public static boolean dateInRange(Date d, Date startDate, Date endDate, boolean inclusiveStart, boolean inclusiveEnd){
    boolean inDateRange = false;
    Integer compStart, compEnd;

    compStart = startDate.daysBetween(d);

    if (endDate == null)
      compEnd = -1;
    else
      compEnd = endDate.daysBetween(d);

    // If the date 'd' is after, or equals the passed in start
    // date and
    // the date 'd' is before, the passed in end date, then it's
    // in the date range.
    if (inclusiveStart && !inclusiveEnd) {
      if (compStart >= 0 && compEnd < 0)
        inDateRange = true;
    } else if (!inclusiveStart && inclusiveEnd) {
      if (compStart >= 0 && compEnd <= 0)
        inDateRange = true;
    } else if (inclusiveStart && inclusiveEnd) {
      if (compStart >= 0 && compEnd <= 0)
        inDateRange = true;
    } else if (!inclusiveStart && !inclusiveEnd) {
      if (compStart > 0 && compEnd < 0)
        inDateRange = true;
    }

    return inDateRange;    
  }

  public static boolean dateInRange(Date d, Date startDate, Date endDate){
    if(startDate <= d && (endDate == null || endDate >= d))
      return true;
    else
      return false;
  }

  /**
  * Returns true if d1 is before d2
  */
  public static boolean dateIsBefore(Date d1, Date d2){
    if(d1.daysBetween(d2) > 0)
      return true;

    return false;
  }

  /**
  * Returns the formated date given Date d, alternateIfNull otherwise.
  */
  public static String formatDateSafe(Date d, String alternateIFNull){
    if(d==null)
      return alternateIFNull;
    
    return d.format();
  }
}