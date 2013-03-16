local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local tsort, tinsert = table.sort, table.insert
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

AC:RegisterOptionsTable("ElvUI", E.Options)
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT)	

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
				pixelPerfect = {
					order = 1,
					name = L['Pixel Perfect'],
					desc = L['The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout.'],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end					
				},
				interruptAnnounce = {
					order = 2,
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
					order = 3,
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
					order = 4,
					name = L['Map Alpha While Moving'],
					desc = L['Controls what the transparency of the worldmap will be set to when you are moving.'],
					type = 'range',
					isPercent = true,
					min = 0, max = 1, step = 0.01,
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
				autoRoll = {
					order = 8,
					name = L['Auto Greed/DE'],
					desc = L['Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level.'],
					type = 'toggle',		
					disabled = function() return not E.private.general.lootRoll end
				},
				loot = {
					order = 9,
					type = "toggle",
					name = L['Loot'],
					desc = L['Enable/Disable the loot frame.'],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 10,
					type = "toggle",
					name = L['Loot Roll'],
					desc = L['Enable/Disable the loot roll frame.'],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoScale = {
					order = 11,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",	
					get = function(info) return E.global.general.autoScale end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},	

				bubbles = {
					order = 12,
					type = "toggle",
					name = L['Chat Bubbles'],
					desc = L['Skin the blizzard chat bubbles.'],
					get = function(info) return E.private.general.bubbles end,
					set = function(info, value) E.private.general.bubbles = value; E:StaticPopup_Show("PRIVATE_RL") end
				},	
				taintLog = {
					order = 13,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				tinyWorldMap = {
					order = 14,
					type = "toggle",
					name = L["Tiny Map"],
					desc = L["Don't scale the large world map to block out sides of the screen."],
					get = function(info) return E.db.general.tinyWorldMap end,
					set = function(info, value) E.db.general.tinyWorldMap = value; E:GetModule('WorldMap'):ToggleTinyWorldMapSetting() end,
				},	
				bottomPanel = {
					order = 15,
					type = 'toggle',
					name = L['Bottom Panel'],
					desc = L['Display a panel across the bottom of the screen. This is for cosmetic only.'],
					get = function(info) return E.db.general.bottomPanel end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end						
				},
				topPanel = {
					order = 16,
					type = 'toggle',
					name = L['Top Panel'],
					desc = L['Display a panel across the top of the screen. This is for cosmetic only.'],
					get = function(info) return E.db.general.topPanel end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end						
				},				
			},
		},	
		minimap = {
			order = 2,
			get = function(info) return E.db.general.minimap[ info[#info] ] end,	
			type = "group",
			name = MINIMAP_LABEL,
			guiInline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L['Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r'],
					get = function(info) return E.private.general.minimap[ info[#info] ] end,
					set = function(info, value) E.private.general.minimap[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,	
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					desc = L['Adjust the size of the minimap.'],
					min = 120, max = 250, step = 1,
					set = function(info, value) E.db.general.minimap[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,	
					disabled = function() return not E.private.general.minimap.enable end,
				},	
				locationText = {
					order = 3,
					type = 'select',
					name = L['Location Text'],
					desc = L['Change settings for the display of the location text that is on the minimap.'],
					get = function(info) return E.db.general.minimap.locationText end,
					set = function(info, value) E.db.general.minimap.locationText = value; E:GetModule('Minimap'):UpdateSettings() end,
					values = {
						['MOUSEOVER'] = L['Minimap Mouseover'],
						['SHOW'] = L['Always Display'],
						['HIDE'] = L['Hide'],
					},
					disabled = function() return not E.private.general.minimap.enable end,
				},				
			},		
		},
		experience = {
			order = 3,
			get = function(info) return E.db.general.experience[ info[#info] ] end,
			set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = XPBAR_LABEL,
			guiInline = true,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ExperienceBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L['Mouseover'],
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
			order = 4,
			get = function(info) return E.db.general.reputation[ info[#info] ] end,
			set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = REPUTATION,
			guiInline = true,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ReputationBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L['Mouseover'],
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
		threat = {
			order = 4,
			get = function(info) return E.db.general.threat[ info[#info] ] end,
			set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):ToggleEnable()end,		
			type = "group",
			name = L['Threat'],
			guiInline = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				position = {
					order = 2,
					type = 'select',
					name = L['Position'],
					desc = L['Adjust the position of the threat bar to either the left or right datatext panels.'],
					values = {
						['LEFTCHAT'] = L['Left Chat'],
						['RIGHTCHAT'] = L['Right Chat'],
					},
					set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,	
				},
				textSize = {
					order = 3,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,	
					set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,	
				},		
			},
		},	
		totems = {
			order = 5,
			type = "group",
			name = TUTORIAL_TITLE47,
			guiInline = true,
			get = function(info) return E.db.general.totems[ info[#info] ] end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):PositionAndSize() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):ToggleEnable() end,
				},					
				size = {
					order = 2,
					type = 'range',
					name = L["Button Size"],
					desc = L['Set the size of your bag buttons.'],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 3,
					type = 'range',
					name = L['Button Spacing'],
					desc = L['The spacing between buttons.'],
					min = 1, max = 10, step = 1,			
				},
				sortDirection = {
					order = 4,
					type = 'select',
					name = L["Sort Direction"],
					desc = L['The direction that the bag frames will grow from the anchor.'],
					values = {
						['ASCENDING'] = L['Ascending'],
						['DESCENDING'] = L['Descending'],
					},
				},
				growthDirection = {
					order = 5,
					type = 'select',
					name = L['Bar Direction'],
					desc = L['The direction that the bag frames be (Horizontal or Vertical).'],
					values = {
						['VERTICAL'] = L['Vertical'],
						['HORIZONTAL'] = L['Horizontal'],
					},
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
				fontSize = {
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
				namefont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 3,
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,							
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				}
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
					desc = L["Main border color of the UI. |cffFF0000This is disabled if you are using the pixel perfect theme.|r"],
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
					disabled = function() return E.PixelMode end,
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
				bubblefadecolor = {
					type = "color",
					order = 4,
					name = L["Chat Bubble Color"],
					desc = L["Backdrop color of chat bubbles"],
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
						E:GetModule('Misc'):HookBubbles(WorldFrame:GetChildren())
					end,						
				},
				valuecolor = {
					type = "color",
					order = 5,
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
					order = 6,
					name = L["Restore Defaults"],
					func = function() 
						E.db.general.backdropcolor = P.general.backdropcolor
						E.db.general.backdropfadecolor = P.general.backdropfadecolor
						E.db.general.bubblefadecolor = P.general.bubblefadecolor
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
local DEVELOPER_STRING = ""
local TESTER_STRING = ""
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
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee"
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine"
}

local TESTERS = {
	"Tukui Community",
	"Affinity",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Blazeflack",
	"Repooc",
	"Darth Predator",
	'Alex',
	'Nidra',
	'Kurhyus',
	'BuG',
	'Yachanay',
	'Catok'
}

tsort(DONATORS, function(a,b) return a < b end) --Alphabetize
for _, donatorName in pairs(DONATORS) do
	tinsert(E.CreditsList, donatorName)
	DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
end

tsort(DEVELOPERS, function(a,b) return a < b end) --Alphabetize
for _, devName in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, devName)
	DEVELOPER_STRING = DEVELOPER_STRING..LINE_BREAK..devName
end

tsort(TESTERS, function(a,b) return a < b end) --Alphabetize
for _, testerName in pairs(TESTERS) do
	tinsert(E.CreditsList, testerName)
	TESTER_STRING = TESTER_STRING..LINE_BREAK..testerName
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L['ELVUI_CREDITS']..'\n\n'..L['Coding:']..DEVELOPER_STRING..'\n\n'..L['Testing:']..TESTER_STRING..'\n\n'..L['Donations:']..DONATOR_STRING,
		},
	},
}


--Create Profiles Table
E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

LibStub('LibDualSpec-1.0'):EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

E.Options.args.profiles.plugins["ElvUI"] = {
	desc = {
		name = L["This feature will allow you to transfer, settings to other characters."],
		type = 'description',
		order = 40.4,
	},
	distributeProfile = {
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = 'execute',
		order = 40.5,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				E:GetModule("Distributor"):Distribute(name)
			elseif server then
				E:GetModule("Distributor"):Distribute(name, true)
			end
		end,
	},
	distributeGlobal = {
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		type = 'execute',
		order = 40.6,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				E:GetModule("Distributor"):Distribute(name, false, true)
			elseif server then
				E:GetModule("Distributor"):Distribute(name, true, true)
			end
		end,
	},		
}