local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local gsub = gsub
local select = select
local strmatch = strmatch
local hooksecurefunc = hooksecurefunc

local function ReplaceGossipFormat(button, textFormat, text)
	local newFormat, count = gsub(textFormat, '000000', 'ffffff')
	if count > 0 then
		button:SetFormattedText(newFormat, text)
	end
end

local ReplacedGossipColor = {
	['000000'] = 'ffffff',
	['414141'] = '7b8489',
}

local function ReplaceGossipText(button, text)
	if text and text ~= '' then
		local newText, count = gsub(text, ':32:32:0:0', ':32:32:0:0:64:64:5:59:5:59')
		if count > 0 then
			text = newText
			button:SetFormattedText('%s', text)
		end

		local colorStr, rawText = strmatch(text, '|c[fF][fF](%x%x%x%x%x%x)(.-)|r')
		colorStr = ReplacedGossipColor[colorStr]
		if colorStr and rawText then
			button:SetFormattedText('|cff%s%s|r', colorStr, rawText)
		end
	end
end

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)

	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)
	S:HandleTrimScrollBar(_G.GossipFrame.GreetingPanel.ScrollBar)
	S:HandleButton(_G.GossipFrame.GreetingPanel.GoodbyeButton, true)

	S:HandleNextPrevButton(_G.ItemTextNextPageButton)
	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)

	for i = 1, 4 do
		local notch = GossipFrame.FriendshipStatusBar['Notch'..i]
		if notch then
			notch:SetColorTexture(0, 0, 0)
			notch:SetSize(E.mult, 16)
		end
	end

	if not E.private.skins.parchmentRemoverEnable then
		local pageBG = _G.ItemTextFramePageBg:GetTexture()
		_G.ItemTextFrame:StripTextures()
		_G.ItemTextFramePageBg:SetTexture(pageBG)
		_G.ItemTextFramePageBg:SetDrawLayer('BACKGROUND', 1)
	else
		_G.ItemTextPageText:SetTextColor('P', 1, 1, 1)
		hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', function(pageText, headerType, r, g, b)
			if r ~= 1 or g ~= 1 or b ~= 1 then
				pageText:SetTextColor(headerType, 1, 1, 1)
			end
		end)

		_G.ItemTextFrame:StripTextures(true)
		_G.QuestFont:SetTextColor(1, 1, 1)
		_G.GossipFrameInset:Hide()

		if GossipFrame.Background then
			GossipFrame.Background:Hide()
		end

		hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, 'Update', function(frame)
			for _, button in next, { frame.ScrollTarget:GetChildren() } do
				if not button.IsSkinned then
					local buttonText = select(3, button:GetRegions())
					if buttonText and buttonText:IsObjectType('FontString') then
						ReplaceGossipText(button, button:GetText())
						hooksecurefunc(button, 'SetText', ReplaceGossipText)
						hooksecurefunc(button, 'SetFormattedText', ReplaceGossipFormat)
					end

					button.IsSkinned = true
				end
			end
		end)
	end

	_G.ItemTextFrame:SetTemplate('Transparent')
	_G.ItemTextScrollFrame:StripTextures()
	S:HandleCloseButton(_G.ItemTextFrameCloseButton)
end

S:AddCallback('GossipFrame')
