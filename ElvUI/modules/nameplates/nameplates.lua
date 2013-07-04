local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")


--TODO:
--[[
	- Performance Tweaks
	- Cleanup Auras Code
	- Raid Icon aura check appears faulty
	- Assure all variables are voided out on nameplate hide
	- Rewrite configuration GUI
	- Add health text
	- Add health threshold coloring via glow texture.
]]

local numChildren = -1
local twipe = table.wipe
local band = bit.band

NP.NumTransparentPlates = 0
NP.CreatedPlates = {};
NP.Healers = {};

NP.ByRaidIcon = {}			-- Raid Icon to GUID 		-- ex.  ByRaidIcon["SKULL"] = GUID
NP.ByName = {}				-- Name to GUID (PVP)
NP.AuraList = {}	-- Two Dimensional
NP.AuraSpellID = {}
NP.AuraExpiration = {}
NP.AuraStacks = {}
NP.AuraCaster = {}
NP.AuraDuration = {}
NP.AuraTexture = {}
NP.AuraType = {}
NP.AuraTarget = {}
NP.CachedAuraDurations = {}
NP.AurasCache = {}

NP.HealerSpecs = {
	[L['Restoration']] = true,
	[L['Holy']] = true,
	[L['Discipline']] = true,
	[L['Mistweaver']] = true,
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

NP.RaidIconCoordinate = {
	[0]		= { [0]		= "STAR", [0.25]	= "MOON", },
	[0.25]	= { [0]		= "CIRCLE", [0.25]	= "SQUARE",	},
	[0.5]	= { [0]		= "DIAMOND", [0.25]	= "CROSS", },
	[0.75]	= { [0]		= "TRIANGLE", [0.25]	= "SKULL", }, 
}

NP.MAX_DISPLAYABLE_DEBUFFS = 5;
NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS = 2;

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6
local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2
local AuraList, AuraGUID = {}, {}
local AURA_TYPE = {
	["Buff"] = 1,
	["Curse"] = 2,
	["Disease"] = 3,
	["Magic"] = 4,
	["Poison"] = 5,
	["Debuff"] = 6,
}
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
local TimeColors = {
	[0] = '|cffeeeeee',
	[1] = '|cffeeeeee',
	[2] = '|cffeeeeee',
	[3] = '|cffFFEE00',
	[4] = '|cfffe0000',
}

function NP:OnUpdate(elapsed)
	NP.PlateParent:Hide()
	local count = WorldFrame:GetNumChildren()
	if(count ~= numChildren) then
		numChildren = count
		NP:ScanFrames(WorldFrame:GetChildren())
	end

	for blizzPlate, plate in pairs(NP.CreatedPlates) do
		plate:Hide()
		if blizzPlate:IsShown() then
			plate:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", blizzPlate:GetCenter())
			plate:Show()
		end
	end

	if(self.elapsed and self.elapsed > 0.2) then
		NP.NumTransparentPlates = 0
		NP:ForEachPlate('SetAlpha')
		NP:ForEachPlate('SetUnitInfo')
		NP:ForEachPlate('ColorizeAndScale')
		NP:ForEachPlate('SetLevel')
		NP:ForEachPlate('CheckFilter')

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end	

	NP.PlateParent:Show()
end

function NP:CheckFilter()
	local myPlate = NP.CreatedPlates[self]
	local name = self.name:GetText()
	if NP.Healers[name] then
		myPlate.healerIcon:Show()
	else
		myPlate.healerIcon:Hide()
	end
end

function NP:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
		if name then
			name = name:match("(.+)%-.+") or name
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil;
			end
		end
	end
end

function NP:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then return end
	
	for i=1, 5 do
		local name = UnitName(format('arena%d', i))
		if name and name ~= UNKNOWN then
			local s = GetArenaOpponentSpec(i)
			local _, talentSpec = nil, UNKNOWN
			if s and s > 0 then
				_, talentSpec = GetSpecializationInfoByID(s)
			end
			
			if talentSpec and talentSpec ~= UNKNOWN and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			end
		end
	end
end

function NP:SetLevel()
	local region = select(4, self:GetRegions())
	if region and region:GetObjectType() == 'FontString' then
		self.level = region
	end

	local myPlate = NP.CreatedPlates[self]

	if self.level:IsShown() then
		if NP.db.level.enable then
			local level, elite, boss, mylevel = self.level:GetObjectType() == 'FontString' and tonumber(self.level:GetText()) or nil, self.eliteIcon:IsShown(), self.bossIcon:IsShown(), UnitLevel("player")
			if boss then
				myPlate.level:SetText("??")
				myPlate.level:SetTextColor(0.8, 0.05, 0)
				myPlate.level:Show()
			elseif level then
				myPlate.level:SetText(level..(elite and "+" or ""))
				myPlate.level:SetTextColor(self.level:GetTextColor())
				myPlate.level:Show()
			end
		else
			myPlate.level:Hide()
			myPlate.level:SetText(nil)
		end
	elseif self.bossIcon:IsShown() and NP.db.level.enable and myPlate.level:GetText() ~= '??' then
		myPlate.level:SetText("??")
		myPlate.level:SetTextColor(0.8, 0.05, 0)
		myPlate.level:Show()
	end
end

function NP:GetReaction(frame)
	local r, g, b = NP:RoundColors(frame.healthBar:GetStatusBarColor())

	for class, _ in pairs(RAID_CLASS_COLORS) do
		local bb = b
		if class == 'MONK' then
			bb = bb - 0.01
		end
		
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == bb then
			return class
		end
	end

	if (r + b + b) > 2 then
		return 'TAPPED_NPC'
	elseif g + b == 0 then
		return 'HOSTILE_NPC'
	elseif r + b == 0 then
		return 'FRIENDLY_NPC'
	elseif r + g > 1.95 then
		return 'NEUTRAL_NPC'
	elseif r + g == 0 then
		return 'FRIENDLY_PLAYER'
	else
		return 'HOSTILE_PLAYER'
	end
end

function NP:GetThreatReaction(frame)
	if frame.threat:IsShown() then
		local r, g, b = frame.threat:GetVertexColor()
		if g + b == 0 then
			return 'FULL_THREAT'
		else
			if self.threatReaction == 'FULL_THREAT' then
				return 'GAINING_THREAT'
			else
				return 'LOSING_THREAT'
			end
		end
	else
		return 'NO_THREAT'
	end
end

local color, scale
function NP:ColorizeAndScale()
	local myPlate = NP.CreatedPlates[self]
	local unitType = NP:GetReaction(self)
	
	self.unitType = unitType
	if RAID_CLASS_COLORS[unitType] then
		color = RAID_CLASS_COLORS[unitType]
	elseif unitType == "TAPPED_NPC" then
		color = NP.db.reactions.tapped
	elseif unitType == "HOSTILE_NPC" then
		local classRole = E.Role
		local threatReaction = NP:GetThreatReaction(self)
		if threatReaction == 'FULL_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.goodColor
			else
				color = NP.db.threat.badColor
			end
		elseif threatReaction == 'GAINING_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.goodTransitionColor
			else
				color = NP.db.threat.badTransitionColor
			end
		elseif threatReaction == 'LOSING_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.badTransitionColor
			else
				color = NP.db.threat.goodTransitionColor
			end
		elseif InCombatLockdown() then
			if classRole == 'Tank' then
				color = NP.db.threat.badColor
			else
				color = NP.db.threat.goodColor
			end
		else
			color = NP.db.reactions.enemy
		end

		self.threatReaction = threatReaction
	elseif unitType == "NEUTRAL_NPC" then
		color = NP.db.reactions.neutral
	elseif unitType == "FRIENDLY_NPC" then
		color = NP.db.reactions.friendlyNPC
	elseif unitType == "FRIENDLY_PLAYER" then
		color = NP.db.reactions.friendlyPlayer
	else
		color = NP.db.reactions.enemy
	end

	myPlate.healthBar:SetStatusBarColor(color.r, color.g, color.b)
end

function NP:SetAlpha()
	local myPlate = NP.CreatedPlates[self]
	if self:GetAlpha() < 1 then
		myPlate:SetAlpha(NP.db.nonTargetAlpha)
		NP.NumTransparentPlates = NP.NumTransparentPlates + 1
	else
		myPlate:SetAlpha(1)
	end
end

function NP:SetUnitInfo()
	local myPlate = NP.CreatedPlates[self]

	if self:GetAlpha() == 1 and UnitExists("target") and UnitName("target") == self.name:GetText() and NP.NumTransparentPlates > 0 then
		self.guid = UnitGUID("target")
		self.unit = "target"
		NP:UpdateAurasByUnitID("target")
		myPlate:SetFrameLevel(2)
		myPlate.overlay:Hide()
	elseif self.highlight:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == self.name:GetText() then
		self.guid = UnitGUID("mouseover")
		self.unit = "mouseover"
		myPlate:SetFrameLevel(1)
		NP:UpdateAurasByUnitID("mouseover")
		myPlate.overlay:Show()
	else
		self.unit = nil
		myPlate:SetFrameLevel(0)
		myPlate.overlay:Hide()
	end	

	myPlate.healthBar.text:SetText(self.guid)
end

function NP:PLAYER_ENTERING_WORLD()
	twipe(self.Healers)
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' and self.db.markHealers then
		self.CheckHealerTimer = self:ScheduleRepeatingTimer("CheckBGHealers", 3)
		self:CheckBGHealers()
	elseif inInstance and instanceType == 'arena' and self.db.markHealers then
		self:RegisterEvent('UNIT_NAME_UPDATE', 'CheckArenaHealers')
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", 'CheckArenaHealers');
		self:CheckArenaHealers()	
	else
		self:UnregisterEvent('UNIT_NAME_UPDATE')
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		if self.CheckHealerTimer then
			self:CancelTimer(self.CheckHealerTimer)
			self.CheckHealerTimer = nil;
		end
	end
end



function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP

	self.PlateParent = CreateFrame("Frame", nil, WorldFrame)
	self.PlateParent:SetFrameStrata("BACKGROUND")
	self.PlateParent:SetFrameLevel(0)	
	WorldFrame:HookScript('OnUpdate', NP.OnUpdate)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")
end

function NP:UpdateAllPlates()
	if E.private["nameplate"].enable ~= true then return end
	NP:ForEachPlate("UpdateSettings")
end

function NP:ForEachPlate(functionToRun, ...)
	for blizzPlate, _ in pairs(self.CreatedPlates) do
		if blizzPlate and blizzPlate:IsShown() then
			self[functionToRun](blizzPlate, ...)
		end
	end
end

function NP:RoundColors(r, g, b)	
	return floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
end


function NP:OnShow()
	local objectType
	for object in pairs(self.queue) do		
		objectType = object:GetObjectType()  
		if objectType == "Texture" then
			object.OldTexture = object:GetTexture()
			object:SetTexture("")
			object:SetTexCoord(0, 0, 0, 0)
		elseif objectType == 'FontString' then
			object:SetWidth(0.001)
		elseif objectType == 'StatusBar' then
			object:SetStatusBarTexture("")
		else
			object:Hide()
		end
	end
end

function NP:OnHide()
	self.threatReaction = nil
	self.unitType = nil
	self.guid = nil
	self.unit = nil
	self.raidIconType = nil

	--TODO: Hide All Auras
end

function NP:HealthBar_OnValueChanged(value)
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.healthBar:SetMinMaxValues(self:GetMinMaxValues())
	myPlate.healthBar:SetValue(value)

	--TODO: Health Text


	--TODO: Health Threshold
end

local green =  {r = 0, g = 1, b = 0}
function NP:CastBar_OnValueChanged(value)
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	local min, max = self:GetMinMaxValues()
	myPlate.castBar:SetMinMaxValues(min, max)
	myPlate.castBar:SetValue(value)
	myPlate.castBar.time:SetFormattedText("%.1f ", value)

	local color
	if(self.shield:IsShown()) then
		color = NP.db.castBar.noInterrupt
	else
		--Color the castbar green slightly before it ends cast.
		if value > 0 and (value/max) >= 0.98 then
			color = green
		else
			color = NP.db.castBar.color
		end
	end			

	myPlate.castBar:SetStatusBarColor(color.r, color.g, color.b)
end

function NP:CastBar_OnShow()
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.castBar:Show()
end

function NP:CastBar_OnHide()
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.castBar:Hide()
end

function NP:UpdateSettings(frame)
	local myPlate = self.CreatedPlates[frame]
	local font = LSM:Fetch("font", self.db.font)
	local fontSize, fontOutline = self.db.fontSize, self.db.fontOutline

	--Name
	frame.name:FontTemplate(font, fontSize, fontOutline)
	frame.name:ClearAllPoints()
	frame.name:SetPoint(E.InversePoints[self.db.name.attachTo], myPlate.healthBar, self.db.name.attachTo, self.db.name.xOffset, self.db.name.yOffset)
	frame.name:SetJustifyH(self.db.name.justifyH)
	frame.name:SetWidth(self.db.name.width)

	--Level
	myPlate.level:FontTemplate(font, fontSize, fontOutline)
	myPlate.level:ClearAllPoints()
	myPlate.level:SetPoint(E.InversePoints[self.db.level.attachTo], myPlate.healthBar, self.db.level.attachTo, self.db.level.xOffset, self.db.level.yOffset)
	myPlate.level:SetJustifyH(self.db.level.justifyH)

	--HealthBar
	myPlate.healthBar:SetSize(self.db.healthBar.width, self.db.healthBar.height)
	myPlate.healthBar:SetStatusBarTexture(E.media.normTex)

	myPlate.healthBar.text:FontTemplate(font, fontSize, fontOutline)
	myPlate.healthBar.text:ClearAllPoints()
	myPlate.healthBar.text:SetPoint(E.InversePoints[self.db.healthBar.text.attachTo], myPlate.healthBar, self.db.healthBar.text.attachTo, self.db.healthBar.text.xOffset, self.db.healthBar.text.yOffset)
	myPlate.healthBar.text:SetJustifyH(self.db.healthBar.text.justifyH)

	--CastBar
	myPlate.castBar:SetSize(self.db.healthBar.width, self.db.castBar.height)
	myPlate.castBar:SetStatusBarTexture(E.media.normTex)
	
	myPlate.castBar.time:ClearAllPoints()
	myPlate.castBar.time:SetPoint(E.InversePoints[self.db.castBar.time.attachTo], myPlate.castBar, self.db.castBar.time.attachTo, self.db.castBar.time.xOffset, self.db.castBar.time.yOffset)
	myPlate.castBar.time:SetJustifyH(self.db.castBar.time.justifyH)	
	myPlate.castBar.time:FontTemplate(font, fontSize, fontOutline)
	
	frame.castBar.name:ClearAllPoints()
	frame.castBar.name:SetPoint(E.InversePoints[self.db.castBar.name.attachTo], myPlate.castBar, self.db.castBar.name.attachTo, self.db.castBar.name.xOffset, self.db.castBar.name.yOffset)
	frame.castBar.name:SetJustifyH(self.db.castBar.name.justifyH)		
	frame.castBar.name:FontTemplate(font, fontSize, fontOutline)
	frame.castBar.name:SetWidth(self.db.castBar.name.width)

	frame.castBar.icon:Size(self.db.castBar.height + self.db.healthBar.height + 5)	

	--Raid Icon
	frame.raidIcon:ClearAllPoints()
	frame.raidIcon:SetPoint(E.InversePoints[self.db.raidIcon.attachTo], myPlate.healthBar, self.db.raidIcon.attachTo, self.db.raidIcon.xOffset, self.db.raidIcon.yOffset)	

	--Healer Icon (Position From Raid-Icon)
	myPlate.healerIcon:ClearAllPoints()
	myPlate.healerIcon:SetPoint(E.InversePoints[self.db.raidIcon.attachTo], myPlate.healthBar, self.db.raidIcon.attachTo, self.db.raidIcon.xOffset, self.db.raidIcon.yOffset)

	--Auras
	for index = 1, NP.MAX_DISPLAYABLE_DEBUFFS do 
		if frame.AuraWidget.AuraIconFrames and frame.AuraWidget.AuraIconFrames[index] then
			local auraFont = LSM:Fetch("font", self.db.auras.font)
			frame.AuraWidget.AuraIconFrames[index].TimeLeft:FontTemplate(auraFont, self.db.auras.fontSize, self.db.auras.fontOutline)
			frame.AuraWidget.AuraIconFrames[index].Stacks:FontTemplate(auraFont, self.db.auras.fontSize, self.db.auras.fontOutline)
		end
	end	
end

function NP:CreatePlate(frame)
	frame.barFrame, frame.nameFrame = frame:GetChildren()
	frame.healthBar, frame.castBar = frame.barFrame:GetChildren()
	frame.threat, frame.border, frame.highlight, frame.level, frame.bossIcon, frame.raidIcon, frame.eliteIcon = frame.barFrame:GetRegions()
	frame.name = frame.nameFrame:GetRegions()
	frame.healthBar.texture = frame.healthBar:GetRegions()
	frame.castBar.texture, frame.castBar.border, frame.castBar.shield, frame.castBar.icon, frame.castBar.name, frame.castBar.shadow = frame.castBar:GetRegions()

	local myPlate = CreateFrame("Frame", nil, self.PlateParent)
	myPlate:SetSize(frame:GetSize())

	--HealthBar
	myPlate.healthBar = CreateFrame("StatusBar", nil, myPlate)
	myPlate.healthBar:SetPoint('BOTTOM', myPlate, 'BOTTOM', 0, 5)
	myPlate.healthBar:SetFrameStrata("BACKGROUND")
	myPlate.healthBar:SetFrameLevel(0)
	NP:CreateBackdrop(myPlate.healthBar)

	myPlate.healthBar.text = myPlate.healthBar:CreateFontString(nil, 'OVERLAY')

	--CastBar
	myPlate.castBar = CreateFrame("StatusBar", nil, myPlate)
	myPlate.castBar:SetPoint('TOP', myPlate.healthBar, 'BOTTOM', 0, -5)	
	myPlate.castBar:SetFrameStrata("BACKGROUND")
	myPlate.castBar:SetFrameLevel(0)
	NP:CreateBackdrop(myPlate.castBar)
	myPlate.castBar.time = myPlate.castBar:CreateFontString(nil, 'OVERLAY')
	frame.castBar.name:SetParent(myPlate.castBar)
	frame.castBar.icon:SetParent(myPlate.castBar)
	frame.castBar.icon:SetTexCoord(.07, .93, .07, .93)
	frame.castBar.icon:SetDrawLayer("OVERLAY")
	frame.castBar.icon:ClearAllPoints()
	frame.castBar.icon:SetPoint("TOPLEFT", myPlate.healthBar, "TOPRIGHT", 5, 0)
	NP:CreateBackdrop(myPlate.castBar, frame.castBar.icon)

	--Name
	frame.name:SetParent(myPlate)

	--Level
	myPlate.level = myPlate:CreateFontString(nil, 'OVERLAY')

	--Raid Icon
	frame.raidIcon:SetParent(myPlate)

	--Healer Icon
	myPlate.healerIcon = myPlate:CreateTexture(nil, 'ARTWORK')
	myPlate.healerIcon:SetSize(frame.raidIcon:GetSize())
	myPlate.healerIcon:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
	myPlate.healerIcon:Hide()

	--Overlay
	myPlate.overlay = myPlate:CreateTexture(nil, 'OVERLAY')
	myPlate.overlay:SetAllPoints(myPlate.healthBar)
	myPlate.overlay:SetTexture(1, 1, 1, 0.3)
	myPlate.overlay:Hide()

	--Auras
	local f = CreateFrame("Frame", nil, frame)
	f:SetHeight(32); f:Show()
	f:SetPoint('BOTTOMRIGHT', myPlate.healthBar, 'TOPRIGHT', 0, 10)
	f:SetPoint('BOTTOMLEFT', myPlate.healthBar, 'TOPLEFT', 0, 10)
	
	f.PollFunction = NP.UpdateAuraTime
	f.AuraIconFrames = {}
	local AuraIconFrames = f.AuraIconFrames
	for index = 1, NP.MAX_DISPLAYABLE_DEBUFFS do AuraIconFrames[index] = NP:CreateAuraIcon(f);  end
	-- Set Anchors	
	AuraIconFrames[1]:SetPoint("LEFT", f, -1, 0)
	for index = 2, NP.MAX_DISPLAYABLE_DEBUFFS do AuraIconFrames[index]:SetPoint("LEFT", AuraIconFrames[index-1], "RIGHT", 1, 0) end

	f._Hide = f.Hide
	f.Hide = function() NP:ClearAuraContext(f); f:_Hide() end
	f:SetScript("OnHide", function() for index = 1, 4 do NP.PolledHideIn(AuraIconFrames[index], 0) end end)	

	frame.AuraWidget = f	

	--Script Handlers
	frame:HookScript("OnShow", NP.OnShow)
	frame:HookScript("OnHide", NP.OnHide)
	frame.healthBar:HookScript("OnValueChanged", NP.HealthBar_OnValueChanged)
	frame.castBar:HookScript("OnShow", NP.CastBar_OnShow)
	frame.castBar:HookScript("OnHide", NP.CastBar_OnHide)
	frame.castBar:HookScript("OnValueChanged", NP.CastBar_OnValueChanged)
	
	--Hide Elements
	NP:QueueObject(frame, frame.healthBar)
	NP:QueueObject(frame, frame.castBar)
	NP:QueueObject(frame, frame.level)
	NP:QueueObject(frame, frame.threat)
	NP:QueueObject(frame, frame.border)
	NP:QueueObject(frame, frame.castBar.shield)
	NP:QueueObject(frame, frame.castBar.border)
	NP:QueueObject(frame, frame.castBar.shadow)
	NP:QueueObject(frame, frame.bossIcon)
	NP:QueueObject(frame, frame.eliteIcon)

	self.CreatedPlates[frame] = myPlate
	NP:UpdateSettings(frame)
	NP.OnShow(frame)

	if not frame.castBar:IsShown() then
		myPlate.castBar:Hide()
	else
		NP.CastBar_OnShow(frame.castBar)
	end
end

function NP:QueueObject(frame, object)
	frame.queue = frame.queue or {}
	frame.queue[object] = true

	if object.OldTexture then
		object:SetTexture(object.OldTexture)
	end
end

function NP:ScanFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local name = frame:GetName()
		
		if(not NP.CreatedPlates[frame] and (name and name:find("NamePlate%d"))) then
			NP:CreatePlate(frame)
		end
	end
end

function NP:CreateBackdrop(parent, point)
	point = point or parent
	local noscalemult = E.mult * UIParent:GetScale()
	
	if point.bordertop then return end

	
	point.backdrop2 = parent:CreateTexture(nil, "BORDER")
	point.backdrop2:SetDrawLayer("BORDER", -4)
	point.backdrop2:SetAllPoints(point)
	point.backdrop2:SetTexture(unpack(E["media"].backdropfadecolor))		
	
	if E.PixelMode then 
		point.bordertop = parent:CreateTexture(nil, "BORDER")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))	
		point.bordertop:SetDrawLayer("BORDER", 1)
		
		point.borderbottom = parent:CreateTexture(nil, "BORDER")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))	
		point.borderbottom:SetDrawLayer("BORDER", 1)
		
		point.borderleft = parent:CreateTexture(nil, "BORDER")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))	
		point.borderleft:SetDrawLayer("BORDER", 1)
		
		point.borderright = parent:CreateTexture(nil, "BORDER")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))	
		point.borderright:SetDrawLayer("BORDER", 1)			
	else
		point.backdrop = parent:CreateTexture(nil, "BORDER")
		point.backdrop:SetDrawLayer("BORDER", -1)
		point.backdrop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*3, noscalemult*3)
		point.backdrop:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
		point.backdrop:SetTexture(0, 0, 0, 1)

		point.bordertop = parent:CreateTexture(nil, "BORDER")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))	
		point.bordertop:SetDrawLayer("BORDER", -7)
		
		point.borderbottom = parent:CreateTexture(nil, "BORDER")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))	
		point.borderbottom:SetDrawLayer("BORDER", -7)
		
		point.borderleft = parent:CreateTexture(nil, "BORDER")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))	
		point.borderleft:SetDrawLayer("BORDER", -7)
		
		point.borderright = parent:CreateTexture(nil, "BORDER")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))	
		point.borderright:SetDrawLayer("BORDER", -7)
	end
