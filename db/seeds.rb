# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# One problem with standard Rails DB seeding: it's not
# idempotent. That makes it really hard to do things like modifying,
# adding to or removing from default DB seed data. To do seeding
# right, you basically need DB migrations or something similar - what
# version of the seed data is it currently at? What version does it
# now want to be at? This is a half-assed attempt to update, not just
# create, for that reason.

# We want to make sure we have the appropriate hardcoded subgames available.
title = Subgame.find_or_create_by(:name => "Title")
entwined = Subgame.find_or_create_by(:name => "Entwined")
activity = Subgame.find_or_create_by(:name => "Activity")
