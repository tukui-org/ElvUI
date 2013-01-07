
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'ATSWSkin'
local function SkinATSW(self)
	AS:SkinFrame(ATSWFrame)
	ATSWSkillIcon:StripTextures(True)
	ATSWListScrollFrame:StripTextures(True)
	ATSWExpandButtonFrame:StripTextures(True)
	ATSWRankFrameBorder:StripTextures(True)
	AS:SkinStatusBar(ATSWRankFrame)
	ATSWRankFrame:Size(398,20)
	ATSWRankFrame:ClearAllPoints()
	ATSWRankFrame:Point("CENTER", ATSWFrame, "CENTER", 165, 200)
	ATSWListScrollFrame:Width(280)
	ATSWFramePortrait:Kill()
	S:HandleScrollBar(ATSWListScrollFrameScrollBar)
	ATSWListScrollFrameScrollBar:Point("CENTER", ATSWListScrollFrame, "CENTER", 0, 0)

	ATSWFrame.bg1 = CreateFrame("Frame", nil, ATSWFrame)
	ATSWFrame.bg1:CreateBackdrop()
	ATSWFrame.bg1:Point("TOPLEFT", 22, -72)
	ATSWFrame.bg1:Point("BOTTOMRIGHT", -439, 20)

	ATSWFrame.bg2 = CreateFrame("Frame", nil, ATSWFrame)
	ATSWFrame.bg2:CreateBackdrop()
	ATSWFrame.bg2:Point("TOPLEFT", 350, -72)
	ATSWFrame.bg2:Point("BOTTOMRIGHT", -20, 20)

	S:HandleEditBox(ATSWFilterBox)
	S:HandleEditBox(ATSWInputBox)
	S:HandleEditBox(ATSWCSNewCategoryBox)
	ATSWFilterBox:ClearAllPoints()
	ATSWFilterBox:Point("TOPLEFT", ATSWFrame, "TOPLEFT", 120, -98)
	ATSWFilterBox:Width(188)

	S:HandleDropDownBox(ATSWSubClassDropDown)
	S:HandleDropDownBox(ATSWInvSlotDropDown)
	ATSWSubClassDropDown:ClearAllPoints()
	ATSWInvSlotDropDown:ClearAllPoints()
	ATSWSubClassDropDown:Point("TOPLEFT", ATSWFrame, "TOPLEFT", 50, -70)
	ATSWInvSlotDropDown:Point("RIGHT", ATSWSubClassDropDown, "RIGHT", 132, 0)

	S:HandleButton(ATSWQueueAllButton)
	S:HandleButton(ATSWCreateAllButton)
	S:HandleButton(ATSWCreateButton)
	S:HandleButton(ATSWQueueButton)
	S:HandleButton(ATSWQueueStartStopButton)
	S:HandleButton(ATSWQueueDeleteButton)
	S:HandleButton(ATSWReagentsButton)
	S:HandleButton(ATSWOptionsButton)
	S:HandleButton(ATSWCSButton)
	S:HandleButton(ATSWBuyReagentsButton)
	S:HandleButton(ATSWOptionsFrameOKButton)
	S:HandleButton(ATSWAddCategoryButton)
	S:HandleCloseButton(ATSWFrameCloseButton)
	S:HandleCloseButton(ATSWReagentFrameCloseButton)
	ATSWOptionsButton:ClearAllPoints()
	ATSWIncrementButton:ClearAllPoints()
	ATSWDecrementButton:ClearAllPoints()
	ATSWQueueAllButton:ClearAllPoints()
	ATSWQueueButton:ClearAllPoints()
	ATSWCreateButton:ClearAllPoints()
	ATSWQueueDeleteButton:ClearAllPoints()
	ATSWReagentsButton:ClearAllPoints()
	ATSWCSButton:Point("LEFT", ATSWCustomSortButton, "RIGHT", 0, -20)
	ATSWOptionsButton:Point("TOPRIGHT", ATSWFrame, "TOPRIGHT", -20, -72)
	ATSWQueueAllButton:Point("BOTTOMLEFT", ATSWFrame, "BOTTOMRIGHT", -418, 152)
	ATSWCreateAllButton:Point("RIGHT", ATSWQueueAllButton, "RIGHT", 80, 0)
	ATSWDecrementButton:Point("RIGHT", ATSWQueueAllButton, "RIGHT", 106, 0)
	ATSWIncrementButton:Point("RIGHT", ATSWDecrementButton, "RIGHT", 52, 0)
	ATSWCreateButton:Point("RIGHT", ATSWQueueAllButton, "RIGHT", 248, 0)
	ATSWQueueButton:Point("RIGHT", ATSWQueueAllButton, "RIGHT", 322, 0)
	ATSWQueueButton:Width(70)
	ATSWQueueStartStopButton:Point("BOTTOMLEFT", ATSWFrame, "BOTTOMRIGHT", -418, 20)
	ATSWQueueDeleteButton:Point("RIGHT", ATSWQueueStartStopButton, "RIGHT", 124, 0)
	ATSWQueueDeleteButton:Width(120)
	ATSWReagentsButton:Width(120)
	ATSWReagentsButton:Point("RIGHT", ATSWQueueStartStopButton, "RIGHT", 248, 0)

	S:HandleCheckBox(ATSWHeaderSortButton)
	S:HandleCheckBox(ATSWNameSortButton)
	S:HandleCheckBox(ATSWDifficultySortButton)
	S:HandleCheckBox(ATSWCustomSortButton)
	S:HandleCheckBox(ATSWOnlyCreatableButton)
	S:HandleCheckBox(ATSWOFUnifiedCounterButton)
	S:HandleCheckBox(ATSWOFSeparateCounterButton)
	S:HandleCheckBox(ATSWOFIncludeBankButton)
	S:HandleCheckBox(ATSWOFIncludeAltsButton)
	S:HandleCheckBox(ATSWOFIncludeMerchantsButton)
	S:HandleCheckBox(ATSWOFAutoBuyButton)
	S:HandleCheckBox(ATSWOFTooltipButton)
	S:HandleCheckBox(ATSWOFShoppingListButton)
	S:HandleCheckBox(ATSWOFReagentListButton)
	ATSWCustomSortButton:ClearAllPoints()
	ATSWOnlyCreatableButton:ClearAllPoints()
	ATSWCustomSortButton:Point("RIGHT", ATSWHeaderSortButton, "RIGHT", 150, 0)
	ATSWOnlyCreatableButton:Point("TOPLEFT", ATSWFrame, "TOPRIGHT", -140, -100)
	ATSWHeaderSortButton:Point("TOPLEFT", ATSWFrame, "TOPLEFT", 20, -15)
	ATSWNameSortButton:Point("TOPLEFT", ATSWFrame, "TOPLEFT", 20, -49)
	ATSWDifficultySortButton:Point("TOPLEFT", ATSWFrame, "TOPLEFT", 20, -32)

	AS:SkinFrame(ATSWTradeskillTooltip)
	AS:SkinFrame(ATSWReagentFrame)
	AS:SkinFrame(ATSWOptionsFrame)

	AS:SkinFrame(ATSWCSFrame)
	ATSWCSUListScrollFrame:StripTextures(True)
	ATSWCSSListScrollFrame:StripTextures(True)

		local once = false
			for i=1, ATSW_MAX_TRADE_SKILL_REAGENTS do
				local button = _G["ATSWReagent"..i]
				local icon = _G["ATSWReagent"..i.."IconTexture"]
				local count = _G["ATSWReagent"..i.."Count"]

			icon:SetTexCoord(.08, .92, .08, .92)
			icon:SetDrawLayer("OVERLAY")

			if not icon.backdrop then
				icon.backdrop = CreateFrame("Frame", nil, button)
				icon.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
				icon.backdrop:SetTemplate("Default")
				icon.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
				icon.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
			end

			icon:SetParent(icon.backdrop)
			count:SetParent(icon.backdrop)
			count:SetDrawLayer("OVERLAY")

			if i > 2 and once == false then
			local point, anchoredto, point2, x, y = button:GetPoint()
			button:ClearAllPoints()
			button:Point(point, anchoredto, point2, x, y - .8)
		end

		_G["ATSWReagent"..i.."NameFrame"]:Kill()
	end

	S:HandleScrollBar(ATSWCSUListScrollFrameScrollBar)
	S:HandleScrollBar(ATSWCSSListScrollFrameScrollBar)
	S:HandleCloseButton(ATSWCSFrameCloseButton)

	for i = 1, 4 do
		S:HandleButton(_G["ATSWQueueItem"..i.."DeleteButton"])
	end

	ATSWQueueStartStopButton:Point("CENTER", ATSWFrame, "TOPLEFT", 425, -480)
	ATSWAddCategoryButton:Point("LEFT", ATSWCSNewCategoryBox, "RIGHT", 5, 0)
	ATSWFrameCloseButton:Point("TOPRIGHT", ATSWFrame, "TOPRIGHT", -5, -5)
	ATSWBuyReagentsButton:Point("CENTER", ATSWReagentFrame, "BOTTOMLEFT", 246, 50)
	ATSWQueueScrollFrame:StripTextures(True)
	ATSWQueueScrollFrame:Width(52)
	S:HandleScrollBar(ATSWQueueScrollFrameScrollBar)
	S:HandleNextPrevButton(ATSWIncrementButton)
	S:HandleNextPrevButton(ATSWDecrementButton)
	S:HandleButton(ATSWAutoBuyButton)

	AS:SkinFrame(ATSWShoppingListFrame)
	ATSWShoppingListFrame:Size(475,150)
	ATSWShoppingListFrame:ClearAllPoints()
	ATSWShoppingListFrame:Point("TOPLEFT", AuctionFrame, "BOTTOMRIGHT", -475, -1)
	S:HandleButton(ATSWSLCloseButton)
	ATSWSLCloseButton:ClearAllPoints()
	ATSWSLCloseButton:Point("TOPRIGHT", ATSWShoppingListFrame, "TOPRIGHT", -5, -5)
	ATSWSLScrollFrame:StripTextures(True)
	S:HandleScrollBar(ATSWSLScrollFrameScrollBar)

	S:HandleButton(ATSWScanDelayFrameSkipButton)
	S:HandleButton(ATSWScanDelayFrameAbortButton)
	AS:SkinFrame(ATSWScanDelayFrame)
	AS:SkinStatusBar(ATSWScanDelayFrameBar, true)
end

AS:RegisterSkin(name,SkinATSW)