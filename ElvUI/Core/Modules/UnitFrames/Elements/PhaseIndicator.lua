local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local PhaseReason = Enum.PhaseReason

function UF:PostUpdate_PhaseIcon(hidden, phaseReason)
	if phaseReason == PhaseReason.TimerunningHwt then -- timerunning world tier, phased in open world between hero/nonhero, but not phased in dungeons.
        local inInstance, _ = IsInInstance()
		if inInstance then
			self:Hide()
			return
		end
	elseif phaseReason == PhaseReason.ChromieTime then -- chromie, gold
		self.Center:SetVertexColor(1, 0.9, 0.5)
	elseif phaseReason == PhaseReason.WarMode then -- warmode, red
		self.Center:SetVertexColor(1, 0.3, 0.3)
	elseif phaseReason == PhaseReason.Sharding then -- sharding, green
		self.Center:SetVertexColor(0.5, 1, 0.3)
	else -- phasing, blue
		self.Center:SetVertexColor(0.3, 0.5, 1)
	end

	self.Center:SetShown(not hidden)
end

function UF:Construct_PhaseIcon(frame)
	local PhaseIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY', nil, 6)
	PhaseIndicator:SetTexture(E.Media.Textures.PhaseBorder)
	PhaseIndicator:Point('CENTER', frame.Health)
	PhaseIndicator:Size(32)
	PhaseIndicator:Hide()

	local Center = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY', nil, 7)
	Center:SetTexture(E.Media.Textures.PhaseCenter)
	Center:Point('CENTER', frame.Health)
	Center:Size(32)
	Center:Hide()

	PhaseIndicator.Center = Center
	PhaseIndicator.PostUpdate = UF.PostUpdate_PhaseIcon

	return PhaseIndicator
end

function UF:Configure_PhaseIcon(frame)
	local PhaseIndicator = frame.PhaseIndicator
	PhaseIndicator:ClearAllPoints()
	PhaseIndicator:Point(frame.db.phaseIndicator.anchorPoint, frame.Health, frame.db.phaseIndicator.anchorPoint, frame.db.phaseIndicator.xOffset, frame.db.phaseIndicator.yOffset)

	local size = 32 * (frame.db.phaseIndicator.scale or 1)
	PhaseIndicator:Size(size)
	PhaseIndicator.Center:Size(size)
	PhaseIndicator.Center:ClearAllPoints()
	PhaseIndicator.Center:SetAllPoints(PhaseIndicator)

	if frame.db.phaseIndicator.enable and not frame:IsElementEnabled('PhaseIndicator') then
		frame:EnableElement('PhaseIndicator')
	elseif not frame.db.phaseIndicator.enable and frame:IsElementEnabled('PhaseIndicator') then
		frame:DisableElement('PhaseIndicator')
		PhaseIndicator.Center:Hide()
	end
end
