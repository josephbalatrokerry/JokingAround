SMODS.Atlas {
	key = "JokingAroundBack",
	path = "JokingAroundBack.png",
	px = 71,
	py = 95
}



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
