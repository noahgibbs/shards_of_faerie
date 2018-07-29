App.chat = App.cable.subscriptions.create("ChatChannel",
    {
        connected: function() {
            App.chatData = [];
        },
        disconnected: function() {
        },
        received: function(data) {
            console.log("received chat data", data);
            if(App.chatData.length > 19) {
                App.chatData.shift();
            }
            App.chatData.push(data.sent_by + ": " + data.body);
            $(".chatarea").html(App.chatData.join("<br/>"));
        }
    });
