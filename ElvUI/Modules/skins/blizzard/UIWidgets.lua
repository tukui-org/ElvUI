local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:
local function BelowMinimapContainer()
	local container = _G["UIWidgetBelowMinimapContainerFrame"]
	local holder = CreateFrame('Frame', 'BelowMinimapContainerHolder', UIParent)
	holder:Point("TOPRIGHT", _G["MinimapCluster"], "BOTTOMRIGHT", 0, -16)
	holder:Size(128, 40)

	container:ClearAllPoints()
	container:Point('CENTER', holder, 'CENTER')
	container:SetParent(holder)
	container.ignoreFramePositionManager = true

	--Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= holder:GetWidth() then holder:Width(widgetContainer:GetWidth()) end
	end)
	--And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(container, "ClearAllPoints", function(self)
		self:SetPoint('CENTER', holder, 'CENTER')
	end)

	E:CreateMover(holder, 'BelowMinimapContainerMover', L["BelowMinimapContainer"])
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.UIWidgets ~= true then return end

	-- TO DO: Fill me with love

	BelowMinimapContainer()
end

S:AddCallbackForAddon("Blizzard_UIWidgets", "Widgets", LoadSkin)