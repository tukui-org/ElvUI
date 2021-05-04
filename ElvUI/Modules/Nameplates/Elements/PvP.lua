local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local strlower = strlower

function NP:PvPIndicator_PostUpdate(_, status)
	if status and status ~= 'FFA' and (not self.Badge or not self.Badge:IsShown()) then
		self:SetAtlas('bfa-landingbutton-'..strlower(status)..'-up')
		self:SetTexCoord(0, 1, 0, 1)
	end
end

function NP:Construct_PvPIndicator(nameplate)
	local PvPIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	PvPIndicator.Badge_ = nameplate:CreateTexture(nil, 'ARTWORK')
	PvPIndicator.PostUpdate = NP.PvPIndicator_PostUpdate

	return PvPIndicator
end

function NP:Update_PvPIndicator(nameplate)
	local db = NP:PlateDB(nameplate)

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
	elseif nameplate:IsElementEnabled('PvPIndicator') then
		nameplate:DisableElement('PvPIndicator')
	end
end

function NP:Construct_PvPClassificationIndicator(nameplate)
	local PvPClassificationIndicator = nameplate:CreateTexture(nil, 'OVERLAY')
	return PvPClassificationIndicator
end

function NP:Update_PvPClassificationIndicator(nameplate)
	local db = NP:PlateDB(nameplate)

	if (nameplate.frameType == 'ENEMY_PLAYER' or nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'PLAYER') and db.pvpclassificationindicator and db.pvpclassificationindicator.enable then
		if not nameplate:IsElementEnabled('PvPClassificationIndicator') then
			nameplate:EnableElement('PvPClassificationIndicator')
		end

		nameplate.PvPClassificationIndicator:ClearAllPoints()
		nameplate.PvPClassificationIndicator:Point(E.InversePoints[db.pvpclassificationindicator.position], nameplate, db.pvpclassificationindicator.position, db.pvpclassificationindicator.xOffset, db.pvpclassificationindicator.yOffset)
		nameplate.PvPClassificationIndicator:Size(db.pvpclassificationindicator.size)
	elseif nameplate:IsElementEnabled('PvPClassificationIndicator') then
		nameplate:DisableElement('PvPClassificationIndicator')
	end
end
