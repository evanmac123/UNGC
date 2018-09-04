$(function() {

    var $autoCompletable = $("input[data-autocomplete-source]");

    if($autoCompletable.length < 1) {
        return;
    }

    $autoCompletable.each(function(index, input) {
        var $input = $(input);
        var targetSelector = $input.data("autocomplete-target");
        var $target = $(targetSelector);

        var field = $input.data("autocomplete-source");
        var url = "/api/v1/autocomplete/" + field + ".json";

        $input.autocomplete({
            source: url,
            select: function(event, ui) {
                $target.val(ui.item.id);
            }
        });
    });

});
