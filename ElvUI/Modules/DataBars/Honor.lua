local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');

--Cache global variables
--Lua functions
local _G = _G
local format = format

--WoW API / Variables
local UnitHonor, UnitHonorMax, UnitHonorLevel, GetMaxPlayerHonorLevel, CanPrestige = UnitHonor, UnitHonorMax, UnitHonorLevel, GetMaxPlayerHonorLevel, CanPrestige
local UnitLevel = UnitLevel

local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local PVP_HONOR_PRESTIGE_AVAILABLE = PVP_HONOR_PRESTIGE_AVAILABLE
local HONOR = HONOR
local MAX_HONOR_LEVEL = MAX_HONOR_LEVEL
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip

function mod:UpdateHonor(event, unit)
	if event == "HONOR_PRESTIGE_UPDATE"  and unit ~= "player" then return end
	local bar = self.honorBar
	local showHonor = UnitLevel("player") >= MAX_PLAYER_LEVEL
	if not showHonor then
		bar:Hide()
	else
		bar:Show()

		local current = UnitHonor("player");
		local max = UnitHonorMax("player");
		local level = UnitHonorLevel("player");
        local levelmax = GetMaxPlayerHonorLevel();

		
        if (level == levelmax) then
			-- Force the bar to full for the max level
			bar.statusBar:SetMinMaxValues(0, 1)
			bar.statusBar:SetValue(1)
		else
			bar.statusBar:SetMinMaxValues(0, max)
			bar.statusBar:SetValue(current)
		end

		if self.db.honor.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local textFormat = self.db.honor.textFormat

		if textFormat == 'PERCENT' then
			if (CanPrestige()) then
				text = PVP_HONOR_PRESTIGE_AVAILABLE
			elseif (level == levelmax) then
				text = MAX_HONOR_LEVEL
			else
				text = format('%d%%', current / max * 100)
			end
		elseif textFormat == 'CURMAX' then
			if (CanPrestige()) then
				text = PVP_HONOR_PRESTIGE_AVAILABLE
			elseif (level == levelmax) then
				text = MAX_HONOR_LEVEL
			else		
				text = format('%s - %s', E:ShortValue(current), E:ShortValue(max))
			end
		elseif textFormat == 'CURPERC' then
			if (CanPrestige()) then
				text = PVP_HONOR_PRESTIGE_AVAILABLE
			elseif (level == levelmax) then
				text = MAX_HONOR_LEVEL
			else
				text = format('%s - %d%%', E:ShortValue(current), current / max * 100)
			end
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
	local levelmax = GetMaxPlayerHonorLevel();

	GameTooltip:AddLine(HONOR)

	GameTooltip:AddDoubleLine(L["Current Level:"], level, 1, 1, 1)
	GameTooltip:AddLine(' ')

	if (CanPrestige()) then
		GameTooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE);
	elseif (level == levelmax) then
		GameTooltip:AddLine(MAX_HONOR_LEVEL);
	else
		GameTooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%d%%)', current, max, current/max * 100), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)
	end
	GameTooltip:Show()
end

function mod:UpdateHonorDimensions()
	self.honorBar:Width(self.db.honor.width)
	self.honorBar:Height(self.db.honor.height)
	self.honorBar.statusBar:SetOrientation(self.db.honor.orientation)
	self.honorBar.statusBar:SetReverseFill(self.db.honor.reverseFill)

	if self.db.honor.mouseover then
		self.honorBar:SetAlpha(0)
	else
		self.honorBar:SetAlpha(1)
	end		
end

function mod:EnableDisable_HonorBar()
	if self.db.honor.enable then
		self:RegisterEvent("HONOR_XP_UPDATE", "UpdateHonor")
		self:RegisterEvent("HONOR_PRESTIGE_UPDATE", "UpdateHonor")
		self:UpdateHonor()
		E:EnableMover(self.honorBar.mover:GetName())
	else
		self:UnregisterEvent("HONOR_XP_UPDATE")
		self.honorBar:Hide()
		E:DisableMover(self.honorBar.mover:GetName())
	end
end

function mod:LoadHonorBar()
	self.honorBar = self:CreateBar('ElvUI_HonorBar', self.HonorBar_OnEnter, 'RIGHT', RightChatPanel, 'LEFT', E.Border - E.Spacing*3, 0)
	self.honorBar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
	self.honorBar.statusBar:SetMinMaxValues(0, 325)

	self:UpdateHonorDimensions()
	E:CreateMover(self.honorBar, "HonorBarMover", L["Honor Bar"])

	self:EnableDisable_HonorBar()
end