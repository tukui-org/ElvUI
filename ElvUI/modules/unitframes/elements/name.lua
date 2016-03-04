local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local UnitIsPlayer = UnitIsPlayer

function UF:Construct_NameText(frame)
	local parent = frame.RaisedElementParent or frame
	local name = parent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(name)
	name:Point('CENTER', frame.Health)

	return name
end

function UF:UpdateNameSettings(frame, childType)
	local db = frame.db
	if childType == "pet" then
		db = frame.db.petsGroup
	elseif childType == "target" then
		db = frame.db.targetsGroup
	end

	local name = frame.Name
	if not db.power or not db.power.hideonnpc then
		local attachPoint = self:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		if(E.global.tukuiMode and frame.InfoPanel and frame.InfoPanel:IsShown()) then
			attachPoint = frame.InfoPanel
		end
		name:ClearAllPoints()
		name:Point(db.name.position, attachPoint, db.name.position, db.name.xOffset, db.name.yOffset)
	end

	frame:Tag(name, db.name.text_format)
end

function UF:PostNamePosition(frame, unit)
	if not frame.Power.value:IsShown() then return end
	local db = frame.db
	if UnitIsPlayer(unit) then
		local position = db.name.position
		local attachPoint = self:GetObjectAnchorPoint(frame, db.name.attachTextTo)
		frame.Power.value:SetAlpha(1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(position, attachPoint, position, db.name.xOffset, db.name.yOffset)
	else
		frame.Power.value:SetAlpha(db.power.hideonnpc and 0 or 1)

		frame.Name:ClearAllPoints()
		frame.Name:Point(frame.Power.value:GetPoint())
	end
end
