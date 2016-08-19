function add_fields(container, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  content = content.replace(regexp, new_id)
  content = $('<textarea/>').html(content).text();
  container.append(content);
}

function remove_fields(container) {
  var hidden_field = container.prev("input[type=hidden]");
  if (hidden_field) {
    hidden_field.val('true');
  }
  $(container).parents(".field").addClass('hidden');
}

$(document).ready(function() {
  $('body').on('click', 'form a.insert_fields', function() {
    data = $(this).data();
    container = $('#' + data['containerId']);
    association = data['method'];
    content = data['content'];
    add_fields(container, association, content);
  });

  $('body').on('click', 'form a.remove_fields', function() {
    remove_fields($(this));
  });
});
