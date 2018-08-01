$(function() {
    $(".action-button").click(function() {
        var act = $(this).attr("click-action");
        App.player_action.send({ action: act });
    });
});
