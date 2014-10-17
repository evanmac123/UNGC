$(function() {

  var pollingInterval = 3 * 1000; // ms
  var reportTimer;
  var BUILDING_REPORT = 0;
  var REPORT_COMPLETE = 1;
  var REPORT_ERROR = 2;

  var dialog = $("#dialog-message");

  function showMessage(status) {
    var selector = '.report-' + status;
    $('.message', dialog).hide();
    $(selector, dialog).show();
  }

  function showModal() {
    showMessage('progress');
    dialog.dialog("option", "title", "Generating report");
    dialog.dialog("open");
  }

  // start polling reports kicked off by clicking a remote link
  $("a[data-remote]").on("ajax:success", function(e, response) {
    showModal();
    var report = JSON.parse(response).report_status;
    pollReport(report.id);
  });

  function pollReport(id) {
    var request = $.ajax({
      url: "/admin/reports/status/" + id,
      method: 'GET',
      dataType: 'json'
    });

    request.then(function(response) {
      var report = response.report_status;
      switch(report.status) {
        case BUILDING_REPORT:
          // keep checking
          reportTimer = setTimeout(function() {
            pollReport(report.id);
          }, pollingInterval);
          break;
        case REPORT_COMPLETE:
          onReportCompleted(report);
          break;
        case REPORT_ERROR:
          onReportError();
          break;
        default:
          throw "Unexpected report status: " + report.status;
      }
    }, function(error) {
      onReportError();
    });
  }

  function downloadUrl(report) {
    return '/admin/reports/download/' + report.id + '.' + report.format;
  }

  function onReportCompleted(report) {
    var $link = $('.report-url');
    $link.attr('href', downloadUrl(report));
    $link.text(report.filename);

    dialog.dialog("option", "title", "Report complete");
    showMessage('complete');
    dialog.dialog("open");
  }

  function onReportError() {
    dialog.dialog("option", "title", "Failed");
    showMessage('error');
    dialog.dialog("open");
  }

  $("#dialog-message").dialog({
    modal: true,
    autoOpen: false,
    buttons: {
      Close: function() {
        $(this).dialog( "close" );
      }
    }
  });

  // start polling reports
  var $reportToLoad = $('*[data-report_id]').first();
  if($reportToLoad.length > 0) {
    showModal();
    var id = $reportToLoad.data('report_id');
    pollReport(id);
  }

})
