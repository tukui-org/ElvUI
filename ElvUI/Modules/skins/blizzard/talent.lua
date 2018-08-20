local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local C_SpecializationInfo_GetSpellsDisplay = C_SpecializationInfo.GetSpellsDisplay
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetNumSpecializations = GetNumSpecializations
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationSpells = GetSpecializationSpells
local GetSpellTexture = GetSpellTexture
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

	for i = 1, 3 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])

		if i == 1 then
			local point, anchor, anchorPoint, x = _G['PlayerTalentFrameTab'..i]:GetPoint()
			_G['PlayerTalentFrameTab'..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end

	hooksecurefunc('PlayerTalentFrame_UpdateTabs', function()
		for i = 1, 3 do
			local point, anchor, anchorPoint, x = _G['PlayerTalentFrameTab'..i]:GetPoint()
			_G['PlayerTalentFrameTab'..i]:Point(point, anchor, anchorPoint, x, -4)
		end
	end)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetColorTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)

	for i = 1, 2 do
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
			ic:SetDrawLayer("OVERLAY", 1)
			ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:CreateBackdrop("Overlay")
			bu.bg:SetFrameLevel(bu:GetFrameLevel() -2)
			bu.bg:Point("TOPLEFT", 15, -1)
			bu.bg:Point("BOTTOMRIGHT", -10, 1)

			bu.bg.SelectedTexture = bu.bg:CreateTexture(nil, 'ARTWORK')
			bu.bg.SelectedTexture:Point("TOPLEFT", bu, "TOPLEFT", 15, -1)
			bu.bg.SelectedTexture:Point("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -10, 1)
			bu.bg.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)

			bu.ShadowedTexture = bu:CreateTexture(nil, 'OVERLAY', nil, 2)
			bu.ShadowedTexture:SetColorTexture(0, 0, 0, 0.6)
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
				local ic = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j.."IconTexture"]
				if bu.bg and bu.knownSelection then
					if bu.knownSelection:IsShown() then
						bu.bg.SelectedTexture:Show()
						bu.ShadowedTexture:Hide()
					else
						bu.ShadowedTexture:SetAllPoints(bu.bg.SelectedTexture)
						bu.bg.SelectedTexture:Hide()
						bu.ShadowedTexture:Show()

						-- blizz sets the unselected ones to desaturate but with the shadow overlay we dont have to
						ic:SetDesaturated(false)
					end
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
		local numSpecs = GetNumSpecializations(nil, self.isPet)
		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child
		scrollChild.specIcon:SetTexture(icon)

		local index = 1
		local bonuses
		local bonusesIncrement = 1
		if self.isPet then
			bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)}
			bonusesIncrement = 2
		else
			bonuses = C_SpecializationInfo_GetSpellsDisplay(id)
		end

		if bonuses then
			for i = 1, #bonuses, bonusesIncrement do
				local frame = scrollChild["abilityButton"..index]
				if frame then
					local _, spellTex = GetSpellTexture(bonuses[i])
					if spellTex then
						frame.icon:SetTexture(spellTex)
					end

					if not frame.reskinned then
						frame.reskinned = true
						frame.ring:Hide()
						frame.icon:SetTexCoord(unpack(E.TexCoords))
					end
				end
				index = index + 1
			end
		end

		for i = 1, numSpecs do
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
		bu.specIcon:SetDrawLayer('ARTWORK', 2)
		bu.roleIcon:SetDrawLayer('ARTWORK', 2)

		bu.SelectedTexture = bu:CreateTexture(nil, 'ARTWORK')
		bu.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
	end

	buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]
			_G["PlayerTalentFrameSpecializationSpecButton"..i.."Glow"]:Kill()

			bu.bg:SetAlpha(0)
			bu.learnedTex:SetAlpha(0)
			bu.selectedTex:SetAlpha(0)

			bu:CreateBackdrop("Overlay")
			bu.backdrop:Point("TOPLEFT", 8, 2)
			bu.backdrop:Point("BOTTOMRIGHT", 10, -2)

			local highlightTex = bu:CreateTexture(nil, 'ARTWORK')
			highlightTex:SetColorTexture(1, 1, 1, 0.2)
			highlightTex:SetInside(bu.backdrop)
			bu:SetHighlightTexture(highlightTex)

			bu.border = CreateFrame("Frame", nil, bu)
			bu.border:SetOutside(bu.specIcon)
			bu.border:SetTemplate("Default", nil, true)
			bu.border:SetBackdropColor(0, 0, 0, 0)
			bu.border.backdropTexture:SetAlpha(0)
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
			bu.specIcon:SetDrawLayer('ARTWORK', 2)
			bu.roleIcon:SetDrawLayer('ARTWORK', 2)

			bu.SelectedTexture = bu:CreateTexture(nil, 'ARTWORK')
			bu.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
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

	-- PVP Talents
	local function SkinPvpTalentSlots(button)
		button._elvUIBG = S:CropIcon(button.Texture, button)
		button.Texture:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
		button.Arrow:SetPoint("LEFT", button.Texture, "RIGHT", 5, 0)
		button.Arrow:SetSize(26, 13)
		button.Border:Hide()

		button:SetSize(button:GetSize())
		button.Texture:SetSize(32, 32)
		button.TalentName:SetPoint("TOP", button, "BOTTOM", 0, 0)
	end

	local function SkinPvpTalentTrinketSlot(button)
		SkinPvpTalentSlots(button)
		button.Texture:SetTexture([[Interface\Icons\INV_Jewelry_Trinket_04]])
		button.Texture:SetSize(48, 48)
		button.Arrow:SetSize(26, 13)
	end

	local PvpTalentFrame = PlayerTalentFrameTalents.PvpTalentFrame
	PvpTalentFrame:StripTextures()

	PvpTalentFrame.Swords:SetSize(72, 67)
	PvpTalentFrame.Orb:Hide()
	PvpTalentFrame.Ring:Hide()

	-- Skin the PvP Icons
	SkinPvpTalentTrinketSlot(PvpTalentFrame.TrinketSlot)
	SkinPvpTalentSlots(PvpTalentFrame.TalentSlot1)
	SkinPvpTalentSlots(PvpTalentFrame.TalentSlot2)
	SkinPvpTalentSlots(PvpTalentFrame.TalentSlot3)

	PvpTalentFrame.TalentList:StripTextures()
	PvpTalentFrame.TalentList:CreateBackdrop("Transparent")

	PvpTalentFrame.TalentList:SetPoint("BOTTOMLEFT", PlayerTalentFrame, "BOTTOMRIGHT", 5, 26)
	S:SkinTalentListButtons(PvpTalentFrame.TalentList)
	PvpTalentFrame.TalentList.MyTopLeftCorner:Hide()
	PvpTalentFrame.TalentList.MyTopRightCorner:Hide()
	PvpTalentFrame.TalentList.MyTopBorder:Hide()

	local function HandleInsetButton(Button)
		S:HandleButton(Button)

		if Button.LeftSeparator then
			Button.LeftSeparator:Hide()
		end
		if Button.RightSeparator then
			Button.RightSeparator:Hide()
		end
	end

	local TalentList_CloseButton = select(4, PlayerTalentFrameTalents.PvpTalentFrame.TalentList:GetChildren())
	if TalentList_CloseButton and TalentList_CloseButton:HasScript("OnClick") then
		HandleInsetButton(TalentList_CloseButton)
	end

	PvpTalentFrame.TalentList.ScrollFrame:SetPoint("TOPLEFT", 5, -5)
	PvpTalentFrame.TalentList.ScrollFrame:SetPoint("BOTTOMRIGHT", -21, 32)
	PvpTalentFrame.OrbModelScene:SetAlpha(0)

	PvpTalentFrame:SetSize(131, 379)
	PvpTalentFrame:SetPoint("LEFT", PlayerTalentFrameTalents, "RIGHT", -135, 0)
	PvpTalentFrame.Swords:SetPoint("BOTTOM", 0, 30)
	PvpTalentFrame.Label:SetPoint("BOTTOM", 0, 104)
	PvpTalentFrame.InvisibleWarmodeButton:SetAllPoints(PvpTalentFrame.Swords)

	PvpTalentFrame.TrinketSlot:SetPoint("TOP", 0, -16)
	PvpTalentFrame.TalentSlot1:SetPoint("TOP", PvpTalentFrame.TrinketSlot, "BOTTOM", 0, -16)
	PvpTalentFrame.TalentSlot2:SetPoint("TOP", PvpTalentFrame.TalentSlot1, "BOTTOM", 0, -10)
	PvpTalentFrame.TalentSlot3:SetPoint("TOP", PvpTalentFrame.TalentSlot2, "BOTTOM", 0, -10)

	for i = 1, 10 do
		local bu = _G["PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameButton"..i]
		if bu then
			local border = bu:GetRegions()
			if border then border:SetTexture(nil) end

			bu:StyleButton()
			bu:CreateBackdrop("Overlay")

			if bu.Selected then
				bu.Selected:SetTexture(nil)

				bu.selectedTexture = bu:CreateTexture(nil, 'ARTWORK')
				bu.selectedTexture:SetInside(bu)
				bu.selectedTexture:SetColorTexture(0, 1, 0, 0.2)
				bu.selectedTexture:SetShown(bu.Selected:IsShown())

				hooksecurefunc(bu, "Update", function(selectedHere)
					if not bu.selectedTexture then return end
					if bu.Selected:IsShown() then
						bu.selectedTexture:SetShown(selectedHere)
					else
						bu.selectedTexture:Hide()
					end
				end)
			end

			bu.backdrop:SetAllPoints()

			if bu.Icon then
				bu.Icon:SetTexCoord(unpack(E.TexCoords))
				bu.Icon:SetDrawLayer('ARTWORK', 1)
			end
		end
	end

	S:HandleButton(PlayerTalentFrameTalentsPvpTalentButton)
	S:HandleScrollBar(PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameScrollBar)

	S:HandleCloseButton(PlayerTalentFrameTalentsPvpTalentFrame.TrinketSlot.HelpBox.CloseButton)
	S:HandleCloseButton(PlayerTalentFrameTalentsPvpTalentFrame.WarmodeTutorialBox.CloseButton)
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)
