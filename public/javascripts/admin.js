// Array Remove - By John Resig (MIT Licensed)
Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

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

// Really only used when creating new folders
var Folder = {
  rename: function(element, tree) {
    // TODO: Should "freeze" other actions until this is done
    var name = tree.get_text(element);
    var url = window.location.pathname + '/create_folder.js';
    jQuery.ajax({
      type: 'post',
      url: url,
      dataType: 'json',
      data: "&name="+name,
      success: function(data) {
        var folder = data.page_group;
        element.attr({id: "section_"+folder.id});
        tree.select_branch(element);
      }
    });
  }
}

var Page = {
  selected: null,
  hasBeenChanged: null,
  attributes: {},
  id: null,
  parent_id: null,
  editor: null,
  approved: null,
  editMode: null,
  approveAndSave: function(e) {
    Page.approved = true;
    Page.saveChanges(e);
  },
  dynamicallyLoad: function(node) {
    var url = $(node).children('a').attr('href');
    if (url != '') {
      $('#loading').show();
      var area = $('#pageArea');
      area.addClass('loading');
      url += '.js';
      jQuery.ajax({
        type: 'get',
        url: url,
        dataType: 'script',
        success: function() {
          Page.launchEditor();
          Treeview.showPage();
          area.removeClass('loading');
        }
      });
    }
  },
  gatherData: function(e) {
    $('#pageArea').addClass('loading');
    if (Page.id) {
      // this is an update
      var url = $(e.target).attr('href') + '.js';
      var data = '_method=put';
    } else {
      var url = window.location.pathname + '.js';
      var data = '';
    }
    if (Page.approved)
      data += '&approved=true';
    for (var key in Page.attributes) {
      data += '&page['+key+']='+encodeURIComponent(Page.attributes[key]);
    }
    if (Page.editor && Page.editor.checkDirty()) {
      var content = Page.editor.getData();
      data += '&page[content]='+encodeURIComponent(content);
    }
    return({data: data, url: url});
  },
  finishedSaving: function(response) {
    if (Page.editMode) {
      var url = window.location.pathname;
      var id = response.id;
      url = url.replace(/\/\d+\/edit/, '/'+id+'/edit');
      window.location.href = url;
    } else {
      console.log("not using edit mode");
      Page.updateNode(response); // needs to happen before Page.selected is cleared
      Page.initialize(Page.selected);
      $('#pageArea').removeClass('loading');
    }
  },
  hasChanges: function() {
    if (Page.selected) {
      if (Page.hasBeenChanged)
        return true
      if (Page.approved)
        return true;
      if (Page.editor)
        return Page.editor.checkDirty();
    }
    return false;
  },
  idForPage: function(element) {
    var id = element.attr('id');
    var matching = id.match(/(page)?\D*_(\d+)/);
    var page_id = null;
    if ((matching) && (matching[1] == 'page')) { // it's a page
      page_id = matching[2];
    }
    return page_id;
  },
  initialize: function(element) {
    if (Page.editor) {
      $('#pageReplace form').hide()
      Page.editor.destroy();
    }
    Page.selected = element;
    Page.dynamicallyLoad(element);
    element = $(element);
    Page.approved = null;
    Page.hasBeenChanged = null;
    Page.attributes = {};
    var page_id = Page.idForPage(element);
    if (page_id)
      Page.id = page_id;
  },
  launchEditor: function() {
    // e.preventDefault();
    Page.editor = startEditor('page_content');
  },
  newPageCreated: function(node, ref_node, type, tree_obj) {
    Page.storeParent(node, ref_node, type);
    Page.selected = node;
    $(node).addClass('updateAfterRename').children('a').addClass('pending'); // Pending on the child refers to the approval status of the page
    tree_obj.rename(node);
  },
  saveChanges: function(e) {
    e.preventDefault();
    if (!Page.hasChanges())
      return;
    var options = Page.gatherData(e);
    Page.saveViaAjax(options);
  },
  saveViaAjax: function(options) {
    var url  = options.url;
    var data = options.data;
    jQuery.ajax({
      type: 'post',
      url: url,
      data: data,
      dataType: 'json',
      success: function(response) { Page.finishedSaving(response) },
      error: function(request, status, error) {
        $('#pageArea').removeClass('loading');
        if (request.status == 403)
          alert("Unable to save changes, please try again.")
      }
    });
  },
  select: function(element) {
    Page.initialize(element);
  },
  setEditing: function(id) {
    Page.selected = id;
    Page.id = id;
    Page.editMode = true;
    Page.launchEditor();
  },
  store: function(elements) {
    elements.each( function(i) {
      var element = $(this);
      var name = element.attr('name');
      // bypass write so that we don't mark this as hasChanges
      Page.attributes[name] = element.text();
    });
  },
  storeParent: function(node, ref_node, type) {
    if (type == 'after') {
      Page.parent_id = $(ref_node).parents('li').attr('id');
    } else if (type == 'inside') {
      Page.parent_id = $(ref_node).attr('id');
    }
  },
  read: function(name) {
    return Page.attributes[name];
  },
  rename: function(element, tree) {
    var url = window.location.pathname + '.js';
    var title = tree.get_text(element);
    var position  = $('#'+Page.parent_id+' ul > li').size();
    jQuery.ajax({
      type: 'post',
      url: url,
      dataType: 'json',
      data: "page[title]="+title+"&page[derive_path_from]="+Page.parent_id+"&page[position]="+position,
      success: function(response) {
        var href = window.location.pathname;
        var page_id = response.page.id;
        element.removeClass('updateAfterRename').attr( { id: "page_"+ page_id} ).children('a').attr({ 'href': href + '/' + page_id });
        Treeview.handleSelect(element[0], tree); // needs to pass the node, not the element
      },
      error: function(response) {
        alert("Something went wrong during save operation. Please try again.");
      }
    });

  },
  // using write allows us to track changes, and alert the user before they are lost
  toggleDynamicContent: function(e) {
    var element = $(e.target);
    Page.write('dynamic_content', element.val());
  },
  updateNode: function(response) {
    var node = $(Page.selected);
    var child = node.children('a');
    var status = response.approval;
    node.attr({id: 'page_'+response.id});
    var href = child.attr('href');
    child.attr({href: href.replace(/\d+/, response.id)});
    $.tree.focused().rename(node, response.title);
    if (status == 'pending')
      child.addClass('pending');
    else if (status == 'approved')
      child.removeClass('pending');
  },
  write: function(name, value) {
    var old_value = Page.read(name);
    if (value != old_value) {
      Page.attributes[name] = value;
      Page.hasBeenChanged = true;
    }
  },
  warnBeforeChange: function() {
    return confirm("You have unsaved changes, they will be lost if you continue.");
  }
}

