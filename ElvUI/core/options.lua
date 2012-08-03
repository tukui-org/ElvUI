local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r",E.version),
		width = "full",		
	},
	LoginMessage = {
		order = 2,
		type = 'toggle',
		name = L['Login Message'],
		get = function(info) return E.db.general.loginmessage end,
		set = function(info, value) E.db.general.loginmessage = value end,
	},	
	ToggleTutorial = {
		order = 3,
		type = 'execute',
		name = L['Toggle Tutorials'],
		func = function() E:Tutorials(true); E:ToggleConfig()  end,
	},
	Install = {
		order = 4,
		type = 'execute',
		name = L['Install'],
		desc = L['Run the installation process.'],
		func = function() E:Install(); E:ToggleConfig() end,
	},	
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode() end,
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},	
}

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"],
		},			
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				interruptAnnounce = {
					order = 1,
					name = L['Announce Interrupts'],
					desc = L['Announce when you interrupt a spell to the specified chat channel.'],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['SAY'] = SAY,
						['PARTY'] = PARTY,
						['RAID'] = RAID,
					},
				},
				autoRepair = {
					order = 2,
					name = L['Auto Repair'],
					desc = L['Automatically repair using the following method when visiting a merchant.'],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['GUILD'] = GUILD,
						['PLAYER'] = PLAYER,
					},				
				},
				mapAlpha = {
					order = 3,
					name = L['Map Alpha While Moving'],
					desc = L['Controls what the transparency of the worldmap will be set to when you are moving.'],
					type = 'range',
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				minimapSize = {
					order = 4,
					name = L['Minimap Size'],
					desc = L['Adjust the size of the minimap.'],
					type = 'range',
					min = 120, max = 250, step = 1,
					set = function(info, value) 
						E.db.general[ info[#info] ] = value
						E:GetModule('Minimap'):UpdateSettings()
					end,
				},				
				autoAcceptInvite = {
					order = 5,
					name = L['Accept Invites'],
					desc = L['Automatically accept invites from guild/friends.'],
					type = 'toggle',
				},
				vendorGrays = {
					order = 6,
					name = L['Vendor Grays'],
					desc = L['Automatically vendor gray items when visiting a vendor.'],
					type = 'toggle',				
				},				
				loot = {
					order = 7,
					type = "toggle",
					name = L['Loot'],
					desc = L['Enable/Disable the loot frame.'],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 8,
					type = "toggle",
					name = L['Loot Roll'],
					desc = L['Enable/Disable the loot roll frame.'],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoscale = {
					order = 9,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",	
					set = function(info, value) E.db.general[ info[#info] ] = value; E:StaticPopup_Show("CONFIG_RL") end
				},	

				bubbles = {
					order = 10,
					type = "toggle",
					name = L['Chat Bubbles'],
					desc = L['Skin the blizzard chat bubbles.'],
					get = function(info) return E.private.general.bubbles end,
					set = function(info, value) E.private.general.bubbles = value; E:StaticPopup_Show("PRIVATE_RL") end
				},	
				taintLog = {
					order = 11,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				tinyWorldMap = {
					order = 12,
					type = "toggle",
					name = L["Tiny Map"],
					desc = L["Don't scale the large world map to block out sides of the screen."],
					get = function(info) return E.db.general.tinyWorldMap end,
					set = function(info, value) E.db.general.tinyWorldMap = value; E:GetModule('WorldMap'):ToggleTinyWorldMapSetting() end					
				},				
			},
		},	
		experience = {
			order = 2,
			get = function(info) return E.db.general.experience[ info[#info] ] end,
			set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = XPBAR_LABEL,
			guiInline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ExperienceBar() end,
				},
				width = {
					order = 2,
					type = "range",
					name = L["Width"],
					min = 100, max = 800, step = 1,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 5, max = 30, step = 1,
				},
				textFormat = {
					order = 4,
					type = 'select',
					name = L["Text Format"],
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
					},
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExperience() end,
				},		
				textSize = {
					order = 5,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,		
				},				
			},
		},
		reputation = {
			order = 3,
			get = function(info) return E.db.general.reputation[ info[#info] ] end,
			set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = XPBAR_LABEL,
			guiInline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ReputationBar() end,
				},
				width = {
					order = 2,
					type = "range",
					name = L["Width"],
					min = 100, max = 800, step = 1,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 5, max = 30, step = 1,
				},
				textFormat = {
					order = 4,
					type = 'select',
					name = L["Text Format"],
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
					},
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateReputation() end,
				},		
				textSize = {
					order = 5,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,		
				},				
			},
		},		
	},
}

E.Options.args.media = {
	order = 2,
	type = "group",
	name = L["Media"],
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,	
	args = {
		fonts = {
			order = 1,
			type = "group",
			name = L["Fonts"],
			guiInline = true,
			args = {
				fontsize = {
					order = 1,
					name = L["Font Size"],
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					type = "range",
					min = 6, max = 22, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},	
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 2,
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,	
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				dmgfont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 3,
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,							
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},							
			},
		},	
		textures = {
			order = 2,
			type = "group",
			name = L["Textures"],
			guiInline = true,
			args = {
				normTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 1,
					name = L["Primary Texture"],
					desc = L["The texture that will be used mainly for statusbars."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end							
				},
				glossTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 2,
					name = L["Secondary Texture"],
					desc = L["This texture will get used on objects like chat windows and dropdown menus."],
					values = AceGUIWidgetLSMlists.statusbar,	
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
				},				
			},
		},
		colors = {
			order = 3,
			type = "group",
			name = L["Colors"],
			guiInline = true,
			args = {
				bordercolor = {
					type = "color",
					order = 1,
					name = L["Border Color"],
					desc = L["Main border color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBorderColors()
					end,					
				},
				backdropcolor = {
					type = "color",
					order = 2,
					name = L["Backdrop Color"],
					desc = L["Main backdrop color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,						
				},
				backdropfadecolor = {
					type = "color",
					order = 3,
					name = L["Backdrop Faded Color"],
					desc = L["Backdrop color of transparent frames"],
					hasAlpha = true,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]	
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,						
				},
				valuecolor = {
					type = "color",
					order = 4,
					name = L["Value Color"],
					desc = L["Color some texts use."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]	
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
					end,						
				},						
				resetbutton = {
					type = "execute",
					order = 5,
					name = L["Restore Defaults"],
					func = function() 
						E.db.general.backdropcolor = P.general.backdropcolor
						E.db.general.backdropfadecolor = P.general.backdropfadecolor
						E.db.general.bordercolor = P.general.bordercolor
						E.db.general.valuecolor = P.general.valuecolor
						E:UpdateMedia()
						E:UpdateFrameTemplates()								
					end,
				},
			},
		},
	},
}

local DONATOR_STRING = ""
local LINE_BREAK = "\n"
local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Varok",
	"Cosmo",
	"Adorno",
	"domoaligato",
	"Smorg"
}
E.DONATORS = DONATORS

table.sort(DONATORS, function(a,b) return a < b end) --Alphabetize
for _, donatorName in pairs(DONATORS) do
	DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L['ELVUI_CREDITS']..'\n\n'..L['Coding:']..'\nTukz\nHaste\nNightcracker\nOmega1970\nHydrazine\n\n'..L['Testing:']..'\nTukui Community\nAffinity\nModarch\nBladesdruid\nTirain\nPhima\nVeiled (www.howtopriest.com)\nBlazeflack\nRepooc\nDarth Predator\n\n'..L['Donations:']..DONATOR_STRING,
		},
	},
}