local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "MasterLootManagerRemixSkin"
local function SkinMLM(self)
	local StripAllTextures = {
				"MasterLootManagerMain",
				"MasterLootLoggerFrame",
				"MasterLootLoggerFrameContentScrollFrame",
				"MasterLootLoggerAddEditFrame",
				}

	local SetTemplateD = { -- Default Texture
				"MasterLootLoggerFrameContentColumnHeader1",
				"MasterLootLoggerFrameContentColumnHeader2",
				"MasterLootLoggerFrameContentColumnHeader3",
				"MasterLootLoggerFrameContentColumnHeader4",
				"MasterLootLoggerFrameContentColumnHeader5",
				"MasterLootLoggerFrameContentColumnHeader6",																			
				}

	local SetTemplateT = {-- Transparent Texture
				"MasterLootManagerMain",
				"MasterLootManagerMain_ScrollFrame",
				"MasterLootLoggerFrame",
				"MasterLootLoggerAddEditFrame",
				}	

	local buttons = {
				"MasterLootManagerMain_Countdown",
				"MasterLootManagerMain_SelectItem",
				"MasterLootManagerMain_AnnounceLoot",
				"MasterLootManagerMain_AnnounceMainSpec",
				"MasterLootManagerMain_AnnounceOffSpec",
				"MasterLootManagerMain_AnnounceNoSpec",
				"MasterLootManagerMain_AwardLoot",
				"MasterLootManagerMain_Settings",
				"MasterLootManagerMain_AssignDE",
				"MasterLootManagerMain_AssignBank",
				"MasterLootLoggerFrameContentExportButton",
				"MasterLootLoggerFrameContentClearButton",
				"MasterLootLoggerFrameContentAddButton",
				"MasterLootLoggerFrameContentEditButton",
				"MasterLootLoggerFrameContentDeleteButton",
				"MasterLootLoggerAddEditFrameConfirm",
				}

	local checkboxes = {
				"MasterLootLoggerAddEditFrameItem",
				"MasterLootLoggerAddEditFrameSource",
				"MasterLootLoggerAddEditFrameWinner",
				"MasterLootLoggerAddEditFrameValue",
				"MasterLootLoggerAddEditFrameMonth",
				"MasterLootLoggerAddEditFrameDay",
				"MasterLootLoggerAddEditFrameYear",
				"MasterLootLoggerAddEditFrameHour",
				"MasterLootLoggerAddEditFrameMinute",
				}

	for _, object in pairs(StripAllTextures) do
                _G[object]:StripTextures()
	end	

	for _, object in pairs(SetTemplateD) do
				_G[object]:SetTemplate("Default")
	end	

	for _, object in pairs(SetTemplateT) do
				_G[object]:SetTemplate("Transparent")
	end	

	-- Skin Buttons
	for _, button in pairs(buttons) do
					S:HandleButton(_G[button])
	end	

	-- Skin CheckBoxes
	for _, button in pairs(checkboxes) do
					S:HandleCheckBox(_G[button])
	end	

	-- Move this
		MasterLootManagerMain_AssignDE:Point("TOPLEFT",  MasterLootManagerMain_SelectDE, "TOPRIGHT", 10, -2)
		MasterLootManagerMain_AssignBank:Point("TOPLEFT",  MasterLootManagerMain_SelectBank, "TOPRIGHT", 10, -2)
		MasterLootManagerMain_ScrollFrame:Point("TOPLEFT", MasterLootManagerMain, "TOPLEFT", 10, -105)
		MasterLootManagerMain_ScrollFrame:Point("TOPRIGHT", MasterLootManagerMain, "TOPRIGHT", -26, -105)
		MasterLootLoggerFrameContentColumnHeader1:ClearAllPoints()
		MasterLootLoggerFrameContentColumnHeader1:Point("LEFT", MasterLootLoggerButton1, "TOPLEFT", 0, 20)
		MasterLootLoggerFrameContentColumnHeader2:Point("LEFT", MasterLootLoggerFrameContentColumnHeader1, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentColumnHeader3:Point("LEFT", MasterLootLoggerFrameContentColumnHeader2, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentColumnHeader4:Point("LEFT", MasterLootLoggerFrameContentColumnHeader3, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentColumnHeader5:Point("LEFT", MasterLootLoggerFrameContentColumnHeader4, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentColumnHeader6:Point("LEFT", MasterLootLoggerFrameContentColumnHeader5, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentClearButton:Point("LEFT", MasterLootLoggerFrameContentExportButton, "RIGHT", 5, 0)
		MasterLootLoggerFrameContentAddButton:Point("RIGHT", MasterLootLoggerFrameContentEditButton, "LEFT", -5, 0)
		MasterLootLoggerFrameContentEditButton:Point("RIGHT", MasterLootLoggerFrameContentDeleteButton, "LEFT", -5, 0)
		MasterLootLoggerAddEditFrameMonth:Point("TOPLEFT", MasterLootLoggerAddEditFrameDateLabel, "BOTTOMLEFT", 0, 0)
		MasterLootLoggerAddEditFrameDay:Point("LEFT", MasterLootLoggerAddEditFrameMonth, "RIGHT", 2, 0)
		MasterLootLoggerAddEditFrameYear:Point("LEFT", MasterLootLoggerAddEditFrameDay, "RIGHT", 2, 0)
		MasterLootLoggerAddEditFrameHour:Point("TOPLEFT", MasterLootLoggerAddEditFrameTimeLabel, "BOTTOMLEFT", 0, 0)
		MasterLootLoggerAddEditFrameMinute:Point("LEFT", MasterLootLoggerAddEditFrameHour, "RIGHT", 0, 0)
		
	-- Change Size
		MasterLootLoggerAddEditFrameMonth:SetJustifyH("CENTER")
		MasterLootLoggerAddEditFrameMonth:SetWidth(25)
		MasterLootLoggerAddEditFrameDay:SetJustifyH("CENTER")
		MasterLootLoggerAddEditFrameDay:SetWidth(25)
		MasterLootLoggerAddEditFrameYear:SetJustifyH("CENTER")
		MasterLootLoggerAddEditFrameYear:SetWidth(45)
		MasterLootLoggerAddEditFrameHour:SetJustifyH("CENTER")
		MasterLootLoggerAddEditFrameHour:SetWidth(25)
		MasterLootLoggerAddEditFrameMinute:SetJustifyH("CENTER")
		MasterLootLoggerAddEditFrameMinute:SetWidth(25)
		
	-- Skin Dropdowns 
		S:HandleDropDownBox(MasterLootManagerMain_SelectDE, 150)
		S:HandleDropDownBox(MasterLootManagerMain_SelectBank, 150)
		S:HandleDropDownBox(MasterLootLoggerAddEditFrameType, 150)

	-- Scrollbar
		S:HandleScrollBar(MasterLootManagerMain_ScrollFrame_Slider, 5)
		S:HandleScrollBar(MasterLootLoggerFrameContentScrollFrameScrollBar)

	-- Skin CloseButtons
		S:HandleCloseButton(MasterLootLoggerFrameCloseButton)
		S:HandleCloseButton(MasterLootLoggerAddEditFrameCloseButton)
end

AS:RegisterSkin(name,SkinMLM)