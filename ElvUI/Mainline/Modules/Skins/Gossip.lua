local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub, next = gsub, next
local hooksecurefunc = hooksecurefunc

local GossipTextColors = {
	['000000'] = 'ffffff',
	['414141'] = '7b8489',
}

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

local function GreetingPanel_Update(frame)
	for _, button in next, { frame.ScrollTarget:GetChildren() } do
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
end

local function GossipFrame_SetAtlas(frame)
	frame:Height(frame:GetHeight() - 2)
end

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)

	S:HandleTrimScrollBar(_G.ItemTextScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.GossipFrame.GreetingPanel.ScrollBar)
	S:HandleButton(_G.GossipFrame.GreetingPanel.GoodbyeButton, true)
	S:HandleCloseButton(_G.ItemTextFrameCloseButton)

	S:HandleNextPrevButton(_G.ItemTextNextPageButton)
	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)

	for i = 1, 4 do
		local notch = GossipFrame.FriendshipStatusBar['Notch'..i]
		if notch then
			notch:SetColorTexture(0, 0, 0)
			notch:SetSize(E.mult, 16)
		end
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

		if GossipFrame.Background then
			GossipFrame.Background:Hide()
		end

	else
		local pageBG = _G.ItemTextFramePageBg:GetTexture()
		_G.ItemTextFrame:StripTextures()
		_G.ItemTextFrame:SetTemplate('Transparent')
		_G.ItemTextScrollFrame:StripTextures()
		_G.ItemTextScrollFrame:CreateBackdrop('Transparent')

		_G.ItemTextFramePageBg:SetTexture(pageBG)
		_G.ItemTextFramePageBg:SetDrawLayer('BACKGROUND', 1)
		_G.ItemTextFramePageBg:SetInside(_G.ItemTextScrollFrame.backdrop)

		if GossipFrame.Background then
			GossipFrame.Background:CreateBackdrop('Transparent')

			hooksecurefunc(GossipFrame.Background, 'SetAtlas', GossipFrame_SetAtlas)
		end
	end
end

S:AddCallback('GossipFrame')
