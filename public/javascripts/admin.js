
function makePostLink (event) {
  event.preventDefault();
  var target = event.target;
  var message = $(target).attr('confirmation');
  // message is optional - may not require confirmation
  if ( (message == undefined) || confirm(message) ) {
    $('<form method="post" action="' + this.href + '" />')
        .append('<input type="hidden" name="_method" value="post" />')
        .append('<input type="hidden" name="authenticity_token" value="' + AUTH_TOKEN + '" />')
        .appendTo('body')
        .submit();
  }

  return false; 
}

function makeDestroyLink (event) {
  event.preventDefault();
  var target = event.target;
  var message = $(target).attr('confirmation');
  // message is mandatory - we need to confirm before we delete
  if (message == '')
    message = "Are you sure you want to delete this?";
  if ( confirm(message) ) {
    $('<form method="post" action="' + this.href.replace('/delete', '') + '" />')
        .append('<input type="hidden" name="_method" value="delete" />')
        .append('<input type="hidden" name="authenticity_token" value="' + AUTH_TOKEN + '" />')
        .appendTo('body')
        .submit();
  }

  return false; 
}

var Treeview = {
  refresh: function(response) {
    $.tree.focused().refresh();
    Treeview.deletedNodes = [];
    Treeview.shownNodes   = [];
    Treeview.hiddenNodes  = [];
  },
  saveNewPagePlaceholder: function(node, ref_node, type, tree_obj, rollback) {
    
  },
  save: function(e) {
    e.preventDefault();
    var url  = $(e.target).attr('href');
    var data = $.tree.reference('#tree').get();
    var deleted = {pages: [], sections: []};
    deleted = Treeview.addNodes(deleted, Treeview.deletedNodes)
    var data_json = encodeURIComponent(JSON.stringify(data));
    var deleted_json = encodeURIComponent(JSON.stringify(deleted));
    jQuery.ajax({
        type: 'post',
        url: url,
        data: "tree="+data_json+'&deleted='+deleted_json,
        dataType: 'json',
        complete: Treeview.refresh
    });
  },
  addNodes: function(hash, array) {
    for(i=0; i<array.length; i++) {
      var matching = array[i].match(/(page)?\D*_(\d+)/)
      if ((matching) && (matching[1] == 'page')) { // it's a page
        hash.pages.push(matching[2]);
      } else { // it's a section
        hash.sections.push(matching[2]);
      }
    }
    return hash
  },
  newSection: function(e) {
    e.preventDefault();
    var tree = $.tree.reference('#tree')
    var time = new Date().getTime();
    var node = tree.create(
      {
        data: { title: 'New section', attributes: { class: 'hidden' } }, 
        attributes: {id: 'new-section_'+time, rel: 'section'}
      }, 
      -1);
    tree.rename(node);
    // console.log(node);
  },
  newPage: function(e) {
    e.preventDefault();
    var tree = $.tree.reference('#tree')
    if (tree.selected) {
      var time = new Date().getTime();
      var node = tree.create(
        {
          data: { title: 'New page', attributes: { class: 'hidden' } },
          attributes: {id: 'new_page_'+time, rel: 'page'}
        }
      );
      tree.rename(node);
    }
  },
  deletedNodes: [],
  hiddenNodes: [],
  shownNodes: [],
  markDeleted: function(e) {
    e.preventDefault();
    var selected = $.tree.focused().selected;
    if (selected) {
      var node = $($.tree.focused().selected[0]); // selected can potentially be multiple, so jsTree returns an array, even if multi-select is disabled
      var children = $('ul > li', node);
      Treeview.deletedNodes.push(node.attr('id'));
      if (children.length > 0) {
        children.each( function(i) { Treeview.deletedNodes.push($(this).attr('id')) } );
      }
      $.tree.focused().remove();
    }
  },
  markHidden: function() {
    
  },
  markShown: function() {
    
  }
}

