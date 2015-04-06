$(function() {

  var $form = $("#new_search");
  if ($form.length < 1) {return;}

  // hide all dropdown options
  var allOptions = $form.find('.library-filter-options-list');
  allOptions.hide();

  // show them on click
  $(".library-filter-options-group").on('click', function(ev) {
    var options = $(this).find('.library-filter-options-list');
    allOptions.not(options).hide();
    options.toggle();
  });

  // submit form on filter selections
  $('.library-filter-option').one('click', function(ev) {
    ev.preventDefault();
    $(this).find('input').attr("checked", true);
    $form.submit();
  });

  // submit form on option selections
  $('#content_type, #sort_field').one('change', function(ev) {
    $form.submit();
  });

  // remove active filter buttons
  $('.active-filters-list a').one('click', function(ev) {
    ev.preventDefault();

    var $removeButton = $(this);
    var filterId = $removeButton.data('filter-id');
    var filterType = $removeButton.data('filter-type');

    // uncheck the input associated with this filter id
    var filterSelector = "#search_" + filterType + "s_" + filterId;
    var $filter = $(filterSelector);
    if ($filter.length > 0) {
      $filter.attr("checked", false);
      $removeButton.remove();
      $form.submit();
    } else {
      console.log("failed to find", filterSelector);
    }
  });

  // clear the form
  var $reset = $form.find('input[type=reset]');
  $reset.on('click', function(ev) {
    $('#search_author').val('');
    $('input:checked').attr("checked", false);
    $('#content_type').val(null);
    $form.submit();
  });

});