var Treeview = {
  changeVisibility: function(e) {
    e.preventDefault();
    var node = $.tree.focused().selected;
    if (!node)
      return;
    var child = $('#' + node.attr('id') + ' > a');
    if (child.hasClass('hidden')) {
      child.removeClass('hidden');
      Treeview.markShown(node);
    } else {
      child.addClass('hidden');
      Treeview.markHidden(node);
    }
  },
  refresh: function(response) {
    $.tree.focused().refresh();
    Treeview.deletedNodes = [];
    Treeview.shownNodes   = [];
    Treeview.hiddenNodes  = [];
    $('#site_tree, #pageArea').removeClass('loading');
  },
  saveNewPagePlaceholder: function(node, ref_node, type, tree_obj, rollback) {

  },
  save: function(e) {
    e.preventDefault();
    $('#site_tree, #pageArea').addClass('loading');
    var url  = $(e.target).attr('href');
    var data = $.tree.focused().get();
    var deleted = Treeview.initNodesForSave(Treeview.deletedNodes);
    var hidden = Treeview.initNodesForSave(Treeview.hiddenNodes);
    var shown = Treeview.initNodesForSave(Treeview.shownNodes);
    var data_json = encodeURIComponent(JSON.stringify(data));
    jQuery.ajax({
        type: 'post',
        url: url,
        data: "tree="+data_json+'&deleted='+deleted+'&hidden='+hidden+'&shown='+shown,
        dataType: 'json',
        complete: Treeview.refresh
    });
  },
  initNodesForSave: function(array) {
    var temp  = {pages: [], sections: []};
    temp = Treeview.addNodes(temp, array);
    var isBlank = ((temp.pages.length == 0) && (temp.sections.length == 0));
    if (isBlank)
      return('');
    else
      return(encodeURIComponent(JSON.stringify(temp)));
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
    var tree = $.tree.focused();
    var time = new Date().getTime();
    var node = tree.create(
      {
        data: {
          title: 'New section',
          attributes: { 'class': 'hidden' }
        },
        attributes: {id: 'new-section_'+time, rel: 'section'}
      },
      -1);
    tree.rename(node);
  },
  newPage: function(e) {
    e.preventDefault();
    if (Treeview.safeToChangePages())
      var donothing = true; // they don't want to lose changes, put it back
    else
      Treeview.createNewPage();
  },
  safeToChangePages: function() {
    return (Page.selected && Page.hasChanges() && !Page.warnBeforeChange());
  },
  createNewPage: function() {
    var tree = $.tree.focused();
    if (tree.selected) {
      var time = new Date().getTime();
      var node = tree.create(
        {
          data: { title: 'New page', attributes: { 'class': 'hidden' } },
          attributes: {id: 'new_page_'+time, rel: 'page'}
        }
      );
    }
  },
  showPage: function() {
    $('#loading').hide();
    setEditable();
    Page.store($('.editable'));
  },
  onrename: function(node, tree, rollback) {
    var element = $(node);
    if (element.attr('rel') == 'section')
      Folder.rename(element, tree);
    else if (element.hasClass('updateAfterRename'))
      Page.rename(element, tree);
    tree.select_branch(node);
  },
  onselect: function(node, tree) {
    var isSection = $(node).attr('rel') == 'section';
    if (isSection)
      tree.open_branch(node);
    if (Page.selected == node)
      return false;
    else if (Treeview.safeToChangePages())
      tree.select_branch(Page.selected); // they don't want to lose changes, put it back
    else
      Treeview.handleSelect(node, tree);
  },
  handleSelect: function(node, tree) {
    Page.initialize(node);
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
  markHidden: function(node) {
    swapNodeFromArrays(node, Treeview.hiddenNodes, Treeview.shownNodes);
  },
  markShown: function(node) {
    swapNodeFromArrays(node, Treeview.shownNodes, Treeview.hiddenNodes);
  }
}

function swapNodeFromArrays(node, addTo, removeFrom) {
  var id = $(node).attr('id');
  addTo.push(id);
  jQuery.unique(addTo);
  var position = jQuery.inArray(id, removeFrom);
  if (position != -1) {
    removeFrom.remove(position);
  }
  jQuery.unique(removeFrom);
}


function storeEditable (value, settings) {
  var element = $(this);
  var name = element.attr('name');
  var rel = element.attr('rel');
  if (rel) { // we have a URL to hit, to validate the change
    var url = element.attr('rel') + '.js';
    // check via Ajax if this change is allowed
    jQuery.ajax({
      type: 'post',
      url: url,
      data: '_method=put&page['+name+"]="+value,
      error: function(request, status, error) {
        if (request.status == 403) {
          alert("The proposed change is invalid, please try again.");
          element.text(Page.read(name));
        }
      },
      success: function(r,s,e) { Page.write(name, value); }
    });
  } else { // we're not validating this change at all
    Page.write(name, value);
  }
  return value;
}

function setEditable() {
  $('.editable').editable( storeEditable, {
    cssclass: 'editable_field',
    width: 'none',
    submit: 'OK',
    tooltip: 'Click to edit'
  } );
}


$(function() {
  // Used generically, as an alternative to Rails broken helpers
  $('a.link_to_post').live('click', makePostLink );
  $('a.link_to_destroy').live( 'click', makeDestroyLink );

  // Wire up the buttons for the treeview
  $('a#save_tree').live('click', Treeview.save );
  $('a#new_section').live('click', Treeview.newSection );
  $('a#new_page').live('click', Treeview.newPage );
  $('a#delete_page').live('click', Treeview.markDeleted );
  $('a.save_page').live('click', Page.saveChanges );
  $('a.approve_page').live('click', Page.approveAndSave );
  $('a#visibility_page').live('click', Treeview.changeVisibility );
  $('.dynamic_when_clicked > input').live('click', Page.toggleDynamicContent );

  $('.disabled a, a.disabled').unbind('click').live('click', function(e) { e.preventDefault(); });

  if ($('.datepicker').length > 0) {
    $('.datepicker').not('.iso-date').datepicker({ showAnim: 'slide' });
    $('.datepicker').filter('.iso-date').datepicker({ showAnim: 'slide', dateFormat: 'yy-mm-dd' });
  }

});



/***** Ready? Aim? Fire! jQuery stuff by Wes *****/

$(document).ready(function() {
  var box_height = $('#session_info ul').innerHeight();
  var state = 'closed';

  $('#session_info')
    .css('top', '-' + box_height + 'px')
    .find('h2 a')
      .click( function() {
        if (state == 'closed'){
          $('#session_info')
            .animate({
              'top' : '0'
            }, 500)
            .find('h2 a')
              .css('backgroundPosition','100% 50%');

          state = 'open';
        }
        else {
          $('#session_info')
            .animate({
              'top' : '-' + box_height
            }, 500)
            .find('h2 a')
              .css('backgroundPosition','0% 50%');

          state = 'closed';
        }
        return false;
      });


  //style and functionality for table rows
    //add .odd to alternating table rows and other elements
    $('div#main_content table.dashboard_table tr:odd').addClass("odd");
    $('ul.striped li:odd').addClass("odd");

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
       var editor_link = $('td a.edit, td a.preview, td a.users', parent_row);
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
       $(this).parents('td').removeClass('pointer').unbind('click');
     })
   }

  // tabbed content
    // mark first tab as selected by default
    $('div.tab_container ul.tab_nav a:first').addClass('selected');


    var tab_container = $('div.tab_container > div.tab_content');

    $('div.tab_container ul.tab_nav a')
      .click(function () {
        tab_container.hide().filter(this.hash).show();

        $('div.tab_container ul.tab_nav a').removeClass('selected');
        $(this).addClass('selected');

        return false;
      });


    // tab selection via query string
    var query = $.parseQuery();
    if (query.tab) {

      // show proper tab_content
      $('div.tab_container > div.tab_content')
        .hide()
        .filter('#' + query.tab)
          .show();

      // highlight active tab
      $('div.tab_container ul.tab_nav a')
        .removeClass('selected')
        .filter(function() {
          return $(this).attr('href').indexOf(query.tab) >= 0;
        })
          .addClass('selected');

    }
    else {
      $('div.tab_container ul.tab_nav a:first').click();
    }

    //add odd-row class to alternating tabbed-content items
    $('div.tab_container ul.items li.item:odd').addClass("odd");

    //tabbed stuff is hidden by default, so that it doesn't display "unstyled" before document.ready fires. Show it now that we're done!
    $('div.tab_container').slideDown();

    $('.file_inputs').each(function() {
      var e         = $(this),
          inputList = e.find('ol'),
          button    = $("<div class='new_page_large align'>Add File</div>");

      if (inputList.length) {
        button.click(function() {
          var lastLi = inputList.find('li:last');

          lastLi
            .clone()
            .html(lastLi.html())
            .appendTo(inputList);
        });

        button.appendTo(e);
      }
    });

    var regionSelect        = $('#local_network_event_search_region'),
        localNetworkSelect  = $('#local_network_event_search_local_network_id'),
        localNetworkOptions = localNetworkSelect.find('option');

    function populateLocalNetworkSelect() {
      var region     = regionSelect.attr('value'),
          selectedId = localNetworkSelect.attr('value');

      localNetworkSelect.empty();

      localNetworkOptions.each(function() {
        var option = $(this),
            id     = option.attr('value');

        if (region === '' || id === '' || $.inArray(id, LocalNetworkRegions[region]) !== -1) {
          option.attr('selected', id === selectedId);
          option.appendTo(localNetworkSelect);
        } else {
          option.attr('selected', false);
        }
      });
    }

    regionSelect.change(populateLocalNetworkSelect);
    populateLocalNetworkSelect();
});
