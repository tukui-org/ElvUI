local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- credit: Aftermathh
function S:Blizzard_CombatLog()
	if E.private.chat.enable ~= true then return end
	-- this is always on with the chat module, it's only handle the top bar in combat log chat frame

	local Button = _G.CombatLogQuickButtonFrame_Custom
	Button:StripTextures()
	Button:SetTemplate("Transparent")

	local FontContainer = _G.ChatFrame2.FontStringContainer
	if FontContainer then
		Button:ClearAllPoints()
		Button:Point("BOTTOMLEFT", FontContainer, "TOPLEFT", -1, 1)
		Button:Point("BOTTOMRIGHT", FontContainer, "TOPRIGHT", E.PixelMode and 4 or 0, 1)
	end

	hooksecurefunc('Blizzard_CombatLog_Update_QuickButtons', function()
		local index = #_G.Blizzard_CombatLog_Filters.filters
		local buttonText = _G["CombatLogQuickButtonFrameButton"..index]:GetFontString()
		buttonText:FontTemplate(nil, nil, 'OUTLINE')
	end)

	local ProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	ProgressBar:SetStatusBarTexture(E.media.normTex)
	ProgressBar:SetInside(Button)

	S:HandleNextPrevButton(_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton)

	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(20, 22)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point("TOPRIGHT", Button, "TOPRIGHT", 0, -1)
	_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
end

S:AddCallbackForAddon('Blizzard_CombatLog')
