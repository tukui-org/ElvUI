local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')
local MC = E:GetModule('ModuleCopy')
local ACH = E.Libs.ACH

local type, pairs = type, pairs

function MC:AddConfigOptions(settings, config)
	for option, tbl in pairs(settings) do
		if type(tbl) == 'table' and not (tbl.r and tbl.g and tbl.b) then
			config.args[option] = ACH:Toggle(option)
		end
	end
end

--Actionbars
local function CreateActionbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["ActionBars"], 'actionbar')
	local order = 3

	MC:AddConfigOptions(P.actionbar, config)

	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	for i = 1, 10 do
		config.args['bar'..i].name = L["Bar "]..i
		config.args['bar'..i].order = order
		order = order + 1
	end

	config.args.barPet.name = L["Pet Bar"]
	config.args.stanceBar.name = L["Stance Bar"]
	config.args.microbar.name = L["Micro Bar"]
	config.args.extraActionButton.name = L["Boss Button"]
	config.args.vehicleExitButton.name = L["Vehicle Exit"]
	config.args.zoneActionButton.name = L["Zone Ability"]

	return config
end

--Auras
local function CreateAurasConfig()
	local config = MC:CreateModuleConfigGroup(L["Auras"], 'auras')

	MC:AddConfigOptions(P.auras, config)

	config.args.cooldown.name = L["Cooldown Text"]
	config.args.cooldown.order = 2

	config.args.buffs.name = L["Buffs"]
	config.args.debuffs.name = L["Debuffs"]

	return config
end

--Bags
local function CreateBagsConfig()
	local config = MC:CreateModuleConfigGroup(L["Bags"], 'bags')

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
	return MC:CreateModuleConfigGroup(L["Chat"], 'chat')
end

--Cooldowns
local function CreateCooldownConfig()
	local config = MC:CreateModuleConfigGroup(L["Cooldown Text"], 'cooldown')
	config.args.fonts = ACH:Toggle(L["Fonts"], nil, 2)

	return config
end

--DataBars
local function CreateDatatbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataBars"], 'databars')

	MC:AddConfigOptions(P.databars, config)

	config.args.colors.name = L["Colors"]
	config.args.experience.name = L["Experience"]
	config.args.reputation.name = L["Reputation"]
	config.args.honor.name = L["Honor"]
	config.args.threat.name = L["Threat"]
	config.args.azerite.name = L["Azerite"]

	return config
end

--DataTexts
local function CreateDatatextsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataTexts"], 'datatexts')
	config.args.panels = ACH:Toggle(L["Panels"], nil, 2)

	return config
end

--General
local function CreateGeneralConfig()
	local config = MC:CreateModuleConfigGroup(L["General"], 'general')

	MC:AddConfigOptions(P.general, config)

	config.args.altPowerBar.name = L["Alternative Power"]
	config.args.minimap.name = L["MINIMAP_LABEL"]
	config.args.totems.name = L["Class Totems"]
	config.args.itemLevel.name = L["Item Level"]

	return config
end

