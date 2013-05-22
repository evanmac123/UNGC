var CKEDITOR_BASEPATH = '/ckeditor/'

function startEditor(replaceMe) {
	var mode = $('#'+replaceMe).attr('rel');
	if ((mode) && (mode == 'dynamic')) {
		var startup = 'source';
	} else {
		var startup = 'wysiwyg';
	}
  var editor = CKEDITOR.replace(replaceMe, {
    toolbar: EditorToolbar,
    width: 618,
    height: 500,
		startupMode: startup,
    dialog_magnetDistance: 5,
    resize_minWidth: 300,
    resize_maxWidth: 600,
  });
  editor.config.protectedSource.push( /<\%=?.*\%>/gm);
  return editor;
};

function replace_with_editor(){
	var element = $('.replace_with_editor')[0];
	CKEDITOR.replace(element.id, {
     toolbar: EditorToolbar,
     width: 500,
     height: 300,
 		 startupMode: 'wysiwyg',
     dialog_magnetDistance: 5,
     resize_minWidth: 300,
     resize_maxWidth: 600,
  });
}

// Mostly used on front-end, click-to-edit areas
var Editor = {
  editor: null,
  originalContents: null,
  create: function(json) {
    if (Editor.editor)
      return;

    Editor.swapButtons();

    var contentDiv = '#rightcontent div.copy';
    Editor.originalContents = $(contentDiv).html();
    $(contentDiv).empty();
    $(contentDiv).after('<form id="fancyEditor" action="'+json.url+'" method="post"></form>');
    editorForm = $('#fancyEditor')
    editorForm.append('<input type="hidden" name="_method" value="put" />');
    editorForm.append('<input type="hidden" name="authenticity_token" value="'+AUTH_TOKEN+'" />');
    editorForm.append('<textarea id="replaceMe" name="content[content]"></textarea>');

    Editor.editor = startEditor('replaceMe');
    Editor.editor.config.startupMode = json.startupMode;
    Editor.editor.setData(json.content);
  },
  save: function() {
    $('#replaceMe').val(Editor.editor.getData());
    Editor.loading();
    var form = $('#fancyEditor');
    var formData = form.serialize();
    var specialMethod = form.children('input[name=_method]').val();
    var method = specialMethod ? specialMethod : form.attr('method');
    var ajaxOptions = {
      type: method,
      url: form.attr('action'),
      dataType: 'json',
      data: formData,
      success: function(data) { Editor.postSave(data.page); }
    };
    jQuery.ajax(ajaxOptions);
    return false;
  },
  postSave: function(response) {
    Editor.doneLoading();
    Editor.restoreButtons();
    if (response.version)
      window.location.hash = '#version_' + response.version;
    Editor.originalContents = response.content; // happens either way, prevents weirdness
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
    var loadImage = $('div.click_to_edit #editorLoading');
    var buttonArea = $('div.click_to_edit');
    buttonArea.empty();
    buttonArea.append('<a href="#" class="saveEditor">Save</a>');
    buttonArea.append('<a href="#" class="cancelEditor">Cancel</a>');
    buttonArea.append(loadImage);
    $('div.click_to_edit .saveEditor').click( Editor.save )
    $('div.click_to_edit .cancelEditor').click( Editor.cancelEditing );
  },
  loading: function() {
    $('#editorLoading').show();
  },
  doneLoading: function() {
    $('#editorLoading').hide();
  }
}

$(document).ready(function() {
  if ($('.replace_with_editor').length == 1) {
  	replace_with_editor();
  }
});
