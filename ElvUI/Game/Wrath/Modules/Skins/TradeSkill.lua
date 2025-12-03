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
	TradeSkillRankFrame:Size(314, 16)
	TradeSkillRankFrame:Point('TOPLEFT', 25, -44)
	TradeSkillRankFrame:CreateBackdrop()
	TradeSkillRankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(TradeSkillRankFrame)

	local TradeSkillFrameSearchBox = _G.TradeSkillFrameSearchBox
	S:HandleEditBox(TradeSkillFrameSearchBox)
	TradeSkillFrameSearchBox:ClearAllPoints()
	TradeSkillFrameSearchBox:Point('TOPLEFT', _G.TradeSkillRankFrame, 'TOPLEFT', 60, -28)
	TradeSkillFrameSearchBox:Size(122, 18)

	_G.TradeSkillExpandButtonFrame:StripTextures()

	local TradeSkillCollapseAllButton = _G.TradeSkillCollapseAllButton
	TradeSkillCollapseAllButton:GetNormalTexture():SetPoint('LEFT', 3, 2)
	TradeSkillCollapseAllButton:GetNormalTexture():Size(15)

	TradeSkillCollapseAllButton:SetHighlightTexture(E.ClearTexture)
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop

	TradeSkillCollapseAllButton:SetDisabledTexture(E.Media.Textures.MinusButton)
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop
	TradeSkillCollapseAllButton:GetDisabledTexture():SetPoint('LEFT', 3, 2)
	TradeSkillCollapseAllButton:GetDisabledTexture():Size(15)
	TradeSkillCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	S:HandleDropDownBox(_G.TradeSkillFrame.FilterDropdown)

	_G.TradeSkillFrameTitleText:ClearAllPoints()
	_G.TradeSkillFrameTitleText:Point('TOP', TradeSkillFrame, 'TOP', 0, -18)

	for i = 1, _G.TRADE_SKILLS_DISPLAYED do
		local button = _G['TradeSkillSkill'..i]

		S:HandleCollapseTexture(button, nil, true)

		local normal = button:GetNormalTexture()
		if normal then
			normal:Size(14)
			normal:SetPoint('LEFT', 2, 1)
		end

		local highlight = _G['TradeSkillSkill'..i..'Highlight']
		if highlight then
			highlight:SetTexture(E.ClearTexture)
			highlight.SetTexture = E.noop
		end

		local subSkillRankBar = _G['TradeSkillSkill'..i..'SubSkillRankBar']
		if subSkillRankBar then
			subSkillRankBar:StripTextures()
			subSkillRankBar:CreateBackdrop()
			subSkillRankBar:SetStatusBarTexture(E.media.normTex)
			subSkillRankBar:SetStatusBarColor(0.13, 0.35, 0.80)

			E:RegisterStatusBar(subSkillRankBar)
		end
	end

	S:HandleCollapseTexture(_G.TradeSkillCollapseAllButton, nil, true)
	S:HandleScrollBar(_G.TradeSkillListScrollFrameScrollBar)
	S:HandleScrollBar(_G.TradeSkillDetailScrollFrameScrollBar)

	_G.TradeSkillSkillIcon:Size(40)
	_G.TradeSkillSkillIcon:Point('TOPLEFT', 2, -3)

	for i = 1, _G.MAX_TRADE_SKILL_REAGENTS do
		local icon = _G['TradeSkillReagent'..i..'IconTexture']
		local count = _G['TradeSkillReagent'..i..'Count']
		local nameFrame = _G['TradeSkillReagent'..i..'NameFrame']

		S:HandleIcon(icon, true)
		icon:SetDrawLayer('OVERLAY')
		count:SetDrawLayer('OVERLAY')

		nameFrame:SetAlpha(0)
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

	S:HandleCloseButton(_G.TradeSkillFrameCloseButton, TradeSkillFrame.backdrop)

	_G.TradeSkillSkillIcon:CreateBackdrop()

	hooksecurefunc('TradeSkillFrame_SetSelection', function(id)
		local _, skillType = GetTradeSkillInfo(id)
		if skillType == 'header' then return end

		if _G.TradeSkillSkillIcon:GetNormalTexture() then
			S:HandleIcon(_G.TradeSkillSkillIcon:GetNormalTexture())
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = GetItemQualityByID(skillLink)
			if quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)

				_G.TradeSkillSkillIcon.backdrop:SetBackdropBorderColor(r, g, b)
				_G.TradeSkillSkillName:SetTextColor(r, g, b)
			else
				_G.TradeSkillSkillIcon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				_G.TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		for i = 1, GetTradeSkillNumReagents(id) do
			local _, _, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)

			if reagentLink then
				local icon = _G['TradeSkillReagent'..i..'IconTexture']
				local quality = GetItemQualityByID(reagentLink)

				if quality and quality > 1 then
					local name = _G['TradeSkillReagent'..i..'Name']
					local r, g, b = E:GetItemQualityColor(quality)

					icon.backdrop:SetBackdropBorderColor(r, g, b)

					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(r, g, b)
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_TradeSkillUI')
