SMODS.Atlas {
	key = "JokingAround",
	path = "JokingAround.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "JokingAroundBack",
	path = "JokingAroundBack.png",
	px = 71,
	py = 95
}


SMODS.Atlas {
	key = "modicon",
	path = "icon.png",
	px = 32,
	py = 32
}

SMODS.current_mod.optional_features = { quantum_enhancements = true }

SMODS.Joker {
    key = "bonus",
    unlocked = true,
	loc_txt = {
		name = 'Bonus Joker',
		text = {
			"Gives {C:chips}+#1#{} Chips for each {C:attention}Bonus Card{} and",
			"{C:mult}+#2#{} Mult for each {C:attention}Mult Card{}",
			"in your {C:attention}full deck{}",
			"{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips,",
			"{C:mult}+#4#{C:inactive} Mult)"
		}
	},
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 0, y = 0 },
	atlas = 'JokingAround',
    config = { extra = { mult = 4, chips = 15 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		info_queue[#info_queue + 1] = G.P_CENTERS.m_mult

        local bonus_tally = 0
		local mult_tally = 0
        if G.playing_card then
			for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_bonus') then bonus_tally = bonus_tally + 1 end
            end
			for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_mult') then mult_tally = mult_tally + 1 end
            end
        end
        return { vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.chips * bonus_tally, card.ability.extra.mult * mult_tally} }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local bonus_tally = 0
			local mult_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_bonus') then bonus_tally = bonus_tally + 1 end
			end
			for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_mult') then mult_tally = mult_tally + 1 end
            end
			return {
					chips = card.ability.extra.chips * bonus_tally,
					mult = card.ability.extra.mult * mult_tally,
					card = context.other_card
				}
        end
    end,
    in_pool = function(self, args) 
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_bonus') or SMODS.has_enhancement(playing_card, 'm_mult') then
                return true
            end
        end
        return false
    end
}

local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.chisel_card = { suit = 'Spades', rank = 'Ace', id = 14 }
	ret.current_round.chisel_card_cnt = 0
	return ret
end

local remove_ref = Card.remove
function Card:remove()
   local ret = remove_ref(self)
   if G.playing_cards then
    if self:get_id() == G.GAME.current_round.chisel_card.id and self:is_suit(G.GAME.current_round.chisel_card.suit) then
	    chisel_card_destroyed = true
	    G.GAME.current_round.chisel_card_cnt = G.GAME.current_round.chisel_card_cnt + 1
		reset_vremade_chisel_card(G.GAME.current_round.chisel_card_cnt)
	end
end
   return ret 
end




--[[ 

local score_ref = Card.score
function Card:score()
    print('test')
   local ret = score_ref(self)
   table.insert(G.GAME.current_round.ranks_played, self:get_id())
   return ret 
end
 ]]









SMODS.Joker {
    key = "chisel", 
		loc_txt = {
		name = 'Chisel',
		text = {			
			"This Joker gains {X:mult,C:white}X#1#{} Mult",
            "when {C:attention}#2#{} of {V:1}#3#{} is destroyed,",
			"{s:0.8}card changes when {s:0.8,C:attention}#2#{s:0.8} of {s:0.8,V:1}#3#{s:0.8} is destroyed",
            "{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)"

		}
	},
    perishable_compat = false,
    unlocked = true,
	atlas = 'JokingAround',
    blueprint_compat = true,
    rarity = 3,
    cost = 8,
    pos = { x = 1, y = 0 },
    config = { extra = { xmult = 1, xmult_gain = 0.75 } },
loc_vars = function(self, info_queue, card)
        local chisel_card = G.GAME.current_round.chisel_card or { rank = 'Ace', suit = 'Spades' }
        return { vars = { card.ability.extra.xmult_gain, localize(chisel_card.rank, 'ranks'), localize(chisel_card.suit, 'suits_plural'), 	colours = { G.C.SUITS[chisel_card.suit] }, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local chisel_card_destroyed = false
            for _, removed_card in ipairs(context.removed) do
                if removed_card:get_id() == G.GAME.current_round.chisel_card.id and removed_card:is_suit(G.GAME.current_round.chisel_card.suit) then
					chisel_card_destroyed = true
				 	G.GAME.current_round.chisel_card_cnt =	G.GAME.current_round.chisel_card_cnt + 1
					reset_vremade_chisel_card(G.GAME.current_round.chisel_card_cnt)
				end
            end
			
            if chisel_card_destroyed then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } } }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}

function reset_vremade_chisel_card(chisel_card_cnt)
    G.GAME.current_round.chisel_card = { rank = 'Ace', suit = 'Spades' }
    local valid_chisel_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(playing_card) and not SMODS.has_no_rank(playing_card) then
            valid_chisel_cards[#valid_chisel_cards + 1] = playing_card
        end
    end
    local picked_chisel_card = pseudorandom_element(valid_chisel_cards, pseudoseed('chisel' .. G.GAME.round_resets.ante))
    if picked_chisel_card then
        G.GAME.current_round.chisel_card.rank = picked_chisel_card.base.value
        G.GAME.current_round.chisel_card.suit = picked_chisel_card.base.suit
        G.GAME.current_round.chisel_card.id = picked_chisel_card.base.id
    end
end




SMODS.Joker {
    key = "snowballing",
    unlocked = true,
	loc_txt = {
		name = 'Snowballing Joker',
		text = {	
			"When {C:attention}Blind{} is selected, set Hands to {C:chips}#1#{},",
			"retrigger all played cards for each",
			"Hand lost this way"
		}
	},
    blueprint_compat = true,
	atlas = 'JokingAround',
    rarity = 3,
    cost = 8,
    pos = { x = 4, y = 0 },
    config = { extra = { hands = 1, retriggers = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
			card.ability.extra.retriggers = G.GAME.current_round.hands_left - card.ability.extra.hands
            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_hands_played(-G.GAME.current_round.hands_left + card.ability.extra.hands)
                            SMODS.calculate_effect(
                                { message = string.format('-%d Hands', card.ability.extra.retriggers)},
                                context.blueprint_card or card)
                            return true
                        end
                    }))
                end
            }
                
        end
		if context.cardarea == G.play and context.repetition and not context.repetition_only then
				return {
					message = 'Again!',
					repetitions = card.ability.extra.retriggers,
					card = context.other_card
				}
		end
    end

}



