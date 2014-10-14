$(function() {

  var pollingInterval = 3 * 1000; // ms
  var reportTimer;
  var BUILDING_REPORT = 0;
  var REPORT_COMPLETE = 1;

  var dialog = $("#dialog-message");
  var $progress = $('.report-progress');
  var $complete = $('.report-complete');

  $("a[data-remote]").on("ajax:success", function(e, response) {
    var report = JSON.parse(response).report_status;

    $complete.hide();
    $progress.show();
    dialog.dialog("option", "title", "Generating report");
    dialog.dialog("open");
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
        default
          throw "Unexpected report status: " + report.status;
      }
    }, function(error) {
      alert("failed", arguments);
    });
  }

  function onReportCompleted(report) {
    dialog.dialog("option", "title", "Report complete");

    var $link = $('.report-url');
    $link.attr('href', '/admin/reports/download/' + report.id);
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

})
