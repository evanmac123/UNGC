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

  // Add the collapsed class to items
  $items.addClass('collapsed');

  // Bind events to header click
  $headers.on('click.ungcAccordion', function() {
    $(this).data('$item').toggleClass('collapsed');
  });

  // Set the container to ready
  $container.addClass('accordion-ready');
});
