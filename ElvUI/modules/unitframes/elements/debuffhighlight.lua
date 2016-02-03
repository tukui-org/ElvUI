local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_DebuffHighlight(frame)
	local dbh = frame:CreateTexture(nil, "OVERLAY")
	dbh:SetInside(frame.Health.backdrop)
	dbh:SetTexture(E['media'].blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode("ADD")
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0.45
	frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors

	frame:CreateShadow('Default')
	local x = frame.shadow
	frame.shadow = nil
	x:Hide();

	frame.DBHGlow = x

	if frame.Health then
		dbh:SetParent(frame.Health)
		frame.DBHGlow:SetParent(frame.Health)
	end

	return dbh
end