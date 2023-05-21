local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

local fullFillWidth = 234 -- picked by Blizzard in LootHistory.lua
local fullDropWidth = fullFillWidth + 30 -- some padding to let it match (via the skinning)

local function LootHistoryElements(button)
	if button.IsSkinned then return end

	if button.NameFrame then
		button.NameFrame:SetAlpha(0)
	end

	if button.BorderFrame then
		button.BorderFrame:SetAlpha(0)
		button.BorderFrame:CreateBackdrop('Transparent')
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

local function HandleScrollElements(box)
	if box then
		box:ForEachFrame(LootHistoryElements)
	end
end

local function LootFrameUpdate(frame)
	for _, button in next, { frame.ScrollTarget:GetChildren() } do
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
end

local function MasterLooterShow()
	local looter = _G.MasterLooterFrame
	local item = looter.Item
	if item then
		local icon = item.Icon
		local color = ITEM_QUALITY_COLORS[_G.LootFrame.selectedQuality or 1]

		local texture = icon:GetTexture() -- keep before strip textures
		item:StripTextures()
		item:SetTemplate()
		item:SetBackdropBorderColor(color.r, color.g, color.b)

		icon:SetTexture(texture)
		icon:SetTexCoord(unpack(E.TexCoords))
	end

	for _, child in next, { looter:GetChildren() } do
		if not child.isSkinned and not child:GetName() and child:IsObjectType('Button') then
			if child:GetPushedTexture() then
				S:HandleCloseButton(child)
			else
				child:SetTemplate()
				child:StyleButton()
			end

			child.isSkinned = true
		end
	end
end

