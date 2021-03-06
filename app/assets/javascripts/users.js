$(document).ready(function() {
  updateFields();
  $('#user_user_permission_attributes_user_role').on('change', function(){
    updateFields();
  })
})

function updateFields() {
  var userRole = $('#user_user_permission_attributes_user_role').val();
  var observerInput = $('#user_observer_id');
  var operatorInput = $('#user_operator_id');
  var holdingInput = $('#user_holding_id');

  switch (userRole) {
    case 'holding':
      holdingInput.prop('disabled', false);
      holdingInput.parent().show();
      observerInput.prop('disabled', true);
      observerInput.parent().hide();
      operatorInput.prop('disabled', true);
      operatorInput.parent().hide();
      break;
    case 'ngo':
    case 'ngo_manager':
      holdingInput.prop('disabled', true);
      holdingInput.parent().hide();
      observerInput.prop('disabled', false);
      observerInput.parent().show();
      operatorInput.prop('disabled', true);
      operatorInput.parent().hide();
      break;
    case 'operator':
      holdingInput.prop('disabled', true);
      holdingInput.parent().hide();
      observerInput.prop('disabled', true);
      observerInput.parent().hide();
      operatorInput.prop('disabled', false);
      operatorInput.parent().show();
      break;
    case 'admin':
    case 'user':
      observerInput.prop('disabled', true);
      observerInput.parent().hide();
      operatorInput.prop('disabled', true);
      operatorInput.parent().hide();
      holdingInput.prop('disabled', true);
      holdingInput.parent().hide();
      break;
  }
}
