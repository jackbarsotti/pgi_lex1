public class ClassicChatterFeedController {
    public ClassicChatterFeedController() {
        System.debug('The value is'+ApexPages.currentPage().getParameters().get('id'));
    }
}