SMODS.Joker {
    key = "shopaholism",
    unlocked = true,
	loc_txt = {
		name = 'Shopaholism',
		text = {
			"This Joker gains {X:mult,C:white}X#1#{} Mult when a Joker is bought,",
			"resets when a Joker is sold",
			"{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
		}
	},
    perishable_compat_compat = false,
    blueprint_compat = true,
    rarity = 2,
	atlas = 'JokingAround',
    cost = 6,
    pos = { x = 3, y = 0},
    config = { extra = { xmult_gain = 0.5, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize('k_upgrade_ex')
            }
        end
        if context.selling_card and context.card.ability.set == 'Joker' and card.ability.extra.xmult > 1 and not context.blueprint then
                card.ability.extra.xmult = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}


SMODS.Joker {
    key = "dystopia",
    unlocked = true,
	loc_txt = {
		name = 'Dystopia',
		text = {
			"If all played cards share the same suit and",
            "played hand is not {C:attention}Flush{},",
			"all played cards give {X:mult,C:white}X#1#{} Mult"
		}
	},
    blueprint_compat = true,
    rarity = 3,
    cost = 7,
	atlas = 'JokingAround',
    pos = { x = 4, y = 1 },
    config = { extra = { xmult = 1.5} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			cards_have_same_suit = true
			first_card_suit = context.scoring_hand[1].base.suit
			for _, scored_card in pairs(context.scoring_hand) do
				if not scored_card:is_suit(first_card_suit) then
					cards_have_same_suit = false
				end
			end
	 		if cards_have_same_suit and not (context.scoring_name == 'Flush') then
            return {
                xmult = card.ability.extra.xmult
            }
		end
		end
    end
}



--[[ SMODS.Joker {
    key = "verdantjoker",
		loc_txt = {
		name = 'Verdant Joker',
		text = {
			"This Joker gains {C:mult}+#1#{} Mult for each",
			"remaining Hand at the end of round",
			"{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)"
		}
	},
    unlocked = true,
    blueprint_compat = true,
    rarity = 1,
	atlas = 'JokingAround',

    cost = 4,
    pos = { x = 4, y = 4 },
    config = { extra = { mult = 0, mult_gain = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and context.game_over == false and G.GAME.current_round.hands_left > 0 then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain * G.GAME.current_round.hands_left
		return {
                message = localize('k_upgrade_ex'),
                colour = G.C.RED
            }
		end
		if context.joker_main then
			    return {
                mult = card.ability.extra.mult
            }
		end
		
    end
} ]]


SMODS.Joker {
    key = "income",
	loc_txt = {
		name = 'Income Report',
		text = {
			"This Joker gains {C:mult}+#1#{} Mult at the end of", 
            "the shop if you have exactly {C:money}#2#${}",
			"{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
		}
	},
    perishable_compat = false,
    unlocked = true,
    blueprint_compat = true,
    rarity = 1,
	atlas = 'JokingAround',
    cost = 4,
    pos = { x = 2, y = 0 },
    config = { extra = { mult = 0, mult_gain = 6, dollars = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.dollars, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
		if context.ending_shop and context.main_eval and G.GAME.dollars == card.ability.extra.dollars and not context.blueprint then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain 
			return {
                message = localize('k_upgrade_ex'),
                colour = G.C.RED
            }
		end
		if context.joker_main then
			    return {
                mult = card.ability.extra.mult
            }
		end
    end
}



--[[ 
SMODS.Joker {
    key = "alloy",
	loc_txt = {
		name = 'Alloy',
		text = {
			"{C:attention}Steel Cards{} held in hand give {C:money}#1#${} at end of round,",
			"{C:attention}Gold Cards{} held in hand give {X:mult,C:white}X#2#{} Mult"
		}
	},
    unlocked = true,
    blueprint_compat = false,
    rarity = 2,
	atlas = 'JokingAround',
    cost = 5,
    pos = { x = 1, y = 1 },
    config = { extra = { xmult = 1.5, dollars = 3 } },
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { card.ability.extra.dollars, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_gold') then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    mult = card.ability.extra.xmult
                }
            end
        end
		if context.individual and context.cardarea == G.hand and context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_steel') then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
				G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                    return {
                        dollars = card.ability.extra.dollars,
                        func = function() 
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.dollar_buffer = 0
                                    return true
                                end
                            }))
						end
					}
            end
        end
    end,
    in_pool = function(self, args) 
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_steel') or SMODS.has_enhancement(playing_card, 'm_gold') then
                return true
            end
        end
        return false
    end
    
} ]]

SMODS.Joker {
    key = "canvas",
    unlocked = true,
	loc_txt = {
		name = 'Canvas',
		text = {
			"{C:attention}+#1#{} hand size at first hand of round",
		}
	},
    blueprint_compat = false,
    rarity = 2,
	atlas = 'JokingAround',
    cost = 6,
    pos = { x = 3, y = 1 },
    config = { extra = { h_size = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            G.hand:change_size(card.ability.extra.h_size)
		end
		if (G.GAME.current_round.hands_played == 0 and context.after and context.main_eval) or (context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint and G.GAME.current_round.hands_played < 1 ) then
			G.hand:change_size(-card.ability.extra.h_size)
	end
    end
}

local oldsetcost = Card.set_cost
function Card:set_cost()
    local g = oldsetcost(self)
    if next(SMODS.find_card("j_joking_consolidation")) then 
        self.sell_cost = self.cost
    end
    return g
end

SMODS.Joker {
    key = "consolidation",
    unlocked = true,
	loc_txt = {
		name = 'Consolidation',
		text = {
			"{C:attention}Sell value{} of every {C:attention}Joker{} and {C:attention}Consumable{}",
            "becomes equal to it's{C:attention} cost"
		}
	},
    blueprint_compat = false,
    rarity = 1,
	atlas = 'JokingAround',
    cost = 4,
    pos = { x = 0, y = 1 },
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
	remove_from_deck = function(self, card, from_debuff)
            for _, area in ipairs({ G.jokers, G.consumeables }) do
                for _, other_card in ipairs(area.cards) do
                    if other_card.set_cost then
                        other_card.ability.extra_value = math.ceil((other_card.ability.extra_value - (card.sell_cost/2)) / 2) 
                        other_card:set_cost()
                    end
                end
            end
    end,
	add_to_deck = function(self, card, from_debuff)
		for _, area in ipairs({ G.jokers, G.consumeables }) do
                for _, other_card in ipairs(area.cards) do
                    local uneven = other_card.cost % 2
                    if other_card.set_cost then
                        other_card.ability.extra_value = math.ceil((((other_card.ability.extra_value or 0) - (other_card.ability.extra_value or 0)  +  other_card.cost ) / 2))
                        other_card:set_cost()
                    end

                end
            end
    end
}

SMODS.Joker {
    key = "aim",
    loc_txt = {
		name = 'Aim',
		text = {
			"if played hand contains {C:attention}#2#{} card,",
            "retrigger it {C:attention}#1#{} additional times"
		}
	},
    blueprint_compat = true,
    rarity = 3,
    atlas = 'JokingAround',
    cost = 9,
    pos = { x = 2, y = 1 },
    config = { extra = { repetitions = 3, size = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions, card.ability.extra.size } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only and #context.full_hand == card.ability.extra.size then
            return {
                repetitions = card.ability.extra.repetitions,
                card = context.other_card,
                message = 'Again!'
            }
        end
    end
}


SMODS.Joker {
    key = "pinata",
    loc_txt = {
		name = 'Pinata',
		text = {
			"Create a pair of random negative {C:attention}Consumables{}",
            "when {C:attention}Blind{} is selected",
            "{C:inactive}(#1# Rounds left){}",
            "{s:0.8,C:green}#2# in #3#{s:0.8} chance for creating a {C:spectral,s:0.8}Spectral{} card,",
            "{s:0.8,C:green}#2# in #4#{s:0.8} chance for creating a {C:planet,s:0.8}Planet{} card.",
            "{s:0.8}If neither trigger, create a {C:tarot,s:0.8}Tarot{s:0.8} card"
		}
	},
    unlocked = true,
    blueprint_compat = false,
    rarity = 2,
    cost = 8,
    eternal_compat = false,
    atlas = 'JokingAround',
    pos = { x = 4, y = 2 },
    config = { extra = {rounds_left = 3, spectral_odds = 6, planet_odds = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, (G.GAME.probabilities.normal or 1), card.ability.extra.spectral_odds, card.ability.extra.planet_odds} }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            local consumable_1 = 'Tarot'
            local consumable_2 = 'Tarot'
            if pseudorandom('joking_spectral_pinata') < G.GAME.probabilities.normal / card.ability.extra.spectral_odds then
                consumable_1 = 'Spectral'
            else
                if pseudorandom('joking_planet_pinata') < G.GAME.probabilities.normal / card.ability.extra.planet_odds then
                    consumable_1 = 'Planet'
                end
            end
            
            if pseudorandom('joking_spectral_pinata') < G.GAME.probabilities.normal / card.ability.extra.spectral_odds then
                consumable_2 = 'Spectral'
            else
                if pseudorandom('joking_planet_pinata') < G.GAME.probabilities.normal / card.ability.extra.planet_odds then
                    consumable_2 = 'Planet'
                end
            end
            
            if card.ability.extra.rounds_left <= 1 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- This replicates the food destruction effect
                        -- If you want a simpler way to destroy Jokers, you can do card:start_dissolve() for a dissolving animation
                        -- or just card:remove() for no animation
                            SMODS.add_card ({
                            set = consumable_1,
                            key_append = 'joking_pinata',
                            edition = 'e_negative'
                        })
                            SMODS.add_card ({
                            set = consumable_2,
                            key_append = 'joking_pinata',
                            edition = 'e_negative'
                        })
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                card:remove()
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = 'Beaten!'
                }

            else
                card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
                G.E_MANAGER:add_event(Event({
                func = function()
                        SMODS.add_card ({
                            set = consumable_1,
                            key_append = 'joking_pinata',
                            edition = 'e_negative'
                        })
                        SMODS.add_card ({
                            set = consumable_2,
                            key_append = 'joking_pinata',
                            edition = 'e_negative'
                        })
                        SMODS.calculate_effect({ message = 'Ouch!', colour = G.C.MULT },
                                context.blueprint_card or card)
                        return true
                end
            }))
        end 
        end
    end
}


SMODS.Joker {
    key = "aristocracy",
    loc_txt = {
		name = 'Aristocracy',
		text = {
			"When {C:attention}Boss Blind{} is defeated, create {C:spectral}Wraith{}",
            "{C:inactive}(Must have room){}"
		}
	},
    unlocked = true,
    blueprint_compat = true,
    rarity = 2,
    cost = 8,
    atlas = 'JokingAround',
    pos = { x = 3, y = 2 },
    config = { extra = {wraith_amount = 1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.wraith_amount} }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            if G.GAME.blind.boss and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                return {
                    func = function()
                        -- This is for retrigger purposes, Jokers need to return something to retrigger
                        -- You can also do this outside the return and `return nil, true` instead
                        G.E_MANAGER:add_event(Event({
                            func = (function()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        SMODS.add_card {
                                            set = 'Spectral',
                                            key_append = 'joking_aristocracy',
                                            key = 'c_wraith'-- Optional, useful for checking the source of the creation in `in_pool`.
                                        }
                                        G.GAME.consumeable_buffer = 0
                                        return true
                                    end
                                }))
                                SMODS.calculate_effect({ message = localize('k_plus_spectral'), colour = G.C.BLUE },
                                    context.blueprint_card or card)
                                return true
                            end)
                        }))
                    end
                }
            end
        end
    end
}

SMODS.Joker {
    key = "ransom",
    loc_txt = {
		name = 'Ransom Joker',
		text = {
            "When a hand is played, add {C:attention}arithmetic mean{} of Chips",
            "of all scored cards to this Joker's Chips",
            "{C:inactive}(Currently {C:blue}+#1#{C:inactive} Chips, can gain maximum #2# Chips per hand)"
		}
	},
    unlocked = true,
    perishable_compat = false,
    rarity = 1,
    cost = 6,
    atlas = 'JokingAround',
    pos = { x = 0, y = 2 },
    config = { extra = {chips = 0, cap = 25} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chips, card.ability.extra.cap} }
    end,

    calculate = function(self, card, context)  
        if context.before and context.main_eval and not context.blueprint then
            local chip_mod = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                chip_mod = chip_mod + scored_card:get_chip_bonus() 
            end
            chip_mod = math.min(card.ability.extra.cap, math.ceil((chip_mod / #context.scoring_hand)))
            card.ability.extra.chips = card.ability.extra.chips + chip_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
            }
        end
        if context.joker_main then
            return {
                    chips = card.ability.extra.chips
                }
            end
    end
}


SMODS.Joker {
    key = "fourleaf",
    loc_txt = {
		name = 'Four-leaf Mirror',
		text = {
            "{C:attention}Lucky{} cards are considered {C:attention}Glass{} cards,",
            "{C:attention}Glass{} cards are considered {C:attention}Lucky{} cards"
		}
	},
    blueprint_compat = false,
    unlocked = true,
    rarity = 2,
    cost = 5,
    atlas = 'JokingAround',
    pos = { x = 1, y = 1 },
    pixel_size = { h = 71 },
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chips} }
    end,

    calculate = function(self, card, context)  
        if context.check_enhancement then
            if context.other_card.config.center.key == "m_glass" then
                return {m_lucky = true}
            end
            if context.other_card.config.center.key == "m_lucky" then
                return {m_glass = true}
            end
        end
    end
}


SMODS.Joker {
    key = "love",
    loc_txt = {
		name = 'Love Letter',
		text = {
            "All scored cards have {C:green}#1# in #2#{} chance to become {C:hearts}#3#",
            "if played hand contains a {C:attention}#4#{}",
		}
	},
    unlocked = true,
    rarity = 1,
    cost = 3,
    atlas = 'JokingAround',
    pos = { x = 1, y = 2 },
    blueprint_compat = true,
    config = { extra = {suit = 'Hearts', type = 'Pair', odds = 2} },
    loc_vars = function(self, info_queue, card)
        return { vars = {G.GAME.probabilities.normal, card.ability.extra.odds, card.ability.extra.suit, card.ability.extra.type} }
    end,

    calculate = function(self, card, context)  
        if context.before and context.main_eval and not context.blueprint and next(context.poker_hands[card.ability.extra.type]) then
            local procs = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                if pseudorandom('joking_date') < G.GAME.probabilities.normal / card.ability.extra.odds and scored_card.base.suit ~= card.ability.extra.suit then
                    procs = procs + 1
                    SMODS.change_base(scored_card, card.ability.extra.suit)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end
            if procs > 0 then
            return {
                    message = card.ability.extra.suit,
                    colour = G.C.RED
                }
            end
        end
    end
}


SMODS.Joker {
    key = "come",
    loc_txt = {
		name = 'Comeback',
		text = {
            "{X:mult,C:white}X#1#{} Mult if the last {C:attention}discarded{} poker hand is played, ",
            "{C:inactive}(Last discarded hand: {C:attention}#2#{C:inactive},",
            "{C:inactive}becomes {C:attention}None{C:inactive} after last discarded hand is played)"
		}

	},
    blueprint_compat = true,
    unlocked = true,
    rarity = 3,
    cost = 7,
    atlas = 'JokingAround',
    pos = { x = 2, y = 2 },
    config = { extra = {xmult = 4, discarded_type = 'None'} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.xmult, card.ability.extra.discarded_type} }
    end,

    calculate = function(self, card, context)  
        if context.pre_discard and not context.hook and not context.blueprint then
            local text, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            card.ability.extra.discarded_type = text
            return
            {
                message = text
            }
        end
        if context.joker_main then
            if context.scoring_name == card.ability.extra.discarded_type then
                card.ability.extra.discarded_type = 'None'
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}



