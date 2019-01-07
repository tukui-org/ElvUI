local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(nameplate)
	local Text = nameplate:CreateFontString(nil, 'OVERLAY')
	Text:SetFont(E.LSM:Fetch('font', self.db.healthFont), self.db.healthFontSize, self.db.healthFontOutline)

	return Text
end

function NP:Update_Name(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.showName then
		nameplate.Name:Show()
		nameplate.Name:ClearAllPoints()
		if not db.showLevel then
			nameplate.Name:SetPoint('BOTTOM', nameplate.Health, 'TOP', 0, E.Border*2) -- need option
			nameplate.Name:SetJustifyH('CENTER')
		else
			nameplate.Name:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, E.Border*2) -- need option
			nameplate.Name:SetJustifyH('LEFT')
			nameplate.Name:SetJustifyV('BOTTOM')
		end
	else
		nameplate.Name:Hide()
	end
end

function NP:Update_Level(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.showLevel then
		nameplate.Level:Show()
	else
		nameplate.Level:Hide()
	end
end

function NP:Update_Tags(nameplate)
	NP:Update_Name(nameplate)

	NP:Update_Level(nameplate)
end