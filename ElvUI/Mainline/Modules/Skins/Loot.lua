local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

local function LootHistoryElements(frame)
	if not frame then return end

	frame:StripTextures()
	frame:SetTemplate('Transparent')

	S:HandleIcon(frame.Item.icon, true)
	S:HandleIconBorder(frame.Item.IconBorder, frame.Item.icon.backdrop)
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
		local c = ITEM_QUALITY_COLORS[_G.LootFrame.selectedQuality]

		local texture = icon:GetTexture() -- keep before strip textures
		item:StripTextures()
		item:SetTemplate()
		item:SetBackdropBorderColor(c.r, c.g, c.b)

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

	local hoist = frame.BlackBackgroundHoist
	if hoist and hoist.backdrop then
		hoist.backdrop:SetFrameLevel(BonusRollFrameLevel+1)
	end

	-- set currency icons position at bottom right (or left of the spec icon, on the bottom right)
	frame.CurrentCountFrame:ClearAllPoints()

	local specIcon = frame.SpecIcon
	if specIcon.backdrop then
		specIcon.backdrop:SetShown(specIcon:IsShown() and specIcon:GetTexture() ~= nil)

		if specIcon.backdrop:IsShown() then
			frame.CurrentCountFrame:Point('RIGHT', specIcon.backdrop, 'LEFT', -2, -2)
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

local function SpecIconHide(specIcon)
	if specIcon.backdrop and specIcon.backdrop:IsShown() then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
		specIcon.backdrop:Hide()
	end
end

local function SpecIconShow(specIcon)
	if specIcon.backdrop and not specIcon.backdrop:IsShown() and specIcon:GetTexture() ~= nil then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('RIGHT', frame.SpecIcon.backdrop, 'LEFT', -2, -2)
		specIcon.backdrop:Show()
	end
end

function S:LootFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.loot) then return end

	local LootFrame = _G.LootFrame
	LootFrame:StripTextures()
	LootFrame:SetTemplate('Transparent')
	S:HandleCloseButton(LootFrame.ClosePanelButton)
	hooksecurefunc(LootFrame.ScrollBox, 'Update', LootFrameUpdate)

	if LootFrame.Bg then
		LootFrame.Bg:SetAlpha(0)
	end

	-- Loot history frame
	local LootHistoryFrame = _G.GroupLootHistoryFrame
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate('Transparent')

	S:HandleCloseButton(LootHistoryFrame.ClosePanelButton)
	S:HandleDropDownBox(LootHistoryFrame.EncounterDropDown)
	S:HandleTrimScrollBar(LootHistoryFrame.ScrollBar)
	hooksecurefunc(_G.LootHistoryElementMixin, 'OnShow', LootHistoryElements) -- OnShow is the only hook that seems to do anything

	local resize = LootHistoryFrame.ResizeButton
	if resize then
		resize:StripTextures()
		resize:SetTemplate()
		resize:ClearAllPoints()
		resize:Point('TOP', LootHistoryFrame, 'BOTTOM', 0, -2)
		resize:Size(LootHistoryFrame:GetWidth(), 19)

		resize.text = resize:CreateFontString(nil, 'OVERLAY')
		resize.text:FontTemplate(nil, 16, 'OUTLINE')
		resize.text:SetJustifyH('CENTER')
		resize.text:Point('CENTER', resize)
		resize.text:SetText('v v v v')
	end

	-- Master Loot
	local MasterLooterFrame = _G.MasterLooterFrame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate()
	hooksecurefunc('MasterLooterFrame_Show', MasterLooterShow)

	-- Bonus Roll Frame
	local BonusRollFrame = _G.BonusRollFrame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate('Transparent')
	BonusRollFrame.SpecRing:SetTexture()
	BonusRollFrame.CurrentCountFrame.Text:FontTemplate()
	hooksecurefunc('BonusRollFrame_StartBonusRoll', StartBonusRoll)

	local prompt = BonusRollFrame.PromptFrame
	prompt.IconBackdrop = CreateFrame('Frame', nil, prompt)
	prompt.IconBackdrop:SetFrameLevel(prompt.IconBackdrop:GetFrameLevel() - 1)
	prompt.IconBackdrop:SetOutside(prompt.Icon)
	prompt.IconBackdrop:SetTemplate()
	prompt.Icon:SetTexCoord(unpack(E.TexCoords))

	prompt.Timer:SetStatusBarTexture(E.media.normTex)
	prompt.Timer:SetStatusBarColor(unpack(E.media.rgbvaluecolor))

	local hoist = BonusRollFrame.BlackBackgroundHoist
	if hoist then
		hoist.Background:Hide()
		hoist.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
		hoist.backdrop:SetTemplate()
		hoist.backdrop:SetOutside(prompt.Timer)
	end

	local specIcon = BonusRollFrame.SpecIcon
	if specIcon then
		specIcon.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
		specIcon.backdrop:SetTemplate()
		specIcon.backdrop:Point('BOTTOMRIGHT', BonusRollFrame, -2, 2)
		specIcon.backdrop:Size(specIcon:GetSize())
		specIcon.backdrop:SetFrameLevel(6)

		specIcon:SetParent(specIcon.backdrop)
		specIcon:SetTexCoord(unpack(E.TexCoords))
		specIcon:SetInside()

		hooksecurefunc(specIcon, 'Hide', SpecIconHide)
		hooksecurefunc(specIcon, 'Show', SpecIconShow)
	end
end

S:AddCallback('LootFrame')
