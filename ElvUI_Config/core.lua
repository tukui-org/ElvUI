local ElvuiConfig = LibStub("AceAddon-3.0"):NewAddon("ElvuiConfig", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ElvuiConfig", false)
local LSM = LibStub("LibSharedMedia-3.0")
local db
local defaults

if IsAddOnLoaded("ElvUI_ConfigUI") then
	error("The AddOn 'ElvUI_ConfigUI' is no longer in use, please remove it from you addons folders. The new config addon is called 'ElvUI_Config'")
end

function ElvuiConfig:LoadDefaults()
	local E, _, _, DB = unpack(ElvUI)
	--Defaults
	defaults = {
		profile = {
			general = DB["general"],
			media = DB["media"],
			nameplate = DB["nameplate"],
			skin = DB["skin"],
			unitframes = DB["unitframes"],
			raidframes = DB["raidframes"],
			classtimer = DB["classtimer"],
			actionbar = DB["actionbar"],
			datatext = DB["datatext"],
			chat = DB["chat"],
			tooltip = DB["tooltip"],
			others = DB["others"],
			spellfilter = {
				FilterPicker = "RaidDebuffs",
				RaidDebuffs = E["RaidDebuffs"],
				DebuffBlacklist = E["DebuffBlacklist"],
				TargetPVPOnly = E["TargetPVPOnly"],
				DebuffWhiteList = E["DebuffWhiteList"],
				ArenaBuffWhiteList = E["ArenaBuffWhiteList"],
				PlateBlacklist = E["PlateBlacklist"],
				HealerBuffIDs = E["HealerBuffIDs"],
				DPSBuffIDs = E["DPSBuffIDs"],
				PetBuffs = E["PetBuffs"],
				TRINKET_FILTER = TRINKET_FILTER,
				CLASS_FILTERS = CLASS_FILTERS,
				ChannelTicks = E["ChannelTicks"]
			},
		},
	}
end	

function ElvuiConfig:OnInitialize()	
	ElvuiConfig:RegisterChatCommand("ec", "ShowConfig")
	ElvuiConfig:RegisterChatCommand("elvui", "ShowConfig")
	
	self.OnInitialize = nil
end

function ElvuiConfig:ShowConfig(arg)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.ElvuiConfig)
end

