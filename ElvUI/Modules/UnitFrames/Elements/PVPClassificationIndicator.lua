local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
--WoW API / Variables

function UF:Construct_PvPClassificationIndicator(frame)
    local PvPClassificationIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')

	return PvPClassificationIndicator
end

function UF:Configure_PvPClassificationIndicator(frame)
	local PvPClassificationIndicator = frame.PvPClassificationIndicator
	PvPClassificationIndicator:ClearAllPoints()
	PvPClassificationIndicator:Point(frame.db.pvpClassificationIndicator.anchorPoint, frame.Health, frame.db.pvpClassificationIndicator.anchorPoint, frame.db.pvpClassificationIndicator.xOffset, frame.db.pvpClassificationIndicator.yOffset)

	if frame.db.pvpClassificationIndicator.enable and not frame:IsElementEnabled('PvPClassificationIndicator') then
		frame:EnableElement('PvPClassificationIndicator')
	elseif not frame.db.pvpClassificationIndicator.enable and frame:IsElementEnabled('PvPClassificationIndicator') then
		frame:DisableElement('PvPClassificationIndicator')
	end
end
