local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local UnitHonorMax = UnitHonorMax
local TogglePVPUI = TogglePVPUI
local HONOR = HONOR

local CurrentHonor, MaxHonor, CurrentLevel, PercentHonor, RemainingHonor

function DB:HonorBar_Update(event, unit)
	if event == 'PLAYER_FLAGS_CHANGED' and unit ~= 'player' then return end

	local bar = DB.StatusBars.Honor
	DB:SetVisibility(bar)

	if not DB.db.honor.enable then return end

	CurrentHonor, MaxHonor, CurrentLevel = UnitHonor('player'), UnitHonorMax('player'), UnitHonorLevel('player')

	--Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
	if MaxHonor == 0 then MaxHonor = 1 end

	PercentHonor, RemainingHonor = (CurrentHonor / MaxHonor) * 100, MaxHonor - CurrentHonor

	local displayString, textFormat = '', DB.db.honor.textFormat
	local color = DB.db.colors.honor

	bar:SetMinMaxValues(0, MaxHonor)
	bar:SetValue(CurrentHonor)
	bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

	if textFormat == 'PERCENT' then
		displayString = format('%d%% - [%s]', PercentHonor, CurrentLevel)
	elseif textFormat == 'CURMAX' then
		displayString = format('%s - %s - [%s]', E:ShortValue(CurrentHonor), E:ShortValue(MaxHonor), CurrentLevel)
	elseif textFormat == 'CURPERC' then
		displayString = format('%s - %d%% - [%s]', E:ShortValue(CurrentHonor), PercentHonor, CurrentLevel)
	elseif textFormat == 'CUR' then
		displayString = format('%s - [%s]', E:ShortValue(CurrentHonor), CurrentLevel)
	elseif textFormat == 'REM' then
		displayString = format('%s - [%s]', E:ShortValue(RemainingHonor), CurrentLevel)
	elseif textFormat == 'CURREM' then
		displayString = format('%s - %s - [%s]', E:ShortValue(CurrentHonor), E:ShortValue(RemainingHonor), CurrentLevel)
	elseif textFormat == 'CURPERCREM' then
		displayString = format('%s - %d%% (%s) - [%s]', E:ShortValue(CurrentHonor), CurrentHonor, E:ShortValue(RemainingHonor), CurrentLevel)
	end

	bar.text:SetText(displayString)
end

function DB:HonorBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, .4, self:GetAlpha(), 1)
	end

	if _G.GameTooltip:IsForbidden() then return end

	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')

	_G.GameTooltip:AddLine(HONOR)

	_G.GameTooltip:AddDoubleLine(L["Current Level:"], CurrentLevel, 1, 1, 1)
	_G.GameTooltip:AddLine(' ')

	_G.GameTooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%d%%)', CurrentHonor, MaxHonor, PercentHonor), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', RemainingHonor, (RemainingHonor) / MaxHonor * 100, 20 * (RemainingHonor) / MaxHonor), 1, 1, 1)

	_G.GameTooltip:Show()
end

function DB:HonorBar_OnClick()
	TogglePVPUI()
end

function DB:HonorBar_Toggle()
	local bar = DB.StatusBars.Honor
	bar.db = DB.db.honor

	if bar.db.enable then
		E:EnableMover(bar.holder.mover:GetName())

		DB:RegisterEvent('HONOR_XP_UPDATE', 'HonorBar_Update')
		DB:RegisterEvent('PLAYER_FLAGS_CHANGED', 'HonorBar_Update')

		DB:HonorBar_Update()
	else
		E:DisableMover(bar.holder.mover:GetName())

		DB:UnregisterEvent('HONOR_XP_UPDATE')
		DB:UnregisterEvent('PLAYER_FLAGS_CHANGED')
	end
end

function DB:HonorBar()
	local Honor = DB:CreateBar('ElvUI_HonorBar', 'Honor', DB.HonorBar_Update, DB.HonorBar_OnEnter, DB.HonorBar_OnClick, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -255})
	DB:CreateBarBubbles(Honor)

	Honor.ShouldHide = function()
		return DB.db.honor.hideBelowMaxLevel and not IsPlayerAtEffectiveMaxLevel()
	end

	E:CreateMover(Honor.holder, 'HonorBarMover', L["Honor Bar"], nil, nil, nil, nil, nil, 'databars,honor')

	DB:HonorBar_Toggle()
end
