local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Portrait(nameplate)
	local Portrait = nameplate:CreateTexture(nil, 'OVERLAY')
	Portrait:SetSize(32, 32)
	Portrait:SetPoint('RIGHT', nameplate, 'LEFT')

	return Portrait
end

function NP:Update_Portrait(nameplate)
	nameplate.Portrait:SetSize(32, 32)
	nameplate.Portrait:SetPoint('RIGHT', nameplate, 'LEFT')
end