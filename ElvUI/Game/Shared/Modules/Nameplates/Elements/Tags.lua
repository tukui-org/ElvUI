local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local CreateFrame = CreateFrame

function NP:Construct_TagText(nameplate, name)
	local element = CreateFrame('Frame', name and (nameplate.frameName..name) or nil, nameplate.RaisedElement)
	element:SetFrameLevel(nameplate.RaisedElement.TagTextLevel)

	local text = element:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(NP.db.font, NP.db.fontSize, NP.db.fontOutline)

	element.text = text

	return text
end

function NP:Update_TagText(nameplate, element, db, hide)
	if not db then return end

	if db.enable and not hide then
		nameplate:Tag(element, db.format or '')

		element:FontTemplate(db.font, db.fontSize, db.fontOutline)
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

	NP:Update_TagText(nameplate, nameplate.Name, db.name)
	NP:Update_TagText(nameplate, nameplate.Title, db.title)
	NP:Update_TagText(nameplate, nameplate.Level, db.level, db.nameOnly)
	NP:Update_TagText(nameplate, nameplate.Health.Text, db.health and db.health.text, db.nameOnly)
	NP:Update_TagText(nameplate, nameplate.Power.Text, db.power and db.power.text, db.nameOnly)
end
