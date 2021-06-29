local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

local function GetValues(curValue, minValue, maxValue)
	local maximum = maxValue - minValue
	local current, diff = curValue - minValue, maximum

	if diff == 0 then diff = 1 end -- prevent a division by zero

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	DB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local displayString, textFormat, label, rewardPending = '', DB.db.reputation.textFormat
	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
	local friendshipID, _, _, _, _, _, standingText, _, nextThreshold = GetFriendshipReputation(factionID)

	if friendshipID then
		reaction, label = 5, standingText

		if not nextThreshold then
			minValue, maxValue, curValue = 0, 1, 1
		end
	elseif C_Reputation_IsFactionParagon(factionID) then
		local current, threshold
		current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			label, minValue, maxValue, curValue, reaction = L["Paragon"], 0, threshold, current % threshold, 9
		end

		bar.Reward:SetPoint('CENTER', bar, DB.db.reputation.rewardPosition)
	end

	if not label then label = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN end
	local color = (DB.db.colors.useCustomFactionColors or reaction == 9) and DB.db.colors.factionColors[reaction] or _G.FACTION_BAR_COLORS[reaction] -- reaction 9 is Paragon

	bar:SetStatusBarColor(color.r, color.g, color.b)
	bar:SetMinMaxValues(minValue, maxValue)
	bar:SetValue(curValue)

	bar.Reward:SetShown(rewardPending and DB.db.reputation.showReward)

	local current, maximum, percent, capped = GetValues(curValue, minValue, maxValue)
	if capped and textFormat ~= 'NONE' then -- show only name and standing on exalted
		displayString = format('%s: [%s]', name, label)
	elseif textFormat == 'PERCENT' then
		displayString = format('%s: %d%% [%s]', name, percent, label)
	elseif textFormat == 'CURMAX' then
		displayString = format('%s: %s - %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum), label)
	elseif textFormat == 'CURPERC' then
		displayString = format('%s: %s - %d%% [%s]', name, E:ShortValue(current), percent, label)
	elseif textFormat == 'CUR' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(current), label)
	elseif textFormat == 'REM' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(maximum - current), label)
	elseif textFormat == 'CURREM' then
		displayString = format('%s: %s - %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum - current), label)
	elseif textFormat == 'CURPERCREM' then
		displayString = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(current), percent, E:ShortValue(maximum - current), label)
	end

	bar.text:SetText(displayString)
end

function DB:ReputationBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
	local standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	local isParagon = C_Reputation_IsFactionParagon(factionID)

	if factionID and isParagon then
		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
		if current and threshold then
			standing, minValue, maxValue, curValue = L["Paragon"], 0, threshold, current % threshold
		end
	end

	if name and not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		_G.GameTooltip:AddLine(name)
		_G.GameTooltip:AddLine(' ')

		local friendID, friendTextLevel, _
		if factionID then friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID) end

		_G.GameTooltip:AddDoubleLine(STANDING..':', (friendID and friendTextLevel) or standing, 1, 1, 1)

		if reaction ~= _G.MAX_REPUTATION_REACTION or isParagon then
			local current, maximum, percent = GetValues(curValue, minValue, maxValue)
			_G.GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', current, maximum, percent), 1, 1, 1)
		end

		_G.GameTooltip:Show()
	end
end

function DB:ReputationBar_OnClick()
	ToggleCharacter('ReputationFrame')
end

function DB:ReputationBar_Toggle()
	local bar = DB.StatusBars.Reputation
	bar.db = DB.db.reputation

	if bar.db.enable then
		E:EnableMover(bar.holder.mover:GetName())

		DB:RegisterEvent('UPDATE_FACTION', 'ReputationBar_Update')
		DB:RegisterEvent('COMBAT_TEXT_UPDATE', 'ReputationBar_Update')
		DB:RegisterEvent('QUEST_FINISHED', 'ReputationBar_Update')

		DB:ReputationBar_Update()
	else
		E:DisableMover(bar.holder.mover:GetName())

		DB:UnregisterEvent('UPDATE_FACTION')
		DB:UnregisterEvent('COMBAT_TEXT_UPDATE')
		DB:UnregisterEvent('QUEST_FINISHED')
	end
end

function DB:ReputationBar()
	local Reputation = DB:CreateBar('ElvUI_ReputationBar', 'Reputation', DB.ReputationBar_Update, DB.ReputationBar_OnEnter, DB.ReputationBar_OnClick, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264})
	DB:CreateBarBubbles(Reputation)

	Reputation.Reward = Reputation:CreateTexture()
	Reputation.Reward:SetAtlas('ParagonReputation_Bag')
	Reputation.Reward:Size(20)

	Reputation.ShouldHide = function()
		return (DB.db.reputation.hideBelowMaxLevel and not IsPlayerAtEffectiveMaxLevel()) or not GetWatchedFactionInfo()
	end

	E:CreateMover(Reputation.holder, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')

	DB:ReputationBar_Toggle()
end
