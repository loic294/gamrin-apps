using Toybox.WatchUi;
using Toybox.Attention;

class ToggleButtonDelegate extends WatchUi.BehaviorDelegate {
	
	function initialize() {
		BehaviorDelegate.initialize();
	}
	
	function onSelectable(event) {
		var instance = event.getInstance();
		
		if (instance instanceof Toggle) {
			currentToggle.handleEvent(event.getPreviousState());
		}
		
		return true;
	}
	
    
    function onKey(keyEvent) {
    	if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
    		System.println("KEY PRESS");
    		currentView.handleSwipe();
    	}
    	return true;
    
    }
	
}
