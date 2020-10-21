local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

function UF:PostUpdate_PhaseIcon(_, phaseReason)
	if phaseReason == 3 then -- chromie, gold
		self.Overlay:SetVertexColor(1, 0.9, 0.5)
	elseif phaseReason == 2 then -- warmode, red
		self.Overlay:SetVertexColor(1, 0.3, 0.3)
	elseif phaseReason == 1 then -- sharding, purple
		self.Overlay:SetVertexColor(0.5, 0.3, 1)
	else -- phasing, blue
		self.Overlay:SetVertexColor(0.3, 0.5, 1)
	end
end

function UF:Construct_PhaseIcon(frame)
	local PhaseIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY', nil, 6)
	PhaseIndicator:SetTexture(E.Media.Textures.PhaseIcon)
	PhaseIndicator:Point('CENTER', frame.Health)
	PhaseIndicator:Size(32)

	local Overlay = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY', nil, 7)
	Overlay:SetTexture(E.Media.Textures.PhaseOverlay)
	Overlay:Point('CENTER', frame.Health)
	Overlay:Size(32)

	PhaseIndicator.Overlay = Overlay
	PhaseIndicator.PostUpdate = UF.PostUpdate_PhaseIcon

	return PhaseIndicator
end

function UF:Configure_PhaseIcon(frame)
	local PhaseIndicator = frame.PhaseIndicator
	PhaseIndicator:ClearAllPoints()
	PhaseIndicator:Point(frame.db.phaseIndicator.anchorPoint, frame.Health, frame.db.phaseIndicator.anchorPoint, frame.db.phaseIndicator.xOffset, frame.db.phaseIndicator.yOffset)

	local scale = frame.db.phaseIndicator.scale or 1
	PhaseIndicator:Size(32 * scale)

	if frame.db.phaseIndicator.enable and not frame:IsElementEnabled('PhaseIndicator') then
		frame:EnableElement('PhaseIndicator')
	elseif not frame.db.phaseIndicator.enable and frame:IsElementEnabled('PhaseIndicator') then
		frame:DisableElement('PhaseIndicator')
	end
end
