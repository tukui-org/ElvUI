local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

function NP:Construct_WidgetContainer(nameplate)
	local WidgetContainer = CreateFrame('Frame', nil, nameplate, 'UIWidgetContainerTemplate')
	WidgetContainer:Hide()
	WidgetContainer:SetPoint('BOTTOM', nameplate, 'TOP')
	WidgetContainer:UnregisterForWidgetSet()

	return WidgetContainer
end

function NP.Widget_DefaultLayout(widgetContainerFrame, sortedWidgets)
	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll();

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints();

		-- Default this to top-bottom until there is a better way...
		if index == 1 then
			-- This is the first widget in the set, so just anchor it to the widget container
			widgetFrame:SetPoint("TOP", widgetContainerFrame);
		else
			-- This is not the first widget in the set, so anchor it to the previous widget
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, widgetContainerFrame.verticalAnchorYOffset or -10);
		end

		widgetFrame:SetParent(widgetContainerFrame);
	end
end
