local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SpellHighlightSetTexture(texture, tex)
	if tex == [[Interface\Buttons\ButtonHilight-Square]] or tex == [[Interface\Buttons\UI-PassiveHighlight]] then
		texture:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function UpdateButton()
	if _G.SpellBookFrame.bookType == _G.BOOKTYPE_PROFESSION then
		return
	end

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local highlight = _G['SpellButton'..i..'Highlight']

		if button.backdrop then
			button.backdrop:SetShown(button.SpellName:IsShown())
		end

		if highlight then
			if highlight:IsShown() then
				E:Flash(highlight, 1, true)
			else
				E:StopFlash(highlight, 1)
			end
		end

		button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)

		local r = button.SpellName:GetTextColor()
		if r < 0.8 then
			button.SpellName:SetTextColor(0.8, 0.8, 0.8)
		elseif r ~= 1 then
			button.SpellName:SetTextColor(1, 1, 1)
		end
	end
end

function S:SpellBookFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	S:HandleFrame(_G.SpellBookFrame, true, nil, 11, -12, -32, 76)

	local showAllRanks = _G.ShowAllSpellRanksCheckbox
	if showAllRanks then
		S:HandleCheckBox(showAllRanks)
		showAllRanks:Point('TOPLEFT', 20, -20)
	end

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

		tab.backdrop:Point('TOPLEFT', 14, -14)
		tab.backdrop:Point('BOTTOMRIGHT', -14, 22)
	end

	-- Reposition Tabs
	_G.SpellBookFrameTabButton1:ClearAllPoints()
	_G.SpellBookFrameTabButton1:Point('TOPLEFT', _G.SpellBookFrame, 'BOTTOMLEFT', -3, 89)
	_G.SpellBookFrameTabButton2:Point('TOPLEFT', _G.SpellBookFrameTabButton1, 'TOPRIGHT', -27, 0)
	_G.SpellBookFrameTabButton3:Point('TOPLEFT', _G.SpellBookFrameTabButton2, 'TOPRIGHT', -27, 0)

	-- Spell Buttons
	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local cooldown = _G['SpellButton'..i..'Cooldown']
		local highlight = _G['SpellButton'..i..'Highlight']

		for _, region in next, { button:GetRegions() } do
			if region:IsObjectType('Texture') and region:GetTexture() ~= [[Interface\Buttons\ActionBarFlyoutButton]] then
				region:SetTexture(nil)
			end
		end

		E:RegisterCooldown(cooldown)
		S:HandleIcon(icon)

		button:CreateBackdrop(nil, true)
		icon:SetInside(button.backdrop)

		button.bg = CreateFrame('Frame', nil, button)
		button.bg:SetTemplate('Transparent')
		button.bg:Point('TOPLEFT', -6, 6)
		button.bg:Point('BOTTOMRIGHT', 112, -6)
		button.bg:Height(46)
		button.bg:OffsetFrameLevel(-1, button)

		highlight:SetAllPoints()
		hooksecurefunc(highlight, 'SetTexture', SpellHighlightSetTexture)
		hooksecurefunc(button, 'UpdateButton', UpdateButton)
	end

	_G.SpellButton1:PointXY(28, -55)

	-- evens
	for i = 2, _G.SPELLS_PER_PAGE, 2 do
		_G['SpellButton'..i]:PointXY(163, 0)
	end
	-- odds
	for i = 3, _G.SPELLS_PER_PAGE, 2 do
		_G['SpellButton'..i]:PointXY(0, -20)
	end

	for i = 1, _G.MAX_SKILLLINE_TABS do
		local tab = _G['SpellBookSkillLineTab'..i]
		if tab then
			tab:StripTextures()
			tab:SetTemplate(nil, true)
			tab:StyleButton(nil, true)

			local normalTexture = tab:GetNormalTexture()
			if normalTexture then
				normalTexture:SetInside()
				normalTexture:SetTexCoords()
			end

			if i == 1 then
				tab:Point('TOPLEFT', _G.SpellBookSideTabsFrame, 'TOPRIGHT', -31, -70)
			end
		end

		local flash = _G['SpellBookSkillLineTab'..i..'Flash']
		if flash then
			flash:Kill()
		end
	end
end

S:AddCallback('SpellBookFrame')
