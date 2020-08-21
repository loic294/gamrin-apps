//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Application;
using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;

var strings = "";
var phoneMethod;
var crashOnMessage = false;
var hasDirectMessagingSupport = true;

class CommExample extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();

        phoneMethod = method(:onPhone);
        if(Communications has :registerForPhoneAppMessages) {
            Communications.registerForPhoneAppMessages(phoneMethod);
        } else {
            hasDirectMessagingSupport = false;
        }
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new CommView(), new CommInputDelegate()];
    }

    function onPhone(msg) {
        var i;

        if((crashOnMessage == true) && msg.data.equals("Hi")) {
            msg.length(); // Generates a symbol not found error in the VM
        }

        strings = msg.data.toString();
    
        WatchUi.requestUpdate();
    }

}