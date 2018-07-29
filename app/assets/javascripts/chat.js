
$(function() {
    $(".chatbutton").click(function() {
        var input = $(".chatinput")[0].value;
        console.log("Chatting", input);
        $(".chatinput")[0].value = "";
        App.chat.send({ body: input });
    });
});
