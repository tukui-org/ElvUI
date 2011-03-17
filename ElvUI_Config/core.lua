local ElvuiConfig = LibStub("AceAddon-3.0"):NewAddon("ElvuiConfig", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ElvuiConfig", false)
local LSM = LibStub("LibSharedMedia-3.0")
local db
local defaults

function ElvuiConfig:LoadDefaults()
	local _, C, _, _ = unpack(ElvUI)
	--Defaults
	defaults = {
		profile = {
			general = C["general"],
			media = C["media"],
			nameplate = C["nameplate"],
		},
	}
end	

function ElvuiConfig:OnInitialize()
	self:RegisterEvent("PLAYER_LOGIN")
	
	ElvuiConfig:RegisterChatCommand("ec", "ShowConfig")
	ElvuiConfig:RegisterChatCommand("elvui", "ShowConfig")
	
	self.OnInitialize = nil
end

function ElvuiConfig:ShowConfig(arg)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.ElvuiConfig)
end

function ElvuiConfig:PLAYER_LOGIN()
	self:LoadDefaults()

	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("ElvConfig", defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile
	
	self:SetupOptions()
end

function ElvuiConfig:OnProfileChanged(event, database, newProfileKey)
	StaticPopup_Show("RELOAD_UI")
end

function ElvuiConfig:SetupOptions()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ElvuiConfig", self.GenerateOptions)
	
	--Create Profiles Table
	self.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ElvProfiles", self.profileOptions)
	
	-- The ordering here matters, it determines the order in the Blizzard Interface Options
	local ACD3 = LibStub("AceConfigDialog-3.0")
	self.optionsFrames = {}
	self.optionsFrames.ElvuiConfig = ACD3:AddToBlizOptions("ElvuiConfig", "ElvUI", nil, "general")
	self.optionsFrames.Media = ACD3:AddToBlizOptions("ElvuiConfig", L["Media"], "ElvUI", "media")
	self.optionsFrames.Nameplates = ACD3:AddToBlizOptions("ElvuiConfig", L["Nameplates"], "ElvUI", "nameplate")
	self.optionsFrames.Profiles = ACD3:AddToBlizOptions("ElvProfiles", L["Profiles"], "ElvUI")
	self.SetupOptions = nil
end

function ElvuiConfig.GenerateOptions()
	if ElvuiConfig.noconfig then assert(false, ElvuiConfig.noconfig) end
	if not ElvuiConfig.Options then
		ElvuiConfig.GenerateOptionsInternal()
		ElvuiConfig.GenerateOptionsInternal = nil
		moduleOptions = nil
	end
	return ElvuiConfig.Options
end

function ElvuiConfig.GenerateOptionsInternal()
	local E, C, _ = unpack(ElvUI)
	
	ElvuiConfig.Options = {
		type = "group",
		name = "ElvUI",
		args = {
			general = {
				order = 1,
				type = "group",
				name = L["General Settings"],
				desc = L["General Settings"],
				get = function(info) return db.general[ info[#info] ] end,
				set = function(info, value) db.general[ info[#info] ] = value; StaticPopup_Show("RELOAD_UI") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["ELVUI_DESC"],
					},
					autoscale = {
						order = 2,
						name = L["Auto Scale"],
						desc = L["Automatically scale the User Interface based on your screen resolution"],
						type = "toggle",
					},					
					uiscale = {
						order = 3,
						name = L["Scale"],
						desc = L["Controls the scaling of the entire User Interface"],
						disabled = function(info) return db.general.autoscale end,
						type = "range",
						min = 0.64, max = 1, step = 0.01,
						isPercent = true,
					},
					multisampleprotect = {
						order = 4,
						name = L["Multisample Protection"],
						desc = L["Force the Blizzard Multisample Option to be set to 1x. WARNING: Turning this off will lead to blurry borders"],
						type = "toggle",
					},
					classcolortheme = {
						order = 5,
						name = L["Class Color Theme"],
						desc = L["Style all frame borders to be your class color, color unitframes to class color"],
						type = "toggle",
					},
					fontscale = {
						order = 6,
						name = L["Font Scale"],
						desc = L["Set the font scale for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
						type = "range",
						min = 9, max = 15, step = 1,
					},
					resolutionoverride = {
						order = 7,
						name = L["Resolution Override"],
						desc = L["Set a resolution version to use. By default any screensize > 1440 is considered a High resolution. This effects actionbar/unitframe layouts. If set to None, then it will be automatically determined by your screen size"],
						type = "select",
						values = {
							["NONE"] = L["None"],
							["Low"] = L["Low"],
							["High"] = L["High"],
						},
					},
					layoutoverride = {
						order = 8,
						name = L["Layout Override"],
						desc = L["Force a specific layout to show."],
						type = "select",
						values = {
							["NONE"] = L["None"],
							["DPS"] = L["DPS"],
							["Heal"] = L["Heal"],
						},
					},
				},
			},
			media = {
				order = 2,
				type = "group",
				name = L["Media"],
				desc = L["MEDIA_DESC"],
				get = function(info) return db.media[ info[#info] ] end,
				set = function(info, value) db.media[ info[#info] ] = value; StaticPopup_Show("RELOAD_UI") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["MEDIA_DESC"],
					},
					Fonts = {
						type = "group",
						order = 2,
						name = L["Fonts"],
						guiInline = true,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["Font"],
								desc = L["The font that the core of the UI will use"],
								values = AceGUIWidgetLSMlists.font,	
							},
							uffont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 2,
								name = L["UnitFrame Font"],
								desc = L["The font that unitframes will use"],
								values = AceGUIWidgetLSMlists.font,	
							},
							dmgfont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 3,
								name = L["Combat Text Font"],
								desc = L["The font that combat text will use. WARNING: This requires a game restart after changing this option."],
								values = AceGUIWidgetLSMlists.font,						
							},					
						},
					},
					Textures = {
						type = "group",
						order = 3,
						name = L["Textures"],
						guiInline = true,
						args = {
							normTex = {
								type = "select", dialogControl = 'LSM30_Statusbar',
								order = 1,
								name = L["StatusBar Texture"],
								desc = L["Texture that gets used on all StatusBars"],
								values = AceGUIWidgetLSMlists.statusbar,								
							},
							glossTex = {
								type = "select", dialogControl = 'LSM30_Statusbar',
								order = 2,
								name = L["Gloss Texture"],
								desc = L["This gets used by some objects, unless gloss mode is on."],
								values = AceGUIWidgetLSMlists.statusbar,								
							},		
							glowTex = {
								type = "select", dialogControl = 'LSM30_Border',
								order = 3,
								name = L["Glow Border"],
								desc = L["Shadow Effect"],
								values = AceGUIWidgetLSMlists.border,								
							},
							blank = {
								type = "select", dialogControl = 'LSM30_Background',
								order = 4,
								name = L["Backdrop Texture"],
								desc = L["Used on almost all frames"],
								values = AceGUIWidgetLSMlists.background,							
							},
							glossyTexture = {
								order = 5,
								type = "toggle",
								name = L["Glossy Texture Mode"],
								desc = L["Glossy texture gets used in all aspects of the UI instead of just on various portions."],
							},
						},
					},
					Colors = {
						type = "group",
						order = 4,
						name = L["Colors"],
						guiInline = true,					
						args = {
							bordercolor = {
								type = "color",
								order = 1,
								name = L["Border Color"],
								desc = L["Main Frame's Border Color"],
								hasAlpha = false,
								get = function(info)
									local r, g, b = unpack(db.media[ info[#info] ])
									return r, g, b
								end,
								set = function(info, r, g, b)
									StaticPopup_Show("RELOAD_UI")
									db.media[ info[#info] ] = {r, g, b}
								end,					
							},
							backdropcolor = {
								type = "color",
								order = 2,
								name = L["Backdrop Color"],
								desc = L["Main Frame's Backdrop Color"],
								hasAlpha = false,
								get = function(info)
									local r, g, b = unpack(db.media[ info[#info] ])
									return r, g, b
								end,
								set = function(info, r, g, b)
									StaticPopup_Show("RELOAD_UI")
									db.media[ info[#info] ] = {r, g, b}
								end,						
							},
							backdropfadecolor = {
								type = "color",
								order = 3,
								name = L["Backdrop Fade Color"],
								desc = L["Faded backdrop color of some frames"],
								hasAlpha = true,
								get = function(info)
									local r, g, b, a = unpack(db.media[ info[#info] ])
									return r, g, b, a
								end,
								set = function(info, r, g, b, a)
									StaticPopup_Show("RELOAD_UI")
									db.media[ info[#info] ] = {r, g, b, a}
								end,						
							},
							valuecolor = {
								type = "color",
								order = 4,
								name = L["Value Color"],
								desc = L["Value color of various text/frame objects"],
								hasAlpha = false,
								get = function(info)
									local r, g, b = unpack(db.media[ info[#info] ])
									return r, g, b
								end,
								set = function(info, r, g, b)
									StaticPopup_Show("RELOAD_UI")
									db.media[ info[#info] ] = {r, g, b}
								end,						
							},
						},
					},
					Sounds = {
						type = "group",
						order = 5,
						name = L["Sounds"],
						guiInline = true,					
						args = {
							whisper = {
								type = "select", dialogControl = 'LSM30_Sound',
								order = 1,
								name = L["Whisper Sound"],
								desc = L["Sound that is played when recieving a whisper"],
								values = AceGUIWidgetLSMlists.sound,								
							},			
							warning = {
								type = "select", dialogControl = 'LSM30_Sound',
								order = 2,
								name = L["Warning Sound"],
								desc = L["Sound that is played when you don't have a buff active"],
								values = AceGUIWidgetLSMlists.sound,								
							},							
						},
					},
				},
			},
			nameplate = {
				order = 3,
				type = "group",
				name = L["Nameplates"],
				desc = L["NAMEPLATE_DESC"],
				get = function(info) return db.nameplate[ info[#info] ] end,
				set = function(info, value) db.nameplate[ info[#info] ] = value; StaticPopup_Show("RELOAD_UI") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["NAMEPLATE_DESC"],
					},				
					enable = {
						type = "toggle",
						order = 2,
						name = ENABLE,
						desc = L["Enable/Disable Nameplates"],
						set = function(info, value)
							db.nameplate[ info[#info] ] = value; 
							StaticPopup_Show("RELOAD_UI")
						end,
					},
					Nameplates = {
						type = "group",
						order = 3,
						name = L["Nameplate Options"],
						guiInline = true,		
						disabled = function() return not db.nameplate.enable end,
						args = {
							showhealth = {
								type = "toggle",
								order = 1,
								name = L["Show Health"],
								desc = L["Display health values on nameplates, this will also increase the size of the nameplate"],
							},
							enhancethreat = {
								type = "toggle",
								order = 2,
								name = L["Health Threat Coloring"],
								desc = L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."],
							},
							combat = {
								type = "toggle",
								order = 3,
								name = L["Toggle Combat"],
								desc = L["Toggles the nameplates off when not in combat."],							
							},
							trackauras = {
								type = "toggle",
								order = 4,
								name = L["Track Auras"],
								desc = L["Tracks your debuffs on nameplates."],									
							},
							trackccauras = {
								type = "toggle",
								order = 5,
								name = L["Track CC Debuffs"],
								desc = L["Tracks CC debuffs on nameplates from you or a friendly player"],										
							},
							Colors = {
								type = "group",
								order = 6,
								name = L["Colors"],
								guiInline = true,	
								get = function(info)
									local r, g, b = unpack(db.nameplate[ info[#info] ])
									return r, g, b
								end,
								set = function(info, r, g, b)
									db.nameplate[ info[#info] ] = {r, g, b}
									StaticPopup_Show("RELOAD_UI")
								end,
								disabled = function() return (not db.nameplate.enhancethreat or not db.nameplate.enable) end,								
								args = {
									goodcolor = {
										type = "color",
										order = 1,
										name = L["Good Color"],
										desc = L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"],
										hasAlpha = false,
										
									},		
									badcolor = {
										type = "color",
										order = 2,
										name = L["Bad Color"],
										desc = L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"],
										hasAlpha = false,
									},
									transitioncolor = {
										type = "color",
										order = 3,
										name = L["Transition Color"],
										desc = L["This color is displayed when gaining/losing threat"],
										hasAlpha = false,									
									},
								},
							},
						},
					},
				},
			},
		},
	}
end


