$(function() {
    $("#crm_owner_name").autocomplete({
        source: "/api/v1/autocomplete/staff.json",
        select: function(e, ui) {
            e.preventDefault();
            $("#crm_owner_contact_id").val(ui.item.id);
            return false;
        }
    });
});
