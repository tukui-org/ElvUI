local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_PhaseIcon(frame)
	local PhaseIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK', nil, 1)
	PhaseIndicator:SetSize(30, 30)
	PhaseIndicator:SetPoint('CENTER', frame.Health, 'CENTER')
	PhaseIndicator:SetDrawLayer('OVERLAY', 7)

	return PhaseIndicator
end

function UF:Configure_PhaseIcon(frame)
	local PhaseIndicator = frame.PhaseIndicator
	PhaseIndicator:ClearAllPoints()
	PhaseIndicator:Point(frame.db.phaseIndicator.anchorPoint, frame.Health, frame.db.phaseIndicator.anchorPoint, frame.db.phaseIndicator.xOffset, frame.db.phaseIndicator.yOffset)

	local scale = frame.db.phaseIndicator.scale or 1
	PhaseIndicator:Size(30 * scale)

	if frame.db.phaseIndicator.enable and not frame:IsElementEnabled('PhaseIndicator') then
		frame:EnableElement('PhaseIndicator')
	elseif not frame.db.phaseIndicator.enable and frame:IsElementEnabled('PhaseIndicator') then
		frame:DisableElement('PhaseIndicator')
	end
end