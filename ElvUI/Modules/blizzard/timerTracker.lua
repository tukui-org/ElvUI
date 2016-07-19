local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--Lua functions
local select, unpack, pairs = select, unpack, pairs
--WoW API / Variables
local CreateFrame = CreateFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TimerTracker

local function SkinIt(bar)
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	bar:SetStatusBarTexture(E["media"].normTex)
	if E.PixelMode then
		bar:SetStatusBarColor(.31, .31, .31)
	else
		bar:SetStatusBarColor(unpack(E["media"].bordercolor))
	end

	if not bar.backdrop then
		bar.backdrop = CreateFrame("Frame", nil, bar)
		bar.backdrop:SetFrameLevel(0)
		bar.backdrop:SetTemplate("Transparent")
		bar.backdrop:SetOutside()
		E:RegisterStatusBar(bar)
	end
end

function B:START_TIMER(event)
	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

function B:SkinBlizzTimers()
	self:RegisterEvent('START_TIMER')
end