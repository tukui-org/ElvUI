local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:SetFont(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_Name(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.name.enable then
		nameplate.Name:ClearAllPoints()
		nameplate.Name:SetPoint(E.InversePoints[db.name.position], nameplate, db.name.position, db.name.xOffset, db.name.yOffset)
		nameplate.Name:Show()
	else
		nameplate.Name:Hide()
	end
end

function NP:Update_Level(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.level.enable then
		nameplate.Level:ClearAllPoints()
		nameplate.Level:SetPoint(E.InversePoints[db.level.position], nameplate, db.level.position, db.level.xOffset, db.level.yOffset)
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