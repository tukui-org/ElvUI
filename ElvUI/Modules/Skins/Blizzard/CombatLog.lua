local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
	if E.private.chat.enable ~= true then return end
	-- this is always on with the chat module, it's only handle the top bar in combat log chat frame

	hooksecurefunc('Blizzard_CombatLog_Update_QuickButtons', StyleButtons)
	StyleButtons()

	local bar = _G.CombatLogQuickButtonFrame_Custom
	bar:StripTextures()
	bar:SetTemplate('Transparent')

	bar:ClearAllPoints()
	bar:SetPoint('BOTTOMLEFT', _G.ChatFrame2, 'TOPLEFT', -3, 2)
	bar:SetPoint('BOTTOMRIGHT', _G.ChatFrame2, 'TOPRIGHT', 3, 0)

	local progress = _G.CombatLogQuickButtonFrame_CustomProgressBar
	progress:SetStatusBarTexture(E.media.normTex)
	progress:SetInside(bar)

	S:HandleNextPrevButton(_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:ClearAllPoints()
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetPoint('TOPRIGHT', bar, 'TOPRIGHT', -2, -2)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0,0,0,0)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetFrameLevel(bar:GetFrameLevel() + 3)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(20)
	_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
end

S:AddCallbackForAddon('Blizzard_CombatLog')
