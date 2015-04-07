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
    $filterLists.add($triggers).not([event.currentTarget, $list.get(0)]).removeClass('is-active');
    $trigger.add($list).toggleClass('is-active');
  });

  // Submit form on filter and option selections
  $('.filter-option input[type=checkbox], #filter-content-type, #filter-sort-order').one('change', function() {
    window.setTimeout(function() {
      $triggers.add($filterLists).removeClass('is-active');
    }, 100);
    $form.submit();
  });

  // Remove active filter buttons
  $('.remove-active-filter').one('click', function(event) {
    event.preventDefault();

    var $removeButton   = $(this),
        filterId        = $removeButton.data('filter-id'),
        filterType      = $removeButton.data('filter-type'),
        filterSelector  = "#search_" + filterType + "s_" + filterId,
        $filter         = $(filterSelector);

    // Uncheck the input associated with this filter id
    if ($filter.length > 0) {
      $filter.prop("checked", false);
      $removeButton.parent().addClass('removing');
      $form.submit();
    } else {
      console.log("failed to find", filterSelector);
    }
  });

  // clear the form
  var $reset = $form.find('input[type=reset]');
  $reset.on('click', function(ev) {
    $('#search_author').val(null);
    $('input:checked').prop("checked", false);
    $('#content-type').val(null);
    $form.submit();
  });

});
