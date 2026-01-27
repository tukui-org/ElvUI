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
	local text = frame.Power.value
	if not text:IsShown() then return end

	local db = frame.db
	local value = text:GetText() -- get secret variable to test
	if (db.power and db.power.enable) and E:NotSecretValue(value) and not UnitIsPlayer(unit) then
		text:SetAlpha(db.power.hideonnpc and 0 or 1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(text:GetPoint()) -- this point will be a secret
	else
		local position = db.name.position
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		text:SetAlpha(1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(position, attachPoint, position, db.name.xOffset, db.name.yOffset)
	end
end
