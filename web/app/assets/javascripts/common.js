$.rails.allowAction = function(link) {
  var message = link.attr('data-confirm');
  if (!message) { return true; }

  BootstrapDialog.confirm({
    title: 'Danger',
    message: message,
    type: BootstrapDialog.TYPE_DANGER,
    callback: function(result) {
      if(result) { $.rails.confirmed(link); }
    }
  });
  return false;
}

$.rails.confirmed = function(link) {
  link.removeAttr('data-confirm');
  link.trigger('click.rails');
}
