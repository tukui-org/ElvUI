local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local select, unpack, pairs = select, unpack, pairs
local CreateFrame = CreateFrame

local function SkinIt(bar)
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
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

function B:START_TIMER()
	for _, b in pairs(_G.TimerTracker.timerList) do
		if b.bar and not b.bar.skinned then
			SkinIt(b.bar)
			b.bar.skinned = true
		end
	end
end

function B:SkinBlizzTimers()
	B:RegisterEvent('START_TIMER')
	B:START_TIMER()
end
