local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local floor = floor
local format = format

local InCombatLockdown = InCombatLockdown
local HasArtifactEquipped = HasArtifactEquipped
local SocketInventoryItem = SocketInventoryItem
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local UIParentLoadAddOn = UIParentLoadAddOn
local ToggleFrame = ToggleFrame
local Item = Item

local C_ArtifactUI_IsEquippedArtifactDisabled = C_ArtifactUI.IsEquippedArtifactDisabled
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local ARTIFACT_POWER = ARTIFACT_POWER

function DB:AzeriteBar_Update(event, unit)
	if event == 'UNIT_INVENTORY_CHANGED' and unit ~= 'player' then return end

	local bar = DB.StatusBars.Azerite
	DB:SetVisibility(bar)

	if not DB.db.azerite.enable then return end

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	local hidden = not azeriteItemLocation or bar:ShouldHide()

	if not hidden then
		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
		local color = DB.db.colors.azerite

		bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
		bar:SetMinMaxValues(0, max)
		bar:SetValue(cur)

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
		if _G.GameTooltip:IsForbidden() then return end

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

			if not _G.GameTooltip:IsForbidden() then
				_G.GameTooltip:ClearLines()
				_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			end

			curXP, maxXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
			currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

			azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
			azeriteItem:ContinueWithCancelOnItemLoad(dataLoadedCancelFunc)
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

function DB:AzeriteBar_Toggle()
	local bar = DB.StatusBars.Azerite
	bar.db = DB.db.azerite

	DB:SetVisibility(bar)

	if bar.db.enable then
		E:EnableMover(bar.holder.mover:GetName())

		DB:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED', 'AzeriteBar_Update')
		DB:RegisterEvent('UNIT_INVENTORY_CHANGED', 'AzeriteBar_Update')

		DB:AzeriteBar_Update()
	else
		E:DisableMover(bar.holder.mover:GetName())

		DB:UnregisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED')
		DB:UnregisterEvent('UNIT_INVENTORY_CHANGED')
	end
end

function DB:AzeriteBar()
	local Azerite = DB:CreateBar('ElvUI_AzeriteBar', 'Azerite', DB.AzeriteBar_Update, DB.AzeriteBar_OnEnter, DB.AzeriteBar_OnClick, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -245})
	DB:CreateBarBubbles(Azerite)

	Azerite.ShouldHide = function()
		return (DB.db.azerite.hideAtMaxLevel and C_AzeriteItem_IsAzeriteItemAtMaxLevel()) or E.mylevel < IsPlayerAtEffectiveMaxLevel()
	end

	E:CreateMover(Azerite.holder, 'AzeriteBarMover', L["Azerite Bar"], nil, nil, nil, nil, nil, 'databars,azerite')

	DB:AzeriteBar_Toggle()
end
