// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-1.7.2
//= require jquery_ujs
//= require jquery-ui
//= require_tree ./admin/
//= require moment
//= require ckeditor/init
//= require jquery.parsequery.min
//= require jquery.tablesorter.min
//= require jquery.tablesorter.pager
//= require jquery.jeditable.mini
//= require jquery.tree.min
//= require chosen.jquery.min
//= require_self
//= require cop_form
//= require dashboard
//= require page_editor
//= require organization_signup
//= require retina

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

$.datepicker.setDefaults({ changeYear: true, duration: 'slow' });

var EditorToolbar = [
  ['Source','-','-'],
  ['Maximize','Preview'],
  ['PasteText','PasteFromWord'],
  ['Undo','Redo'],
  ['Image','Table','HorizontalRule','SpecialChar'],
  ['Link','Unlink','Anchor'],
  '/',
  ['Format','Bold','Italic','Underline','Subscript','Superscript','RemoveFormat'],
  ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
  ['Outdent','Indent','NumberedList','BulletedList']
];

// public participant search controls
function showBusinessOnly (argument) {
  $('.for_stakeholders_only').fadeOut('slow');
  $('.for_business_only').fadeIn('slow');
}

function showStakeholdersOnly (argument) {
  $('.for_business_only').fadeOut('slow');
  $('.for_stakeholders_only').fadeIn('slow');
}

function hideBusinessAndStakeholders (argument) {
  $('.for_stakeholders_only').fadeOut('slow');
  $('.for_business_only').fadeOut('slow');
}

function makeChildrenVisible (id) {
  var parent = $("#"+id);
  var children = parent.children('ul');
  if (children[0])
    children[0].style.visibility = 'visible';
}

function include(path_to_file) {
  $.ajax({
    url: path_to_file,
    dataType: "script",
    async: false,
    success: function(js){if(jQuery.browser.safari){eval(js);}}
  });
}

function makeChildrenInvisible (id) {
  var parent = $("#"+id);
  var children = parent.children('ul');
  if (children[0])
    children[0].style.visibility = 'hidden';
}

function versionNumberAnchor() {
  if (window.location.href.match(/\#/)) {
    var anchor = window.location.href.split('#')[1];
    if (anchor) {
      var version_match = anchor.match(/version_([0-9]+)/);
      if (version_match) {
        return version_match[1];
      }
    }
  }
  return false;
}

var Watcher = {
  watcher: null,
  fetched: null,
  included: null,
  init: function() {
    this.watcher = setInterval( Watcher.watchForVersion, 500 );
  },
  stop: function() {
    clearInterval(Watcher.watcher);
  },
  watchForVersion: function() {
    var versionNumber = versionNumberAnchor();
    if (versionNumber)
      Watcher.goDecorate(versionNumber);
    else
      Watcher.goDecorate();
  },
  alreadyFetched: function(url) {
    if (Watcher.fetched == url) {
      return true;
    } else {
      Watcher.fetched = url;
      return false;
    }
  },
  goDecorate: function(number) {
    if ((window.location.pathname != '/') && (window.location.pathname != '')) {
      var url = "/decorate"+window.location.pathname;
      url = url.replace(/preview\//, '');
      if (number != null) url += '?version=' + number;

      if (Watcher.alreadyFetched(url)) {
        return false;
      } else {
        jQuery.ajax({
          type: 'get',
          url: url,
          dataType: 'json',
          success: Watcher.decoratePage
        });
      }
    }
  },
  decoratePage: function(response) {
    if (response.csrf_token) {
      $('head').append('<meta content="authenticity_token" name="csrf-param" />');
      $('head').append('<meta content="'+response.csrf_token+'" name="csrf-token" />');
    }
    if (!Watcher.included) {
      Watcher.included = true;
    }
    if (response.content) {
      var possible_editor = $('#rightcontent .click_to_edit');
      if (possible_editor.size() > 0) { possible_editor.remove(); }
      $('#rightcontent').prepend(response.editor);
      $('#rightcontent .copy').html(response.content);
    } else {
      $('#rightcontent').prepend(response.editor);
    }
  }
};

$(document).ready(function() {
  if ($('table.sortable').size() > 0) {
    $('table.sortable').tablesorter({widgets: ['zebra']});
  }

  $('.sort.server').click(function() {

    new_window_location = window.location.href;
    new_direction = 'ASC';
    new_sort_by = this.id;
    previous_sort_by = (/sort_by=(\w+)/.test(new_window_location)) ? new_window_location.match(/sort_by=(\w+)/)[1] : 'n/a'
    previous_direction = (/direction=(\w+)/.test(new_window_location)) ? new_window_location.match(/direction=(\w+)/)[1] : 'n/a'

    // Cut the previous sort_by and direction params out
    new_window_location = new_window_location.replace(/&direction=(\w+)/g, '');
    new_window_location = new_window_location.replace(/&sort_by=(\w+)/g, '');
    new_window_location = new_window_location.replace(/&amp;direction=(\w+)/g, '');
    new_window_location = new_window_location.replace(/&amp;sort_by=(\w+)/g, '');

    if(new_sort_by == previous_sort_by) {
      if(previous_direction != 'undefined' && previous_direction == 'ASC') {
        new_direction = 'DESC';
      }
    }

    // Add the new sort params to the end of the URL and redirect
    new_window_location += '&sort_by=' + new_sort_by + '&direction=' + new_direction;
    window.location = new_window_location
  });


  if ($('body.editable_page').length > 0) {
    Watcher.init();
  }

  // $(".tablesorter").tablesorter({widgets: ['zebra']});

  $('body').on('click','a.edit_content', function(event) {
    // jQuery.get(event.target.href, [], null, 'script');
    Editor.loading();
    jQuery.ajax({
      type: 'get',
      url: event.target.href,
      dataType: 'json',
      success: function(json) {
        Editor.doneLoading();
        Editor.create(json.page);
      }
    });
    return false;
  });

  $('#nav > ul > li').each( function(elem) {
    $(this).bind('mouseover', function() { makeChildrenVisible(this.className) } );
    $(this).bind('mouseout', function() { makeChildrenInvisible(this.className) } );
  } );

  $('body').on('change','select.autolink', function(e) {
    var select = $(e.target);
    var go = select.val();
    var anchor = window.location.hash;
    if (go !== '') {
      window.location = go.replace(/\&amp;/, '&') + anchor;
    }
  });

  $('body').on('click', 'form #business_only', showBusinessOnly);
  $('body').on('click', 'form #stakeholders_only', showStakeholdersOnly);
  $('body').on('click', 'form #hide_business_and_stakeholders', hideBusinessAndStakeholders);
  $('body').on('change', '#listing_status_id', function() {
    selected_listing_status = jQuery.trim($("#listing_status_id option:selected").text());
    if (selected_listing_status === "Publicly Listed") {
      $('.public_company_only').show();
    } else {
      $('.public_company_only').hide();
    }
  });

  // hide and show sections for FAQs, titles and descriptions etc.
  $("body").on('click', ".hint_toggle", function(){
    $(this).next(".hint_text").slideToggle();
    $(this).toggleClass('selected');
  });

  // called from views/signup/step5.html.haml
  $("body").on("click", "#contact_foundation_contact", function() {
    $('#errorExplanation').toggle();
    $('#contact_form').toggle();
  });

  $("body").on('click', 'a[data-popup]', function(e) {
      window.open(this.href, 'newWindow', 'left=50,top=50,height=600,width=1024,resizable=1,scrollbars=1');
      e.preventDefault();
   });
});
