$(function(){
    $("#organization_precise_revenue")
        .priceFormat({
            prefix: "$",
            centsLimit: 2,
            clearOnEmpty: true
        });

    var $parentCompanyId = $('#organization_parent_company_id');
    var $parentCompanyName = $("#organization_parent_company_name");
    var $autocompleteField = $parentCompanyName.data('autocomplete');
    var autocompleteUrl = "/api/v1/autocomplete/" + $autocompleteField + ".json";

    $parentCompanyName.autocomplete({
        source: autocompleteUrl,
        select: function(event, ui) {
            $parentCompanyId.val(ui.item.id);
        }
    });
});
