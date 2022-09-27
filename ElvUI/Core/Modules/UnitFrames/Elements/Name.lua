local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local UnitIsPlayer = UnitIsPlayer

function UF:Construct_NameText(frame)
	local name = UF:CreateRaisedText(frame.RaisedElementParent)

	name:Point('CENTER', frame.Health)

	return name
end

function UF:UpdateNameSettings(frame)
	local db = frame.db

	local name = frame.Name
	if not db.power or not db.power.enable or not db.power.hideonnpc then
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		name:ClearAllPoints()
		name:Point(db.name.position, attachPoint, db.name.position, db.name.xOffset, db.name.yOffset)
	end

	frame:Tag(name, db.name.text_format)
end

function UF:PostNamePosition(frame, unit)
	if not frame.Power.value:IsShown() then return end

	local db = frame.db
	if UnitIsPlayer(unit) or (db.power and not db.power.enable) then
		local position = db.name.position
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		frame.Power.value:SetAlpha(1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(position, attachPoint, position, db.name.xOffset, db.name.yOffset)
	else
		frame.Power.value:SetAlpha(db.power.hideonnpc and 0 or 1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(frame.Power.value:GetPoint())
	end
end
