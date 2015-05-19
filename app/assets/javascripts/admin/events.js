$(function() {
  $('.events-html-editor').each(function(i,e) {
    var element = e;
    CKEDITOR.replace(element.id, {
       toolbar: EditorToolbar,
       width: 500,
       height: 300,
        startupMode: 'wysiwyg',
       dialog_magnetDistance: 5,
       resize_minWidth: 300,
       resize_maxWidth: 600
    });
  });
});
