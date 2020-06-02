$(document).ready(function() {
  updateFields();
  $('#required_operator_document_type_input').on('change', function(){
    updateFields();
  })
  $('#required_operator_document_country_id').on('change', function(){
    updateFields();
  })
})

function updateFields() {
  const countryList = {
    53: [4, 5],
    45: [1, 2, 3]
  }
  var type = $('#required_operator_document_type').val();
  var forestTypes = $('#required_operator_document_forest_types');
  var country = $('#required_operator_document_country_id').val();

  if (type === 'RequiredOperatorDocumentFmu') {
    if (country in countryList) {
      forestTypes.prop('disabled', false);
      forestTypes.parent().show();

      console.log(countryList[country])
      Array.from(forestTypes.select2({width: '80%'})[0].options).forEach( op => {
        if (countryList[country].includes(parseInt(op.value))) {
          $(op).prop('disabled', false);
        } else {
          $(op).prop('disabled', true);
        }
      })
      forestTypes.val([])
      forestTypes.select2({width: '80%'}).trigger('change')
     }
  } else
  {
    forestTypes.prop('disabled', true);
    forestTypes.parent().hide();
  }
}