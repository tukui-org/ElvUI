local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_TagText(nameplate, element, db, hide, fonts)
	if not db then return end

	if fonts then
		element:FontTemplate(E.LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
	elseif db.enable and not hide then
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

function NP:Update_Tags(nameplate, fonts)
	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)
	local hide = db.nameOnly or sf.NameOnly

	NP:Update_TagText(nameplate, nameplate.Name, db.name, nil, fonts)
	NP:Update_TagText(nameplate, nameplate.Title, db.title, nil, fonts)
	NP:Update_TagText(nameplate, nameplate.Level, db.level, hide, fonts)
	NP:Update_TagText(nameplate, nameplate.Health.Text, db.health and db.health.text, hide, fonts)
	NP:Update_TagText(nameplate, nameplate.Power.Text, db.power and db.power.text, hide, fonts)
end
