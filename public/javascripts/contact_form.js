Event.observe(document, 'dom:loaded', function() {
    new Autocomplete('company_search_field', {
        serviceUrl: '/company_search',
        minChars: 1,
        maxHeight: 400,
        width: 390,
        deferRequestBy: 200,
        onSelect: function(value, data) {
            var element = $('company_search_field');
            var form = element.form;
            var next_id = 0;
            for (var i = 0; i < form.elements.length; i++) {
                if (form.elements[i] == element) {
                    next_id = i + 1;
                }
            }
            var next_element = form.elements[next_id];
            if (next_element) {
                next_element.focus();
            }
        }
    });
});
