local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local fullFillWidth = 234 -- picked by Blizzard in LootHistory.lua
local fullDropWidth = fullFillWidth + 30 -- some padding to let it match (via the skinning)

local function LootHistoryElements(button) -- headers and padding rows share the scroll box
	if button.IsSkinned then return end

	if button.BackgroundArtFrame then
		button.BackgroundArtFrame:StripTextures()
		button.BackgroundArtFrame:CreateBackdrop('Transparent')
	end

	if button.NameFrame then
		button.NameFrame:SetAlpha(0)
	end

	if button.BorderFrame then
		button.BorderFrame:SetAlpha(0)
	end

	local item = button.Item
	local icon = item and item.icon
	if item then
		item:StripTextures()
		S:HandleIcon(icon, true)
		S:HandleIconBorder(item.IconBorder, icon.backdrop)
	end

	button.IsSkinned = true
end

local function HandleScrollElements(frame)
	frame:ForEachFrame(LootHistoryElements)
end

local function LootFrameUpdateChild(button)
	local item = button.Item
	if item then
		if not item.backdrop then
			item:StyleButton()
			item.icon:SetInside(item)

			S:HandleIcon(item.icon, true)
		end

		if item.NormalTexture then item.NormalTexture:SetAlpha(0) end
		if item.IconBorder then item.IconBorder:SetAlpha(0) end

		if button.Text then -- icon border isn't updated for white/grey so pull color from the name
			local r, g, b = button.Text:GetVertexColor()
			item.icon.backdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	if button.NameFrame and not button.NameFrame.backdrop then
		button.NameFrame:StripTextures()
		button.NameFrame:CreateBackdrop('Transparent')
		button.NameFrame.backdrop:SetAllPoints()
		button.NameFrame.backdrop:SetFrameLevel(2)
	end

	if button.IconQuestTexture then button.IconQuestTexture:SetAlpha(0) end
	if button.BorderFrame then button.BorderFrame:SetAlpha(0) end
	if button.HighlightNameFrame then button.HighlightNameFrame:SetAlpha(0) end
	if button.PushedNameFrame then button.PushedNameFrame:SetAlpha(0) end

end

local function LootFrameUpdate(frame)
	frame:ForEachFrame(LootFrameUpdateChild)
end

local function MasterLooterShow()
	local looter = _G.MasterLooterFrame
	local item = looter.Item
	local icon = item.Icon
	local r, g, b = E:GetItemQualityColor(_G.LootFrame.selectedQuality or 1)

	local texture = icon:GetTexture() -- keep before strip textures
	item:StripTextures()
	item:SetTemplate()
	item:SetBackdropBorderColor(r, g, b)

	icon:SetTexture(texture)
	icon:SetTexCoords()

	for _, child in next, { looter:GetChildren() } do
		if not child.IsSkinned and not child:GetName() and child:IsObjectType('Button') then
			if child:GetPushedTexture() then
				S:HandleCloseButton(child)
			else
				child:SetTemplate()
				child:StyleButton()
			end

			child.IsSkinned = true
		end
	end
end

local function EncounterDropdownWidth(dropdown, width)
	if width ~= fullDropWidth then
		dropdown:SetWidth(fullDropWidth)
	end
end

function S:LootFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.loot) then return end

	local LootFrame = _G.LootFrame
	LootFrame:StripTextures()
	LootFrame:SetTemplate('Transparent')
	LootFrame.Bg:SetAlpha(0)
	S:HandleCloseButton(LootFrame.ClosePanelButton)
	hooksecurefunc(LootFrame.ScrollBox, 'Update', LootFrameUpdate)

	local HistoryFrame = _G.GroupLootHistoryFrame
	HistoryFrame:StripTextures()
	HistoryFrame:SetTemplate('Transparent')
	HistoryFrame.Bg:SetAlpha(0)

	local Dropdown = HistoryFrame.EncounterDropdown
	S:HandleDropDownBox(Dropdown)
	hooksecurefunc(Dropdown, 'SetWidth', EncounterDropdownWidth)
	Dropdown:ClearAllPoints()
	Dropdown:Point('TOP', -6, -32)

	local Timer = HistoryFrame.Timer
	Timer:StripTextures()
	Timer:CreateBackdrop('Transparent')
	Timer:SetWidth(fullFillWidth) -- dont use Width
	Timer:ClearAllPoints()
	Timer:Point('TOP', Dropdown, 'BOTTOM', 6, 2)

	Timer.Fill:SetTexture(E.media.normTex)
	Timer.Fill:SetVertexColor(unpack(E.media.rgbvaluecolor))
	Timer.Fill:ClearAllPoints()
	Timer.Fill:Point('LEFT', Timer.backdrop, 1, 0)

	S:HandleCloseButton(HistoryFrame.ClosePanelButton)
	S:HandleTrimScrollBar(HistoryFrame.ScrollBar)
	hooksecurefunc(HistoryFrame.ScrollBox, 'Update', HandleScrollElements)

	local LootResize = HistoryFrame.ResizeButton
	LootResize:StripTextures()
	LootResize:SetTemplate()
	LootResize:ClearAllPoints()
	LootResize:Point('TOP', HistoryFrame, 'BOTTOM', 0, -2)
	LootResize:Size(HistoryFrame:GetWidth(), 19)

	LootResize.text = LootResize:CreateFontString(nil, 'OVERLAY')
	LootResize.text:FontTemplate(nil, 16, 'OUTLINE')
	LootResize.text:SetJustifyH('CENTER')
	LootResize.text:Point('CENTER', LootResize)
	LootResize.text:SetText('v v v v')

	local MasterLooterFrame = _G.MasterLooterFrame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate()
	hooksecurefunc('MasterLooterFrame_Show', MasterLooterShow)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'LootFrame')
