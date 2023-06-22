local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SetupTimer(self, timer)
	local bar = self:GetAvailableTimer(timer)
	if bar then
		bar.atlasHolder = CreateFrame('Frame', nil, bar)
		bar.atlasHolder:SetClipsChildren(true)
		bar.atlasHolder:SetInside()

		bar.StatusBar:SetParent(bar.atlasHolder)
		bar.StatusBar:ClearAllPoints()
		bar.StatusBar:SetSize(204, 22)
		bar.StatusBar:Point('TOP', 0, 2)

		bar:SetSize(200, 18)

		bar.Text:FontTemplate()
		bar.Text:ClearAllPoints()
		bar.Text:SetParent(bar.StatusBar)
		bar.Text:Point('CENTER', bar.StatusBar, 0, 1)

		bar:StripTextures()
		bar:SetTemplate('Transparent')

		-- ToDO: look at the blizz mover stuff
	end
end

function S:MirrorTimers() -- Mirror Timers (Underwater Breath, etc.)
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mirrorTimers) then return end

	-- ToDO: 10.1.5
	hooksecurefunc(_G.MirrorTimerContainer, 'SetupTimer', SetupTimer)
end

S:AddCallback('MirrorTimers')
