//= require_tree ./admin/
//= require moment
//= require_self

// Array Remove - By John Resig (MIT Licensed)
Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

/***** Ready? Aim? Fire! jQuery stuff by Wes *****/
$(document).ready(function() {
  var box_height = $('#session_info ul').innerHeight();
  var state = 'closed';

  $('#session_info')
    .css('top', '-' + box_height + 'px')
    .find('h2 a')
      .click( function() {
        if (state == 'closed'){
          $('#session_info')
            .animate({
              'top' : '0'
            }, 500)
            .find('h2 a')
              .css('backgroundPosition','100% 50%');

          state = 'open';
        }
        else {
          $('#session_info')
            .animate({
              'top' : '-' + box_height
            }, 500)
            .find('h2 a')
              .css('backgroundPosition','0% 50%');

          state = 'closed';
        }
        return false;
      });


  //style and functionality for table rows
    //add .odd to alternating table rows and other elements
    $('div#main_content table.dashboard_table tr:odd').addClass("odd");
    $('ul.striped li:odd').addClass("odd");

    //hover styling for table rows
    $('div#main_content table.dashboard_table tr').hover(
      function() {
        $(this).addClass("over");
      },
      function() {
        $(this).removeClass("over");
      }
    );

  //set click action to anywhere in a table row to go to the url of the a.edit element in that row
   //note: edited to use the td rather than tr in an attempt to remove click-action from header row
   $('div#main_content table.dashboard_table tr td').addClass('pointer').click(
     function(e) {
       var parent_row = $(this).parent();
       var editor_link = $('td a.edit, td a.preview, td a.users', parent_row);
       var has_edit = editor_link.length > 0;
       if (has_edit)
         document.location.href = editor_link.attr("href");
     }
   );

   // Order matters: this section must come after the table-row-link code
   // shouldn't go to the edit action if we clicked on another action icon
   var links = $('div#main_content table.dashboard_table tr td a.edit')
   if (links.length > 0) {
     links.each( function(i) {
       $(this).parents('td').removeClass('pointer').unbind('click');
     })
   }

  // tabbed content
    // mark first tab as selected by default
    $('div.tab_container ul.tab_nav a:first').addClass('selected');


    var tab_container = $('div.tab_container > div.tab_content');

    $('div.tab_container ul.tab_nav a')
      .click(function () {
        tab_container.hide().filter(this.hash).show();

        $('div.tab_container ul.tab_nav a').removeClass('selected');
        $(this).addClass('selected');

        return false;
      });


    // tab selection via query string
    var query = $.parseQuery();
    if (query.tab) {

      // show proper tab_content
      $('div.tab_container > div.tab_content')
        .hide()
        .filter('#' + query.tab)
          .show();

      // highlight active tab
      $('div.tab_container ul.tab_nav a')
        .removeClass('selected')
        .filter(function() {
          return $(this).attr('href').indexOf(query.tab) >= 0;
        })
          .addClass('selected');

    }
    else {
      $('div.tab_container ul.tab_nav a:first').click();
    }

    //add odd-row class to alternating tabbed-content items
    $('div.tab_container ul.items li.item:odd').addClass("odd");

    //tabbed stuff is hidden by default, so that it doesn't display "unstyled" before document.ready fires. Show it now that we're done!
    $('div.tab_container').slideDown();

    $('.file_inputs').each(function() {
      var e         = $(this),
          inputList = e.find('ol'),
          button    = $("<div class='new_page_large align'>Choose another file to upload...</div>");

      if (inputList.length) {
        button.click(function() {
          var lastLi = inputList.find('li:last');

          lastLi
            .clone()
            .html(lastLi.html())
            .appendTo(inputList);
        });

        button.appendTo(e);
      }
    });

    var regionSelect        = $('#local_network_event_search_region'),
        localNetworkSelect  = $('#local_network_event_search_local_network_id'),
        localNetworkOptions = localNetworkSelect.find('option');

    function populateLocalNetworkSelect() {
      var region     = regionSelect.attr('value'),
          selectedId = localNetworkSelect.attr('value');

      localNetworkSelect.empty();

      localNetworkOptions.each(function() {
        var option = $(this),
            id     = option.attr('value');

        if (region === '' || id === '' || $.inArray(id, LocalNetworkRegions[region]) !== -1) {
          option.attr('selected', id === selectedId);
          option.appendTo(localNetworkSelect);
        } else {
          option.attr('selected', false);
        }
      });
    }

    regionSelect.change(populateLocalNetworkSelect);
    populateLocalNetworkSelect();
});
