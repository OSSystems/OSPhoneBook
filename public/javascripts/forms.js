function add_fields(container, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g")
    $(container).insert(
        {'bottom' : content.replace(regexp, new_id)}
    );
}

function remove_fields(container) {
    var hidden_field = $(container).previous("input[type=hidden]");
    if (hidden_field) {
        hidden_field.value = '1';
    }
    $(container).up(".field").hide();
}
