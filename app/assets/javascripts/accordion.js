$(function() {
  // Cache elements
  var $container  = $('.accordion-container'),
      $items      = $('.accordion-item', $container),
      $headers    = $('.accordion-item-header', $container);

  // Prepare accordion elements
  $items.each(function() {
    var $item             = $(this),
        $inputsWithErrors = $('.field_with_errors', $item),
        $header           = $item.children('.accordion-item-header'),
        $content          = $item.children('.accordion-item-content-wrapper');

    // Set max-height property for $content container
    $content.css('max-height', $content.height());

    // Add class to items which contain inputs with errors
    if ($inputsWithErrors.length) {
      $item.addClass('contains-inputs-with-errors');
    }

    // Store a reference to the item in the header object
    $header.data('$item', $item);
  });

  var toggleItem = function($item) {
    var $itemInputs = $('input, textarea, select', $item);

    $item.toggleClass('collapsed');

    if ($item.is('.collapsed')) {
      $itemInputs.not('.accordion-disabled').addClass('accordion-disabled');
    }
    else {
      $itemInputs.filter('.accordion-disabled').removeClass('accordion-disabled');
      $itemInputs.first().focus();
    }
  };

	function setDefaultItemState() {
		// Collapse items on load
		// leaving the default parent and child open
		// unless they contain inputs with errors
		var defaults = $container.data('accordion-defaults') || "1,1";
		var defaultIndexes = defaults.split(',').map(function(indexStr) {
			return parseInt(indexStr, 10);
		});

		var parentIndex = defaultIndexes[0] || 1;
		var childIndex = defaultIndexes[1] || 1;

		var itemsToCollapse = $items.not(itemsToOpen(parentIndex, childIndex));
		toggleItem(itemsToCollapse);
	}

	function itemsToOpen(parentIndex, childIndex) {
		// NB the index values are 1-based

		var items = [];

		var enableOpeningDefaultsItems = false; // disable the feature for now
		if (enableOpeningDefaultsItems) {

			// open the parent at parentIndex and it's child at childIndex
			var parentItem = '.accordion-item:not(.accordion-child):nth-child(' + parentIndex + ')';
			var childItem = parentItem + ' .accordion-child:nth-child(' + childIndex + ')';

			items.push(parentItem);
			items.push(childItem);
		}

		items.push('.contains-inputs-with-errors');
		items.push('.fields-required');

		return items.join(', ');
	}

	setDefaultItemState();


  // Bind events to header click
  $headers.on('click.ungcAccordion', function() {
    toggleItem($(this).data('$item'));
  });

  // Set the container to ready
  $container.addClass('accordion-ready');
});