SMODS.Joker {
    key = "conspiracy",
    loc_txt = {
		name = 'Conspiracy',
		text = {
			"Create a random {C:spectral}Spectral{} card for each {C:attention}#1#",
            "{C:attention}consecutive rerolls{} in {C:money}the shop",
            "{C:inactive}(Must have space, #2# rerolls left)"
		}
	},
    blueprint_compat = false,
    rarity = 2,
    atlas = 'JokingAround',
    cost = 6,
    pos = { x = 2, y = 3 },
    config = { extra = {rerolls = 3, rerolls_left = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rerolls, card.ability.extra.rerolls_left } }
    end,
    calculate = function(self, card, context)
            if context.reroll_shop then
                card.ability.extra.rerolls_left = card.ability.extra.rerolls_left - 1
                if card.ability.extra.rerolls_left == 0 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    card.ability.extra.rerolls_left = card.ability.extra.rerolls
                return {
                func = function()
                    -- This is for retrigger purposes, Jokers need to return something to retrigger
                    -- You can also do this outside the return and `return nil, true` instead
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    SMODS.add_card {
                                        set = 'Spectral',
                                        key_append = 'joking_conspiracy' -- Optional, useful for checking the source of the creation in `in_pool`.
                                    }
                                    G.GAME.consumeable_buffer = 0
                                    return true
                                end
                            }))
                            SMODS.calculate_effect({ message = localize('k_plus_spectral'), colour = G.C.BLUE },
                                context.blueprint_card or card)
                            return true
                        end)
                    }))
                end
            }
            else
                    if card.ability.extra.rerolls_left == 0 then
                        card.ability.extra.rerolls_left = card.ability.extra.rerolls
                    end
                        return {
                            message = '...',
                            colour = G.C.PURPLE
                        }

            end 
        end
    
        


        if context.ending_shop and not context.blueprint and card.ability.extra.rerolls_left ~= card.ability.extra.rerolls then
            card.ability.extra.rerolls_left = card.ability.extra.rerolls
            return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
        end
    end
}












