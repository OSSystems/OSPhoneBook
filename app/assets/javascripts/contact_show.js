var popupRemovalTimeout;
var dialKeypressBindings = [];

function showRequestFailure(dialog, response) {
  message = "Unable to dial your requested number; Received error was: \n" +
    response.text + "\nPlease contact your administrator.";
  dialog.find(".dialing:not(.hidden) .message").text(message);
  dialog.find(".dialing-close input").value = "Close";
}

function dialPhoneNumber(url, key) {
  var dialogId = "dialing-popup-" + key;
  var dialog = $("#" + dialogId);
  new $.get({
    url: url,
    beforeSend: function() {
      showDialDialog(dialog, "Cancel")
    },
    success: function(responseText, statusText, ajaxObject) {
      if(ajaxObject.status == 0) {
        showRequestFailure(dialog, responseText);
      } else {
        showDialDialog(dialog, "Cancel", responseText);
        popupRemovalTimeout = setTimeout("hideDialDialog()", 5000);
      }
      setUpHotkeys();
    },
    error: function(responseText) {
      showRequestFailure(dialog, responseText);
    }
  });
}

function dialFromElement(element) {
  options = $(element).data();
  dialPhoneNumber(options['phonePath'], options['phoneKey']);
}

function setUpHotkeys() {
  // Remove all previous bindings
  $(dialKeypressBindings).map(function(idx, binding) {
    binding.unbind()
  });
  dialKeypressBindings = [];

  // Clear pressed keys
  $('.hotkey').removeClass('pressed');
  $('.hotkey').removeClass('expect-press');

  $('#phones_numbers .dial-option').each(function() {
    current = $(this)
    options = current.data();
    link = current.find('#phone_' + options['phoneKey'])
    dialKeypressBindings.push(link.click(function() {
      element = $(this).parents('.dial-option');
      dialFromElement(element);
    }));
  });

  // hotkeys for quick dialing:
  dialKeypressBindings.push(jwerty.key('d', function() {
    $('.hotkey.start').addClass('pressed');
    $('.hotkey.activate').addClass('expect-press');

    $('#phones_numbers .dial-option').each(function() {
      current = $(this)
      opts = current.data();
      dialKeypressBindings.push(jwerty.key(opts['phoneKey'], function(event) {
        options = $('#dial-option-' + event.key).data();
        dialPhoneNumber(options['phonePath'], options['phoneKey']);
      }));
    });

    dialKeypressBindings.push($('#phones_numbers').click(function() {
      setUpHotkeys();
    }));

    setTimeout("setUpHotkeys()", 4000);
  }));
}

function hideDialDialog() {
  var divBackground = $('.dialing');
  divBackground.addClass('hidden');
  clearTimeout(popupRemovalTimeout);
  $('.close-popup-button').unbind();
}

function showDialDialog(dialog, buttonCaption, newMessage) {
  message = dialog.find(".message")
  if (typeof newMessage === 'undefined') {
    newMessage = message.data('original-message');
  }
  message.text(newMessage);
  closeButton = dialog.find(".close-popup-button");
  closeButton.value = buttonCaption;
  hideDialDialog();

  // remove pop-up when canceling
  closeButton.click(function(event) {
    hideDialDialog();
  });

  dialog.removeClass('hidden');
  closeButton.focus();
}

$(document).ready(function() {
  $('#phones_numbers .dial-option').each(function() {
    option = $(this).data()
    key = option['phoneKey'];
    $('#phone_' + key).prop('href', 'javascript:void(0)');
  });
  setUpHotkeys();
});