--NamePlates
local function CreateNamePlatesConfig()
	local config = MC:CreateModuleConfigGroup(L["NamePlates"], 'nameplates')

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
	config.args.units = ACH:Group(L["NamePlates"], nil, -5, nil, function(info) return E.global.profileCopy.nameplates[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.nameplates[info[#info-1]][info[#info]] = value; end)
	config.args.units.inline = true

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
	local config = MC:CreateModuleConfigGroup(L["Tooltip"], 'tooltip')

	MC:AddConfigOptions(P.tooltip, config)

	config.args.visibility.name = L["Visibility"]
	config.args.healthBar.name = L["Health Bar"]
	config.args.factionColors.name = L["Custom Faction Colors"]

	return config
end

--UnitFrames
local function CreateUnitframesConfig()
	local config = MC:CreateModuleConfigGroup(L["UnitFrames"], 'unitframe')
	config.args.cooldown = ACH:Toggle(L["Cooldown Text"], nil, 2, nil, nil, nil, function(info) return E.global.profileCopy.unitframe[info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info]] = value; end)
	config.args.colors = ACH:Group(L["COLORS"], nil, 3, nil, function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end)
	config.args.colors.inline = true

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

	config.args.units = ACH:Group(L["UnitFrames"], nil, 4, nil, function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end, function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end)
	config.args.units.inline = true

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

E.Options.args.modulecontrol= ACH:Group(L["Module Control"], nil, 3, 'tab')
E.Options.args.modulecontrol.args.modulecopy = ACH:Group(L["Module Copy"], nil, 1, 'tab')
E.Options.args.modulecontrol.args.modulecopy.handler = E.Options.args.profiles.handler
E.Options.args.modulecontrol.args.modulecopy.args.intro = ACH:Description(L["This section will allow you to copy settings to a select module from or to a different profile."], 1, 'medium')
E.Options.args.modulecontrol.args.modulecopy.args.pluginInfo = ACH:Description(L["If you have any plugins supporting this feature installed you can find them in the selection dropdown to the right."], 2, 'medium')
E.Options.args.modulecontrol.args.modulecopy.args.profile = ACH:Select(L["Profile"], L["Select a profile to copy from/to."], 3, function() local tbl = {} for profile in pairs(E.data.profiles) do tbl[profile] = profile end return tbl end, nil, nil, function() return E.global.profileCopy.selected end, function(_, value) E.global.profileCopy.selected = value end)
E.Options.args.modulecontrol.args.modulecopy.args.elvui = ACH:Group('ElvUI', L["Core |cff1784d1ElvUI|r options."], 10, 'tree')
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.header = ACH:Header(L["Core |cff1784d1ElvUI|r options."], 0)
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar = CreateActionbarsConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.auras = CreateAurasConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.bags = CreateBagsConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.chat = CreateChatConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.cooldown = CreateCooldownConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.databars = CreateDatatbarsConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.datatexts = CreateDatatextsConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.general = CreateGeneralConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.nameplates = CreateNamePlatesConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.tooltip = CreateTooltipConfig()
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.uniframes = CreateUnitframesConfig()

E.Options.args.modulecontrol.args.modulecopy.args.movers = ACH:Group(L["Movers"], L["On screen positions for different elements."], 20, 'tree')
E.Options.args.modulecontrol.args.modulecopy.args.movers.args = MC:CreateMoversConfigGroup()

E.Options.args.modulecontrol.args.modulereset = ACH:Group(L["Module Reset"], nil, 2, nil, nil, nil, nil, nil, function(info) E:CopyTable(E.db[info[#info]], P[info[#info]]) end)
E.Options.args.modulecontrol.args.modulereset.args.header = ACH:Header(L["Module Reset"], 0)
E.Options.args.modulecontrol.args.modulereset.args.intro = ACH:Description(L["This section will help reset specfic settings back to default."], 1)
E.Options.args.modulecontrol.args.modulereset.args.space1 = ACH:Spacer(2)
E.Options.args.modulecontrol.args.modulereset.args.general = ACH:Execute(L["General"], nil, 3, nil, nil, L["Are you sure you want to reset General settings?"])
E.Options.args.modulecontrol.args.modulereset.args.actionbar = ACH:Execute(L["ActionBars"], nil, 4, nil, nil, L["Are you sure you want to reset ActionBars settings?"])
E.Options.args.modulecontrol.args.modulereset.args.bags = ACH:Execute(L["Bags"], nil, 5, nil, nil, L["Are you sure you want to reset Bags settings?"])
E.Options.args.modulecontrol.args.modulereset.args.auras = ACH:Execute(L["Auras"], nil, 6, nil, nil, L["Are you sure you want to reset Auras settings?"])
E.Options.args.modulecontrol.args.modulereset.args.chat = ACH:Execute(L["Chat"], nil, 7, nil, nil, L["Are you sure you want to reset Chat settings?"])
E.Options.args.modulecontrol.args.modulereset.args.cooldown = ACH:Execute(L["Cooldown Text"], nil, 8, nil, nil, L["Are you sure you want to reset Cooldown settings?"])
E.Options.args.modulecontrol.args.modulereset.args.databars = ACH:Execute(L["DataBars"], nil, 9, nil, nil, L["Are you sure you want to reset DataBars settings?"])
E.Options.args.modulecontrol.args.modulereset.args.datatexts = ACH:Execute(L["DataTexts"], nil, 10, nil, nil, L["Are you sure you want to reset DataTexts settings?"])
E.Options.args.modulecontrol.args.modulereset.args.nameplates = ACH:Execute(L["NamePlates"], nil, 11, nil, nil, L["Are you sure you want to reset NamePlates settings?"])
E.Options.args.modulecontrol.args.modulereset.args.tooltip = ACH:Execute(L["Tooltip"], nil, 12, nil, nil, L["Are you sure you want to reset Tooltip settings?"])
E.Options.args.modulecontrol.args.modulereset.args.uniframes = ACH:Execute(L["UnitFrames"], nil, 13, function() E:CopyTable(E.db.unitframe, P.unitframe); UF:Update_AllFrames() end, nil, L["Are you sure you want to reset UnitFrames settings?"])
