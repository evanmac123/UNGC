$(function() {
  $("#review_organization_name").autocomplete({
    source: "/api/v1/autocomplete/organizations.json"
  });

    $("#review_event_title").autocomplete({
        source: "/api/v1/autocomplete/events.json"
    });
});
