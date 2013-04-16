local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

--[[
	This file handles functions for the Castbar and Debuff modules of nameplates.
]]

NP.GroupTanks = {};
NP.GroupMembers = {};
NP.CachedAuraDurations = {};
NP.AurasCache = {}

NP.TankClasses = {
	['WARRIOR'] = true,
	['PALADIN'] = true,
	['MONK'] = true,
	['DEATHKNIGHT'] = true,
	['DRUID'] = true,
	--['PRIEST'] = true -- temp
}

NP.RaidTargetReference = {
	["STAR"] = 0x00000001,
	["CIRCLE"] = 0x00000002,
	["DIAMOND"] = 0x00000004,
	["TRIANGLE"] = 0x00000008,
	["MOON"] = 0x00000010,
	["SQUARE"] = 0x00000020,
	["CROSS"] = 0x00000040,
	["SKULL"] = 0x00000080,
}

NP.GUIDIgnoreCast = {};

NP.ComboColors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.65, 0.63, 0.35},
	[4] = {0.65, 0.63, 0.35},
	[5] = {0.33, 0.59, 0.33}
}

NP.RaidIconCoordinate = {
	[0]		= { [0]		= "STAR", [0.25]	= "MOON", },
	[0.25]	= { [0]		= "CIRCLE", [0.25]	= "SQUARE",	},
	[0.5]	= { [0]		= "DIAMOND", [0.25]	= "CROSS", },
	[0.75]	= { [0]		= "TRIANGLE", [0.25]	= "SKULL", }, 
}

NP.TargetOfGroupMembers = {}
NP.ByRaidIcon = {}			-- Raid Icon to GUID 		-- ex.  ByRaidIcon["SKULL"] = GUID
NP.ByName = {}				-- Name to GUID (PVP)
NP.Aura_List = {}	-- Two Dimensional
NP.Aura_Spellid = {}
NP.Aura_Expiration = {}
NP.Aura_Stacks = {}
NP.Aura_Caster = {}
NP.Aura_Duration = {}
NP.Aura_Texture = {}
NP.Aura_Type = {}
NP.Aura_Target = {}

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6
local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2
local AuraList, AuraGUID = {}, {}
NP.MAX_DISPLAYABLE_DEBUFFS = 5;
NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS = 2;

local AURA_TYPE = {
	["Buff"] = 1,
	["Curse"] = 2,
	["Disease"] = 3,
	["Magic"] = 4,
	["Poison"] = 5,
	["Debuff"] = 6,
}

local band = bit.band
local ceil = math.ceil
local twipe = table.wipe

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL",
}

do
	local PolledHideIn
	local Framelist = {}			-- Key = Frame, Value = Expiration Time
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0
	
	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + 1
		-- Cycle through the watchlist, hiding frames which are timed-out
		for frame, expiration in pairs(Framelist) do
			-- If expired...
			if expiration < curTime then frame:Hide(); Framelist[frame] = nil
			-- If active...
			else 
				-- Update the frame
				if frame.Poll then frame.Poll(NP, frame, expiration) end
				framecount = framecount + 1 
			end
		end
		-- If no more frames to watch, unregister the OnUpdate script
		if framecount == 0 then Watcherframe:SetScript("OnUpdate", nil); WatcherframeActive = false end
	end
	
	function PolledHideIn(frame, expiration)
	
		if expiration == 0 then 
			
			frame:Hide()
			Framelist[frame] = nil
		else
			Framelist[frame] = expiration
			frame:Show()
			
			if not WatcherframeActive then 
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end
	
	NP.PolledHideIn = PolledHideIn
end

