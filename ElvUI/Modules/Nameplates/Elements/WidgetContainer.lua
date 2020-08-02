local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_WidgetContainer(nameplate)
	local WidgetContainer = CreateFrame('Frame', nil, nameplate, 'UIWidgetContainerTemplate')
	WidgetContainer:Hide()
	WidgetContainer:SetPoint('BOTTOM', nameplate, 'TOP')

	return WidgetContainer
end
