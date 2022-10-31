local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function S:HandleMirrorTimer()
	local i = 1
	local frame = _G.MirrorTimer1
	while frame do
		if not frame.atlasHolder then
			frame.atlasHolder = CreateFrame('Frame', nil, frame)
			frame.atlasHolder:SetClipsChildren(true)
			frame.atlasHolder:SetInside()

			frame.StatusBar:SetParent(frame.atlasHolder)
			frame.StatusBar:ClearAllPoints()
			frame.StatusBar:SetSize(204, 22)
			frame.StatusBar:Point('TOP', 0, 2)

			frame:SetSize(200, 18)

			frame.Text:FontTemplate()
			frame.Text:ClearAllPoints()
			frame.Text:SetParent(frame.StatusBar)
			frame.Text:Point('CENTER', frame.StatusBar, 0, 1)
		end

		frame:StripTextures()
		frame:SetTemplate('Transparent')

		i = i + 1
		frame = _G['MirrorTimer'..i]
	end
end

function S:MirrorTimers() -- Mirror Timers (Underwater Breath, etc.)
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mirrorTimers) then return end

	local i = 1
	local frame = _G.MirrorTimer1
	while frame do
		E:CreateMover(frame, 'MirrorTimer'..i..'Mover', L["MirrorTimer"]..i, nil, nil, nil, 'ALL,SOLO')

		i = i + 1
		frame = _G['MirrorTimer'..i]
	end

	hooksecurefunc('MirrorTimer_Show', S.HandleMirrorTimer)
end

S:AddCallback('MirrorTimers')