function NP:CreateAuraIcon(parent)
	local noscalemult = E.mult * UIParent:GetScale()
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetScript('OnHide', function()
		if parent.guid then
			NP:UpdateIconGrid(parent, parent.guid)
		end
	end)
	
	if E.PixelMode then
		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
		
		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)		
	else
		button.bg = button:CreateTexture(nil, "BACKGROUND")
		button.bg:SetTexture(0, 0, 0, 1)
		button.bg:SetAllPoints(button)
		
		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
		
		button.bg2 = button:CreateTexture(nil, "BACKGROUND")
		button.bg2:SetDrawLayer('BACKGROUND', 3)
		button.bg2:SetTexture(0, 0, 0, 1)
		button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)	

		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)		
	end
	
	button.TimeLeft = button:CreateFontString(nil, 'OVERLAY')
	button.TimeLeft:Point('CENTER', 1, 1)
	button.TimeLeft:SetJustifyH('CENTER')	
	button.TimeLeft:SetShadowColor(0, 0, 0, 0)
	
	button.Stacks = button:CreateFontString(nil,"OVERLAY")
	button.Stacks:SetShadowColor(0, 0, 0, 0)
	button.Stacks:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
	
	button.AuraInfo = {	
		Name = "",
		Icon = "",
		Stacks = 0,
		Expiration = 0,
		Type = "",
	}			

	button.Poll = parent.PollFunction
	button:Hide()
	
	return button
end

local TimeColors = {
	[0] = '|cffeeeeee',
	[1] = '|cffeeeeee',
	[2] = '|cffeeeeee',
	[3] = '|cffFFEE00',
	[4] = '|cfffe0000',
}

function NP:UpdateAuraTime(frame, expiration)
	local timeleft = expiration-GetTime()
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4)	
	frame.TimeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], E.TimeFormats[3][2]), timervalue)	
end

function NP:ClearAuraContext(frame)
	if frame.guidcache then 
		AuraGUID[frame.guidcache] = nil 
		frame.unit = nil
	end
	AuraList[frame] = nil
end

function NP:UpdateAuraContext(frame)
	local parent = frame:GetParent()
	local guid = parent.guid
	frame.unit = parent.unit
	frame.guidcache = guid
	
	AuraList[frame] = true
	if guid then AuraGUID[guid] = frame end
	
	if parent.isTarget then UpdateAurasByUnitID("target")
	elseif parent.isMouseover then UpdateAurasByUnitID("mouseover") end
	
	local raidicon, name
	if parent.isMarked then
		raidicon = parent.raidIconType
		if guid and raidicon then ByRaidIcon[raidicon] = guid end
	end
	
	
	local frame = NP:SearchForFrame(guid, raidicon, parent.hp.name:GetText())
	if frame then
		NP:UpdateAuras(frame)
	end
end

function NP.UpdateAuraTarget(frame)
	NP:UpdateIconGrid(frame, UnitGUID("target"))
end

function NP:CheckRaidIcon(frame)
	frame.isMarked = frame.raidicon:IsShown() or false
	
	if frame.isMarked then
		local ux, uy = frame.raidicon:GetTexCoord()
		frame.raidIconType = NP.RaidIconCoordinate[ux][uy]	
	else
		frame.isMarked = nil;
		frame.raidIconType = nil;
	end
end

function NP:SearchNameplateByGUID(guid)
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.guid == guid then
			return frame
		end
	end
end

function NP:SearchNameplateByName(sourceName)
	if not sourceName then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.hp.name:GetText() == SearchFor and frame.hasClass then
			return frame
		end
	end
end

function NP:SearchNameplateByIcon(UnitFlags)
	local UnitIcon
	for iconname, bitmask in pairs(NP.RaidTargetReference) do
		if band(UnitFlags, bitmask) > 0  then
			UnitIcon = iconname
			break
		end
	end	

	return NP:SearchNameplateByIconName(UnitIcon)
end

function NP:SearchNameplateByIconName(raidicon)
	local frame
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.isMarked and (frame.raidIconType == raidIcon) then
			return frame
		end
	end		
end

function NP:SearchForFrame(guid, raidicon, name)
	local frame

	if guid then frame = self:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = self:SearchNameplateByName(name) end
	if (not frame) and raidicon then frame = self:SearchNameplateByIconName(raidicon) end
	
	return frame
