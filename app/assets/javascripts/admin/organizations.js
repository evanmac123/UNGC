$(function(){
    $("#organization_precise_revenue")
        .priceFormat({
            prefix: "$",
            centsLimit: 2,
            clearOnEmpty: true
        });
});
