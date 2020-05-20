local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local format = format

local C_ArtifactUI_IsEquippedArtifactDisabled = C_ArtifactUI.IsEquippedArtifactDisabled
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local ARTIFACT_POWER = ARTIFACT_POWER
local Item = Item
local HasArtifactEquipped = HasArtifactEquipped
local SocketInventoryItem = SocketInventoryItem
local UIParentLoadAddOn = UIParentLoadAddOn
local ToggleFrame = ToggleFrame

function mod:UpdateAzerite(event, unit)
	if not mod.db.azerite.enable then return end

	if event == 'UNIT_INVENTORY_CHANGED' and unit ~= 'player' then
		return
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		mod.azeriteBar.eventFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end

	local bar = mod.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if not azeriteItemLocation or (mod.db.azerite.hideAtMaxLevel and C_AzeriteItem_IsAzeriteItemAtMaxLevel())
	or (mod.db.azerite.hideInCombat and (event == 'PLAYER_REGEN_DISABLED' or InCombatLockdown())) or (mod.db.azerite.hideBelowMaxLevel and E.mylevel < MAX_PLAYER_LEVEL) then
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
	else
		E:EnableMover(bar.mover:GetName())
		bar:Show()

		if mod.db.azerite.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

		local textFormat = mod.db.azerite.textFormat
		if textFormat == 'NONE' then
			bar.text:SetText('')
		elseif textFormat == 'PERCENT' then
			bar.text:SetFormattedText('%s%% [%s]', floor(cur / max * 100), currentLevel)
		elseif textFormat == 'CURMAX' then
			bar.text:SetFormattedText('%s - %s [%s]', E:ShortValue(cur), E:ShortValue(max), currentLevel)
		elseif textFormat == 'CURPERC' then
			bar.text:SetFormattedText('%s - %s%% [%s]', E:ShortValue(cur), floor(cur / max * 100), currentLevel)
		elseif textFormat == 'CUR' then
			bar.text:SetFormattedText('%s [%s]', E:ShortValue(cur), currentLevel)
		elseif textFormat == 'REM' then
			bar.text:SetFormattedText('%s [%s]', E:ShortValue(max - cur), currentLevel)
		elseif textFormat == 'CURREM' then
			bar.text:SetFormattedText('%s - %s [%s]', E:ShortValue(cur), E:ShortValue(max - cur), currentLevel)
		elseif textFormat == 'CURPERCREM' then
			bar.text:SetFormattedText('%s - %s%% (%s) [%s]', E:ShortValue(cur), floor(cur / max * 100), E:ShortValue(max - cur), currentLevel)
		else
			bar.text:SetFormattedText('[%s]', currentLevel)
		end
	end
end

do
	local azeriteItem, currentLevel, curXP, maxXP
	local function dataLoadedCancelFunc()
		_G.GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItem:GetItemName()..' ('..currentLevel..')', nil,  nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
		_G.GameTooltip:AddLine(' ')

		_G.GameTooltip:AddDoubleLine(L["AP:"], format(' %d / %d (%d%%)', curXP, maxXP, curXP / maxXP  * 100), 1, 1, 1)
		_G.GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', maxXP - curXP, (maxXP - curXP) / maxXP * 100, 10 * (maxXP - curXP) / maxXP), 1, 1, 1)

		_G.GameTooltip:Show()
	end

	function mod:AzeriteBar_OnEnter()
		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		if azeriteItemLocation then
			if mod.db.azerite.mouseover then
				E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
			end

			_G.GameTooltip:ClearLines()
			_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

			curXP, maxXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
			currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

			azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
			azeriteItem:ContinueWithCancelOnItemLoad(dataLoadedCancelFunc)
		else
			_G.GameTooltip:Hide()
		end
	end
end

function mod:AzeriteBar_OnClick()
	if InCombatLockdown() then return end

	if HasArtifactEquipped() and not C_ArtifactUI_IsEquippedArtifactDisabled() then
		SocketInventoryItem(_G.INVSLOT_MAINHAND)
	elseif C_AzeriteItem_FindActiveAzeriteItem() then
		UIParentLoadAddOn("Blizzard_AzeriteEssenceUI")
		ToggleFrame(_G.AzeriteEssenceUI)
	end
end

function mod:UpdateAzeriteDimensions()
	self.azeriteBar:Width(self.db.azerite.width)
	self.azeriteBar:Height(self.db.azerite.height)
	self.azeriteBar.statusBar:SetOrientation(self.db.azerite.orientation)
	self.azeriteBar.statusBar:SetReverseFill(self.db.azerite.reverseFill)

	if self.db.azerite.orientation == 'HORIZONTAL' then
		self.azeriteBar.statusBar:SetRotatesTexture(false)
	else
		self.azeriteBar.statusBar:SetRotatesTexture(true)
	end

	self.azeriteBar.text:FontTemplate(LSM:Fetch('font', self.db.azerite.font), self.db.azerite.textSize, self.db.azerite.fontOutline)
	if self.db.azerite.mouseover then
		self.azeriteBar:SetAlpha(0)
	else
		self.azeriteBar:SetAlpha(1)
	end
end

function mod:EnableDisable_AzeriteBar()
	if self.db.azerite.enable then
		self:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED', 'UpdateAzerite')
		self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateAzerite')

		self:UpdateAzerite()
		E:EnableMover(self.azeriteBar.mover:GetName())
	else
		self:UnregisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED')
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

	self.azeriteBar.eventFrame = CreateFrame('Frame')
	self.azeriteBar.eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	self.azeriteBar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	self.azeriteBar.eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
	self.azeriteBar.eventFrame:SetScript('OnEvent', mod.UpdateAzerite)
	self.azeriteBar.eventFrame:Hide()

	self:UpdateAzeriteDimensions()
	E:CreateMover(self.azeriteBar, 'AzeriteBarMover', L["Azerite Bar"], nil, nil, nil, nil, nil, 'databars,azerite')
	self:EnableDisable_AzeriteBar()
end
