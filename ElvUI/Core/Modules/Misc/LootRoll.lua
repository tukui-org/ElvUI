local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local B = E:GetModule('Bags')

local LSM = E.Libs.LSM

local _G = _G
local pairs, unpack, next = pairs, unpack, next
local wipe, tinsert, format = wipe, tinsert, format

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot

local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem

local C_LootHistory_GetItem = C_LootHistory.GetItem
local C_LootHistory_GetPlayerInfo = C_LootHistory.GetPlayerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES or 4

local cachedRolls = {}
local cancelled_rolls = {}
local completedRolls = {}
M.RollBars = {}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local rolltypes = { [1] = 'need', [2] = 'greed', [3] = 'disenchant', [0] = 'pass' }
local function SetTip(frame)
	GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(frame.tiptext)

	local lineAdded
	if frame:IsEnabled() == 0 then
		GameTooltip:AddLine('|cffff3333'..L["Can't Roll"])
	end

	local rolls = frame.parent.rolls[frame.rolltype]
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

local function SetItemTip(frame)
	if not frame.rollID or not frame:IsMouseOver() then return end

	GameTooltip:SetOwner(frame, 'ANCHOR_TOPLEFT')
	GameTooltip:SetLootRollItem(frame.rollID)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
end

local function LootClick(frame)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(frame.link)
	end
end

local function StatusUpdate(frame, elapsed)
	if not frame.parent.rollID then return end

	if frame.elapsed and frame.elapsed > 0.1 then
		frame:SetValue(GetLootRollTimeLeft(frame.parent.rollID))
		frame.elapsed = 0
	else
		frame.elapsed = (frame.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = {1.05, -0.1, 1.05, -0.1}, -- pass
	[2] = {0.05, 1.05, -0.025, 0.85}, -- greed
	[1] = {0.05, 1.05, -0.05, .95}, -- need
	[3] = {0.05, 1.05, -0.05, .95}, -- disenchant
}

local function RollTexCoords(f, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == f.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == f.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(f, texture, rolltype)
	f:SetNormalTexture(texture)
	f:SetPushedTexture(texture)
	f:SetDisabledTexture(texture)
	f:SetHighlightTexture(texture)

	f.normalTex = f:GetNormalTexture()
	f.disabledTex = f:GetDisabledTexture()
	f.pushedTex = f:GetPushedTexture()
	f.highlightTex = f:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(f, f.normalTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.disabledTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.pushedTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.highlightTex, rolltype, minX, maxX, minY, maxY)
end

local function RollMouseDown(f)
	if f.highlightTex then
		f.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(f)
	if f.highlightTex then
		f.highlightTex:SetAlpha(1)
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local f = CreateFrame('Button', format('$parent_%sButton', tiptext), parent)
	f:SetScript('OnMouseDown', RollMouseDown)
	f:SetScript('OnMouseUp', RollMouseUp)
	f:SetScript('OnClick', ClickRoll)
	f:SetScript('OnEnter', SetTip)
	f:SetScript('OnLeave', GameTooltip_Hide)
	f:SetMotionScriptsWhileDisabled(true)
	f:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(f, texture..'-Up', rolltype)

	f.parent = parent
	f.rolltype = rolltype
	f.tiptext = tiptext

	f.text = f:CreateFontString(nil, 'ARTWORK')
	f.text:FontTemplate(nil, nil, 'OUTLINE')
	f.text:SetPoint('BOTTOMRIGHT', 2, -2)

	return f
end

function M:LootRoll_Create(index)
	local frame = CreateFrame('Frame', 'ElvUI_LootRollFrame'..index, E.UIParent)
	frame:Hide()

	local status = CreateFrame('StatusBar', nil, frame)
	status:SetFrameLevel(frame:GetFrameLevel())
	status:SetFrameStrata(frame:GetFrameStrata())
	status:CreateBackdrop()
	status:SetScript('OnUpdate', StatusUpdate)
	status:SetStatusBarTexture(E.db.general.lootRoll.statusBarTexture)
	status.parent = frame
	frame.status = status

	local spark = status:CreateTexture(nil, 'ARTWORK', nil, 1)
	spark:SetBlendMode('BLEND')
	spark:Point('RIGHT', status:GetStatusBarTexture())
	spark:Point('BOTTOM')
	spark:Point('TOP')
	spark:Width(2)
	status.spark = spark

	local button = CreateFrame('Button', nil, frame)
	button:CreateBackdrop()
	button:SetScript('OnEnter', SetItemTip)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetScript('OnClick', LootClick)
	button:SetScript('OnEvent', SetItemTip)
	frame.button = button

	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(E.TexCoords))

	button.stack = button:CreateFontString(nil, 'OVERLAY')
	button.stack:SetPoint('BOTTOMRIGHT', -1, 1)
	button.stack:FontTemplate(nil, nil, 'OUTLINE')

	button.questIcon = button:CreateTexture(nil, 'OVERLAY')
	button.questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
	button.questIcon:SetTexCoord(1, 0, 0, 1)
	button.questIcon:Hide()

	frame.pass = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Pass]], 0, PASS)
	frame.disenchant = E.Retail and CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT) or nil
	frame.greed = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED)
	frame.need = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED)

	local name = frame:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, nil, 'OUTLINE')
	name:SetJustifyH('LEFT')
	name:SetWordWrap(false)
	frame.name = name

	local bind = frame:CreateFontString(nil, 'OVERLAY')
	bind:FontTemplate(nil, nil, 'OUTLINE')
	frame.bind = bind

	frame.rolls = {}

	tinsert(M.RollBars, frame)

	return frame
