local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local LSM = E.Libs.LSM

local _G = _G
local pairs, unpack, next = pairs, unpack, next
local wipe, tinsert = wipe, tinsert

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

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
	local t = GetLootRollTimeLeft(frame.parent.rollID)
	local perc = t / frame.parent.time
	frame.spark:Point('CENTER', frame, 'LEFT', perc * frame:GetWidth(), 0)
	frame:SetValue(t)
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local f = CreateFrame('Button', nil, parent)
	f:SetNormalTexture(texture..'-Up')
	f:SetDisabledTexture(texture..'-Up')
	f:GetDisabledTexture():SetDesaturated(true)
	f:GetDisabledTexture():SetAlpha(.2)
	f:SetPushedTexture(texture..'-Down')
	f:SetHighlightTexture(texture..'-Highlight')
	f:SetScript('OnEnter', SetTip)
	f:SetScript('OnLeave', GameTooltip_Hide)
	f:SetScript('OnClick', ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)

	f.parent = parent
	f.rolltype = rolltype
	f.tiptext = tiptext

	f.text = f:CreateFontString(nil, 'ARTWORK')
	f.text:FontTemplate(nil, nil, 'OUTLINE')
	f.text:SetPoint('BOTTOMRIGHT', 0, 0)

	return f
end

function M:CreateRollFrame()
	local frame = CreateFrame('Frame', nil, E.UIParent)
	frame:Hide()

	local status = CreateFrame('StatusBar', nil, frame)
	status:SetFrameLevel(frame:GetFrameLevel())
	status:SetFrameStrata(frame:GetFrameStrata())
	status:CreateBackdrop()
	status:SetScript('OnUpdate', StatusUpdate)
	status:SetStatusBarTexture(E.db.general.lootRoll.statusBarTexture)
	status.parent = frame
	frame.status = status

	local spark = frame:CreateTexture(nil, 'ARTWORK', nil, 1)
	spark:SetPoint('CENTER', status:GetStatusBarTexture(), 'RIGHT', 0, 0)
	spark:SetBlendMode('BLEND')
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
	if E.Retail then
		frame.disenchant = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT)
	end
	frame.greed = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED)
	frame.need = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED)

	local name = frame:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, nil, 'OUTLINE')
	name:SetJustifyH('LEFT')
	frame.name = name

	local bind = frame:CreateFontString(nil, 'OVERLAY')
	bind:FontTemplate(nil, nil, 'OUTLINE')
	frame.bind = bind

	frame.rolls = {}

	return frame
end

local function GetFrame(i)
	for _, f in next, M.RollBars do
		if not f.rollID and not i then
			return f
		end
	end

	local f = M:CreateRollFrame()
	f:ClearAllPoints()
	f:Point('TOP', next(M.RollBars) and M.RollBars[#M.RollBars] or _G.AlertFrameHolder, 'BOTTOM', 0, -4)

	tinsert(M.RollBars, f)

	return f
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

	local f = GetFrame()
	wipe(f.rolls)

	f.rollID = rollID
	f.time = rollTime

	f.button.link = link
	f.button.rollID = rollID
	f.button:RegisterEvent('MODIFIER_STATE_CHANGED')
	f.button.icon:SetTexture(texture)
	f.button.stack:SetShown(count > 1)
	f.button.stack:SetText(count)

	f.button.questIcon:SetShown(E.Bags:GetItemQuestInfo(link, bindType, itemClassID))

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

	f.status:SetMinMaxValues(0, rollTime)
	f.status:SetValue(rollTime)

	f:ClearAllPoints()
	f:Point('CENTER', _G.WorldFrame)
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

function M:UpdateLootRollFrames()
	if not E.private.general.lootRoll then return end
	local texture = LSM:Fetch('statusbar', E.db.general.lootRoll.statusBarTexture)

	for i = 1, 4 do
		local frame = M.RollBars[i]
		frame:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height)

		frame.status:SetStatusBarTexture(texture)
		frame.status.backdrop.Center:SetTexture(E.db.general.lootRoll.statusBarBGTexture and E.media.normTex or E.media.blankTex)

		frame.button:ClearAllPoints()
		frame.button:Point('RIGHT', frame, 'LEFT', -3, 0)
		frame.button:Size(E.db.general.lootRoll.height)

		frame.button.questIcon:ClearAllPoints()
		frame.button.questIcon:Point('RIGHT', frame.button, 'LEFT', -3, 0)
		frame.button.questIcon:Size(E.db.general.lootRoll.height)

		for _, button in next, rolltypes do
			local icon = frame[button]
			if icon then
				icon:Size(E.db.general.lootRoll.height / 1.5)
				icon:ClearAllPoints()
			end
		end

		if E.db.general.lootRoll.style == 'halfbar' then
			frame.status:ClearAllPoints()
			frame.status:Point('BOTTOM', 3, 0)
			frame.status:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height / 3)
			frame.status.spark:Size(2, (E.db.general.lootRoll.height / 3))

			frame.name:ClearAllPoints()
			frame.name:Point('BOTTOMLEFT', frame.status, 'TOPLEFT', 4, 4)

			frame.bind:ClearAllPoints()
			frame.bind:Point('RIGHT', frame.need, 'LEFT', -1, 0)

			frame.pass:Point('TOPRIGHT', frame, 4, 0)
			if frame.disenchant then frame.disenchant:Point('RIGHT', frame.pass, 'LEFT', 1, 0) end
			frame.greed:Point('RIGHT', frame.disenchant or frame.pass, 'LEFT', 1, 0)
			frame.need:Point('RIGHT', frame.greed, 'LEFT', 1, 0)
		else
			frame.status:ClearAllPoints()
			frame.status:SetAllPoints()
			frame.status:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height)
			frame.status.spark:Size(2, (E.db.general.lootRoll.height))

			frame.name:ClearAllPoints()
			frame.name:Point('LEFT', frame.status, 4, 0)

			frame.bind:ClearAllPoints()
			frame.bind:Point('RIGHT', frame.need, 'LEFT', -1, 0)

			frame.pass:Point('RIGHT', frame.status, 'RIGHT', -4, 0)
			if frame.disenchant then frame.disenchant:Point('RIGHT', frame.pass, 'LEFT', 1, 0) end
			frame.greed:Point('RIGHT', frame.disenchant or frame.pass, 'LEFT', 1, 0)
			frame.need:Point('RIGHT', frame.greed, 'LEFT', 1, 0)
		end
	end
end

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	for i = 1, 4 do
		GetFrame(i)
	end

	M:UpdateLootRollFrames()

	M:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
	M:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE')
	M:RegisterEvent('START_LOOT_ROLL')
	M:RegisterEvent('CANCEL_LOOT_ROLL')
	M:RegisterEvent('LOOT_ROLLS_COMPLETE')

	_G.UIParent:UnregisterEvent('START_LOOT_ROLL')
	_G.UIParent:UnregisterEvent('CANCEL_LOOT_ROLL')
end
