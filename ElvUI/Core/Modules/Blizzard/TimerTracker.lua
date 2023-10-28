local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local next = next
local unpack, pairs = unpack, pairs
local CreateFrame = CreateFrame

local function SkinIt(bar)
	for _, region in next, { bar:GetRegions() } do
		if region:IsObjectType('Texture') then
			region:SetTexture()
		elseif region:IsObjectType('FontString') then
			region:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	bar:SetStatusBarTexture(E.media.normTex)
	if E.PixelMode then
		bar:SetStatusBarColor(.31, .31, .31)
	else
		bar:SetStatusBarColor(unpack(E.media.bordercolor))
	end

	if not bar.backdrop then
		bar.backdrop = CreateFrame('Frame', nil, bar)
		bar.backdrop:SetFrameLevel(0)
		bar.backdrop:SetTemplate('Transparent')
		bar.backdrop:SetOutside()
		E:RegisterStatusBar(bar)
	end
end

function BL:START_TIMER()
	for _, b in pairs(_G.TimerTracker.timerList) do
		if b.bar and not b.bar.skinned then
			SkinIt(b.bar)
			b.bar.skinned = true
		end
	end
end

function BL:SkinBlizzTimers()
	BL:RegisterEvent('START_TIMER')
	BL:START_TIMER()
end
