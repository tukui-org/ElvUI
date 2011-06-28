--Create interactable actionbars
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end

local function Button_OnEnter(self)
	self.Text:SetTextColor(1, 1, 1)
	self:SetBackdropBorderColor(unpack(C["media"].valuecolor))
end

local function Button_OnLeave(self)
	self.Text:SetTextColor(unpack(C["media"].valuecolor))
	self:SetTemplate("Default", true)
end

local function Button_OnEvent(self, event)
	if self:IsShown() then self:Hide() end
	E.ABLock = false
end

local btnnames = {}

local function CreateMoverButton(name, text)
	local b = CreateFrame("Button", name, E.UIParent)
	b:SetTemplate("Default", true)
	b:RegisterEvent("PLAYER_REGEN_DISABLED")
	b:SetScript("OnEvent", Button_OnEvent)
	b:SetScript("OnEnter", Button_OnEnter)
	b:SetScript("OnLeave", Button_OnLeave)
	b:EnableMouse(true)
	b:Hide()
	b:CreateShadow("Default")
	tinsert(btnnames, tostring(name))
	
	local t = b:CreateFontString(nil, "OVERLAY", b)
	t:SetFont(C["media"].font,14,"THINOUTLINE")
	t:SetShadowOffset(E.mult, -E.mult)
	t:SetShadowColor(0, 0, 0, 0.4)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")
	t:SetText(text)
	t:SetTextColor(unpack(C["media"].valuecolor))
	b.Text = t
end

local function SaveBars(var, val)
	E["actionbar"][var] = val
	E.PositionAllBars()
end

function E.ToggleABLock()
	if InCombatLockdown() then return end
	
	if E.ABLock == true then
		E.ABLock = false
	else
		E.ABLock = true
	end
	
	for i, btnnames in pairs(btnnames) do
		if E.ABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			ElvuiInfoLeftRButton.text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (E["actionbar"].rightbars ~= 0 or (E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			ElvuiInfoLeftRButton.text:SetTextColor(unpack(C["media"].valuecolor))
		end
	end
end

--Create our buttons
do
	CreateMoverButton("LeftSplit", "<")
	CreateMoverButton("RightSplit", ">")
	CreateMoverButton("TopMainBar", "+")
	CreateMoverButton("RightBarBig", "<")
	CreateMoverButton("RightBarInc", "<")
	CreateMoverButton("RightBarDec", ">")
end

--Position & Size our buttons after variables loaded
local barloader = CreateFrame("Frame")
barloader:RegisterEvent("ADDON_LOADED")
barloader:SetScript("OnEvent", function(self, addon)
	if not IsAddOnLoaded("ElvUI") then return end
	self:UnregisterEvent("ADDON_LOADED")
	
	if E.SavePath["actionbar"] == nil then E.SavePath["actionbar"] = {} end
	
	E["actionbar"] = E.SavePath["actionbar"]
	
	--Default settings
	if E["actionbar"].splitbar == nil then E["actionbar"].splitbar = true end
	if E["actionbar"].bottomrows == nil then E["actionbar"].bottomrows = 1 end
	if E["actionbar"].rightbars == nil then E["actionbar"].rightbars = 0 end
	
	if E["actionbar"].splitbar == true then
		LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.Scale(-19), 0)
		LeftSplit.Text:SetText(">")
		
		RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", E.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", E.Scale(19), 0)
		RightSplit.Text:SetText("<")
	else
		LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", E.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", E.Scale(-19), 0)	
		
		RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", E.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", E.Scale(19), 0)
	end
	
	if E.lowversion == true then
		if E["actionbar"].bottomrows == 3 then
			TopMainBar.Text:SetText("-")
		else
			TopMainBar.Text:SetText("+")
		end
	else
		if E["actionbar"].bottomrows == 2 then
			TopMainBar.Text:SetText("-")
		else
			TopMainBar.Text:SetText("+")
		end	
	end
	
	TopMainBar:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "TOPLEFT", 0, E.Scale(4))
	TopMainBar:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPRIGHT", 0, E.Scale(19))
	
	if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
	else
		RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
	end
	
	ElvuiPetBar:HookScript("OnShow", function(self)
		if C["actionbar"].bottompetbar == true then return end
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))	
	end)
	
	ElvuiPetBar:HookScript("OnHide", function(self)
		if InCombatLockdown() then return end
		if C["actionbar"].bottompetbar == true then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
	end)
	
	RightBarBig:HookScript("OnEnter", function()
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
			RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
		else
			RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
		end
	end)
	
	if E["actionbar"].rightbars ~= 0 or (E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar == true) then
		RightBarBig:Hide()
	end
	
	RightBarInc:SetParent(ElvuiActionBarBackgroundRight)
	RightBarDec:SetParent(ElvuiActionBarBackgroundRight)
	
	--Disable some default button stuff
	if C["actionbar"].rightbarmouseover == true then
		RightBarInc:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		RightBarInc:SetScript("OnLeave", function() RightBarMouseOver(0) end)
		RightBarDec:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		RightBarDec:SetScript("OnLeave", function() RightBarMouseOver(0) end)	
	else
		RightBarInc:SetScript("OnEnter", function() end)
		RightBarInc:SetScript("OnLeave", function() end)
		RightBarDec:SetScript("OnEnter", function() end)
		RightBarDec:SetScript("OnLeave", function() end)	
	end

	RightBarDec:SetAlpha(1)
	RightBarInc:SetAlpha(1)
	
	RightBarInc:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "BOTTOMLEFT", 0, E.Scale(-4))
	RightBarInc:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackgroundRight, "BOTTOM", E.Scale(-2), E.Scale(-19))
	RightBarDec:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "BOTTOMRIGHT", 0, E.Scale(-4))
	RightBarDec:SetPoint("BOTTOMLEFT", ElvuiActionBarBackgroundRight, "BOTTOM", E.Scale(2), E.Scale(-19))

	E.ABLock = false
	ElvuiInfoLeftRButton.text:SetTextColor(1,1,1)
	E.PositionAllBars()
