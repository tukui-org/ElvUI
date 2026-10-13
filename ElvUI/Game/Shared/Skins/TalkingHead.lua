local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_FrameXML', 'TalkingHead', nil, nil, nil, nil, 'talkinghead')

function S:TalkingHead()
	local frame = _G.TalkingHeadFrame
	frame.BackgroundFrame.TextBackground:SetAtlas(nil)
	frame.PortraitFrame.Portrait:SetAtlas(nil)
	frame.MainFrame.Model.PortraitBg:SetAtlas(nil)
	frame.PortraitFrame:StripTextures()

	if E.db.general.talkingHeadFrameBackdrop then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
		frame.MainFrame:StripTextures()

		local button = frame.MainFrame.CloseButton
		S:HandleCloseButton(button)
		button:ClearAllPoints()
		button:Point('TOPRIGHT', frame.BackgroundFrame, 'TOPRIGHT', 0, -2)
	else
		frame.MainFrame.Model:CreateBackdrop('Transparent')
		frame.MainFrame.Model.backdrop:ClearAllPoints()
		frame.MainFrame.Model.backdrop:Point('CENTER')
		frame.MainFrame.Model.backdrop:Size(120, 119)

		frame.MainFrame.CloseButton:Kill()
	end

	frame.BackgroundFrame.TextBackground.SetAtlas = E.noop
	frame.PortraitFrame.Portrait.SetAtlas = E.noop
	frame.MainFrame.Model.PortraitBg.SetAtlas = E.noop

	frame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
	frame.NameFrame.Name.SetTextColor = E.noop
	frame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
	frame.NameFrame.Name:SetShadowOffset(2, -2)

	frame.TextFrame.Text:SetTextColor(1, 1, 1)
	frame.TextFrame.Text.SetTextColor = E.noop
	frame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
	frame.TextFrame.Text:SetShadowOffset(2, -2)
end
