local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mirrorTimers ~= true then return end
	--Mirror Timers (Underwater Breath etc.), credit to Azilroka
	for i = 1, MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G['MirrorTimer'..i]
		local statusBar = _G['MirrorTimer'..i..'StatusBar']
		local text = _G['MirrorTimer'..i.."Text"]

		mirrorTimer:StripTextures()
		mirrorTimer:Size(222, 18)
		statusBar:SetStatusBarTexture(E["media"].normTex)
		statusBar:CreateBackdrop()
		statusBar:Size(222, 18)
		text:ClearAllPoints()
		text:SetPoint('CENTER', statusBar, 'CENTER', 0, 0)

		E:CreateMover(mirrorTimer, "MirrorTimer"..i.."Mover", L["MirrorTimer"]..i, nil, nil, nil, "ALL,SOLO")
	end
end

S:RegisterSkin('ElvUI', LoadSkin)