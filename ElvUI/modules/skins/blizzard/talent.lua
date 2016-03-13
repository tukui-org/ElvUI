local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local objects = {
		PlayerTalentFrame,
		PlayerTalentFrameInset,
		PlayerTalentFrameTalents
	}

	for _, object in pairs(objects) do
		object:StripTextures()
	end

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


	PlayerTalentFrameTalentsClearInfoFrame:CreateBackdrop('Default')
	PlayerTalentFrameTalentsClearInfoFrame.icon:SetTexCoord(unpack(E.TexCoords))
	PlayerTalentFrameTalentsClearInfoFrame:Width(PlayerTalentFrameTalentsClearInfoFrame:GetWidth() - 2)
	PlayerTalentFrameTalentsClearInfoFrame:Height(PlayerTalentFrameTalentsClearInfoFrame:GetHeight() - 2)
	PlayerTalentFrameTalentsClearInfoFrame.icon:Size(PlayerTalentFrameTalentsClearInfoFrame:GetSize())
	PlayerTalentFrameTalentsClearInfoFrame:Point('TOPLEFT', PlayerTalentFrameTalents, 'BOTTOMLEFT', 8, -8)

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

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
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
		local point, relatedTo, point2, x, y = PlayerSpecTab1:GetPoint()
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
					bu.bg.SelectedTexture:SetTexture(0, 1, 0, 0.1)
				else
					bu.bg.SelectedTexture:Hide()
				end
				if bu.learnSelection:IsShown() then
					bu.bg.SelectedTexture:Show()
					bu.bg.SelectedTexture:SetTexture(1, 1, 0, 0.1)
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
		bu.SelectedTexture:SetTexture(1, 1, 0, 0.1)
	end

	local buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]
			_G["PlayerTalentFrameSpecializationSpecButton"..i.."Glow"]:Kill()

			local tex = bu:CreateTexture(nil, 'ARTWORK')
			tex:SetTexture(1, 1, 1, 0.1)
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
			bu.SelectedTexture:SetTexture(1, 1, 0, 0.1)
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(0.2)
	end

	PlayerTalentFrameSpecialization:DisableDrawLayer('ARTWORK')
	PlayerTalentFrameSpecialization:DisableDrawLayer('BORDER')
	for i=1, PlayerTalentFrameSpecialization:GetNumChildren() do
		local child = select(i, PlayerTalentFrameSpecialization:GetChildren())
		if child and not child:GetName() then
			child:DisableDrawLayer("OVERLAY")
		end
	end
end

S:RegisterSkin("Blizzard_TalentUI", LoadSkin)