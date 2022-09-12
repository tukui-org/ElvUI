local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local C_Timer_NewTimer = C_Timer.NewTimer
local UnitAffectingCombat = UnitAffectingCombat

function UF:Construct_CombatIndicator(frame)
	return frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')
end

local TestingTimer, TestingFrame

local function TestingFunc()
	local inCombat = UnitAffectingCombat('player')
	if TestingFrame and not inCombat then
		TestingFrame:Hide()
	end
end

function UF:TestingDisplay_CombatIndicator(frame)
	local Icon = frame.CombatIndicator
	if not Icon then return end

	if TestingTimer then
		TestingTimer:Cancel()
	end

	local db = frame.db and frame.db.CombatIcon
	if not db or not db.enable then
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
	elseif db.texture ~= 'DEFAULT' and E.Media.CombatIcons[db.texture] then
		Icon:SetTexture(E.Media.CombatIcons[db.texture])
		Icon:SetTexCoord(0, 1, 0, 1)
	else
		Icon:SetTexture(E.Media.CombatIcons.DEFAULT)
		Icon:SetTexCoord(.5, 1, 0, .49)
	end

	if db.enable and not frame:IsElementEnabled('CombatIndicator') then
		frame:EnableElement('CombatIndicator')
	elseif not db.enable and frame:IsElementEnabled('CombatIndicator') then
		frame:DisableElement('CombatIndicator')
	end
end
