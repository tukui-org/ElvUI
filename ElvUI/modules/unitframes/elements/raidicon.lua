local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

function UF:Construct_RaidIcon(frame)
	local tex = (frame.RaisedElementParent or frame):CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	tex:Size(18)
	tex:Point("CENTER", frame.Health, "TOP", 0, 2)
	tex.SetTexture = E.noop

	return tex
end

