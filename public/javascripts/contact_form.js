Event.observe(document, 'dom:loaded', function() {
    new Autocomplete('company_search_field', {
        serviceUrl: '/company_search',
        minChars: 1,
        maxHeight: 400,
        width: 'auto',
        deferRequestBy: 200
    });
});
