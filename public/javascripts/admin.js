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
		
		Editor.editor = CKEDITOR.replace('replaceMe', {
			toolbar: EditorToolbar,
			width: 600,
			height: 500,
			dialog_magnetDistance: 5,
			resize_minWidth: 300,
			resize_maxWidth: 600
		});
		Editor.editor.setData(contents);
	},
	save: function() {
		$('#replaceMe').val(Editor.editor.getData());
		var form = $('#fancyEditor');
		var formData = form.serialize();
		var specialMethod = form.children('input[name=_method]').val();
		var method = specialMethod ? specialMethod : form.attr('method');
		var ajaxOptions = {
    	type: method,
    	url: form.attr('action'),
    	dataType: 'json',
    	data: formData,
    	success: function(data) { Editor.postSave(data); }
    };
    jQuery.ajax(ajaxOptions);
		return false;
	},
	postSave: function(response) {
		Editor.restoreButtons();
		Editor.originalContents = response.content;
		Editor.restoreContent();
	},
	cancelEditing: function() {
		Editor.restoreButtons();
		Editor.restoreContent();
		return false;
	},
	restoreButtons: function() {
		$('div.click_to_edit').html(Editor.originalButtons);
	},
	restoreContent: function() {
		Editor.editor.destroy();
		Editor.editor = null;
		$('#fancyEditor').remove();
		$('#rightcontent div.copy').html(Editor.originalContents);
	},
	swapButtons: function() {
		Editor.originalButtons = $('div.click_to_edit').children();
		var buttonArea = $('div.click_to_edit');
		buttonArea.empty();
		buttonArea.append('<a href="#" class="saveEditor">Save</a>');
		$('div.click_to_edit .saveEditor').click( Editor.save )
		buttonArea.append('<a href="#" class="cancelEditor">Cancel</a>');
		$('div.click_to_edit .cancelEditor').click( Editor.cancelEditing );
	}
}
