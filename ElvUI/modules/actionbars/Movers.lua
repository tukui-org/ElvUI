--Create interactable actionbars
local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true or not IsAddOnLoaded("ElvUI_ConfigUI") then return end

local function Button_OnEnter(self)
	self.Text:SetTextColor(1, 1, 1)
	self:SetBackdropBorderColor(unpack(C["media"].valuecolor))
end

local function Button_OnLeave(self)
	self.Text:SetTextColor(unpack(C["media"].valuecolor))
	DB.SetNormTexTemplate(self)
end

local function Button_OnEvent(self, event)
	if self:IsShown() then self:Hide() end
end

local btnnames = {}

local function CreateMoverButton(name, text)
	local b = CreateFrame("Button", name, UIParent)
	DB.SetNormTexTemplate(b)
	b:RegisterEvent("PLAYER_REGEN_DISABLED")
	b:SetScript("OnEvent", Button_OnEvent)
	b:SetScript("OnEnter", Button_OnEnter)
	b:SetScript("OnLeave", Button_OnLeave)
	b:EnableMouse(true)
	b:Hide()
	DB.CreateShadow(b)
	tinsert(btnnames, tostring(name))
	
	local t = b:CreateFontString(nil, "OVERLAY", b)
	t:SetFont(C.media.font,14,"THINOUTLINE")
	t:SetShadowOffset(DB.mult, -DB.mult)
	t:SetShadowColor(0, 0, 0)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")
	t:SetText(text)
	t:SetTextColor(unpack(C["media"].valuecolor))
	b.Text = t
end

local function SaveBars(var, val)
	C["actionbar"][var] = val
	PositionAllBars()
	
	--Save configui variables
	local myPlayerRealm = GetCVar("realmName")
	local myPlayerName  = DB.myname

	if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
		if not ElvuiConfig then ElvuiConfig = {} end
		if not ElvuiConfig["actionbar"] then ElvuiConfig["actionbar"] = {} end
		ElvuiConfig["actionbar"][var] = val
	else
		if not ElvuiConfigSettings then ElvuiConfigSettings = {} end
		if not ElvuiConfigSettings["actionbar"] then ElvuiConfigSettings["actionbar"] = {} end
		ElvuiConfigSettings["actionbar"][var] = val
	end
end

function DB.ToggleABLock()
	if InCombatLockdown() then return end
	
	if DB.ABLock == true then
		DB.ABLock = false
	else
		DB.ABLock = true
	end
	
	for i, btnnames in pairs(btnnames) do
		if DB.ABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			ElvuiInfoLeftRButton.Text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (C["actionbar"].rightbars ~= 0 or (C["actionbar"].bottomrows == 3 and C["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			ElvuiInfoLeftRButton.Text:SetTextColor(unpack(C["media"].valuecolor))
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
barloader:RegisterEvent("PLAYER_ENTERING_WORLD")
barloader:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	if C["actionbar"].splitbar == true then
		LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", DB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", DB.Scale(-19), 0)
		LeftSplit.Text:SetText(">")
		
		RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", DB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", DB.Scale(19), 0)
		RightSplit.Text:SetText("<")
	else
		LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", DB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", DB.Scale(-19), 0)	
		
		RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", DB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", DB.Scale(19), 0)
	end
	
	if C["actionbar"].bottomrows == 3 then
		TopMainBar.Text:SetText("-")
	else
		TopMainBar.Text:SetText("+")
	end
	
	TopMainBar:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "TOPLEFT", 0, DB.Scale(4))
	TopMainBar:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPRIGHT", 0, DB.Scale(19))
	
	if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", DB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", DB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
	else
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", DB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", DB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
	end
	
	ElvuiPetBar:HookScript("OnShow", function(self)
		if C["actionbar"].bottompetbar == true then return end
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", DB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", DB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))	
	end)
	
	ElvuiPetBar:HookScript("OnHide", function(self)
		if InCombatLockdown() then return end
		if C["actionbar"].bottompetbar == true then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", DB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", DB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
	end)
	
	RightBarBig:HookScript("OnEnter", function()
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
			RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", DB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", DB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
		else
			RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", DB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", DB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
		end
	end)
	
	if C["actionbar"].rightbars ~= 0 or (C["actionbar"].bottomrows == 3 and C["actionbar"].splitbar == true) then
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
	
	RightBarInc:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "BOTTOMLEFT", 0, DB.Scale(-4))
	RightBarInc:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackgroundRight, "BOTTOM", DB.Scale(-2), DB.Scale(-19))
	
	RightBarDec:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "BOTTOMRIGHT", 0, DB.Scale(-4))
	RightBarDec:SetPoint("BOTTOMLEFT", ElvuiActionBarBackgroundRight, "BOTTOM", DB.Scale(2), DB.Scale(-19))
	
	DB.ABLock = false
	ElvuiInfoLeftRButton.Text:SetTextColor(1,1,1)
end)

--Setup button clicks
do
	LeftSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end	
		if C["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", DB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", DB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", DB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", DB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", DB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", DB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", DB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", DB.Scale(19), 0)
		end
	end)
	
	RightSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if C["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", DB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", DB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", DB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", DB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", DB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", DB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", DB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", DB.Scale(19), 0)
		end
	end)
	
	TopMainBar:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if C["actionbar"].bottomrows == 1 then
			SaveBars("bottomrows", 2)
			TopMainBar.Text:SetText("+")
		elseif C["actionbar"].bottomrows == 2 then
			SaveBars("bottomrows", 3)
			TopMainBar.Text:SetText("-")
		elseif C["actionbar"].bottomrows == 3 then
			SaveBars("bottomrows", 1)
			TopMainBar.Text:SetText("+")
		end
	end)
	
	RightBarBig:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		if C["actionbar"].rightbarmouseover ~= true then 
			DB.SlideIn(ElvuiActionBarBackgroundRight)
		else
			ElvuiActionBarBackgroundRight:SetAlpha(0)
		end
		SaveBars("rightbars", 1)
		self:Hide()
	end)
	
	RightBarInc:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if C["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 2)
		elseif C["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 3)
		elseif C["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", DB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", DB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", DB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", DB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end			
		end		
		if C["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	RightBarDec:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if C["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not C["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", DB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", DB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", DB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", DB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end
		elseif C["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 1)
		elseif C["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 2)
		end		
		
		if C["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
end