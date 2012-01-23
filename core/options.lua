local E, L, DF = unpack(select(2, ...)); --Engine

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
		get = function(info) return E.db.core.loginmessage end,
		set = function(info, value) E.db.core.loginmessage = value end,
	},
	ToggleAnchors = {
		order = 3,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:MoveUI() end,
	},
	ResetAllMovers = {
		order = 4,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},	
	Install = {
		order = 5,
		type = 'execute',
		name = L['Install'],
		desc = L['Run the installation process.'],
		func = function() E:Install(); E:ToggleConfig() end,
	},
}

E.Options.args.core = {
	type = "group",
	name = L["General"],
	order = 1,
	get = function(info) return E.db.core[ info[#info] ] end,
	set = function(info, value) E.db.core[ info[#info] ] = value end,
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
				expRepPos = {
					order = 3,
					type = 'select',
					name = L['Exp/Rep Position'],
					desc = L['Change the position of the experience/reputation bar.'],
					set = function(info, value) E.db.core.expRepPos = value; E:GetModule('Misc'):UpdateExpRepBarAnchor() end,
					values = {
						['TOP_SCREEN'] = L['Top Screen'],
						['MINIMAP_BOTTOM'] = L["Below Minimap"],
					},
				},
				bags = {
					order = 4,
					type = "toggle",
					name = L['Bags'],
					desc = L['Enable\Disable the all-in-one bag.'],
					get = function(info) return E.db.core.bags end,
					set = function(info, value) E.db.core.bags = value; StaticPopup_Show("CONFIG_RL") end
				},
				loot = {
					order = 5,
					type = "toggle",
					name = L['Loot'],
					desc = L['Enable\Disable the loot frame.'],
					get = function(info) return E.db.core.loot end,
					set = function(info, value) E.db.core.loot = value; StaticPopup_Show("CONFIG_RL") end
				},
				lootRoll = {
					order = 6,
					type = "toggle",
					name = L['Loot Roll'],
					desc = L['Enable\Disable the loot roll frame.'],
					get = function(info) return E.db.core.lootRoll end,
					set = function(info, value) E.db.core.lootRoll = value; StaticPopup_Show("CONFIG_RL") end
				},
				autoscale = {
					order = 7,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",	
					set = function(info, value) E.db.core[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end
				},
				uiscale = {
					order = 8,
					name = L["Scale"],
					desc = L["Controls the scaling of the entire User Interface"],
					disabled = function(info) return E.db["core"].autoscale end,
					type = "range",
					min = 0.64, max = 1, step = 0.01,
					isPercent = true,
					set = function(info, value) E.db.core[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end
				},		
				mapTransparency = {
					order = 9,
					name = L['Map Transparency'],
					desc = L['Controls what the transparency of the worldmap will be set to when you are moving.'],
					type = 'range',
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				panelWidth = {
					order = 100,
					type = 'range',
					name = L['Panel Width'],
					desc = L['PANEL_DESC'],
					set = function(info, value) E.db.core.panelWidth = value; E:GetModule('Chat'):PositionChat(true); local bags = E:GetModule('Bags'); bags:Layout(); bags:Layout(true); end,
					min = 150, max = 700, step = 1,
				},
				panelHeight = {
					order = 101,
					type = 'range',
					name = L['Panel Height'],
					desc = L['PANEL_DESC'],
					set = function(info, value) E.db.core.panelHeight = value; E:GetModule('Chat'):PositionChat(true) end,
					min = 150, max = 600, step = 1,
				},
				panelBackdrop = {
					order = 102,
					type = 'select',
					name = L['Panel Backdrop'],
					desc = L['Toggle showing of the left and right chat panels.'],
					set = function(info, value) E.db.core.panelBackdrop = value; E:GetModule('Layout'):ToggleChatPanels() end,
					values = {
						['HIDEBOTH'] = L['Hide Both'],
						['SHOWBOTH'] = L['Show Both'],
						['LEFT'] = L['Left Only'],
						['RIGHT'] = L['Right Only'],
					},
				},
				panelBackdropNameLeft = {
					order = 103,
					type = 'input',
					width = 'full',
					name = L['Panel Texture (Left)'],
					desc = L['Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.'],
					set = function(info, value) 
						E.db.core[ info[#info] ] = value
						E:UpdateMedia()
					end,
				},
				panelBackdropNameRight = {
					order = 104,
					type = 'input',
					width = 'full',
					name = L['Panel Texture (Right)'],
					desc = L['Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.'],
					set = function(info, value) 
						E.db.core[ info[#info] ] = value
						E:UpdateMedia()
					end,
				},				
			},
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			guiInline = true,
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
							set = function(info, value) E.db.core[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},	
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 2,
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,	
							set = function(info, value) E.db.core[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						dmgfont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 3,
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,		
							set = function(info, value) E.db.core[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
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
							name = L["StatusBar Texture"],
							desc = L["Main statusbar texture."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value) E.db.core[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end							
						},
						glossTex = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 2,
							name = L["Gloss Texture"],
							desc = L["This gets used by some objects."],
							values = AceGUIWidgetLSMlists.statusbar,	
							set = function(info, value) E.db.core[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end
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
								local t = E.db.core[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.core[ info[#info] ] = {}
								local t = E.db.core[ info[#info] ]
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
								local t = E.db.core[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.core[ info[#info] ] = {}
								local t = E.db.core[ info[#info] ]
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
								local t = E.db.core[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								E.db.core[ info[#info] ] = {}
								local t = E.db.core[ info[#info] ]	
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
								local t = E.db.core[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								E.db.core[ info[#info] ] = {}
								local t = E.db.core[ info[#info] ]	
								t.r, t.g, t.b, t.a = r, g, b, a
								E:UpdateMedia()
							end,						
						},						
						resetbutton = {
							type = "execute",
							order = 5,
							name = L["Restore Defaults"],
							func = function() 
								E.db.core.backdropcolor = DF.core.backdropcolor
								E.db.core.backdropfadecolor = DF.core.backdropfadecolor
								E.db.core.bordercolor = DF.core.bordercolor
								E.db.core.valuecolor = DF.core.valuecolor
								E:UpdateMedia()
								E:UpdateFrameTemplates()								
							end,
						},
					},
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
}

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
			name = L['ELVUI_CREDITS']..'\n\n'..L['Coding:']..'\nTukz\nHaste\nNightcracker\nOmega1970\nHydrazine\n\n'..L['Testing:']..'\nTukui Community\nAffinity\nModarch\nBladesdruid\nTirain\nPhima\n\n'..L['Donations:']..DONATOR_STRING,
		},
	},
}