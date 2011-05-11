Event.observe(document, 'dom:loaded', function() {
    new Autocomplete('search_field', {
        serviceUrl: '/search',
        minChars: 1,
        maxHeight: 400,
        width: 'auto',
        deferRequestBy: 100,
        onSelect: function(value, data) {window.location.href = data[0];}
    });

    $('search_field').focus();
});
