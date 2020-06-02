local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')
local MC = E:GetModule('ModuleCopy')

function MC:AddConfigOptions(settings, config)
	for option, tbl in pairs(settings) do
		if type(tbl) == 'table' and not (tbl.r and tbl.g and tbl.b) then
			config.args[option] = {
				type = "toggle",
				name = option,
			}
		end
	end
end

--Actionbars
local function CreateActionbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["ActionBars"], "actionbar")
	local order = 3

	MC:AddConfigOptions(P.actionbar, config)

	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	for i = 1, 10 do
		config.args["bar"..i].name = L["Bar "]..i
		config.args["bar"..i].order = order
		order = order + 1
	end

	config.args.barPet.name = L["Pet Bar"]
	config.args.stanceBar.name = L["Stance Bar"]
	config.args.microbar.name = L["Micro Bar"]
	config.args.extraActionButton.name = L["Boss Button"]
	config.args.vehicleExitButton.name = L["Vehicle Exit"]

	return config
end

--Auras
local function CreateAurasConfig()
	local config = MC:CreateModuleConfigGroup(L["Auras"], "auras")

	MC:AddConfigOptions(P.auras, config)

	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	config.args.buffs.name = L["Buffs"]
	config.args.debuffs.name = L["Debuffs"]

	return config
end

--Bags
local function CreateBagsConfig()
	local config = MC:CreateModuleConfigGroup(L["Bags"], "bags")

	MC:AddConfigOptions(P.bags, config)

	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	config.args.ignoredItems = nil
	config.args.colors.name = L["COLORS"]
	config.args.bagBar.name = L["Bag-Bar"]
	config.args.split.name = L["Split"]
	config.args.vendorGrays.name = L["Vendor Grays"]

	return config
end

--Chat
local function CreateChatConfig()
	local config = MC:CreateModuleConfigGroup(L["Chat"], "chat")

	return config
end

--Cooldowns
local function CreateCooldownConfig()
	local config = MC:CreateModuleConfigGroup(L["Cooldown Text"], "cooldown")
	config.args.fonts = {
		order = 2,
		type = "toggle",
		name = L["Fonts"],
	}

	return config
end

--DataBars
local function CreateDatatbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataBars"], "databars")

	MC:AddConfigOptions(P.databars, config)

	config.args.experience.name = L["XPBAR_LABEL"]
	config.args.reputation.name = L["REPUTATION"]
	config.args.honor.name = L["HONOR"]
	config.args.azerite.name = L["Azerite Bar"]

	return config
end

--DataTexts
local function CreateDatatextsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataTexts"], "datatexts")
	config.args.panels = {
		order = 2,
		type = "toggle",
		name = L["Panels"],
	}

	return config
end

--General
local function CreateGeneralConfig()
	local config = MC:CreateModuleConfigGroup(L["General"], "general")

	MC:AddConfigOptions(P.general, config)

	config.args.altPowerBar.name = L["Alternative Power"]
	config.args.minimap.name = L["MINIMAP_LABEL"]
	config.args.threat.name = L["Threat"]
	config.args.totems.name = L["Class Totems"]
	config.args.itemLevel.name = L["Item Level"]

	return config
end

