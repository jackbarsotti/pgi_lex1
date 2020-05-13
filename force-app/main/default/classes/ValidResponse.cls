/**
* JSON API - Response 
* See: http://jsonapi.org/examples
*/
public class ValidResponse{    
  public Object data;

  public ValidResponse(Object d){
    this.data = d;
  }

  public class Data{
    public boolean success;

    public Data(boolean success){
      this.success = success;
    }
  }  
}