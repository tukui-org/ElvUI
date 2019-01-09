local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SkinTab(tab)
	-- Avoid a lua error when using the character boost. The spells are learned through "combat training" and are not ready to be skinned.
	-- sometimes this needs to be done again; i think it has to do with leveling up, maybe, im not 100% sure.
	local normTex = tab.GetNormalTexture and tab:GetNormalTexture()
	if normTex then
		normTex:SetTexCoord(unpack(E.TexCoords))
		normTex:SetInside()
	end

	if tab.isSkinned then return end

	tab:StripTextures()
	tab.pushed = true;
	tab:CreateBackdrop("Default")
	tab.backdrop:SetAllPoints()
	tab:StyleButton(true)
	hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
		if texPath ~= nil then
			self:SetPushedTexture(nil);
		end
	end)

	hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
		if texPath ~= nil then
			self:SetHighlightTexture(nil);
		end
	end)

	local point, relatedTo, point2, _, y = tab:GetPoint()
	tab:Point(point, relatedTo, point2, 1, y)

	tab.isSkinned = true
end

local function SkinSkillLine()
	for i=1, _G.MAX_SKILLLINE_TABS do
		SkinTab(_G["SpellBookSkillLineTab"..i])
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true then return end

	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame, true)

	for _, object in pairs({ "SpellBookSpellIconsFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame" }) do
		_G[object]:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		_G.SpellBookFrameTutorialButton:Kill()
	end

	if E.private.skins.parchmentRemover.enable then
		_G.SpellBookPage1:SetAlpha(0)
		_G.SpellBookPage2:SetAlpha(0)
		_G.SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
	else
		local pagebackdrop = CreateFrame("Frame", nil, SpellBookFrame)
		pagebackdrop:SetTemplate("Default")
		pagebackdrop:Point("TOPLEFT", _G.SpellBookPage1, "TOPLEFT", -2, 2)
		pagebackdrop:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -8, 4)
		SpellBookFrame.pagebackdrop = pagebackdrop
		for i = 1, 2 do
			_G['SpellBookPage'..i]:SetParent(pagebackdrop)
			_G['SpellBookPage'..i]:SetDrawLayer('BACKGROUND', 3)
		end
	end

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton)
	S:HandleNextPrevButton(_G.SpellBookNextPageButton)

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		local icon = _G["SpellButton"..i.."IconTexture"]
		local highlight =_G["SpellButton"..i.."Highlight"]

		highlight:SetColorTexture(1, 1, 1, 0.3)
		highlight:SetAllPoints(icon)

		for j = 1, button:GetNumRegions() do
			local region = select(j, button:GetRegions())
			if region:IsObjectType("Texture") then
				if region ~= button.FlyoutArrow and region ~= button.GlyphIcon and region ~= button.GlyphActivate
					and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture then
					region:SetTexture(nil)
				end
			end
		end

		S:HandleTexture(icon)
		icon:SetAllPoints()
		E:RegisterCooldown(_G["SpellButton"..i.."Cooldown"])
		button:CreateBackdrop("Default", true)

		if button.SpellHighlightTexture then
			button.SpellHighlightTexture:SetColorTexture(0.8, 0.8, 0, 0.6)
			if icon then
				button.SpellHighlightTexture:SetOutside(button.backdrop)
			end
			E:Flash(button.SpellHighlightTexture, 1, true)
		end

		if button.shine then
			button.shine:ClearAllPoints()
			button.shine:Point('TOPLEFT', button, 'TOPLEFT', -3, 3)
			button.shine:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 3, -3)
		end
	end

	hooksecurefunc("SpellButton_UpdateButton", function()
		for i = 1, _G.SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			local icon = _G["SpellButton"..i.."IconTexture"]

			if button.SpellHighlightTexture then
				button.SpellHighlightTexture:SetColorTexture(0.8, 0.8, 0, 0.6)
				if icon then
					button.SpellHighlightTexture:SetOutside(button.backdrop)
				end
				E:Flash(button.SpellHighlightTexture, 1, true)
			end
			if E.private.skins.parchmentRemover.enable then
				button:SetHighlightTexture('')
				local r = button.SpellName:GetTextColor()
				if r < 0.8 then
					button.SpellName:SetTextColor(0.6, 0.6, 0.6)
				else
					button.SpellName:SetTextColor(1, 1, 1)
				end
				button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)
				button.RequiredLevelString:SetTextColor(0.6, 0.6, 0.6)
			end
		end
	end)

	-- needs review
	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", SkinSkillLine)
	_G.SpellBookFrame_UpdateSkillLineTabs() --This update fixes issue with tab textures being empty on first show

	--Profession Tab
	local professionbuttons = {
		"PrimaryProfession1SpellButtonTop",
		"PrimaryProfession1SpellButtonBottom",
		"PrimaryProfession2SpellButtonTop",
		"PrimaryProfession2SpellButtonBottom",
		"SecondaryProfession1SpellButtonLeft",
		"SecondaryProfession1SpellButtonRight",
		"SecondaryProfession2SpellButtonLeft",
		"SecondaryProfession2SpellButtonRight",
		"SecondaryProfession3SpellButtonLeft",
		"SecondaryProfession3SpellButtonRight",
	}

	local professionheaders = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3",
	}

	for _, header in pairs(professionheaders) do
		_G[header.."Missing"]:SetTextColor(1, 1, 0)

		if E.private.skins.parchmentRemover.enable then
			_G[header].missingText:SetTextColor(1, 1, 1)
		else
			_G[header].missingText:SetTextColor(0, 0, 0)
		end
	end

	for _, button in pairs(professionbuttons) do
		button = _G[button]
		button:StripTextures()
		button:SetTemplate("Transparent")
		button.iconTexture:SetTexCoord(unpack(E.TexCoords))
		button.iconTexture:SetInside()
		button.highlightTexture:SetInside()

		if button == _G[professionbuttons[2]] then
			button:Point("TOPLEFT", _G[professionbuttons[1]], "BOTTOMLEFT", 0, -2)
		elseif button == _G[professionbuttons[4]] then
			button:Point("TOPLEFT", _G[professionbuttons[3]], "BOTTOMLEFT", 0, -2)
		end

		hooksecurefunc(button.highlightTexture, "SetTexture", function(self, texture)
			if texture == "Interface\\Buttons\\ButtonHilight-Square" then
				self:SetColorTexture(1, 1, 1, 0.3)
			end
		end)
	end

	local professionstatusbars = {
		"PrimaryProfession1StatusBar",
		"PrimaryProfession2StatusBar",
		"SecondaryProfession1StatusBar",
		"SecondaryProfession2StatusBar",
		"SecondaryProfession3StatusBar",
	}

	for _, statusbar in pairs(professionstatusbars) do
		statusbar = _G[statusbar]
		statusbar:StripTextures()
		statusbar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusbar)
		statusbar:SetStatusBarColor(0, 220/255, 0)
		statusbar:CreateBackdrop("Default")

		statusbar.rankText:ClearAllPoints()
		statusbar.rankText:Point("CENTER")
	end

	--Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G["SpellBookFrameTabButton"..i])
	end

	_G.SpellBookFrameTabButton1:ClearAllPoints()
	_G.SpellBookFrameTabButton1:Point('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', 0, 2)
end

S:AddCallback("Spellbook", LoadSkin)
