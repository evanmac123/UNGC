
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
var	Folder = {
	rename: function(element, tree) {
		// TODO: Should "freeze" other actions until this is done
		var name = tree.get_text(element);
		var url = window.location.href + '/create_folder.js';
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
	hasChanges: function() {
		if (Page.selected) {
			if (Page.hasBeenChanged)
				return true 
			if (Page.editor)
				return Page.editor.checkDirty();
		} else {
			return false;
		}
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
		if (Page.hasChanges()) {
			if (Page.id) {
				// this is an update
				var url = $(e.target).attr('href') + '.js';
				var data = '_method=put';
			} else {
				var url = window.location.href + '.js';
				var data = '';
			}
			for (var key in Page.attributes) {
				data += '&page['+key+']='+encodeURIComponent(Page.attributes[key]);
			}
			var needsPending = false;
			if (Page.editor && Page.editor.checkDirty()) {
				var content = Page.editor.getData();
				data += '&page[content]='+encodeURIComponent(content);
				var needsPending = true;
			}
		  jQuery.ajax({
		    type: 'post',
		    url: url,
		    data: data,
				success: function() { 
					Page.hasBeenChanged = null; 
					Page.editor.resetDirty(); 
					if (needsPending)
						$(Page.selected).children('a').addClass('pending');
				},
		    error: function(request, status, error) {
		      if (request.status == 403)
		        alert("Unable to save changes, please try again.")
		    }
		  });
		}
	},
	select: function(element) {
		Page.selected = element;
		element = $(element);
		if (Page.editor) {
			$('#pageReplace form').hide()
			Page.editor.destroy();
		}
		Page.hasBeenChanged = null;
		var id = element.attr('id');
		var matching = id.match(/(page)?\D*_(\d+)/);
		if ((matching) && (matching[1] == 'page')) { // it's a page
			Page.id = matching[2];
	  }
	},
	setEditing: function(id) {
		
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
		var url = window.location.href + '.js';
		var title = tree.get_text(element);
		var position  = $('#'+Page.parent_id+' ul > li').size();
		jQuery.ajax({
		  type: 'post',
		  url: url,
		  dataType: 'json',
		  data: "page[title]="+title+"&page[derive_path_from]="+Page.parent_id+"&page[position]="+position,
		  success: function(response) { 
		    var href = window.location.href;
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
    var data = $.tree.focused().get();
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
    var tree = $.tree.focused();
    var time = new Date().getTime();
    var node = tree.create(
      {
        data: { title: 'New section', attributes: { class: 'hidden' } }, 
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
          data: { title: 'New page', attributes: { class: 'hidden' } },
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
		tree.toggle_branch(node);
		if (Page.selected == node)
			return false;
		else if (Treeview.safeToChangePages())
			tree.select_branch(Page.selected); // they don't want to lose changes, put it back
		else
			Treeview.handleSelect(node, tree);
  },
	handleSelect: function(node, tree) {
		Page.select(node);
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
	$('.editable').editable( storeEditable, { cssclass: 'editable_field', width: 'none', submit: 'OK', tooltip: 'Click to edit' } );
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

	$('.disabled a').live('click', function(e) { e.preventDefault(); });

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
        $(this).parents('td').removeClass('pointer').unbind('click');
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