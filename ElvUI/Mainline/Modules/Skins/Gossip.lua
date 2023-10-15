local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local gsub = gsub
local select = select
local strmatch = strmatch
local hooksecurefunc = hooksecurefunc

local function ReplaceTextColor(text, r)
	if r ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
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

	if not E.private.skins.parchmentRemoverEnable then
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

			hooksecurefunc(GossipFrame.Background, 'SetAtlas', function(frame)
				frame:Height(frame:GetHeight() - 2)
			end)
		end
	else
		_G.ItemTextPageText:SetTextColor('P', 1, 1, 1)
		hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', function(pageText, headerType, r, g, b)
			if r ~= 1 or g ~= 1 or b ~= 1 then
				pageText:SetTextColor(headerType, 1, 1, 1)
			end
		end)

		_G.ItemTextFrame:StripTextures(true)
		_G.ItemTextFrame:SetTemplate('Transparent')
		_G.ItemTextScrollFrame:StripTextures()

		_G.QuestFont:SetTextColor(1, 1, 1)
		_G.GossipFrameInset:Hide()

		if GossipFrame.Background then
			GossipFrame.Background:Hide()
		end

		hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, 'Update', function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local button = select(i, self.ScrollTarget:GetChildren())
				if not button.IsSkinned then
					local buttonText = button.GreetingText or button.GetFontString and button:GetFontString()
					if buttonText then
						buttonText:SetTextColor(1, 1, 1)
						hooksecurefunc(buttonText, 'SetTextColor', ReplaceTextColor)
					end

					button.IsSkinned = true
				end
			end
		end)
	end
end

S:AddCallback('GossipFrame')
