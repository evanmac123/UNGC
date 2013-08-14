$(function() {

  // TODO check for a tell-tale element.

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
  var addLinkButton = $('#add_link'),
      linkTable = $('.link_table')
      template = $('#link_template').html();

  linkTable.on('click', function(ev) {
    var target = $(ev.target)
    if(target.attr('class') === 'remove_link') {
      ev.preventDefault();
      target.parents('tr').remove();
    }
  });

  addLinkButton.on('click', function(ev) {
    ev.preventDefault();
    linkTable.append(template);
  });

})
