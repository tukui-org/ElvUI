local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local format = format
local min = min
--WoW API / Variables
local GetPetExperience, UnitXP, UnitXPMax = GetPetExperience, UnitXP, UnitXPMax
local UnitLevel = UnitLevel
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local InCombatLockdown = InCombatLockdown

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, LeftChatPanel, CreateFrame

function mod:GetXP(unit)
	if(unit == 'pet') then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function mod:UpdateExperience(event)
	if not mod.db.experience.enable then return end

	local bar = self.expBar
	local hideXP = ((UnitLevel('player') == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] and self.db.experience.hideAtMaxLevel) or IsXPUserDisabled())

	if hideXP or (event == "PLAYER_REGEN_DISABLED" and self.db.experience.hideInCombat) then
		E:DisableMover(self.expBar.mover:GetName())
		bar:Hide()
	elseif not hideXP and (not self.db.experience.hideInCombat or not InCombatLockdown()) then
		E:EnableMover(self.expBar.mover:GetName())
		bar:Show()

		if self.db.experience.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = self:GetXP('player')
		if max <= 0 then max = 1 end
		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		local rested = GetXPExhaustion()
		local text = ''
		local textFormat = self.db.experience.textFormat

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(min(cur + rested, max))

			if textFormat == 'PERCENT' then
				text = format('%d%% R:%d%%', cur / max * 100, rested / max * 100)
			elseif textFormat == 'CURMAX' then
				text = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == 'CURPERC' then
				text = format('%s - %d%% R:%s [%d%%]', E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			elseif textFormat == 'CUR' then
				text = format('%s R:%s', E:ShortValue(cur), E:ShortValue(rested))
			elseif textFormat == 'REM' then
				text = format('%s R:%s', E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURREM' then
				text = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURPERCREM' then
				text = format('%s - %d%% (%s) R:%s', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur), E:ShortValue(rested))
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			if textFormat == 'PERCENT' then
				text = format('%d%%', cur / max * 100)
			elseif textFormat == 'CURMAX' then
				text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max))
			elseif textFormat == 'CURPERC' then
				text = format('%s - %d%%', E:ShortValue(cur), cur / max * 100)
			elseif textFormat == 'CUR' then
				text = format('%s', E:ShortValue(cur))
			elseif textFormat == 'REM' then
				text = format('%s', E:ShortValue(max - cur))
			elseif textFormat == 'CURREM' then
				text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max - cur))
			elseif textFormat == 'CURPERCREM' then
				text = format('%s - %d%% (%s)', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
			end
		end

		bar.text:SetText(text)
	end
end

function mod:ExperienceBar_OnEnter()
	if mod.db.experience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max = mod:GetXP('player')
	local rested = GetXPExhaustion()
	GameTooltip:AddLine(L["Experience"])
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Rested:"], format('+%d (%d%%)', rested, rested / max * 100), 1, 1, 1)
	end

	GameTooltip:Show()
end

function mod:ExperienceBar_OnClick() end

function mod:UpdateExperienceDimensions()
	self.expBar:Width(self.db.experience.width)
	self.expBar:Height(self.db.experience.height)

	self.expBar.text:FontTemplate(LSM:Fetch("font", self.db.experience.font), self.db.experience.textSize, self.db.experience.fontOutline)
	self.expBar.rested:SetOrientation(self.db.experience.orientation)
	self.expBar.statusBar:SetReverseFill(self.db.experience.reverseFill)

	self.expBar.statusBar:SetOrientation(self.db.experience.orientation)
	self.expBar.rested:SetReverseFill(self.db.experience.reverseFill)

	if self.db.experience.orientation == "HORIZONTAL" then
		self.expBar.rested:SetRotatesTexture(false)
		self.expBar.statusBar:SetRotatesTexture(false)
	else
		self.expBar.rested:SetRotatesTexture(true)
		self.expBar.statusBar:SetRotatesTexture(true)
	end

	if self.db.experience.mouseover then
		self.expBar:SetAlpha(0)
	else
		self.expBar:SetAlpha(1)
	end
end

function mod:EnableDisable_ExperienceBar()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()];
	if (UnitLevel('player') ~= maxLevel or not self.db.experience.hideAtMaxLevel) and self.db.experience.enable then
		self:RegisterEvent('PLAYER_XP_UPDATE', 'UpdateExperience')
		self:RegisterEvent("DISABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent("ENABLE_XP_GAIN", 'UpdateExperience')
		self:RegisterEvent('UPDATE_EXHAUSTION', 'UpdateExperience')
		self:UnregisterEvent("UPDATE_EXPANSION_LEVEL")
		self:UpdateExperience()
		E:EnableMover(self.expBar.mover:GetName())
	else
		self:UnregisterEvent('PLAYER_XP_UPDATE')
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:UnregisterEvent('UPDATE_EXHAUSTION')
		self:RegisterEvent("UPDATE_EXPANSION_LEVEL", "EnableDisable_ExperienceBar")
		self.expBar:Hide()
		E:DisableMover(self.expBar.mover:GetName())
	end
end

function mod:LoadExperienceBar()
	self.expBar = self:CreateBar('ElvUI_ExperienceBar', self.ExperienceBar_OnEnter, self.ExperienceBar_OnClick, 'LEFT', LeftChatPanel, 'RIGHT', -E.Border + E.Spacing*3, 0)
	self.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	self.expBar.rested = CreateFrame('StatusBar', nil, self.expBar)
	self.expBar.rested:SetInside()
	self.expBar.rested:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(self.expBar.rested)
	self.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)

	self.expBar.eventFrame = CreateFrame("Frame")
	self.expBar.eventFrame:Hide()
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.expBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateExperience(event) end)

	self:UpdateExperienceDimensions()

	E:CreateMover(self.expBar, "ExperienceBarMover", L["Experience Bar"], nil, nil, nil, nil, nil, 'databars,experience')
	self:EnableDisable_ExperienceBar()
end
