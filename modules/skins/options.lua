local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "select",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"],
		},	
		embedRight = {
			order = 2,
			type = 'select',
			name = L['Embedded Addon'],
			desc = L['Select an addon to embed to the right chat window. This will resize the addon to fit perfectly into the chat window, it will also parent it to the chat window so hiding the chat window will also hide the addon.'],
			values = {
				[''] = ' ',
				['Recount'] = "Recount",
				['Omen'] = "Omen",
				--['Skada'] = "Skada",
			},
			get = function(info) return E.db.skins[ info[#info] ] end,
			set = function(info, value) E.db.skins[ info[#info] ] = value; S:SetEmbedRight(value) end,
		},
		bigwigs = {
			order = 3,
			type = 'group',
			name = 'BigWigs',
			get = function(info) return E.db.skins.bigwigs[ info[#info] ] end,
			set = function(info, value) E.db.skins.bigwigs[ info[#info] ] = value; end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,
					get = function(info) return E.db.skins.bigwigs[ info[#info] ] end,
					set = function(info, value) E.db.skins.bigwigs[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,					
				},
				spacing = {
					name = L['Spacing'],
					desc = L['The spacing in between bars.'],
					type = 'range',
					order = 2,
					min = 0, max = 25, step = 1,
				},
			},
		},
		ace3 = {
			order = 4,
			type = 'group',
			name = 'Ace3',
			get = function(info) return E.db.skins.ace3[ info[#info] ] end,
			set = function(info, value) E.db.skins.ace3[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},
		recount = {
			order = 5,
			type = 'group',
			name = 'Recount',
			get = function(info) return E.db.skins.recount[ info[#info] ] end,
			set = function(info, value) E.db.skins.recount[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},
		omen = {
			order = 6,
			type = 'group',
			name = 'Omen',
			get = function(info) return E.db.skins.omen[ info[#info] ] end,
			set = function(info, value) E.db.skins.omen[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},	
		skada = {
			order = 7,
			type = 'group',
			name = 'Skada',
			get = function(info) return E.db.skins.skada[ info[#info] ] end,
			set = function(info, value) E.db.skins.skada[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},	
		dxe = {
			order = 8,
			type = 'group',
			name = 'DXE',
			get = function(info) return E.db.skins.dxe[ info[#info] ] end,
			set = function(info, value) E.db.skins.dxe[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},	
		dbm = {
			order = 9,
			type = 'group',
			name = 'DBM',
			get = function(info) return E.db.skins.dbm[ info[#info] ] end,
			set = function(info, value) E.db.skins.dbm[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},	
		tinydps = {
			order = 10,
			type = 'group',
			name = 'TinyDPS',
			get = function(info) return E.db.skins.tinydps[ info[#info] ] end,
			set = function(info, value) E.db.skins.tinydps[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},			
			},
		},		
		blizzard = {
			order = 300,
			type = 'group',
			name = 'Blizzard',
			get = function(info) return E.db.skins.blizzard[ info[#info] ] end,
			set = function(info, value) E.db.skins.blizzard[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end,	
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},		
				encounterjournal = {
					type = "toggle",
					name = L["Encounter Journal"],
					desc = L["TOGGLESKIN_DESC"],
				},
				reforge = {
					type = "toggle",
					name = L["Reforge Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				achievement = {
					type = "toggle",
					name = L["Achievement Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},		
				lfguild = {
					type = "toggle",
					name = L["LF Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},	
				inspect = {
					type = "toggle",
					name = L["Inspect Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},		
				binding = {
					type = "toggle",
					name = L["KeyBinding Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},		
				gbank = {
					type = "toggle",
					name = L["Guild Bank"],
					desc = L["TOGGLESKIN_DESC"],
				},	
				archaeology = {
					type = "toggle",
					name = L["Archaeology Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},	
				guildcontrol = {
					type = "toggle",
					name = L["Guild Control Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},		
				guild = {
					type = "toggle",
					name = L["Guild Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},
				tradeskill = {
					type = "toggle",
					name = L["TradeSkill Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},	
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],									
				},
				talent = {
					type = "toggle",
					name = L["Talent Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},
				glyph = {
					type = "toggle",
					name = L["Glyph Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},
				auctionhouse = {
					type = "toggle",
					name = L["Auction Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				timemanager = {
					type = "toggle",
					name = L["Time Manager"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				barber = {
					type = "toggle",
					name = L["Barbershop Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},
				macro = {
					type = "toggle",
					name = L["Macro Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"],							
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"],							
				},		
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				achievement_popup = {
					type = "toggle",
					name = L["Achievement Popup Frames"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				bgscore = {
					type = "toggle",
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				merchant = {
					type = "toggle",
					name = L["Merchant Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				mail = {
					type = "toggle",
					name = L["Mail Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				trade = {
					type = "toggle",
					name = L["Trade Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				greeting = {
					type = "toggle",
					name = L["Greeting Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				worldmap = {
					type = "toggle",
					name = L["World Map"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				taxi = {
					type = "toggle",
					name = L["Taxi Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				lfd = {
					type = "toggle",
					name = L["LFD Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				quest = {
					type = "toggle",
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				petition = {
					type = "toggle",
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				dressingroom = {
					type = "toggle",
					name = L["Dressing Room"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				pvp = {
					type = "toggle",
					name = L["PvP Frames"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				nonraid = {
					type = "toggle",
					name = L["Non-Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				friends = {
					type = "toggle",
					name = L["Friends"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				spellbook = {
					type = "toggle",
					name = L["Spellbook"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},
				lfr = {
					type = "toggle",
					name = L["LFR Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				misc = {
					type = "toggle",
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"],								
				},		
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"],								
				},		
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"],								
				},		
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],									
				},				
			},
		},
	},
}