--[[ 
SMODS.Joker {
    key = "test",
    loc_txt = {
		name = 'Extrovert',
		text = {
            "Gains +#1# Chips for each Face Card held in hand,",
            "resets if a face card is played",
            "{С:inactive}(Currently {C:chips}+#2#{C:inactive})"
		}
	},
    unlocked = true,
    perishable_compat = false,
    rarity = 1,
    cost = 4,
    atlas = 'JokingAround',
    pos = { x = 7, y = 2 },
    config = { extra = {chips = 0, chip_gain = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chip_gain, card.ability.extra.chips} }
    end,

    calculate = function(self, card, context)  
        if context.before and context.main_eval and not context.blueprint then
            local faces = 0
            for _, held_card in ipairs(G.hand.cards) do
                if held_card:is_face() then
                    faces = faces + 1
                end
            end
            for _, playing_card in ipairs(context.scoring_hand) do
                if playing_card:is_face() then
                    card.ability.extra.mult = 0
                    return {
                        message = localize('k_reset'),
                    }       
                end
            end
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain * faces
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
            }

        end
--[[         if context.before and context.main_eval and not context.blueprint then
            local faces = 0
            for _, held_card in ipairs(G.hand.cards) do
                if held_card:is_face() then
                    faces = faces + 1
                end
            end
            if faces == 1 then
                card.ability.extra.mult = 0
                    return {
                        message = localize('k_reset')
                    }
            else
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain * faces
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                }
            end
        end ]]









SMODS.Back {
    key = "everchanging",
    pos = { x = 0, y = 0 },
    config = { extra = { hand_size = 1} },
    unlocked = true,
    loc_txt = {
        name = "Everchanging Deck",
        text ={
            "{C:attention}+#1#{} hand size,",
            "all cards held in hand",
            "at the end of round",
            "change their {C:attention}suits,",
            "{C:attention}ranks{} and enhancement",
            "(if the card has one)"
        },
    },
    atlas = 'JokingAroundBack',

    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.hand_size} }
    end,
    apply = function(self, back)
        G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + self.config.extra.hand_size
    end,
    
    calculate = function(self, back, context)
        if context.individual and context.cardarea == G.hand and context.end_of_round  then
                local everchanging_suits = {}
                for k, v in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
                    if v ~= context.other_card.base.suit then
                        everchanging_suits[#everchanging_suits + 1] = v
                    end
                end
                local new_suit = pseudorandom_element(everchanging_suits, pseudoseed('joking_everchanging' .. G.GAME.round_resets.ante))
                SMODS.change_base(context.other_card, new_suit)
                local everchanging_ranks = {}
                for k, v in ipairs({ '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace' }) do
                    if v ~= context.other_card.base.value then
                        everchanging_ranks[#everchanging_ranks + 1] = v
                    end
                end
                local new_rank = pseudorandom_element(everchanging_ranks, pseudoseed('joking_everchanging' .. G.GAME.round_resets.ante))

                SMODS.change_base(context.other_card, nil, new_rank)
                if next(SMODS.get_enhancements(context.other_card)) then
                    context.other_card:set_ability(SMODS.poll_enhancement({guaranteed=true}))
                end
                G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_card:juice_up()
                            return true
                        end
                    }))
        end
    end
}



