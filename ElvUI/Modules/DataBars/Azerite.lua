local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
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
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local HasArtifactEquipped = HasArtifactEquipped
local SocketInventoryItem = SocketInventoryItem
local UIParentLoadAddOn = UIParentLoadAddOn
local ToggleFrame = ToggleFrame
local Item = Item

function DB:UpdateAzerite(event, unit)
	if not DB.db.azerite.enable then return end

	if event == 'UNIT_INVENTORY_CHANGED' and unit ~= 'player' then
		return
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		DB.azeriteBar.eventFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end

	local bar = DB.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if not azeriteItemLocation or (DB.db.azerite.hideAtMaxLevel and C_AzeriteItem_IsAzeriteItemAtMaxLevel())
	or (DB.db.azerite.hideInCombat and (event == 'PLAYER_REGEN_DISABLED' or InCombatLockdown())) or (DB.db.azerite.hideBelowMaxLevel and E.mylevel < MAX_PLAYER_LEVEL) then
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
	else
		E:EnableMover(bar.mover:GetName())
		bar:Show()

		if DB.db.azerite.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

		local textFormat = DB.db.azerite.textFormat
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

	function DB:AzeriteBar_OnEnter()
		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		if azeriteItemLocation then
			if DB.db.azerite.mouseover then
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

function DB:AzeriteBar_OnClick()
	if InCombatLockdown() then return end

	if HasArtifactEquipped() and not C_ArtifactUI_IsEquippedArtifactDisabled() then
		SocketInventoryItem(_G.INVSLOT_MAINHAND)
	elseif C_AzeriteItem_FindActiveAzeriteItem() then
		UIParentLoadAddOn('Blizzard_AzeriteEssenceUI')
		ToggleFrame(_G.AzeriteEssenceUI)
	end
end

function DB:UpdateAzeriteDimensions()
	DB.azeriteBar:SetWidth(DB.db.azerite.width)
	DB.azeriteBar:SetHeight(DB.db.azerite.height)
	DB.azeriteBar.statusBar:SetOrientation(DB.db.azerite.orientation)
	DB.azeriteBar.statusBar:SetReverseFill(DB.db.azerite.reverseFill)

	if DB.db.azerite.orientation == 'HORIZONTAL' then
		DB.azeriteBar.statusBar:SetRotatesTexture(false)
	else
		DB.azeriteBar.statusBar:SetRotatesTexture(true)
	end

	DB.azeriteBar.text:FontTemplate(LSM:Fetch('font', DB.db.azerite.font), DB.db.azerite.textSize, DB.db.azerite.fontOutline)
	if DB.db.azerite.mouseover then
		DB.azeriteBar:SetAlpha(0)
	else
		DB.azeriteBar:SetAlpha(1)
	end
end

function DB:EnableDisable_AzeriteBar()
	if DB.db.azerite.enable then
		DB:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED', 'UpdateAzerite')
		DB:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateAzerite')

		DB:UpdateAzerite()
		E:EnableMover(DB.azeriteBar.mover:GetName())
	else
		DB:UnregisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED')
		DB:UnregisterEvent('UNIT_INVENTORY_CHANGED')

		DB.azeriteBar:Hide()
		E:DisableMover(DB.azeriteBar.mover:GetName())
	end
end

function DB:LoadAzeriteBar()
	DB.azeriteBar = DB:CreateBar('ElvUI_AzeriteBar', DB.AzeriteBar_OnEnter, DB.AzeriteBar_OnClick, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -245)
	DB.azeriteBar.statusBar:SetStatusBarColor(.901, .8, .601)
	DB.azeriteBar.statusBar:SetMinMaxValues(0, 325)
	DB.azeriteBar.statusBar:SetFrameLevel(DB.azeriteBar:GetFrameLevel() + 2)

	DB.azeriteBar.eventFrame = CreateFrame('Frame')
	DB.azeriteBar.eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	DB.azeriteBar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	DB.azeriteBar.eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
	DB.azeriteBar.eventFrame:SetScript('OnEvent', DB.UpdateAzerite)
	DB.azeriteBar.eventFrame:Hide()

	DB:UpdateAzeriteDimensions()
	E:CreateMover(DB.azeriteBar, 'AzeriteBarMover', L["Azerite Bar"], nil, nil, nil, nil, nil, 'databars,azerite')
	DB:EnableDisable_AzeriteBar()
end
