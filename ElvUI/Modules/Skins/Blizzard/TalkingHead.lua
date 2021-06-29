local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

--Just some test code
--[[
local talkingHeadTextureKitRegionFormatStrings = {
	TextBackground = '%s-TextBackground',
	Portrait = '%s-PortraitFrame',
}
local talkingHeadDefaultAtlases = {
	TextBackground = 'TalkingHeads-TextBackground',
	Portrait = 'TalkingHeads-Alliance-PortraitFrame',
}
local talkingHeadFontColor = {
	['TalkingHeads-Horde'] = {Name = CreateColor(0.28, 0.02, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	['TalkingHeads-Alliance'] = {Name = CreateColor(0.02, 0.17, 0.33), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	['TalkingHeads-Neutral'] = {Name = CreateColor(0.33, 0.16, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
	['Normal'] = {Name = CreateColor(1, 0.82, 0.02), Text = CreateColor(1, 1, 1), Shadow = CreateColor(0.0, 0.0, 0.0, 1.0)},
}

--test
function TestTalkingHead()
	local frame = TalkingHeadFrame
	local model = frame.MainFrame.Model

	if frame.finishTimer then
		frame.finishTimer:Cancel()
		frame.finishTimer = nil
	end
	if frame.voHandle then
		StopSound(frame.voHandle)
		frame.voHandle = nil
	end

	local currentDisplayInfo = model:GetDisplayInfo()
	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKitID

	displayInfo = 76291
	cameraID = 1240
	vo = 103175
	duration = 20.220001220703
	lineNumber = 0
	numLines = 4
	name = 'Some Ugly Woman'
	text = 'Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out '
	isNewTalkingHead = true
	textureKitID = 0

	local textFormatted = format(text)
	if displayInfo and displayInfo ~= 0 then
		local textureKit
		if textureKitID ~= 0 then
			SetupTextureKits(textureKitID, frame.BackgroundFrame, talkingHeadTextureKitRegionFormatStrings, false, true)
			SetupTextureKits(textureKitID, frame.PortraitFrame, talkingHeadTextureKitRegionFormatStrings, false, true)
			textureKit = GetUITextureKitInfo(textureKitID)
		else
			SetupAtlasesOnRegions(frame.BackgroundFrame, talkingHeadDefaultAtlases, true)
			SetupAtlasesOnRegions(frame.PortraitFrame, talkingHeadDefaultAtlases, true)
			textureKit = 'Normal'
		end
		local nameColor = talkingHeadFontColor[textureKit].Name
		local textColor = talkingHeadFontColor[textureKit].Text
		local shadowColor = talkingHeadFontColor[textureKit].Shadow
		frame.NameFrame.Name:SetTextColor(nameColor:GetRGB())
		frame.NameFrame.Name:SetShadowColor(shadowColor:GetRGBA())
		frame.TextFrame.Text:SetTextColor(textColor:GetRGB())
		frame.TextFrame.Text:SetShadowColor(shadowColor:GetRGBA())
		frame:Show()
		if currentDisplayInfo ~= displayInfo then
			model.uiCameraID = cameraID
			model:SetDisplayInfo(displayInfo)
		else
			if model.uiCameraID ~= cameraID then
				model.uiCameraID = cameraID
				Model_ApplyUICamera(model, model.uiCameraID)
			end
			TalkingHeadFrame_SetupAnimations(model)
		end

		if isNewTalkingHead then
			TalkingHeadFrame_Reset(frame, textFormatted, name)
			TalkingHeadFrame_FadeinFrames()
		else
			if name ~= frame.NameFrame.Name:GetText() then
				-- Fade out the old name and fade in the new name
				frame.NameFrame.Fadeout:Play()
				E:Delay(0.25, frame.NameFrame.Name.SetText, frame.NameFrame.Name, name)
				E:Delay(0.5, frame.NameFrame.Fadein.Play, frame.NameFrame.Fadein)

				frame.MainFrame.TalkingHeadsInAnim:Play()
			end

			if textFormatted ~= frame.TextFrame.Text:GetText() then
				-- Fade out the old text and fade in the new text
				frame.TextFrame.Fadeout:Play()
				E:Delay(0.25, frame.TextFrame.Text.SetText, frame.TextFrame.Text, textFormatted)
				E:Delay(0.5, frame.TextFrame.Fadein.Play, frame.TextFrame.Fadein)
			end
		end

		local success, voHandle = PlaySound(vo, 'Talking Head', true, true)
		if success then
			frame.voHandle = voHandle
		end
	end
end]]

function S:Blizzard_TalkingHeadUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talkinghead) then return end

	local TalkingHeadFrame = _G.TalkingHeadFrame

	TalkingHeadFrame.BackgroundFrame.TextBackground:SetAtlas(nil)
	TalkingHeadFrame.PortraitFrame.Portrait:SetAtlas(nil)
	TalkingHeadFrame.MainFrame.Model.PortraitBg:SetAtlas(nil)
	TalkingHeadFrame.PortraitFrame:StripTextures()

	if E.db.general.talkingHeadFrameBackdrop then
		TalkingHeadFrame:StripTextures()
		TalkingHeadFrame:SetTemplate('Transparent')
		TalkingHeadFrame.MainFrame:StripTextures()

		local button = TalkingHeadFrame.MainFrame.CloseButton
		S:HandleCloseButton(button)
		button:ClearAllPoints()
		button:Point('TOPRIGHT', TalkingHeadFrame.BackgroundFrame, 'TOPRIGHT', 0, -2)
	else
		TalkingHeadFrame.MainFrame.Model:CreateBackdrop('Transparent')
		TalkingHeadFrame.MainFrame.Model.backdrop:ClearAllPoints()
		TalkingHeadFrame.MainFrame.Model.backdrop:Point('CENTER')
		TalkingHeadFrame.MainFrame.Model.backdrop:Size(120, 119)

		TalkingHeadFrame.MainFrame.CloseButton:Kill()
	end

	TalkingHeadFrame.BackgroundFrame.TextBackground.SetAtlas = E.noop
	TalkingHeadFrame.PortraitFrame.Portrait.SetAtlas = E.noop
	TalkingHeadFrame.MainFrame.Model.PortraitBg.SetAtlas = E.noop

	TalkingHeadFrame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
	TalkingHeadFrame.NameFrame.Name.SetTextColor = E.noop
	TalkingHeadFrame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
	TalkingHeadFrame.NameFrame.Name:SetShadowOffset(2, -2)

	TalkingHeadFrame.TextFrame.Text:SetTextColor(1, 1, 1)
	TalkingHeadFrame.TextFrame.Text.SetTextColor = E.noop
	TalkingHeadFrame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
	TalkingHeadFrame.TextFrame.Text:SetShadowOffset(2, -2)
end

S:AddCallbackForAddon('Blizzard_TalkingHeadUI')
