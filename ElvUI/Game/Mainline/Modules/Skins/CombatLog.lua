local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local CH = E:GetModule('Chat')
local LSM = E.Libs.LSM

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

local function StyleButtons()
	for index in ipairs(_G.Blizzard_CombatLog_Filters.filters) do
		local button = _G['CombatLogQuickButtonFrameButton'..index]
		local text = button and button:GetFontString()
		if text then
			text:FontTemplate(LSM:Fetch('font', CH.db.tabFont), CH.db.tabFontSize, CH.db.tabFontOutline)
		end
	end
end

-- credit: Aftermathh, edited by Simpy
function S:Blizzard_CombatLog()
	if not E.private.chat.enable then return end

	StyleButtons()
	hooksecurefunc('Blizzard_CombatLog_Update_QuickButtons', StyleButtons)

	local progress = _G.CombatLogQuickButtonFrame_CustomProgressBar
	if progress then
		progress:SetStatusBarTexture(E.media.normTex)
	end
end

S:AddCallbackForAddon('Blizzard_CombatLog')
