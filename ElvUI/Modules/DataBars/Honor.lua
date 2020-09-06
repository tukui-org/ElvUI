local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local format = format
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local TogglePVPUI = TogglePVPUI
local HONOR = HONOR

function DB:HonorBar_Update(event, unit)
	if not DB.db.honor.enable then return end
	local bar = DB.StatusBars.Honor

	if event == 'PLAYER_FLAGS_CHANGED' and unit ~= 'player' then return end

	local cur, max = UnitHonor('player'), UnitHonorMax('player')

	--Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
	if max == 0 then max = 1 end

	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)
	local color = DB.db.colors.honor
	bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

	local text = ''
	local textFormat = DB.db.honor.textFormat

	if textFormat == 'PERCENT' then
		text = format('%d%%', cur / max * 100)
	elseif textFormat == 'CURMAX' then
		text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max))
	elseif textFormat == 'CURPERC' then
		text = format('%s - %d%%', E:ShortValue(cur), cur / max * 100)
	elseif textFormat == 'CUR' then
		text = format('%s', E:ShortValue(cur))
	elseif textFormat == 'REM' then
		text = format('%s', E:ShortValue(max - cur))
	elseif textFormat == 'CURREM' then
		text = format('%s - %s', E:ShortValue(cur), E:ShortValue(max - cur))
	elseif textFormat == 'CURPERCREM' then
		text = format('%s - %d%% (%s)', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
	end

	bar.text:SetText(text)
end

function DB:HonorBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, .4, self:GetAlpha(), 1)
	end

	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max, level = UnitHonor('player'), UnitHonorMax('player'), UnitHonorLevel('player')

	_G.GameTooltip:AddLine(HONOR)

	_G.GameTooltip:AddDoubleLine(L["Current Level:"], level, 1, 1, 1)
	_G.GameTooltip:AddLine(' ')

	_G.GameTooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	_G.GameTooltip:Show()
end

function DB:HonorBar_OnClick()
	TogglePVPUI()
end

function DB:HonorBar_Toggle()
	local bar = DB.StatusBars.Honor
	bar:SetShown(bar.db.enable)

	if bar.db.enable then
		DB:RegisterEvent('HONOR_XP_UPDATE', 'HonorBar_Update')
		DB:RegisterEvent('PLAYER_FLAGS_CHANGED', 'HonorBar_Update')
		DB:HonorBar_Update()
		E:EnableMover(bar.mover:GetName())
	else
		DB:UnregisterEvent('HONOR_XP_UPDATE')
		DB:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		E:DisableMover(bar.mover:GetName())
	end
end

function DB:HonorBar()
	DB.StatusBars.Honor = DB:CreateBar('ElvUI_HonorBar', DB.HonorBar_OnEnter, DB.HonorBar_OnClick, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -255)
	DB.StatusBars.Honor.db = DB.db.honor

	E:CreateMover(DB.StatusBars.Honor, 'HonorBarMover', L["Honor Bar"], nil, nil, nil, nil, nil, 'databars,honor')

	DB:HonorBar_Toggle()
end
