local E, L, V, P, G = unpack(ElvUI)
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local HasPetUI = HasPetUI
local UnitLevel = UnitLevel
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local GetPetExperience = GetPetExperience
local GameTooltip = GameTooltip

function DB:PetExperienceBar_ShouldBeVisible()
	return not IsLevelAtEffectiveMaxLevel(UnitLevel('pet'))
end

function DB:PetExperienceBar_Update()
	local bar = DB.StatusBars.PetExperience
	DB:SetVisibility(bar)

	if not bar:IsShown() then return end

	local color = DB.db.colors.petExperience
	bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

	local cur, max = GetPetExperience()
	if max <= 0 then max = 1 end
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)

	local text, textFormat = '', bar.db.textFormat

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

function DB:PetExperienceBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local cur, max = GetPetExperience()
	if max <= 0 then max = 1 end

	GameTooltip:AddLine(L["Pet Experience"])
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	GameTooltip:Show()
end

function DB:PetExperienceBar_OnClick() end

function DB:PetExperienceBar_Toggle()
	local bar = DB.StatusBars.PetExperience
	bar.db = DB.db.petExperience

	if bar.db.enable then
		E:EnableMover(bar.holder.mover.name)

		DB:PetExperienceBar_Update()
	else
		bar:Hide()

		E:DisableMover(bar.holder.mover.name)
	end
end

function DB:PetExperienceBar()
	local PetExperience = DB:CreateBar('ElvUI_PetExperienceBar', 'PetExperience', DB.PetExperienceBar_Update, DB.PetExperienceBar_OnEnter, DB.PetExperienceBar_OnClick, {'LEFT', _G.LeftChatPanel, 'RIGHT', -E.Border + E.Spacing * 3, 0})
	DB:CreateBarBubbles(PetExperience)

	PetExperience.ShouldHide = function()
		return not HasPetUI() or (HasPetUI() and DB.db.petExperience.hideAtMaxLevel and not DB:PetExperienceBar_ShouldBeVisible())
	end

	DB:RegisterEvent('PET_BAR_UPDATE', 'PetExperienceBar_Toggle')
	DB:RegisterEvent('UNIT_PET_EXPERIENCE', 'PetExperienceBar_Update')

	E:CreateMover(PetExperience.holder, 'PetExperienceBarMover', L["Pet Experience Bar"], nil, nil, nil, nil, nil, 'databars,petExperience')
	DB:PetExperienceBar_Toggle()
end