--NamePlates
local function CreateNamePlatesConfig()
	local config = MC:CreateModuleConfigGroup(L["NamePlates"], "nameplates")

	MC:AddConfigOptions(P.nameplates, config)

	-- Locales
	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	config.args.threat.name = L["Threat"]
	config.args.cutaway.name = L["Cutaway Bars"]
	config.args.clickThrough.name = L["Click Through"]
	config.args.plateSize.name = L["Clickable Size"]
	config.args.colors.name = L["COLORS"]
	config.args.visibility.name = L["Visibility"]

	-- Modify Tables
	config.args.filters = nil
	config.args.units = {
		order = -5,
		type = "group",
		guiInline = true,
		name = L["NamePlates"],
		get = function(info) return E.global.profileCopy.nameplates[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.nameplates[info[#info-1]][info[#info]] = value; end,
		args = {},
	}

	MC:AddConfigOptions(P.nameplates.units, config.args.units)

	-- Locales
	config.args.units.args.PLAYER.name = L["Player"]
	config.args.units.args.TARGET.name = L["Target"]
	config.args.units.args.FRIENDLY_PLAYER.name = L["FRIENDLY_PLAYER"]
	config.args.units.args.ENEMY_PLAYER.name = L["ENEMY_PLAYER"]
	config.args.units.args.FRIENDLY_NPC.name = L["FRIENDLY_NPC"]
	config.args.units.args.ENEMY_NPC.name = L["ENEMY_NPC"]

	return config
end

--Tooltip
local function CreateTooltipConfig()
	local config = MC:CreateModuleConfigGroup(L["Tooltip"], "tooltip")

	MC:AddConfigOptions(P.tooltip, config)

	config.args.visibility.name = L["Visibility"]
	config.args.healthBar.name = L["Health Bar"]
	config.args.factionColors.name = L["Custom Faction Colors"]

	return config
end

--UnitFrames
local function CreateUnitframesConfig()
	local config = MC:CreateModuleConfigGroup(L["UnitFrames"], "unitframe")
	config.args.cooldown = {
		order = 2,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.unitframe[info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info]] = value; end
	}

	config.args.colors = {
		order = 3,
		type = "group",
		guiInline = true,
		name = L["COLORS"],
		get = function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end,
		args = {},
	}

	MC:AddConfigOptions(P.unitframe.colors, config.args.colors)

	config.args.colors.args.power.name = L["Powers"]
	config.args.colors.args.reaction.name = L["Reactions"]
	config.args.colors.args.healPrediction.name = L["Heal Prediction"]
	config.args.colors.args.classResources.name = L["Class Resources"]
	config.args.colors.args.frameGlow.name = L["Frame Glow"]
	config.args.colors.args.debuffHighlight.name = L["Debuff Highlighting"]
	config.args.colors.args.powerPrediction.name = L["Power Prediction"]
	config.args.colors.args.selection.name = L["Selection"]
	config.args.colors.args.threat.name = L["Threat"]

	config.args.units = {
		order = 4,
		type = "group",
		guiInline = true,
		name = L["UnitFrames"],
		get = function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end,
		args = {},
	}

	MC:AddConfigOptions(P.unitframe.units, config.args.units)

	config.args.units.args.player.name = L["Player"]
	config.args.units.args.target.name = L["Target"]
	config.args.units.args.targettarget.name = L["TargetTarget"]
	config.args.units.args.targettargettarget.name = L["TargetTargetTarget"]
	config.args.units.args.focus.name = L["Focus"]
	config.args.units.args.focustarget.name = L["FocusTarget"]
	config.args.units.args.pet.name = L["PET"]
	config.args.units.args.pettarget.name = L["PetTarget"]
	config.args.units.args.boss.name = L["Boss"]
	config.args.units.args.arena.name = L["Arena"]
	config.args.units.args.party.name = L["PARTY"]
	config.args.units.args.raid.name = L["Raid"]
	config.args.units.args.raid40.name = L["Raid-40"]
	config.args.units.args.raidpet.name = L["Raid Pet"]
	config.args.units.args.tank.name = L["TANK"]
	config.args.units.args.assist.name = L["Assist"]

	return config
end

E.Options.args.modulecontrol= {
	order = 3,
	type = "group",
	name = L["Module Control"],
	childGroups = "tab",
	args = {
		modulecopy = {
			type = "group",
			name = L["Module Copy"],
			order = 1,
			childGroups = "tab",
			handler = E.Options.args.profiles.handler,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["This section will allow you to copy settings to a select module from or to a different profile."],
				},
				pluginInfo = {
					order = 2,
					type = "description",
					name = L["If you have any plugins supporting this feature installed you can find them in the selection dropdown to the right."],
				},
				profile = {
					order = 3,
					type = "select",
					name = L["Profile"],
					desc = L["Select a profile to copy from/to."],
					get = function(info) return E.global.profileCopy.selected end,
					set = function(info, value) E.global.profileCopy.selected = value end,
					values = E.Options.args.profiles.args.copyfrom.values,
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					arg = E.Options.args.profiles.args.copyfrom.arg,
				},
				elvui = {
					order = 10,
					type = 'group',
					name = 'ElvUI',
					desc = L["Core |cff1784d1ElvUI|r options."],
					childGroups = "tree",
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					args = {
						header = {
							order = 0,
							type = "header",
							name = L["Core |cff1784d1ElvUI|r options."],
						},
						actionbar = CreateActionbarsConfig(),
						auras = CreateAurasConfig(),
						bags = CreateBagsConfig(),
						chat = CreateChatConfig(),
						cooldown = CreateCooldownConfig(),
						databars = CreateDatatbarsConfig(),
						datatexts = CreateDatatextsConfig(),
						general = CreateGeneralConfig(),
						nameplates = CreateNamePlatesConfig(),
						tooltip = CreateTooltipConfig(),
						uniframes = CreateUnitframesConfig(),
					},
				},
				movers = {
					order = 20,
					type = 'group',
					name = L["Movers"],
					desc = L["On screen positions for different elements."],
					childGroups = "tree",
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					args = MC:CreateMoversConfigGroup(),
				},
			},
		},
		modulereset = {
			type = "group",
			name = L["Module Reset"],
			order = 2,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Module Reset"],
				},
				intro = {
					order = 1,
					type = "description",
					name = L["This section will help reset specfic settings back to default."],
				},
				space1 = {
					order = 2,
					type = "description",
					name = "",
				},
				general = {
					order = 3,
					type = 'execute',
					name = L["General"],
					confirm = true,
					confirmText = L["Are you sure you want to reset General settings?"],
					func = function() E:CopyTable(E.db.general, P.general) end,
				},
				actionbar = {
					order = 5,
					type = 'execute',
					name = L["ActionBars"],
					confirm = true,
					confirmText = L["Are you sure you want to reset ActionBars settings?"],
					func = function() E:CopyTable(E.db.actionbar, P.actionbar) end,
				},
				bags = {
					order = 6,
					type = 'execute',
					name = L["Bags"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Bags settings?"],
					func = function() E:CopyTable(E.db.bags, P.bags) end,
				},
				auras = {
					order = 7,
					type = 'execute',
					name = L["Auras"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Auras settings?"],
					func = function() E:CopyTable(E.db.auras, P.auras) end,
				},
				chat = {
					order = 8,
					type = 'execute',
					name = L["Chat"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Chat settings?"],
					func = function() E:CopyTable(E.db.chat, P.chat) end,
				},
				cooldown = {
					order = 9,
					type = 'execute',
					name = L["Cooldown Text"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Cooldown settings?"],
					func = function() E:CopyTable(E.db.cooldown, P.cooldown) end,
				},
				databars = {
					order = 10,
					type = 'execute',
					name = L["DataBars"],
					confirm = true,
					confirmText = L["Are you sure you want to reset DataBars settings?"],
					func = function() E:CopyTable(E.db.databars, P.databars) end,
				},
				datatexts = {
					order = 11,
					type = 'execute',
					name = L["DataTexts"],
					confirm = true,
					confirmText = L["Are you sure you want to reset DataTexts settings?"],
					func = function() E:CopyTable(E.db.datatexts, P.datatexts) end,
				},
				nameplates = {
					order = 12,
					type = 'execute',
					name = L["NamePlates"],
					confirm = true,
					confirmText = L["Are you sure you want to reset NamePlates settings?"],
					func = function() E:CopyTable(E.db.nameplates, P.nameplates) end,
				},
				tooltip = {
					order = 13,
					type = 'execute',
					name = L["Tooltip"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Tooltip settings?"],
					func = function() E:CopyTable(E.db.tooltip, P.tooltip) end,
				},
				uniframes = {
					order = 14,
					type = 'execute',
					name = L["UnitFrames"],
					confirm = true,
					confirmText = L["Are you sure you want to reset UnitFrames settings?"],
					func = function() E:CopyTable(E.db.unitframe, P.unitframe); UF:Update_AllFrames() end,
				},
			},
		},
	},
}
