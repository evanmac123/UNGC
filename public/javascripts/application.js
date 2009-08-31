function makeChildrenVisible (id) {
	var parent = $("#"+id);
	var children = parent.children('ul')
	if (children[0])
		children[0].style.visibility = 'visible';
}

function makeChildrenInvisible (id) {
	var parent = $("#"+id);
	var children = parent.children('ul')
	if (children[0])
		children[0].style.visibility = 'hidden';
}

$(function() {
	$('#nav > ul > li').each( function(elem) {
		$(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
		$(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
	} );
});