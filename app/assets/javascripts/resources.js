$(document).ready(function() {
  if ($('form.resources_search').length == 1) {
    $('#author').chosen();
  }

  $('ol.resources-list .toggle').on('click', function(e){
    var ol = $(this).siblings('ol')
    ol.toggle();
    $(this).removeClass('collapse','expand');
    if(ol.is(':visible')){
      $(this).addClass('collapse');
    }else{
      $(this).addClass('expand');
    }
  });
});