end

function NP:SetAuraInstance(guid, spellid, expiration, stacks, caster, duration, texture, auratype, auratarget)
	local filter = false
	if (self.db.trackauras and caster == UnitGUID('player')) then
		filter = true;
	end
	
	local trackFilter = E.global['unitframe']['aurafilters'][self.db.trackfilter]
	if self.db.trackfilter and #self.db.trackfilter > 1 and trackFilter then
		local name = GetSpellInfo(spellid)
		local spellList = trackFilter.spells
		local type = trackFilter.type
		if type == 'Blacklist' then
			if spellList[name] and spellList[name].enable then
				filter = false;
			end
		else
			if spellList[name] and spellList[name].enable then
				filter = true;
			end
		end
	end
	
	if E.global.unitframe.InvalidSpells[spellid] then
		filter = false;
	end

	if filter ~= true then
		return;
	end

	if guid and spellid and caster and texture then
		local aura_id = spellid..(tostring(caster or "UNKNOWN_CASTER"))
		local aura_instance_id = guid..aura_id
		NP.Aura_List[guid] = NP.Aura_List[guid] or {}
		NP.Aura_List[guid][aura_id] = aura_instance_id
		NP.Aura_Spellid[aura_instance_id] = spellid
		NP.Aura_Expiration[aura_instance_id] = expiration
		NP.Aura_Stacks[aura_instance_id] = stacks
		NP.Aura_Caster[aura_instance_id] = caster
		NP.Aura_Duration[aura_instance_id] = duration
		NP.Aura_Texture[aura_instance_id] = texture
		NP.Aura_Type[aura_instance_id] = auratype
		NP.Aura_Target[aura_instance_id] = auratarget
	end
end

function NP:RemoveAuraInstance(guid, spellid)
	if guid and spellid and NP.Aura_List[guid] then
		local aura_instance_id = tostring(guid)..tostring(spellid)..(tostring(caster or "UNKNOWN_CASTER"))
		local aura_id = spellid..(tostring(caster or "UNKNOWN_CASTER"))
		if NP.Aura_List[guid][aura_id] then
			NP.Aura_Spellid[aura_instance_id] = nil
			NP.Aura_Expiration[aura_instance_id] = nil
			NP.Aura_Stacks[aura_instance_id] = nil
			NP.Aura_Caster[aura_instance_id] = nil
			NP.Aura_Duration[aura_instance_id] = nil
			NP.Aura_Texture[aura_instance_id] = nil
			NP.Aura_Type[aura_instance_id] = nil
			NP.Aura_Target[aura_instance_id] = nil
			NP.Aura_List[guid][aura_id] = nil
		end
	end
end

function NP:UpdateAuraByLookup(guid)
 	if guid == UnitGUID("target") then
		NP:UpdateAurasByUnitID("target")
	elseif guid == UnitGUID("mouseover") then
		NP:UpdateAurasByUnitID("mouseover")
	elseif self.TargetOfGroupMembers[guid] then
		local unit = self.TargetOfGroupMembers[guid]
		if unit then
			local unittarget = UnitGUID(unit.."target")
			if guid == unittarget then
				NP:UpdateAurasByUnitID(unittarget)
			end
		end		
	end
end

function NP:UpdateIsBeingTanked(frame)
	local guid = frame.guid
	if not guid then return end
	
	local unit = self.TargetOfGroupMembers[guid]
 	if unit then
		local targetUnit = unit.."target"
		if UnitExists(targetUnit) then
			local isTankGUID = self.GroupTanks[UnitGUID(targetUnit)]
			local isTanking = UnitDetailedThreatSituation(targetUnit, unit)

			if isTankGUID and isTanking then
				frame.isBeingTanked = true
			elseif not isTankGUID and isTanking then
				frame.isBeingTanked = nil
			end
		end
	end
end

function NP:InvalidCastCheck(frame)
	if frame.guid and self.GUIDIgnoreCast[frame.guid] then
		self.GUIDIgnoreCast[frame.guid] = nil;
	end
