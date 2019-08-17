local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetNumSpecializations = GetNumSpecializations
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationSpells = GetSpecializationSpells
local GetSpellTexture = GetSpellTexture
local UnitSex = UnitSex
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo
local C_SpecializationInfo_GetSpellsDisplay = C_SpecializationInfo.GetSpellsDisplay

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandlePortraitFrame(PlayerTalentFrame, true)

	_G.PlayerTalentFrameTalents:StripTextures()


	if E.global.general.disableTutorialButtons then
		_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
		_G.PlayerTalentFramePetSpecializationTutorialButton:Kill()
	end

	local buttons = {
		_G.PlayerTalentFrameSpecializationLearnButton,
		_G.PlayerTalentFrameTalentsLearnButton,
		_G.PlayerTalentFramePetSpecializationLearnButton
	}

	S:HandleButton(_G.PlayerTalentFrameActivateButton)

	for _, button in pairs(buttons) do
		S:HandleButton(button)
	end

	for i = 1, 3 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	for _, Frame in pairs({ _G.PlayerTalentFrameSpecialization, _G.PlayerTalentFramePetSpecialization }) do
		Frame:StripTextures()

		for _, Child in pairs({Frame:GetChildren()}) do
			if Child:IsObjectType("Frame") and not Child:GetName() then
				Child:StripTextures()
			end
		end

		for i = 1, 4 do
			local Button = Frame['specButton'..i]
			local _, _, _, icon = GetSpecializationInfo(i, false, Frame.isPet)

			_G["PlayerTalentFrameSpecializationSpecButton"..i.."Glow"]:Kill()

			Button:CreateBackdrop()
			Button.backdrop:Point("TOPLEFT", 8, 2)
			Button.backdrop:Point("BOTTOMRIGHT", 10, -2)
			Button.specIcon:Size(50, 50)
			Button.specIcon:Point("LEFT", Button, "LEFT", 15, 0)
			Button.specIcon:SetDrawLayer('ARTWORK', 2)
			Button.roleIcon:SetDrawLayer('ARTWORK', 2)

			Button.bg:SetAlpha(0)
			Button.ring:SetAlpha(0)
			Button.learnedTex:SetAlpha(0)
			Button.selectedTex:SetAlpha(0)
			Button.specIcon:SetTexture(icon)
			S:HandleIcon(Button.specIcon, true)
			Button:SetHighlightTexture(nil)

			Button.SelectedTexture = Button:CreateTexture(nil, 'ARTWORK')
			Button.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
		end

		Frame.spellsScroll.child.gradient:Kill()
		Frame.spellsScroll.child.scrollwork_topleft:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_topright:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_bottomleft:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_bottomright:SetAlpha(0)
		Frame.spellsScroll.child.ring:SetAlpha(0)
		Frame.spellsScroll.child.Seperator:SetAlpha(0)

		S:HandleIcon(Frame.spellsScroll.child.specIcon, true)
	end

	do
		local onFinished = function(self)
			local r, g, b = self:GetChange()
			local defaultR, defaultG, defaultB = unpack(E.media.bordercolor)
			defaultR = E:Round(defaultR, 2)
			defaultG = E:Round(defaultG, 2)
			defaultB = E:Round(defaultB, 2)

			if r == defaultR and g == defaultG and b == defaultB then
				self:SetChange(unpack(E.media.rgbvaluecolor))
			else
				self:SetChange(defaultR, defaultG, defaultB)
			end
		end

		local onShow = function(self)
			local parent = self:GetParent()
			if not parent.transition:IsPlaying() then
				for _, child in pairs(parent.transition.color.children) do
					child:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				parent.transition:Play()
			end
		end

		local onHide = function(self)
			local parent = self:GetParent()
			if parent.transition:IsPlaying() then
				parent.transition:Stop()

				for _, child in pairs(parent.transition.color.children) do
					child:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end

		for i = 1, _G.MAX_TALENT_TIERS do
			local row = _G.PlayerTalentFrameTalents['tier'..i]
			row:StripTextures()

			row.TopLine:Point("TOP", 0, 4)
			row.BottomLine:Point("BOTTOM", 0, -4)

			row.transition = _G.CreateAnimationGroup(row)
			row.transition:SetLooping(true)

			row.transition.color = row.transition:CreateAnimation("Color")
			row.transition.color:SetDuration(0.7)
			row.transition.color:SetColorType("border")
			row.transition.color:SetChange(unpack(E.media.rgbvaluecolor))
			row.transition.color:SetScript("OnFinished", onFinished)

			row.GlowFrame:StripTextures()
			row.GlowFrame:HookScript('OnShow', onShow)
			row.GlowFrame:HookScript('OnHide', onHide)

			for j = 1, _G.NUM_TALENT_COLUMNS do
				local bu = row['talent'..j]

				bu:StripTextures()
				bu:SetFrameLevel(bu:GetFrameLevel() + 5)
				bu.knownSelection:SetAlpha(0)
				bu.icon:SetDrawLayer("OVERLAY", 1)
				S:HandleIcon(bu.icon, true)

				bu.bg = CreateFrame("Frame", nil, bu)
				bu.bg:CreateBackdrop("Overlay")
				bu.bg:SetFrameLevel(bu:GetFrameLevel() - 4)
				bu.bg:Point("TOPLEFT", 15, -1)
				bu.bg:Point("BOTTOMRIGHT", -10, 1)
				row.transition.color:AddChild(bu.bg.backdrop)

				bu.GlowFrame:Kill()

				bu.bg.SelectedTexture = bu.bg:CreateTexture(nil, 'ARTWORK')
				bu.bg.SelectedTexture:Point("TOPLEFT", bu, "TOPLEFT", 15, -1)
				bu.bg.SelectedTexture:Point("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -10, 1)
				bu.bg.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)

				bu.ShadowedTexture = bu:CreateTexture(nil, 'OVERLAY', nil, 2)
				bu.ShadowedTexture:SetColorTexture(0, 0, 0, 0.6)
			end
		end
	end

	hooksecurefunc("TalentFrame_Update", function(self)
		for i = 1, _G.MAX_TALENT_TIERS do
			for j = 1, _G.NUM_TALENT_COLUMNS do
				local bu = self['tier'..i]['talent'..j]
				if bu.bg and bu.knownSelection then
					if bu.knownSelection:IsShown() then
						bu.bg.SelectedTexture:Show()
						bu.ShadowedTexture:Hide()
					else
						bu.ShadowedTexture:SetAllPoints(bu.bg.SelectedTexture)
						bu.bg.SelectedTexture:Hide()
						bu.ShadowedTexture:Show()
						bu.icon:SetDesaturated(false)
					end
				end
			end
		end
	end)

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, _G.PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1
		local numSpecs = GetNumSpecializations(nil, self.isPet)
		local sex = self.isPet and UnitSex("pet") or UnitSex("player")
		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
		if not id then return end
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

		for i = 1, numSpecs do
			local bu = self["specButton"..i]
			bu.SelectedTexture:SetInside(bu.backdrop)
			if bu.selected then
				bu.SelectedTexture:Show()
			else
				bu.SelectedTexture:Hide()
			end
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
						frame.icon:Size(40, 40)
						frame:CreateBackdrop()
						frame.backdrop:SetOutside(frame.icon)
					end
				end
				index = index + 1
			end
		end

		-- Hide the default flash anim
		self.learnButton.Flash:Hide()
		self.learnButton.FlashAnim:Stop()
	end)

	local PvpTalentFrame = _G.PlayerTalentFrameTalents.PvpTalentFrame
	PvpTalentFrame:StripTextures()

	for _, button in pairs(PvpTalentFrame.Slots) do
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.Texture)

		button.Arrow:SetAlpha(0)
		button.Border:Hide()

		hooksecurefunc(button, "Update", function(self)
			local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(self.slotIndex);
			if (not slotInfo) then
				return;
			end

			if (slotInfo.enabled) then
				S:HandleIcon(self.Texture)
				if (not slotInfo.selectedTalentID) then
					self.Texture:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
					self.backdrop:SetBackdropBorderColor(0, 1, 0, 1)
				else
					self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				self.Texture:SetTexture([[Interface\PetBattles\PetBattle-LockIcon]])
				self.Texture:SetTexCoord(0, 1, 0, 1)
				self.Texture:SetDesaturated(true)
				self.Texture:Show()
				self.backdrop:SetBackdropBorderColor(1, 0, 0, 1)
			end
		end)
	end

	PvpTalentFrame.TalentList:StripTextures()
	PvpTalentFrame.TalentList:CreateBackdrop("Transparent")

	PvpTalentFrame.TalentList:Point("BOTTOMLEFT", PlayerTalentFrame, "BOTTOMRIGHT", 5, 26)
	S:SkinTalentListButtons(PvpTalentFrame.TalentList)

	local TalentList_CloseButton = select(4, _G.PlayerTalentFrameTalents.PvpTalentFrame.TalentList:GetChildren())
	if TalentList_CloseButton and TalentList_CloseButton:HasScript("OnClick") then
		S:HandleButton(TalentList_CloseButton, true)
	end

	PvpTalentFrame.TalentList.ScrollFrame:Point("TOPLEFT", 5, -5)
	PvpTalentFrame.TalentList.ScrollFrame:Point("BOTTOMRIGHT", -21, 32)
	PvpTalentFrame.OrbModelScene:SetAlpha(0)

	PvpTalentFrame:Size(131, 379)
	PvpTalentFrame:Point("LEFT", _G.PlayerTalentFrameTalents, "RIGHT", -135, 0)
	PvpTalentFrame.Swords:Point("BOTTOM", 0, 30)
	PvpTalentFrame.Label:Point("BOTTOM", 0, 104)
	PvpTalentFrame.InvisibleWarmodeButton:SetAllPoints(PvpTalentFrame.Swords)

	PvpTalentFrame.Swords:Size(72, 67)
	PvpTalentFrame.Orb:Hide()
	PvpTalentFrame.Ring:Hide()

	PvpTalentFrame.TrinketSlot:Point("TOP", 0, -16)
	PvpTalentFrame.TalentSlot1:Point("TOP", PvpTalentFrame.TrinketSlot, "BOTTOM", 0, -16)
	PvpTalentFrame.TalentSlot2:Point("TOP", PvpTalentFrame.TalentSlot1, "BOTTOM", 0, -10)
	PvpTalentFrame.TalentSlot3:Point("TOP", PvpTalentFrame.TalentSlot2, "BOTTOM", 0, -10)

	for _, Button in pairs(PvpTalentFrame.TalentList.ScrollFrame.buttons) do
		Button:DisableDrawLayer("BACKGROUND")
		S:HandleIcon(Button.Icon)
		Button:StyleButton()
		Button:CreateBackdrop()
		Button.Selected:SetTexture()
		Button.backdrop:SetAllPoints()

		Button.selectedTexture = Button:CreateTexture(nil, 'ARTWORK')
		Button.selectedTexture:SetInside(Button)
		Button.selectedTexture:SetColorTexture(0, 1, 0, 0.2)
		Button.selectedTexture:SetShown(Button.Selected:IsShown())
	end

	hooksecurefunc(PvpTalentFrame.TalentList, "Update", function()
		for _, Button in pairs(PvpTalentFrame.TalentList.ScrollFrame.buttons) do
			if not Button.selectedTexture then return end
			if Button.Selected:IsShown() then
				Button.selectedTexture:SetShown(true)
			else
				Button.selectedTexture:Hide()
			end
		end
	end)

	S:HandleButton(_G.PlayerTalentFrameTalents.PvpTalentButton)
	S:HandleScrollBar(_G.PlayerTalentFrameTalents.PvpTalentFrame.TalentList.ScrollFrame.ScrollBar)

	S:HandleCloseButton(_G.PlayerTalentFrameTalents.PvpTalentFrame.TrinketSlot.HelpBox.CloseButton)
	S:HandleCloseButton(_G.PlayerTalentFrameTalents.PvpTalentFrame.WarmodeTutorialBox.CloseButton)
end

S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)
