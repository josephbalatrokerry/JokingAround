SMODS.ConsumableType {
    key = 'joking_Chess',
    default = 'c_joking_pawn',
    collection_rows = { 6, 6 },
    primary_colour = G.C.SET.Tarot,
    secondary_colour = G.C.SECONDARY_SET.Tarot,
    shop_rate = 0,
    loc_txt = {
		name = 'Chess',
		text = {
		""
		}
	},
    
}

SMODS.Atlas {
	key = "JokingAroundChess",
	path = "JokingAroundChess.png",
	px = 71,
	py = 94
}

local function mostPlayedHand()
    local most_played_hand = ''
    local most_played_hand_cnt = 0
    for handname, values in pairs(G.GAME.hands) do
        if values.played >= most_played_hand_cnt and values.visible then
            most_played_hand_cnt = values.played
            most_played_hand = handname
        end
    end
    return most_played_hand
end




SMODS.Consumable {
    atlas = 'JokingAroundChess',
    key = 'pawn',
    set = 'joking_Chess',
    pos = { x = 0, y = 0 },
    loc_txt = {
		name = 'White Pawn',
		text = {
			"Destroy {C:attention}#1#{} random cards",
            "in hand and upgrade {C:attention}most played hand{} by {C:attention}#2#",
		},
	},
    config = { extra = { upgrade = 3, destroy = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.destroy, card.ability.extra.upgrade } }
    end,
    use = function(self, card, area, copier)
        local destroyed_cards = {}
        local temp_hand = {}

        for _, playing_card in ipairs(G.hand.cards) do temp_hand[#temp_hand + 1] = playing_card end
        table.sort(temp_hand,
            function(a, b)
                return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
            end
        )

        pseudoshuffle(temp_hand, pseudoseed('immolate'))

        for i = 1, card.ability.extra.destroy do destroyed_cards[#destroyed_cards + 1] = temp_hand[i] end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        SMODS.destroy_cards(destroyed_cards)
        level_up_hand(card, mostPlayedHand(), true, card.ability.extra.upgrade)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
}




SMODS.Consumable {
    key = 'knight',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 1, y = 0 },
    loc_txt = {
		name = 'White Knight',
		text = {
			"Spawn {C:attention}#1#{C:planet} Planet{} cards",
            "{C:inactive}(Space is not neccesary)"
		},
	},
    config = { extra = { planet = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.planet } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, card.ability.extra.planet do
                        SMODS.add_card {
                            set = 'Planet',
                        }
                    end
                    return true
                end
            }))


    end,
    can_use = function(self, card)
        return true
    end,
}



SMODS.Consumable {
    key = 'bishop',
    atlas = "JokingAroundChess",
    set = 'joking_Chess',
    pos = { x = 2, y = 0 },
    loc_txt = {
		name = 'White Bishop',
		text = {
			"Add levels from your {C:attention}most played hand{}",
            "to a hand above in hierarchy, set {C:attention}most played hand{}'s",
            "level to {C:attention}0{}"
		},
	},
    config = { extra = { downgrade = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local mostPlayedHand = mostPlayedHand()
        local mphOrder = 1
        local mphLevel = 1
        for handname, values in pairs(G.GAME.hands) do
            if handname == mostPlayedHand then
                print('found most played hand')
                mphOrder = values.order
                mphLevel = values.level
                break
            end
        end
        for handname, values in pairs(G.GAME.hands) do
            if values.order == mphOrder - 1 then
                    level_up_hand(card, handname, true, mphLevel)
                    level_up_hand(card, mostPlayedHand, true, -mphLevel)
            end
        end

    
        delay(0.3)
   

    end,
    can_use = function(self, card)
        for handname, values in pairs(G.GAME.hands) do
            if handname == mostPlayedHand() then
                return values.order > 1
                --#G.GAME.hands
            end
        end
    end,
}

-- high card is 12


SMODS.Consumable {
    key = 'rook',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 2, y = 1 },
    loc_txt = {
		name = 'White Rook',
				text = {
			"Upgrade {C:attention}most played hand{} by {C:attention}#1#{} levels,",
            "set money to {C:money}$#2#{}",
		},
	},
    config = { extra = { upgrade = 2, set_money = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.upgrade, card.ability.extra.set_money } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        if G.GAME.dollars ~= 0 then
            ease_dollars(-G.GAME.dollars + card.ability.extra.set_money, true)
        end
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            level_up = 1,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end

        }))
        delay(0.3)
        level_up_hand(card, mostPlayedHand(), true, card.ability.extra.upgrade)
        
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })


    end,
    can_use = function(self, card)
        return true
    end,
}


