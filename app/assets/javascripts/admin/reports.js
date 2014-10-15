$(function() {

  var pollingInterval = 3 * 1000; // ms
  var reportTimer;
  var BUILDING_REPORT = 0;
  var REPORT_COMPLETE = 1;

  var dialog = $("#dialog-message");
  var $progress = $('.report-progress');
  var $complete = $('.report-complete');

  function showModal() {
    $complete.hide();
    $progress.show();
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
          break
        default:
          throw "Unexpected report status: " + report.status;
      }
    }, function(error) {
      alert("failed", arguments);
    });
  }

  function showUrl(report) {
    return '/admin/reports/show/' + report.id + '.' + report.format;
  }

  function onReportCompleted(report) {
    dialog.dialog("option", "title", "Report complete");

    var $link = $('.report-url');
    $link.attr('href', showUrl(report));
    $link.text(report.filename);

    $progress.hide();
    $complete.show();
  }

  $("#dialog-message").dialog({
    modal: true,
    autoOpen: false,
    buttons: {
      Cancel: function() {
        $( this ).dialog( "close" );
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
