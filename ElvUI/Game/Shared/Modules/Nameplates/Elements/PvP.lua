local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local format = format
local strlower = strlower
local CreateFrame = CreateFrame

function NP:PvPIndicator_PostUpdate(_, status)
	if status and status ~= 'FFA' and (not self.Badge or not self.Badge:IsShown()) then
		local atlas = format('bfa-landingbutton-%s-up', strlower(status))
		self:SetAtlas(atlas)
		self:SetTexCoord(0, 1, 0, 1)
	end
end

function NP:Construct_PvPIndicator(nameplate)
	local element = CreateFrame('Frame', '$parent_PvPIndicator', nameplate)
	element:SetFrameLevel(nameplate.RaisedElement.PvPIndicatorLevel)

	local PvPIndicator = element:CreateTexture(nil, 'OVERLAY')
	PvPIndicator.Badge_ = element:CreateTexture(nil, 'ARTWORK')
	PvPIndicator.PostUpdate = NP.PvPIndicator_PostUpdate

	return PvPIndicator
end

function NP:Update_PvPIndicator(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.pvpindicator and db.pvpindicator.enable then
		if not nameplate:IsElementEnabled('PvPIndicator') then
			nameplate:EnableElement('PvPIndicator')
		end

		local size = db.pvpindicator.size
		nameplate.PvPIndicator:Size(size, size)
		nameplate.PvPIndicator.Badge_:Size(size + 14, size + 16)

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
	return nameplate.RaisedElement:CreateTexture(nil, 'OVERLAY')
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
