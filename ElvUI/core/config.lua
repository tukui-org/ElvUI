local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local ACD = LibStub("AceConfigDialog-3.0")
local grid

local selectedValue = 'GENERAL'
E.ConfigModeLayouts = {
	'GENERAL',
	'ALL',
	'SOLO',
	'PARTY',
	'ARENA',
	'RAID10',
	'RAID25',
	'RAID40',
	'ACTIONBARS'
}

E.ConfigModeLocalizedStrings = {
	GENERAL = GENERAL,
	ALL = ALL,
	SOLO = SOLO,
	PARTY = PARTY,
	ARENA = ARENA,
	RAID10 = RAID..'-10',
	RAID25 = RAID..'-25',
	RAID40 = RAID..'-40',
	ACTIONBARS = ACTIONBARS_LABEL
}


function E:Grid_Show()
	if not grid then
        E:Grid_Create()
	elseif grid.boxSize ~= E.db.gridSize then
        grid:Hide()
        E:Grid_Create()
    else
		grid:Show()
	end
end

function E:Grid_Hide()
	if grid then
		grid:Hide()
	end
end

function E:ToggleConfigMode(override, configType)
	if InCombatLockdown() then return; end
	if override ~= nil and override ~= '' then E.ConfigurationMode = override end

	if E.ConfigurationMode ~= true then
		if not grid then
			E:Grid_Create()
		elseif grid.boxSize ~= E.db.gridSize then
			grid:Hide()
			E:Grid_Create()
		else
			grid:Show()
		end
		
		if not ElvUIMoverPopupWindow then
			E:CreateMoverPopup()
		end
		
		ElvUIMoverPopupWindow:Show()
		ACD['Close'](ACD, 'ElvUI') 
		GameTooltip:Hide()		
		E.ConfigurationMode = true
	else
		if ElvUIMoverPopupWindow then
			ElvUIMoverPopupWindow:Hide()
		end	
		
		if grid then
			grid:Hide()
		end
		
		E.ConfigurationMode = false
	end
	
	if type(configType) ~= 'string' then
		configType = nil
	end
	
	self:ToggleMovers(E.ConfigurationMode, configType or 'GENERAL')
end

function E:Grid_Create() 
	grid = CreateFrame('Frame', 'EGrid', UIParent) 
	grid.boxSize = E.db.gridSize
	grid:SetAllPoints(E.UIParent) 
	grid:Show()

	local size = 1 
	local width = E.eyefinity or GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / E.db.gridSize
	local hStep = height / E.db.gridSize

	for i = 0, E.db.gridSize do 
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		if i == E.db.gridSize / 2 then 
			tx:SetTexture(1, 0, 0) 
		else 
			tx:SetTexture(0, 0, 0) 
		end 
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0) 
		tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0) 
	end 
	height = GetScreenHeight()
	
	do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(1, 0, 0)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end
	
	for i = 1, math.floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0)
		
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))
		
		tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0)
		
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end
end

local function ConfigMode_OnClick(self)
	selectedValue = self.value
	E:ToggleConfigMode(false, self.value)
	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, self.value);
end

local function ConfigMode_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = ConfigMode_OnClick;
	
	for _, configMode in ipairs(E.ConfigModeLayouts) do
		info.text = E.ConfigModeLocalizedStrings[configMode];
		info.value = configMode;
		UIDropDownMenu_AddButton(info);		
	end

	UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue);
end

function E:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(130)
	f:SetTemplate('Transparent')
	f:SetPoint("BOTTOM", UIParent, 'CENTER')
	f:SetScript('OnHide', function()
		if ElvUIMoverPopupWindowDropDown then
			UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, 'GENERAL');
		end
	end)
	f:Hide()

	local S = E:GetModule('Skins')

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)
	
	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Movers unlocked. Move them now and click Lock when you are done."])

	local snapping = CreateFrame("CheckButton", f:GetName()..'CheckButton', f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName() .. "Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(self)
		self:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(self)
		E.db.general.stickyFrames = self:GetChecked()
	end)

	local lock = CreateFrame("Button", f:GetName()..'CloseButton', f, "OptionsButtonTemplate")
	_G[lock:GetName() .. "Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function(self)
		local ACD = LibStub("AceConfigDialog-3.0")
		E:ToggleConfigMode(true)
		ACD['Open'](ACD, 'ElvUI') 
		selectedValue = 'GENERAL'
		UIDropDownMenu_SetSelectedValue(ElvUIMoverPopupWindowDropDown, selectedValue);
	end)
	
	local align = CreateFrame('EditBox', f:GetName()..'EditBox', f, 'InputBoxTemplate')
	align:Width(24)
	align:Height(17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(self)
		self:SetText(E.db.gridSize)
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				self:SetText(E.db.gridSize)
			end
		else
			self:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEditFocusLost", function(self)
		self:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E.db.gridSize)
	end)
	
	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:SetPoint('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L['Grid Size:'])

	--position buttons
	snapping:SetPoint("BOTTOMLEFT", 14, 10)
	lock:SetPoint("BOTTOMRIGHT", -14, 14)
	align:SetPoint('TOPRIGHT', lock, 'TOPLEFT', -4, -2)
	
	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)
	
	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
			E:Grid_Hide()
			E:ToggleConfigMode(true)
		end
	end)
	
	local configMode = CreateFrame('Frame', f:GetName()..'DropDown', f, 'UIDropDownMenuTemplate')
	configMode:Point('BOTTOMRIGHT', lock, 'TOPRIGHT', 8, -5)
	S:HandleDropDownBox(configMode, 148)
	configMode.text = configMode:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	configMode.text:SetPoint('RIGHT', configMode.backdrop, 'LEFT', -2, 0)
	configMode.text:SetText(L['Config Mode:'])	
	
	
	UIDropDownMenu_Initialize(configMode, ConfigMode_Initialize);
end