end

function NP:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, ...)
	local _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellid, spellName, _, auraType, stackCount  = ...

	if event == 'SPELL_AURA_APPLIED' or event == 'SPELL_HEAL' or event == 'SPELL_DAMAGE' or event == 'SPELL_MISS' then
		self.GUIDIgnoreCast[sourceGUID] = spellName;
	end
	
	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		local duration = NP:GetSpellDuration(spellid)
		local texture = GetSpellTexture(spellid)
				
		NP:SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
	elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
		local duration = NP:GetSpellDuration(spellid)
		local texture = GetSpellTexture(spellid)
		NP:SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
	elseif event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then
		NP:RemoveAuraInstance(destGUID, spellid)
	elseif event == "SPELL_CAST_START" then
		local spell, _, icon, _, _, _, castTime, _, _ = GetSpellInfo(spellid)
		if self.GUIDIgnoreCast[sourceGUID] == spell then
			self.GUIDIgnoreCast[sourceGUID] = nil;
			return
		end
	
		local FoundPlate = nil;

		if not (castTime > 0) then return end		
		if band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then 
			if band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
				--	destination plate, by name
				FoundPlate = NP:SearchNameplateByName(sourceName)
			elseif band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then 
				--	destination plate, by GUID
				FoundPlate = NP:SearchNameplateByGUID(sourceGUID)
				if not FoundPlate then 
					FoundPlate = NP:SearchNameplateByIcon(sourceRaidFlags) 
				end
			else 
				return	
			end
		else 
			return 
		end	
		
		if not FoundPlate or not FoundPlate:IsShown() then return; end
		
		if FoundPlate.unit == 'mouseover' then
			NP:UpdateCastInfo('UPDATE_MOUSEOVER_UNIT', true)	
		elseif FoundPlate.unit == 'target' then
			NP:UpdateCastInfo('PLAYER_TARGET_CHANGED')
		else
			FoundPlate.guid = sourceGUID
			local currentTime = GetTime() * 1e3
			NP:StartCastAnimationOnNameplate(FoundPlate, spell, spellid, icon, currentTime, currentTime + castTime, false, false)
		end		
	elseif event == "SPELL_CAST_FAILED" or event == "SPELL_INTERRUPT" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_HEAL" then
		local FoundPlate = nil;
		if sourceGUID == UnitGUID('player') and event == "SPELL_CAST_FAILED" then return; end
		if band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then 
			if band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
				--	destination plate, by name
				FoundPlate = NP:SearchNameplateByName(sourceName)
			elseif band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then 
				--	destination plate, by GUID
				FoundPlate = NP:SearchNameplateByGUID(sourceGUID)
				if not FoundPlate then 
					FoundPlate = NP:SearchNameplateByIcon(sourceRaidFlags) 
				end
			else 
				return	
			end
		else 
			return 
		end	

		if FoundPlate and FoundPlate:IsShown() then 
			FoundPlate.guid = sourceGUID
			NP:StopCastAnimation(FoundPlate)
		end		
	else
		if band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then 
			if band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
				--	destination plate, by name
				FoundPlate = NP:SearchNameplateByName(sourceName)
			elseif band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then 
				--	destination plate, by raid icon
				FoundPlate = NP:SearchNameplateByIcon(sourceRaidFlags) 
			else 
				return	
			end
		else 
			return 
		end	
		
		if FoundPlate and FoundPlate:IsShown() and FoundPlate.unit ~= "target" then 
			FoundPlate.guid = sourceGUID
		end			
	end

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then	
		NP:UpdateAuraByLookup(destGUID)
		local name, raidicon
		-- Cache Unit Name for alternative lookup strategy
		if band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and destName then 
			local rawName = strsplit("-", destName)			-- Strip server name from players
			NP.ByName[rawName] = destGUID
			name = rawName
		end
		-- Cache Raid Icon Data for alternative lookup strategy
		for iconname, bitmask in pairs(NP.RaidTargetReference) do
			if band(destRaidFlags, bitmask) > 0  then
				NP.ByRaidIcon[iconname] = destGUID
				raidicon = iconname
				break
			end
		end

		local frame = self:SearchForFrame(destGUID, raidicon, name)	
		if frame then
			NP:UpdateAuras(frame)
		end				
	end	
