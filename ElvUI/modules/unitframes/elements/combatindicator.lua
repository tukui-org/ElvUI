local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_CombatIndicator(frame)
	local combat = frame:CreateTexture(nil, "OVERLAY")
	combat:Size(19)
	combat:Point("CENTER", frame.Health, "CENTER", 0,6)
	combat:SetVertexColor(0.69, 0.31, 0.31)

	return combat
end