end

function M:LootFrame_GetFrame(i)
	if M.RollBars[i] then
		return M.RollBars[i]
	else
		for _, f in next, M.RollBars do
			if not f.rollID and not i then
				return f
			end
		end

		return M:LootRoll_Create(i)
	end
end

function M:CANCEL_LOOT_ROLL(_, rollID)
	cancelled_rolls[rollID] = true

	for _, bar in next, M.RollBars do
		if bar.rollID == rollID then
			bar.rollID = nil
			bar.time = nil
			bar:Hide()
			bar.button:UnregisterAllEvents()
		end
	end
end

function M:START_LOOT_ROLL(_, rollID, rollTime)
	if cancelled_rolls[rollID] then return end
	local link = GetLootRollItemLink(rollID)
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	local _, _, _, _, _, _, _, _, _, _, _, itemClassID, _, bindType = GetItemInfo(link)
	local color = ITEM_QUALITY_COLORS[quality]

	local f = M:LootFrame_GetFrame()
	wipe(f.rolls)

	f.rollID = rollID
	f.time = rollTime

	f.button.link = link
	f.button.rollID = rollID
	f.button:RegisterEvent('MODIFIER_STATE_CHANGED')
	f.button.icon:SetTexture(texture)
	f.button.stack:SetShown(count > 1)
	f.button.stack:SetText(count)
	f.button.questIcon:SetShown(B:GetItemQuestInfo(link, bindType, itemClassID))

	f.need:SetEnabled(canNeed)
	f.greed:SetEnabled(canGreed)

	f.need.text:SetText(0)
	f.greed.text:SetText(0)
	f.pass.text:SetText(0)

	if f.disenchant then
		f.disenchant.text:SetText(0)
		f.disenchant:SetEnabled(canDisenchant)
	end

	f.name:SetText(name)

	if E.db.general.lootRoll.qualityName then
		f.name:SetTextColor(color.r, color.g, color.b)
	else
		f.name:SetTextColor(1, 1, 1)
	end

	f.bind:SetText(bop and L["BoP"] or bindType == 2 and L["BoE"] or bindType == 3 and L["BoU"])
	f.bind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	if E.db.general.lootRoll.qualityStatusBar then
		f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
		f.status.spark:SetColorTexture(color.r, color.g, color.b, .9)
	else
		local c = E.db.general.lootRoll.statusBarColor
		f.status:SetStatusBarColor(c.r, c.g, c.b, .7)
		f.status.spark:SetColorTexture(c.r, c.g, c.b, .9)
	end

	if E.db.general.lootRoll.qualityStatusBarBackdrop then
		f.status.backdrop:SetBackdropColor(color.r, color.g, color.b, .1)
	else
		local r, g, b = unpack(E.media.backdropfadecolor)
		f.status.backdrop:SetBackdropColor(r, g, b, .1)
	end

	f.status.elapsed = 1
	f.status:SetMinMaxValues(0, rollTime)
	f.status:SetValue(rollTime)

	f:Show()

	_G.AlertFrame:UpdateAnchors()

	--Add cached roll info, if any
	for rollid, rollTable in pairs(cachedRolls) do
		if f.rollID == rollid then --rollid matches cached rollid
			for rollType, rollerInfo in pairs(rollTable) do
				local rollerName, class = rollerInfo[1], rollerInfo[2]
				if not f.rolls[rollType] then f.rolls[rollType] = {} end
				tinsert(f.rolls[rollType], { rollerName, class })
				f[rolltypes[rollType]].text:SetText(#f.rolls[rollType])
			end

			completedRolls[rollid] = true
			break
		end
	end
end

function M:LOOT_HISTORY_ROLL_CHANGED(_, itemIdx, playerIdx)
	local rollID = C_LootHistory_GetItem(itemIdx)
	local name, class, rollType = C_LootHistory_GetPlayerInfo(itemIdx, playerIdx)

	local rollIsHidden = true
	if name and rollType then
		for _, f in next, M.RollBars do
			if f.rollID == rollID then
				if not f.rolls[rollType] then f.rolls[rollType] = {} end
				tinsert(f.rolls[rollType], { name, class })
				f[rolltypes[rollType]].text:SetText(#f.rolls[rollType])
				rollIsHidden = false
				break
			end
		end

		--History changed for a loot roll that hasn't popped up for the player yet, so cache it for later
		if rollIsHidden then
			if not cachedRolls[rollID] then cachedRolls[rollID] = {} end
			if not cachedRolls[rollID][rollType] then
				if not cachedRolls[rollID][rollType] then cachedRolls[rollID][rollType] = {} end
				tinsert(cachedRolls[rollID][rollType], { name, class })
			end
		end
	end
end

function M:LOOT_HISTORY_ROLL_COMPLETE()
	wipe(cachedRolls)
	wipe(completedRolls)
end
M.LOOT_ROLLS_COMPLETE = M.LOOT_HISTORY_ROLL_COMPLETE

function M:UpdateLootRollAnchors(POSITION)
	local spacing, lastFrame, lastShown = E.db.general.lootRoll.spacing + E.Spacing
	for i, frame in next, M.RollBars do
		frame:ClearAllPoints()

		local anchor = i ~= 1 and lastFrame or _G.AlertFrameHolder
		if POSITION == 'TOP' then
			frame:Point('TOP', anchor, 'BOTTOM', 0, -spacing)
		else
			frame:Point('BOTTOM', anchor, 'TOP', 0, spacing)
		end

		lastFrame = frame

		if frame:IsShown() then
			lastShown = frame
		end
	end

	return lastShown
end

function M:UpdateLootRollFrames()
	if not E.private.general.lootRoll then return end
	local db = E.db.general.lootRoll

	local font = LSM:Fetch('font', db.nameFont)
	local texture = LSM:Fetch('statusbar', db.statusBarTexture)

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = M:LootFrame_GetFrame(i)
		frame:Size(db.width, db.height)

		frame.status:SetStatusBarTexture(texture)
		frame.status.backdrop.Center:SetTexture(db.statusBarBGTexture and E.media.normTex or E.media.blankTex)

		frame.button:ClearAllPoints()
		frame.button:Point('RIGHT', frame, 'LEFT', E.PixelMode and -1 or -2, 0)
		frame.button:Size(db.height)

		frame.button.questIcon:ClearAllPoints()
		frame.button.questIcon:Point('RIGHT', frame.button, 'LEFT', -3, 0)
		frame.button.questIcon:Size(db.height)

		frame.name:FontTemplate(font, db.nameFontSize, db.nameFontOutline)
		frame.bind:FontTemplate(font, db.nameFontSize, db.nameFontOutline)

		for _, button in next, rolltypes do
			local icon = frame[button]
			if icon then
				icon:Size(db.buttonSize)
				icon:ClearAllPoints()
			end
		end

		frame.status:ClearAllPoints()
		frame.name:ClearAllPoints()
		frame.bind:ClearAllPoints()

		local full = db.style == 'fullbar'
		if full then
			frame.status:SetAllPoints()
			frame.status:Size(db.width, db.height)
		else
			frame.status:Point('BOTTOM', 3, 0)
			frame.status:Size(db.width, db.height / 3)
		end

		local anchor = full and frame or frame.status
		if db.leftButtons then
			frame.need:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', 3, 0)
			if frame.disenchant then frame.disenchant:Point('LEFT', frame.need, 'RIGHT', 3, 0) end
			frame.greed:Point('LEFT', frame.disenchant or frame.need, 'RIGHT', 3, 0)
			frame.pass:Point('LEFT', frame.greed, 'RIGHT', 3, 0)

			frame.name:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', full and -3 or -1, full and 0 or 3)
			frame.name:Point('LEFT', frame.bind, 'RIGHT', 1, 0)
			frame.bind:Point('LEFT', frame.pass, 'RIGHT', 1, 0)
		else
			frame.pass:Point(full and 'RIGHT' or 'BOTTOMRIGHT', anchor, full and 'RIGHT' or 'TOPRIGHT', -3, 0)
			if frame.disenchant then frame.disenchant:Point('RIGHT', frame.pass, 'LEFT', -3, 0) end
			frame.greed:Point('RIGHT', frame.disenchant or frame.pass, 'LEFT', -3, 0)
			frame.need:Point('RIGHT', frame.greed, 'LEFT', -3, 0)

			frame.name:Point(full and 'LEFT' or 'BOTTOMLEFT', anchor, full and 'LEFT' or 'TOPLEFT', full and 3 or 1, full and 0 or 3)
			frame.name:Point('RIGHT', frame.bind, 'LEFT', -1, 0)
			frame.bind:Point('RIGHT', frame.need, 'LEFT', -1, 0)
		end
	end
end

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	M:UpdateLootRollFrames()

	M:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
	M:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE')
	M:RegisterEvent('START_LOOT_ROLL')
	M:RegisterEvent('CANCEL_LOOT_ROLL')
	M:RegisterEvent('LOOT_ROLLS_COMPLETE')

	_G.UIParent:UnregisterEvent('START_LOOT_ROLL')
	_G.UIParent:UnregisterEvent('CANCEL_LOOT_ROLL')
end
