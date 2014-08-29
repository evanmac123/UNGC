$(function() {
  if($('fieldset.contribution_levels')) {
    var addButton = $('#add-contribution-level'),
        table = $('#contribution-levels-table tbody'),
        template = $('#contribution-level-template').html();

    table.on('click', function(ev) {
      var target = $(ev.target)
      if(target.hasClass('remove')) {
        ev.preventDefault();
        target.parents('tr').remove();
      }
    })

    addButton.on('click', function(ev) {
      ev.preventDefault()
      table.append(template);
    });
  }
})
