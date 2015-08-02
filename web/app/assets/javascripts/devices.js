$("a[data-edit-location]").on('click', function(){
  event.preventDefault();
  var deviceId = $(this).attr('data-delete-device');
  var currentValue = $(this).attr('data-location');

  BootstrapDialog.show({
    title: 'Edit location',
    size: BootstrapDialog.SIZE_SMALL,
    message: 'Device location: <input type="text" class="form-control" value="' + currentValue + '" />',
    buttons: [{
      label: 'Cancel',
      action: function(dialogRef) {
        dialogRef.close();
      }
    },
    {
      label: 'Save',
      action: function(dialogRef) {
        var newValue = dialogRef.getModalBody().find('input').val();
      }
    }]
  });
});
