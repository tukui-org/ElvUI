local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_CombatIndicator(frame)
	return frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
end

function UF:Configure_CombatIndicator(frame)
	local Icon = frame.CombatIndicator
	local db = frame.db.CombatIcon

	Icon:ClearAllPoints()
	Icon:Point("CENTER", frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
	Icon:SetVertexColor(db.color.r, db.color.g, db.color.b, db.color.a)
	Icon:Size(20 * (db.scale or 1))

	if db.enable and not frame:IsElementEnabled('CombatIndicator') then
		frame:EnableElement('CombatIndicator')
	elseif not db.enable and frame:IsElementEnabled('CombatIndicator') then
		frame:DisableElement('CombatIndicator')
	end
end