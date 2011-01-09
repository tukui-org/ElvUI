--Create interactable actionbars
if not IsAddOnLoaded("Tukui_ConfigUI") or not TukuiCF["actionbar"].enable == true then return end
local TukuiDB = TukuiDB
local TukuiCF = TukuiCF


local function Button_OnEnter(self)
	if InCombatLockdown() then return end
	self:SetAlpha(1)
	self.shown = true
end

local function Button_OnLeave(self)
	self:SetAlpha(0)
	self.shown = false
end

local btnnames = {}

local function CreateMoverButton(name, text)
	local b = CreateFrame("Button", name, UIParent)
	TukuiDB.SetNormTexTemplate(b)
	b:SetScript("OnEnter", Button_OnEnter)
	b:SetScript("OnLeave", Button_OnLeave)
	b:EnableMouse(true)
	b:SetAlpha(0)
	TukuiDB.CreateShadow(b)
	tinsert(btnnames, tostring(name))
	
	local t = b:CreateFontString(nil, "OVERLAY", b)
	t:SetFont(TukuiCF.media.font,14,"THINOUTLINE")
	t:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	t:SetShadowColor(0, 0, 0)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")
	t:SetText(text)
	t:SetTextColor(unpack(TukuiCF["media"].valuecolor))
	b.Text = t
end

local function SaveBars(var, val)
	TukuiCF["actionbar"][var] = val
	PositionAllBars()
	
	--Save configui variables
	local myPlayerRealm = GetCVar("realmName")
	local myPlayerName  = TukuiDB.myname

	if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
		if not TukuiConfig then TukuiConfig = {} end
		if not TukuiConfig["actionbar"] then TukuiConfig["actionbar"] = {} end
		TukuiConfig["actionbar"][var] = val
	else
		if not TukuiConfigSettings then TukuiConfigSettings = {} end
		if not TukuiConfigSettings["actionbar"] then TukuiConfigSettings["actionbar"] = {} end
		TukuiConfigSettings["actionbar"][var] = val
	end
end

function ToggleABLock()
	if InCombatLockdown() then return end
	
	if TukuiABLock == true then
		TukuiABLock = false
	else
		TukuiABLock = true
	end
	
	for i, btnnames in pairs(btnnames) do
		if TukuiABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			TukuiInfoLeftRButton.Text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (TukuiCF["actionbar"].rightbars ~= 0 or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			TukuiInfoLeftRButton.Text:SetTextColor(unpack(TukuiCF["media"].valuecolor))
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
	
	if TukuiCF["actionbar"].splitbar == true then
		LeftSplit:SetPoint("TOPRIGHT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", TukuiSplitActionBarLeftBackground, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)
		LeftSplit.Text:SetText(">")
		
		RightSplit:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPRIGHT", TukuiDB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", TukuiSplitActionBarRightBackground, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)
		RightSplit.Text:SetText("<")
	else
		LeftSplit:SetPoint("TOPRIGHT", TukuiMainMenuBar, "TOPLEFT", TukuiDB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)	
		
		RightSplit:SetPoint("TOPLEFT", TukuiMainMenuBar, "TOPRIGHT", TukuiDB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", TukuiMainMenuBar, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)
	end
	
	if TukuiCF["actionbar"].bottomrows == 3 then
		TopMainBar.Text:SetText("-")
	else
		TopMainBar.Text:SetText("+")
	end
	
	TopMainBar:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "TOPLEFT", 0, TukuiDB.Scale(4))
	TopMainBar:SetPoint("TOPRIGHT", TukuiMainMenuBar, "TOPRIGHT", 0, TukuiDB.Scale(19))
	
	if TukuiPetBar:IsShown() and not TukuiCF["actionbar"].bottompetbar == true then
		RightBarBig:SetPoint("TOPRIGHT", TukuiPetBar, "LEFT", TukuiDB.Scale(-3), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", TukuiPetBar, "LEFT", TukuiDB.Scale(-19), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))			
	else
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", TukuiDB.Scale(-1), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", TukuiDB.Scale(-16), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))		
	end
	
	TukuiPetBar:HookScript("OnShow", function(self)
		if TukuiCF["actionbar"].bottompetbar == true then return end
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", TukuiPetBar, "LEFT", TukuiDB.Scale(-3), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", TukuiPetBar, "LEFT", TukuiDB.Scale(-19), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))	
	end)
	
	TukuiPetBar:HookScript("OnHide", function(self)
		if InCombatLockdown() then return end
		if TukuiCF["actionbar"].bottompetbar == true then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", TukuiDB.Scale(-1), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", TukuiDB.Scale(-16), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))
	end)
	
	RightBarBig:HookScript("OnEnter", function()
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		if TukuiPetBar:IsShown() and not TukuiCF["actionbar"].bottompetbar == true then
			RightBarBig:SetPoint("TOPRIGHT", TukuiPetBar, "LEFT", TukuiDB.Scale(-3), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", TukuiPetBar, "LEFT", TukuiDB.Scale(-19), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))			
		else
			RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", TukuiDB.Scale(-1), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", TukuiDB.Scale(-16), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))		
		end
	end)
	
	if TukuiCF["actionbar"].rightbars ~= 0 or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true) then
		RightBarBig:Hide()
	end
	
	RightBarInc:SetParent(TukuiActionBarBackgroundRight)
	RightBarDec:SetParent(TukuiActionBarBackgroundRight)
	
	--Disable some default button stuff
	if TukuiCF["actionbar"].rightbarmouseover == true then
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
	
	RightBarInc:SetPoint("TOPLEFT", TukuiActionBarBackgroundRight, "BOTTOMLEFT", 0, TukuiDB.Scale(-4))
	RightBarInc:SetPoint("BOTTOMRIGHT", TukuiActionBarBackgroundRight, "BOTTOM", TukuiDB.Scale(-2), TukuiDB.Scale(-19))
	
	RightBarDec:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "BOTTOMRIGHT", 0, TukuiDB.Scale(-4))
	RightBarDec:SetPoint("BOTTOMLEFT", TukuiActionBarBackgroundRight, "BOTTOM", TukuiDB.Scale(2), TukuiDB.Scale(-19))
	
	if not TukuiABLock == nil then TukuiABLock = false end
	for i, btnnames in pairs(btnnames) do
		if TukuiABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			TukuiInfoLeftRButton.Text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (TukuiCF["actionbar"].rightbars ~= 0 or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			TukuiInfoLeftRButton.Text:SetTextColor(unpack(TukuiCF["media"].valuecolor))
		end
	end

end)

