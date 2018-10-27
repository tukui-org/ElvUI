local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local format = format
--WoW API / Variables
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local UnitIsPVP = UnitIsPVP
local UnitLevel = UnitLevel
local InCombatLockdown = InCombatLockdown
local TogglePVPUI = TogglePVPUI
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local HONOR = HONOR

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, RightChatPanel, CreateFrame

function mod:UpdateHonor(event, unit)
	if not mod.db.honor.enable then return end
	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then return end

	local bar = self.honorBar
	local showHonor = true

	if (self.db.honor.hideInCombat and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown())) then
		showHonor = false
	elseif (self.db.honor.hideOutsidePvP and not UnitIsPVP("player")) then
		showHonor = false
	elseif (self.db.honor.hideBelowMaxLevel and UnitLevel("player") < MAX_PLAYER_LEVEL) then
		showHonor = false
	end

	if not showHonor then
		bar:Hide()
	else
		bar:Show()

		local current = UnitHonor("player");
		local max = UnitHonorMax("player");

		--Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if max == 0 then max = 1 end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(current)

		if self.db.honor.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local textFormat = self.db.honor.textFormat

		if textFormat == 'PERCENT' then
			text = format('%d%%', current / max * 100)
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(current), E:ShortValue(max))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %d%%', E:ShortValue(current), current / max * 100)
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(current))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(max-current))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(current), E:ShortValue(max-current))
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %d%% (%s)', E:ShortValue(current), current / max * 100, E:ShortValue(max - current))
		end

		bar.text:SetText(text)
	end
end

function mod:HonorBar_OnEnter()
	if mod.db.honor.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local current = UnitHonor("player");
	local max = UnitHonorMax("player");
	local level = UnitHonorLevel("player");

	GameTooltip:AddLine(HONOR)

	GameTooltip:AddDoubleLine(L["Current Level:"], level, 1, 1, 1)
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%d%%)', current, max, current/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)

	GameTooltip:Show()
end

function mod:HonorBar_OnClick()
	TogglePVPUI()
end

function mod:UpdateHonorDimensions()
	self.honorBar:Width(self.db.honor.width)
	self.honorBar:Height(self.db.honor.height)
	self.honorBar.statusBar:SetOrientation(self.db.honor.orientation)
	self.honorBar.statusBar:SetReverseFill(self.db.honor.reverseFill)
	self.honorBar.text:FontTemplate(LSM:Fetch("font", self.db.honor.font), self.db.honor.textSize, self.db.honor.fontOutline)

	if self.db.honor.orientation == "HORIZONTAL" then
		self.honorBar.statusBar:SetRotatesTexture(false)
	else
		self.honorBar.statusBar:SetRotatesTexture(true)
	end

	if self.db.honor.mouseover then
		self.honorBar:SetAlpha(0)
	else
		self.honorBar:SetAlpha(1)
	end
end

function mod:EnableDisable_HonorBar()
	if self.db.honor.enable then
		self:RegisterEvent("HONOR_XP_UPDATE", "UpdateHonor")
		self:UpdateHonor()
		E:EnableMover(self.honorBar.mover:GetName())
	else
		self:UnregisterEvent("HONOR_XP_UPDATE")
		self.honorBar:Hide()
		E:DisableMover(self.honorBar.mover:GetName())
	end
end

function mod:LoadHonorBar()
	self.honorBar = self:CreateBar('ElvUI_HonorBar', self.HonorBar_OnEnter, self.HonorBar_OnClick, 'RIGHT', RightChatPanel, 'LEFT', E.Border - E.Spacing*3, 0)
	self.honorBar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
	self.honorBar.statusBar:SetMinMaxValues(0, 325)

	self.honorBar.eventFrame = CreateFrame("Frame")
	self.honorBar.eventFrame:Hide()
	self.honorBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.honorBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.honorBar.eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self.honorBar.eventFrame:SetScript("OnEvent", function(self, event, unit) mod:UpdateHonor(event, unit) end)

	self:UpdateHonorDimensions()
	E:CreateMover(self.honorBar, "HonorBarMover", L["Honor Bar"], nil, nil, nil, nil, nil, 'databars,honor')

	self:EnableDisable_HonorBar()
end
