Event.observe(document, 'dom:loaded', function() {
    new Autocomplete('search_field', {
        serviceUrl: '/search',
        minChars: 1,
        maxHeight: 400,
        width: 'auto',
        deferRequestBy: 200,
        onSelect: function(value, data) {window.location.href = data[0];}
    });

    $('search_field').observe('keypress', function(e) {
        if (e.keyCode == Event.KEY_RETURN) {
            ac = Autocomplete.getInstance('search_field');
            if (ac.data.size() > 0) {
                window.location.href = ac.data[0][0];
            }
        }
    });


    $('search_field').focus();
});
