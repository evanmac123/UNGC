// full toolbar:
// [
//     ['Source','-','Save','NewPage','Preview','-','Templates'],
//     ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
//     ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
//     ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
//     '/',
//     ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
//     ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
//     ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
//     ['Link','Unlink','Anchor'],
//     ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
//     '/',
//     ['Styles','Format','Font','FontSize'],
//     ['TextColor','BGColor'],
//     ['Maximize', 'ShowBlocks','-','About']
// ]

$.datepicker.setDefaults({ changeYear: true, duration: 'slow' });

var EditorToolbar = [
	['Source','-','-'],
	['Maximize','Preview'],
	['PasteText','PasteFromWord'],
	['Undo','Redo'],
	['Image','Table','HorizontalRule','SpecialChar'],
	['Link','Unlink','Anchor'],
	'/',
	['Format','Bold','Italic','Underline','Subscript','Superscript','RemoveFormat'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	['Outdent','Indent','NumberedList','BulletedList']
];


function makeChildrenVisible (id) {
	var parent = $("#"+id);
	var children = parent.children('ul')
	if (children[0])
		children[0].style.visibility = 'visible';
}

function include(path_to_file) {
	$.ajax({
		url: path_to_file,
		dataType: "script",
		async: false,
		success: function(js){if(jQuery.browser.safari){eval(js);}}
	});
}

function makeChildrenInvisible (id) {
	var parent = $("#"+id);
	var children = parent.children('ul')
	if (children[0])
		children[0].style.visibility = 'hidden';
}

function versionNumberAnchor() {
	if (window.location.href.match(/\#/)) {
		var anchor = window.location.href.split('#')[1]
		if (anchor) {
			var version_match = anchor.match(/version_([0-9]+)/)
			if (version_match) {
				return version_match[1];
			}
		}
	}
	return false;
}

var Watcher = {
	watcher: null,
	fetched: null,
	included: null,
	init: function() {
		this.watcher = setInterval( Watcher.watchForVersion, 500 );
	},
	stop: function() {
		clearInterval(Watcher.watcher);
	},
	watchForVersion: function() {
		var versionNumber = versionNumberAnchor();
		if (versionNumber)
			Watcher.goDecorate(versionNumber);
		else
			Watcher.goDecorate();
	},
	alreadyFetched: function(url) {
		if (Watcher.fetched == url) {
			return true;
		} else {
			Watcher.fetched = url;
			return false;
		}
	},
	goDecorate: function(number) {
		if ((window.location.pathname != '/') && (window.location.pathname != '')) {
			var url = "/decorate"+window.location.pathname;
			url = url.replace(/preview\//, '');
			if (number != null) url += '?version=' + number;

			if (Watcher.alreadyFetched(url)) {
				return false;
			} else {
				jQuery.ajax({
		    	type: 'get',
		    	url: url,
		    	dataType: 'json',
					success: Watcher.decoratePage
				});
			}
		}
	},
	decoratePage: function(response) {
		if (!Watcher.included) {
			Watcher.included = true;
			include('/javascripts/page_editor.js');
			include('/ckeditor/ckeditor.js');
		}
		if (response.content) {
			var possible_editor = $('#rightcontent .click_to_edit');
			if (possible_editor.size() > 0)
				possible_editor.remove();
				// $('#rightcontent .click_to_edit').replaceWith(response.editor);
			// else
			$('#rightcontent').prepend(response.editor);
			$('#rightcontent .copy').html(response.content);
		} else {
			$('#rightcontent').prepend(response.editor);
		}
	}
}

$(function() {

  if ($('table.sortable').size() > 0) 
  		$('table.sortable').tablesorter({widgets: ['zebra']});
	
  // if ($('table.sortable').size() > 0) {
  //   $('table.sortable').tablesorter({widgets: ['zebra']});
  //   $('table.sortable')
  //    .tablesorter({
  //      widthFixed: true, 
  //      widgets: ['zebra']}) 
  //        .tablesorterPager({
  //      container: $(".pager"), 
  //      positionFixed: false,
  //      size: 20
  //    });
  // }
});

$(document).ready(function() { 
	
	$('.sort.server').click(function() {	
		
		new_window_location = window.location.href;
		new_direction = 'ASC';
		new_sort_by = this.id;			
		previous_sort_by = (/sort_by=(\w+)/.test(new_window_location)) ? new_window_location.match(/sort_by=(\w+)/)[1] : 'n/a'
		previous_direction = (/direction=(\w+)/.test(new_window_location)) ? new_window_location.match(/direction=(\w+)/)[1] : 'n/a'
		
		// Cut the previous sort_by and direction params out
		new_window_location = new_window_location.replace(/&direction=(\w+)/g, '');
		new_window_location = new_window_location.replace(/&sort_by=(\w+)/g, ''); 
		new_window_location = new_window_location.replace(/&amp;direction=(\w+)/g, '');
		new_window_location = new_window_location.replace(/&amp;sort_by=(\w+)/g, '');
		
		if(new_sort_by == previous_sort_by) {
			if(previous_direction != 'undefined' && previous_direction == 'ASC') {
				new_direction = 'DESC';
			}
		}
			
		// Add the new sort params to the end of the URL and redirect
		new_window_location += '&sort_by=' + new_sort_by + '&direction=' + new_direction;			
		window.location = new_window_location
	});
	
});
	
	if ($('body.editable_page').length > 0) {
		Watcher.init();
	}

  // $(".tablesorter").tablesorter({widgets: ['zebra']}); 
	
	
	$('a.edit_content').live('click', function(event) {
		// jQuery.get(event.target.href, [], null, 'script');
		Editor.loading();
		jQuery.ajax({
    	type: 'get',
    	url: event.target.href,
    	dataType: 'json',
			success: function(json) {
				Editor.doneLoading();
				Editor.create(json);
			}
		});
		return false;
	});

	$('#nav > ul > li').each( function(elem) {
		$(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
		$(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
	} );

	$('select.autolink').change(function(e) {
		var select = $(e.target);
		var go = select.val();
		var anchor = window.location.hash;
		if (go != '') {
			window.location = go.replace(/\&amp;/, '&') + anchor;
		}
	});
  
  // public participant search controls
  function showBusinessOnly (argument) {
  	$('.for_stakeholders_only').fadeOut('slow')
  	$('.for_business_only').fadeIn('slow');
  }

  function showStakeholdersOnly (argument) {
  	$('.for_business_only').fadeOut('slow');
  	$('.for_stakeholders_only').fadeIn('slow');
  }

  function hideBusinessAndStakeholders (argument) {
  	$('.for_stakeholders_only').fadeOut('slow');
  	$('.for_business_only').fadeOut('slow');
  }
  
	$('form #business_only').click( showBusinessOnly );
	$('form #stakeholders_only').click( showStakeholdersOnly );
	$('form #hide_business_and_stakeholders').click( hideBusinessAndStakeholders );
	$("#listing_status_id").change(function() {
    selected_listing_status = jQuery.trim($("#listing_status_id option:selected").text());
    if (selected_listing_status == "Public Company") {
      $('.public_company_only').show();
    } else {
      $('.public_company_only').hide();
    }
  })
  
  // hide and show sections for FAQs, titles and descriptions etc.
  $(".hint_toggle").click(function(){
    $(this).next(".hint_text").slideToggle();
    $(this).toggleClass('selected');
  });

  // called from views/signup/step5.html.haml
  $("#contact_foundation_contact").click(function() {
    if ($('#errorExplanation').length > 0) {
      $('#errorExplanation').slideToggle('slow');  
    }
    $('#contact_form').slideToggle('slow');
  });
  