end

function NP:PLAYER_REGEN_ENABLED()
	if self.db.combat then
		SetCVar("nameplateShowEnemies", 0)
	end
	
	self:CleanAuraLists()
end

function NP:PLAYER_REGEN_DISABLED()
	if self.db.combat then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function NP:UpdateCastInfo(event, ignoreInt)
	local unit = 'target'
	if event == 'UPDATE_MOUSEOVER_UNIT' then
		unit = 'mouseover'
	end
	
	local GUID = UnitGUID(unit)
	if not GUID then return; end

	if not ignoreInt then
		NP:UpdateAurasByUnitID(unit)
	end
	
	local targetPlate = NP:SearchNameplateByGUID(GUID)
	local channel
	local spell, _, name, icon, start, finish, _, spellid, nonInt = UnitCastingInfo(unit)
	
	if not spell then 
		spell, _, name, icon, start, finish, spellid, nonInt = UnitChannelInfo(unit); 
		channel = true 
	end	
	
	if event == 'UPDATE_MOUSEOVER_UNIT' then
		nonInt = false
	end

	if spell and targetPlate then 
		NP:StartCastAnimationOnNameplate(targetPlate, spell, spellid, icon, start, finish, nonInt, channel) 
	elseif targetPlate then
		NP:StopCastAnimation(targetPlate) 
	end
end

function NP:CleanAuraLists()	
	local currentTime = GetTime()
	for guid, instance_list in pairs(NP.Aura_List) do
		local auracount = 0
		for aura_id, aura_instance_id in pairs(instance_list) do
			local expiration = NP.Aura_Expiration[aura_instance_id]
			if expiration and expiration < currentTime then
				NP.Aura_List[guid][aura_id] = nil
				NP.Aura_Spellid[aura_instance_id] = nil
				NP.Aura_Expiration[aura_instance_id] = nil
				NP.Aura_Stacks[aura_instance_id] = nil
				NP.Aura_Caster[aura_instance_id] = nil
				NP.Aura_Duration[aura_instance_id] = nil
				NP.Aura_Texture[aura_instance_id] = nil
				NP.Aura_Type[aura_instance_id] = nil
				NP.Aura_Target[aura_instance_id] = nil
				auracount = auracount + 1
			end
		end
		if auracount == 0 then
			NP.Aura_List[guid] = nil
		end
	end
end

function NP:AddToRoster(unitId)
	local unitName = UnitName(unitId)

	if unitName then
		local _, unitClass = UnitClass(unitId)
		local guid = UnitGUID(unitId)
		self.GroupMembers[unitName] = unitId
		
		if ((UnitGroupRolesAssigned(unitId) == 'TANK') or GetPartyAssignment("MAINTANK", unitId)) and self.TankClasses[unitClass] then
			self.GroupTanks[guid] = true
		end		
	end
end

function NP:UpdateRoster()
	local groupType, groupSize, unitId, unitName
	wipe(self.GroupMembers)
	wipe(self.GroupTanks)	
	
	local petExists = UnitExists('pet')
	local inGroup = IsInGroup()
	if IsInRaid() then 
		groupType = "raid"
		groupSize = GetNumGroupMembers()
	elseif inGroup then 
		groupType = "party"
		groupSize = GetNumGroupMembers() - 1
	else 
		groupType = "solo"
		groupSize = 1
	end

	-- Cycle through Group
	if groupType then
		for index = 1, groupSize do
			self:AddToRoster(groupType..index)
		end
	end
	
	if petExists then
		self:AddToRoster('pet')
		
		if groupType ~= "raid" then
			self.GroupTanks[UnitGUID('pet')] = true
		end
	end
	
	if groupType == 'party' then
		self:AddToRoster('player')
	end
	
	local _, instanceType = IsInInstance()
	if (inGroup or petExists) and instanceType ~= 'pvp' and instanceType ~= 'arena' then
		NP.displayLooseMobs = true
	else
		NP.displayLooseMobs = nil
	end	
