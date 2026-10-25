local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_FrameXML', 'TalkingHead', nil, nil, nil, nil, 'talkinghead')

-- This prevents a taint trying to force an atlas or color lock by setting it to E.noop
-- The kit call also resizes the region (useAtlasSize) and the Name anchors to the Portrait
local ATLAS_SIZES = {}
local function ClearAtlas(region, atlas)
	if not atlas then return end

	local size = ATLAS_SIZES[region]
	region:SetTexture()
	region:SetSize(size.width, size.height)
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
	local mainFrame = frame.MainFrame
	local modelFrame = mainFrame.Model
	modelFrame.PortraitBg:SetAtlas(nil)

	local bgFrame = frame.BackgroundFrame
	bgFrame.TextBackground:SetAtlas(nil)

	local portraitFrame = frame.PortraitFrame
	portraitFrame.Portrait:SetAtlas(nil)
	portraitFrame:StripTextures()

	local closeButton = mainFrame.CloseButton
	if E.db.general.talkingHeadFrameBackdrop then
		frame:StripTextures()
		frame:SetTemplate('Transparent')

		mainFrame:StripTextures()

		closeButton:ClearAllPoints()
		closeButton:Point('TOPRIGHT', bgFrame, 'TOPRIGHT', 0, -2)

		S:HandleCloseButton(closeButton)
	else
		modelFrame:CreateBackdrop('Transparent')
		modelFrame.backdrop:ClearAllPoints()
		modelFrame.backdrop:Point('CENTER')
		modelFrame.backdrop:Size(120, 119)

		closeButton:Kill()
	end

	for _, region in next, { bgFrame.TextBackground, portraitFrame.Portrait, modelFrame.PortraitBg } do
		local width, height = region:GetSize()
		ATLAS_SIZES[region] = { width = width, height = height }

		hooksecurefunc(region, 'SetAtlas', ClearAtlas)
	end

	local nameText = frame.NameFrame.Name
	nameText:SetTextColor(1, 0.82, 0.02)
	nameText:SetShadowColor(0, 0, 0, 1)
	nameText:SetShadowOffset(2, -2)

	hooksecurefunc(nameText, 'SetTextColor', LockGold)

	local frameText = frame.TextFrame.Text
	frameText:SetTextColor(1, 1, 1)
	frameText:SetShadowColor(0, 0, 0, 1)
	frameText:SetShadowOffset(2, -2)

	hooksecurefunc(frameText, 'SetTextColor', LockWhite)
end
