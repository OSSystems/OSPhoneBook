function add_childs(container, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g")
    $(container).insert(
        {'bottom' : content.replace(regexp, new_id)}
    );
}

function remove_childs(link) {
    var hidden_field = $(link).previous("input[type=hidden]");
    if (hidden_field) {
        hidden_field.value = '1';
    }
    $(link).up(".child").hide();
}
