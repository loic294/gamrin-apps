using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.Attention;
using Toybox.Application.Storage;

var currentView = null;
var currentToggle = null;
var dcView;

var devices;


class Toggle extends WatchUi.Selectable {
	
	var stateHighlightedSelected;
	var openAction;
	var closeAction;
	var deviceName;

    function initialize(options) {
    
    	currentToggle = self;
    
        Selectable.initialize(options);
        
        openAction = options.get("openAction");
        closeAction = options.get("closeAction");
        deviceName = options.get("deviceName");
        
        if (Storage.getValue(deviceName)) {
        	setState(:stateSelected);
        } else {
        	setState(:stateDefault);
        }
    }
    
    function handleEvent(previousState) {
    	System.println("CLICK OCCURED");
    
        if(getState() == :stateHighlighted) {
            highlight(previousState);
        }
        else if(getState() == :stateSelected) {
            select(previousState);
        }
        else if(getState() == :stateDefault) {
            reset(previousState);
        }
    }

    //! Special case - handle unhighlighting of a CheckBox
    function unHighlight() {
        // If we were highlighted, returnt to default state
        if(getState() == :stateHighlighted) {
            setState(:stateDefault);
            System.println("SET OFF 2");
        }
        // If were were highlighted/selected, move to selected state
        else if(getState() == :stateHighlightedSelected) {
            setState(:stateSelected);
            System.println("SET ON 1");
        }
    }

    //! Handle onSelectable() returning stateDefault
    function reset(previousState) {
        // If we were highlighted/selected, or selected, move to selected state
        // We only return to the unchecked state if selected again
        if(previousState == :stateSelected) {
            setState(:stateSelected);
        }
        else if(previousState == :stateHighlightedSelected) {
            setState(:stateSelected);
            System.println("SET ON 2");
            // Open light here
            Storage.setValue(deviceName, true);
            makeRequest(openAction);
        }
    }

    //! Handle onSelectable() returning stateHighlighted
    function highlight(previousState) {
        // If we were selected, move to highlighted/selected state,
        // otherwise stay in the highlighted state
        if(previousState == :stateSelected) {
            setState(:stateHighlightedSelected);
        }
    }

    //! Handle onSelectable() returning stateSelected
    function select(previousState) {
        // If we were highlighted, move to highlighted/selected state ("checked")
        if(previousState == :stateHighlighted) {
            setState(:stateHighlightedSelected);
        }
        // If were were highlighted/selected state, move to highlighted state
        else if(previousState == :stateHighlightedSelected) {
            setState(:stateHighlighted);
            System.println("SET OFF 3");
            // Close light here
            Storage.setValue(deviceName, false);
            makeRequest(closeAction);
        }
        // If we were selected, move to default state ("unchecked")
        else if(previousState == :stateSelected) {
            setState(:stateDefault);
            System.println("SET OFF 1");
        }
    }
    
    function vibrate() {
    	if (Attention has :vibrate) {
		    var vibeData =
		    [
		        new Attention.VibeProfile(75, 100)
		    ];
		    Attention.vibrate(vibeData);
		}
		
    }
    
    
   // set up the response callback function
   function onReceive(responseCode, data) {
       if (responseCode == 200) {
           System.println("Request Successful");                   // print success
       }
       else {
           System.println("Response: " + data);            // print response code
       }
       
   }

   function makeRequest(action) {
   		vibrate();
   
       var url = "https://maker.ifttt.com/trigger/" + action + "/with/key/bzYHT3QslSuDMD0PE90VfG";  
      
      System.println("URL: " + url);
      
      var params = {};


       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_POST,      // set HTTP method
           :headers => {                                           // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
                                                                   // set response type
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN 
       };

       var responseCallback = method(:onReceive);                  // set responseCallback to
                                                                   // onReceive() method
       // Make the Communications.makeWebRequest() call
       Communications.makeWebRequest(url, params, options, responseCallback);
       
     }
	
}


class ToggleView {
	hidden var items;
	
	function initialize(dc, index) {
		var device = devices[index];
		renderItem(dc, device);
	}
	
	function renderItem(dc, device) {
		var toggleDefault = new WatchUi.Bitmap({:rezId=>Rez.Drawables.toggleOff});
		var toggleOn = new WatchUi.Bitmap({:rezId=>Rez.Drawables.toggleOn});
		
		var dims = toggleDefault.getDimensions();

        var initY = 30;
        var initX = (dc.getWidth() / 2) - (180 / 2);       
        
        var options = {
        	:width => 180,
        	:height => 180,
        	:locX => initX,
        	:locY =>initY,
            :stateDefault=>toggleDefault,
            :stateHighlighted=>toggleDefault,
            :stateSelected=>toggleOn,
            :stateDisabled=>toggleDefault,
            "openAction" => device.get("open"),
            "closeAction" => device.get("close"),
            "deviceName" => device.get("name")
        };
	
		var toggle = new Toggle(options);
		
		
		var text = new WatchUi.TextArea({
            :text=> device.get("name"),
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
            :width=>dc.getWidth(),
            :height=>50,
            :justification => Graphics.TEXT_JUSTIFY_CENTER
        });
		
		
		items = new [2];
		
		items[0] = toggle;
		items[1] = text;
	}
	
	function getItems() {
		return items;
	}

}


class ToogleButtonView extends WatchUi.View {

	var toggles = null;
	var currentIndex = 0;
	var deviceCount = 4;
	var localDc = null;
	
	function initialize() {
		View.initialize();
		currentView = self;
		
		devices = new [deviceCount];
		
		devices[0] = {
			"name" => "Bureau",
			"open" => "open_bureau",
			"close" => "close_bureau"
		};
		devices[1] = {
			"name" => "Table de chevet",
			"open" => "open_table_de_chevet",
			"close" => "close_table_de_chevet"
		};
		devices[2] = {
			"name" => "Salon",
			"open" => "open_salon",
			"close" => "close_salon"
		};
		devices[3] = {
			"name" => "Toutes les lumières",
			"open" => "open_chambre",
			"close" => "close_chambre"
		};
		
	}
	
	function onLayout(dc) {
		localDc = dc;
		var toggleView = new ToggleView(dc, 0); 
		setLayout(toggleView.getItems());
	}
	
	function onUpdate(dc) {
		View.onUpdate(dc);
	}
	
	function handleSwipe() {

		if (currentIndex == deviceCount - 1) {
			currentIndex = 0;
		}	else {
			currentIndex += 1;
		}
    	
    	System.println("CURR INDEX: " + currentIndex);
    	var toggleView = new ToggleView(localDc, currentIndex); 
		setLayout(toggleView.getItems());
		WatchUi.requestUpdate();
    }

}