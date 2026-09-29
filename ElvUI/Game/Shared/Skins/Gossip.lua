local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local hooksecurefunc = hooksecurefunc

local GossipTextColors = {
	['000000'] = 'ffffff',
	['414141'] = '7b8489',
}

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'GossipFrame', nil, nil, nil, nil, 'gossip')

local function Gossip_SetTextColor(text, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

local function Gossip_ReplaceColor(color)
	return '|cFF' .. (GossipTextColors[color] or color)
end

local function Gossip_SetFormattedText(button, textFormat, text, skip)
	if skip or not text or text == '' then return end

	local colorText, colorCount = gsub(textFormat, '|c[fF][fF](%x%x%x%x%x%x)', Gossip_ReplaceColor)
	if colorCount > 0 then
		button:SetFormattedText(colorText, text, true)
	end
end

local function Gossip_SetText(button, text)
	if not text or text == '' then return end

	local startText = text

	local iconText, iconCount = gsub(text, ':32:32:0:0', ':32:32:0:0:64:64:5:59:5:59')
	if iconCount > 0 then text = iconText end

	local colorText, colorCount = gsub(text, '|c[fF][fF](%x%x%x%x%x%x)', Gossip_ReplaceColor)
	if colorCount > 0 then text = colorText end

	if startText ~= text then
		button:SetFormattedText('%s', text, true)
	end
end

local function ItemTextPage_SetTextColor(pageText, headerType, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		pageText:SetTextColor(headerType, 1, 1, 1)
	end
end

local function GreetingPanel_UpdateChild(button)
	if not button.IsSkinned then
		if button.GreetingText then
			button.GreetingText:SetTextColor(1, 1, 1)
			hooksecurefunc(button.GreetingText, 'SetTextColor', Gossip_SetTextColor)
		end

		local fontString = button.GetFontString and button:GetFontString()
		if fontString then
			fontString:SetTextColor(1, 1, 1)
			hooksecurefunc(fontString, 'SetTextColor', Gossip_SetTextColor)

			Gossip_SetText(button, button:GetText())
			hooksecurefunc(button, 'SetText', Gossip_SetText)
			hooksecurefunc(button, 'SetFormattedText', Gossip_SetFormattedText)
		end

		button.IsSkinned = true
	end
end

local function GreetingPanel_Update(frame)
	frame:ForEachFrame(GreetingPanel_UpdateChild)
end

local function GossipFrame_SetAtlas(frame)
	frame:Height(frame:GetHeight() - 2)
end

local function CreateParchment(frame)
	local tex = frame:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture([[Interface\QuestFrame\QuestBG]])
	tex:SetTexCoord(0, 0.586, 0.02, 0.655)
	return tex
end

function S:GossipFrame()
	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)

	if E.Modern then
		S:HandleTrimScrollBar(_G.ItemTextScrollFrame.ScrollBar)
	else
		S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)
	end

	S:HandleTrimScrollBar(_G.GossipFrame.GreetingPanel.ScrollBar)
	S:HandleButton(_G.GossipFrame.GreetingPanel.GoodbyeButton, true)
	S:HandleCloseButton(_G.ItemTextFrameCloseButton)

	S:HandleNextPrevButton(_G.ItemTextNextPageButton)
	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)

	for i = 1, 4 do
		local notch = GossipFrame.FriendshipStatusBar['Notch'..i]
		notch:SetColorTexture(0, 0, 0)
		notch:SetSize(E.mult, 16)
	end

	-- titan keeps the frame border in a child frame
	if E.Wrath then
		_G.ItemTextFrame.BorderTexture:SetAlpha(0)
	end

	if E.private.skins.parchmentRemoverEnable then
		_G.ItemTextFrame:StripTextures(true)
		_G.ItemTextFrame:SetTemplate('Transparent')
		_G.ItemTextScrollFrame:StripTextures()

		_G.GossipFrameInset:Hide()
		_G.QuestFont:SetTextColor(1, 1, 1)

		_G.ItemTextPageText:SetTextColor('P', 1, 1, 1)
		hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', ItemTextPage_SetTextColor)
		hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, 'Update', GreetingPanel_Update)

		if E.Modern then
			GossipFrame.Background:Hide()
		end
	else
		local pageBG = E.Modern and _G.ItemTextFramePageBg:GetTexture()
		_G.ItemTextFrame:StripTextures()
		_G.ItemTextFrame:SetTemplate('Transparent')
		_G.ItemTextScrollFrame:StripTextures()
		_G.ItemTextScrollFrame:CreateBackdrop('Transparent')

		if E.Modern then
			_G.ItemTextFramePageBg:SetTexture(pageBG)
			_G.ItemTextFramePageBg:SetDrawLayer('BACKGROUND', 1)
			_G.ItemTextFramePageBg:SetInside(_G.ItemTextScrollFrame.backdrop)

			GossipFrame.Background:CreateBackdrop('Transparent')
			hooksecurefunc(GossipFrame.Background, 'SetAtlas', GossipFrame_SetAtlas)
		else
			_G.ItemTextMaterialBotLeft:SetDrawLayer('ARTWORK', 1)
			_G.ItemTextMaterialBotRight:SetDrawLayer('ARTWORK', 1)
			_G.ItemTextMaterialTopLeft:SetDrawLayer('ARTWORK', 1)
			_G.ItemTextMaterialTopRight:SetDrawLayer('ARTWORK', 1)

			local ItemTextFrame = _G.ItemTextFrame
			local itemTex = CreateParchment(ItemTextFrame)
			itemTex:SetInside(_G.ItemTextScrollFrame.backdrop)
			ItemTextFrame.itemTex = itemTex

			local GreetingPanel = _G.GossipFrame.GreetingPanel
			GreetingPanel:CreateBackdrop('Transparent')
			GreetingPanel.backdrop:Point('TOPLEFT', GreetingPanel.ScrollBox, 0, 0)
			GreetingPanel.backdrop:Point('BOTTOMRIGHT', GreetingPanel.ScrollBox, 0, 4)

			local spellTex = CreateParchment(GreetingPanel)
			spellTex:SetInside(GreetingPanel.backdrop)
			GreetingPanel.spellTex = spellTex
		end
	end
end
