local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_Name(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if not db.name then return end

	nameplate:Tag(nameplate.Name, db.name.format)

	if db.name.enable then
		nameplate.Name:ClearAllPoints()
		nameplate.Name:Point(E.InversePoints[db.name.position], db.name.parent == 'Nameplate' and nameplate or nameplate[db.name.parent], db.name.position, db.name.xOffset, db.name.yOffset)
		nameplate.Name:FontTemplate(E.LSM:Fetch('font', db.name.font), db.name.fontSize, db.name.fontOutline)
		nameplate.Name:Show()
	else
		nameplate.Name:Hide()
	end
end

function NP:Update_Level(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if not db.level then return end

	nameplate:Tag(nameplate.Level, db.level.format)

	if db.level.enable then
		nameplate.Level:ClearAllPoints()
		nameplate.Level:Point(E.InversePoints[db.level.position], db.level.parent == 'Nameplate' and nameplate or nameplate[db.level.parent], db.level.position, db.level.xOffset, db.level.yOffset)
		nameplate.Level:FontTemplate(E.LSM:Fetch('font', db.level.font), db.level.fontSize, db.level.fontOutline)
		nameplate.Level:Show()
	else
		nameplate.Level:Hide()
	end
end

function NP:Update_Title(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if not db.title then return end

	nameplate:Tag(nameplate.Title, db.title.format)

	if db.title.enable then
		nameplate.Title:ClearAllPoints()
		nameplate.Title:Point(E.InversePoints[db.title.position], db.title.parent == 'Nameplate' and nameplate or nameplate[db.title.parent], db.title.position, db.title.xOffset, db.title.yOffset)
		nameplate.Title:FontTemplate(E.LSM:Fetch('font', db.title.font), db.title.fontSize, db.title.fontOutline)
		nameplate.Title:Show()
	else
		nameplate.Title:Hide()
	end
end

function NP:Update_Tags(nameplate)
	NP:Update_Name(nameplate)
	NP:Update_Level(nameplate)
	NP:Update_Title(nameplate)
end
