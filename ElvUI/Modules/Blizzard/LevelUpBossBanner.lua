local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local Holder
local function Reanchor(frame, _, anchor)
	if anchor and (anchor ~= Holder) then
		frame:ClearAllPoints()
		frame:Point("TOP", Holder)
	end
end

function B:Handle_LevelUpDisplay_BossBanner()
	if not Holder then
		Holder = CreateFrame("Frame", "LevelUpBossBannerHolder", E.UIParent)
		Holder:Size(200, 20)
		Holder:Point("TOP", E.UIParent, "TOP", 0, -120)
	end

	E:CreateMover(Holder, "LevelUpBossBannerMover", L["Level Up Display / Boss Banner"])

	_G.LevelUpDisplay:ClearAllPoints()
	_G.LevelUpDisplay:Point("TOP", Holder)
	hooksecurefunc(_G.LevelUpDisplay, "SetPoint", Reanchor)

	_G.BossBanner:ClearAllPoints()
	_G.BossBanner:Point("TOP", Holder)
	hooksecurefunc(_G.BossBanner, "SetPoint", Reanchor)
end