end


function NP:WipeAuraList(guid)
	if guid and self.Aura_List[guid] then
		local unit_aura_list = self.Aura_List[guid]
		for aura_id, aura_instance_id in pairs(unit_aura_list) do
			self.Aura_Spellid[aura_instance_id] = nil
			self.Aura_Expiration[aura_instance_id] = nil
			self.Aura_Stacks[aura_instance_id] = nil
			self.Aura_Caster[aura_instance_id] = nil
			self.Aura_Duration[aura_instance_id] = nil
			self.Aura_Texture[aura_instance_id] = nil
			self.Aura_Type[aura_instance_id] = nil
			self.Aura_Target[aura_instance_id] = nil
			unit_aura_list[aura_id] = nil
		end
	end
end

function NP:GetSpellDuration(spellid)
	if spellid then return NP.CachedAuraDurations[spellid] end
end

function NP:SetSpellDuration(spellid, duration)
	if spellid then NP.CachedAuraDurations[spellid] = duration end
end

function NP:GetAuraList(guid)
	if guid and self.Aura_List[guid] then return self.Aura_List[guid] end
end

function NP:GetAuraInstance(guid, aura_id)
	if guid and aura_id then
		local aura_instance_id = guid..aura_id
		return self.Aura_Spellid[aura_instance_id], self.Aura_Expiration[aura_instance_id], self.Aura_Stacks[aura_instance_id], self.Aura_Caster[aura_instance_id], self.Aura_Duration[aura_instance_id], self.Aura_Texture[aura_instance_id], self.Aura_Type[aura_instance_id], self.Aura_Target[aura_instance_id]
	end
end

function NP:UpdateIcon(frame, texture, expiration, stacks)

	if frame and texture and expiration then
		-- Icon
		frame.Icon:SetTexture(texture)
		
		-- Stacks
		if stacks > 1 then frame.Stacks:SetText(stacks)
		else frame.Stacks:SetText("") end
		
		-- Expiration
		NP:UpdateAuraTime(frame, expiration)
		frame:Show()
		NP.PolledHideIn(frame, expiration)
	else 
		NP.PolledHideIn(frame, 0)
	end
end

function NP:UpdateIconGrid(frame, guid)
	local widget = frame.AuraWidget 
	local AuraIconFrames = widget.AuraIconFrames
	local AurasOnUnit = self:GetAuraList(guid)
	local AuraSlotIndex = 1
	local instanceid
	
	self.AurasCache = wipe(self.AurasCache)
	local aurasCount = 0
	
	-- Cache displayable debuffs
	if AurasOnUnit then
		widget:Show()
		for instanceid in pairs(AurasOnUnit) do
			
			--for i,v in pairs(aura) do aura[i] = nil end
			local aura = {}
			aura.spellid, aura.expiration, aura.stacks, aura.caster, aura.duration, aura.texture, aura.type, aura.target = self:GetAuraInstance(guid, instanceid)
			if tonumber(aura.spellid) then
				aura.name = GetSpellInfo(tonumber(aura.spellid))
				aura.unit = frame.unit
				-- Get Order/Priority
				if aura.expiration > GetTime() then
					aurasCount = aurasCount + 1
					self.AurasCache[aurasCount] = aura
				end
			end
		end
	end
	
	-- Display Auras
	if aurasCount > 0 then 
		for index = 1,  #self.AurasCache do
			local cachedaura = self.AurasCache[index]
			if cachedaura.spellid and cachedaura.expiration then 
				self:UpdateIcon(AuraIconFrames[AuraSlotIndex], cachedaura.texture, cachedaura.expiration, cachedaura.stacks) 
				AuraSlotIndex = AuraSlotIndex + 1
			end
			if AuraSlotIndex > ((frame.isSmallNP and NP.db.smallPlates) and NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS or NP.MAX_DISPLAYABLE_DEBUFFS) then break end
		end
	end
	
	-- Clear Extra Slots
	for AuraSlotIndex = AuraSlotIndex, ((frame.isSmallNP and NP.db.smallPlates) and NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS or NP.MAX_DISPLAYABLE_DEBUFFS) do self:UpdateIcon(AuraIconFrames[AuraSlotIndex]) end
	
	self.AurasCache = wipe(self.AurasCache)