function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end



SMODS.Joker {
    key = "whet",
    loc_txt = {
		name = 'Whetstone',
		text = {
			"Gives {X:mult,C:white}X#1#{} Mult when a card is played if",
            "it's rank was played in a previous hand this round"
		}
	},

    blueprint_compat = true,
    rarity = 2,
    cost = 7,
    atlas = 'JokingAround',
    pos = { x = 1, y = 4 },
    config = { extra = { Xmult = 1.5, played_ranks = {}} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.after and context.main_eval and not context.blueprint then
            for _, scored_card in ipairs(context.scoring_hand) do
                if not table_contains(card.ability.extra.played_ranks, scored_card:get_id()) then
                    table.insert(card.ability.extra.played_ranks, scored_card:get_id())
                end
            end
        end
        if context.individual and context.cardarea == G.play then
            local rank_already_played = false
            for _, rank in ipairs(card.ability.extra.played_ranks) do
                
                 if context.other_card:get_id() == rank then
                    rank_already_played = true
                end
            end
            if rank_already_played then
                return {
                    xmult = card.ability.extra.Xmult
                }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            
        for i = 1, #card.ability.extra.played_ranks do
            card.ability.extra.played_ranks[i] = nil
        end

        end
    end,
}





SMODS.Joker {
    key = "french",
    loc_txt = {
		name = 'Revolution',
		text = {
			"Sell this Joker to set your money to {C:money}#4#$,",
            "create {C:tarot}Hanged Man{} for each {C:money}#1#${} lost",
            "{C:inactive}(Space is not neccesary,",
            "{C:inactive}maximum #2#, currently #3#)"

		}
	},
    blueprint_compat = true,
    rarity = 1,
    atlas = 'JokingAround',
    cost = 10,
    pos = { x = 2, y = 4 },
    config = { extra = { money = 10, cap = 4, set_money = 0} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, card.ability.extra.cap, math.max(0, math.min(card.ability.extra.cap, math.floor(G.GAME.dollars / card.ability.extra.money))), card.ability.extra.set_money } }
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra_value = card.ability.extra_value - card.sell_cost
        card:set_cost()
    end,
    calculate = function(self, card, context)
        if context.selling_self then
                if G.GAME.dollars ~= 0 then
                    local hm_to_create = math.max(0, math.min(card.ability.extra.cap, math.floor(G.GAME.dollars / card.ability.extra.money)))
                    ease_dollars(-G.GAME.dollars + card.ability.extra.set_money, true)
                
                G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, hm_to_create do
                        SMODS.add_card {
                                            set = 'Tarot',
                                            key_append = 'joking_french',
                                            key = 'c_hanged_man'-- Optional, useful for checking the source of the creation in `in_pool`.
                                        }
                    end
                    return true
                end
                }))

                return {
                    message = string.format("+%d Tarots", hm_to_create),
                    colour = G.C.PURPLE,
                }
            end
        
        end
        
    end,
}












