local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local B = E:GetModule('Bags')

local LSM = E.Libs.LSM

local _G = _G
local unpack, next, wipe = unpack, next, wipe
local tinsert, tremove, format = tinsert, tremove, format

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot
local UIParent = UIParent

local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local GetItemInfo = C_Item.GetItemInfo
local C_LootHistory_GetItem = C_LootHistory.GetItem
local C_LootHistory_GetPlayerInfo = C_LootHistory.GetPlayerInfo

local GREED, NEED, PASS = GREED, NEED, PASS
local TRANSMOGRIFY, ROLL_DISENCHANT = TRANSMOGRIFY, ROLL_DISENCHANT
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

M.RollBars = {}

local cachedRolls = {}
local waitingRolls = {}
local rollTypes = {
	[1] = 'need',
	[2] = 'greed',
	[3] = 'disenchant',
	[4] = 'transmog',
	[0] = 'pass'
}

local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

local function SetTip(button)
	GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(button.tiptext)

	local lineAdded
	if button:IsEnabled() == 0 then
		GameTooltip:AddLine('|cffff3333'..L["Can't Roll"])
	end

	local rolls = button.parent.rolls[button.rolltype]
	if rolls then
		for _, infoTable in next, rolls do
			local playerName, className = unpack(infoTable)
			if not lineAdded then
				GameTooltip:AddLine(' ')
				lineAdded = true
			end

			local classColor = E:ClassColor(className) or PRIEST_COLOR
			GameTooltip:AddLine(playerName, classColor.r, classColor.g, classColor.b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(button, event)
	if not button.rollID or (event == 'MODIFIER_STATE_CHANGED' and not button:IsMouseOver()) then return end

	GameTooltip:SetOwner(button, 'ANCHOR_TOPLEFT')
	GameTooltip:SetLootRollItem(button.rollID)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
end

local function LootClick(button)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(button.link)
	end
end

local function StatusUpdate(status, elapsed)
	local bar = status.parent
	local rollID = bar.rollID
	if not rollID then
		bar:Hide()
		return
	end

	if status.elapsed and status.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(rollID)
		if timeLeft <= 0 then -- workaround for other addons auto-passing loot
			M.CANCEL_LOOT_ROLL(bar, 'OnUpdate', rollID)
		else
			status:SetValue(timeLeft)
			status.elapsed = 0
		end
	else
		status.elapsed = (status.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = {1.05, -0.1, 1.05, -0.1}, -- pass
	[2] = {0.05, 1.05, -0.025, 0.85}, -- greed
	[1] = {0.05, 1.05, -0.05, .95}, -- need
	[3] = {0.05, 1.05, -0.05, .95}, -- disenchant
	[4] = {0, 1, 0, 1}, -- transmog
}

local function RollTexCoords(button, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == button.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(button, texture, rolltype)
	button:SetNormalTexture(texture)
	button:SetPushedTexture(texture)
	button:SetDisabledTexture(texture)
	button:SetHighlightTexture(texture)

	button.normalTex = button:GetNormalTexture()
	button.disabledTex = button:GetDisabledTexture()
	button.pushedTex = button:GetPushedTexture()
	button.highlightTex = button:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(button, button.normalTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.disabledTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.pushedTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.highlightTex, rolltype, minX, maxX, minY, maxY)
end

local function RollMouseDown(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(1)
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local button = CreateFrame('Button', format('$parent_%sButton', tiptext), parent)
	button:SetScript('OnMouseDown', RollMouseDown)
	button:SetScript('OnMouseUp', RollMouseUp)
	button:SetScript('OnClick', ClickRoll)
	button:SetScript('OnEnter', SetTip)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(button, texture, rolltype)

	button.parent = parent
	button.rolltype = rolltype
	button.tiptext = tiptext

	button.text = button:CreateFontString(nil, 'ARTWORK')
	button.text:FontTemplate(nil, nil, 'OUTLINE')
	button.text:SetPoint('BOTTOMRIGHT', 2, -2)

	return button
end

function M:LootRoll_Create(index)
	local bar = CreateFrame('Frame', 'ElvUI_LootRollFrame'..index, E.UIParent)
	bar:SetScript('OnEvent', M.LootRoll_OnEvent)
	bar:RegisterEvent('CANCEL_LOOT_ROLL')
	bar:Hide()

	if E.Retail then
		bar:RegisterEvent('CANCEL_ALL_LOOT_ROLLS')
	end

	local status = CreateFrame('StatusBar', nil, bar)
	status:OffsetFrameLevel(nil, bar)
	status:SetFrameStrata(bar:GetFrameStrata())
	status:CreateBackdrop()
	status:SetScript('OnUpdate', StatusUpdate)
	status:SetStatusBarTexture(E.db.general.lootRoll.statusBarTexture)
	status.parent = bar
	bar.status = status

	local spark = status:CreateTexture(nil, 'ARTWORK', nil, 1)
	spark:SetBlendMode('BLEND')
	spark:Point('RIGHT', status:GetStatusBarTexture())
	spark:Point('BOTTOM')
	spark:Point('TOP')
	spark:Width(2)
	status.spark = spark

	local button = CreateFrame('Button', nil, bar)
	button:CreateBackdrop()
	button:SetScript('OnEvent', SetItemTip)
	button:SetScript('OnEnter', SetItemTip)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetScript('OnClick', LootClick)
	button:RegisterEvent('MODIFIER_STATE_CHANGED')
	bar.button = button

	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoords()

	button.stack = button:CreateFontString(nil, 'OVERLAY')
	button.stack:SetPoint('BOTTOMRIGHT', -1, 1)
	button.stack:FontTemplate(nil, nil, 'OUTLINE')

	button.ilvl = button:CreateFontString(nil, 'OVERLAY')
	button.ilvl:SetPoint('BOTTOM', button, 'BOTTOM', 0, 0)
	button.ilvl:FontTemplate(nil, nil, 'OUTLINE')

	button.questIcon = button:CreateTexture(nil, 'OVERLAY')
	button.questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
	button.questIcon:SetTexCoord(1, 0, 0, 1)
	button.questIcon:Hide()

	bar.pass = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Pass-Up]], 0, PASS)
	bar.disenchant = E.Retail and CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-DE-Up]], 3, ROLL_DISENCHANT) or nil
	bar.transmog = E.Retail and CreateRollButton(bar, [[Interface\MINIMAP\TRACKING\Transmogrifier]], 4, TRANSMOGRIFY) or nil
	bar.greed = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Coin-Up]], 2, GREED)
	bar.need = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Dice-Up]], 1, NEED)

	local name = bar:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, nil, 'OUTLINE')
	name:SetJustifyH('LEFT')
	name:SetWordWrap(false)
	bar.name = name

	local bind = bar:CreateFontString(nil, 'OVERLAY')
	bind:FontTemplate(nil, nil, 'OUTLINE')
	bar.bind = bind

	bar.rolls = {}

	tinsert(M.RollBars, bar)

	return bar
