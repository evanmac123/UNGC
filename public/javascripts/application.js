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

var EditorToolbar = [
	['Source','-','-'],
	['Cut','Copy','Paste','PasteText','PasteFromWord','-','SpellChecker', 'Scayt'],
	['Undo','Redo','-','Find','Replace','SelectAll'],
	['Image','Table','HorizontalRule','SpecialChar'],
	// ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
	'/',
	['Bold','Italic','Underline','Strike','Subscript','Superscript','RemoveFormat'],
	['Link','Unlink'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	['Outdent','Indent','NumberedList','BulletedList','Blockquote'],
	// '/',
	// ['Styles','Format','Font','FontSize'],
	// ['TextColor','BGColor'],
	// ['Maximize', 'ShowBlocks','-','About']
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
		var url = "/decorate"+window.location.pathname;
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
	},
	decoratePage: function(response) {
		include('/javascripts/admin.js');
		include('/ckeditor/ckeditor.js');
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
	if ($('body.editable_page').length > 0) {
		Watcher.init();
	}

	$('a.edit_content').live('click', function(event) {
		// jQuery.get(event.target.href, [], null, 'script');
		Editor.loading();
		jQuery.ajax({
    	type: 'get',
    	url: event.target.href,
    	dataType: 'json',
			success: function(json) {
				Editor.doneLoading();
				Editor.create(json.url, json.content);
			}
		});
		return false;
	});

	$('#nav > ul > li').each( function(elem) {
		$(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
		$(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
	} );
});