SMODS.Joker {
    key = "washing",
    loc_txt = {
		name = 'Washing Machine',
		text = {
			"Destroy all scored {C:attention}enhanced{} cards"
		}
	},
    blueprint_compat = false,
    rarity = 1,
    cost = 5,
    atlas = 'JokingAround',
    pixel_size = { h = 91 },
    pos = { x = 3, y = 3 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and context.destroying_card and context.destroy_card.config.center.key ~= 'c_base' then
            return
            {
                remove = true
            }
        end
    end,
}





SMODS.Joker {
    key = "travel",
    loc_txt = {
		name = 'Traveller',
		text = {
			"All played cards become",
            "{C:attention}Bonus{} or {C:attention}Mult{} cards when scored"
		}
	},
    blueprint_compat = false,
    rarity = 3,
    cost = 7,
    atlas = 'JokingAround',
    pos = { x = 4, y = 3 },
    config = { extra = { odds = 2} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then
            for _, scored_card in ipairs(context.scoring_hand) do
                if pseudorandom('joking_travel') < 1 / card.ability.extra.odds then
                    scored_card:set_ability('m_bonus', nil, true)
                else
                    scored_card:set_ability('m_mult', nil, true)
                end
                G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))

            end
        end

    end,
}








SMODS.Joker {
    key = "gamblers",
    loc_txt = {
		name = 'Gamblers Anonymous',
		text = {
			"{X:mult,C:white}X#1#{} Mult, {C:red}debuff{} all playing cards"
		}
	},
    blueprint_compat = false,
    atlas = 'JokingAround',
    rarity = 2,
    cost = 7,
    pos = { x = 0, y = 4 },
    config = { extra = { xmult = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult} }
    end,
    update = function(self, card, dt)
		if G.deck and card.added_to_deck then
			for i, v in pairs(G.deck.cards) do
					v:set_debuff(true)
			end
		end
		if G.hand and card.added_to_deck then
			for i, v in pairs(G.hand.cards) do
					v:set_debuff(true)
			end
		end
	end,


    calculate = function(self, card, context)
        if context.joker_main then
            return
            {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}










SMODS.Joker {
    key = "mustache",
    loc_txt = {
		name = 'Mustached Joker',
		text = {
            "Gain {C:money}#1#${} when skipping a blind"
		}

	},
    blueprint_compat = true,
    unlocked = true,
    rarity = 1,
    cost = 5,
    atlas = 'JokingAround',
    pos = { x = 3, y = 4 },
    config = { extra = {dollars = 8} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.dollars} }
    end,

    calculate = function(self, card, context)  
        if context.skip_blind and context.main_eval then 
            return {
                dollars = card.ability.extra.dollars,
                func = function() -- This is for timing purposes, it runs after the dollar manipulation
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}







SMODS.Joker {
    key = "bill",
    loc_txt = {
		name = 'Dollar Bill',
		text = {
            "Earn {C:money}$#1#{} for each {C:attention}#2#{} cards with {C:clubs}#3#{} suit",
            "in your {C:attention}full deck{} at end of round",
            "{C:inactive}(Currently {C:money}$#4#{C:inactive})"
		}

	},
    blueprint_compat = false,
    unlocked = true,
    rarity = 2,
    cost = 7,
    atlas = 'JokingAround',
    pos = { x = 4, y = 4 },
    config = { extra = {dollars = 1, suit = 'Clubs', for_each = 3} },
    loc_vars = function(self, info_queue, card)
        local club_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.base.suit == card.ability.extra.suit then club_tally = club_tally + 1 end
            end
        end
        local total_money = math.floor((club_tally * card.ability.extra.dollars) / card.ability.extra.for_each)
        return { vars = {card.ability.extra.dollars, card.ability.extra.for_each, localize(card.ability.extra.suit, 'suits_singular'), total_money } }
    end,

    calc_dollar_bonus = function(self, card)
        local club_tally = 0
        for _, playing_card in ipairs(G.playing_cards) do
            if playing_card.base.suit == card.ability.extra.suit then club_tally = club_tally + 1 end
        end
        return club_tally > 0 and math.floor((club_tally * card.ability.extra.dollars) / card.ability.extra.for_each) or nil
    end
}



SMODS.Joker {
    key = "tie",
    loc_txt = {
		name = 'Long Necktie',
		text = {
            "If played hand contains a {C:attention}Straight{}, this Joker gains",
            "{C:mult}+#1#{} Mult for each scored rank it shares",
            "with previous {C:attention}Straight",
            "{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult, previous Straight",
            "{C:inactive}consisted of #3#, #4#, #5#, #6#, #7#)"
		}

	},
    blueprint_compat = true,
    perishable_compat = false,
    unlocked = true,
    rarity = 2,
    cost = 6,
    atlas = 'JokingAround',
    pos = { x = 0, y = 5 },
    config = { extra = {mult = 0, mult_gain = 1, previous_straight = {'None', 'None', 'None', 'None', 'None'}} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult, 
        card.ability.extra.previous_straight[1], card.ability.extra.previous_straight[2],  card.ability.extra.previous_straight[3], 
        card.ability.extra.previous_straight[4], card.ability.extra.previous_straight[5],} }
    end,

    calculate = function(self, card, context)  
        if context.before and context.main_eval and not context.blueprint and next(context.poker_hands['Straight']) then
            local share_tally = 0
            local accum = {'None', 'None', 'None', 'None', 'None'}
            for ind, scored_card in ipairs(context.scoring_hand) do
                for _, past_scored_rank in ipairs(card.ability.extra.previous_straight) do
                    if scored_card.base.value == past_scored_rank then
                        share_tally = share_tally + 1
                    end
                end
                accum[ind] = context.scoring_hand[ind].base.value
            end
            for ind, rank in ipairs(accum) do
                card.ability.extra.previous_straight[ind] = accum[ind]
            end
            if share_tally > 0 then
                card.ability.extra.mult = card.ability.extra.mult + share_tally * card.ability.extra.mult_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return
            {
                mult = card.ability.extra.mult
            }
        end
    end

}