end

function NP:UpdateAuras(frame)
	-- Check for ID
	local guid = frame.guid
	
	if not guid then
		-- Attempt to ID widget via Name or Raid Icon
		if frame.hasClass then 
			guid = NP.ByName[frame.hp.name:GetText()]
		elseif frame.isMarked then 
			guid = NP.ByRaidIcon[frame.raidIconType] 
		end
		
		if guid then 
			frame.guid = guid
		else
			frame.AuraWidget:Hide()
			return
		end
	end
	
	self:UpdateIconGrid(frame, guid)
end

function NP:UpdateAurasByUnitID(unit)
	-- Check the units Auras
	local guid = UnitGUID(unit)
	-- Reset Auras for a guid
	self:WipeAuraList(guid)
	
	if NP.db.filterType == 'DEBUFFS' then
		local index = 1
		local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid, _, isBossDebuff = UnitDebuff(unit, index)
		while name do
			NP:SetSpellDuration(spellid, duration)
			NP:SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE[dispelType or "Debuff"], unitType)
			index = index + 1
			name , _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid, _, isBossDebuff = UnitDebuff(unit, index)
		end	
	else
		local index = 1
		local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid = UnitBuff(unit, index);
		while name do
			NP:SetSpellDuration(spellid, duration)
			NP:SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE[dispelType or "Buff"], unitType)
			index = index + 1
			name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, index);
		end		
	end
	
	local raidicon, name
	if UnitPlayerControlled(unit) then name = UnitName(unit) end
	raidicon = RaidIconIndex[GetRaidTargetIndex(unit) or ""]
	if raidicon then self.ByRaidIcon[raidicon] = guid end
	
	local frame = self:SearchForFrame(guid, raidicon, name)
	if frame then
		NP:UpdateAuras(frame)
	end
end

function NP:UNIT_TARGET(event, unit)	
	self.TargetOfGroupMembers = wipe(self.TargetOfGroupMembers)
	
	for name, unitid in pairs(self.GroupMembers) do
		local targetOf = unitid.."target"
		if UnitExists(targetOf) then
			self.TargetOfGroupMembers[UnitGUID(targetOf)] = targetOf
		end
	end
end

function NP:UPDATE_MOUSEOVER_UNIT()
	self:UpdateCastInfo()

	if UnitExists("mouseover") then
		self.TargetOfGroupMembers[UnitGUID("mouseover")] = "mouseover"
	end
end

function NP:UNIT_AURA(event, unit)
	if unit == "target" then
		self:UpdateAurasByUnitID("target")
	elseif unit == "focus" then
		self:UpdateAurasByUnitID("focus")
	end
end

function NP:StopCastAnimation(frame)
	frame.cb:Hide()	
	frame.cb:SetScript("OnUpdate", nil)
end

function NP:UpdateCastAnimation()
	local duration = GetTime() - self.startTime
	if duration > self.max then
		NP:StopCastAnimation(self:GetParent())
	else 
		self:SetValue(duration)
		self.time:SetFormattedText("%.1f ", (self.endTime - self.startTime) - duration)
	end
end

function NP:UpdateChannelAnimation()
	local duration = self.endTime - GetTime()
	if duration < 0 then
		NP:StopCastAnimation(self:GetParent())
	else 
		self:SetValue(duration) 
		self.time:SetFormattedText("%.1f ", duration)
	end
