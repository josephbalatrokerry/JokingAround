SMODS.Atlas {
	key = "JokingAround",
	path = "JokingAround.png",
	px = 71,
	py = 95
}

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
    config = { extra = { mult = 4, chips = 30 } },
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
			"retrigger all played cards amount of times",
			"equal to how many Hands were lost"
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
			card.ability.extra.retriggers = G.GAME.current_round.hands_left - 1
            return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_hands_played(-G.GAME.current_round.hands_left + card.ability.extra.hands)
                            SMODS.calculate_effect(
                                { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra.hands } } },
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
			"({C:inactive}Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
		}
	},
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
    cost = 8,
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



--[[ local enhancement_ref = SMODS.has_enhancement()
function SMODS:has_enhancement(enhancement, bypass_debuff)
local d = oldhasenhancement(self, enhancement, bypass_debuff)
    if not d and next(SMODS.find_card("j_joking_alloy")) then
        return alloy_check(self, enhancement)
    end
    return d
end
function alloy_check(self, enhancement)

end ]]

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
    
}

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
    config = { extra = { repetitions = 4, size = 1 } },
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

