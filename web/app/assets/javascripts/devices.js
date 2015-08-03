$("a[data-edit-location]").on('click', function(){
  event.preventDefault();
  var deviceId = $(this).attr('data-delete-device');
  var currentValue = $(this).attr('data-location');
  var url = $(this).attr('href');

  BootstrapDialog.show({
    title: 'Edit location',
    size: BootstrapDialog.SIZE_SMALL,
    message: 'Device location: <input type="text" class="form-control" value="' + currentValue + '" />',
    onshow: function(dialog) {
      setTimeout(function(){dialog.getModalBody().find('input').select();}, 520);
    },
    buttons: [{
      label: 'Cancel',
      action: function(dialogRef) {
        dialogRef.close();
      }
    },
    {
      label: 'Save',
      hotkey: 13,
      action: function(dialogRef) {
        var newValue = dialogRef.getModalBody().find('input').val();
        $("#editLocation").attr("action", url);
        $("#editLocation > input[name='device[location]']").val(newValue);
        $("#editLocation").submit();
      }
    }]
  });
});
