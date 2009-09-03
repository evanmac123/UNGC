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

$(function() {
	if ($('body.editable_page').length > 0)
		jQuery.get("/decorate"+window.location.pathname, [], null, 'script');

	$('a.edit_content').live('click', function(event) {
		// jQuery.get(event.target.href, [], null, 'script');
		Editor.loading();
		jQuery.ajax({
    	type: 'get',
    	url: event.target.href,
    	dataType: 'script'
		});
		return false;
	});

	$('#nav > ul > li').each( function(elem) {
		$(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
		$(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
	} );
});