local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetTradeSkillNumReagents = GetTradeSkillNumReagents
local GetTradeSkillInfo = GetTradeSkillInfo
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local GetItemQualityByID = C_Item.GetItemQualityByID

local function SetSelection(id)
	local _, skillType = GetTradeSkillInfo(id)
	if skillType == 'header' then return end

	local TradeSkillSkillIcon = _G.TradeSkillSkillIcon
	local normal = TradeSkillSkillIcon:GetNormalTexture()
	if normal then -- cleared when the recipe has no icon
		S:HandleIcon(normal)
	end

	local skillLink = GetTradeSkillItemLink(id)
	if skillLink then
		local quality = GetItemQualityByID(skillLink)
		if quality and quality > 1 then
			local r, g, b = E:GetItemQualityColor(quality)

			TradeSkillSkillIcon.backdrop:SetBackdropBorderColor(r, g, b)
			_G.TradeSkillSkillName:SetTextColor(r, g, b)
		else
			TradeSkillSkillIcon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			_G.TradeSkillSkillName:SetTextColor(1, 1, 1)
		end
	end

	local numReagents = GetTradeSkillNumReagents(id)
	for i = 1, numReagents do
		local reagentLink = GetTradeSkillReagentItemLink(id, i)
		if reagentLink then
			local reagent = _G['TradeSkillReagent'..i]
			local quality = GetItemQualityByID(reagentLink)

			if quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				reagent.Icon.backdrop:SetBackdropBorderColor(r, g, b)

				local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
				if playerReagentCount < reagentCount then
					reagent.Name:SetTextColor(0.5, 0.5, 0.5)
				else
					reagent.Name:SetTextColor(r, g, b)
				end
			else
				reagent.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end
end

function S:Blizzard_TradeSkillUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local TradeSkillFrame = _G.TradeSkillFrame
	S:HandleFrame(TradeSkillFrame, true, nil, 11, -12, -32, 76)

	_G.TradeSkillRankFrameBorder:StripTextures()
	_G.TradeSkillDetailScrollFrame:StripTextures()
	_G.TradeSkillListScrollFrame:StripTextures()
	_G.TradeSkillDetailScrollChildFrame:StripTextures()

	_G.TradeSkillFrameBottomLeftTexture:Kill()
	_G.TradeSkillFrameBottomRightTexture:Kill()

	local TradeSkillRankFrame = _G.TradeSkillRankFrame
	TradeSkillRankFrame:Size(314, 14)
	TradeSkillRankFrame:Point('TOPLEFT', 25, -36)
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(TradeSkillRankFrame)

	local TradeSkillFrameEditBox = _G.TradeSkillFrameEditBox
	S:HandleEditBox(TradeSkillFrameEditBox)
	TradeSkillFrameEditBox:ClearAllPoints()
	TradeSkillFrameEditBox:Point('TOPLEFT', TradeSkillFrame, 'TOPLEFT', 28, -16)
	TradeSkillFrameEditBox:Size(122, 18)

	_G.TradeSkillExpandButtonFrame:StripTextures()

	local TradeSkillCollapseAllButton = _G.TradeSkillCollapseAllButton
	local collapseNormal = TradeSkillCollapseAllButton:GetNormalTexture()
	collapseNormal:SetPoint('LEFT', 3, 2)
	collapseNormal:Size(15)

	TradeSkillCollapseAllButton:SetHighlightTexture(E.ClearTexture)
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture(E.Media.Textures.MinusButton)
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop

	local collapseDisabled = TradeSkillCollapseAllButton:GetDisabledTexture()
	collapseDisabled:SetPoint('LEFT', 3, 2)
	collapseDisabled:Size(15)
	collapseDisabled:SetDesaturated(true)

	S:HandleDropDownBox(TradeSkillFrame.InvSlotDropdown, 120)
	S:HandleDropDownBox(TradeSkillFrame.SubClassDropdown, 120)

	_G.TradeSkillFrameTitleText:ClearAllPoints()
	_G.TradeSkillFrameTitleText:Point('TOP', TradeSkillFrame, 'TOP', 0, -18)

	local TradeSkillFrameAvailableFilterCheckButton = _G.TradeSkillFrameAvailableFilterCheckButton
	S:HandleCheckBox(TradeSkillFrameAvailableFilterCheckButton)
	TradeSkillFrameAvailableFilterCheckButton:Point('TOPLEFT', 20, -49)

	for i = 1, _G.TRADE_SKILLS_DISPLAYED do
		local button = _G['TradeSkillSkill'..i]

		S:HandleCollapseTexture(button, nil, true)

		local normal = button:GetNormalTexture()
		normal:Size(14)
		normal:SetPoint('LEFT', 2, 1)

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.ClearTexture)
		highlight.SetTexture = E.noop
	end

	S:HandleCollapseTexture(TradeSkillCollapseAllButton, nil, true)
	S:HandleScrollBar(_G.TradeSkillListScrollFrameScrollBar)
	S:HandleScrollBar(_G.TradeSkillDetailScrollFrameScrollBar)

	_G.TradeSkillSkillIcon:Size(40)
	_G.TradeSkillSkillIcon:Point('TOPLEFT', 2, -3)

	for i = 1, _G.MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G['TradeSkillReagent'..i]
		S:HandleIcon(reagent.Icon, true)
		reagent.Icon:SetDrawLayer('OVERLAY')
		reagent.Count:SetDrawLayer('OVERLAY')
		reagent.NameFrame:SetAlpha(0)
	end

	_G.TradeSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	_G.TradeSkillHighlight:SetAlpha(0.3)

	S:HandleButton(_G.TradeSkillCancelButton)
	S:HandleButton(_G.TradeSkillCreateButton)
	S:HandleButton(_G.TradeSkillCreateAllButton)

	S:HandleNextPrevButton(_G.TradeSkillDecrementButton)
	_G.TradeSkillInputBox:Size(36, 16)
	S:HandleEditBox(_G.TradeSkillInputBox)
	S:HandleNextPrevButton(_G.TradeSkillIncrementButton)

	_G.TradeSkillSkillIcon:CreateBackdrop()

	hooksecurefunc('TradeSkillFrame_SetSelection', SetSelection)
end

S:AddCallbackForAddon('Blizzard_TradeSkillUI')
