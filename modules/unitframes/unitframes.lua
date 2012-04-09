local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local UF = E:NewModule('UnitFrames', 'AceTimer-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0");

local _, ns = ...
local ElvUF = ns.oUF
local AceTimer = LibStub:GetLibrary("AceTimer-3.0")
assert(ElvUF, "ElvUI was unable to locate oUF.")

UF['headerstoload'] = {}
UF['unitgroupstoload'] = {}
UF['unitstoload'] = {}

UF['handledheaders'] = {}
UF['handledgroupunits'] = {}
UF['handledunits'] = {}

UF['statusbars'] = {}
UF['fontstrings'] = {}
UF['badHeaderPoints'] = {
	['TOP'] = 'BOTTOM',
	['LEFT'] = 'RIGHT',
	['BOTTOM'] = 'TOP',
	['RIGHT'] = 'LEFT',
}

local find = string.find
local gsub = string.gsub

function UF:Construct_UF(frame, unit)
	frame:RegisterForClicks("AnyUp")
	frame:SetScript('OnEnter', UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UnitFrame_OnLeave)	
	
	frame.menu = self.SpawnMenu
	
	frame:SetFrameLevel(5)
	
	if not self['handledgroupunits'][unit] then
		local stringTitle = E:StringTitle(unit)
		if stringTitle:find('target') then
			stringTitle = gsub(stringTitle, 'target', 'Target')
		end
		self["Construct_"..stringTitle.."Frame"](self, frame, unit)
	else
		UF["Construct_"..E:StringTitle(self['handledgroupunits'][unit]).."Frames"](self, frame, unit)
	end
	
	self:Update_StatusBars()
	self:Update_FontStrings()	
	return frame
end

function UF:GetPositionOffset(position, offset)
	if not offset then offset = 2; end
	local x, y = 0, 0
	if find(position, 'LEFT') then
		x = offset
	elseif find(position, 'RIGHT') then
		x = -offset
	end					
	
	if find(position, 'TOP') then
		y = -offset
	elseif find(position, 'BOTTOM') then
		y = offset
	end
	
	return x, y
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0
	if p1 == "RIGHT" and p2 == "LEFT" then
		x = -3
	elseif p1 == "LEFT" and p2 == "RIGHT" then
		x = 3
	end
	
	if find(p1, 'TOP') and find(p2, 'BOTTOM') then
		y = -1
	elseif find(p1, 'BOTTOM') and find(p2, 'TOP') then
		y = 1
	end
	
	return E:Scale(x), E:Scale(y)
end

local opposites = {
	['DEBUFFS'] = 'BUFFS',
	['BUFFS'] = 'DEBUFFS'
}

function UF:GetAuraAnchorFrame(frame, attachTo, isConflict)
	if isConflict then
		E:Print(string.format(L['%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed.'], E:StringTitle(frame:GetName())))
	end
	
	if isConflict or attachTo == 'FRAME' then
		return frame
	elseif attachTo == 'BUFFS' then
		return frame.Buffs
	elseif attachTo == 'DEBUFFS' then
		return frame.Debuffs
	else
		return frame
	end
end

function UF:GarbageCollect()
	collectgarbage('collect')
	
	--This is a hackish way to disable all created timers except the UpdatePvPText one..
	local timersList = AceTimer.selfs[self]
	if timersList then
		for handle, v in pairs(timersList) do
			if type(v) == "table" and v.callback ~= 'UpdatePvPText' then
				AceTimer.CancelTimer(self, handle, true)
			end
		end
	end
end

function UF:UpdateGroupChildren(header, db)
	if header:IsShown() then --No need to update groups that aren't even shown
		for i=1, header:GetNumChildren() do
			local frame = select(i, header:GetChildren())
			if frame and frame.unit then
				UF["Update_"..E:StringTitle(header.groupName).."Frames"](self, frame, self.db['units'][header.groupName])
			end
		end	
	
		UF:ScheduleTimer('GarbageCollect', 10)
	end
end

function UF:ClearChildPoints(...)
	for i=1, select("#", ...) do
		local child = select(i, ...)
		child:ClearAllPoints()
	end
end

function UF:UpdateColors()
	local db = self.db.colors
	local tapped = db.tapped
	local dc = db.disconnected
	local mana = db.power.MANA
	local rage = db.power.RAGE
	local focus = db.power.FOCUS
	local energy = db.power.ENERGY
	local runic = db.power.RUNIC_POWER
	local good = db.reaction.GOOD
	local bad = db.reaction.BAD
	local neutral = db.reaction.NEUTRAL
	local health = db.health
	
	ElvUF['colors'] = setmetatable({
		tapped = {tapped.r, tapped.g, tapped.b},
		disconnected = {dc.r, dc.g, dc.b},
		health = {health.r, health.g, health.b},
		power = setmetatable({
			["MANA"] = {mana.r, mana.g, mana.b},
			["RAGE"] = {rage.r, rage.g, rage.b},
			["FOCUS"] = {focus.r, focus.g, focus.b},
			["ENERGY"] = {energy.r, energy.g, energy.b},
			["RUNES"] = {0.55, 0.57, 0.61},
			["RUNIC_POWER"] = {runic.r, runic.g, runic.b},
			["AMMOSLOT"] = {0.8, 0.6, 0},
			["FUEL"] = {0, 0.55, 0.5},
			["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
			["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
		}, {__index = ElvUF['colors'].power}),
		runes = setmetatable({
				[1] = {.69,.31,.31},
				[2] = {.33,.59,.33},
				[3] = {.31,.45,.63},
				[4] = {.84,.75,.65},
		}, {__index = ElvUF['colors'].runes}),
		reaction = setmetatable({
			[1] = {bad.r, bad.g, bad.b}, -- Hated
			[2] = {bad.r, bad.g, bad.b}, -- Hostile
			[3] = {bad.r, bad.g, bad.b}, -- Unfriendly
			[4] = {neutral.r, neutral.g, neutral.b}, -- Neutral
			[5] = {good.r, good.g, good.b}, -- Friendly
			[6] = {good.r, good.g, good.b}, -- Honored
			[7] = {good.r, good.g, good.b}, -- Revered
			[8] = {good.r, good.g, good.b}, -- Exalted	
		}, {__index = ElvUF['colors'].reaction}),
		class = setmetatable({
			["DEATHKNIGHT"] = { 196/255,  30/255,  60/255 },
			["DRUID"]       = { 255/255, 125/255,  10/255 },
			["HUNTER"]      = { 171/255, 214/255, 116/255 },
			["MAGE"]        = { 104/255, 205/255, 255/255 },
			["PALADIN"]     = { 245/255, 140/255, 186/255 },
			["PRIEST"]      = { 212/255, 212/255, 212/255 },
			["ROGUE"]       = { 255/255, 243/255,  82/255 },
			["SHAMAN"]      = {  41/255,  79/255, 155/255 },
			["WARLOCK"]     = { 148/255, 130/255, 201/255 },
			["WARRIOR"]     = { 199/255, 156/255, 110/255 },
		}, {__index = ElvUF['colors'].class}),
		smooth = setmetatable({
			1, 0, 0,
			1, 1, 0,
			health.r, health.g, health.b
		}, {__index = ElvUF['colors'].smooth}),
		
	}, {__index = ElvUF['colors']})
end

function UF:Update_StatusBars()
	for statusbar in pairs(UF['statusbars']) do
		if statusbar and statusbar:GetObjectType() == 'StatusBar' then
			statusbar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
		end
	end
end

function UF:Update_FontStrings()
	for font in pairs(UF['fontstrings']) do
		font:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontsize, self.db.fontoutline)
	end
end

function UF:ChangeVisibility(header, visibility)
	if(visibility) then
		local type, list = string.split(' ', visibility, 2)
		if(list and type == 'custom') then
			RegisterAttributeDriver(header, 'state-visibility', list)
		end
	end	
end
local UNITFRAMES = UF
function UF:Update_AllFrames()
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	if E.global["unitframe"].enable ~= true then return; end
	self:UpdateColors()
	for unit in pairs(self['handledunits']) do
		if self.db['units'][unit].enable then
			self[unit]:Enable()
			self[unit]:Update()
		else
			self[unit]:Disable()
		end
	end

	for unit, group in pairs(self['handledgroupunits']) do
		if self.db['units'][group].enable then
			self[unit]:Enable()
			self[unit]:Update()
		else
			self[unit]:Disable()
		end
	end	
	
	self:UpdateAllHeaders()
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	
	self:UpdateColors()
	
	for i=1, numGroup do
		local unit = group..i
		local frameName = E:StringTitle(unit)
		frameName = frameName:gsub('t(arget)', 'T%1')		
		if not self[unit] then
			self['handledgroupunits'][unit] = group;	
			self[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
			self[unit].index = i
		end
		
		local frameName = E:StringTitle(group)
		frameName = frameName:gsub('t(arget)', 'T%1')		
		self[unit].Update = function()
			UF["Update_"..E:StringTitle(frameName).."Frames"](self, self[unit], self.db['units'][group])	
		end

		if self.db['units'][group].enable then
			self[unit]:Enable()
			self[unit].Update()
		else
			self[unit]:Disable()
		end
	end
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	
	self:UpdateColors()
	
	local db = self.db['units'][group]
	if not self[group] then
		ElvUF:RegisterStyle("ElvUF_"..E:StringTitle(group), UF["Construct_"..E:StringTitle(group).."Frames"])
		ElvUF:SetActiveStyle("ElvUF_"..E:StringTitle(group))

		if template then
			self[group] = ElvUF:SpawnHeader("ElvUF_"..E:StringTitle(group), nil, 'raid', 'point', self.db['units'][group].point, 'oUF-initialConfigFunction', ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.width, db.height), 'template', template, 'groupFilter', groupFilter)
		else
			self[group] = ElvUF:SpawnHeader("ElvUF_"..E:StringTitle(group), nil, 'raid', 'point', self.db['units'][group].point, 'oUF-initialConfigFunction', ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.width, db.height), 'groupFilter', groupFilter)
		end
		self['handledheaders'][group] = self[group]
		self[group].groupName = group
	end
	
	self[group].Update = function()
		local db = self.db['units'][group]
		if db.enable ~= true then return end
		UF["Update_"..E:StringTitle(group).."Header"](self, self[group], db)
		
		for i=1, self[group]:GetNumChildren() do
			local child = select(i, self[group]:GetChildren())
			UF["Update_"..E:StringTitle(group).."Frames"](self, child, self.db['units'][group])

			if _G[child:GetName()..'Pet'] then
				UF["Update_"..E:StringTitle(group).."Frames"](self, _G[child:GetName()..'Pet'], self.db['units'][group])
			end
			
			if _G[child:GetName()..'Target'] then
				UF["Update_"..E:StringTitle(group).."Frames"](self, _G[child:GetName()..'Target'], self.db['units'][group])
			end			
		end			
	end	

	if self.db['units'][group].enable then
		self[group].Update()
	else
		self[group]:SetAttribute("showParty", false)
		self[group]:SetAttribute("showRaid", false)
		self[group]:SetAttribute("showSolo", false)
	end
end

function UF:PLAYER_REGEN_ENABLED()
	self:Update_AllFrames()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, 'No unit provided to create or update.')
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	
	self:UpdateColors()

	local frameName = E:StringTitle(unit)
	frameName = frameName:gsub('t(arget)', 'T%1')
	if not self[unit] then
		self[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
		self['handledunits'][unit] = unit
	end

	self[unit].Update = function()
		UF["Update_"..frameName.."Frame"](self, self[unit], self.db['units'][unit])
	end

	if self.db['units'][unit].enable then
		self[unit]:Enable()
		self[unit].Update()
	else
		self[unit]:Disable()
	end
end


function UF:LoadUnits()
	for _, unit in pairs(self['unitstoload']) do
		self:CreateAndUpdateUF(unit)
	end	
	self['unitstoload'] = nil
	
	for group, numGroup in pairs(self['unitgroupstoload']) do
		self:CreateAndUpdateUFGroup(group, numGroup)
	end
	self['unitgroupstoload'] = nil
	
	for group, groupOptions in pairs(self['headerstoload']) do
		local groupFilter, template
		if type(groupOptions) == 'table' then
			groupFilter, template = unpack(groupOptions)
		end

		self:CreateAndUpdateHeaderGroup(group, groupFilter, template)
	end
	self['headerstoload'] = nil
end

function UF:UpdateAllHeaders(event)	
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateAllHeaders')
		return
	end
	
	if event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if ORD then
		ORD:ResetDebuffData()
		ORD:RegisterDebuffs(E.global.unitframe.aurafilters.RaidDebuffs.spells)		
	end	
	
	for _, header in pairs(UF['handledheaders']) do
		header:Update()
	end	
	
	if E.global.unitframe.disableBlizzard then
		ElvUF:DisableBlizzard('party')	
	end
	
	if event == 'PLAYER_ENTERING_WORLD' then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end	
end

function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then 
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function UF:DisableBlizzard(event)
	hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
	CompactRaidFrameManager:HookScript('OnShow', HideRaid)
	CompactRaidFrameContainer:UnregisterAllEvents()
	HideRaid()
end

function UF:ForceShow(frame)
	if not frame.isForced then
		UnregisterUnitWatch(frame)
		RegisterUnitWatch(frame, true)
		
		frame.oldUnit = frame.unit
		frame.unit = 'dummy'
		frame.isForced = true;
	end
	
	frame:Show()
end

function UF:UnforceShow(frame)
	if not frame.isForced then
		return
	end
	frame.isForced = nil
	
	-- Ask the SecureStateDriver to show/hide the frame for us
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)
	
	frame.unit = frame.oldUnit or frame.unit
	
	-- If we're visible force an udpate so everything is properly in a
	-- non-config mode state
	if frame:IsVisible() then
		frame:Update()
	end	
