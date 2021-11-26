local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local LSM = E.Libs.LSM

local _G = _G
local pairs, unpack, ipairs, next, tonumber, tinsert = pairs, unpack, ipairs, next, tonumber, tinsert
local wipe = wipe

local ChatEdit_InsertLink = ChatEdit_InsertLink
local CreateFrame = CreateFrame
local DressUpItemLink = DressUpItemLink
local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local GetItemInfo = GetItemInfo
local ShowInspectCursor = ShowInspectCursor
local IsControlKeyDown = IsControlKeyDown
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot

local C_LootHistory_GetItem = C_LootHistory.GetItem
local C_LootHistory_GetPlayerInfo = C_LootHistory.GetPlayerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT

local GameTooltip = _G.GameTooltip

local cancelled_rolls = {}
local cachedRolls = {}
local completedRolls = {}
M.RollBars = {}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local rolltypes = { [1] = 'need', [2] = 'greed', [3] = 'disenchant', [0] = 'pass' }
local function SetTip(frame)
	GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
	GameTooltip:SetLootRollItem(frame.parent.rollID)

	local lineAdded
	if frame:IsEnabled() == 0 then GameTooltip:AddLine('|cffff3333'..L["Can't Roll"]) end

	for _, infoTable in next, frame.parent.rolls[frame.rolltype] do
		local playerName, className = unpack(infoTable)
		if not lineAdded then
			GameTooltip:AddLine(' ')
			lineAdded = true
		end
		local classColor = E:ClassColor(className)
		GameTooltip:AddLine(playerName, classColor.r, classColor.g, classColor.b)
	end

	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then return end
	_G.GameTooltip:SetOwner(frame, 'ANCHOR_TOPLEFT')
	_G.GameTooltip:SetHyperlink(frame.link)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick('DRESSUP') then ShowInspectCursor() end
end


local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
	local t = GetLootRollTimeLeft(frame.parent.rollID)
	local perc = t / frame.parent.time
	frame.spark:Point('CENTER', frame, 'LEFT', perc * frame:GetWidth(), 0)
	frame:SetValue(t)

	if t > 1000000000 then
		frame:GetParent():Hide()
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local f = CreateFrame('Button', nil, parent)
	f:SetNormalTexture(texture..'-Up')
	f:SetDisabledTexture(texture..'-Up')
	f:GetDisabledTexture():SetDesaturated(true)
	f:GetDisabledTexture():SetAlpha(.2)
	f:SetPushedTexture(texture..'-Down')
	f:SetHighlightTexture(texture..'-Highlight')
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript('OnEnter', SetTip)
	f:SetScript('OnLeave', GameTooltip_Hide)
	f:SetScript('OnClick', ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)

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
	frame.button = button

	button.icon = button:CreateTexture(nil, 'OVERLAY')
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(E.TexCoords))

	button.stack = button:CreateFontString(nil, 'OVERLAY')
	button.stack:SetPoint('BOTTOMRIGHT', -1, 1)
	button.stack:FontTemplate(nil, nil, 'OUTLINE')

	frame.pass = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Pass]], 0, PASS)
	if E.Retail then
		frame.disenchant = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT)
	end
	frame.greed = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED)
	frame.need = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED)

	local name = frame:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, nil, 'OUTLINE')
	name:Size(200, 10)
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
		end
	end
end

