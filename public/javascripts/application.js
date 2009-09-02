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
		jQuery.get(event.target.href, [], null, 'script');
		return false;
	});

	$('#nav > ul > li').each( function(elem) {
		$(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
		$(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
	} );
});