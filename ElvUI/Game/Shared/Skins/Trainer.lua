local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_TrainerUI', nil, nil, nil, nil, nil, 'trainer')

-- TrainerUICategoryTemplate, keep the Blizzard plus / minus
local function HandleCategory(button)
	button.LeftPiece:SetAlpha(0)
	button.CenterPiece:SetAlpha(0)
	button.RightPiece:SetAlpha(0)

	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 0, 1)
end

local function ClassTrainerScrollUpdateChild(button)
	if not button.IsSkinned then
		if not button.icon then -- Forever category headers
			HandleCategory(button)
		else
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
		end

		button.IsSkinned = true
	end
end

local function ClassTrainerScrollUpdate(frame)
	frame:ForEachFrame(ClassTrainerScrollUpdateChild)
end

local function SetSelection()
	local skillIcon = _G.ClassTrainerSkillIcon
	local skillTexture = skillIcon:GetNormalTexture()
	if skillTexture then -- nothing selected yet
		skillTexture:SetInside()
		skillTexture:SetTexCoords()

		skillIcon:SetTemplate()
	end
end

local function SkinMainline()
	_G.ClassTrainerFrameSkillStepButton:StripTextures()
	_G.ClassTrainerFrameBottomInset:StripTextures()
	_G.ClassTrainerFramePortrait:Kill()

	_G.ClassTrainerTrainButton:StripTextures()
	S:HandleButton(_G.ClassTrainerTrainButton)

	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandlePortraitFrame(ClassTrainerFrame)

	hooksecurefunc(ClassTrainerFrame.ScrollBox, 'Update', ClassTrainerScrollUpdate)

	S:HandleTrimScrollBar(ClassTrainerFrame.ScrollBar)
	S:HandleButton(ClassTrainerFrame.FilterDropdown)

	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 5)

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

	local money = E.Forever and ClassTrainerFrame.money or _G.ClassTrainerFrameMoneyFrame -- ToDo: Forever
	money:CreateBackdrop('Transparent')
	money.backdrop:SetOutside(money, 4, 4)

	local trainingPoints = ClassTrainerFrame.trainingPoints
	if trainingPoints then
		trainingPoints:CreateBackdrop('Transparent')
		trainingPoints.backdrop:SetOutside(trainingPoints, 4, 4)
	end
end

local function SkinClassic()
	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandleFrame(ClassTrainerFrame, true, nil, 11, -12, -32, 76)

	_G.ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(_G.ClassTrainerFrame.FilterDropdown)
	_G.ClassTrainerFrame.FilterDropdown:Point('TOPRIGHT', -40, -64)

	_G.ClassTrainerListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerListScrollFrameScrollBar)

	_G.ClassTrainerDetailScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerDetailScrollFrameScrollBar)

	_G.ClassTrainerSkillIcon:StripTextures()

	_G.ClassTrainerCancelButton:Kill()

	_G.ClassTrainerMoneyFrame:ClearAllPoints()
	_G.ClassTrainerMoneyFrame:Point('BOTTOMLEFT', _G.ClassTrainerFrame, 'BOTTOMLEFT', 18, 82)

	S:HandleButton(_G.ClassTrainerTrainButton)
	_G.ClassTrainerTrainButton:Point('BOTTOMRIGHT', -36, 80)

	hooksecurefunc('ClassTrainer_SetSelection', SetSelection)

	for i = 1, _G.CLASS_TRAINER_SKILLS_DISPLAYED do
		local button = _G['ClassTrainerSkill'..i]
		S:HandleCollapseTexture(button, nil, true)

		local normal = button:GetNormalTexture()
		normal:Size(16)
		normal:Point('LEFT', 5, 0)

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.ClearTexture)
		highlight.SetTexture = E.noop
	end

	local ClassTrainerCollapseAllButton = _G.ClassTrainerCollapseAllButton
	S:HandleCollapseTexture(ClassTrainerCollapseAllButton, nil, true)
	ClassTrainerCollapseAllButton:SetHighlightTexture(E.ClearTexture)
end

function S:Blizzard_TrainerUI()
	if E.Modern then
		SkinMainline()
	else
		SkinClassic()
	end
end
