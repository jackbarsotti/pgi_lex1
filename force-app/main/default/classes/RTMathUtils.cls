public with sharing class RTMathUtils {
    
    public static Double getRandomBetween(Double minValue, Double maxValue) {
        return minValue+(Math.random()*(maxValue-minValue));
    }
}