end

---------------------------------------------
--Auras
---------------------------------------------
do
	local PolledHideIn
	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0
	
	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + 0.1

		for frame, expiration in pairs(Framelist) do
			if expiration < curTime then 
				frame:Hide(); 
				Framelist[frame] = nil
			else 
				if frame.Poll then frame.Poll(NP, frame, expiration) end
				framecount = framecount + 1 
			end
		end

		if framecount == 0 then 
			Watcherframe:SetScript("OnUpdate", nil); 
			WatcherframeActive = false 
		end
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

function NP:GetSpellDuration(spellid)
	if spellid then return NP.CachedAuraDurations[spellid] end
end

function NP:SetSpellDuration(spellid, duration)
	if spellid then NP.CachedAuraDurations[spellid] = duration end
end

function NP:CreateAuraIcon(parent)
	local noscalemult = E.mult * UIParent:GetScale()
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(NP.db.auras.width)
	button:SetHeight(NP.db.auras.height)
	button:SetScript('OnHide', function()
		if parent:GetParent().guid then
			NP:UpdateIconGrid(parent:GetParent(), parent:GetParent().guid)
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
		button.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)		
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
		button.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)		
	end
	
	button.TimeLeft = button:CreateFontString(nil, 'OVERLAY')
	button.TimeLeft:Point('TOPLEFT', 2, 2)
	button.TimeLeft:SetJustifyH('CENTER')	
	
	button.Stacks = button:CreateFontString(nil,"OVERLAY")
	button.Stacks:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	
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

