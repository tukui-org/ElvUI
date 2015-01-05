local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true then return end
	ItemTextFrame:StripTextures(true)
	ItemTextScrollFrame:StripTextures()
	GossipFrame:SetTemplate("Transparent")
	S:HandleCloseButton(GossipFrameCloseButton)
	S:HandleNextPrevButton(ItemTextPrevPageButton)
	S:HandleNextPrevButton(ItemTextNextPageButton)
	ItemTextPageText:SetTextColor(1, 1, 1)
	hooksecurefunc(ItemTextPageText, "SetTextColor", function(self, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			ItemTextPageText:SetTextColor(1, 1, 1)
		end
	end)
	ItemTextFrame:SetTemplate("Transparent")
	ItemTextFrameInset:Kill()
	S:HandleScrollBar(ItemTextScrollFrameScrollBar)
	S:HandleCloseButton(ItemTextFrameCloseButton)

	local StripAllTextures = {
		"GossipFrameGreetingPanel",
		"GossipFrame",
		"GossipFrameInset",
		"GossipGreetingScrollFrame",
	}

	S:HandleScrollBar(GossipGreetingScrollFrameScrollBar, 5)


	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	GossipGreetingScrollFrame:SetTemplate()
	GossipGreetingScrollFrame.spellTex = GossipGreetingScrollFrame:CreateTexture(nil, 'ARTWORK')
	GossipGreetingScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	GossipGreetingScrollFrame.spellTex:SetPoint("TOPLEFT", 2, -2)
	GossipGreetingScrollFrame.spellTex:Size(506, 615)
	GossipGreetingScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)

	local KillTextures = {
		"GossipFramePortrait",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	local buttons = {
		"GossipFrameGreetingGoodbyeButton",
	}

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		S:HandleButton(_G[buttons[i]])
	end


	S:HandleCloseButton(GossipFrameCloseButton,GossipFrame.backdrop)

	NPCFriendshipStatusBar:StripTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(E.media.normTex)
	NPCFriendshipStatusBar:CreateBackdrop('Default')
end

S:RegisterSkin('ElvUI', LoadSkin)