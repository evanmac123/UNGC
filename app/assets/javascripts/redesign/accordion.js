$(function() {
  // Cache elements
  var $container  = $('.accordion-container'),
      $items      = $('.accordion-item', $container),
      $headers    = $('.accordion-item-header', $container);

  // Prepare accordion elements
  $items.each(function() {
    var $item     = $(this),
        $header   = $item.children('.accordion-item-header'),
        $content  = $item.children('.accordion-item-content-wrapper');

    // Set max-height property for $content container
    $content.css('max-height', $content.height());

    // Store a reference to the item in the header object
    $header.data('$item', $item);
  });

  var toggleItem = function($item) {
    var $itemInputs = $('input, textarea, select', $item);

    $item.toggleClass('collapsed');

    if ($item.is('.collapsed')) {
      $itemInputs.not(':disabled').prop('disabled', true).addClass('accordion-disabled');
    }
    else {
      $itemInputs.filter('.accordion-disabled').prop('disabled', false).removeClass('accordion-disabled');
    }
  };

  // Add the collapsed class to items
  toggleItem($items);

  // Bind events to header click
  $headers.on('click.ungcAccordion', function() {
    toggleItem($(this).data('$item'));
  });

  // Set the container to ready
  $container.addClass('accordion-ready');
});
