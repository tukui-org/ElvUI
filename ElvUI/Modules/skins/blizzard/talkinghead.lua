local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talkinghead ~= true then return end
	
	TalkingHeadFrame:StripTextures()
	TalkingHeadFrame.MainFrame:StripTextures()
	TalkingHeadFrame.BackgroundFrame:StripTextures()
	TalkingHeadFrame.BackgroundFrame:CreateBackdrop('Transparent')
	TalkingHeadFrame.BackgroundFrame.backdrop:SetAllPoints()
	TalkingHeadFrame.PortraitFrame:StripTextures()

	TalkingHeadFrame.MainFrame.Model:CreateBackdrop('Transparent')
	TalkingHeadFrame.MainFrame.Model:CreateShadow('Default')
	TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()
	
	local button = TalkingHeadFrame.MainFrame.CloseButton
	S:HandleCloseButton(button)
	button:ClearAllPoints()
	button:Point('TOPRIGHT', TalkingHeadFrame.BackgroundFrame, 'TOPRIGHT', -2, -2)
end

S:RegisterSkin('Blizzard_TalkingHeadUI', LoadSkin)