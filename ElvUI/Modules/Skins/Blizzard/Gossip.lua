local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, ipairs = next, pairs, ipairs
local hooksecurefunc = hooksecurefunc

local function handleGossipText()
	local buttons = _G.GossipFrame.buttons
	if buttons and next(buttons) then
		for _, button in ipairs(buttons) do
			local str = button:GetFontString()
			if str then
				str:SetTextColor(1, 1, 1)

				local text = str:GetText()
				if text then
					local stripped = E:StripString(text)
					str:SetText(stripped)
				end
			end
		end
	end
end

function S:GossipFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gossip) then return end

	_G.ItemTextFrame:StripTextures(true)
	_G.ItemTextFrame:CreateBackdrop('Transparent')

	_G.ItemTextScrollFrame:StripTextures()

	_G.GossipFrame:CreateBackdrop('Transparent')
	_G.GossipFrame.Background:Hide()
	_G.GossipFramePortrait:Kill()

	S:HandleCloseButton(_G.ItemTextFrameCloseButton)

	S:HandleScrollBar(_G.GossipGreetingScrollFrameScrollBar, 5)
	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)

	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)
	S:HandleNextPrevButton(_G.ItemTextNextPageButton)

	_G.ItemTextPageText:SetTextColor(1, 1, 1)
	hooksecurefunc(_G.ItemTextPageText, 'SetTextColor', function(pageText, headerType, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			pageText:SetTextColor(headerType, 1, 1, 1)
		end
	end)

	local StripAllTextures = { 'GossipFrameGreetingPanel', 'GossipGreetingScrollFrame' }

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame)

	local GossipGreetingScrollFrame = _G.GossipGreetingScrollFrame
	GossipGreetingScrollFrame:CreateBackdrop()

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc('GossipFrameUpdate', handleGossipText)
		_G.GossipGreetingText:SetTextColor(1, 1, 1)
		handleGossipText()
	else
		GossipGreetingScrollFrame.spellTex = GossipGreetingScrollFrame:CreateTexture(nil, 'ARTWORK')
		GossipGreetingScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
		GossipGreetingScrollFrame.spellTex:Point('TOPLEFT', 2, -2)
		GossipGreetingScrollFrame.spellTex:Size(506, 615)
		GossipGreetingScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
	end

	_G.GossipFrameGreetingGoodbyeButton:StripTextures()
	S:HandleButton(_G.GossipFrameGreetingGoodbyeButton)

	for i = 1, 4 do
		local notch = _G['NPCFriendshipStatusBarNotch'..i]
		if notch then
			notch:SetColorTexture(0, 0, 0)
			notch:Size(1, 16)
		end
	end

	local NPCFriendshipStatusBar = _G.NPCFriendshipStatusBar
	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:CreateBackdrop()
	E:RegisterStatusBar(NPCFriendshipStatusBar)

	NPCFriendshipStatusBar.icon:ClearAllPoints()
	NPCFriendshipStatusBar.icon:Point('RIGHT', NPCFriendshipStatusBar, 'LEFT', 0, -3)
	S:HandleIcon(NPCFriendshipStatusBar.icon)
end

S:AddCallback('GossipFrame')