end

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

function ElvUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')

		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	elseif(unit == 'pet') then
		HandleFrame(PetFrame)
	elseif(unit == 'target') then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == 'focus') then
		HandleFrame(FocusFrame)
		HandleFrame(TargetofFocusFrame)
	elseif(unit == 'targettarget') then
		HandleFrame(TargetFrameToT)
	elseif(unit:match'(boss)%d?$' == 'boss') then
		local id = unit:match'boss(%d)'
		if(id) then
			HandleFrame('Boss' .. id .. 'TargetFrame')
		else
			for i=1, 4 do
				HandleFrame(('Boss%dTargetFrame'):format(i))
			end
		end
	elseif(unit:match'(party)%d?$' == 'party') then
		local id = unit:match'party(%d)'
		if(id) then
			HandleFrame('PartyMemberFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('PartyMemberFrame%d'):format(i))
			end
		end
	elseif(unit:match'(arena)%d?$' == 'arena') then
		local id = unit:match'arena(%d)'
		if(id) then
			HandleFrame('ArenaEnemyFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('ArenaEnemyFrame%d'):format(i))
			end
		end
	end
end

function UF:Initialize()	
	self.db = E.db["unitframe"]
	if E.global["unitframe"].enable ~= true then return; end
	E.UnitFrames = UF;
	
	--Database conversion from ElvUI v3.2.2 and below.
	local specToCopy = E.db.unitframe.mainSpec
	if not specToCopy then specToCopy = 'Primary' end
	if specToCopy and E.db.unitframe.layouts and E.db.unitframe.layouts[specToCopy] then
		E:CopyTable(E.db.unitframe.units, E.db.unitframe.layouts[specToCopy])
		E.db.unitframe.layouts = nil;
	end

	
	ElvUF:RegisterStyle('ElvUF', function(frame, unit)
		self:Construct_UF(frame, unit)
	end)
		
	self:LoadUnits()
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateAllHeaders')
	
	if E.global["unitframe"].disableBlizzard then
		self:DisableBlizzard()	

		UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
		UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
		UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
		UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
		UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "VOTE_TO_KICK", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
		UnitPopupMenus["RAID"] = { "WHISPER", "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "SELECT_ROLE", "LOOT_PROMOTE", "RAID_DEMOTE", "VOTE_TO_KICK", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
		UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
		UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
		UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
		UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
		UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }	
		
		if E.myclass == 'HUNTER' then
			UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "CANCEL" };
		end
		
		self:RegisterEvent('RAID_ROSTER_UPDATE', 'DisableBlizzard')
	end
		
	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if not ORD then return end
	ORD.ShowDispelableDebuff = true
	ORD.FilterDispellableDebuff = true
	ORD.MatchBySpellName = true
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db['units'][unit], P['unitframe']['units'][unit]); 
	
	self:Update_AllFrames()
