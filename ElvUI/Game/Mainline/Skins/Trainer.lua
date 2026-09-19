local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function ClassTrainerScrollUpdateChild(button)
	if not button.IsSkinned then
		S:HandleIcon(button.icon, true)
		button:CreateBackdrop('Transparent')
		button.backdrop:Point('TOPLEFT', button.icon, 'TOPRIGHT', 1, 0)
		button.backdrop:Point('BOTTOMRIGHT', button.icon, 'BOTTOMRIGHT', 253, 0)

		button.name:SetParent(button.backdrop)
		button.name:Point('TOPLEFT', button.icon, 'TOPRIGHT', 6, -2)
		button.subText:SetParent(button.backdrop)
		button.money:SetParent(button.backdrop)
		button.money:Point('TOPRIGHT', button, 'TOPRIGHT', 5, -8)

		button:SetNormalTexture(E.Media.Textures.Invisible)
		button:SetHighlightTexture(E.Media.Textures.Invisible)
		button.disabledBG:SetTexture()
		button.selectedTex:SetInside(button.backdrop)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		button.selectedTex:SetColorTexture(r, g, b, .25)

		button.IsSkinned = true
	end
end

local function ClassTrainerScrollUpdate(frame)
	frame:ForEachFrame(ClassTrainerScrollUpdateChild)
end

function S:Blizzard_TrainerUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer) then return end

	_G.ClassTrainerFrameSkillStepButton:StripTextures()
	_G.ClassTrainerFrameBottomInset:StripTextures()
	_G.ClassTrainerFramePortrait:Kill()

	_G.ClassTrainerTrainButton:StripTextures()
	S:HandleButton(_G.ClassTrainerTrainButton)

	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandlePortraitFrame(ClassTrainerFrame)

	hooksecurefunc(ClassTrainerFrame.ScrollBox, 'Update', ClassTrainerScrollUpdate)

	S:HandleTrimScrollBar(_G.ClassTrainerFrame.ScrollBar)
	S:HandleButton(_G.ClassTrainerFrame.FilterDropdown)

	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 5)
	ClassTrainerFrame:SetTemplate('Transparent')

	local stepButton = _G.ClassTrainerFrameSkillStepButton
	stepButton:SetTemplate()
	stepButton.icon:SetTexCoords()
	stepButton.selectedTex:SetColorTexture(1,1,1,0.3)
	_G.ClassTrainerFrameSkillStepButtonHighlight:SetColorTexture(1,1,1,0.3)

	local ClassTrainerStatusBar = _G.ClassTrainerStatusBar
	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:CreateBackdrop()
	ClassTrainerStatusBar.rankText:ClearAllPoints()
	ClassTrainerStatusBar.rankText:Point('CENTER', ClassTrainerStatusBar, 'CENTER')
	E:RegisterStatusBar(ClassTrainerStatusBar)
end

S:AddCallbackForAddon('Blizzard_TrainerUI')
