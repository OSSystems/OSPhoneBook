Event.observe(document, 'dom:loaded', function() {
    if(document.location.pathname != "/") {
        Hotkeys.bind('s', function() {
            window.location.href = '/';
        });
    }
});
