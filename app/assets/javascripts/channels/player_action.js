function getUrlParameter(name) {
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    var results = regex.exec(location.search);
    return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
};

// If the 'subgame' query parameter is present, it may affect how we connect.
// So we pass it through.

App.player_action = App.cable.subscriptions.create(
    {
        channel: "PlayerActionChannel",
        subgame: getUrlParameter("subgame")
    },
    {
        connected: function() {
        },
        disconnected: function() {
        },
        received: function(data) {
            if(data.action === "replace") {
                $(data.selector).html(data.content);
                return;
            }
            if(data.action === "run_code") {
                eval(data.code);
                return;
            }
            if(data.action === "subgame") {
                if(data.subgame === "eventing") {
                    return window.EventingSubgame.receive(data);
                }
                console.log("Unknown subgame in subgame action: ", data.subgame)
                return;
            }
            //if(data.action === "") {
            //}
            console.log("Unrecognized action in data: ", data);
            //if(App.chatData.length > 19) {
            //    App.chatData.shift();
            //}
            //App.chatData.push(data.sent_by + ": " + data.body);
            //$(".chatarea").html(App.chatData.join("<br/>"));
        }
    });
