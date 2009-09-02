var CKEDITOR_BASEPATH = '/ckeditor/'

var Editor = {
	editor: null,
	originalContents: null,
	create: function(contents) {
		if (Editor.editor)
			return;
		
		var contentDiv = '#rightcontent div.copy';
		Editor.originalContents = $(contentDiv).html();
		$(contentDiv).html('');
		Editor.editor = CKEDITOR.appendTo('rightcontent');
		Editor.editor.setData(contents);
	}
}
