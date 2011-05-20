var popup_hide_timeout;

function requestFailure(response) {
    $("dialing-message").update("Unable to dial your requested number; Please contact your administrator.");
    $$("#dialing-close input")[0].value = "Close";
}

function dialPhoneNumber(url, dialingMessage) {
    new Ajax.Request(url, {
        method: 'get',
        onCreate: function(response) {
            $("dialing-message").update(dialingMessage);
            $$("#dialing-close input")[0].value = "Cancel"
	    Element.show('dialing-background');
        },
        onSuccess: function(response) {
            // Prototype fires this callback even when there is a comm failure
            // between the browser and the server. So, use the response status
            // to assume it is a failure:
            if(response.status == 0) {
                requestFailure(response);
            } else {
                $("dialing-message").update(response.responseText);
                $$("#dialing-close input")[0].value = "Close"
	        popup_hide_timeout = setTimeout("Element.hide('dialing-background')",5000);
            }
        },
        onFailure: function(response) {
            requestFailure(response);
        }
    });
}

Event.observe(document, 'dom:loaded', function() {
    // close pop-up when canceling
    Event.observe($("dialing-close"), "click", function respondToClick(event) {
        clearTimeout(popup_hide_timeout);
        Element.hide('dialing-background');
    });
});
