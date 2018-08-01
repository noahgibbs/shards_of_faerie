App.player_action = App.cable.subscriptions.create("PlayerActionChannel",
    {
        connected: function() {
        },
        disconnected: function() {
        },
        received: function(data) {
            console.log("received pa data", data);
            if(data.action === "replace") {
                $(data.selector).html(data.content);
                return;
            }
            console.log("Unrecognized action in data:", data);
            //if(App.chatData.length > 19) {
            //    App.chatData.shift();
            //}
            //App.chatData.push(data.sent_by + ": " + data.body);
            //$(".chatarea").html(App.chatData.join("<br/>"));
        }
    });
