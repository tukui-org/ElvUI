local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local format = format
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local UnitIsPVP = UnitIsPVP
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local TogglePVPUI = TogglePVPUI
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local HONOR = HONOR

function DB:UpdateHonor(event, unit)
	if not DB.db.honor.enable then return end
	if event == 'PLAYER_FLAGS_CHANGED' and unit ~= 'player' then return end

	local bar = DB.honorBar

	if (DB.db.honor.hideInCombat and (event == 'PLAYER_REGEN_DISABLED' or InCombatLockdown())) or
		(DB.db.honor.hideOutsidePvP and not UnitIsPVP('player')) or (DB.db.honor.hideBelowMaxLevel and E.mylevel < MAX_PLAYER_LEVEL) then
		bar:Hide()
	else
		bar:Show()

		if DB.db.honor.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur = UnitHonor('player')
		local max = UnitHonorMax('player')

		--Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if max == 0 then max = 1 end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

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
end

function DB:HonorBar_OnEnter()
	local GameTooltip = _G.GameTooltip
	if DB.db.honor.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur = UnitHonor('player')
	local max = UnitHonorMax('player')
	local level = UnitHonorLevel('player')

	GameTooltip:AddLine(HONOR)

	GameTooltip:AddDoubleLine(L["Current Level:"], level, 1, 1, 1)
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	GameTooltip:Show()
end

function DB:HonorBar_OnClick()
	TogglePVPUI()
end

function DB:UpdateHonorDimensions()
	DB.honorBar:SetWidth(DB.db.honor.width)
	DB.honorBar:SetHeight(DB.db.honor.height)
	DB.honorBar.statusBar:SetOrientation(DB.db.honor.orientation)
	DB.honorBar.statusBar:SetReverseFill(DB.db.honor.reverseFill)
	DB.honorBar.text:FontTemplate(LSM:Fetch('font', DB.db.honor.font), DB.db.honor.textSize, DB.db.honor.fontOutline)

	if DB.db.honor.orientation == 'HORIZONTAL' then
		DB.honorBar.statusBar:SetRotatesTexture(false)
	else
		DB.honorBar.statusBar:SetRotatesTexture(true)
	end

	if DB.db.honor.mouseover then
		DB.honorBar:SetAlpha(0)
	else
		DB.honorBar:SetAlpha(1)
	end
end

function DB:EnableDisable_HonorBar()
	if DB.db.honor.enable then
		DB:RegisterEvent('HONOR_XP_UPDATE', 'UpdateHonor')
		DB:UpdateHonor()
		E:EnableMover(DB.honorBar.mover:GetName())
	else
		DB:UnregisterEvent('HONOR_XP_UPDATE')
		DB.honorBar:Hide()
		E:DisableMover(DB.honorBar.mover:GetName())
	end
end

function DB:LoadHonorBar()
	DB.honorBar = DB:CreateBar('ElvUI_HonorBar', DB.HonorBar_OnEnter, DB.HonorBar_OnClick, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -255)
	DB.honorBar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
	DB.honorBar.statusBar:SetMinMaxValues(0, 325)

	DB.honorBar.eventFrame = CreateFrame('Frame')
	DB.honorBar.eventFrame:Hide()
	DB.honorBar.eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	DB.honorBar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	DB.honorBar.eventFrame:RegisterEvent('PLAYER_FLAGS_CHANGED')
	DB.honorBar.eventFrame:SetScript('OnEvent', function(self, event, unit) DB:UpdateHonor(event, unit) end)

	DB:UpdateHonorDimensions()
	E:CreateMover(DB.honorBar, 'HonorBarMover', L["Honor Bar"], nil, nil, nil, nil, nil, 'databars,honor')

	DB:EnableDisable_HonorBar()
end