function M:START_LOOT_ROLL(_, rollID, time)
	if cancelled_rolls[rollID] then return end
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	local link = GetLootRollItemLink(rollID)
	local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(link)
	local color = ITEM_QUALITY_COLORS[quality]

	local f = GetFrame()
	wipe(f.rolls)

	f.rollID = rollID
	f.time = time

	f.button.link = link
	f.button.icon:SetTexture(texture)
	f.button.stack:SetShown(count > 1)
	f.button.stack:SetText(count)

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

	f.bind:SetText(bop and L["BoP"] or bindType == 2 and L["BoE"])
	f.bind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	if E.db.general.lootRoll.qualityStatusBar then
		f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
		f.status.spark:SetColorTexture(color.r, color.g, color.b, .9)
	else
		f.status:SetStatusBarColor(1, 1, 0, .7)
		f.status.spark:SetColorTexture(1, 1, 0, .9)
	end

	if E.db.general.lootRoll.qualityStatusBarBackdrop then
		f.status.backdrop:SetBackdropColor(color.r, color.g, color.b, .1)
	else
		local r, g, b = unpack(E.media.backdropfadecolor)
		f.status.backdrop:SetBackdropColor(r, g, b, .1)
	end

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:ClearAllPoints()
	f:Point('CENTER', _G.WorldFrame)
	f:Show()

	_G.AlertFrame:UpdateAnchors()

	--Add cached roll info, if any
	for rollid, rollTable in pairs(cachedRolls) do
		if f.rollID == rollid then --rollid matches cached rollid
			for rollType, rollerInfo in pairs(rollTable) do
				local rollerName, class = rollerInfo[1], rollerInfo[2]
				f.rolls[rollType] = f.rolls[rollType] or {}
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
				f.rolls[rollType] = f.rolls[rollType] or {}
				tinsert(f.rolls[rollType], { name, class })
				f[rolltypes[rollType]].text:SetText(#f.rolls[rollType])
				rollIsHidden = false
				break
			end
		end

		--History changed for a loot roll that hasn't popped up for the player yet, so cache it for later
		if rollIsHidden then
			cachedRolls[rollID] = cachedRolls[rollID] or {}
			if not cachedRolls[rollID][rollType] then
				cachedRolls[rollID][rollType] = cachedRolls[rollID][rollType] or {}
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
		frame.status:SetStatusBarTexture(texture)
		frame.status.backdrop.Center:SetTexture(E.db.general.lootRoll.statusBarBGTexture and E.media.normTex or E.media.blankTex)

		if E.db.general.lootRoll.style == 'halfbar' then
			frame:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height)

			frame.button:ClearAllPoints()
			frame.button:Point('RIGHT', frame, 'LEFT', -3, 0)
			frame.button:Size(E.db.general.lootRoll.height, E.db.general.lootRoll.height)

			frame.status:ClearAllPoints()
			frame.status:Point('BOTTOM', 3, 0)
			frame.status:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height / 3)
			frame.status.spark:Size(2, (E.db.general.lootRoll.height / 3))

			frame.name:ClearAllPoints()
			frame.name:Point('BOTTOMLEFT', frame.status, 'TOPLEFT', 4, 4)

			frame.bind:ClearAllPoints()
			frame.bind:Point('RIGHT', frame.need, 'LEFT', -1, 0)

			for _, button in next, rolltypes do
				if frame[button] then
					frame[button]:Size(E.db.general.lootRoll.height / 1.5)
					frame[button]:ClearAllPoints()
				end
			end

			frame.pass:Point('TOPRIGHT', frame, 4, 0)
			if frame.disenchant then frame.disenchant:Point('RIGHT', frame.pass, 'LEFT', 1, 0) end
			frame.greed:Point('RIGHT', frame.disenchant or frame.pass, 'LEFT', 1, 0)
			frame.need:Point('RIGHT', frame.greed, 'LEFT', 1, 0)
		else
			frame:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height)

			frame.button:ClearAllPoints()
			frame.button:Point('RIGHT', frame, 'LEFT', -3, 0)
			frame.button:Size(E.db.general.lootRoll.height, E.db.general.lootRoll.height)

			frame.status:ClearAllPoints()
			frame.status:SetAllPoints()
			frame.status:Size(E.db.general.lootRoll.width, E.db.general.lootRoll.height)
			frame.status.spark:Size(2, (E.db.general.lootRoll.height))

			frame.name:ClearAllPoints()
			frame.name:Point('LEFT', frame.status, 4, 0)

			frame.bind:ClearAllPoints()
			frame.bind:Point('RIGHT', frame.need, 'LEFT', -1, 0)

			for _, button in next, rolltypes do
				if frame[button] then
					frame[button]:Size(E.db.general.lootRoll.height / 1.5)
					frame[button]:ClearAllPoints()
				end
			end

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
