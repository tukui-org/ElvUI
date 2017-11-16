local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local C_TimerNewTimer = C_Timer.NewTimer
local UnitAffectingCombat = UnitAffectingCombat

function UF:Construct_CombatIndicator(frame)
	return frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
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
	if TestingTimer then
		TestingTimer:Cancel()
	end

	frame:Show()
	TestingFrame = frame
	TestingTimer = C_TimerNewTimer(10, TestingFunc)
end

function UF:Configure_CombatIndicator(frame)
	local Icon = frame.CombatIndicator
	local db = frame.db.CombatIcon

	Icon:ClearAllPoints()
	Icon:Point("CENTER", frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
	Icon:SetVertexColor(db.color.r, db.color.g, db.color.b, db.color.a)
	Icon:Size(db.size)

	if db.enable and not frame:IsElementEnabled('CombatIndicator') then
		frame:EnableElement('CombatIndicator')
	elseif not db.enable and frame:IsElementEnabled('CombatIndicator') then
		frame:DisableElement('CombatIndicator')
	end
end