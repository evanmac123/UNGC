$(document).ready(function() {
  // enable chosen for the search form
  if ($('form.resources_search').length == 1) {
    $('#author').chosen();
  }

  // deal with the topics tree
  var hideResourceList = function(el){
    var ol = $(el).siblings('ol')
    ol.toggle();
    $(el).removeClass('collapse','expand');
    if(ol.is(':visible')){
      $(el).addClass('collapse');
    }else{
      $(el).addClass('expand');
    }
  }

  var showResourceList = function(el){
    var ol = $(el).siblings('ol')
    ol.show();
    $(el).removeClass('expand');
    $(el).addClass('collapse');
  }


  $('ol.resources-list input[checked]').each(function(i,e){
    $(e).parents('ol.expanded-list').parent().children('span').each(function(j,o){
      showResourceList(o);
    })
  });

  $('ol.resources-list .toggle').on('click', function(e){
    hideResourceList(this);
  });

});
