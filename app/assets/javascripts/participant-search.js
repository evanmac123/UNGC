$(function() {
  var $form = $("#filters-form");
  var $sortHeaders = $('.participants-table .sort-direction-toggle');

  $sortHeaders.one('click', function(e) {
    e.preventDefault();
    var sortField = $(this).data('field');

    // see app/assets/javascripts/filters-form.js
    participantSearchChangeSortingField(sortField);
  });

});