function NP:UpdateAuraTime(frame, expiration)
	local timeleft = expiration-GetTime()
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4)
	local format = E.TimeFormats[3][2]
	if timervalue < 4 then
		format = E.TimeFormats[4][2]
	end
	frame.TimeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], format), timervalue)	
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
	
	if parent.unit == 'target' then UpdateAurasByUnitID("target")
	elseif parent.unit == 'mouseover' then UpdateAurasByUnitID("mouseover") end
	
	local raidicon, name
	if parent.raidIcon:IsShown() then
		raidicon = parent.raidIconType
		if guid and raidicon then ByRaidIcon[raidicon] = guid end
	end
	
	
	local frame = NP:SearchForFrame(guid, raidicon, parent.name:GetText())
	if frame then
		NP:UpdateAuras(frame)
	end
end

function NP:RemoveAuraInstance(guid, spellid)
	if guid and spellid and NP.AuraList[guid] then
		local aura_instance_id = tostring(guid)..tostring(spellid)..(tostring(caster or "UNKNOWN_CASTER"))
		local aura_id = spellid..(tostring(caster or "UNKNOWN_CASTER"))
		if NP.AuraList[guid][aura_id] then
			NP.AuraSpellID[aura_instance_id] = nil
			NP.AuraExpiration[aura_instance_id] = nil
			NP.AuraStacks[aura_instance_id] = nil
			NP.AuraCaster[aura_instance_id] = nil
			NP.AuraDuration[aura_instance_id] = nil
			NP.AuraTexture[aura_instance_id] = nil
			NP.AuraType[aura_instance_id] = nil
			NP.AuraTarget[aura_instance_id] = nil
			NP.AuraList[guid][aura_id] = nil
		end
	end
