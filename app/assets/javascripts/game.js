$(function() {
    $(".client-area").on("click", ".action-button", function() {
        var act = $(this).attr("click-action");
        App.player_action.send({ gameaction: act });
    });
    setBackground("greenGlow");
});

var bgNum = 0;
function setBackground(data) {
    bgNum++;
    window.backgroundSet = bgNum;
    window.backgroundSetData = data;
}

(function(){
    // Set the background based on the requested appearance.
    if(undefined !== window.backgroundSet) {
        if(undefined === window.lastBackgroundSet) {
            window.lastBackgroundSet = 0;
        }
        // Did the background change? If so, switch it up.
        if(window.lastBackgroundSet !== window.backgroundSet) {
            var clientBgElement = document.getElementById("client-bg");
            if("greenGlow" === window.backgroundSetData) {
                clientBgElement.style.opacity = 0.5;
                clientBgElement.style.background = "url(/img/20180810_Green_glow.png)";
                clientBgElement.style.position = "absolute";
                clientBgElement.style.top = 0;
                clientBgElement.style.left = 0;
                clientBgElement.style.bottom = 0;
                clientBgElement.style.right = 0;
                clientBgElement.style["z-index"] = -1;
                clientBgElement.style.display = "block";
                clientBgElement.style.filter = "hue-rotate(20deg)";
            } else {
                console.log("Didn't recognize window.backgroundSetData!", window.backgroundSetData);
                clientBgElement.style.display = "none";
            }
            window.lastBackgroundSet = window.backgroundSet;
        }
    }

    // Check once every 1 second
    setTimeout(arguments.callee, 1000);
})();