--Setup button clicks
do
	LeftSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end	
		if TukuiCF["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", TukuiSplitActionBarLeftBackground, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPRIGHT", TukuiDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", TukuiSplitActionBarRightBackground, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", TukuiMainMenuBar, "TOPLEFT", TukuiDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", TukuiMainMenuBar, "TOPRIGHT", TukuiDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", TukuiMainMenuBar, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)
		end
		LeftSplit:SetAlpha(0)
		RightSplit:SetAlpha(0)
	end)
	
	RightSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if TukuiCF["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", TukuiSplitActionBarLeftBackground, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPRIGHT", TukuiDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", TukuiSplitActionBarRightBackground, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", TukuiMainMenuBar, "TOPLEFT", TukuiDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", TukuiMainMenuBar, "BOTTOMLEFT", TukuiDB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", TukuiMainMenuBar, "TOPRIGHT", TukuiDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", TukuiMainMenuBar, "BOTTOMRIGHT", TukuiDB.Scale(19), 0)
		end
		LeftSplit:SetAlpha(0)
		RightSplit:SetAlpha(0)
	end)
	
	TopMainBar:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if TukuiCF["actionbar"].bottomrows == 1 then
			SaveBars("bottomrows", 2)
			TopMainBar.Text:SetText("+")
		elseif TukuiCF["actionbar"].bottomrows == 2 then
			SaveBars("bottomrows", 3)
			TopMainBar.Text:SetText("-")
		elseif TukuiCF["actionbar"].bottomrows == 3 then
			SaveBars("bottomrows", 1)
			TopMainBar.Text:SetText("+")
		end
		TopMainBar:SetAlpha(0)
	end)
	
	RightBarBig:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		if TukuiCF["actionbar"].rightbarmouseover ~= true then 
			TukuiDB.SlideIn(TukuiActionBarBackgroundRight)
		else
			TukuiActionBarBackgroundRight:SetAlpha(0)
		end
		SaveBars("rightbars", 1)
		self:Hide()
	end)
	
	RightBarInc:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if TukuiCF["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 2)
		elseif TukuiCF["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 3)
		elseif TukuiCF["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if TukuiPetBar:IsShown() and not TukuiCF["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", TukuiPetBar, "LEFT", TukuiDB.Scale(-3), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", TukuiPetBar, "LEFT", TukuiDB.Scale(-19), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", TukuiDB.Scale(-1), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", TukuiDB.Scale(-16), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end			
		end		
		if TukuiCF["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	RightBarDec:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if TukuiCF["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if TukuiPetBar:IsShown() and not TukuiCF["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", TukuiPetBar, "LEFT", TukuiDB.Scale(-3), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", TukuiPetBar, "LEFT", TukuiDB.Scale(-19), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", TukuiDB.Scale(-1), (TukuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", TukuiDB.Scale(-16), -(TukuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end
		elseif TukuiCF["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 1)
		elseif TukuiCF["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 2)
		end		
		
		if TukuiCF["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	--Toggle lock button
	TukuiInfoLeftRButton:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		ToggleABLock()	
		
		if TukuiInfoLeftRButton.hovered == true then
			GameTooltip:ClearLines()
			if TukuiABLock == false then
				GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", LOCKED,1,1,1,unpack(TukuiCF["media"].valuecolor))
			else
				GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", UNLOCK,1,1,1,unpack(TukuiCF["media"].valuecolor))
			end
		end
	end)
	
	TukuiInfoLeftRButton:SetScript("OnEnter", function(self)
		TukuiInfoLeftRButton.hovered = true
		if InCombatLockdown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
		GameTooltip:ClearLines()
		
		if TukuiABLock == false then
			GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", LOCKED,1,1,1,unpack(TukuiCF["media"].valuecolor))
		else
			GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", UNLOCK,1,1,1,unpack(TukuiCF["media"].valuecolor))
		end
		GameTooltip:Show()
	end)
	
	TukuiInfoLeftRButton:SetScript("OnLeave", function(self)
		TukuiInfoLeftRButton.hovered = false
		GameTooltip:Hide()
	end)
	
end