local function StartBonusRoll()
	local frame = _G.BonusRollFrame

	-- keep the status bar a frame above but its increased 1 extra beacuse mera has a grid layer
	local BonusRollFrameLevel = frame:GetFrameLevel()
	frame.PromptFrame.Timer:SetFrameLevel(BonusRollFrameLevel+2)

	local bonusHoist = frame.BlackBackgroundHoist
	if bonusHoist and bonusHoist.backdrop then
		bonusHoist.backdrop:SetFrameLevel(BonusRollFrameLevel+1)
	end

	-- set currency icons position at bottom right (or left of the spec icon, on the bottom right)
	frame.CurrentCountFrame:ClearAllPoints()

	local bonusSpecIcon = frame.SpecIcon
	if bonusSpecIcon.backdrop then
		bonusSpecIcon.backdrop:SetShown(bonusSpecIcon:IsShown() and bonusSpecIcon:GetTexture() ~= nil)

		if bonusSpecIcon.backdrop:IsShown() then
			frame.CurrentCountFrame:Point('RIGHT', bonusSpecIcon.backdrop, 'LEFT', -2, -2)
		else
			frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
		end
	else
		frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
	end

	-- skin currency icons
	local ccf, pfifc = frame.CurrentCountFrame.Text, frame.PromptFrame.InfoFrame.Cost
	local text1, text2 = ccf and ccf:GetText(), pfifc and pfifc:GetText()
	if text1 and text1:find('|t') then ccf:SetText(text1:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
	if text2 and text2:find('|t') then pfifc:SetText(text2:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
end

local function SpecIconHide(bonusSpecIcon)
	if bonusSpecIcon.backdrop and bonusSpecIcon.backdrop:IsShown() then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
		bonusSpecIcon.backdrop:Hide()
	end
end

local function SpecIconShow(bonusSpecIcon)
	if bonusSpecIcon.backdrop and not bonusSpecIcon.backdrop:IsShown() and bonusSpecIcon:GetTexture() ~= nil then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('RIGHT', frame.SpecIcon.backdrop, 'LEFT', -2, -2)
		bonusSpecIcon.backdrop:Show()
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
	if LootFrame then
		LootFrame:StripTextures()
		LootFrame:SetTemplate('Transparent')
		S:HandleCloseButton(LootFrame.ClosePanelButton)
		hooksecurefunc(LootFrame.ScrollBox, 'Update', LootFrameUpdate)

		if LootFrame.Bg then
			LootFrame.Bg:SetAlpha(0)
		end
	end

	local HistoryFrame = _G.GroupLootHistoryFrame
	if HistoryFrame then
		HistoryFrame:StripTextures()
		HistoryFrame:SetTemplate('Transparent')

		if HistoryFrame.Bg then
			HistoryFrame.Bg:SetAlpha(0)
		end

		local Dropdown = HistoryFrame.EncounterDropDown
		if Dropdown then
			S:HandleDropDownBox(Dropdown)
			hooksecurefunc(Dropdown, 'SetWidth', EncounterDropdownWidth)

			Dropdown:ClearAllPoints()
			Dropdown:Point('TOP', -6, -32)
		end

		local Timer = HistoryFrame.Timer
		if Timer then
			Timer:StripTextures()
			Timer:CreateBackdrop('Transparent')
			Timer:SetWidth(fullFillWidth) -- dont use Width

			if Dropdown then
				Timer:ClearAllPoints()
				Timer:Point('TOP', Dropdown, 'BOTTOM', 6, 2)
			end

			if Timer.Fill then
				Timer.Fill:SetTexture(E.media.normTex)
				Timer.Fill:SetVertexColor(unpack(E.media.rgbvaluecolor))
				Timer.Fill:ClearAllPoints()
				Timer.Fill:Point('LEFT', Timer.backdrop, 1, 0)
			end
		end

		S:HandleCloseButton(HistoryFrame.ClosePanelButton)
		S:HandleTrimScrollBar(HistoryFrame.ScrollBar)
		hooksecurefunc(HistoryFrame.ScrollBox, 'Update', HandleScrollElements)

		local LootResize = HistoryFrame.ResizeButton
		if LootResize then
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
		end
	end

	local MasterLooterFrame = _G.MasterLooterFrame
	if MasterLooterFrame then
		MasterLooterFrame:StripTextures()
		MasterLooterFrame:SetTemplate()
		hooksecurefunc('MasterLooterFrame_Show', MasterLooterShow)
	end

	local BonusRollFrame = _G.BonusRollFrame
	if BonusRollFrame then
		BonusRollFrame:StripTextures()
		BonusRollFrame:SetTemplate('Transparent')
		BonusRollFrame.SpecRing:SetTexture()
		BonusRollFrame.CurrentCountFrame.Text:FontTemplate()
		hooksecurefunc('BonusRollFrame_StartBonusRoll', StartBonusRoll)

		local BonusPrompt = BonusRollFrame.PromptFrame
		BonusPrompt.IconBackdrop = CreateFrame('Frame', nil, BonusPrompt)
		BonusPrompt.IconBackdrop:SetFrameLevel(BonusPrompt.IconBackdrop:GetFrameLevel() - 1)
		BonusPrompt.IconBackdrop:SetOutside(BonusPrompt.Icon)
		BonusPrompt.IconBackdrop:SetTemplate()
		BonusPrompt.Icon:SetTexCoord(unpack(E.TexCoords))

		BonusPrompt.Timer:SetStatusBarTexture(E.media.normTex)
		BonusPrompt.Timer:SetStatusBarColor(unpack(E.media.rgbvaluecolor))

		local BonusHoist = BonusRollFrame.BlackBackgroundHoist
		if BonusHoist then
			BonusHoist.Background:Hide()
			BonusHoist.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
			BonusHoist.backdrop:SetTemplate()
			BonusHoist.backdrop:SetOutside(BonusPrompt.Timer)
		end

		local BonusSpecIcon = BonusRollFrame.SpecIcon
		if BonusSpecIcon then
			BonusSpecIcon.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
			BonusSpecIcon.backdrop:SetTemplate()
			BonusSpecIcon.backdrop:Point('BOTTOMRIGHT', BonusRollFrame, -2, 2)
			BonusSpecIcon.backdrop:Size(BonusSpecIcon:GetSize())
			BonusSpecIcon.backdrop:SetFrameLevel(6)

			BonusSpecIcon:SetParent(BonusSpecIcon.backdrop)
			BonusSpecIcon:SetTexCoord(unpack(E.TexCoords))
			BonusSpecIcon:SetInside()

			hooksecurefunc(BonusSpecIcon, 'Hide', SpecIconHide)
			hooksecurefunc(BonusSpecIcon, 'Show', SpecIconShow)
		end
	end
end

S:AddCallback('LootFrame')
