/**
* JSON API - Error Response 
* See: http://jsonapi.org/examples/#error-objects
*/
public class ErrorResponse{
  public List<Error> errors;

  public ErrorResponse(List<Error> errors){
    this.errors = errors;
  }

  public class Error{
    public Object detail;

    public Error(Object detail){
      this.detail = detail;
    }
  }         
}