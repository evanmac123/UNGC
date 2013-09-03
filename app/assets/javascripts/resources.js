$(document).ready(function() {

  // enable chosen for the search form
  var enableChosen = function(){
    $('#resource_search_language').chosen();
    $('#resource_search_author').chosen();
  };

  var showFeatured = function(){
    $('#resources_search').addClass('hidden');
    $('#resources_featured').removeClass('hidden');
    $('.browse').addClass('active')
    $('.search').removeClass('active')
  };

  var showSearch = function(){
    $('#resources_search').removeClass('hidden');
    $('#resources_featured').addClass('hidden');
    $('.browse').removeClass('active')
    $('.search').addClass('active')
    enableChosen();
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
  };

  var showTopicsList = function(el){
    var ol = $(el).siblings('ol')
    ol.show();
    $(el).removeClass('expand');
    $(el).addClass('collapse');
  };


  $('ol.topics-list input[checked]').each(function(i,e){
    $(e).parents('ol.expanded-list').parent().children('span').each(function(j,o){
      showTopicsList(o);
    })
  });

  $('ol.topics-list .toggle').on('click', function(e){
    hideTopicsList(this);
  });

  if($('form.resources_search').length === 1) {

    var query = $.parseQuery();
    if (query.tab === "search") {
      showSearch();
    } else {
      showFeatured();
    }

    $('.browse').on('click',function(e){
      e.preventDefault();
      showFeatured();
    });

    $('.search').on('click',function(e){
      e.preventDefault();
      showSearch();
    });

  }

  if($('.resource-show-details').length === 1) {
    $('.resource_link').on('click',function(e){
      var id = $(this).data('resource-link-id');

      $.ajax({
        url: '/resources/link_views',
        type: 'POST',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: { resource_link_id: id }
      });
    });
  }

});