end

local ignoreSettings = {
	['position'] = true
}
function UF:MergeUnitSettings(fromUnit, toUnit)
	local db = self.db['units']
	
	if fromUnit ~= toUnit then
		for option, value in pairs(db[fromUnit]) do
			if type(value) ~= 'table' and not ignoreSettings[option] then
				if db[toUnit][option] ~= nil then
					db[toUnit][option] = value
				end
			elseif not ignoreSettings[option] then
				if type(value) == 'table' then
					for opt, val in pairs(db[fromUnit][option]) do
						if type(val) ~= 'table' and not ignoreSettings[opt] then
							if db[toUnit][option] ~= nil and db[toUnit][option][opt] ~= nil then
								db[toUnit][option][opt] = val
							end				
						elseif not ignoreSettings[o] then
							if type(val) == 'table' then
								for o, v in pairs(db[fromUnit][option][opt]) do
									if not ignoreSettings[o] then
										if db[toUnit][option] ~= nil and db[toUnit][option][opt] ~= nil and db[toUnit][option][opt][o] ~= nil then
											db[toUnit][option][opt][o] = v	
										end
									end
								end		
							end
						end
					end
				end
			end
		end
	else
		E:Print(L['You cannot copy settings from the same unit.'])
	end
	
	self:Update_AllFrames()
end


E:RegisterModule(UF:GetName())