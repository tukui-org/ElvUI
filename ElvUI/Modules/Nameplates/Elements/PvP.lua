local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_PvPIndicator(nameplate)
	local PvPIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	PvPIndicator:Size(36, 36)
	PvPIndicator:Point('CENTER', nameplate)
	PvPIndicator.Badge_ = nameplate:CreateTexture(nil, 'ARTWORK')
	PvPIndicator.Badge_:SetSize(50, 52)
	PvPIndicator.Badge_:SetPoint('CENTER', PvPIndicator, 'CENTER')

	function PvPIndicator:PostUpdate(unit, status)
		if not status then return end

		if (not self.Badge) or (self.Badge and not self.Badge:IsShown()) then
			if status ~= 'FFA' then
				self:SetAtlas('bfa-landingbutton-'..strlower(status)..'-up', true)
				self:SetTexCoord(0, 1, 0, 1)
			end
		end
	end

	return PvPIndicator
end

function NP:Update_PvPIndicator(nameplate)

end