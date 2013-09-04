$(function() {
  if($('form.edit_resource')) {

    // authors
    var addAuthorButton = $('#add_author'),
        authorTable = $('.author_table')
        authorTemplate = $('#author_template').html();

    authorTable.on('click', function(ev) {
      var target = $(ev.target)
      if(target.attr('class') === 'remove_author') {
        ev.preventDefault();
        target.parents('tr').remove();
      }
    });

    addAuthorButton.on('click', function(ev) {
      ev.preventDefault();
      authorTable.append(authorTemplate);
    });

    // links
    var addLinkButton = $('#add_link'),
        linkTable = $('.link_table'),
        linkTemplate = $('#link_template').html();

    linkTable.on('click', function(ev) {
      var target = $(ev.target)
      if(target.hasClass('remove_link')) {
        ev.preventDefault();
        target.parents('tr').remove();
      }
    })

    addLinkButton.on('click', function(ev) {
      ev.preventDefault()
      linkTable.append(linkTemplate);
    });
  }
})
