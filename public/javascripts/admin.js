var CKEDITOR_BASEPATH = '/ckeditor/'

var Editor = {
	editor: null,
	originalContents: null,
	create: function(actionUrl, contents) {
		if (Editor.editor)
			return;
		
		Editor.swapButtons();
		
		var contentDiv = '#rightcontent div.copy';
		Editor.originalContents = $(contentDiv).html();
		$(contentDiv).empty();
		$(contentDiv).after('<form id="fancyEditor" action="'+actionUrl+'" method="post"></form>');
		editorForm = $('#fancyEditor')
		editorForm.append('<input type="hidden" name="_method" value="put" />');
		editorForm.append('<input type="hidden" name="authenticity_token" value="'+AUTH_TOKEN+'" />');
		editorForm.append('<textarea id="replaceMe" name="content[content]"></textarea>');
		
		editorForm.ajaxForm( Editor.postSave );
		
		Editor.editor = CKEDITOR.replace('replaceMe', {
			toolbar: EditorToolbar,
			width: 600,
			height: 500,
			dialog_magnetDistance: 5,
			resize_minWidth: 300,
			resize_maxWidth: 600
		});
		// Editor.editor.on('pluginsLoaded', function(ev) {
		// 	Editor.editor.addCommand('fancyCustomSave', Editor.save );
		// 	Editor.editor.ui.addButton('AjaxSave',
		// 	{
		// 		label: 'Save',
		// 		command: 'fancyCustomSave'
		// 	});
		// });
		Editor.editor.setData(contents);
	},
	postSave: function() {
		Editor.restoreContent();
	},
	cancelEditing: function() {
		Editor.restoreButtons();
		Editor.restoreContent();
	},
	restoreButtons: function() {
		$('div.click_to_edit').html(Editor.originalButtons);
	},
	restoreContent: function() {
		Editor.editor.destroy();
		Editor.editor = null;
		$('#rightcontent div.copy').html(Editor.originalContents);
	},
	swapButtons: function() {
		Editor.originalButtons = $('div.click_to_edit').children();
		$('div.click_to_edit').html('<a href="#" class="cancelEditor">Cancel</a>');
		$('div.click_to_edit .cancelEditor').click( Editor.cancelEditing );
	}
}
