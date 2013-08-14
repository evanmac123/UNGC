$(function() {
  if($('form.edit_resource')) {

    // authors
    var addAuthorButton = $('#add_author'),
        authorTable = $('.author_table')
        template = $('#author_template').html();

    authorTable.on('click', function(ev) {
      var target = $(ev.target)
      if(target.attr('class') === 'remove_author') {
        ev.preventDefault();
        target.parents('tr').remove();
      }
    });

    addAuthorButton.on('click', function(ev) {
      ev.preventDefault();
      authorTable.append(template);
    });

    // links
    var linkTable = $('.link_table');
    linkTable.on('click', function(ev) {
      var target = $(ev.target)
      if(target.attr('class') === 'delete_link') {
        ev.preventDefault();

        $.ajax({
          url: target.attr('href') + '.json',
          dataType: 'json',
          type: 'delete',
          success: function() {
            target.parents('tr').remove();
          }
        });

        return false;
      }
    })

  }
})
