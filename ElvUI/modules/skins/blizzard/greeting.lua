local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.greeting ~= true then return end
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		QuestFrameGreetingPanel:StripTextures()
		S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
		QuestGreetingFrameHorizontalBreak:Kill()
	end)
end

S:RegisterSkin('ElvUI', LoadSkin)