function saveNewPagePlaceholder(node, ref_node, type, tree_obj, rollback) {
  if (type == 'after') { // section has other pages, ref_node will be another page
    // ref_node is not the parent, it's the nearest sibling, go up and get the real parent
    var parent_id = $(ref_node).parents('li').attr('id');
  } else if (type == 'inside') { // this is the first page in this 'folder'
    // ref_node may be a section or page
    var parent_id = $(ref_node).attr('id');
  }
  var url = window.location.href + '.js';
  var time = new Date().getTime();
  var title = tree_obj.get_text(node);
  title += ' ' + time; // add timestamp to title for path
  $(node).addClass('updateAfterRename').children('a').addClass('pending');
  var position  = $('#'+parent_id+' ul > li').size();
  jQuery.ajax({
    type: 'post',
    url: url,
    dataType: 'json',
    data: "page[title]="+title+"&page[derive_path_from]="+parent_id+"&page[position]="+position,
    success: function(response) { 
      var href = window.location.href;
      var page_id = response.page.id;
      $(node).attr( { id: "page_"+ page_id} ).children('a').attr({ 'href': href + '/' + page_id });
    }
  });
}

function showPage(argument) {
  $('#loading').hide();
  setEditable();
}

function submitEditable(value, settings) {
  var element = $(this);
  var url = element.attr('rel') + '.js';
  var name = element.attr('name');
  console.log(element.text());
  jQuery.ajax({
    type: 'post',
    url: url,
    data: '_method=put&'+name+"="+value,
    error: function(request, status, error) {
      if (request.status == 403)
        alert("Unable to save this change, please try again.")
    }
  });
  return value;
}

function setEditable() {
	$('.editable').editable( submitEditable, { submit: 'OK', tooltip: 'Click to edit' } );
}

$(function() {
  $('a.link_to_post').live('click', makePostLink );
  $('a.link_to_destroy').live( 'click', makeDestroyLink );
  
  $('a#save_tree').live('click', Treeview.save );
  $('a#new_section').live('click', Treeview.newSection );
  $('a#new_page').live('click', Treeview.newPage );
  $('a#delete_page').live('click', Treeview.markDeleted );
  
  if ($('form textarea#page_content').size() > 0) {
    startEditor('page_content');
  }

  if ($('.datepicker').length > 0)
    $('.datepicker').datepicker();
});



/***** Ready? Aim? Fire! jQuery stuff by Wes *****/

$(document).ready(function() {
  //style and functionality for table rows
    //add .odd to alternating table rows
    $('div#main_content table.dashboard_table tr:odd').addClass("odd");
  
    //hover styling for table rows
    $('div#main_content table.dashboard_table tr').hover(
      function() {
        $(this).addClass("over");
      },
      function() {
        $(this).removeClass("over");
      }
    );
  
    //set click action to anywhere in a table row to go to the url of the a.edit element in that row
    //note: edited to use the td rather than tr in an attempt to remove click-action from header row
    $('div#main_content table.dashboard_table tr td').addClass('pointer').click(
      function(e) {
        var parent_row = $(this).parent();
        var editor_link = $('td a.edit', parent_row);
        var has_edit = editor_link.length > 0;
        if (has_edit)
          document.location.href = editor_link.attr("href");
      }
    );
    
    // Order matters: this section must come after the table-row-link code
    // shouldn't go to the edit action if we clicked on another action icon
    var links = $('div#main_content table.dashboard_table tr td a.edit')
    if (links.length > 0) {
      links.each( function(i) {
        console.log("Removing link from "+$(this).attr('id'));
        $(this).parents('td').removeClass('pointer').unbind('click');
        console.log('done unbinding');
      })
    }
  
  // tabbed content
    var tab_container = $('div.tab_container > div.tab_content');

    $('div.tab_container ul.tab_nav a').click(function () {
        tab_container.hide().filter(this.hash).show();

        $('div.tab_container ul.tab_nav a').removeClass('selected');
        $(this).addClass('selected');

        return false;
    }).filter(':first').click();
  
    //add odd-row class to alternating tabbed-content items
    $('div.tab_container ul.items li.item:odd').addClass("odd");
    
    //tabbed stuff is hidden by default, so that it doesn't display "unstyled" before document.ready fires. Show it now that we're done!
    $('div.tab_container').slideDown();
    
});