local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_FrameXML', 'TalkingHead', nil, nil, nil, nil, 'talkinghead')

-- This prevents a taint trying to force an atlas or color lock by setting it to E.noop
-- The kit call also resizes the region (useAtlasSize) and the Name anchors to the Portrait
local atlasSizes = {}
local function ClearAtlas(region, atlas)
	if atlas then
		local size = atlasSizes[region]
		region:SetTexture()
		region:SetSize(size[1], size[2])
	end
end

local function LockGold(text, r, g, b)
	if r ~= 1 or g ~= 0.82 or b ~= 0.02 then
		text:SetTextColor(1, 0.82, 0.02)
	end
end

local function LockWhite(text, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

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

	for _, region in next, { frame.BackgroundFrame.TextBackground, frame.PortraitFrame.Portrait, frame.MainFrame.Model.PortraitBg } do
		atlasSizes[region] = { region:GetSize() }
		hooksecurefunc(region, 'SetAtlas', ClearAtlas)
	end

	frame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
	hooksecurefunc(frame.NameFrame.Name, 'SetTextColor', LockGold)
	frame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
	frame.NameFrame.Name:SetShadowOffset(2, -2)

	frame.TextFrame.Text:SetTextColor(1, 1, 1)
	hooksecurefunc(frame.TextFrame.Text, 'SetTextColor', LockWhite)
	frame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
	frame.TextFrame.Text:SetShadowOffset(2, -2)
end
