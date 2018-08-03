$(function() {
    $(".client-area").on("click", ".action-button", function() {
        var act = $(this).attr("click-action");
        App.player_action.send({ gameaction: act });
    });
});