end

function M:LootRoll_GetFrame(i)
	if i then
		return M.RollBars[i] or M:LootRoll_Create(i)
	else -- check for a bar to reuse
		for _, bar in next, M.RollBars do
			if not bar.rollID then
				return bar
			end
		end
	end
end

function M:LootRoll_OnEvent(event, rollID)
	M[event](self, event, rollID)
end

function M:LootRoll_ClearBar(bar, event)
	bar.rollID = nil
	bar.time = nil

	if next(waitingRolls) then
		local newRoll = waitingRolls[1]
		tremove(waitingRolls, 1)

		M:START_LOOT_ROLL(event, newRoll.rollID, newRoll.rollTime)
	end
end

function M:CANCEL_LOOT_ROLL(event, rollID)
	if self.rollID == rollID then
		M:LootRoll_ClearBar(self, event)
	end
end

function M:CANCEL_ALL_LOOT_ROLLS(event)
	M:LootRoll_ClearBar(self, event)
end

function M:START_LOOT_ROLL(event, rollID, rollTime)
	local texture, name, count, quality, _, canNeed, canGreed, canDisenchant, _, _, _, _, canTransmog = GetLootRollItemInfo(rollID)
	if not name then -- also done in GroupLootFrame_OnShow
		for _, rollBar in next, M.RollBars do
			if rollBar.rollID == rollID then
				M.CANCEL_LOOT_ROLL(rollBar, event, rollID)
			end
		end

		return
	end

	local bar = M:LootRoll_GetFrame()
	if not bar then
		if E.Retail then
			tinsert(waitingRolls, { rollID = rollID, rollTime = rollTime })
		end

		return -- well this shouldn't happen
	end

	local itemLink = GetLootRollItemLink(rollID)
	local _, _, _, itemLevel, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID, bindType = GetItemInfo(itemLink)

	local db = E.db.general.lootRoll
	local r, g, b = E:GetItemQualityColor(quality)

	wipe(bar.rolls)

	bar.rollID = rollID
	bar.time = rollTime

	bar.button.link = itemLink
	bar.button.rollID = rollID
	bar.button.icon:SetTexture(texture)
	bar.button.stack:SetShown(count > 1)
	bar.button.stack:SetText(count)
	bar.button.ilvl:SetShown(B:IsItemEligibleForItemLevelDisplay(itemClassID, itemSubClassID, itemEquipLoc, quality))
	bar.button.ilvl:SetText(itemLevel)
	bar.button.questIcon:SetShown(B:GetItemQuestInfo(itemLink, bindType, itemClassID))

	bar.need.text:SetText('')
	bar.greed.text:SetText('')
	bar.pass.text:SetText('')
	bar.need:SetEnabled(canNeed)
	bar.greed:SetEnabled(canGreed and not canTransmog)

	if bar.disenchant then
		bar.disenchant.text:SetText('')
		bar.disenchant:SetEnabled(canDisenchant)
	end

	if bar.transmog then
		bar.transmog.text:SetText('')
		bar.transmog:SetEnabled(canTransmog)
	end

	bar.name:SetText(name)

	if db.qualityName then
		bar.name:SetTextColor(r, g, b)
	else
		bar.name:SetTextColor(1, 1, 1)
	end

	if db.qualityItemLevel then
		bar.button.ilvl:SetTextColor(r, g, b)
	else
		bar.button.ilvl:SetTextColor(1, 1, 1)
	end

	local bop = bindType == 1
	bar.bind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)
	bar.bind:SetText(B.BindText[bindType] or '')

	if db.qualityStatusBar then
		bar.status:SetStatusBarColor(r, g, b, .7)
		bar.status.spark:SetColorTexture(r, g, b, .9)
	else
		local c = db.statusBarColor
		bar.status:SetStatusBarColor(c.r, c.g, c.b, .7)
		bar.status.spark:SetColorTexture(c.r, c.g, c.b, .9)
	end

	if db.qualityStatusBarBackdrop then
		bar.status.backdrop:SetBackdropColor(r, g, b, .1)
	else
		local br, bg, bb = unpack(E.media.backdropfadecolor)
		bar.status.backdrop:SetBackdropColor(br, bg, bb, .1)
	end

	bar.status.elapsed = 1
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)

	bar:Show()

	_G.AlertFrame:UpdateAnchors()

	-- Add cached roll info, if any
	for rollid, rollTable in next, cachedRolls do
		if bar.rollID == rollid then -- rollid matches cached rollid
			for rollType, rollerInfo in next, rollTable do
				if not bar.rolls[rollType] then bar.rolls[rollType] = {} end
				tinsert(bar.rolls[rollType], { rollerInfo[1], rollerInfo[2] }) -- name, playerClass
				bar[rollTypes[rollType]].text:SetText(#bar.rolls[rollType])
			end

			break
		end
	end
end

function M:LOOT_HISTORY_ROLL_CHANGED(_, itemIdx, playerIdx)
	local name, playerClass, rollType = C_LootHistory_GetPlayerInfo(itemIdx, playerIdx)
	local rollID = C_LootHistory_GetItem(itemIdx)

	local rollIsHidden = true
	if name and rollType then
		local rollInfo = { name, playerClass }
		for _, bar in next, M.RollBars do
			if bar.rollID == rollID then
				if not bar.rolls[rollType] then bar.rolls[rollType] = {} end

				tinsert(bar.rolls[rollType], rollInfo)
				bar[rollTypes[rollType]].text:SetText(#bar.rolls[rollType])
				rollIsHidden = false

				break
			end
		end

		-- History changed for a loot roll that hasn't popped up for the player yet, so cache it for later
		if not rollIsHidden then return end
		if not cachedRolls[rollID] then cachedRolls[rollID] = {} end
		if not cachedRolls[rollID][rollType] then cachedRolls[rollID][rollType] = {} end

		tinsert(cachedRolls[rollID][rollType], rollInfo)
	end
end

function M:ClearLootRollCache()
	wipe(cachedRolls)
end

function M:UpdateLootRollAnchors(POSITION)
	local spacing, lastFrame, lastShown = E.db.general.lootRoll.spacing + E.Spacing
	for i, bar in next, M.RollBars do
		bar:ClearAllPoints()

		local anchor = i ~= 1 and lastFrame or _G.AlertFrameHolder
		if POSITION == 'TOP' then
			bar:Point('TOP', anchor, 'BOTTOM', 0, -spacing)
		else
			bar:Point('BOTTOM', anchor, 'TOP', 0, spacing)
		end

		lastFrame = bar

		if bar:IsShown() then
			lastShown = bar
		end
	end

	return lastShown
end

function M:UpdateLootRollFrames()
	if not E.private.general.lootRoll then return end
	local db = E.db.general.lootRoll

	local font = LSM:Fetch('font', db.nameFont)
	local texture = LSM:Fetch('statusbar', db.statusBarTexture)
	local maxBars = E.Retail and db.maxBars or _G.NUM_GROUP_LOOT_FRAMES or 4

	for i = 1, maxBars do
		local bar = M:LootRoll_GetFrame(i)
		bar:Size(db.width, db.height)

		bar.status:SetStatusBarTexture(texture)
		bar.status.backdrop.Center:SetTexture(db.statusBarBGTexture and E.media.normTex or E.media.blankTex)

		bar.button:ClearAllPoints()
		bar.button:Point('RIGHT', bar, 'LEFT', E.PixelMode and -1 or -2, 0)
		bar.button:Size(db.height)

		bar.button.questIcon:ClearAllPoints()
		bar.button.questIcon:Point('RIGHT', bar.button, 'LEFT', -3, 0)
		bar.button.questIcon:Size(db.height)

		bar.name:FontTemplate(font, db.nameFontSize, db.nameFontOutline)
		bar.bind:FontTemplate(font, db.nameFontSize, db.nameFontOutline)

		for _, button in next, rollTypes do
			local icon = bar[button]
			if icon then
				icon:Size(db.buttonSize)
				icon:ClearAllPoints()
			end
		end

		bar.status:ClearAllPoints()
		bar.name:ClearAllPoints()
		bar.bind:ClearAllPoints()

		local full = db.style == 'fullbar'
		if full then
			bar.status:SetAllPoints()
			bar.status:Size(db.width, db.height)
		else
			bar.status:Point('BOTTOM', 3, 0)
			bar.status:Size(db.width, db.height / 3)
		end

		local anchor = full and bar or bar.status
		if db.leftButtons then
			bar.need:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', 3, 0)
			if bar.disenchant then bar.disenchant:Point('LEFT', bar.need, 'RIGHT', 3, 0) end
			if bar.transmog then bar.transmog:Point('LEFT', bar.disenchant or bar.need, 'RIGHT', 3, 0) end
			bar.greed:Point('LEFT', bar.transmog or bar.disenchant or bar.need, 'RIGHT', 3, 0)
			bar.pass:Point('LEFT', bar.greed, 'RIGHT', 3, 0)

			bar.name:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', full and -3 or -1, full and 0 or 3)
			bar.name:Point('LEFT', bar.bind, 'RIGHT', 1, 0)
			bar.bind:Point('LEFT', bar.pass, 'RIGHT', 1, 0)
		else
			bar.pass:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', -3, 0)
			if bar.disenchant then bar.disenchant:Point('RIGHT', bar.pass, 'LEFT', -3, 0) end
			if bar.transmog then bar.transmog:Point('RIGHT', bar.disenchant or bar.pass, 'LEFT', -3, 0) end
			bar.greed:Point('RIGHT', bar.transmog or bar.disenchant or bar.pass, 'LEFT', -3, 0)
			bar.need:Point('RIGHT', bar.greed, 'LEFT', -3, 0)

			bar.name:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', full and 3 or 1, full and 0 or 3)
			bar.name:Point('RIGHT', bar.bind, 'LEFT', -1, 0)
			bar.bind:Point('RIGHT', bar.need, 'LEFT', -1, 0)
		end
	end
end

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	M:UpdateLootRollFrames()

	if not E.Retail then
		M:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
		M:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE', 'ClearLootRollCache')
		M:RegisterEvent('LOOT_ROLLS_COMPLETE', 'ClearLootRollCache')
	end

	M:RegisterEvent('START_LOOT_ROLL')

	UIParent:UnregisterEvent('START_LOOT_ROLL')
	UIParent:UnregisterEvent('CANCEL_LOOT_ROLL')
end
