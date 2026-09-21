local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

local function StyleButtons()
	for index in ipairs(_G.Blizzard_CombatLog_Filters.filters) do
		local button = _G['CombatLogQuickButtonFrameButton'..index] -- created on demand
		local text = button and button:GetFontString()
		if text then
			text:FontTemplate(nil, nil, 'OUTLINE')
		end
	end
end

-- Credits: Aftermathh
function S:Blizzard_CombatLog()
	if E.private.chat.enable ~= true then return end -- This is always on with the chat module, it's only handle the top bar in combat log chat frame

	local Button = _G.CombatLogQuickButtonFrame_Custom
	Button:StripTextures()
	Button:SetTemplate('Transparent')

	local FontContainer = _G.ChatFrame2.FontStringContainer
	local point1, point2 = E.PixelMode and 2 or 1, E.PixelMode and 0 or 1
	Button:ClearAllPoints()
	Button:Point('BOTTOMLEFT', FontContainer, 'TOPLEFT', -point1, point2)
	Button:Point('BOTTOMRIGHT', FontContainer, 'TOPRIGHT', point1, point2)

	hooksecurefunc('Blizzard_CombatLog_Update_QuickButtons', StyleButtons)
	StyleButtons()

	local ProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	ProgressBar:SetStatusBarTexture(E.media.normTex)
	ProgressBar:SetInside(Button)

	local FilterButton = _G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton
	S:HandleNextPrevButton(FilterButton)
	FilterButton:SetHitRectInsets(0, 0, 0, 0)
	FilterButton:Size(20, 22)
	FilterButton:Point('TOPRIGHT', Button, 'TOPRIGHT', 0, -1)
	_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
end

S:AddCallbackForAddon('Blizzard_CombatLog')
