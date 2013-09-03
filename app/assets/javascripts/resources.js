$(document).ready(function() {
  // enable chosen for the search form
  if ($('form.resources_search').length == 1) {
    $('#resource_search_language').chosen();
    $('#resource_search_author').chosen();
  }

  // deal with the topics tree
  var hideTopicsList = function(el){
    var ol = $(el).siblings('ol')
    ol.toggle();
    $(el).removeClass('collapse','expand');
    if(ol.is(':visible')){
      $(el).addClass('collapse');
    }else{
      $(el).addClass('expand');
    }
  }

  var showTopicsList = function(el){
    var ol = $(el).siblings('ol')
    ol.show();
    $(el).removeClass('expand');
    $(el).addClass('collapse');
  }


  $('ol.topics-list input[checked]').each(function(i,e){
    $(e).parents('ol.expanded-list').parent().children('span').each(function(j,o){
      showTopicsList(o);
    })
  });

  $('ol.topics-list .toggle').on('click', function(e){
    hideTopicsList(this);
  });

});
