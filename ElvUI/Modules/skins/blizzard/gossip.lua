local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local gsub = gsub
local pairs = pairs
local strfind = strfind
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: NUMGOSSIPBUTTONS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end

	ItemTextFrame:StripTextures(true)
	ItemTextFrame:SetTemplate("Transparent")

	ItemTextScrollFrame:StripTextures()

	GossipFrame:SetTemplate("Transparent")
	GossipFramePortrait:Kill()

	S:HandleCloseButton(ItemTextFrameCloseButton)
	S:HandleCloseButton(GossipFrameCloseButton)

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)
	S:HandleScrollBar(ItemTextScrollFrameScrollBar)

	S:HandleNextPrevButton(ItemTextPrevPageButton)
	S:HandleNextPrevButton(ItemTextNextPageButton)

	ItemTextPageText:SetTextColor(1, 1, 1)

	hooksecurefunc(ItemTextPageText, "SetTextColor", function(self, headerType, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			ItemTextPageText:SetTextColor(headerType, 1, 1, 1)
		end
	end)

	local StripAllTextures = { "GossipFrameGreetingPanel", "GossipFrame", "GossipFrameInset", "GossipGreetingScrollFrame" }

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	GossipGreetingScrollFrame:SetTemplate()

	if E.private.skins.parchmentRemover.enable then
		for i = 1, NUMGOSSIPBUTTONS do
			_G["GossipTitleButton"..i]:GetFontString():SetTextColor(1, 1, 1)
		end

		GossipGreetingText:SetTextColor(1, 1, 1)

		hooksecurefunc("GossipFrameUpdate", function()
			for i = 1, NUMGOSSIPBUTTONS do
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

	GossipFrameGreetingGoodbyeButton:StripTextures()
	S:HandleButton(GossipFrameGreetingGoodbyeButton)

	S:HandleCloseButton(GossipFrameCloseButton,GossipFrame.backdrop)

	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:CreateBackdrop('Default')

	E:RegisterStatusBar(NPCFriendshipStatusBar)
end

S:AddCallback("Gossip", LoadSkin)
