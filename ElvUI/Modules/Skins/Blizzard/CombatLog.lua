local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

-- credit: Aftermathh
function S:Blizzard_CombatLog()
	if E.private.chat.enable ~= true then return end
	-- this is always on with the chat module, it's only handle the top bar in combat log chat frame

	local Button = _G.CombatLogQuickButtonFrame_Custom
	Button:StripTextures()
	Button:SetTemplate('Transparent')

	local FontContainer = _G.ChatFrame2.FontStringContainer
	if FontContainer then
		local point1, point2 = E.PixelMode and 2 or 1, E.PixelMode and 0 or 1
		Button:ClearAllPoints()
		Button:Point('BOTTOMLEFT', FontContainer, 'TOPLEFT', -point1, point2)
		Button:Point('BOTTOMRIGHT', FontContainer, 'TOPRIGHT', point1, point2)
	end

	hooksecurefunc('Blizzard_CombatLog_Update_QuickButtons', function()
		for index in ipairs(_G.Blizzard_CombatLog_Filters.filters) do
			local button = _G['CombatLogQuickButtonFrameButton'..index]
			if button then
				local text = button:GetFontString()
				if text then
					text:FontTemplate(nil, nil, 'OUTLINE')
				end
			end
		end
	end)

	local ProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	ProgressBar:SetStatusBarTexture(E.media.normTex)
	ProgressBar:SetInside(Button)

	S:HandleNextPrevButton(_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton)

	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Size(20, 22)
	_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:Point('TOPRIGHT', Button, 'TOPRIGHT', 0, -1)
	_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
end

S:AddCallbackForAddon('Blizzard_CombatLog')
