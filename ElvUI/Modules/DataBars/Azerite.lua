local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars')
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local floor = floor
local format = format
--WoW API / Variables
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local ARTIFACT_POWER = ARTIFACT_POWER
local Item = Item

function mod:UpdateAzerite(event, unit)
	if not mod.db.azerite.enable then return end

	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		self.azeriteBar.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	local bar = self.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if not azeriteItemLocation or (self.db.azerite.hideAtMaxLevel and C_AzeriteItem_IsAzeriteItemAtMaxLevel()) or
		(self.db.azerite.hideInCombat and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown())) then
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
	else
		E:EnableMover(bar.mover:GetName())
		bar:Show()

		if self.db.azerite.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

		local text = ''
		local textFormat = self.db.azerite.textFormat

		if textFormat == 'PERCENT' then
			text = format('%s%% [%s]', floor(cur / max * 100), currentLevel)
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s [%s]', E:ShortValue(cur), E:ShortValue(max), currentLevel)
		elseif textFormat == 'CURPERC' then
			text = format('%s - %s%% [%s]', E:ShortValue(cur), floor(cur / max * 100), currentLevel)
		elseif textFormat == 'CUR' then
			text = format('%s [%s]', E:ShortValue(cur), currentLevel)
		elseif textFormat == 'REM' then
			text = format('%s [%s]', E:ShortValue(max - cur), currentLevel)
		elseif textFormat == 'CURREM' then
			text = format('%s - %s [%s]', E:ShortValue(cur), E:ShortValue(max - cur), currentLevel)
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %s%% (%s) [%s]', E:ShortValue(cur), floor(cur / max * 100), E:ShortValue(max - cur), currentLevel)
		end

		bar.text:SetText(text)
	end
end

function mod:AzeriteBar_OnEnter()
	if mod.db.azerite.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
	local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
	local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

	self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
		local azeriteItemName = azeriteItem:GetItemName()

		_G.GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil,  nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
		_G.GameTooltip:AddLine(' ')

		_G.GameTooltip:AddDoubleLine(L["AP:"], format(' %d / %d (%d%%)', cur, max, cur / max  * 100), 1, 1, 1)
		_G.GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 10 * (max - cur) / max), 1, 1, 1)

		_G.GameTooltip:Show()
	end)
end

function mod:AzeriteBar_OnClick() end

function mod:UpdateAzeriteDimensions()
	self.azeriteBar:Width(self.db.azerite.width)
	self.azeriteBar:Height(self.db.azerite.height)
	self.azeriteBar.statusBar:SetOrientation(self.db.azerite.orientation)
	self.azeriteBar.statusBar:SetReverseFill(self.db.azerite.reverseFill)

	if self.db.azerite.orientation == "HORIZONTAL" then
		self.azeriteBar.statusBar:SetRotatesTexture(false)
	else
		self.azeriteBar.statusBar:SetRotatesTexture(true)
	end

	self.azeriteBar.text:FontTemplate(LSM:Fetch("font", self.db.azerite.font), self.db.azerite.textSize, self.db.azerite.fontOutline)
	if self.db.azerite.mouseover then
		self.azeriteBar:SetAlpha(0)
	else
		self.azeriteBar:SetAlpha(1)
	end
end

function mod:EnableDisable_AzeriteBar()
	if self.db.azerite.enable then
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", 'UpdateAzerite')
		self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateAzerite')

		self:UpdateAzerite()
		E:EnableMover(self.azeriteBar.mover:GetName())
	else
		self:UnregisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')

		self.azeriteBar:Hide()
		E:DisableMover(self.azeriteBar.mover:GetName())
	end
end

function mod:LoadAzeriteBar()
	self.azeriteBar = self:CreateBar('ElvUI_AzeriteBar', self.AzeriteBar_OnEnter, self.AzeriteBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.azeriteBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.azeriteBar.statusBar:SetMinMaxValues(0, 325)
	self.azeriteBar.statusBar:SetFrameLevel(self.azeriteBar:GetFrameLevel() + 2)

	self.azeriteBar.eventFrame = CreateFrame("Frame")
	self.azeriteBar.eventFrame:Hide()
	self.azeriteBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.azeriteBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.azeriteBar.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.azeriteBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateAzerite(event) end)

	self:UpdateAzeriteDimensions()
	E:CreateMover(self.azeriteBar, "AzeriteBarMover", L["Azerite Bar"], nil, nil, nil, nil, nil, 'databars,azerite')
	self:EnableDisable_AzeriteBar()
end