SMODS.Consumable {
    key = 'queen',
    set = 'joking_Chess',
    pos = { x = 0, y = 1 },
    atlas = "JokingAroundChess",
    loc_txt = {
		name = 'White Queen',
		text = {
			"Upgrade {C:attention}most played hand{} by {C:attention}#1#{} levels",
            "{C:attention}#2#{} hand size"
		},
	},
    config = { extra = { upgrade = 5, h_size = -1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.upgrade, card.ability.extra.h_size } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.hand:change_size(card.ability.extra.h_size)
        level_up_hand(card, mostPlayedHand(), true, card.ability.extra.upgrade)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })

    end,
    can_use = function(self, card)
        return true
    end,
}

SMODS.Consumable {
    atlas = "JokingAroundChess",
    key = 'king',
    set = 'joking_Chess',
    pos = { x = 1, y = 1 },
    loc_txt = {
		name = 'White King',
		text = {
			"Destroy a random {C:attention}Joker{} and",
            "upgrade {C:attention}most played hand{} by {C:attention}#1#{} levels",
		},
	},
    config = { extra = { upgrade = 2, set_money = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.upgrade, card.ability.extra.set_money } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local destructable_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced then
                    destructable_jokers[#destructable_jokers + 1] =
                        G.jokers.cards[i]
                end
            end
            local joker_to_destroy = pseudorandom_element(destructable_jokers, 'vremade_madness')

            if joker_to_destroy then
                joker_to_destroy.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        (card):juice_up(0.8, 0.8)
                        joker_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
                        return true
                    end
                }))
            end
        delay(0.3)
        level_up_hand(card, mostPlayedHand(), true, card.ability.extra.upgrade)
   

    end,
    can_use = function(self, card)
        return true
    end,
}
--[[ 

SMODS.Consumable {
    key = 'wchecker',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 1, y = 0 },
    loc_txt = {
		name = 'White Checker',
		text = {
			"Move all the levels on your most played hand to",
            "the next hand in hierarchy"
		},
	},
    config = { extra = { planet = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.planet } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        played_hand = mostPlayedHand()
        for handname, values in pairs(G.GAME.hands) do
            if handname == played_hand and values.visible then
                print('layer 1')
                print(values.order)

                for handname2, values2 in pairs(G.GAME.hands) do
                    if values2.order == (values.order + 1) and values2.visible then
                        level_up_hand(card, handname2, true, values.level)
                        print('layer 2')

        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })
                        level_up_hand(card, handname, true, -values.level)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })
                        break
                    end
                end
                break
            end
        end
    end,
    can_use = function(self, card)
        return true
    end,
}


SMODS.Consumable {
    key = 'bchecker',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 1, y = 0 },
    loc_txt = {
		name = 'Black Checker',
		text = {
			"Move all the levels on your most played hand to",
            "the previous hand in hierarchy"
		},
	},
    config = { extra = { planet = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.planet } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        played_hand = mostPlayedHand()
        for handname, values in pairs(G.GAME.hands) do
            if handname == played_hand and values.visible then
                for handname2, values2 in pairs(G.GAME.hands) do
                    if values2.order == (values.order - 1) and values2.visible then
                        level_up_hand(card, handname2, true, values.level)
                        level_up_hand(card, handname, true, -values.level)
                        break
                    end
                end
                break                
            end
        end
    end,
    can_use = function(self, card)
        return true
    end,
}
 ]]

SMODS.Consumable {
    atlas = 'JokingAroundChess',
    key = 'bpawn',
    set = 'joking_Chess',
    pos = { x = 0, y = 2 },
    loc_txt = {
		name = 'Black Pawn',
		text = {
			"Downgrade {C:attention}most played hand{} by {C:attention}#1#",
            "and add {C:attention}#2#{} random cards",
            "with {C:blue}Blue Seal{} to your hand"
		},
	},
    config = { extra = { downgrade = 4, cards = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade, card.ability.extra.cards } }
    end,
    use = function(self, card, area, copier)

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local cards = {}
                for i = 1, card.ability.extra.cards do
                    cards[i] = SMODS.add_card { set = "Base", seal = "Blue"}
                end
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))

        level_up_hand(card, mostPlayedHand(), true, -card.ability.extra.downgrade)
        delay(0.3)


    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
}




