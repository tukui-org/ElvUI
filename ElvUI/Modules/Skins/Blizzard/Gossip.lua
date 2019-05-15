local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local gsub = gsub
local pairs = pairs
local strfind = strfind
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end

	_G.ItemTextFrame:StripTextures(true)
	_G.ItemTextFrame:SetTemplate("Transparent")

	_G.ItemTextScrollFrame:StripTextures()

	_G.GossipFrame:SetTemplate("Transparent")
	_G.GossipFramePortrait:Kill()

	S:HandleCloseButton(_G.ItemTextFrameCloseButton)

	S:HandleScrollBar(_G.GossipGreetingScrollFrameScrollBar, 5)
	S:HandleScrollBar(_G.ItemTextScrollFrameScrollBar)

	S:HandleNextPrevButton(_G.ItemTextPrevPageButton)
	S:HandleNextPrevButton(_G.ItemTextNextPageButton)

	_G.ItemTextPageText:SetTextColor(1, 1, 1)
	hooksecurefunc(_G.ItemTextPageText, "SetTextColor", function(pageText, headerType, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			pageText:SetTextColor(headerType, 1, 1, 1)
		end
	end)

	local StripAllTextures = { "GossipFrameGreetingPanel", "GossipGreetingScrollFrame" }

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local GossipFrame = _G.GossipFrame
	S:HandlePortraitFrame(GossipFrame, true)

	local GossipGreetingScrollFrame = _G.GossipGreetingScrollFrame
	GossipGreetingScrollFrame:SetTemplate()

	if E.private.skins.parchmentRemover.enable then
		for i = 1, _G.NUMGOSSIPBUTTONS do
			_G["GossipTitleButton"..i]:GetFontString():SetTextColor(1, 1, 1)
		end

		_G.GossipGreetingText:SetTextColor(1, 1, 1)

		hooksecurefunc("GossipFrameUpdate", function()
			for i = 1, _G.NUMGOSSIPBUTTONS do
				local button = _G["GossipTitleButton"..i]
				if button:GetFontString() then
					local Text = button:GetFontString():GetText()
					if Text and strfind(Text, '|cff000000') then
						button:GetFontString():SetText(gsub(Text, '|cff000000', '|cffffe519'))
					end
				end
			end
		end)
	else
		GossipGreetingScrollFrame.spellTex = GossipGreetingScrollFrame:CreateTexture(nil, 'ARTWORK')
		GossipGreetingScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
		GossipGreetingScrollFrame.spellTex:Point("TOPLEFT", 2, -2)
		GossipGreetingScrollFrame.spellTex:Size(506, 615)
		GossipGreetingScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
	end

	_G.GossipFrameGreetingGoodbyeButton:StripTextures()
	S:HandleButton(_G.GossipFrameGreetingGoodbyeButton)

	local NPCFriendshipStatusBar = _G.NPCFriendshipStatusBar
	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:CreateBackdrop()

	E:RegisterStatusBar(NPCFriendshipStatusBar)
end

S:AddCallback("Gossip", LoadSkin)
