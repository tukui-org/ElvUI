local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talkinghead ~= true then return end
	
	-- Needs Review, i like it
	TalkingHeadFrame:StripTextures()
	-- TalkingHeadFrame:SetTemplate("Transparent")
	TalkingHeadFrame.MainFrame:StripTextures()
	TalkingHeadFrame.PortraitFrame:StripTextures()
	
	S:HandleCloseButton(TalkingHeadFrame.MainFrame.CloseButton)
end

S:RegisterSkin('Blizzard_TalkingHeadUI', LoadSkin)