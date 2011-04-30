local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Dummy Bar
--/run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local function SkinIt(bar)
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["media"].font,C["general"].fontscale, "THINOUTLINE")
			region:SetShadowColor(0,0,0,0)
		end
	end
	
	bar:SetStatusBarTexture(C["media"].normTex)
	bar:SetStatusBarColor(unpack(C["media"].bordercolor))
	
	bar.backdrop = CreateFrame("Frame", nil, bar)
	bar.backdrop:SetFrameLevel(0)
	bar.backdrop:SetTemplate("Transparent")
	bar.backdrop:Point("TOPLEFT", bar, "TOPLEFT", -2, 2)
	bar.backdrop:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
end

local function SkinBlizzTimer()	
	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

local load = CreateFrame("Frame")
load:RegisterEvent("START_TIMER")
load:SetScript("OnEvent", SkinBlizzTimer)