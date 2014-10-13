$(function() {

  var pollingInterval = 1 * 1000; // ms
  var reportTimer;
  var BUILDING_REPORT = 0;
  var REPORT_COMPLETE = 1;

  $("a[data-remote]").on("ajax:success", function(e, response) {
    var report = JSON.parse(response).report_status;
    if(report.status === BUILDING_REPORT) {
      $('.report-progress').fadeIn();
      pollReport(report.id);
    } else {
      onReportCompleted(report);
    }
  });

  // TODO handle failure

  function pollReport(id) {
    var request = $.ajax({
      url: "/admin/reports/status/" + id,
      method: 'GET',
      dataType: 'json'
    });

    request.then(function(response) {
      var report = response.report_status;
      if(report.status === BUILDING_REPORT) {
        // keep checking
        reportTimer = setTimeout(function() {
          pollReport(report.id);
        }, pollingInterval);
      } else {
        $('.report-progress').fadeOut();
        onReportCompleted(report);
      }
    }, function(error) {
      alert("failed", arguments);
    });
  }

  function onReportCompleted(report) {
    console.log('onReportCompleted');

    var $el = $('.report-complete');
    var $link = $('#report-url');

    $el.fadeIn();
  }
})
