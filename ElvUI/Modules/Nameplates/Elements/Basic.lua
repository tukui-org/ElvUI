local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_TagText(frame)
	local Text = frame:CreateFontString(nil, 'OVERLAY')
	Text:SetFont(E.LSM:Fetch('font', self.db.healthFont), self.db.healthFontSize, self.db.healthFontOutline)

	return Text
end