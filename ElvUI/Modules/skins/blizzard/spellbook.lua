local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select, unpack = select, unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true then return end
	S:HandleCloseButton(SpellBookFrameCloseButton)
	SpellBookFrame:SetTemplate("Transparent")

	local StripAllTextures = {
		"SpellBookFrame",
		"SpellBookFrameInset",
		"SpellBookSpellIconsFrame",
		"SpellBookSideTabsFrame",
		"SpellBookPageNavigationFrame",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		SpellBookFrameTutorialButton:Kill()
	end

	local pagebackdrop = CreateFrame("Frame", nil, SpellBookFrame)
	pagebackdrop:SetTemplate("Default")
	pagebackdrop:Point("TOPLEFT", SpellBookPage1, "TOPLEFT", -2, 2)
	pagebackdrop:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -8, 4)
	SpellBookFrame.pagebackdrop = pagebackdrop

	for i=1, 2 do
		_G['SpellBookPage'..i]:SetParent(pagebackdrop)
		_G['SpellBookPage'..i]:SetDrawLayer('BACKGROUND', 3)
	end

	S:HandleNextPrevButton(SpellBookPrevPageButton)
	S:HandleNextPrevButton(SpellBookNextPageButton)

	--Skin SpellButtons
	local function SpellButtons(self, first)
		for i=1, SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			local icon = _G["SpellButton"..i.."IconTexture"]

			if not InCombatLockdown() then
				button:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 5)
			end

			if first then
				--button:StripTextures()
				for i=1, button:GetNumRegions() do
					local region = select(i, button:GetRegions())
					if region:GetObjectType() == "Texture" then
						if region ~= button.FlyoutArrow and region ~= button.GlyphIcon and region ~= button.GlyphActivate
							and region ~= button.AbilityHighlight then
							if E.wowbuild >= 23623 then --7.2
								if region ~= button.SpellHighlightTexture then
									region:SetTexture(nil)
								end
							else
								region:SetTexture(nil)
							end
						end
					end
				end
			end

			if _G["SpellButton"..i.."Highlight"] then
				_G["SpellButton"..i.."Highlight"]:SetColorTexture(1, 1, 1, 0.3)
				_G["SpellButton"..i.."Highlight"]:ClearAllPoints()
				_G["SpellButton"..i.."Highlight"]:SetAllPoints(icon)
			end

			if button.shine then
				button.shine:ClearAllPoints()
				button.shine:Point('TOPLEFT', button, 'TOPLEFT', -3, 3)
				button.shine:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 3, -3)
			end

			if icon then
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:ClearAllPoints()
				icon:SetAllPoints()

				if not button.backdrop then
					button:CreateBackdrop("Default", true)
				end
			end
		end
	end
	SpellButtons(nil, true)
	hooksecurefunc("SpellButton_UpdateButton", SpellButtons)

	-- needs review
	local function SkinTab(tab)
		if tab.isSkinned then return; end

		tab:StripTextures()
		-- Avoid a lua error when using the character boost. The spells are learned through "combat training" and are not ready to be skinned.
		if tab:GetNormalTexture() then
			tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			tab:GetNormalTexture():SetInside()
		end
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

		local point, relatedTo, point2, x, y = tab:GetPoint()
		tab:Point(point, relatedTo, point2, 1, y)

		tab.isSkinned = true
	end

	local function SkinSkillLine()
		for i=1, MAX_SKILLLINE_TABS do
			local tab = _G["SpellBookSkillLineTab"..i]
			SkinTab(tab)
		end
	end
	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", SkinSkillLine)
	SpellBookFrame_UpdateSkillLineTabs() --This update fixes issue with tab textures being empty on first show

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
		"SecondaryProfession4SpellButtonLeft",
		"SecondaryProfession4SpellButtonRight",
	}

	local professionheaders = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3",
		"SecondaryProfession4",
	}

	for _, header in pairs(professionheaders) do
		_G[header.."Missing"]:SetTextColor(1, 1, 0)
		_G[header].missingText:SetTextColor(0, 0, 0)
	end

	for _, button in pairs(professionbuttons) do
		local icon = _G[button.."IconTexture"]
		local button = _G[button]
		button:StripTextures()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()

			button:SetFrameLevel(button:GetFrameLevel() + 2)
			if not button.backdrop then
				button:CreateBackdrop("Default", true)
				button.backdrop:SetAllPoints()
			end
		end
	end

	local professionstatusbars = {
		"PrimaryProfession1StatusBar",
		"PrimaryProfession2StatusBar",
		"SecondaryProfession1StatusBar",
		"SecondaryProfession2StatusBar",
		"SecondaryProfession3StatusBar",
		"SecondaryProfession4StatusBar",
	}

	for _, statusbar in pairs(professionstatusbars) do
		local statusbar = _G[statusbar]
		statusbar:StripTextures()
		statusbar:SetStatusBarTexture(E["media"].normTex)
		E:RegisterStatusBar(statusbar)
		statusbar:SetStatusBarColor(0, 220/255, 0)
		statusbar:CreateBackdrop("Default")

		statusbar.rankText:ClearAllPoints()
		statusbar.rankText:Point("CENTER")
	end

	--Bottom Tabs
	for i=1, 5 do
		S:HandleTab(_G["SpellBookFrameTabButton"..i])
	end

	SpellBookFrameTabButton1:ClearAllPoints()
	SpellBookFrameTabButton1:Point('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', 0, 2)
end

S:AddCallback("Spellbook", LoadSkin)