local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
--WoW API / Variables

function UF:Construct_ReadyCheckIcon(frame)
	local tex = frame.RaisedElementParent:CreateTexture(nil, "OVERLAY", nil, 7)
	tex:Size(12)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)

	return tex
end

function UF:Configure_ReadyCheckIcon(frame)
	if not frame:IsElementEnabled('ReadyCheck') then
		frame:EnableElement('ReadyCheck')
	end
end