SMODS.Consumable {
    key = 'bknight',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 1, y = 2 },
    loc_txt = {
		name = 'Black Knight',
		text = {
			"Spawn {C:attention}#1#{C:planet} Chess{} cards"
		},
	},
    config = { extra = { chess = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chess } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local cards_to_create = math.min(2, G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, cards_to_create do
                        SMODS.add_card {
                            set = 'joking_Chess',
                        }
                    end
                    return true
                end
            }))


    end,
    can_use = function(self, card)
        return (#G.consumeables.cards + G.GAME.consumeable_buffer) < G.consumeables.config.card_limit
    end,
}



SMODS.Consumable {
    key = 'bbishop',
    atlas = "JokingAroundChess",
    set = 'joking_Chess',
    pos = { x = 2, y = 2 },
    loc_txt = {
		name = 'Black Bishop',
		text = {
			"Add levels from your {C:attention}most played hand{}",
            "to a hand below in hierarchy, set {C:attention}most played hand{}'s",
            "level to {C:attention}0{}"
		},
	},
    config = { extra = { downgrade = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local mostPlayedHand = mostPlayedHand()
        local mphOrder = 1
        local mphLevel = 1
        for handname, values in pairs(G.GAME.hands) do
            if handname == mostPlayedHand then
                print('found most played hand')
                mphOrder = values.order
                mphLevel = values.level
                break
            end
        end
        for handname, values in pairs(G.GAME.hands) do
            if values.order == mphOrder - 1 then
                    level_up_hand(card, handname, true, mphLevel)
                    level_up_hand(card, mostPlayedHand, true, -mphLevel)
            end
        end

    
        delay(0.3)
   

    end,
    can_use = function(self, card)
        for handname, values in pairs(G.GAME.hands) do
            if handname == mostPlayedHand() then
                return not (values.order == #G.GAME.hands)
            end
        end
    end,
}




SMODS.Consumable {
    key = 'brook',
    set = 'joking_Chess',
    atlas = "JokingAroundChess",
    pos = { x = 2, y = 3 },
    loc_txt = {
		name = 'Black Rook',
				text = {
			"Downgrade {C:attention}most played hand{} by {C:attention}#1#{} levels,",
            "gain {C:money}$#2#{}",
		},
	},
    config = { extra = { downgrade = 2, dollars = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade, card.ability.extra.dollars } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        ease_dollars(card.ability.extra.dollars, true)
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            level_up = 1,
            func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true
            end

        }))
        delay(0.3)
        level_up_hand(card, mostPlayedHand(), true, -card.ability.extra.downgrade)
        
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })


    end,
    can_use = function(self, card)
        return true
    end,
}

SMODS.Consumable {
    key = 'bqueen',
    set = 'joking_Chess',
    pos = { x = 0, y = 3 },
    atlas = "JokingAroundChess",
    loc_txt = {
		name = 'Black Queen',
		text = {
			"Downgrade {C:attention}most played hand{} by {C:attention}#1#{} levels",
            "{C:attention}#2#{} hand size"
		},
	},
    config = { extra = { downgrade = 5, h_size = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade, card.ability.extra.h_size } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.hand:change_size(card.ability.extra.h_size)
        level_up_hand(card, mostPlayedHand(), true, -card.ability.extra.downgrade)
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = mostPlayedHand(), level = '' })

    end,
    can_use = function(self, card)
        return true
    end,
}


SMODS.Consumable {
    atlas = "JokingAroundChess",
    key = 'bking',
    set = 'joking_Chess',
    pos = { x = 1, y = 3 },
    loc_txt = {
		name = 'Black King',
		text = {
			"Create a random {C:rare}Rare{C:attention} Joker{} and",
            "decrease level of {C:attention}most played hand{} by {C:attention}#1#"
		},
	},
    config = { extra = { downgrade = 2} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.downgrade } }
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'Joker', rarity = 'Rare' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.3)
        level_up_hand(card, mostPlayedHand(), true, -card.ability.extra.downgrade)

    end,
    can_use = function(self, card)
        return true
    end,
}
