public with sharing class WaitDialog{

    private String header;
    private String status;
    private String button;
    private String cancelButton;
    private String additionalInfo;
    private String clickCommand;
    private String cancelClickCommand;
    private boolean shouldRenderCancelButton;
    private boolean shouldRender;
    private boolean shouldRenderForm;

    public WaitDialog() {
        this.header = '';
        this.status = '';
        this.button = '';
        this.cancelButton = '';
        this.additionalInfo = '';
        this.shouldRender = false;
        this.shouldRenderForm = false;
        this.shouldRenderCancelButton = false;
    }

    public String getHeader() {
        return this.header;
    }

    public void setHeader(String header) {
        this.header = header;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getButton() {
        return this.button;
    }

    public void setButton(String button) {
        this.button = button;
    }
    
    public String getCancelButton() {
        return this.cancelButton;
    }

    public void setCancelButton(String cancelButton) {
        this.cancelButton = cancelButton;
    }

    public String getAdditionalInfo() {
        return this.additionalInfo;
    }

    public void setAdditionalInfo(String additionalInfo) {
        this.additionalInfo = additionalInfo;
    }
    
    public boolean getShouldRender() {
        return this.shouldRender;
    }
    
    public void setShouldRender(boolean shouldRender) {
        this.shouldRender = shouldRender;
    }
    
    public boolean getShouldRenderCancelButton() {
        return this.shouldRenderCancelButton;
    }
    
    public void setShouldRenderCancelButton(boolean shouldRenderCancelButton) {
        this.shouldRenderCancelButton = shouldRenderCancelButton;
    }
    
    public boolean getShouldRenderForm() {
        return this.shouldRenderForm;
    }
    
    public void setShouldRenderForm(boolean shouldRenderForm) {
        this.shouldRenderForm = shouldRenderForm;
    }
    
    public String getClickCommand() {
        return this.clickCommand;
    }
    
    public void setClickCommand(String clickCommand) {
        this.clickCommand = clickCommand;
    }
    
    public String getCancelClickCommand() {
        return this.cancelClickCommand;
    }
    
    public void setCancelClickCommand(String cancelClickCommand) {
        this.cancelClickCommand = cancelClickCommand;
    }
}