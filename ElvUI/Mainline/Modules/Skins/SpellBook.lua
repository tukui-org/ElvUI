local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, select = pairs, select
local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local hooksecurefunc = hooksecurefunc
local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION

local function clearBackdrop(self)
	self:SetBackdropColor(0, 0, 0, 1)
end

local function spellButtonHighlight(button, texture)
	if texture == [[Interface\Buttons\ButtonHilight-Square]] then
		button:SetColorTexture(1, 1, 1, 0.3)
	end
end

function S:SpellBookFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame)

	-- hide flyout backgrounds
	_G.SpellFlyoutHorizontalBackground:SetAlpha(0)
	_G.SpellFlyoutVerticalBackground:SetAlpha(0)
	_G.SpellFlyoutBackgroundEnd:SetAlpha(0)

	for _, object in pairs({ 'SpellBookSpellIconsFrame', 'SpellBookSideTabsFrame', 'SpellBookPageNavigationFrame' }) do
		_G[object]:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		_G.SpellBookFrameTutorialButton:Kill()
	end

	if E.private.skins.parchmentRemoverEnable then
		_G.SpellBookPage1:SetAlpha(0)
		_G.SpellBookPage2:SetAlpha(0)
		_G.SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
	else
		local pagebackdrop = CreateFrame('Frame', nil, SpellBookFrame)
		pagebackdrop:SetTemplate()
		pagebackdrop:Point('TOPLEFT', _G.SpellBookPage1, 'TOPLEFT', -2, 2)
		pagebackdrop:Point('BOTTOMRIGHT', SpellBookFrame, 'BOTTOMRIGHT', -8, 4)
		SpellBookFrame.pagebackdrop = pagebackdrop

		for i = 1, 2 do
			_G['SpellBookPage'..i]:SetParent(pagebackdrop)
			_G['SpellBookPage'..i]:SetDrawLayer('BACKGROUND', 3)
		end
	end

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(_G.SpellBookNextPageButton, nil, nil, true)

	_G.SpellBookPageText:ClearAllPoints()
	_G.SpellBookPageText:Point('RIGHT', _G.SpellBookPrevPageButton, 'LEFT', -5, 0)

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local highlight =_G['SpellButton'..i..'Highlight']

		for j = 1, button:GetNumRegions() do
			local region = select(j, button:GetRegions())
			if region:IsObjectType('Texture') then
				if region ~= button.FlyoutArrow and region ~= button.GlyphIcon and region ~= button.GlyphActivate
					and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture then
					region:SetTexture()
				end
			end
		end

		E:RegisterCooldown(_G['SpellButton'..i..'Cooldown'])
		S:HandleIcon(icon)

		button:CreateBackdrop(nil, true)
		icon:SetInside(button.backdrop)

		local ht = button.SpellHighlightTexture
		if ht then
			ht:SetColorTexture(0.8, 0.8, 0, 0.6)
			ht:SetInside(button.backdrop)
		end

		if button.shine then
			button.shine:ClearAllPoints()
			button.shine:Point('TOPLEFT', button, 'TOPLEFT', -3, 3)
			button.shine:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 3, -3)
		end

		if E.private.skins.parchmentRemoverEnable then
			button:SetHighlightTexture('')
		end

		highlight:SetAllPoints(icon)
		hooksecurefunc(highlight, 'SetTexture', spellButtonHighlight)
	end

	hooksecurefunc('SpellButton_UpdateButton', function()
		if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
			return
		end

		for i = 1, _G.SPELLS_PER_PAGE do
			local button = _G['SpellButton'..i]
			if button.backdrop then
				button.backdrop:SetShown(button.SpellName:IsShown())
			end

			local ht = button.SpellHighlightTexture
			if ht and ht:IsShown() then
				E:Flash(ht, 1, true)
			elseif ht then
				E:StopFlash(ht)
			end

			if E.private.skins.parchmentRemoverEnable then
				button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)
				button.RequiredLevelString:SetTextColor(0.6, 0.6, 0.6)

				local r = button.SpellName:GetTextColor()
				if r < 0.8 then
					button.SpellName:SetTextColor(0.6, 0.6, 0.6)
				elseif r ~= 1 then
					button.SpellName:SetTextColor(1, 1, 1)
				end
			end
		end
	end)

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)

	for i = 1, 8 do
		local Tab = _G['SpellBookSkillLineTab'..i]
		Tab:StripTextures()
		Tab:SetTemplate()
		Tab:StyleButton(nil, true)
	end

	hooksecurefunc('SpellBookFrame_UpdateSkillLineTabs', function()
		for i = 1, 8 do
			local tex = _G['SpellBookSkillLineTab'..i]:GetNormalTexture()
			if tex then
				S:HandleIcon(tex)
				tex:SetInside()
			end
		end
	end)

	--Profession Tab
	for _, frame in pairs({ _G.SpellBookProfessionFrame:GetChildren() }) do
		frame.missingHeader:SetTextColor(1, 1, 0)

		if E.private.skins.parchmentRemoverEnable then
			frame.missingText:SetTextColor(1, 1, 1)
		else
			frame.missingText:SetTextColor(0, 0, 0)
		end

		local a, b, c, _, e = frame.statusBar:GetPoint()
		frame.statusBar:Point(a, b, c, 0, e)
		frame.statusBar.rankText:Point('CENTER')
		S:HandleStatusBar(frame.statusBar, {0, .86, 0})

		if a == 'BOTTOMLEFT' then
			frame.rank:Point('BOTTOMLEFT', frame.statusBar, 'TOPLEFT', 0, 4)
		elseif a == 'TOPLEFT' then
			frame.rank:Point('TOPLEFT', frame.professionName, 'BOTTOMLEFT', 0, -20)
		end

		if frame.unlearn then
			frame.unlearn:Point('RIGHT', frame.statusBar, 'LEFT', -18, -5)
		end

		if frame.icon then
			S:HandleIcon(frame.icon)

			frame:StripTextures()
			frame.professionName:Point('TOPLEFT', 100, -4)

			frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			frame.backdrop.Center:SetDrawLayer('BORDER', -1)
			frame.backdrop:SetOutside(frame.icon)
			frame.backdrop:SetBackdropColor(0, 0, 0, 1)
			frame.backdrop.callbackBackdropColor = clearBackdrop

			frame.icon:SetDesaturated(false)
			frame.icon:SetAlpha(1)
		end

		for i = 1, 2 do
			local button = frame['button'..i]
			S:HandleButton(button, true, nil, true)

			if i == 1 and button:GetPoint() == 'TOPLEFT' then
				button:Point('TOPLEFT', frame.button2, 'BOTTOMLEFT', 0, -3)
			end

			if button.iconTexture then
				S:HandleIcon(button.iconTexture, true)
			end

			hooksecurefunc(button.highlightTexture, 'SetTexture', spellButtonHighlight)
		end
	end

	--Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G['SpellBookFrameTabButton'..i])
	end

	_G.SpellBookFrameTabButton1:ClearAllPoints()
	_G.SpellBookFrameTabButton1:Point('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', 0, 2)

	-- Some Texture Magic
	hooksecurefunc('FormatProfession', function(frame, id)
		if not (id and frame and frame.icon) then return end

		local texture = select(2, GetProfessionInfo(id))
		if texture then frame.icon:SetTexture(texture) end
	end)
end

S:AddCallback('SpellBookFrame')
