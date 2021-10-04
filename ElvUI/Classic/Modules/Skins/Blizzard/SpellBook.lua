local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local select = select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function S:SpellBookFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	S:HandleFrame(_G.SpellBookFrame, true, nil, 11, -12, -32, 76)

	_G.SpellBookTitleText:Point('TOP', -10, -17)
	_G.SpellBookTitleText:SetTextColor(1, 1, 1)

	_G.SpellBookSpellIconsFrame:StripTextures(true)
	_G.SpellBookSideTabsFrame:StripTextures(true)
	_G.SpellBookPageNavigationFrame:StripTextures(true)

	_G.SpellBookPageText:SetTextColor(1, 1, 1)
	_G.SpellBookPageText:Point('BOTTOM', -10, 87)

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton)
	_G.SpellBookPrevPageButton:Point('BOTTOMRIGHT', _G.SpellBookFrame, 'BOTTOMRIGHT', -73, 87)
	_G.SpellBookPrevPageButton:Size(24)

	S:HandleNextPrevButton(_G.SpellBookNextPageButton)
	_G.SpellBookNextPageButton:Point('TOPLEFT', _G.SpellBookPrevPageButton, 'TOPLEFT', 30, 0)
	_G.SpellBookNextPageButton:Size(24)

	S:HandleCloseButton(_G.SpellBookCloseButton, _G.SpellBookFrame.backdrop)

	for i = 1, 3 do
		local tab = _G['SpellBookFrameTabButton'..i]

		tab:GetNormalTexture():SetTexture(nil)
		tab:GetDisabledTexture():SetTexture(nil)

		S:HandleTab(tab)

		tab.backdrop:Point('TOPLEFT', 14, E.PixelMode and -16 or -19)
		tab.backdrop:Point('BOTTOMRIGHT', -14, 19)
	end

	-- Spell Buttons
	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local cooldown = _G['SpellButton'..i..'Cooldown']
		local highlight = _G['SpellButton'..i..'Highlight']

		for y = 1, button:GetNumRegions() do
			local region = select(y, button:GetRegions())
			if region:GetObjectType() == 'Texture' then
				if region:GetTexture() ~= [[Interface\Buttons\ActionBarFlyoutButton]] then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBackdrop('Default', true)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() - 1)

		button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)

		button.bg = CreateFrame('Frame', nil, button)
		button.bg:CreateBackdrop('Transparent', true)
		button.bg:Point('TOPLEFT', -6, 6)
		button.bg:Point('BOTTOMRIGHT', 112, -6)
		button.bg:Height(46)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

		icon:SetTexCoord(unpack(E.TexCoords))

		highlight:SetAllPoints()
		hooksecurefunc(highlight, 'SetTexture', function(texture, tex)
			if tex == [[Interface\Buttons\ButtonHilight-Square]] or tex == [[Interface\Buttons\UI-PassiveHighlight]] then
				texture:SetColorTexture(1, 1, 1, 0.3)
			end
		end)

		E:RegisterCooldown(cooldown)
	end

	S:HandlePointXY(_G.SpellButton1, 28, -55)

	-- evens
	for i = 2, _G.SPELLS_PER_PAGE, 2 do
		S:HandlePointXY(_G['SpellButton'..i], 163, 0)
	end
	-- odds
	for i = 3, _G.SPELLS_PER_PAGE, 2 do
		S:HandlePointXY(_G['SpellButton'..i], 0, -20)
	end

	hooksecurefunc('SpellButton_UpdateButton', function(button)
		local spellName = _G[button:GetName()..'SpellName']
		local r = spellName:GetTextColor()

		if r < 0.8 then
			spellName:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

	for i = 1, _G.MAX_SKILLLINE_TABS do
		local tab = _G['SpellBookSkillLineTab'..i]
		local flash = _G['SpellBookSkillLineTab'..i..'Flash']

		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
		tab:SetTemplate('Default', true)
		tab.pushed = true

		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

		if i == 1 then
			tab:Point('TOPLEFT', _G.SpellBookSideTabsFrame, 'TOPRIGHT', -32, -70)
		end

		hooksecurefunc(tab:GetHighlightTexture(), 'SetTexture', function(texture, tex)
			if tex ~= nil then
				texture:SetPushedTexture(nil)
			end
		end)

		hooksecurefunc(tab:GetCheckedTexture(), 'SetTexture', function(texture, tex)
			if tex ~= nil then
				texture:SetHighlightTexture(nil)
			end
		end)

		flash:Kill()
	end
end

S:AddCallback('SpellBookFrame')

