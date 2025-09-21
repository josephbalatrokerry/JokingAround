


SMODS.Atlas {
	key = "JokingAroundBooster",
	path = "JokingAroundBooster.png",
	px = 71,
	py = 95
}


SMODS.Booster {
    key = "chess_normal_1",
    weight = 0.3,
    loc_txt = {
		name = 'Piece Pack',
		text = {
			"Choose #1# of up to #2#",
            "Chess cards to be used immediately"
        }
    },
    kind = 'joking_Chess', -- You can also use Spectral if you want it to belong to the vanilla kind
    cost = 4,
    pos = { x = 0, y = 0 },
    config = { extra = 2, choose = 1 },
    group_key = "k_chess_pack",
    atlas = 'JokingAroundBooster',
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
            key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.1,
            initialize = true,
            lifespan = 3,
            speed = 0.2,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        return {
            set = "joking_Chess",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append =
            "joking_chess"
        }
    end,
}




SMODS.Tag {
    key = "bates",
    min_ante = 2,
    pos = { x = 1, y = 2 },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_standard_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local booster = SMODS.create_card { key = 'p_chess_normal_1', area = G.play }
                booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
                booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
                booster.T.w = G.CARD_W * 1.27
                booster.T.h = G.CARD_H * 1.27
                booster.cost = 0
                booster.from_tag = true
                G.FUNCS.use_card({ config = { ref_table = booster } })
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}





SMODS.Tag {
    key = "bae",
    min_ante = 2,
    pos = { x = 4, y = 2 },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_buffoon_mega_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local booster = SMODS.create_card { key = 'p_buffoon_mega_1', area = G.play }
                booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
                booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
                booster.T.w = G.CARD_W * 1.27
                booster.T.h = G.CARD_H * 1.27
                booster.cost = 0
                booster.from_tag = true
                G.FUNCS.use_card({ config = { ref_table = booster } })
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}





SMODS.Booster {
    key = "chess_normal_2",
    weight = 0.3,
    kind = 'joking_Chess', -- You can also use Spectral if you want it to belong to the vanilla kind
    cost = 4,
    atlas = 'JokingAroundBooster',
    loc_txt = {
		name = 'Piece Pack',
		text = {
			"Choose #1# of up to #2#",
            "Chess cards to be used immediately"
        }
    },
    pos = { x = 1, y = 0 },
    config = { extra = 2, choose = 1 },
    group_key = "k_chess_pack",
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
            key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.1,
            initialize = true,
            lifespan = 3,
            speed = 0.2,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        return {
            set = "joking_Chess",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append =
            "joking_chess"
        }
    end,
}


SMODS.Booster {
    key = "chess_jumbo_1",
    weight = 0.3,
    kind = 'joking_Chess', -- You can also use Spectral if you want it to belong to the vanilla kind
    cost = 6,
    loc_txt = {
		name = 'Jumbo Piece Pack',
		text = {
			"Choose #1# of up to #2#",
            "Chess cards to be used immediately"
        }
    },
    pos = { x = 2, y = 0 },
    config = { extra = 4, choose = 1 },
    group_key = "k_chess_pack",
    draw_hand = true,
        atlas = 'JokingAroundBooster',

    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
            key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.1,
            initialize = true,
            lifespan = 3,
            speed = 0.2,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        return {
            set = "joking_Chess",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append =
            "joking_chess"
        }
    end,
}


SMODS.Booster {
    key = "chess_mega_1",
    weight = 0.07,
    kind = 'joking_Chess', 
    cost = 8,
    loc_txt = {
		name = 'Mega Piece Pack',
		text = {
			"Choose #1# of up to #2#",
            "Chess cards to be used immediately"
        }
    },
    pos = { x = 3, y = 0 },
    config = { extra = 4, choose = 2 },
    group_key = "k_chess_pack",
    draw_hand = true,
    loc_txt = {
		name = 'Piece Pack',
		text = {
			"Gives {C:chips}+#1#{} Chips for each {C:attention}Bonus Card{} and",
			"{C:mult}+#2#{} Mult for each {C:attention}Mult Card{}",
			"in your {C:attention}full deck{}",
			"{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips,",
			"{C:mult}+#4#{C:inactive} Mult)"
		}
	},
    atlas = 'JokingAroundBooster',
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra },
            key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end
        }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.1,
            initialize = true,
            lifespan = 3,
            speed = 0.2,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        return {
            set = "joking_Chess",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append =
            "joking_chess"
        }
    end,
}