SMODS.Joker {
    key = "credits",
    loc_txt = {
		name = 'Roll the Credits',
		text = {
            "Each played card gives {X:mult,C:white}X#1#{} Mult",
            "on {C:attention}final hand{} of round"
        }

	},
    blueprint_compat = true,
    unlocked = true,
    rarity = 3,
    cost = 8,
    atlas = 'JokingAround',
    pos = { x = 1, y = 5 },
    config = { extra = { xmult = 1.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)  
        if context.individual and context.cardarea == G.play and G.GAME.current_round.hands_left == 0 then
            return
            {
                xmult = card.ability.extra.xmult
            }
        end
    end

}

SMODS.Joker {
    key = "earth",
    loc_txt = {
		name = 'Earthquake',
		text = {
            "Each {C:attention}Stone{} card held in hand",
            "gives {C:chips}+#1#{} Chips"
        }

	},
    blueprint_compat = true,
    unlocked = true,
    rarity = 1,
    cost = 5,
    atlas = 'JokingAround',
    pos = { x = 3, y = 5 },
    config = { extra = { chips = 50 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)  
        if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, 'm_stone') then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
    end

}









SMODS.Joker {
    key = "prayer",
    loc_txt = {
		name = 'Prayer Card',
		text = {
            "{C:green}#1# in amount of hands left{} chance to",
            "create a {C:tarot}Tarot{} card when a hand is played",
            "{C:inactive}(Currently {C:green}1 in #2#{C:inactive})"
        }

	},
    blueprint_compat = true,
    unlocked = true,
    rarity = 2,
    cost = 6,
    atlas = 'JokingAround',
    pos = { x = 2, y = 5 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, G.GAME.current_round.hands_left + 1} }
    end,

    calculate = function(self, card, context)  
        if context.joker_main and
            #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and 
             pseudorandom('joking_prayer') < G.GAME.probabilities.normal / (G.GAME.current_round.hands_left + 1)
             then -- See note about Talisman compatibility at the bottom
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = 'Tarot',
                            key_append = 'joking_prayer' -- Optional, useful for checking the source of the creation in `in_pool`.
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {
                    message = localize('k_plus_tarot'),
                }
        end
    end

}






