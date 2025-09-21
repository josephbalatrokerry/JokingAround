


SMODS.Atlas {
	key = "modicon",
	path = "icon.png",
	px = 32,
	py = 32
}

assert(SMODS.load_file("src/Chess.lua"))()
assert(SMODS.load_file("src/Boosters.lua"))()
assert(SMODS.load_file("src/Tags.lua"))()
assert(SMODS.load_file("src/Backs.lua"))()
assert(SMODS.load_file("src/Jokers.lua"))()



SMODS.current_mod.optional_features = { quantum_enhancements = true, retrigger_joker = true }