end

function NP:GetAuraList(guid)
	if guid and self.AuraList[guid] then return self.AuraList[guid] end
end

function NP:GetAuraInstance(guid, aura_id)
	if guid and aura_id then
		local aura_instance_id = guid..aura_id
		return self.AuraSpellID[aura_instance_id], self.AuraExpiration[aura_instance_id], self.AuraStacks[aura_instance_id], self.AuraCaster[aura_instance_id], self.AuraDuration[aura_instance_id], self.AuraTexture[aura_instance_id], self.AuraType[aura_instance_id], self.AuraTarget[aura_instance_id]
	end
end

function NP:SetAuraInstance(guid, spellid, expiration, stacks, caster, duration, texture, auratype, auratarget)
	local filter = false
	if (self.db.auras.enable and caster == UnitGUID('player')) then
		filter = true;
	end
	
	local trackFilter = E.global['unitframe']['aurafilters'][self.db.auras.additionalFilter]
	if self.db.auras.additionalFilter and #self.db.auras.additionalFilter > 1 and trackFilter then
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
		NP.AuraList[guid] = NP.AuraList[guid] or {}
		NP.AuraList[guid][aura_id] = aura_instance_id
		NP.AuraSpellID[aura_instance_id] = spellid
		NP.AuraExpiration[aura_instance_id] = expiration
		NP.AuraStacks[aura_instance_id] = stacks
		NP.AuraCaster[aura_instance_id] = caster
		NP.AuraDuration[aura_instance_id] = duration
		NP.AuraTexture[aura_instance_id] = texture
		NP.AuraType[aura_instance_id] = auratype
		NP.AuraTarget[aura_instance_id] = auratarget
	end
