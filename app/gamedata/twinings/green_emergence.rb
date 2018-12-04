name "green_emergence"

start "1"

# It can be tough to track a data object across things like renames. An ID will do that.
id "7B4D239A-F328-469C-AA8E-A83F2A53DDD0"

style do
  content <<CSS
.green {
  color: green;
};
CSS
end

script do
  content <<JS
// Leftover JavaScript, still here as a placeholder
window.jQuery("#toolbar .saveButton").on("click", function() {
});
JS
end

passage "Awareness" do
  pid 1
  tags []
  content <<PASSAGE
You are floating, bodiless. <span class='green'>Everything is green.</span>

* [[Where am I?]]
* [[Who am I?]]
* [[I think I know who I am]]
PASSAGE
end

passage "Where am I?" do
  content <<PASSAGE
You're not sure. <span class='green'>You're floating in greenness.</span>

As you feel carefully outwards, there are uncountable threads leading to you. Or to
many different creatures (people?) that <i>might</i> be you?

[[Go back to floating|Awareness]]
PASSAGE
end

passage "Who am I?" do
  content <<PASSAGE
You're not sure. <span class='green'>You're still floating in greenness.</span>

It's hard to tell if this is a place, or a feeling, or a point of view.

Perhaps you're all three.

[[Go back to floating|Awareness]]
PASSAGE
end

passage "I think I know who I am" do
  content <<PASSAGE
Everything is hard to remember when <span class='green'>it's green</span>.

But maybe you're coming out of the green, a bit?

[[No, everything is still green|Awareness]]
[[Yes, the green is starting to recede|Emergence]]
PASSAGE
end

passage "Emergence" do
  content <<PASSAGE
The green was feeling very intense, and now it's dimming.

Other colors exist a bit now, up ahead - grays, browns and a spot of twinkling blue.

[[Retreat from the colors|Awareness]]

[[Follow the colors|Hills]]
PASSAGE
end

passage "Hills" do
  content <<PASSAGE
You can see different vistas from here, but only in a blurred, cloudy way. Some glow with
a sort of green-white glowing presence, some are chaotic and violent, some are detached,
some are serene, some are dark, some move quickly and seem to dart...

Most are closed to you. They are far away, but you can feel it - you can't get in now, and
perhaps never.

[[Drift toward green-white light|Purity]]

[[Drift toward violence and chaos|Chaos]]

[[Drift back into the Green behind you|Awareness]]
PASSAGE
end

passage "Chaos" do
  content <<PASSAGE
Here, you can see more of the chaos close-up.

There are windows into wars, endless wars, in the distance.

Here, though, you see a tiny viewpoint into a dark, twisting forest. There are a vast number
of vicious little creatures, hunting each other and fighting. [[See through their eyes?|Vicious Forest]]

[[Drift away from the chaos?|Hills]]

[[Drift far back into the Green behind you?|Awareness]]
PASSAGE
end

passage "Vicious Forest" do
  content <<PASSAGE
There are more points of view than you can possibly tease apart here - like an immense, changing tapestry of
tiny eyes, hunting and watching. From here you can see an entire forest, all at once, but can remember no part
of it.

The forest isn't made of trees, but of some kind of melding of flesh and spirit. It's as though the entire
forest is a living creature, or a group of many of them.

You know (remember?) that if you narrow your point of view down to one creature, you will be (become? join? absorb?)
that creature.

[[Narrow Your Eyes|Vicious Forest Creature]]

[[Drift back into violence and chaos?|War Hills]]

[[Drift far back into the Green behind you?|Awareness]]
PASSAGE
end

passage "Vicious Forest Creature" do
  content <<PASSAGE
<%
  appearance["body"] = "creature"
  # How do I set this character to automatically go to the forest initially?
%>

You can feel your point of view narrowing and shifting. You can feel yourself being this creature.
Your old point of view is left behind (lost?) and your new one awaits you.
PASSAGE
end

passage "Formatting Test" do
  content <<PASSAGE
  Formatting Test (Content)
  <% # This is a test
  %>
  &lt;thingie&gt;
PASSAGE
end
