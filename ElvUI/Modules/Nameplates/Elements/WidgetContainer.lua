local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local ipairs = ipairs

function NP:Construct_WidgetContainer(nameplate)
	local WidgetContainer = CreateFrame('Frame', nil, nameplate, 'UIWidgetContainerTemplate')
	WidgetContainer:Hide()
	WidgetContainer:SetPoint('BOTTOM', nameplate, 'TOP', 0, 5)
	WidgetContainer:UnregisterForWidgetSet()

	return WidgetContainer
end

-- Copy & Pasta Blizz Code
function NP.Widget_DefaultLayout(widgetContainerFrame, sortedWidgets)
	local horizontalRowContainer = nil;

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll();

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints();

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == Enum.UIWidgetSetLayoutDirection.Vertical;
		local widgetUsesVertical = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Vertical;

		local useOverlapLayout = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Overlap;
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Default and widgetSetUsesVertical);

		if useOverlapLayout then
			-- This widget uses overlap layout

			if index == 1 then
				-- But this is the first widget in the set, so just anchor it to the widget container
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame);
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, widgetContainerFrame);
				end
			else
				-- This is not the first widget in the set, so anchor it so it overlaps the previous widget
				local relative = sortedWidgets[index - 1];
				if widgetSetUsesVertical then
					-- Overlap it vertically
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalAnchorPoint, 0, 0);
				else
					-- Overlap it horizontally
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalAnchorPoint, 0, 0);
				end
			end

			widgetFrame:SetParent(widgetContainerFrame);
		elseif useVerticalLayout then
			-- This widget uses vertical layout

			if index == 1 then
				-- This is the first widget in the set, so just anchor it to the widget container
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame);
			else
				-- This is not the first widget in the set, so anchor it to the previous widget (or the horizontalRowContainer if that exists)
				local relative = horizontalRowContainer or sortedWidgets[index - 1];
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset);

				if horizontalRowContainer then
					-- This widget is vertical, so horizontalRowContainer is done. Call layout on it and clear horizontalRowContainer
					horizontalRowContainer:Layout();
					horizontalRowContainer = nil;
				end
			end

			widgetFrame:SetParent(widgetContainerFrame);
		else
			-- This widget uses horizontal layout

			local forceNewRow = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.HorizontalForceNewRow;
			local needNewRowContainer = not horizontalRowContainer or forceNewRow;
			if needNewRowContainer then
				-- We either don't have a horizontalRowContainer or this widget has requested a new row be started
				if horizontalRowContainer then
					horizontalRowContainer:Layout();
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire();
				newHorizontalRowContainer:Show();

				if index == 1 then
					-- This is the first widget in the set, so just anchor it to the widget container
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint);
				else
					-- This is not the first widget in the set, so anchor it to the previous widget (or the horizontalRowContainer if that exists)
					local relative = horizontalRowContainer or sortedWidgets[index - 1];
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset);
				end
				widgetFrame:SetPoint("TOPLEFT", newHorizontalRowContainer);
				widgetFrame:SetParent(newHorizontalRowContainer);

				-- The old horizontalRowContainer is no longer needed for anchoring, so set it to newHorizontalRowContainer
				horizontalRowContainer = newHorizontalRowContainer;
			else
				-- horizontalRowContainer already existed, so we just keep going in it, anchoring to the previous widget
				local relative = sortedWidgets[index - 1];
				widgetFrame:SetParent(horizontalRowContainer);
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0);
			end
		end
	end
end
