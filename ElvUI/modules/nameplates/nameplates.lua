local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

local numChildren = -1
local twipe = table.wipe
NP.CreatedPlates = {};
NP.Healers = {};

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
			
			NP.SetUnitInfo(blizzPlate)
			NP.SetAlpha(blizzPlate)
			NP.ColorizeAndScale(blizzPlate)
			NP.SetLevel(blizzPlate)
			NP.CheckFilter(blizzPlate)

			plate:Show()
		end
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
			elseif not elite and level == mylevel then
				myPlate.level:Hide()
				myPlate.level:SetText(nil)
			elseif level then
				myPlate.level:SetText(level..(elite and "+" or ""))
				myPlate.level:SetTextColor(self.level:GetTextColor())
				myPlate.level:Show()
			end
		else
			myPlate.level:Hide()
			myPlate.level:SetText(nil)
		end
	elseif self.bossIcon:IsShown() and self.db.level.enable and myPlate.level:GetText() ~= '??' then
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
	
	scale = 1
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
	else
		myPlate:SetAlpha(1)
	end
end

function NP:SetUnitInfo()
	local myPlate = NP.CreatedPlates[self]
	if self:GetAlpha() == 1 and UnitExists("target") and UnitName("target") == self.name:GetText() then
		self.guid = UnitGUID("target")
		self.unit = "target"
		myPlate:SetFrameLevel(5)
	elseif self.highlight:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == self.name:GetText() then
		self.guid = UnitGUID("mouseover")
		self.unit = "mouseover"
		myPlate:SetFrameLevel(0)
	else
		self.unit = nil
		myPlate:SetFrameLevel(0)
	end	
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
end

function NP:UpdateAllPlates()
	if E.private["nameplate"].enable ~= true then return end
	for frame, _ in pairs(self.CreatedPlates) do
		self:SkinPlate(frame:GetChildren())
	end
end

--Run a function for all visible nameplates
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
end

function NP:HealthBar_OnValueChanged(value)
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.healthBar:SetMinMaxValues(self:GetMinMaxValues())
	myPlate.healthBar:SetValue(value)
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

	frame:HookScript("OnShow", NP.OnShow)
	frame:HookScript("OnHide", NP.OnHide)
	frame.healthBar:HookScript("OnValueChanged", NP.HealthBar_OnValueChanged)
	frame.castBar:HookScript("OnShow", NP.CastBar_OnShow)
	frame.castBar:HookScript("OnHide", NP.CastBar_OnHide)
	frame.castBar:HookScript("OnValueChanged", NP.CastBar_OnValueChanged)
	

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


E:RegisterModule(NP:GetName())