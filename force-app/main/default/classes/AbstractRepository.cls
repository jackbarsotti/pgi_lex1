public with sharing abstract class AbstractRepository {
  public String selectBuilder(String table, String columns, String clauses){
    return 'select '+columns+' from '+table+' '+clauses;
  }  

  public String innerSelectBuilder(String relationTable, String columns, String clauses){
    return ',('+selectBuilder(relationTable,columns,clauses)+')';
  }

  public String relationBuilder(String relationTable, String relationColumns){
    String columns = ','+relationColumns;
    columns = columns.replaceAll('\\,', ','+relationTable+'.');
    return columns;
  }

  public Double findMaxObjectId(String table){
    List<AggregateResult> aggResults = Database.query('SELECT MAX(objectId__c) maxObjectId FROM '+table);
    System.debug('Max objectId__c is: ' + aggResults[0].get('maxObjectId'));  

    return Double.valueOf(aggResults[0].get('maxObjectId'));
  }  
}