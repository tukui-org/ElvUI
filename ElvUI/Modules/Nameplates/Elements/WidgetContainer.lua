local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local ipairs = ipairs

function NP:Construct_WidgetContainer(nameplate)
	local WidgetContainer = CreateFrame('Frame', nil, nameplate, 'UIWidgetContainerTemplate')
	WidgetContainer:Hide()
	WidgetContainer:SetPoint('BOTTOM', nameplate, 'TOP')

	return WidgetContainer
end

function NP.Widget_DefaultLayout(widgetContainerFrame, sortedWidgets)
	local horizontalRowContainer = nil
	local horizontalRowHeight = 0
	local horizontalRowWidth = 0
	local totalWidth = 0
	local totalHeight = 0

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll()

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints()

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == Enum.UIWidgetSetLayoutDirection.Vertical
		local widgetUsesVertical = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Vertical

		local useOverlapLayout = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Overlap
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Default and widgetSetUsesVertical)

		if useOverlapLayout then
			-- This widget uses overlap layout

			if index == 1 then
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, widgetContainerFrame)
				end
			else
				local relative = sortedWidgets[index - 1]
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalAnchorPoint, 0, 0)
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalAnchorPoint, 0, 0)
				end
			end

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			if height > totalHeight then
				totalHeight = height
			end

			widgetFrame:SetParent(widgetContainerFrame)
		elseif useVerticalLayout then
			if index == 1 then
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
			else
				local relative = horizontalRowContainer or sortedWidgets[index - 1]
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

				if horizontalRowContainer then
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
					horizontalRowContainer = nil
				end

				totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
			end

			widgetFrame:SetParent(widgetContainerFrame)

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			totalHeight = totalHeight + height
		else
			local forceNewRow = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.HorizontalForceNewRow
			local needNewRowContainer = not horizontalRowContainer or forceNewRow
			if needNewRowContainer then
				if horizontalRowContainer then
					--horizontalRowContainer:Layout()
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire()
				newHorizontalRowContainer:Show()

				if index == 1 then
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint)
				else
					local relative = horizontalRowContainer or sortedWidgets[index - 1]
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

					totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
				end
				widgetFrame:SetPoint('TOPLEFT', newHorizontalRowContainer)
				widgetFrame:SetParent(newHorizontalRowContainer)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth()
				horizontalRowContainer = newHorizontalRowContainer
			else
				local relative = sortedWidgets[index - 1]
				widgetFrame:SetParent(horizontalRowContainer)
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth() + widgetContainerFrame.horizontalAnchorXOffset
			end

			local widgetHeight = widgetFrame:GetHeight()
			if widgetHeight > horizontalRowHeight then
				horizontalRowHeight = widgetHeight
			end
		end
	end

	if horizontalRowContainer then
		horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
		totalWidth = totalWidth + horizontalRowWidth
		totalHeight = totalHeight + horizontalRowHeight
		horizontalRowHeight = 0
		horizontalRowWidth = 0
	end

	widgetContainerFrame:SetSize(totalWidth, totalHeight)
end
