local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Credit to Camealion

local function cbResizeAll(self)
    for i=1,20,1 do
        local checkbox = _G["ACP_AddonListEntry" .. i .. "Enabled"]
        local collapse = _G["ACP_AddonListEntry" .. i .. "Collapse"]
        local security = _G["ACP_AddonListEntry" .. i .. "Security"]
        local curr_category = ""

		if curr_category == "" then
			checkbox:SetPoint("LEFT", 5, 0)
			if collapse:IsShown() then
				checkbox:Size(26)
			else
				checkbox:SetPoint("LEFT", 15, 0)
				checkbox:Size(20)
			end
		end
		if security:IsShown() then
			checkbox:SetPoint("LEFT", 5, 0)
			checkbox:Size(26)
		end
   end
end 

local function LoadSkin()
	local StripAllTextures = {
		"ACP_AddonList",
		"ACP_AddonList_ScrollFrame",
	}
	
	local buttons = {
		"ACP_AddonListSetButton",
		"ACP_AddonListDisableAll",
		"ACP_AddonListEnableAll",
		"ACP_AddonList_ReloadUI",
		"ACP_AddonListBottomClose",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end	

	-- Skin Buttons
	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end	
	
	for i = 1, 20 do
		S:HandleButton(_G["ACP_AddonListEntry"..i.."LoadNow"])
	end	
	
	ACP_AddonList:SetTemplate('Transparent')	
		
	-- Skin the Close Button
	S:HandleCloseButton(ACP_AddonListCloseButton)

	-- Skin Check Boxes
	for i = 1, 20 do
		S:HandleCheckBox(_G["ACP_AddonListEntry"..i.."Enabled"])
	end
	
	local ACP = ACP
	local oldShow = ACP.AddonList_OnShow
	function ACP:AddonList_OnShow(this)
		oldShow(self, this)
		cbResizeAll()
	end
	
	S:HandleCheckBox(ACP_AddonList_NoRecurse)

	-- Skin Scrollbar
	S:HandleScrollBar(ACP_AddonList_ScrollFrameScrollBar)

	-- Skin Dropdown box
	S:HandleDropDownBox(ACP_AddonListSortDropDown, 130)


	-- Set Positons and sizes of some frames
	ACP_AddonList_ScrollFrame:SetWidth(590)
	ACP_AddonList_ScrollFrame:SetHeight(412)
	ACP_AddonList:SetHeight(502)
	ACP_AddonListEntry1:Point("TOPLEFT", ACP_AddonList, "TOPLEFT", 47, -62)
	ACP_AddonList_ScrollFrame:Point("TOPLEFT", ACP_AddonList, "TOPLEFT", 20, -53)
	ACP_AddonListCloseButton:Point("TOPRIGHT", ACP_AddonList, "TOPRIGHT", 4, 5)
	ACP_AddonListSetButton:Point("BOTTOMLEFT", ACP_AddonList, "BOTTOMLEFT", 20, 8)
	ACP_AddonListSetButton:SetHeight(25)
	ACP_AddonListDisableAll:Point("BOTTOMLEFT", ACP_AddonList, "BOTTOMLEFT", 90, 8)
	ACP_AddonListDisableAll:SetHeight(25)
	ACP_AddonListEnableAll:Point("BOTTOMLEFT", ACP_AddonList, "BOTTOMLEFT", 175, 8)
	ACP_AddonListEnableAll:SetHeight(25)
	ACP_AddonList_ReloadUI:Point("BOTTOMRIGHT", ACP_AddonList, "BOTTOMRIGHT", -160, 8)
	ACP_AddonListBottomClose:Point("BOTTOMRIGHT", ACP_AddonList, "BOTTOMRIGHT", -50, 8)
	ACP_AddonListBottomClose:SetHeight(25)
	ACP_AddonList:SetParent(UIParent) --WTF?
end

S:RegisterSkin('ACP', LoadSkin)