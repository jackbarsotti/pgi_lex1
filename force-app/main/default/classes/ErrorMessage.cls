public class ErrorMessage {
  private Id id; 
  private String message;
  
  public void setId(Id id) {
    this.id = id;
  }
  
  public Id getId() {
    return this.id;
  }
  
  public void setMessage(String message) {
    this.message = message;   
  }
  
  public String getMessage() {
    return this.message;
  }
}