end

function NP:UNIT_AURA(event, unit)
	if unit == "target" then
		self:UpdateAurasByUnitID("target")
	elseif unit == "focus" then
		self:UpdateAurasByUnitID("focus")
	end
end

function NP:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, ...)
	local _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellid, spellName, _, auraType, stackCount  = ...

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then	
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
		end	

		--NP:UpdateAuraByLookup(destGUID)
		local name, raidIcon
		-- Cache Unit Name for alternative lookup strategy
		if band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and destName then 
			local rawName = strsplit("-", destName)			-- Strip server name from players
			NP.ByName[rawName] = destGUID
			name = rawName
		end

		-- Cache Raid Icon Data for alternative lookup strategy
		for iconName, bitmask in pairs(NP.RaidTargetReference) do
			if band(destRaidFlags, bitmask) > 0  then
				NP.ByRaidIcon[iconName] = destGUID
				raidIcon = iconName
				break
			end
		end

		local frame = self:SearchForFrame(destGUID, raidIcon, name)
		if frame then
			NP:UpdateAuras(frame)
		end
	end	
end

function NP:WipeAuraList(guid)
	if guid and self.AuraList[guid] then
		local unit_aura_list = self.AuraList[guid]
		for aura_id, aura_instance_id in pairs(unit_aura_list) do
			self.AuraSpellID[aura_instance_id] = nil
			self.AuraExpiration[aura_instance_id] = nil
			self.AuraStacks[aura_instance_id] = nil
			self.AuraCaster[aura_instance_id] = nil
			self.AuraDuration[aura_instance_id] = nil
			self.AuraTexture[aura_instance_id] = nil
			self.AuraType[aura_instance_id] = nil
			self.AuraTarget[aura_instance_id] = nil
			unit_aura_list[aura_id] = nil
		end
	end