end

function NP:StartCastAnimationOnNameplate(frame, spellName, spellID, icon, startTime, endTime, notInterruptible, channel)
	if not (tonumber(GetCVar("showVKeyCastbar")) == 1) or not spellName then return; end
	local castbar = frame.cb

	castbar.name:SetText(spellName)
	castbar.icon:SetTexture(icon)
	castbar.endTime = endTime / 1e3
	castbar.startTime = startTime / 1e3
	castbar.max = (castbar.endTime - castbar.startTime)
	castbar:SetMinMaxValues(0, castbar.max)
	
	castbar:Show();
	
	if notInterruptible then 
		castbar.shield:Show()
		castbar:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	else 
		castbar.shield:Hide()
		castbar:SetStatusBarColor(1, 208/255, 0)
	end
	
	if channel then 
		castbar:SetScript("OnUpdate", NP.UpdateChannelAnimation)	
	else 
		castbar:SetScript("OnUpdate", NP.UpdateCastAnimation)	
	end	
end


function NP:CastBar_OnShow()
	local frame = self
	frame:ClearAllPoints()
	frame:SetSize(frame:GetParent().hp:GetWidth(), NP.db.cbheight)
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -8)
	frame:SetStatusBarTexture(E["media"].normTex)
	frame:GetStatusBarTexture():SetHorizTile(true)
	if(frame.shield:IsShown()) then
		frame:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	else
		frame:SetStatusBarColor(1, 208/255, 0)
	end	
	
	while frame:GetEffectiveScale() < 1 do
		frame:SetScale(frame:GetScale() + 0.01)
	end
		
	NP:SetVirtualBorder(frame, unpack(E["media"].bordercolor))
	NP:SetVirtualBackdrop(frame, unpack(E["media"].backdropcolor))	
	
	frame.icon:Size(NP.db.cbheight + frame:GetParent().hp:GetHeight() + 8)
	NP:SetVirtualBorder(frame.icon, unpack(E["media"].bordercolor))
	NP:SetVirtualBackdrop(frame.icon, unpack(E["media"].backdropcolor))		
end

function NP:CastBar_OnValueChanged()
	local channel
	local spell, _, name, icon, start, finish, _, spellid, nonInt = UnitCastingInfo("target")
	
	if not spell then 
		spell, _, name, icon, start, finish, spellid, nonInt = UnitChannelInfo("target"); 
		channel = true 
	end	
	
	if spell then 
		NP:StartCastAnimationOnNameplate(self:GetParent(), spell, spellid, icon, start, finish, nonInt, channel) 
	else 
		NP:StopCastAnimation(self:GetParent()) 
	end
end

function NP:ToggleCPoints()
	if self.db.comboPoints then
		self:RegisterEvent("UNIT_COMBO_POINTS", "UpdateCPoints")
	else
		self:ForEachPlate(NP.HideCPoints)
		self:UnregisterEvent("UNIT_COMBO_POINTS")
	end
end

function NP:HideCPoints(frame)
	if not frame.cpoints[1]:IsShown() then return end
	for i=1, MAX_COMBO_POINTS do
		frame.cpoints[i]:Hide()
	end
end

function NP:UpdateCPoints(frame, isMouseover)
	local unit = "target"
	if isMouseover == true then
		unit = "mouseover"
	end

	if type(frame) ~= "table" then
		frame = self:GetTargetNameplate()
		if frame then
			self:ForEachPlate(self.HideCPoints)
		end
	end
	
	if not frame then return; end

	local cp
	if(UnitHasVehicleUI'player') then
		cp = GetComboPoints('vehicle', unit)
	else
		cp = GetComboPoints('player', unit)
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			frame.cpoints[i]:Show()
			frame.cpoints[i]:SetVertexColor(unpack(NP.ComboColors[cp]))
		else
			frame.cpoints[i]:Hide()
		end
	end
end
