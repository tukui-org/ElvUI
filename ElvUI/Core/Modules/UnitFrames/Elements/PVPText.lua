local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

function UF:Construct_PvPText(frame)
	return UF:CreateRaisedText(frame.RaisedElementParent)
end

function UF:Configure_PVPText(frame)
	local pvp = frame.PvPText
	local x, y = self:GetPositionOffset(frame.db.pvp.position)
	pvp:ClearAllPoints()
	pvp:Point(frame.db.pvp.position, frame.Health, frame.db.pvp.position, x, y)

	frame:Tag(pvp, frame.db.pvp.text_format)
end