end

function NP:UpdateAurasByUnitID(unit)
	-- Check the units Auras
	local guid = UnitGUID(unit)
	-- Reset Auras for a guid
	self:WipeAuraList(guid)

	if NP.db.auras.filterType == 'DEBUFFS' then
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

function NP:UpdateIcon(frame, texture, expiration, stacks)
	if frame and texture and expiration then
		-- Icon
		frame.Icon:SetTexture(texture)
		
		-- Stacks
		if stacks > 1 then 
			frame.Stacks:SetText(stacks)
		else 
			frame.Stacks:SetText("") 
		end
		
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
		if RAID_CLASS_COLORS[frame.unitType] then 
			guid = NP.ByName[frame.name:GetText()]
		elseif frame.raidIcon:IsShown() then 
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

function NP:UpdateAuraByLookup(guid)
 	if guid == UnitGUID("target") then
		NP:UpdateAurasByUnitID("target")
	elseif guid == UnitGUID("mouseover") then
		NP:UpdateAurasByUnitID("mouseover")
	end
end

function NP:CheckRaidIcon(frame)
	if frame.raidIcon:IsShown() then
		local ux, uy = frame.raidIcon:GetTexCoord()
		frame.raidIconType = NP.RaidIconCoordinate[ux][uy]	
	else
		frame.raidIconType = nil;
	end
end

function NP:SearchNameplateByGUID(guid)
	for frame, _ in pairs(NP.CreatedPlates) do
		if frame and frame:IsShown() and frame.guid == guid then
			return frame
		end
	end
end

function NP:SearchNameplateByName(sourceName)
	if not sourceName then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame, _ in pairs(NP.CreatedPlates) do
		if frame and frame:IsShown() and frame.name:GetText() == SearchFor and RAID_CLASS_COLORS[frame.unitType] then
			return frame
		end
	end
end

function NP:SearchNameplateByIconName(raidIcon)
	for frame, _ in pairs(NP.CreatedPlates) do
		NP:CheckRaidIcon(frame)
		if frame and frame:IsShown() and frame.raidIcon:IsShown() and (frame.raidIconType == raidIcon) then
			return frame
		end
	end		
end

function NP:SearchForFrame(guid, raidIcon, name)
	local frame

	if guid then frame = self:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = self:SearchNameplateByName(name) end
	if (not frame) and raidIcon then frame = self:SearchNameplateByIconName(raidIcon) end
	
	return frame
end


E:RegisterModule(NP:GetName())