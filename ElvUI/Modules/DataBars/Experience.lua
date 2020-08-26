local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local min = min
local format = format
local GetPetExperience, UnitXP, UnitXPMax = GetPetExperience, UnitXP, UnitXPMax
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame

function DB:GetXP(unit)
	if unit == 'pet' then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function DB:UpdateExperience(event)
	if not DB.db.experience.enable then return end
	local bar = DB.expBar

	if IsXPUserDisabled()
	or (DB.db.experience.hideAtMaxLevel and E.mylevel == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()])
	or (DB.db.experience.hideInCombat and (event == 'PLAYER_REGEN_DISABLED' or InCombatLockdown())) then
		E:DisableMover(DB.expBar.mover:GetName())
		bar:Hide()
	else
		E:EnableMover(DB.expBar.mover:GetName())
		bar:Show()

		if DB.db.experience.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local cur, max = DB:GetXP('player')
		if max <= 0 then max = 1 end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur)

		local rested = GetXPExhaustion()
		local text = ''
		local textFormat = DB.db.experience.textFormat

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(min(cur + rested, max))

			if textFormat == 'PERCENT' then
				text = format('%d%% R:%d%%', cur / max * 100, rested / max * 100)
			elseif textFormat == 'CURMAX' then
				text = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == 'CURPERC' then
				text = format('%s - %d%% R:%s [%d%%]', E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			elseif textFormat == 'CUR' then
				text = format('%s R:%s', E:ShortValue(cur), E:ShortValue(rested))
			elseif textFormat == 'REM' then
				text = format('%s R:%s', E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURREM' then
				text = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURPERCREM' then
				text = format('%s - %d%% (%s) R:%s', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur), E:ShortValue(rested))
			end
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

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
		end

		bar.text:SetText(text)
	end
end

function DB:ExperienceBar_OnEnter()
	local GameTooltip = _G.GameTooltip
	if DB.db.experience.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max = DB:GetXP('player')
	local rested = GetXPExhaustion()
	GameTooltip:AddLine(L["Experience"])
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, E:Round(cur/max * 100)), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, E:Round((max - cur) / max * 100), 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Rested:"], format('+%d (%d%%)', rested, E:Round(rested / max * 100)), 1, 1, 1)
	end

	GameTooltip:Show()
end

function DB:ExperienceBar_OnClick() end

function DB:UpdateExperienceDimensions()
	DB.expBar:SetWidth(DB.db.experience.width)
	DB.expBar:SetHeight(DB.db.experience.height)

	DB.expBar.text:FontTemplate(LSM:Fetch('font', DB.db.experience.font), DB.db.experience.textSize, DB.db.experience.fontOutline)
	DB.expBar.rested:SetOrientation(DB.db.experience.orientation)
	DB.expBar.statusBar:SetReverseFill(DB.db.experience.reverseFill)

	DB.expBar.statusBar:SetOrientation(DB.db.experience.orientation)
	DB.expBar.rested:SetReverseFill(DB.db.experience.reverseFill)

	if DB.db.experience.orientation == 'HORIZONTAL' then
		DB.expBar.rested:SetRotatesTexture(false)
		DB.expBar.statusBar:SetRotatesTexture(false)
	else
		DB.expBar.rested:SetRotatesTexture(true)
		DB.expBar.statusBar:SetRotatesTexture(true)
	end

	if DB.db.experience.mouseover then
		DB.expBar:SetAlpha(0)
	else
		DB.expBar:SetAlpha(1)
	end
end

function DB:EnableDisable_ExperienceBar()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if DB.db.experience.enable and (E.mylevel ~= maxLevel or not DB.db.experience.hideAtMaxLevel) then
		DB:RegisterEvent('PLAYER_XP_UPDATE', 'UpdateExperience')
		DB:RegisterEvent('DISABLE_XP_GAIN', 'UpdateExperience')
		DB:RegisterEvent('ENABLE_XP_GAIN', 'UpdateExperience')
		DB:RegisterEvent('UPDATE_EXHAUSTION', 'UpdateExperience')
		DB:UnregisterEvent('UPDATE_EXPANSION_LEVEL')
		DB:UpdateExperience()
		E:EnableMover(DB.expBar.mover:GetName())
	else
		DB:UnregisterEvent('PLAYER_XP_UPDATE')
		DB:UnregisterEvent('DISABLE_XP_GAIN')
		DB:UnregisterEvent('ENABLE_XP_GAIN')
		DB:UnregisterEvent('UPDATE_EXHAUSTION')
		DB:RegisterEvent('UPDATE_EXPANSION_LEVEL', 'EnableDisable_ExperienceBar')
		DB.expBar:Hide()
		E:DisableMover(DB.expBar.mover:GetName())
	end
end

function DB:LoadExperienceBar()
	DB.expBar = DB:CreateBar('ElvUI_ExperienceBar', DB.ExperienceBar_OnEnter, DB.ExperienceBar_OnClick, 'BOTTOM', E.UIParent, 'BOTTOM', 0, 43)
	DB.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	DB.expBar.rested = CreateFrame('StatusBar', nil, DB.expBar)
	DB.expBar.rested:SetInside()
	DB.expBar.rested:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(DB.expBar.rested)
	DB.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)

	DB.expBar.eventFrame = CreateFrame('Frame')
	DB.expBar.eventFrame:Hide()
	DB.expBar.eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	DB.expBar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	DB.expBar.eventFrame:SetScript('OnEvent', function(_, event)
		DB:UpdateExperience(event)
	end)

	DB:UpdateExperienceDimensions()

	E:CreateMover(DB.expBar, 'ExperienceBarMover', L["Experience Bar"], nil, nil, nil, nil, nil, 'databars,experience')
	DB:EnableDisable_ExperienceBar()
end
