$(function() {
  var $form = $(".filters-form");
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

  // Toggle filter lists on click
  $triggers.on('click', function(event) {
    event.preventDefault();
    var $trigger  = $(event.currentTarget),
        $list     = $trigger.data('$list');
    $filterLists.add($triggers).not([event.currentTarget, $list.get(0)]).removeClass('is-active');
    $trigger.add($list).toggleClass('is-active');
  });

  // Submit form on filter and option selections
  $('.filter-option input[type=checkbox], .filter-sorting select', $form).one('change.filters-form', function() {
    window.setTimeout(function() {
      $triggers.add($filterLists);
    }, 100);
    $form.submit();
  });

  // Remove active filter buttons
  $('.remove-active-filter').one('click', function(event) {
    event.preventDefault();

    var $removeButton   = $(this),
        filterId        = $removeButton.data('filter-id'),
        filterType      = $removeButton.data('filter-type'),
        filterSelector  = "#search_" + filterType + "_" + filterId,
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
  $form.find('.clear-all-filters button').on('click.filter-form', function(ev) {
    $('#section-search input[type=search]', $form).val(null);
    $('input[type=checkbox]:checked', $form).prop("checked", false);
    $('.filter-sorting select', $form).val(null);
    $form.submit();
  });

  // sort column & direction
  var $sortField = $('#search_sort_field');
  var $sortDirection = $('#search_sort_direction');

  window.participantSearchChangeSortingField = function(newField) {
    var oldField = $sortField.val();
    var oldDirection = $sortDirection.val();
    var newDirection;

    if(newField === oldField) {
      // toggle direction
      newDirection = toggleSortDirection(oldDirection);
    } else {
      // switching columns, default to ascending
      newDirection = 'asc';
    }

    $sortField.val(newField);
    $sortDirection.val(newDirection);
    $form.submit();
  }

  function toggleSortDirection(direction) {
    if(direction === 'asc') {
      return 'desc';
    } else {
      return 'asc';
    }
  }

  function pluralize(name) {
    var plural;
    switch (name){
    case 'country':
      plural = 'countries';
    break;
    case 'reporting_status':
      plural = 'reporting_statuses';
    break;
    default:
      plural = name + 's';
    }
    return plural;
  }

});