end)

--Setup button clicks
do
	LeftSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end	
		if E["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", E.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", E.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", E.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", E.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", E.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", E.Scale(19), 0)
		end
		
		if E.lowversion ~= true and E["actionbar"].rightbars > 2 and E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 1 then
			SaveBars("rightbars", 2)
		elseif E.lowversion ~= true and E["actionbar"].rightbars > 1 and E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 2 then
			SaveBars("rightbars", 1)
		end	
		
		if E.lowversion == true and E["actionbar"].splitbar ~= true and E.actionbar.bottomrows == 3 then
			SaveBars("rightbars", 0)	
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end	
		elseif E.lowversion == true and E.actionbar.bottomrows == 3 then
			RightBarBig:Hide()
			SaveBars("rightbars", 0)
		end	
	end)
	
	RightSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if E["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", E.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", E.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", E.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", E.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", E.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", E.Scale(19), 0)
		end
			
		if E.lowversion ~= true and E["actionbar"].rightbars > 2 and E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 1 then
			SaveBars("rightbars", 2)
		elseif E.lowversion ~= true and E["actionbar"].rightbars > 1 and E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 2 then
			SaveBars("rightbars", 1)
		end		
		
		if E.lowversion == true and E["actionbar"].splitbar ~= true and E.actionbar.bottomrows == 3 then
			SaveBars("rightbars", 0)	
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end	
		elseif E.lowversion == true and E.actionbar.bottomrows == 3 then
			RightBarBig:Hide()
			SaveBars("rightbars", 0)			
		end		
	end)
	
	TopMainBar:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if E.lowversion == true then
			if E["actionbar"].bottomrows == 1 then
				SaveBars("bottomrows", 2)
				TopMainBar.Text:SetText("+")
			elseif E["actionbar"].bottomrows == 2 then
				SaveBars("bottomrows", 3)
				TopMainBar.Text:SetText("-")
				
				if E["actionbar"].splitbar == true then
					SaveBars("rightbars", 0)
					RightBarBig:Hide()		
				end
			elseif E["actionbar"].bottomrows == 3 then
				SaveBars("bottomrows", 1)
				TopMainBar.Text:SetText("+")
			end
			
			if E["actionbar"].bottomrows ~= 3 and E["actionbar"].rightbars == 0 then
				RightBarBig:Show()
				RightBarBig:ClearAllPoints()
				if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
					RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
				else
					RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
				end	
			end
		else
			if E["actionbar"].bottomrows == 1 then
				SaveBars("bottomrows", 2)
				TopMainBar.Text:SetText("-")	
				if E["actionbar"].rightbars > 0 and E["actionbar"].splitbar == true then
					SaveBars("rightbars", 1)
				end
			else
				SaveBars("bottomrows", 1)
				TopMainBar.Text:SetText("+")			
			end
		end
	end)
	
	RightBarBig:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		if C["actionbar"].rightbarmouseover ~= true then 
			ElvuiActionBarBackgroundRight:Show()
		else
			ElvuiActionBarBackgroundRight:SetAlpha(0)
		end
		SaveBars("rightbars", 1)
		self:Hide()
	end)
	
	RightBarInc:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if E.lowversion == true then
			if E["actionbar"].rightbars == 1 then
				SaveBars("rightbars", 2)
			elseif E["actionbar"].rightbars == 2 then
				SaveBars("rightbars", 0)
				RightBarBig:Show()
				RightBarBig:ClearAllPoints()
				if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
					RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
				else
					RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
				end			
			end
		else
			if E["actionbar"].rightbars == 1 then
				if E["actionbar"].splitbar == true then
					SaveBars("splitbar", false)
					LeftSplit.Text:SetText("<")
					LeftSplit:ClearAllPoints()
					LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", E.Scale(-4), 0)
					LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", E.Scale(-19), 0)
					
					RightSplit.Text:SetText(">")
					RightSplit:ClearAllPoints()
					RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", E.Scale(4), 0)
					RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", E.Scale(19), 0)					
				end
				SaveBars("rightbars", 2)
			elseif E["actionbar"].rightbars == 2 then
				if E["actionbar"].splitbar == true then
					SaveBars("splitbar", false)
					LeftSplit.Text:SetText("<")
					LeftSplit:ClearAllPoints()
					LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", E.Scale(-4), 0)
					LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", E.Scale(-19), 0)
					
					RightSplit.Text:SetText(">")
					RightSplit:ClearAllPoints()
					RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", E.Scale(4), 0)
					RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", E.Scale(19), 0)					
				end	
				SaveBars("rightbars", 3)				
			elseif E["actionbar"].rightbars == 3 then
				SaveBars("rightbars", 0)
				RightBarBig:Show()
				RightBarBig:ClearAllPoints()
				if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
					RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
				else
					RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
				end			
			end		
		end
		if C["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	RightBarDec:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if E.lowversion == true then
			if E["actionbar"].rightbars == 1 then
				SaveBars("rightbars", 0)
				RightBarBig:Show()
				RightBarBig:ClearAllPoints()
				if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
					RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
				else
					RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
				end
			else
				SaveBars("rightbars", 1)
			end		
		else
			if E["actionbar"].rightbars == 1 then
				SaveBars("rightbars", 0)
				RightBarBig:Show()
				RightBarBig:ClearAllPoints()
				if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
					RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", E.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", E.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
				else
					RightBarBig:SetPoint("TOPRIGHT", E.UIParent, "RIGHT", E.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
					RightBarBig:SetPoint("BOTTOMLEFT", E.UIParent, "RIGHT", E.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
				end		
			elseif E["actionbar"].rightbars == 2 then
				SaveBars("rightbars", 1)
			else
				SaveBars("rightbars", 2)
			end
		end
		
		if C["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
end