local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "MyRolePlaySkin"
local function SkinMyRolePlay(self)
	hooksecurefunc(mrp, "CreateBrowseFrame", function()
		if (AS:CheckOption("MyRolePlaySkin")) then 
			local bg = CreateFrame("Frame", nil, MyRolePlayBrowseFrame)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT")
			bg:SetFrameLevel(MyRolePlayBrowseFrame:GetFrameLevel()-1)
			bg:SetTemplate("Transparent")

			MyRolePlayBrowseFrame:DisableDrawLayer("BACKGROUND")
			MyRolePlayBrowseFrame:DisableDrawLayer("BORDER")
			MyRolePlayBrowseFramePortraitFrame:Hide()
			MyRolePlayBrowseFrameTopBorder:Hide()
			MyRolePlayBrowseFrameTopRightCorner:Hide()
			MyRolePlayBrowseFrameInset:DisableDrawLayer("BORDER")
			MyRolePlayBrowseFrameInsetBg:Hide()

			S:HandleTab(MyRolePlayBrowseFrameTab1)
			S:HandleTab(MyRolePlayBrowseFrameTab2)

			MyRolePlayBrowseFramePortrait:Hide()

			S:HandleCloseButton(MyRolePlayBrowseFrameCloseButton)
			S:HandleScrollBar(MyRolePlayBrowseFrameAScrollFrameScrollBar)
			S:HandleScrollBar(MyRolePlayBrowseFrameBScrollFrameScrollBar)
		end
	end)

	hooksecurefunc(mrp, "AddMRPTab", function()
		if (AS:CheckOption("MyRolePlaySkin")) then
			S:HandleTab(CharacterFrameTab5)
		end
	end)

	hooksecurefunc(mrp, "CreateEditFrames", function()
		if (AS:CheckOption("MyRolePlaySkin")) then
			MyRolePlayMultiEditFrame:DisableDrawLayer("BORDER")
			MyRolePlayMultiEditFrameBg:Hide()
			MyRolePlayMultiEditFrameScrollFrameTop:Hide()
			MyRolePlayMultiEditFrameScrollFrameBottom:Hide()

			MyRolePlayCharacterFrame.ver:SetPoint("TOP", CharacterFrameInset, "TOP", -110, 17)
			S:HandleButton(MyRolePlayMultiEditFrameOK)
			S:HandleButton(MyRolePlayMultiEditFrameCancel)
			S:HandleButton(MyRolePlayMultiEditFrameInherit)
			S:HandleButton(MyRolePlayComboEditFrameOK)
			S:HandleButton(MyRolePlayComboEditFrameCancel)
			S:HandleButton(MyRolePlayComboEditFrameInherit)
			S:HandleButton(MyRolePlayCharacterFrame_NewProfileButton)
			S:HandleButton(MyRolePlayCharacterFrame_RenProfileButton)
			S:HandleButton(MyRolePlayCharacterFrame_DelProfileButton)
			S:HandleButton(MyRolePlayEditFrameOK)
			S:HandleButton(MyRolePlayEditFrameCancel)
			S:HandleButton(MyRolePlayEditFrameInherit)
			MyRolePlayCharacterFrame_NewProfileButton:Point("LEFT", MyRolePlayCharacterFrame_ProfileComboBox_Button, "RIGHT", 37, 0)
			MyRolePlayEditFrame.editbox:Height(25)
			MyRolePlayEditFrame.editbox:SetBackdrop({
				bgFile = "",
				edgeFile = "",
				tile = true,
				tileSize = 0,
				edgeSize = 0,
				insets = { left = 0, right = 0, top = 0, bottom = 0	},
			} )

			MyRolePlayEditFrame.editbox:CreateBackdrop()
			MyRolePlayCharacterFrame_ProfileComboBox:SetPoint("TOP", CharacterFrameInset, "TOP", 0, 22)
			MyRolePlayCharacterFrame_ProfileComboBox.text:SetPoint("LEFT", MyRolePlayCharacterFrame_ProfileComboBox, "LEFT", 8, 0)
			S:HandleNextPrevButton(MyRolePlayCharacterFrame_ProfileComboBox_Button)
			MyRolePlayCharacterFrame_ProfileComboBox:StripTextures()
			MyRolePlayCharacterFrame_ProfileComboBox:CreateBackdrop()
			MyRolePlayCharacterFrame_ProfileComboBox:Size(100,20)
			MyRolePlayCharacterFrame_ProfileComboBox_Button:ClearAllPoints()
			MyRolePlayCharacterFrame_ProfileComboBox_Button:SetPoint("RIGHT", MyRolePlayCharacterFrame_ProfileComboBox, "RIGHT", 0 , 0)
		--	MyRolePlayComboEditFrameComboBox:StripTextures()
		--	MyRolePlayComboEditFrameComboBox:CreateBackdrop()
		--	S:HandleEditBox(MyRolePlayComboEditFrameComboBox)
		--	MyRolePlayComboEditFrameComboBox:Size(100,20)
		--	MyRolePlayComboEditFrameComboBoxButton:ClearAllPoints()
		--	MyRolePlayComboEditFrameComboBoxButton:SetPoint("RIGHT", MyRolePlayComboEditFrameComboBox, "RIGHT", 0 , 0)
		--	S:HandleNextPrevButton(MyRolePlayComboEditFrameComboBoxButton)
			S:HandleScrollBar(MyRolePlayMultiEditFrameScrollFrameScrollBar)
		end
	end)

	hooksecurefunc(mrp, "CreateOptionsPanel", function()
		if (AS:CheckOption("MyRolePlaySkin")) then
			S:HandleCheckBox(MyRolePlayOptionsPanel_Enable)
			S:HandleCheckBox(MyRolePlayOptionsPanel_MRPButton)
			S:HandleCheckBox(MyRolePlayOptionsPanel_RPChatName)
			S:HandleCheckBox(MyRolePlayOptionsPanel_Biog)
			S:HandleCheckBox(MyRolePlayOptionsPanel_FormAC)
			S:HandleCheckBox(MyRolePlayOptionsPanel_EquipAC)
			S:HandleDropDownBox(MyRolePlayOptionsPanel_TTStyle)
			S:HandleDropDownBox(MyRolePlayOptionsPanel_HeightUnit)
			S:HandleDropDownBox(MyRolePlayOptionsPanel_WeightUnit)
		end
	end)

	local function reskinHeader(c, field)
		if (AS:CheckOption("MyRolePlaySkin")) then
			for i = 1, field:GetNumChildren() do
				local f = select(i, field:GetChildren())
				if not f.reskinned then
					f.h.SetBackdrop = E.noop
					f:StripTextures(True)
					f.h:CreateBackdrop()
					f.h:StripTextures(True)
					f.h.fs:SetPoint("TOPLEFT", f.h, "TOPLEFT", 0, 1)

				if f.sep then
					f.sep:SetAlpha(0)
				end

				f.reskinned = true
				end
			end
		end
	end

	hooksecurefunc(mrp, "CreateCFpfield", reskinHeader)
	hooksecurefunc(mrp, "CreateBFpfield", reskinHeader)
end

AS:RegisterSkin(name,SkinMyRolePlay)