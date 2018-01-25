local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetNumSpecializations = GetNumSpecializations
local GetPrestigeInfo = GetPrestigeInfo
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationSpells = GetSpecializationSpells
local GetSpellTexture = GetSpellTexture
local UnitPrestige = UnitPrestige
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: MAX_PVP_TALENT_TIERS, MAX_PVP_TALENT_COLUMNS, SPEC_SPELLS_DISPLAY
-- GLOBALS: MAX_TALENT_TIERS, NUM_TALENT_COLUMNS, PlayerSpecTab1, PlayerSpecTab2

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G["PlayerTalentFrame"]
	local objects = {
		PlayerTalentFrame,
		PlayerTalentFrameInset,
		PlayerTalentFrameTalents,
		PlayerTalentFramePVPTalents.Talents
	}

	for _, object in pairs(objects) do
		object:StripTextures()
	end

	PlayerTalentFramePortrait:Kill()
	PlayerTalentFrame:StripTextures()
	PlayerTalentFrame:CreateBackdrop('Transparent')
	PlayerTalentFrame.backdrop:SetAllPoints()
	PlayerTalentFrame.backdrop:SetFrameLevel(0)
	PlayerTalentFrame.backdrop:Point('BOTTOMRIGHT', PlayerTalentFrame, 'BOTTOMRIGHT', 0, -6)

	PlayerTalentFrameInset:StripTextures()
	PlayerTalentFrameInset:CreateBackdrop('Default')
	PlayerTalentFrameInset.backdrop:Hide()

	if E.global.general.disableTutorialButtons then
		PlayerTalentFrameSpecializationTutorialButton:Kill()
		PlayerTalentFrameTalentsTutorialButton:Kill()
		PlayerTalentFramePetSpecializationTutorialButton:Kill()
	end

	S:HandleCloseButton(PlayerTalentFrameCloseButton)

	local buttons = {
		PlayerTalentFrameSpecializationLearnButton,
		PlayerTalentFrameTalentsLearnButton,
		PlayerTalentFramePetSpecializationLearnButton
	}

	S:HandleButton(PlayerTalentFrameActivateButton)

	for _, button in pairs(buttons) do
		S:HandleButton(button, true)
		local point, anchor, anchorPoint, x = button:GetPoint()
		button:Point(point, anchor, anchorPoint, x, -28)
	end

	for i=1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])

		if i == 1 then
			local point, anchor, anchorPoint, x = _G['PlayerTalentFrameTab'..i]:GetPoint()
			_G['PlayerTalentFrameTab'..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end

	hooksecurefunc('PlayerTalentFrame_UpdateTabs', function()
		for i=1, 4 do
			local point, anchor, anchorPoint, x = _G['PlayerTalentFrameTab'..i]:GetPoint()
			_G['PlayerTalentFrameTab'..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetColorTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

	for i=1, 2 do
		local tab = _G['PlayerSpecTab'..i]
		_G['PlayerSpecTab'..i..'Background']:Kill()

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()

		tab.pushed = true;
		tab:CreateBackdrop("Default")
		tab.backdrop:SetAllPoints()
		tab:StyleButton(true)
		hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then
				self:SetTexture(nil)
			end
		end)
		hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then
				self:SetTexture(nil)
			end
		end)
	end

	hooksecurefunc('PlayerTalentFrame_UpdateSpecs', function()
		local point, relatedTo, point2, _, y = PlayerSpecTab1:GetPoint()
		PlayerSpecTab1:Point(point, relatedTo, point2, E.PixelMode and -1 or 1, y)
	end)

	for i = 1, MAX_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow"..i]
		_G["PlayerTalentFrameTalentsTalentRow"..i.."Bg"]:Hide()
		row:DisableDrawLayer("BORDER")
		row:StripTextures()

		row.TopLine:Point("TOP", 0, 4)
		row.BottomLine:Point("BOTTOM", 0, -4)

		for j = 1, NUM_TALENT_COLUMNS do
			local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
			local ic = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j.."IconTexture"]

			bu:StripTextures()
			bu:SetFrameLevel(bu:GetFrameLevel() + 5)
			bu:CreateBackdrop("Default")
			bu.backdrop:SetOutside(ic)
			bu.knownSelection:SetAlpha(0)
			ic:SetDrawLayer("OVERLAY")
			ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:CreateBackdrop("Overlay")
			bu.bg:SetFrameLevel(bu:GetFrameLevel() -2)
			bu.bg:Point("TOPLEFT", 15, -1)
			bu.bg:Point("BOTTOMRIGHT", -10, 1)
			bu.bg.SelectedTexture = bu.bg:CreateTexture(nil, 'ARTWORK')
			bu.bg.SelectedTexture:Point("TOPLEFT", bu, "TOPLEFT", 15, -1)
			bu.bg.SelectedTexture:Point("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -10, 1)
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
				if bu.knownSelection:IsShown() then
					bu.bg.SelectedTexture:Show()
					bu.bg.SelectedTexture:SetColorTexture(0, 1, 0, 0.1)
				else
					bu.bg.SelectedTexture:Hide()
				end
			end
		end
	end)

	for i = 1, 5 do
		select(i, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	local pspecspell = _G["PlayerTalentFrameSpecializationSpellScrollFrameScrollChild"]
	pspecspell.ring:Hide()
	pspecspell:CreateBackdrop("Default")
	pspecspell.backdrop:SetOutside(pspecspell.specIcon)
	pspecspell.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	pspecspell.specIcon:SetParent(pspecspell.backdrop)

	local specspell2 = _G["PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild"]
	specspell2.ring:Hide()
	specspell2:CreateBackdrop("Default")
	specspell2.backdrop:SetOutside(specspell2.specIcon)
	specspell2.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	specspell2.specIcon:SetParent(specspell2.backdrop)

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1

		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child

		scrollChild.specIcon:SetTexture(icon)

		local index = 1
		local bonuses
		if self.isPet then
			bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet)}
		else
			bonuses = SPEC_SPELLS_DISPLAY[id]
		end
		if bonuses then
			for i = 1, #bonuses, 2 do
				local frame = scrollChild["abilityButton"..index]
				local _, icon = GetSpellTexture(bonuses[i])
				if frame then
					frame.icon:SetTexture(icon)
					if not frame.reskinned then
						frame.reskinned = true
						frame:Size(30, 30)
						frame.ring:Hide()
						frame:SetTemplate("Default")
						frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						frame.icon:SetInside()
					end
				end

				index = index + 1
			end
		end

		for i = 1, GetNumSpecializations(nil, self.isPet) do
			local bu = self["specButton"..i]
			bu.SelectedTexture:SetInside(bu.backdrop)
			if bu.selected then
				bu.SelectedTexture:Show()
			else
				bu.SelectedTexture:Hide()
			end
		end
	end)

	for i = 1, GetNumSpecializations(false, nil) do
		local bu = PlayerTalentFrameSpecialization["specButton"..i]
		local _, _, _, icon = GetSpecializationInfo(i, false, nil)

		bu.ring:Hide()

		bu.specIcon:SetTexture(icon)
		bu.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		bu.specIcon:SetSize(50, 50)
		bu.specIcon:Point("LEFT", bu, "LEFT", 15, 0)
		bu.SelectedTexture = bu:CreateTexture(nil, 'ARTWORK')
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
	end

	buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]
			_G["PlayerTalentFrameSpecializationSpecButton"..i.."Glow"]:Kill()

			local tex = bu:CreateTexture(nil, 'ARTWORK')
			tex:SetColorTexture(1, 1, 1, 0.1)
			bu:SetHighlightTexture(tex)
			bu.bg:SetAlpha(0)
			bu.learnedTex:SetAlpha(0)
			bu.selectedTex:SetAlpha(0)

			bu:CreateBackdrop("Overlay")
			bu.backdrop:Point("TOPLEFT", 8, 2)
			bu.backdrop:Point("BOTTOMRIGHT", 10, -2)
			bu:GetHighlightTexture():SetInside(bu.backdrop)

			bu.border = CreateFrame("Frame", nil, bu)
			bu.border:CreateBackdrop("Default")
			bu.border.backdrop:SetOutside(bu.specIcon)
		end
	end

	if E.myclass == "HUNTER" then
		for i = 1, 6 do
			select(i, PlayerTalentFramePetSpecialization:GetRegions()):Hide()
		end

		for i=1, PlayerTalentFramePetSpecialization:GetNumChildren() do
			local child = select(i, PlayerTalentFramePetSpecialization:GetChildren())
			if child and not child:GetName() then
				child:DisableDrawLayer("OVERLAY")
			end
		end

		for i = 1, 5 do
			select(i, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end

		for i = 1, GetNumSpecializations(false, true) do
			local bu = PlayerTalentFramePetSpecialization["specButton"..i]
			local _, _, _, icon = GetSpecializationInfo(i, false, true)

			bu.ring:Hide()
			bu.specIcon:SetTexture(icon)
			bu.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			bu.specIcon:SetSize(50, 50)
			bu.specIcon:Point("LEFT", bu, "LEFT", 15, 0)

			bu.SelectedTexture = bu:CreateTexture(nil, 'ARTWORK')
			bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetColorTexture(1, 1, 1, 0.2)
	end

	PlayerTalentFrameSpecialization:DisableDrawLayer('ARTWORK')
	PlayerTalentFrameSpecialization:DisableDrawLayer('BORDER')
	for i=1, PlayerTalentFrameSpecialization:GetNumChildren() do
		local child = select(i, PlayerTalentFrameSpecialization:GetChildren())
		if child and not child:GetName() then
			child:DisableDrawLayer("OVERLAY")
		end
	end

	--Skin talent rows and buttons
	for i = 1, MAX_PVP_TALENT_TIERS do
		local row = PlayerTalentFramePVPTalents.Talents["Tier"..i]
		row.Bg:Hide()
		row:DisableDrawLayer("BORDER")
		row:StripTextures()
		row.GlowFrame:Kill() --We can either kill or reposition the glows. Not sure which is preferred.
		-- row.GlowFrame.TopGlowLine:SetPoint("TOP", 0, 5)
		-- row.GlowFrame.BottomGlowLine:SetPoint("BOTTOM", 0, -5)

		row.TopLine:Point("TOP", 0, 4)
		row.BottomLine:Point("BOTTOM", 0, -4)

		for j = 1, MAX_PVP_TALENT_COLUMNS do
			local button = row["Talent"..j];
			local icon = button.Icon

			button:StripTextures()
			button:SetFrameLevel(button:GetFrameLevel() + 5)
			button:CreateBackdrop("Default")
			button.backdrop:SetOutside(icon)
			icon:SetDrawLayer("OVERLAY")
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:CreateBackdrop("Overlay")
			button.bg:SetFrameLevel(button:GetFrameLevel() -2)
			button.bg:Point("TOPLEFT", 15, -1)
			button.bg:Point("BOTTOMRIGHT", -10, 1)
			button.bg.SelectedTexture = button.bg:CreateTexture(nil, 'ARTWORK')
			button.bg.SelectedTexture:Point("TOPLEFT", button, "TOPLEFT", 15, -1)
			button.bg.SelectedTexture:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -10, 1)
		end
	end

	--Apply color to chosen talents
	hooksecurefunc("PVPTalentFrame_Update", function(self)
		for i = 1, MAX_PVP_TALENT_TIERS do
			for j = 1, MAX_PVP_TALENT_COLUMNS do
				local button = self.Talents["Tier"..i]["Talent"..j]
				if button.knownSelection then
					if button.knownSelection:IsShown() then
						button.bg.SelectedTexture:Show()
						button.bg.SelectedTexture:SetColorTexture(0, 1, 0, 0.1)
					else
						button.bg.SelectedTexture:Hide()
					end
				end
			end
		end
	end)

	--Create portrait element for the PvP Talent Frame so we can see prestige
	local portrait = PlayerTalentFramePVPTalents:CreateTexture(nil, "OVERLAY")
	portrait:SetSize(57,57);
	portrait:SetPoint("CENTER", PlayerTalentFramePVPTalents.PortraitBackground, "CENTER", 0, 0);
	--Kill background
	PlayerTalentFramePVPTalents.PortraitBackground:Kill()
	--Reposition portrait by repositioning the background
	PlayerTalentFramePVPTalents.PortraitBackground:ClearAllPoints()
	PlayerTalentFramePVPTalents.PortraitBackground:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", 5, -5)
	--Reposition the wreath
	PlayerTalentFramePVPTalents.SmallWreath:ClearAllPoints()
	PlayerTalentFramePVPTalents.SmallWreath:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -2, -25)
	--Update texture according to prestige
	hooksecurefunc("PlayerTalentFramePVPTalents_SetUp", function()
		local prestigeLevel = UnitPrestige("player");
		if (prestigeLevel > 0) then
			portrait:SetTexture(GetPrestigeInfo(prestigeLevel));
		end
	end)

	-- Prestige Level Dialog
	PVPTalentPrestigeLevelDialog:StripTextures()
	PVPTalentPrestigeLevelDialog:CreateBackdrop('Transparent')
	PVPTalentPrestigeLevelDialog.Laurel:SetAtlas("honorsystem-prestige-laurel", true) --Re-add textures removed by StripTextures()
	PVPTalentPrestigeLevelDialog.TopDivider:SetAtlas("honorsystem-prestige-rewardline", true)
	PVPTalentPrestigeLevelDialog.BottomDivider:SetAtlas("honorsystem-prestige-rewardline", true)
	S:HandleButton(PVPTalentPrestigeLevelDialog.Accept)
	S:HandleButton(PVPTalentPrestigeLevelDialog.Cancel)
	S:HandleCloseButton(PVPTalentPrestigeLevelDialog.CloseButton) --There are 2 buttons with the exact same name, may not be able to skin it properly until fixed by Blizzard.

	S:SkinPVPHonorXPBar('PlayerTalentFramePVPTalents')

	-- Tutorial
	S:HandleCloseButton(PlayerTalentFramePVPTalents.TutorialBox.CloseButton)
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)