local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	return nameplate:CreateFontString(nil, 'OVERLAY')
end

function NP:Update_TagText(nameplate, element, db, hide)
	if not db then return end

	if db.enable and not hide then
		element:FontTemplate(E.LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
		nameplate:Tag(element, db.format or '')
		element:UpdateTag()

		element:ClearAllPoints()
		element:Point(E.InversePoints[db.position], db.parent == 'Nameplate' and nameplate or nameplate[db.parent], db.position, db.xOffset, db.yOffset)
		element:Show()
	else
		nameplate:Untag(element)
		element:Hide()
	end
end

function NP:Update_Tags(nameplate)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)
	local hide = db.nameOnly or sf.NameOnly

	NP:Update_TagText(nameplate, nameplate.Name, db.name)
	NP:Update_TagText(nameplate, nameplate.Title, db.title)
	NP:Update_TagText(nameplate, nameplate.Level, db.level, hide)

	if nameplate.Health then
		NP:Update_TagText(nameplate, nameplate.Health.Text, db.health and db.health.text, hide)
	end
	if nameplate.Power then
		NP:Update_TagText(nameplate, nameplate.Power.Text, db.power and db.power.text, hide)
	end
end
