local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:FontTemplate(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	return Text
end

function NP:Update_TagText(nameplate, element, db)
	if not db then return end

	if db.enable then
		nameplate:Tag(element, db.format or '')
		element:FontTemplate(E.LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
		element:UpdateTag()

		element:ClearAllPoints()
		element:SetPoint(E.InversePoints[db.position], db.parent == 'Nameplate' and nameplate or nameplate[db.parent], db.position, db.xOffset, db.yOffset)
		element:Show()
	else
		nameplate:Untag(element)
		element:Hide()
	end
end

function NP:Update_Tags(nameplate)
	local db = NP:PlateDB(nameplate)

	NP:Update_TagText(nameplate, nameplate.Name, db.name)
	NP:Update_TagText(nameplate, nameplate.Level, db.level)
	NP:Update_TagText(nameplate, nameplate.Title, db.title)
	NP:Update_TagText(nameplate, nameplate.Health.Text, db.health and db.health.text)
	NP:Update_TagText(nameplate, nameplate.Power.Text, db.power and db.power.text)
end
