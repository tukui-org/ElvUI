local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions

--WoW API / Variables
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

function mod:UpdateAzerite(event, unit)
	if not mod.db.azerite.enable then return end

	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	local bar = self.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if not azeriteItemLocation or (event == "PLAYER_REGEN_DISABLED" and self.db.azerite.hideInCombat) then
		bar:Hide()
	elseif azeriteItemLocation and (not self.db.azerite.hideInCombat or not InCombatLockdown()) then
		bar:Show()

		if self.db.azerite.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
		local xpToNextLevel = totalLevelXP - xp

		bar.statusBar:SetMinMaxValues(0, totalLevelXP)
		bar.statusBar:SetValue(xp)

		local textFormat = self.db.azerite.textFormat
		if textFormat == 'PERCENT' then
			text = format('%s%%', floor(xp / xpToNextLevel * 100))
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpToNextLevel))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %s%%', E:ShortValue(xp), floor(xp /xpToNextLevel * 100))
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(totalLevelXP))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(xpToNextLevel - xp))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpToNextLevel - xp))
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %s%% (%s)', E:ShortValue(xp), floor(xp / xpToNextLevel * 100), E:ShortValue(xpToNextLevel - xp))
		end

		bar.text:SetText(text)
	end
end

function mod:AzeriteBar_OnEnter()
	if mod.db.azerite.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem();
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
	local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
	local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
	local xpToNextLevel = totalLevelXP - xp

	itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
		local azeriteItemName = azeriteItem:GetItemName();
		GameTooltip:AddDoubleLine(AZERITE_POWER_TOOLTIP_TITLE:format(currentLevel, xpToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName));
		GameTooltip:Show()
	end)
end

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
		--Possible Events
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
	self.azeriteBar = self:CreateBar('ElvUI_AzeriteBar', self.AzeriteBar_OnEnter, nil, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.azeriteBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.azeriteBar.statusBar:SetMinMaxValues(0, 325)
	self.azeriteBar.statusBar:SetFrameLevel(self.azeriteBar:GetFrameLevel() + 2)

	self:UpdateAzeriteDimensions()
	E:CreateMover(self.azeriteBar, "AzeriteBarMover", L["Azerite Bar"])
	self:EnableDisable_AzeriteBar()
end