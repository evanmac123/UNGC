$(function() {
  var $form = $("#new_search");
  if ($form.length < 1) {return;}

  // Cache relevant elements
  var $triggers     = $form.find('.filter-options-list-trigger'),
      $filterLists  = $triggers.siblings('.filter-options-list');

  // Cache associated filter list as data attribute of trigger
  $triggers.each(function(){
    var $trigger = $(this);
    $trigger.data('$list', $filterLists.filter(function(){
      return $(this).data('filter') === $trigger.data('filter');
    }));
  });

  // show them on click
  $triggers.on('click', function(event) {
    event.preventDefault();
    var $trigger  = $(event.currentTarget),
        $list     = $trigger.data('$list');
    $filterLists.add($triggers).not([$trigger, $list]).removeClass('is-active');
    $trigger.add($list).toggleClass('is-active');
  });

  // submit form on filter selections
  $('.filter-option input').one('change', function(ev) {
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
