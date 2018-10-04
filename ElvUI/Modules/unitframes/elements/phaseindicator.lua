local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local unpack = unpack
--WoW API / Variables
local UnitIsWarModePhased = UnitIsWarModePhased

local texCoords = {
    [1] = {1 / 128, 33 / 128, 1 / 64, 33 / 64},
    [2] = {34 / 128, 66 / 128, 1 / 64, 33 / 64},
}

function UF:PostUpdate_PhaseIcon(isInSamePhase)
	if not isInSamePhase then
		self:SetTexCoord(unpack(texCoords[UnitIsWarModePhased(self.__owner.unit) and 2 or 1]))
	end
end

function UF:Construct_PhaseIcon(frame)
	local PhaseIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK', nil, 1)
	PhaseIndicator:SetSize(30, 30)
	PhaseIndicator:SetPoint('CENTER', frame.Health, 'CENTER')
	PhaseIndicator:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\phaseIcons')
	PhaseIndicator:SetDrawLayer('OVERLAY', 7)

	PhaseIndicator.PostUpdate = UF.PostUpdate_PhaseIcon

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
