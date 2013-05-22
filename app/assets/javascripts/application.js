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
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require admin
//= require ckeditor/init
//= require jquery.parsequery.min
//= require jquery.tablesorter.min
//= require jquery.tablesorter.pager
//= require jquery.jeditable.mini
//= require jquery.tree.min
//= require_self
//= require cop_form
//= require dashboard
//= require page_editor

$(document).ajaxSend(function(e, xhr, options) {
 var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
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


function makeChildrenVisible (id) {
  var parent = $("#"+id);
  var children = parent.children('ul')
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
  var children = parent.children('ul')
  if (children[0])
    children[0].style.visibility = 'hidden';
}

function versionNumberAnchor() {
  if (window.location.href.match(/\#/)) {
    var anchor = window.location.href.split('#')[1]
    if (anchor) {
      var version_match = anchor.match(/version_([0-9]+)/)
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
    if (!Watcher.included) {
      Watcher.included = true;
      // include('/javascripts/page_editor.js');
      // include('/ckeditor/ckeditor.js');
    }
    if (response.content) {
      var possible_editor = $('#rightcontent .click_to_edit');
      if (possible_editor.size() > 0)
        possible_editor.remove();
        // $('#rightcontent .click_to_edit').replaceWith(response.editor);
      // else
      $('#rightcontent').prepend(response.editor);
      $('#rightcontent .copy').html(response.content);
    } else {
      $('#rightcontent').prepend(response.editor);
    }
  }
}

$(function() {

  if ($('table.sortable').size() > 0)
      $('table.sortable').tablesorter({widgets: ['zebra']});

  // if ($('table.sortable').size() > 0) {
  //   $('table.sortable').tablesorter({widgets: ['zebra']});
  //   $('table.sortable')
  //    .tablesorter({
  //      widthFixed: true,
  //      widgets: ['zebra']})
  //        .tablesorterPager({
  //      container: $(".pager"),
  //      positionFixed: false,
  //      size: 20
  //    });
  // }
});

$(document).ready(function() {

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

  $('a.edit_content').live('click', function(event) {
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

  $('select.autolink').live('change', function(e) {
    var select = $(e.target);
    var go = select.val();
    var anchor = window.location.hash;
    if (go != '') {
      window.location = go.replace(/\&amp;/, '&') + anchor;
    }
  });

  $('form #business_only').live('click', showBusinessOnly);
  $('form #stakeholders_only').live('click', showStakeholdersOnly);
  $('form #hide_business_and_stakeholders').live('click', hideBusinessAndStakeholders);
  $("#listing_status_id").live('change', function() {
    selected_listing_status = jQuery.trim($("#listing_status_id option:selected").text());
    if (selected_listing_status == "Public Company") {
      $('.public_company_only').show();
    } else {
      $('.public_company_only').hide();
    }
  })

  // hide and show sections for FAQs, titles and descriptions etc.
  $(".hint_toggle").live('click', function(){
    $(this).next(".hint_text").slideToggle();
    $(this).toggleClass('selected');
  });

  // called from views/signup/pledge_form.html.haml
  // disable select if amount is chosen
  $('.fixed_pledge').live('click', function() {
    result = (this.id != 'organization_pledge_amount_100')
    $("#organization_pledge_amount").attr('disabled', result);
  });

  // called from views/signup/step5.html.haml
  $("#contact_foundation_contact").live('click', function() {
    if ($('#errorExplanation').length > 0) {
      $('#errorExplanation').toggle();
    }
    $('#contact_form').toggle();
  });
  $('a[data-popup]').live('click', function(e) {
      window.open(this.href, 'newWindow', 'left=50,top=50,height=600,width=1024,resizable=1,scrollbars=1');
      e.preventDefault();
   });
});

  // public participant search controls
  function showBusinessOnly (argument) {
    $('.for_stakeholders_only').fadeOut('slow')
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

