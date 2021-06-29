local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LBG = E.Libs.ButtonGlow

local _G = _G
local unpack, select = unpack, select

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetLootSlotInfo = GetLootSlotInfo
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local IsFishingLoot = IsFishingLoot
local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LOOT, ITEMS = LOOT, ITEMS

local function UpdateLoots()
	local numItems = C_LootHistory_GetNumItems()
	for i=1, numItems do
		local frame = _G.LootHistoryFrame.itemFrames[i]
		if frame and not frame.isSkinned then
			local Icon = frame.Icon:GetTexture()
			frame:StripTextures()
			frame.Icon:SetTexture(Icon)
			frame.Icon:SetTexCoord(unpack(E.TexCoords))

			-- create a backdrop around the icon
			frame:CreateBackdrop()
			frame.backdrop:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.backdrop)

			frame.isSkinned = true
		end
	end
end

function S:LootFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.loot) then return end

	-- Loot history frame
	local LootHistoryFrame = _G.LootHistoryFrame
	LootHistoryFrame:StripTextures()
	S:HandleCloseButton(LootHistoryFrame.CloseButton)
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate('Transparent')
	LootHistoryFrame.ResizeButton:StripTextures()
	LootHistoryFrame.ResizeButton.text = LootHistoryFrame.ResizeButton:CreateFontString(nil, 'OVERLAY')
	LootHistoryFrame.ResizeButton.text:FontTemplate(nil, 16, 'OUTLINE')
	LootHistoryFrame.ResizeButton.text:SetJustifyH('CENTER')
	LootHistoryFrame.ResizeButton.text:Point('CENTER', LootHistoryFrame.ResizeButton)
	LootHistoryFrame.ResizeButton.text:SetText('v v v v')
	LootHistoryFrame.ResizeButton:SetTemplate()
	LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
	LootHistoryFrame.ResizeButton:Height(19)
	LootHistoryFrame.ResizeButton:ClearAllPoints()
	LootHistoryFrame.ResizeButton:Point('TOP', LootHistoryFrame, 'BOTTOM', 0, -2)
	_G.LootHistoryFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.LootHistoryFrameScrollFrameScrollBar)

	hooksecurefunc('LootHistoryFrame_FullUpdate', UpdateLoots)

	-- Master Loot
	local MasterLooterFrame = _G.MasterLooterFrame
	MasterLooterFrame:StripTextures()
	MasterLooterFrame:SetTemplate()

	hooksecurefunc('MasterLooterFrame_Show', function()
		local b = MasterLooterFrame.Item
		if b then
			local i = b.Icon
			local icon = i:GetTexture()
			local c = ITEM_QUALITY_COLORS[_G.LootFrame.selectedQuality]

			i:SetTexture(icon)
			i:SetTexCoord(unpack(E.TexCoords))

			b:StripTextures()
			b:SetTemplate()
			b:SetBackdropBorderColor(c.r, c.g, c.b)
		end

		for i=1, MasterLooterFrame:GetNumChildren() do
			local child = select(i, MasterLooterFrame:GetChildren())
			if child and not child.isSkinned and not child:GetName() then
				if child:IsObjectType('Button') then
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
	end)

	-- Bonus Roll Frame
	local BonusRollFrame = _G.BonusRollFrame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate('Transparent')

	BonusRollFrame.SpecRing:SetTexture()
	BonusRollFrame.CurrentCountFrame.Text:FontTemplate()

	BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.PromptFrame.IconBackdrop = CreateFrame('Frame', nil, BonusRollFrame.PromptFrame)
	BonusRollFrame.PromptFrame.IconBackdrop:SetFrameLevel(BonusRollFrame.PromptFrame.IconBackdrop:GetFrameLevel() - 1)
	BonusRollFrame.PromptFrame.IconBackdrop:SetOutside(BonusRollFrame.PromptFrame.Icon)
	BonusRollFrame.PromptFrame.IconBackdrop:SetTemplate()

	BonusRollFrame.PromptFrame.Timer:SetStatusBarTexture(E.media.normTex)
	BonusRollFrame.PromptFrame.Timer:SetStatusBarColor(unpack(E.media.rgbvaluecolor))

	BonusRollFrame.BlackBackgroundHoist.Background:Hide()
	BonusRollFrame.BlackBackgroundHoist.b = CreateFrame('Frame', nil, BonusRollFrame)
	BonusRollFrame.BlackBackgroundHoist.b:SetTemplate()
	BonusRollFrame.BlackBackgroundHoist.b:SetOutside(BonusRollFrame.PromptFrame.Timer)

	BonusRollFrame.SpecIcon.b = CreateFrame('Frame', nil, BonusRollFrame)
	BonusRollFrame.SpecIcon.b:SetTemplate()
	BonusRollFrame.SpecIcon.b:Point('BOTTOMRIGHT', BonusRollFrame, -2, 2)
	BonusRollFrame.SpecIcon.b:Size(BonusRollFrame.SpecIcon:GetSize())
	BonusRollFrame.SpecIcon.b:SetFrameLevel(6)
	BonusRollFrame.SpecIcon:SetParent(BonusRollFrame.SpecIcon.b)
	BonusRollFrame.SpecIcon:SetTexCoord(unpack(E.TexCoords))
	BonusRollFrame.SpecIcon:SetInside()
	hooksecurefunc(BonusRollFrame.SpecIcon, 'Hide', function(specIcon)
		if specIcon.b and specIcon.b:IsShown() then
			BonusRollFrame.CurrentCountFrame:ClearAllPoints()
			BonusRollFrame.CurrentCountFrame:Point('BOTTOMRIGHT', BonusRollFrame, -2, 1)
			specIcon.b:Hide()
		end
	end)
	hooksecurefunc(BonusRollFrame.SpecIcon, 'Show', function(specIcon)
		if specIcon.b and not specIcon.b:IsShown() and specIcon:GetTexture() ~= nil then
			BonusRollFrame.CurrentCountFrame:ClearAllPoints()
			BonusRollFrame.CurrentCountFrame:Point('RIGHT', BonusRollFrame.SpecIcon.b, 'LEFT', -2, -2)
			specIcon.b:Show()
		end
	end)

	hooksecurefunc('BonusRollFrame_StartBonusRoll', function()
		--keep the status bar a frame above but its increased 1 extra beacuse mera has a grid layer
		local BonusRollFrameLevel = BonusRollFrame:GetFrameLevel()
		BonusRollFrame.PromptFrame.Timer:SetFrameLevel(BonusRollFrameLevel+2)
		if BonusRollFrame.BlackBackgroundHoist.b then
			BonusRollFrame.BlackBackgroundHoist.b:SetFrameLevel(BonusRollFrameLevel+1)
		end

		--set currency icons position at bottom right (or left of the spec icon, on the bottom right)
		BonusRollFrame.CurrentCountFrame:ClearAllPoints()
		if BonusRollFrame.SpecIcon.b then
			BonusRollFrame.SpecIcon.b:SetShown(BonusRollFrame.SpecIcon:IsShown() and BonusRollFrame.SpecIcon:GetTexture() ~= nil)
			if BonusRollFrame.SpecIcon.b:IsShown() then
				BonusRollFrame.CurrentCountFrame:Point('RIGHT', BonusRollFrame.SpecIcon.b, 'LEFT', -2, -2)
			else
				BonusRollFrame.CurrentCountFrame:Point('BOTTOMRIGHT', BonusRollFrame, -2, 1)
			end
		else
			BonusRollFrame.CurrentCountFrame:Point('BOTTOMRIGHT', BonusRollFrame, -2, 1)
		end

		--skin currency icons
		local ccf, pfifc = BonusRollFrame.CurrentCountFrame.Text, BonusRollFrame.PromptFrame.InfoFrame.Cost
		local text1, text2 = ccf and ccf:GetText(), pfifc and pfifc:GetText()
		if text1 and text1:find('|t') then ccf:SetText(text1:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
		if text2 and text2:find('|t') then pfifc:SetText(text2:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
	end)

	local LootFrame = _G.LootFrame
	S:HandlePortraitFrame(LootFrame)
	LootFrame:Height(LootFrame:GetHeight() - 30)
	_G.LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	for i=1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:IsObjectType('FontString') then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point('TOPLEFT', LootFrame, 'TOPLEFT', 4, -4)
	LootFrame.Title:SetJustifyH('LEFT')

	for i=1, _G.LOOTFRAME_NUMBUTTONS do
		local button = _G['LootButton'..i]
		_G['LootButton'..i..'NameFrame']:Hide()
		_G['LootButton'..i..'IconQuestTexture']:SetParent(E.HiddenFrame)
		S:HandleItemButton(button, true)
		S:HandleIconBorder(button.IconBorder)

		local point, attachTo, point2, x, y = button:GetPoint()
		button:ClearAllPoints()
		button:Point(point, attachTo, point2, x, y+30)
	end

	hooksecurefunc('LootFrame_UpdateButton', function(index)
		local numLootItems = LootFrame.numLootItems
		--Logic to determine how many items to show per page
		local numLootToShow = _G.LOOTFRAME_NUMBUTTONS
		if LootFrame.AutoLootTable then
			numLootItems = #LootFrame.AutoLootTable
		end
		if numLootItems > _G.LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1 -- make space for the page buttons
		end

		local button = _G['LootButton'..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index
		if button and button:IsShown() then
			local texture, _, isQuestItem, questId, isActive
			if LootFrame.AutoLootTable then
				local entry = LootFrame.AutoLootTable[slot]
				if entry.hide then
					button:Hide()
					return
				else
					texture = entry.texture
					isQuestItem = entry.isQuestItem
					questId = entry.questId
					isActive = entry.isActive
				end
			else
				texture, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
			end

			if texture then
				if questId and not isActive then
					LBG.ShowOverlayGlow(button)
				elseif questId or isQuestItem then
					LBG.ShowOverlayGlow(button)
				else
					LBG.HideOverlayGlow(button)
				end
			end
		end
	end)

	LootFrame:HookScript('OnShow', function(s)
		if IsFishingLoot() then
			s.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
			s.Title:SetText(UnitName('target'))
		else
			s.Title:SetText(LOOT)
		end
	end)

	S:HandleNextPrevButton(_G.LootFrameDownButton)
	S:HandleNextPrevButton(_G.LootFrameUpButton)
end

S:AddCallback('LootFrame')
