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
		Editor.editor = CKEDITOR.appendTo('rightcontent', {
			toolbar: [
			    ['Source','-','Save','NewPage','Preview','-','Templates'],
			    ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Print', 'SpellChecker', 'Scayt'],
			    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
			    ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
			    '/',
			    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
			    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
			    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
			    ['Link','Unlink','Anchor'],
			    ['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
			    '/',
			    ['Styles','Format','Font','FontSize'],
			    ['TextColor','BGColor'],
			    ['Maximize', 'ShowBlocks','-','About']
			],
			width: 600,
			dialog_magnetDistance: 5,
			resize_minWidth: 300,
			resize_maxWidth: 600
		});
		Editor.editor.setData(contents);
	}
}
