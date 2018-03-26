$(function(){

    // Revenue
    $("#organization_precise_revenue")
        .priceFormat({
            prefix: "$",
            centsLimit: 0,
            clearOnEmpty: true
        });

    // Parent Company
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

    // Video
    var $preview = $("#video-preview");
    if($preview.length < 1) {
        return;
    }

    var embedCodeField = $("#organization_video_embed");
    var refreshButton = $("#video-preview-refresh");

    function refreshVideoPreview(e) {
        if(e) { e.preventDefault(); }

        var embedCode = embedCodeField.val();
        $preview.html(embedCode);
    }

    embedCodeField.on("change", refreshVideoPreview);
    refreshButton.on("click", refreshVideoPreview);
    refreshVideoPreview();
});
