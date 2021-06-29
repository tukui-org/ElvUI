local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

function UF:Construct_PvPClassificationIndicator(frame)
	local PvPClassificationIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')

	return PvPClassificationIndicator
end

function UF:Configure_PvPClassificationIndicator(frame)
	local PvPClassificationIndicator = frame.PvPClassificationIndicator
	local db = frame.db

	PvPClassificationIndicator:Size(db.pvpclassificationindicator.size)
	PvPClassificationIndicator:ClearAllPoints()
	PvPClassificationIndicator:Point(E.InversePoints[db.pvpclassificationindicator.position], frame, db.pvpclassificationindicator.position, db.pvpclassificationindicator.xOffset, db.pvpclassificationindicator.yOffset)

	if frame.db.pvpclassificationindicator.enable and not frame:IsElementEnabled('PvPClassificationIndicator') then
		frame:EnableElement('PvPClassificationIndicator')
	elseif not frame.db.pvpclassificationindicator.enable and frame:IsElementEnabled('PvPClassificationIndicator') then
		frame:DisableElement('PvPClassificationIndicator')
	end
end
