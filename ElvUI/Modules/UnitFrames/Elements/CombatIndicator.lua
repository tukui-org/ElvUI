local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local C_Timer_NewTimer = C_Timer.NewTimer
local UnitAffectingCombat = UnitAffectingCombat

local CombatTextures = {
	COMBAT = E.Media.Textures.Combat,
	DEFAULT = [[Interface\CharacterFrame\UI-StateIcon]],
	PLATINUM = [[Interface\Challenges\ChallengeMode_Medal_Platinum]],
	ATTACK = [[Interface\CURSOR\Attack]],
	ALERT = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
	ALERT2 = [[Interface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon]],
	ARTHAS = [[Interface\LFGFRAME\UI-LFR-PORTRAIT]],
	SKULL = [[Interface\LootFrame\LootPanel-Icon]],
}

function UF:Construct_CombatIndicator(frame)
	return frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')
end

local TestingTimer
local TestingFrame
local function TestingFunc()
	local inCombat = UnitAffectingCombat('player')
	if TestingFrame and not inCombat then
		TestingFrame:Hide()
	end
end

function UF:TestingDisplay_CombatIndicator(frame)
	local Icon = frame.CombatIndicator
	local db = frame.db.CombatIcon

	if TestingTimer then
		TestingTimer:Cancel()
	end

	if not db.enable then
		Icon:Hide()
		return
	end

	Icon:Show()
	TestingFrame = Icon
	TestingTimer = C_Timer_NewTimer(10, TestingFunc)
end

function UF:Configure_CombatIndicator(frame)
	local Icon = frame.CombatIndicator
	local db = frame.db.CombatIcon

	Icon:ClearAllPoints()
	Icon:Point('CENTER', frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
	Icon:Size(db.size)

	if db.defaultColor then
		Icon:SetVertexColor(1, 1, 1, 1)
		Icon:SetDesaturated(false)
	else
		Icon:SetVertexColor(db.color.r, db.color.g, db.color.b, db.color.a)
		Icon:SetDesaturated(true)
	end

	if db.texture == 'CUSTOM' and db.customTexture then
		Icon:SetTexture(db.customTexture)
		Icon:SetTexCoord(0, 1, 0, 1)
	elseif db.texture ~= 'DEFAULT' and CombatTextures[db.texture] then
		Icon:SetTexture(CombatTextures[db.texture])
		Icon:SetTexCoord(0, 1, 0, 1)
	else
		Icon:SetTexture(CombatTextures.DEFAULT)
		Icon:SetTexCoord(.5, 1, 0, .49)
	end

	if db.enable and not frame:IsElementEnabled('CombatIndicator') then
		frame:EnableElement('CombatIndicator')
	elseif not db.enable and frame:IsElementEnabled('CombatIndicator') then
		frame:DisableElement('CombatIndicator')
	end
end