SMODS.Joker {
    key = "dead",
    loc_txt = {
		name = 'Dead End',
		text = {
            "Allows {C:attention}Straights{} to be made with",
            "one gap in the middle of any size",
            "{C:inactive}(ex: {C:attention}2 3 4 9 10{C:inactive})"
        }

	},
    blueprint_compat = false,
    unlocked = true,
    rarity = 2,
    cost = 7,
    atlas = 'JokingAround',
    pos = { x = 4, y = 5 },
    config = { extra = { } },
}




local get_straight_ref = get_straight

function get_straight(hand)
    --checking if the joker is even there
    if not next(SMODS.find_card("j_joking_dead")) then
        return get_straight_ref(hand)
    end

    local ret = {}
	local four_fingers = next(SMODS.find_card('j_four_fingers'))
	local can_skip = next(SMODS.find_card('j_shortcut'))
    --checking if the length is valid

	if #hand < (5 - (four_fingers and 1 or 0)) then return ret end
	local t = {}
	local RANKS = {}

	for i = 1, #hand do
		if hand[i]:get_id() > 0 then
			local rank = hand[i]:get_id()
			table.insert(RANKS, rank)
		end
	end
    table.sort(RANKS)

    local break_amount = 0

    for i = 1, #RANKS - 1 do
        if not (RANKS[i] == RANKS[i + 1] - 1) then
            if not(RANKS[i + 1] - RANKS[i] == 2 and can_skip) then
                if i == 2 or i == 3 then
                    if break_amount > 0 then
                        return get_straight_ref(hand)
                    else
                    break_amount = break_amount + 1
                    end
                end

            end
        end

    end
    for _, card in ipairs(hand) do
        table.insert(t, card)
    end
    table.insert(ret, t)
    return ret
end


--[[ 

SMODS.Joker {
    key = "election",
    loc_txt = {
		name = 'Election',
		text = {
            "+#1# Mult, +#2#, Chips"
		}

	},
    blueprint_compat = false,
    unlocked = true,
    rarity = 1,
    cost = 5,
    --atlas = 'JokingAround',
    pos = { x = 0, y = 0 },
    config = { extra = { mult = 0, chips = 0, mult_gain = 1, chip_gain = 3, suit_1 = 'Spades', suit_2 = 'Hearts'} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult, card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)  
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit(card.ability.extra.suit_1) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                }
            end
            if context.other_card:is_suit(card.ability.extra.suit_2) then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS,
                }
            end
        end
        if context.joker_main then 
            return
            {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
        if context.end_of_round and context.main_eval then
            local base_mult = card.ability.extra.mult / card.ability.extra.mult_gain
            local base_chips = card.ability.extra.chips / card.ability.extra.chip_gain
            local balanced = math.ceil(base_mult + base_chips / 2) 
            card.ability.extra.mult = balanced * card.ability.extra.mult_gain
            card.ability.extra.chips = balanced * card.ability.extra.chip_gain
            return
            {
                message = 'Balanced!'
            }

        end

    end

}



 ]]

SMODS.Joker {
    key = "piper",
    loc_txt = {
		name = 'Pied Piper',
		text = {
            "{C:attention}First{} scored card gains",
            "{C:attention}Chips{} and {C:attention}Enhancements{}",
            "of other scored cards, all cards",
            "aside from the first one have {C:green}#1# in #2#{} chance",
            "to be destroyed after scoring"
		}
	},
    unlocked = true,
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    atlas = 'JokingAround',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    config = { extra = { odds = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = {G.GAME.probabilities.normal, card.ability.extra.odds} }
    end,

    calculate = function(self, card, context)  
        if context.before and context.main_eval and not context.blueprint then
            local affected_card = context.scoring_hand[1]
            for _, played_card in ipairs(context.scoring_hand) do
                if played_card ~= affected_card then
                    affected_card.ability.perma_bonus = (affected_card.ability.perma_bonus or 0) + played_card:get_chip_bonus() 
                    if played_card.config.center.key ~= 'c_base' then
                        affected_card:set_ability(played_card.config.center.key, nil, true)
                    end
                end
            end
            G.E_MANAGER:add_event(Event({
                        func = function()
                            affected_card:juice_up()
                            return true
                        end
                    }))
        end
        if pseudorandom('joking_piper') < G.GAME.probabilities.normal / card.ability.extra.odds and context.destroy_card and context.cardarea == G.play and context.destroying_card and context.destroy_card ~= context.scoring_hand[1]
        then
            return{
                remove = true
            }
        end
    end
}





SMODS.Joker {
    key = "smiley",
    loc_txt = {
		name = 'Smiley Face Jr',
		text = {
            "{C:money}Look, I am on this mod's icon!{}",
            "{C:money}(C) Smilington Facezergald Junior",
            "{C:inactive}(This Joker cannot appear during regular gameplay",
            "{C:inactive}and is here just for flavour)"
            
        }
	},
    blueprint_compat = false,
    rarity = 1,
    cost = 1,
    pos = { x = 6, y = 15 },
    display_size = { w = 71 * 0.5, h = 95 * 0.5 },

    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    in_pool = function(self, args) -- equivalent to `yes_pool_flag = 'vremade_gros_michel_extinct'`
        return false
    end

}--[[ 

function SMODS.current_mod.reset_game_globals(run_start)
    reset_joking_whetstone_ranks()    
end ]]