function ElvuiConfig:Load()
	self:LoadDefaults()

	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("ElvConfig", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile
	
	self:SetupOptions()
end

function ElvuiConfig:OnProfileChanged(event, database, newProfileKey)
	StaticPopup_Show("CFG_RELOAD")
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
	self.optionsFrames.Unitframes = ACD3:AddToBlizOptions("ElvuiConfig", L["Unit Frames"], "ElvUI", "unitframes")
	self.optionsFrames.Raidframes = ACD3:AddToBlizOptions("ElvuiConfig", L["Raid Frames"], "ElvUI", "raidframes")
	self.optionsFrames.Classtimer = ACD3:AddToBlizOptions("ElvuiConfig", L["Class Timers"], "ElvUI", "classtimer")
	self.optionsFrames.Actionbar = ACD3:AddToBlizOptions("ElvuiConfig", L["Action Bars"], "ElvUI", "actionbar")
	self.optionsFrames.Datatext = ACD3:AddToBlizOptions("ElvuiConfig", L["Data Texts"], "ElvUI", "datatext")
	self.optionsFrames.Chat = ACD3:AddToBlizOptions("ElvuiConfig", L["Chat"], "ElvUI", "chat")
	self.optionsFrames.Tooltip = ACD3:AddToBlizOptions("ElvuiConfig", L["Tooltip"], "ElvUI", "tooltip")
	self.optionsFrames.Skins = ACD3:AddToBlizOptions("ElvuiConfig", L["Addon Skins"], "ElvUI", "skin")
	self.optionsFrames.SpellFilter = ACD3:AddToBlizOptions("ElvuiConfig", L["Filters"], "ElvUI", "spellfilter")
	self.optionsFrames.Others = ACD3:AddToBlizOptions("ElvuiConfig", L["Misc"], "ElvUI", "others")
	self.optionsFrames.Profiles = ACD3:AddToBlizOptions("ElvProfiles", L["Profiles"], "ElvUI")
	self.SetupOptions = nil
end

function ElvuiConfig.GenerateOptions()
	if ElvuiConfig.noconfig then assert(false, ElvuiConfig.noconfig) end
	if not ElvuiConfig.Options then
		ElvuiConfig.GenerateOptionsInternal()
		ElvuiConfig.GenerateOptionsInternal = nil
	end
	return ElvuiConfig.Options
end

function ElvuiConfig.GenerateOptionsInternal()
	local E, C, _, DB = unpack(ElvUI)

	StaticPopupDialogs["CFG_RELOAD"] = {
		text = L["CFG_RELOAD"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function() ReloadUI() end,
		timeout = 0,
		whileDead = 1,
	}

	if C["general"].upperpanel == true then
		L["DATATEXT_POS"] = L["DATATEXT_POS2"]
	end
	
	local RaidBuffs = {
		["HealerBuffIDs"] = true,
		["DPSBuffIDs"] = true,
		["PetBuffs"] = true
	}
	
	local ClassTimerShared = {
		["TRINKET_FILTER"] = true,
	}
	
	local ClassTimer = {
		["CLASS_FILTERS"] = true
	}
	
	local function CreateFilterTable(tab)
		local spelltable = db.spellfilter[tab]
		if not spelltable then error("db.spellfilter could not find value 'tab'") return {} end
		local newtable = {}
		
		if tab == "ChannelTicks" then
			for spell, value in pairs(spelltable) do
				if db.spellfilter[tab][spell] ~= nil then
					newtable[spell] = {
						name = spell,
						desc = L["To disable set to zero, otherwise set to the amount of times the spell ticks in a cast"],
						type = "range",
						get = function(info) return db.spellfilter[tab][spell] end,
						set = function(info, val) db.spellfilter[tab][spell] = val; StaticPopup_Show("CFG_RELOAD") end,
						min = 0, max = 15, step = 1,	
					}
				end
			end		
		elseif ClassTimer[tab] then
			newtable["SelectSpellFilter"] = {
				name = L["Choose Filter"],
				desc = L["Choose the filter you want to modify."],
				type = "select",
				order = 1,
				values = {
					["target"] = TARGET,
					["player"] = PLAYER,
					["procs"] = L["Procs"],
				},
				set = function(info, value) 
					db.spellfilter[ info[#info] ] = value;
					local config = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ElvuiConfig", "dialog", "MyLib-1.2")
					local curfilter = db.spellfilter.FilterPicker
		
					config.args.spellfilter.args.SpellListTable.args = CreateFilterTable(curfilter)
				end,
			}
			local curfilter = db.spellfilter["SelectSpellFilter"]
			if curfilter ~= nil then
				newtable["SelectSpell"] = {
					name = L["Select Spell"],
					type = "select",
					order = 2,
					values = {},
					set = function(info, value) 
						db.spellfilter[ info[#info] ] = value;
						local config = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ElvuiConfig", "dialog", "MyLib-1.2")
						local curfilter = db.spellfilter.FilterPicker
			
						config.args.spellfilter.args.SpellListTable.args = CreateFilterTable(curfilter)
					end,
				}
				
				if not spelltable[E.myclass] then spelltable[E.myclass] = {} end
				
				for i, spell in pairs(spelltable[E.myclass][curfilter]) do
					local id = spell["id"]
					newtable["SelectSpell"]["values"][id] = GetSpellInfo(id)

					if id == db.spellfilter["SelectSpell"] then
						newtable["SpellGroup"] = {
							order = 3,
							type = "group",
							name = GetSpellInfo(id).." ("..id..")",
							guiInline = true,				
							args = {
								Enabled = {
									type = "toggle",
									order = 1,
									name = L["Enabled"],
									get = function(info) return db.spellfilter[tab][E.myclass][curfilter][i]["enabled"] end,
									set = function(info, value) db.spellfilter[tab][E.myclass][curfilter][i]["enabled"] = value; StaticPopup_Show("CFG_RELOAD") end,										
								},
								CastByAnyone = {
									type = "toggle",
									order = 2,
									name = L["Any Unit"],
									desc = L["Display the buff if cast by anyone?"],
									get = function(info) return db.spellfilter[tab][E.myclass][curfilter][i]["castByAnyone"] end,
									set = function(info, value) db.spellfilter[tab][E.myclass][curfilter][i]["castByAnyone"] = value; StaticPopup_Show("CFG_RELOAD") end,									
								},
								Color = {
									type = "color",
									order = 3,
									name = L["Color"],
									hasAlpha = false,
									get = function(info)
										local t = db.spellfilter[tab][E.myclass][curfilter][i]["color"]
										if not t then
											t = {}
											t.r = 0
											t.g = 0
											t.b = 0
										end
										
										return t.r, t.g, t.b
									end,
									set = function(info, r, g, b)
										db.spellfilter[tab][E.myclass][curfilter][i]["color"] = {}
										local t = db.spellfilter[tab][E.myclass][curfilter][i]["color"]
										t.r, t.g, t.b = r, g, b
										StaticPopup_Show("CFG_RELOAD")
									end,							
								},
								UnitType = {
									type = "select",
									order = 4,
									name = L["Unit Type"],
									desc = L["Only display on this type of unit"],
									values = {
										[0] = L["All"],
										[1] = L["Friendly"],
										[2] = L["Enemy"],
									},
									get = function(info) if db.spellfilter[tab][E.myclass][curfilter][i]["unitType"] == nil then return 0 else return db.spellfilter[tab][E.myclass][curfilter][i]["unitType"] end end,
									set = function(info, value) db.spellfilter[tab][E.myclass][curfilter][i]["unitType"] = value; StaticPopup_Show("CFG_RELOAD") end,									
								},
								CastSpellID = {
									type = "input",
									order = 5,
									name = L["Show Ticks"],
									desc = L["Fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id."],
									get = function(info) if db.spellfilter[tab][E.myclass][curfilter][i]["castSpellId"] == nil then return "" else return db.spellfilter[tab][E.myclass][curfilter][i]["castSpellId"] end end,
									set = function(info, value) db.spellfilter[tab][E.myclass][curfilter][i]["castSpellId"] = value; StaticPopup_Show("CFG_RELOAD") end,									
								},
							},
						}					
					end
				end
			end
		elseif ClassTimerShared[tab] then
			newtable["SelectSpell"] = {
				name = L["Select Spell"],
				type = "select",
				order = 1,
				values = {},
				set = function(info, value) 
					db.spellfilter[ info[#info] ] = value;
					local config = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ElvuiConfig", "dialog", "MyLib-1.2")
					local curfilter = db.spellfilter.FilterPicker
		
					config.args.spellfilter.args.SpellListTable.args = CreateFilterTable(curfilter)
				end,
			}
			
			for i, spell in pairs(spelltable) do
				local id = spell["id"]

				newtable["SelectSpell"]["values"][id] = GetSpellInfo(id)
				
				--{ enabled = true, id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId }
				if id == db.spellfilter["SelectSpell"] then
					newtable["SpellGroup"] = {
						order = 2,
						type = "group",
						name = GetSpellInfo(id).." ("..id..")",
						guiInline = true,				
						args = {
							Enabled = {
								type = "toggle",
								order = 1,
								name = L["Enabled"],
								get = function(info) return db.spellfilter[tab][i]["enabled"] end,
								set = function(info, value) db.spellfilter[tab][i]["enabled"] = value; StaticPopup_Show("CFG_RELOAD") end,										
							},
							CastByAnyone = {
								type = "toggle",
								order = 2,
								name = L["Any Unit"],
								desc = L["Display the buff if cast by anyone?"],
								get = function(info) return db.spellfilter[tab][i]["castByAnyone"] end,
								set = function(info, value) db.spellfilter[tab][i]["castByAnyone"] = value; StaticPopup_Show("CFG_RELOAD") end,									
							},
							Color = {
								type = "color",
								order = 3,
								name = L["Color"],
								hasAlpha = false,
								get = function(info)
									local t = db.spellfilter[tab][i]["color"]
									if not t then
										t = {}
										t.r = 0
										t.g = 0
										t.b = 0
									end
									
									return t.r, t.g, t.b
								end,
								set = function(info, r, g, b)
									db.spellfilter[tab][i]["color"] = {}
									local t = db.spellfilter[tab][i]["color"]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,							
							},
							UnitType = {
								type = "select",
								order = 4,
								name = L["Unit Type"],
								desc = L["Only display on this type of unit"],
								values = {
									[0] = L["All"],
									[1] = L["Friendly"],
									[2] = L["Enemy"],
								},
								get = function(info) if db.spellfilter[tab][i]["unitType"] == nil then return 0 else return db.spellfilter[tab][i]["unitType"] end end,
								set = function(info, value) db.spellfilter[tab][i]["unitType"] = value; StaticPopup_Show("CFG_RELOAD") end,									
							},
							CastSpellID = {
								type = "input",
								order = 5,
								name = L["Show Ticks"],
								desc = L["Fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id."],
								get = function(info) if db.spellfilter[tab][i]["castSpellId"] == nil then return "" else return db.spellfilter[tab][i]["castSpellId"] end end,
								set = function(info, value) db.spellfilter[tab][i]["castSpellId"] = value; StaticPopup_Show("CFG_RELOAD") end,									
							},
						},
					}
				end
			end
		elseif RaidBuffs[tab] then
			if not spelltable[E.myclass] then spelltable[E.myclass] = {} end
			newtable["SelectSpell"] = {
				name = L["Select Spell"],
				type = "select",
				order = 1,
				values = {},
				set = function(info, value) 
					db.spellfilter[ info[#info] ] = value;
					local config = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ElvuiConfig", "dialog", "MyLib-1.2")
					local curfilter = db.spellfilter.FilterPicker
		
					config.args.spellfilter.args.SpellListTable.args = CreateFilterTable(curfilter)
				end,
			}
			
			for i, spell in pairs(spelltable[E.myclass]) do
				local id = spell["id"]
				
				newtable["SelectSpell"]["values"][id] = GetSpellInfo(id)
				
				if id == db.spellfilter["SelectSpell"] then
					newtable["SpellGroup"] = {
						order = 2,
						type = "group",
						name = GetSpellInfo(id).." ("..id..")",
						guiInline = true,				
						args = {
							Enabled = {
								type = "toggle",
								order = 1,
								name = L["Enabled"],
								get = function(info) return db.spellfilter[tab][E.myclass][i]["enabled"] end,
								set = function(info, value) db.spellfilter[tab][E.myclass][i]["enabled"] = value; StaticPopup_Show("CFG_RELOAD") end,										
							},
							Position = {
								type = "select",
								order = 2,
								name = L["Position"],
								desc = L["Position where the buff appears on the frame"],
								get = function(info) return db.spellfilter[tab][E.myclass][i]["point"] end,
								set = function(info, value) db.spellfilter[tab][E.myclass][i]["point"] = value; StaticPopup_Show("CFG_RELOAD") end,		
								values = {
									["TOPLEFT"] = "TOPLEFT",
									["TOP"] = "TOP",
									["TOPRIGHT"] = "TOPRIGHT",
									["LEFT"] = "LEFT",
									["RIGHT"] = "RIGHT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOM"] = "BOTTOM",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
								},
							},
							anyUnit = {
								type = "toggle",
								order = 3,
								name = L["Any Unit"],
								desc = L["Display the buff if cast by anyone?"],
								get = function(info) return db.spellfilter[tab][E.myclass][i]["anyUnit"] end,
								set = function(info, value) db.spellfilter[tab][E.myclass][i]["anyUnit"] = value; StaticPopup_Show("CFG_RELOAD") end,									
							},
							Color = {
								type = "color",
								order = 4,
								name = L["Color"],
								hasAlpha = false,
								get = function(info)
									local t = db.spellfilter[tab][E.myclass][i]["color"]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.spellfilter[tab][E.myclass][i]["color"] = {}
									local t = db.spellfilter[tab][E.myclass][i]["color"]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,																	
							},					
						},
					}
				end
			end	
		else
			for spell, value in pairs(spelltable) do
				if db.spellfilter[tab][spell] ~= nil then
					newtable[spell] = {
						name = spell,
						type = "toggle",
						get = function(info) if db.spellfilter[tab][spell] then return true else return false end end,
						set = function(info, value) db.spellfilter[tab][spell] = value; E[tab] = db.spellfilter[tab]; StaticPopup_Show("CFG_RELOAD") end,
					}
				end
			end
		end
		
		return newtable
	end		
				
	local function GetFilterDesc()
		if db.spellfilter.FilterPicker == "PlateBlacklist" then
			return L["Filter whether or not a nameplate is shown by the name of the nameplate"]
		elseif db.spellfilter.FilterPicker == "ArenaBuffWhiteList" then
			return L["Filter the buffs that get displayed on arena units."]
		elseif db.spellfilter.FilterPicker == "DebuffBlacklist" then
			return L["Set buffs that will never get displayed."]
		elseif db.spellfilter.FilterPicker == "DebuffWhiteList" then
			return L["These debuffs will always get displayed on the Target Frame, Arena Frames, and Nameplates."]
		elseif db.spellfilter.FilterPicker == "TargetPVPOnly" then
			return L["These debuffs only get displayed on the target unit when the unit happens to be an enemy player."]
		elseif db.spellfilter.FilterPicker == "RaidDebuffs" then
			return L["These debuffs will be displayed on your raid frames in addition to any debuff that is dispellable."]
		elseif db.spellfilter.FilterPicker == "HealerBuffIDs" then
			return L["These buffs are displayed on the healer raid and party layouts"]
		elseif db.spellfilter.FilterPicker == "DPSBuffIDs" then
			return L["These buffs are displayed on the DPS raid and party layouts"]
		elseif db.spellfilter.FilterPicker == "PetBuffs" then
			return L["These buffs are displayed on the pet frame"]
		elseif db.spellfilter.FilterPicker == "TRINKET_FILTER" then
			return L["These buffs are displayed no matter your class you must have a layout enabled that uses trinkets however for them to show"]
		elseif db.spellfilter.FilterPicker == "CLASS_FILTERS" then
			return L["These buffs/debuffs are displayed as a classtimer, where they get positioned is based on your layout option choice"]
		elseif db.spellfilter.FilterPicker == "ChannelTicks" then
			return L["These spells when cast will display tick marks on the castbar"]
		else
			return ""
		end
	end
	
	local function GetFilterName()
		if db.spellfilter.FilterPicker == "ChannelTicks" then
			return L["Spells"]
		elseif db.spellfilter.FilterPicker == "PlateBlacklist" then
			return L["Nameplate Names"]
		else
			return L["Auras"]
		end	
	end
	
	local function UpdateSpellFilter()
		local config = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("ElvuiConfig", "dialog", "MyLib-1.2")
		local curfilter = db.spellfilter.FilterPicker
		
		config.args.spellfilter.args.SpellListTable.args = CreateFilterTable(curfilter)
		config.args.spellfilter.args.FilterDesc.name = GetFilterDesc()
		config.args.spellfilter.args.SpellListTable.name = GetFilterName()

		collectgarbage("collect") -- Memory dump
	end
	
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
				set = function(info, value) db.general[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
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
					sharpborders = {
						order = 9,
						type = "toggle",
						name = L["Sharp Borders"],
						desc = L["Enhance the borders on all frames by making a dark outline around the edges. You will probably need to disable this if you do not play in your monitors max resolution."],	
					},
					upperpanel = {
						order = 10,
						type = "toggle",
						name = L["Upper Frame"],
						desc = L["Enable a bar accross the top of the screen, doing this will move the location and coords texts to that bar, and also allow for spaces nine and ten of the datatexts to be used."],
					},
					lowerpanel = {
						order = 11,
						type = "toggle",
						name = L["Lower Frame"],
						desc = L["Enable a bar accross the bottom of the screen, mostly for decoration."],					
					},
				},
			},
			media = {
				order = 2,
				type = "group",
				name = L["Media"],
				desc = L["MEDIA_DESC"],
				get = function(info) return db.media[ info[#info] ] end,
				set = function(info, value) db.media[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
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
					Sounds = {
						type = "group",
						order = 4,
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
					GenColors = {
						type = "group",
						order = 5,
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
									local t = db.media[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.media[ info[#info] ] = {}
									local t = db.media[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,					
							},
							backdropcolor = {
								type = "color",
								order = 2,
								name = L["Backdrop Color"],
								desc = L["Main Frame's Backdrop Color"],
								hasAlpha = false,
								get = function(info)
									local t = db.media[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.media[ info[#info] ] = {}
									local t = db.media[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,						
							},
							backdropfadecolor = {
								type = "color",
								order = 3,
								name = L["Backdrop Fade Color"],
								desc = L["Faded backdrop color of some frames"],
								hasAlpha = true,
								get = function(info)
									local t = db.media[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b, a)
									db.media[ info[#info] ] = {}
									local t = db.media[ info[#info] ]	
									t.r, t.g, t.b, t.a = r, g, b, a
									StaticPopup_Show("CFG_RELOAD")
								end,						
							},
							valuecolor = {
								type = "color",
								order = 4,
								name = L["Value Color"],
								desc = L["Value color of various text/frame objects"],
								hasAlpha = false,
								get = function(info)
									local t = db.media[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.media[ info[#info] ] = {}
									local t = db.media[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,						
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
				set = function(info, value) db.nameplate[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
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
							StaticPopup_Show("CFG_RELOAD")
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
									local t = db.nameplate[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.nameplate[ info[#info] ] = {}
									local t = db.nameplate[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
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
			unitframes = {
				order = 4,
				type = "group",
				name = L["Unit Frames"],
				desc = L["UF_DESC"],
				get = function(info) return db.unitframes[ info[#info] ] end,
				set = function(info, value) db.unitframes[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["UF_DESC"],
					},								
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
						desc = L["Enable Unitframes"],
					},
					UFGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.unitframes.enable end,	
						args = {
							fontsize = {
								type = "range",
								order = 1,
								name = L["Font Scale"],
								desc = L["Controls the size of the unitframe font"],
								type = "range",
								min = 9, max = 15, step = 1,							
							},
							lowThreshold = {
								type = "range",
								order = 2,
								name = L["Low Mana Threshold"],
								desc = L["Point to warn about low mana"],
								type = "range",
								min = 1, max = 99, step = 1,							
							},
							targetpowerplayeronly = {
								type = "toggle",
								order = 3,
								name = L["Target Power on Player Only"],
								desc = L["Only display power values on player units"] ,
							},
							showfocustarget = {
								type = "toggle",
								order = 4,
								name = L["Focus's Target"],
								desc = L["Display the focus unit's target"],							
							},
							pettarget = {
								type = "toggle",
								order = 5,
								name = L["Pet's Target"],
								desc = L["Display the pet unit's target"],
								disabled = function() return (not db.unitframes.enable or not (IsAddOnLoaded("ElvUI_RaidDPS") or db.general.layoutoverride == "DPS")) end,	
							},
							showtotalhpmp = {
								type = "toggle",
								order = 6,
								name = L["Total HP/MP"],
								desc = L["Display the total HP/MP on all available units"],								
							},
							showsmooth = {
								type = "toggle",
								order = 7,
								name = L["Smooth Bars"],
								desc = L["Smoothly transition statusbars when values change"],									
							},
							charportrait = {
								type = "toggle",
								order = 8,
								name = L["Character Portrait"],
								desc = L["Display character portrait on available frames"],								
							},
							charportraithealth = {
								type = "toggle",
								order = 8,
								name = L["Character Portrait on Health"],
								desc = L["Overlay character portrait on the healthbar available frames"],
								disabled = function() return (not db.unitframes.enable or not db.unitframes.charportrait) end,
							},
							classcolor = {
								type = "toggle",
								order = 9,
								name = L["Class Color"],
								desc = L["Color unitframes by class"],						
							},
							healthcolor = {
								type = "color",
								order = 10,
								name = L["Health Color"],
								desc = L["Color of the healthbar"],
								hasAlpha = false,
								disabled = function() return (not db.unitframes.enable or db.unitframes.classcolor) end,
								get = function(info)
									local t = db.unitframes[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.unitframes[ info[#info] ] = {}
									local t = db.unitframes[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,								
							},
							healthcolorbyvalue = {
								type = "toggle",
								order = 11,
								name = L["Color Health by Value"],
								desc = L["Color the health frame by current ammount of hp remaining"],							
							},
							healthbackdrop = {
								type = "toggle",
								order = 12,
								name = L["Custom Backdrop Color"],
								desc = L["Enable using the custom backdrop color, otherwise 20% of the current health color gets used"],
							},
							healthbackdropcolor = {
								type = "color",
								order = 13,
								name = L["Health Backdrop Color"],
								desc = L["Color of the healthbar's backdrop"],
								hasAlpha = false,
								disabled = function() return (not db.unitframes.enable or not db.unitframes.healthbackdrop) end,
								get = function(info)
									local t = db.unitframes[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.unitframes[ info[#info] ] = {}
									local t = db.unitframes[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,									
							},
							combatfeedback = {
								type = "toggle",
								order = 14,
								name = L["Combat Feedback"],
								desc = L["Enable displaying incoming damage/healing on player/target frame"],							
							},
							debuffhighlight = {
								type = "toggle",
								order = 15,
								name = L["Debuff Highlighting"],
								desc = L["Enable highlighting unitframes when there is a debuff you can dispel"],							
							},
							classbar = {
								type = "toggle",
								order = 16,
								name = L["ClassBar"],
								desc = L["Display class specific bar (runebar/totembar/holypowerbar/soulshardbar/eclipsebar)"],							
							},
							combat = {
								type = "toggle",
								order = 17,
								name = L["Combat Fade"],
								desc = L["Fade main unitframes out when not in combat, unless you cast or mouseover the frame"],								
							},
							mini_powerbar = {
								type = "toggle",
								order = 18,
								name = L["Mini-Powerbar Theme"],
								desc = L["Style the unitframes with a smaller powerbar"],		
								disabled = function() return not db.unitframes.enable or db.unitframes.powerbar_offset ~= 0 end,	
							},
							mini_classbar = {
								type = "toggle",
								order = 19,
								name = L["Mini-Classbar Theme"],
								desc = L["Make classbars smaller and restyle them"],
							},
							arena = {
								type = "toggle",
								order = 20,
								name = L["Arena Frames"],							
							},
							showboss = {
								type = "toggle",
								order = 21,
								name = L["Boss Frames"],							
							},
							swing = {
								type = "toggle",
								order = 22,
								name = L["Swing Bar"],
								desc = L["Bar that displays time between melee attacks"],
								disabled = function() return (not db.unitframes.enable or not (IsAddOnLoaded("ElvUI_RaidDPS") or db.general.layoutoverride == "DPS")) end,	
							},
							displayaggro = {
								type = "toggle",
								order = 23,
								name = L["Display Aggro"],
								desc = L["Enable red glow around the player frame when you have aggro"],
							},
							powerbar_offset = {
								type = "range",
								order = 24,
								name = L["Powerbar Offset"],
								desc = L["Detach and offset the power bar on the main unitframes"],
								min = 0, max = 12, step = 1,	
							},
						},
					},
					UFSizeGroup = {
						order = 4,
						type = "group",
						name = L["Frame Sizes"],
						guiInline = true,
						disabled = function() return not db.unitframes.enable end,	
						args = {
							playtarwidth = {
								type = "range",
								order = 1,
								name = L["Player/Target Width"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 185, max = 320, step = 1,								
							},
							playtarheight = {
								type = "range",
								order = 2,
								name = L["Player/Target Height"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 35, max = 75, step = 1,								
							},
							smallwidth = {
								type = "range",
								order = 3,
								name = L["TargetTarget, Focus, FocusTarget, Pet Width"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 80, max = 175, step = 1,								
							},
							smallheight = {
								type = "range",
								order = 4,
								name = L["TargetTarget, Focus, FocusTarget, Pet Height"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 18, max = 55, step = 1,								
							},
							arenabosswidth = {
								type = "range",
								order = 5,
								name = L["Arena/Boss Width"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 175, max = 275, step = 1,								
							},
							arenabossheight = {
								type = "range",
								order = 6,
								name = L["Arena/Boss Height"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 30, max = 70, step = 1,								
							},
							assisttankwidth = {
								type = "range",
								order = 7,
								name = L["Assist/Tank Width"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 100, max = 140, step = 1,							
							},
							assisttankheight = {
								type = "range",
								order = 8,
								name = L["Assist/Tank Height"],
								desc = L["Controls the size of the frame"],
								type = "range",
								min = 15, max = 40, step = 1,							
							},							
						},
					},
					UFAurasGroup = {
						order = 5,
						type = "group",
						name = L["Auras"],
						guiInline = true,
						disabled = function() return not db.unitframes.enable end,	
						args = {
							playerbuffs = {
								type = "toggle",
								order = 1,
								name = L["Player Buffs"],
								desc = L["Display auras on frame"],				
							},
							playerdebuffs = {
								type = "toggle",
								order = 2,
								name = L["Player Debuffs"],
								desc = L["Display auras on frame"],				
							},
							targetbuffs = {
								type = "toggle",
								order = 3,
								name = L["Target Buffs"],
								desc = L["Display auras on frame"],								
							},
							targetdebuffs = {
								type = "toggle",
								order = 4,
								name = L["Target Debuffs"],
								desc = L["Display auras on frame"],								
							},
							arenabuffs = {
								type = "toggle",
								order = 5,
								name = L["Arena Buffs"],
								desc = L["Display important buffs on the arena unit, these may be changed in the filter section of the config"],								
							},
							arenadebuffs = {
								type = "toggle",
								order = 6,
								name = L["Arena Debuffs"],
								desc = L["Display important debuffs on the arena unit, these may be changed in the filter section of the config"],								
							},
							bossbuffs = {
								type = "toggle",
								order = 7,
								name = L["Boss Buffs"],
								desc = L["Display auras on frame"],								
							},
							bossdebuffs = {
								type = "toggle",
								order = 8,
								name = L["Boss Debuffs"],
								desc = L["Display auras on frame"],
							},
							totdebuffs = {
								type = "toggle",
								order = 9,
								name = L["TargetTarget Debuffs"],
								desc = L["Display auras on frame"],									
							},
							focusdebuffs = {
								type = "toggle",
								order = 10,
								name = L["Focus Debuffs"],
								desc = L["Display auras on frame"],									
							},
							playerdebuffsonly = {
								type = "toggle",
								order = 11,
								name = L["Player's Debuffs Only"],
								desc = L["Only display debuffs on the target, targettarget, boss, and arena frames that are from yourself"],						
							},
							auratimer = {
								type = "toggle",
								order = 12,
								name = L["Aura Timer"],
								desc = L["Display aura timer"],								
							},
							playtarbuffperrow = {
								type = "range",
								order = 13,
								name = L["Player/Target Auras in Row"],
								desc = L["The ammount of auras displayed in a single row"],
								type = "range",
								min = 7, max = 13, step = 1,								
							},
							smallbuffperrow = {
								type = "range",
								order = 14,
								name = L["Small Frames Auras in Row"],
								desc = L["The ammount of auras displayed in a single row"],
								type = "range",
								min = 3, max = 9, step = 1,								
							},							
							auratextscale = {
								type = "range",
								order = 15,
								name = L["Aura Text Scale"],
								desc = L["Controls the size of the aura font"],
								type = "range",
								min = 9, max = 15, step = 1,									
							},
						},
					},
					UFCBGroup = {
						order = 6,
						type = "group",
						name = L["Castbar"],
						guiInline = true,
						disabled = function() return (not db.unitframes.enable or not db.unitframes.unitcastbar) end,	
						args = {
							unitcastbar = {
								type = "toggle",
								order = 1,
								name = ENABLE,
								desc = L["Enable/Disable Castbars"],
								disabled = false,
							},
							cblatency = {
								type = "toggle",
								order = 2,
								name = L["Castbar Latency"],
								desc = L["Show latency on player castbar"],							
							},
							cbicons = {
								type = "toggle",
								order = 3,
								name = L["Castbar Icons"],
								desc = L["Show icons on castbars"],								
							},
							cbticks = {
								type = "toggle",
								order = 4,
								name = L["Castbar Ticks"],
								desc = L["Display ticks on castbar when you cast a spell that is channeled, this list may be modified under filters"],
							},
							castplayerwidth = {
								type = "range",
								order = 5,
								name = L["Width Player Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 200, max = math.ceil(ElvuiActionBarBackground:GetWidth()), step = .01,								
							},
							castplayerheight = {
								type = "range",
								order = 6,
								name = L["Height Player Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 10, max = 50, step = 1,								
							},
							casttargetwidth = {
								type = "range",
								order = 7,
								name = L["Width Target Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 200, max = math.ceil(ElvuiActionBarBackground:GetWidth()), step = .01,							
							},								
							casttargetheight = {
								type = "range",
								order = 8,
								name = L["Height Target Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 10, max = 50, step = 1,								
							},	
							castfocuswidth = {
								type = "range",
								order = 9,
								name = L["Width Focus Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 200, max = math.ceil(ElvuiActionBarBackground:GetWidth()), step = .01,						
							},							
							castfocusheight = {
								type = "range",
								order = 10,
								name = L["Height Focus Castbar"],
								desc = L["The size of the castbar"],
								type = "range",
								min = 10, max = 50, step = 1,								
							},								
							castbarcolor = {
								type = "color",
								order = 11,
								name = L["Castbar Color"],
								desc = L["Color of the castbar"],
								hasAlpha = false,
								disabled = function() return (not db.unitframes.enable or db.general.classcolortheme) end,
								get = function(info)
									local t = db.unitframes[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.unitframes[ info[#info] ] = {}
									local t = db.unitframes[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,								
							},
							nointerruptcolor = {
								type = "color",
								order = 12,
								name = L["Interrupt Color"],
								desc = L["Color of the castbar when you can't interrupt the cast"],
								hasAlpha = false,
								get = function(info)
									local t = db.unitframes[ info[#info] ]
									return t.r, t.g, t.b
								end,
								set = function(info, r, g, b)
									db.unitframes[ info[#info] ] = {}
									local t = db.unitframes[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,									
							},
						},
					},
					PowerColors = {
						type = "group",
						order = 6,
						name = L["Power Colors"],
						guiInline = true,
						get = function(info)
							local t = db.unitframes[ info[#info] ]
							return t.r, t.g, t.b, t.a
						end,
						set = function(info, r, g, b)
							db.unitframes[ info[#info] ] = {}
							local t = db.unitframes[ info[#info] ]
							t.r, t.g, t.b = r, g, b
							StaticPopup_Show("CFG_RELOAD")
						end,								
						args = {
							POWER_MANA = {
								type = "color",
								order = 1,
								name = L["Mana"],
								hasAlpha = false,						
							},
							POWER_RAGE = {
								type = "color",
								order = 2,
								name = L["Rage"],
								hasAlpha = false,							
							},
							POWER_FOCUS = {
								type = "color",
								order = 3,
								name = L["Focus"],
								hasAlpha = false,							
							},
							POWER_ENERGY = {
								type = "color",
								order = 4,
								name = L["Energy"],
								hasAlpha = false,							
							},
							POWER_RUNICPOWER = {
								type = "color",
								order = 6,
								name = L["Runic Power"],
								hasAlpha = false,							
							},
						},
					},
				},
			},
			raidframes = {
				order = 5,
				type = "group",
				name = L["Raid Frames"],
				desc = L["RF_DESC"],
				get = function(info) return db.raidframes[ info[#info] ] end,
				set = function(info, value) db.raidframes[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,				
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["RF_DESC"],					
					},
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
						desc = L["Enable Raidframes"],
					},
					RFGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.raidframes.enable or (not IsAddOnLoaded("ElvUI_RaidDPS") and not IsAddOnLoaded("ElvUI_RaidHeal")) end,	
						args = {
							fontsize = {
								type = "range",
								order = 1,
								name = L["Font Scale"],
								desc = L["Controls the size of the unitframe font"],
								type = "range",
								min = 9, max = 15, step = 1,							
							},
							scale = {
								type = "range",
								order = 2,
								name = L["Scale"],
								type = "range",
								min = 0.64, max = 1.5, step = 0.01,
								isPercent = true,
							},
							showrange = {
								order = 3,
								type = "toggle",
								name = L["Fade with Range"],
								desc = L["Fade the unit out when they become out of range"],
							},
							raidalphaoor = {
								type = "range",
								order = 2,
								name = L["Out of Range Alpha"],
								type = "range",
								min = 0, max = 1, step = 0.01,
								isPercent = true,							
							},
							healcomm = {
								order = 5,
								type = "toggle",
								name = L["Incoming Heals"],
								desc = L["Show predicted incoming heals"],
								disabled = false,	
							},
							gridhealthvertical = {
								order = 6,
								type = "toggle",
								name = L["Vertical Healthbar"],
								desc = L["Healthbar grows vertically instead of horizontally"],
								disabled = function() return not db.raidframes.enable or not IsAddOnLoaded("ElvUI_RaidHeal") end,	
							},
							showplayerinparty = {
								order = 7,
								type = "toggle",
								name = L["Player In Party"],
								desc = L["Show the player frame in the party layout"],							
							},
							maintank = {
								order = 8,
								type = "toggle",
								name = L["Maintank"],
								desc = L["Display unit"],								
							},
							mainassist = {
								order = 9,
								type = "toggle",
								name = L["Mainassist"],
								desc = L["Display unit"],								
							},
							partypets = {
								order = 10,
								type = "toggle",
								name = L["Party Pets"],
								desc = L["Display unit"],								
							},
							disableblizz = {
								order = 11,
								type = "toggle",
								name = L["Disable Blizzard Frames"],
								disabled = false,
							},
							healthdeficit = {
								order = 12,
								type = "toggle",
								name = L["Health Deficit"],
								desc = L["Display health deficit on the frame"],
							},
							griddps = {
								order = 13,
								type = "toggle",
								name = L["DPS GridMode"],
								desc = L["Show the DPS layout in gridmode instead of vertical"],
								disabled = function() return not db.raidframes.enable or not IsAddOnLoaded("ElvUI_RaidDPS") end,
							},
							role = {
								order = 14,
								type = "toggle",
								name = L["Role"],
								desc = L["Show the unit's role (DPS/Tank/healer) Note: Party frames always show this"],
							},
							partytarget = {
								order = 15,
								type = "toggle",
								name = L["Party Target's"],
								desc = L["Display unit"],
								disabled = function() return not db.raidframes.enable or not IsAddOnLoaded("ElvUI_RaidDPS") end,							
							},
							mouseglow = {
								order = 16,
								type = "toggle",
								name = L["Mouse Glow"],
								desc = L["Glow the unitframe to the unit's Reaction/Class when mouseover'd"],							
							},
							displayaggro = {
								type = "toggle",
								order = 17,
								name = L["Display Aggro"],
								desc = L["Change the frame's border to red when a unit has aggro"],
							},
							mini_powerbar = {
								type = "toggle",
								order = 18,
								name = L["Mini-Powerbar Theme"],
								desc = L["Style the unitframes with a smaller powerbar"],
							},
							gridonly = {
								type = "toggle",
								order = 19,
								name = L["25 Man Layout Party"],
								desc = L["Use the 25 man layout inside a party group"],
							},							
							raidunitbuffwatch = {
								type = "toggle",
								order = 20,
								name = L["Raid Buff Display"],
								desc = L["Display special buffs on raidframes"],
								disabled = function() return not db.raidframes.enable and not db.unitframes.enable end,
							},
							debuffs = {
								type = "toggle",
								order = 21,
								name = L["Display Debuffs"],
							},
							buffindicatorsize = {
								type = "range",
								order = 22,
								name = L["Raid Buff Display Size"],
								desc = L["Size of the buff icon on raidframes"],
								disabled = function() return not db.raidframes.enable and not db.unitframes.enable end,
								type = "range",
								min = 3, max = 9, step = 1,									
							},
						},
					},
				},
			},
			classtimer = {
				order = 6,
				type = "group",
				name = L["Class Timers"],
				desc = L["CLASSTIMER_DESC"],
				get = function(info) return db.classtimer[ info[#info] ] end,
				set = function(info, value) db.classtimer[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["CLASSTIMER_DESC"],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
						desc = L["Enable Class Timers"],
					},
					CTGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.classtimer.enable or (not ElvDPS_player and not ElvHeal_player) or not db.unitframes.enable end,	
						args = {
							bar_height = {
								type = "range",
								order = 1,
								name = L["Bar Height"],
								desc = L["Controls the height of the bar"],
								type = "range",
								min = 9, max = 25, step = 1,								
							},
							bar_spacing = {
								type = "range",
								order = 2,
								name = L["Bar Spacing"],
								desc = L["Controls the spacing in between bars"],
								type = "range",
								min = 5, max = 10, step = 1,								
							},
							icon_position = {
								type = "range",
								order = 3,
								name = L["Icon Position"],
								desc = L["0 = Left\n1 = Right\n2 = Outside Left\n3 = Outside Right"],
								type = "range",
								min = 0, max = 3, step = 1,								
							},
							layout = {
								type = "range",
								order = 4,
								name = L["Layout"],
								desc = L["LAYOUT_DESC"],
								type = "range",
								min = 1, max = 5, step = 1,								
							},
							showspark = {
								type = "toggle",
								order = 5,
								name = L["Spark"],
								desc = L["Display spark"],
							},
							cast_suparator = {
								type = "toggle",
								order = 6,
								name = L["Cast Seperator"],							
							},
							classcolor = {
								type = "toggle",
								order = 7,
								name = L["Class Color"],								
							},
							ColorGroup = {
								order = 8,
								type = "group",
								name = L["Colors"],
								guiInline = true,
								disabled = function() return not db.classtimer.enable or (not ElvDPS_player and not ElvHeal_player) or not db.unitframes.enable or db.classtimer.classcolor end,
								get = function(info)
									local t = db.classtimer[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.classtimer[ info[#info] ] = {}
									local t = db.classtimer[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,									
								args = {
									buffcolor = {
										type = "color",
										order = 1,
										name = L["Buff"],
										hasAlpha = false,	
									},
									debuffcolor = {
										type = "color",
										order = 2,
										name = L["Debuff"],
										hasAlpha = false,	
									},	
									proccolor = {
										type = "color",
										order = 3,
										name = L["Proc"],
										hasAlpha = false,	
									},											
								},
							},				
						},
					},
				},
			},
			actionbar = {
				order = 7,
				type = "group",
				name = L["Action Bars"],
				desc = L["AB_DESC"],
				get = function(info) return db.actionbar[ info[#info] ] end,
				set = function(info, value) db.actionbar[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["AB_DESC"],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
					},
					ABGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.actionbar.enable end,	
						args = {
							hotkey = {
								type = "toggle",
								order = 1,
								name = L["Hotkey Text"],
								desc = L["Display hotkey text on action buttons"],
							},
							rightbarmouseover = {
								type = "toggle",
								order = 2,
								name = L["Right Bar on Mouseover"],
								desc = L["Hide the right action bar unless mouseovered"],							
							},
							hideshapeshift = {
								type = "toggle",
								order = 3,
								name = L["Shape Shift Bar"],
								desc = L["Hide the shape shift action bar"],								
							},
							shapeshiftmouseover = {
								type = "toggle",
								order = 4,
								name = L["Shape Shift on Mouseover"],
								desc = L["Hide the shape shift action bar unless mouseovered"],	
								disabled = function() return not db.actionbar.enable or db.actionbar.hideshapeshift end,
							},
							verticalstance = {
								type = "toggle",
								order = 5,
								name = L["Vertical Shape Shift"],
								desc = L["Make the shape shift bar grow vertically instead of horizontally"],	
								disabled = function() return not db.actionbar.enable or db.actionbar.hideshapeshift end,							
							},
							showgrid = {
								type = "toggle",
								order = 6,
								name = L["Display Grid"],
								desc = L["Display grid backdrop behind empty buttons"],	
							},
							bottompetbar = {
								type = "toggle",
								order = 7,
								name = L["Pet Bar below main actionbar"],
								desc = L["Positions the pet bar below the main actionbar instead of to the right side of the screen"],								
							},
							buttonsize = {
								type = "range",
								order = 8,
								name = L["Button Size"],
								type = "range",
								min = 20, max = 40, step = 1,									
							},
							buttonspacing = {
								type = "range",
								order = 9,
								name = L["Button Spacing"],
								type = "range",
								min = 2, max = 7, step = 1,								
							},
							petbuttonsize = {
								type = "range",
								order = 10,
								name = L["Pet Button Size"],
								type = "range",
								min = 20, max = 40, step = 1,								
							},
							swaptopbottombar = {
								type = "toggle",
								order = 11,
								name = L["Main actionbar on top"],
								desc = L["Positions the main actionbar above all other actionbars"],								
							},
							macrotext = {
								type = "toggle",
								order = 12,
								name = L["Macro Text"],						
							},
							microbar = {
								type = "toggle",
								order = 13,
								name = L["Micro Bar"],
								desc = L["Display blizzards default microbar, this will disable the right click menu on minimap"],
							},
							mousemicro = {
								type = "toggle",
								order = 14,
								name = L["Micro Bar on Mouseover"],
								desc = L["Display blizzards default microbar when mouseovered"],
								disabled = function() return not db.actionbar.enable or not db.actionbar.microbar end,
							},
						},
					},
					CDGroup = {
						order = 4,
						type = "group",
						name = L["Cooldown Text"],
						guiInline = true,
						disabled = function() return not db.actionbar.enablecd end,								
						args = {
							enablecd = {
								type = "toggle",
								order = 1,
								name = ENABLE,
								disabled = false,								
							},
							treshold = {
								type = "range",
								order = 2,
								name = L["Threshold"],
								desc = L["Threshold before turning text red and displaying decimal places"],
								type = "range",
								min = -1, max = 60, step = 1,		
							},
							ColorGroup = {
								order = 3,
								type = "group",
								name = L["Colors"],
								guiInline = true,
								get = function(info)
									local t = db.actionbar[ info[#info] ]
									return t.r, t.g, t.b, t.a
								end,
								set = function(info, r, g, b)
									db.actionbar[ info[#info] ] = {}
									local t = db.actionbar[ info[#info] ]
									t.r, t.g, t.b = r, g, b
									StaticPopup_Show("CFG_RELOAD")
								end,									
								args = {
									expiringcolor = {
										type = "color",
										order = 1,
										name = L["Expiring"],
										desc = L["This gets displayed when your below the threshold"],
										hasAlpha = false,		
									},
									secondscolor = {
										type = "color",
										order = 2,
										name = L["Seconds"],
										hasAlpha = false,												
									},
									minutescolor = {
										type = "color",
										order = 3,
										name = L["Minutes"],
										hasAlpha = false,													
									},
									hourscolor = {
										type = "color",
										order = 4,
										name = L["Hours"],
										hasAlpha = false,												
									},
									dayscolor = {
										type = "color",
										order = 5,
										name = L["Days"],
										hasAlpha = false,													
									},
								},
							},
						},
					},
				},
			},
			datatext = {
				order = 8,
				type = "group",
				name = L["Data Texts"],
				desc = L["DATATEXT_DESC"],
				get = function(info) return db.datatext[ info[#info] ] end,
				set = function(info, value) db.datatext[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,		
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["DATATEXT_DESC"],
					},
					battleground = {
						order = 2,
						type = "toggle",
						name = L["BG Text"],
						desc = L["Display special datatexts when inside a battleground"],
					},
					fontsize = {
						order = 3,
						name = L["Font Scale"],
						desc = L["Font size for datatexts"],
						type = "range",
						min = 9, max = 15, step = 1,					
					},
					time24 = {
						order = 4,
						type = "toggle",
						name = L["24-Hour Time"],
						desc = L["Display time datatext on a 24 hour time scale"],	
						disabled = function() return db.datatext.wowtime == 0 end,
					},
					localtime = {
						order = 5,
						type = "toggle",
						name = L["Local Time"],
						desc = L["Display local time instead of server time"],	
						disabled = function() return db.datatext.wowtime == 0 end,					
					},
					masteryspell = {
						order = 6,
						type = "toggle",
						name = L["Mastery Spell"],
						desc = L["Display the mastery spell on the mastery datatext"],	
						disabled = function() return db.datatext.mastery == 0 end,
					},					
					classcolor = {
						order = 7,
						type = "toggle",
						name = L["Class Color"],
						desc = L["Color the datatext values based on your class"],
					},
					DataGroup = {
						order = 8,
						type = "group",
						name = L["Text Positions"],
						guiInline = true,
						args = {
							stat1 = {
								order = 1,
								type = "range",
								name = L["Stat #1"],
								desc = L["Display stat based on your role (Avoidance-Tank, AP-Melee, SP/HP-Caster)"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,
							},
							dur = {
								order = 2,
								type = "range",
								name = L["Durability"],
								desc = L["Display your current durability"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,							
							},
							stat2 = {
								order = 3,
								type = "range",
								name = L["Stat #2"],
								desc = L["Display stat based on your role (Armor-Tank, Crit-Melee, Crit-Caster)"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,							
							},
							system = {
								order = 4,
								type = "range",
								name = L["System"],
								desc = L["Display FPS and Latency"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							wowtime = {
								order = 5,
								type = "range",
								name = L["Time"],
								desc = L["Display current time"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,									
							},
							gold = {
								order = 6,
								type = "range",
								name = L["Gold"],
								desc = L["Display current gold"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							guild = {
								order = 7,
								type = "range",
								name = L["Guild"],
								desc = L["Display current online people in guild"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							friends = {
								order = 8,
								type = "range",
								name = L["Friends"],
								desc = L["Display current online friends"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							bags = {
								order = 9,
								type = "range",
								name = L["Bags"],
								desc = L["Display ammount of bag space"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							dps_text = {
								order = 10,
								type = "range",
								name = L["DPS"],
								desc = L["Display ammount of DPS"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							hps_text = {
								order = 11,
								type = "range",
								name = L["HPS"],
								desc = L["Display ammount of HPS"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							currency = {
								order = 12,
								type = "range",
								name = L["Currency"],
								desc = L["Display current watched items in backpack"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							specswitch = {
								order = 13,
								type = "range",
								name = L["Talent Spec"],
								desc = L["Display current spec"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							mastery = {
								order = 14,
								type = "range",
								name = L["Mastery"],
								desc = L["Display Mastery Rating"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							hit = {
								order = 15,
								type = "range",
								name = L["Hit Rating"],
								desc = L["Display Hit Rating"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							haste = {
								order = 16,
								type = "range",
								name = L["Haste Rating"],
								desc = L["Display Haste Rating"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,								
							},
							crit = {
								order = 17,
								type = "range",
								name = L["Crit Rating"],
								desc = L["Display Critical Strike Rating"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,									
							},
							manaregen = {
								order = 17,
								type = "range",
								name = L["Mana Regen"],
								desc = L["Display Mana Regen Rate"]..L["DATATEXT_POS"],
								min = 0, max = 8, step = 1,									
							},
						},
					},
				},
			},
			chat = {
				order = 9,
				type = "group",
				name = L["Chat"],
				desc = L["CHAT_DESC"],
				get = function(info) return db.chat[ info[#info] ] end,
				set = function(info, value) db.chat[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,		
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["CHAT_DESC"],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
					},
					ChatGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.chat.enable end,	
						args = {
							whispersound = {
								type = "toggle",
								order = 1,
								name = L["Whisper Sound"],
								desc = L["Play a sound when receiving a whisper, this can be set in media section"],
							},
							showbackdrop = {
								type = "toggle",
								order = 2,
								name = L["Chat Backdrop"],
								desc = L["Display backdrop panels behind chat window"],							
							},
							chatwidth = {
								type = "range",
								order = 3,
								name = L["Chat Width"],
								desc = L["Width of chatframe"],
								min = 200, max = 600, step = 1,
							},
							chatheight = {
								type = "range",
								order = 4,
								name = L["Chat Height"],
								desc = L["Height of chatframe"],
								min = 75, max = 450, step = 1,
							},
							fadeoutofuse = {
								type = "toggle",
								order = 5,
								name = L["Fade Windows"],
								desc = L["Fade chat windows after a long period of no activity"],								
							},
							sticky = {
								type = "toggle",
								order = 6,
								name = L["Sticky Editbox"],
								desc = L["When pressing enter to open the chat editbox, display the last known channel"],								
							},
							combathide = {
								type = "select",
								order = 7,
								name = L["Toggle Chat In Combat"],
								desc = L["When you enter combat, the selected window will toggle out of view"],
								values = {
									["NONE"] = L["None"],
									["Left"] = L["Left"],
									["Right"] = L["Right"],
									["Both"] = L["Both"],
								},
							},
							bubbles = {
								type = "toggle",
								order = 8,
								name = L["Chat Bubbles"],
								desc = L["Skin Blizzard's Chat Bubbles"],							
							},
						},
					},
				},
			},
			tooltip = {
				order = 9,
				type = "group",
				name = L["Tooltip"],
				desc = L["TT_DESC"],
				get = function(info) return db.tooltip[ info[#info] ] end,
				set = function(info, value) db.tooltip[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,		
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["TT_DESC"],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = ENABLE,
					},
					TTGroup = {
						order = 3,
						type = "group",
						name = L["General Settings"],
						guiInline = true,
						disabled = function() return not db.tooltip.enable end,	
						args = {
							hidecombat = {
								order = 1,
								type = "toggle",
								name = L["Hide Combat"],
								desc = L["Hide tooltip when entering combat"],
							},
							hidecombatraid = {
								order = 2,
								type = "toggle",
								name = L["Hide Combat in Raid"],
								desc = L["Hide tooltip when entering combat only inside a raid instance"],	
								disabled = function() return not db.tooltip.enable or not db.tooltip.hidecombat end,
							},
							hidebuttons = {
								order = 3,
								type = "toggle",
								name = L["Hide Buttons"],
								desc = L["Hide tooltip when mousing over action buttons"],								
							},
							hideuf = {
								order = 4,
								type = "toggle",
								name = L["Hide Unit Frames"],
								desc = L["Hide tooltip when mousing over unit frames"],								
							},
							cursor = {
								order = 5,
								type = "toggle",
								name = L["Cursor"],
								desc = L["Tooltip anchored to cursor"],								
							},
							colorreaction = {
								order = 6,
								type = "toggle",
								name = L["Color Reaction"],
								desc = L["Always color border of tooltip by unit reaction"],									
							},
							itemid = {
								order = 7,
								type = "toggle",
								name = L["ItemID"],
								desc = L["Display itemid on item tooltips"],							
							},
							whotargetting = {
								order = 8,
								type = "toggle",
								name = L["Who's Targetting?"],
								desc = L["Display if anyone in your party/raid is targetting the tooltip unit"],								
							},
						},
					},
				},
			},
			skin = {
				order = 10,
				type = "group",
				name = L["Addon Skins"],
				desc = L["ADDON_DESC"],
				get = function(info) return db.skin[ info[#info] ] end,
				set = function(info, value) db.skin[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["ADDON_DESC"],
					},
					embedright = {
						order = 2,
						type = "select",
						name = L["Embed Right"],
						desc = L["EMBED_DESC"],
						values = {
							["NONE"] = L["None"],
							["Recount"] = "Recount",
							["Omen"] = "Omen",
							["Skada"] = "Skada",
						},						
					},
					SkadaGroup = {
						order = 3,
						type = "group",
						name = "Skada",
						args = {
							skada = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
						},
					},
					RecountGroup = {
						order = 4,
						type = "group",
						name = "Recount",
						args = {
							recount = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
						},
					},	
					OmenGroup = {
						order = 5,
						type = "group",
						name = "Omen",
						args = {
							omen = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
						},
					},		
					KLEGroup = {
						order = 6,
						type = "group",
						name = "KLE",
						args = {
							kle = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
							hookkleright = {
								order = 2,
								type = "toggle",
								name = L["Hook KLE Bars"],
								desc = L["Attach KLE's Bars to the right window"],
							},
						},
					},	
					DBMGroup = {
						order = 7,
						type = "group",
						name = "DBM",
						args = {
							dbm = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
						},
					},		
					BigWigsGroup = {
						order = 8,
						type = "group",
						name = "BigWigs",
						args = {
							bigwigs = {
								order = 1,
								type = "toggle",
								name = ENABLE,
								desc = L["Enable this skin"],
							},
							hookbwright = {
								order = 2,
								type = "toggle",
								name = L["Hook BigWigs Bars"],
								desc = L["Attach BigWigs's Bars to the right window"],
							},							
						},
					},						
				},
			},	
			spellfilter = {
				order = 9,
				type = "group",
				name = L["Filters"],
				desc = L["SPELL_FILTER_DESC"],
				get = function(info) return db.spellfilter[ info[#info] ] end,
				set = function(info, value) db.spellfilter[ info[#info] ] = value end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["SPELL_FILTER_DESC"],
					},
					FilterPicker = {
						order = 2,
						type = "select",
						name = L["Choose Filter"],
						desc = L["Choose the filter you want to modify."],
						set = function(info, value) 
							db.spellfilter[ info[#info] ] = value 
							UpdateSpellFilter()
						end,
						values = {
							["RaidDebuffs"] = L["Raid Debuffs"],
							["DebuffBlacklist"] = L["Debuff Blacklist"],	
							["DebuffWhiteList"] = L["Debuff Whitelist"],
							["TargetPVPOnly"] = L["Target Debuffs (PvP Only)"],
							["ArenaBuffWhiteList"] = L["Arena Buffs"],
							["PlateBlacklist"] = L["Nameplate Blacklist"],
							["HealerBuffIDs"] = L["Raid Buffs (Heal)"],
							["DPSBuffIDs"] = L["Raid Buffs (DPS)"],
							["PetBuffs"] = L["Pet Buffs"],
							["TRINKET_FILTER"] = L["Class Timer (Shared)"],
							["CLASS_FILTERS"] = L["Class Timer (Player)"],
							["ChannelTicks"] = L["Castbar Ticks"]
						},						
					},			
					spacer = {
						type = 'description',
						name = '',
						desc = '',
						order = 3,
					},		
					FilterDesc = {
						type = 'description',
						name = GetFilterDesc(),
						order = 4,
					},						
					NewName = {
						type = 'input',
						name = function() if ClassTimerShared[db.spellfilter.FilterPicker] or ClassTimer[db.spellfilter.FilterPicker] or RaidBuffs[db.spellfilter.FilterPicker] then return L["New ID"] else return L["New name"] end end,
						desc = L["Add a new spell name / ID to the list."],
						get = function(info) return "" end,
						set = function(info, value)
							if db.spellfilter.FilterPicker == "ChannelTicks" then
								local name_list = db.spellfilter[db.spellfilter.FilterPicker]
								name_list[value] = 0
								UpdateSpellFilter()
								StaticPopup_Show("CFG_RELOAD")
							elseif ClassTimer[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								elseif not db.spellfilter["SelectSpellFilter"] then
									print(L["You must select a filter first"])
								else
									local curfilter = db.spellfilter["SelectSpellFilter"]
									local num = #db.spellfilter[db.spellfilter.FilterPicker] + 1
									db.spellfilter[db.spellfilter.FilterPicker][E.myclass][curfilter][num] = { enabled = true, id = tonumber(value), castByAnyone = false, color = nil, unitType = 0, castSpellId = nil }
									UpdateSpellFilter()								
									StaticPopup_Show("CFG_RELOAD")
								end									
							elseif ClassTimerShared[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								else
									local num = #db.spellfilter[db.spellfilter.FilterPicker] + 1
									db.spellfilter[db.spellfilter.FilterPicker][num] = { enabled = true, id = tonumber(value), castByAnyone = false, color = nil, unitType = 0, castSpellId = nil }
									UpdateSpellFilter()								
									StaticPopup_Show("CFG_RELOAD")
								end							
							elseif RaidBuffs[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								else
									local num = #db.spellfilter[db.spellfilter.FilterPicker][E.myclass] + 1
									db.spellfilter[db.spellfilter.FilterPicker][E.myclass][num] = {["enabled"] = true, ["id"] = tonumber(value), ["point"] = "TOPRIGHT", ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0}, ["anyUnit"] = false}
									UpdateSpellFilter()								
									StaticPopup_Show("CFG_RELOAD")
								end
							else
								local name_list = db.spellfilter[db.spellfilter.FilterPicker]
								name_list[value] = true
								UpdateSpellFilter()
								E[name_list] = db.spellfilter[name_list]
								
								StaticPopup_Show("CFG_RELOAD")
							end
						end,
						order = 5,
					},
					DeleteName = {
						type = 'input',
						name = function() if ClassTimerShared[db.spellfilter.FilterPicker] or ClassTimer[db.spellfilter.FilterPicker] or RaidBuffs[db.spellfilter.FilterPicker] then return L["Remove ID"] else return L["Remove Name"] end end,
						desc = L["You may only delete spells that you have added. Default spells can be disabled by unchecking the option"],
						get = function(info) return "" end,
						set = function(info, value)

							if ClassTimer[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								elseif not db.spellfilter["SelectSpellFilter"] then
									print(L["You must select a filter first"])
								else
									local curfilter = db.spellfilter["SelectSpellFilter"]
									local match
									for x, y in pairs (db.spellfilter[db.spellfilter.FilterPicker][E.myclass][curfilter]) do
										if y["id"] == tonumber(value) then
											match = y
											db.spellfilter[db.spellfilter.FilterPicker][E.myclass][curfilter][x] = nil
										end
									end
									if match == nil then
										print(L["Spell not found in list"])
									else
										UpdateSpellFilter()								
										StaticPopup_Show("CFG_RELOAD")									
									end	
								end	
							elseif ClassTimerShared[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								else
									local match
									for x, y in pairs (db.spellfilter[db.spellfilter.FilterPicker]) do
										if y["id"] == tonumber(value) then
											match = y
											db.spellfilter[db.spellfilter.FilterPicker][x] = nil
										end
									end
									if match == nil then
										print(L["Spell not found in list"])
									else
										UpdateSpellFilter()								
										StaticPopup_Show("CFG_RELOAD")									
									end	
								end	
							elseif RaidBuffs[db.spellfilter.FilterPicker] then
								if not GetSpellInfo(value) then
									print(L["Not valid spell id"])
								else
									local match
									for x, y in pairs(db.spellfilter[db.spellfilter.FilterPicker][E.myclass]) do
										if y["id"] == tonumber(value) then
											match = y
											db.spellfilter[db.spellfilter.FilterPicker][E.myclass][x] = nil
										end
									end
									if match == nil then
										print(L["Spell not found in list"])
									else
										UpdateSpellFilter()								
										StaticPopup_Show("CFG_RELOAD")									
									end									
								end								
							else
								local name_list = db.spellfilter[db.spellfilter.FilterPicker]
								if db.spellfilter[db.spellfilter.FilterPicker][value] == nil then
									print(L["Spell not found in list"])
								else
									name_list[value] = nil
									UpdateSpellFilter()
									E[name_list] = db.spellfilter[name_list]
									
									if name_list == "RaidDebuffs" then
										StaticPopup_Show("CFG_RELOAD")
									end
								end
							end
						end,
						order = 6,
					},
					SpellListTable = {
						order = 7,
						type = "group",
						name = GetFilterName(),
						guiInline = true,
						args = CreateFilterTable(db.spellfilter.FilterPicker),
					},
				},
			},
			others = {
				order = 10,
				type = "group",
				name = L["Misc"],
				desc = L["MISC_DESC"],
				get = function(info) return db.others[ info[#info] ] end,
				set = function(info, value) db.others[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,		
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["MISC_DESC"],
					},
					GenGroup = {
						order = 2,
						type = "group",
						name = L["General"],	
						args = {
							pvpautorelease = {
								type = "toggle",
								order = 1,
								name = L["PVP Autorelease"],
								desc = L["Automatically release body when dead inside a bg"],
								disabled = function() return E.myclass == "SHAMAN" end,
							},
							errorenable = {
								type = "toggle",
								order = 2,
								name = L["Hide Error Text"],
								desc = L["Hide annoying red error text on center of screen"],							
							},
							autoacceptinv = {
								type = "toggle",
								order = 3,
								name = L["Auto Accept Invite"],
								desc = L["Automatically accept invite when invited by a friend/guildie"],							
							},
							enablebag = {
								type = "toggle",
								order = 4,
								name = L["All-In-One Bag"],
								desc = L["Enable/Disable the All-In-One Bag, you must disable this if you wish to run another bag addon"],										
							},
							enablemap = {
								type = "toggle",
								order = 5,
								name = L["Map Skin"],
								desc = L["Enable/Disable the map skin"],										
							},							
						},
					},
					LootGroup = {
						order = 3,
						type = "group",
						name = L["Loot"],	
						args = {
							lootframe = {
								type = "toggle",
								order = 1,
								name = L["Loot Frame"],
								desc = L["Skin loot window"],							
							},
							rolllootframe = {
								type = "toggle",
								order = 2,
								name = L["Loot Roll Frame"],
								desc = L["Skin loot roll window"],								
							},
							autogreed = {
								type = "toggle",
								order = 3,
								name = L["Auto Greed/DE"],
								desc = L["Automatically roll greed or Disenchant on green quality items"],								
							},
							sellgrays = {
								type = "toggle",
								order = 4,
								name = L["Sell Grays"],
								desc = L["Automatically sell gray items when visiting a vendor"],								
							},
							autorepair = {
								type = "toggle",
								order = 4,
								name = L["Auto Repair"],
								desc = L["Automatically repair when visiting a vendor"],							
							},
						},
					},
					AurasGroup = {
						order = 3,
						type = "group",
						name = L["Combat"],	
						args = {
							buffreminder = {
								type = "toggle",
								order = 1,
								name = L["Buff Reminder"],
								desc = L["Icon at center of screen when you are missing a buff, or you have a buff you shouldn't have"],									
							},
							remindersound = {
								type = "toggle",
								order = 2,
								name = L["Buff Reminder Sound"],
								desc = L["Play sound when icon is displayed"],							
							},
							raidbuffreminder = {
								type = "toggle",
								order = 3,
								name = L["Raid Buffs Reminder"],
								desc = L["Icons below minimap, displayed inside instances"],								
							},
							announceinterrupt = {
								type = "select",
								order = 4,
								name = L["Interrupt Announce"],
								desc = L["Announce when you interrupt a spell"],
								values = {
									["NONE"] = L["None"],
									["SAY"] = CHAT_MSG_SAY,
									["PARTY"] = PARTY,
									["RAID"] = RAID,
								},
							},
							showthreat = {
								type = "toggle",
								order = 5,
								name = L["Threat Display"],
								desc = L["Display threat in the bottomright panel"],							
							},
							minimapauras = {
								type = "toggle",
								order = 6,
								name = L["Minimap Auras"],
								desc = L["Display blizzard skinned auras by the minimap"],							
							},
						},
					},
				},		
			},
		},
	}
	
	if C["general"].upperpanel == true then
		for _, option in pairs(ElvuiConfig.Options.args.datatext.args.DataGroup.args) do
			option.max = 10
		end
		L["DATATEXT_POS"] = L["DATATEXT_POS2"]
	end
end


