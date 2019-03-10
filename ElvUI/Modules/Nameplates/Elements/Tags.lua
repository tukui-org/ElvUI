local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_Name(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.name.enable then
		nameplate.Name:ClearAllPoints()
		nameplate.Name:Point(E.InversePoints[db.name.position], nameplate, db.name.position, db.name.xOffset, db.name.yOffset)
		nameplate.Name:FontTemplate(E.LSM:Fetch('font', db.name.font), db.name.fontSize, db.name.fontOutline)
		nameplate.Name:Show()
	else
		nameplate.Name:Hide()
	end
end

function NP:Update_Level(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.level.enable then
		nameplate.Level:ClearAllPoints()
		nameplate.Level:Point(E.InversePoints[db.level.position], nameplate, db.level.position, db.level.xOffset, db.level.yOffset)
		nameplate.Level:FontTemplate(E.LSM:Fetch('font', db.level.font), db.level.fontSize, db.level.fontOutline)
		nameplate.Level:Show()
	else
		nameplate.Level:Hide()
	end
end

function NP:Update_Tags(nameplate)
	local db = NP.db.units[nameplate.frameType]

	nameplate:Tag(nameplate.Name, db.name.format)
	nameplate:Tag(nameplate.Level, db.level.format)

	NP:Update_Name(nameplate)
	NP:Update_Level(nameplate)
end
