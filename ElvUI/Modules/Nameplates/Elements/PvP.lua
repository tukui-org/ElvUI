local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local strlower = strlower

function NP:Construct_PvPIndicator(nameplate)
	local PvPIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	PvPIndicator:Size(36, 36)
	PvPIndicator:Point('CENTER', nameplate)
	PvPIndicator.Badge_ = nameplate:CreateTexture(nil, 'ARTWORK')
	PvPIndicator.Badge_:Size(50, 52)
	PvPIndicator.Badge_:Point('CENTER', PvPIndicator, 'CENTER')

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
	local db = NP.db.units[nameplate.frameType]

	if db.pvpindicator and db.pvpindicator.enable then
		if not nameplate:IsElementEnabled('PvPIndicator') then
			nameplate:EnableElement('PvPIndicator')
		end

		nameplate.PvPIndicator:Size(db.pvpindicator.size, db.pvpindicator.size)
		nameplate.PvPIndicator.Badge_:Size(db.pvpindicator.size + 14, db.pvpindicator.size + 16)

		nameplate.PvPIndicator.Badge = nil

		if db.pvpindicator.showBadge then
			nameplate.PvPIndicator.Badge = nameplate.PvPIndicator.Badge_
		end

		nameplate.PvPIndicator:ClearAllPoints()
		nameplate.PvPIndicator:Point(E.InversePoints[db.pvpindicator.position], nameplate, db.pvpindicator.position, db.pvpindicator.xOffset, db.pvpindicator.yOffset)
	else
		if nameplate:IsElementEnabled('PvPIndicator') then
			nameplate:DisableElement('PvPIndicator')
		end
	end
end
