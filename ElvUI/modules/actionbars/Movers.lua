--Create interactable actionbars
if not IsAddOnLoaded("ElvUI_ConfigUI") or not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF


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
	ElvDB.SetNormTexTemplate(b)
	b:SetScript("OnEnter", Button_OnEnter)
	b:SetScript("OnLeave", Button_OnLeave)
	b:EnableMouse(true)
	b:SetAlpha(0)
	ElvDB.CreateShadow(b)
	tinsert(btnnames, tostring(name))
	
	local t = b:CreateFontString(nil, "OVERLAY", b)
	t:SetFont(ElvCF.media.font,14,"THINOUTLINE")
	t:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	t:SetShadowColor(0, 0, 0)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")
	t:SetText(text)
	t:SetTextColor(unpack(ElvCF["media"].valuecolor))
	b.Text = t
end

local function SaveBars(var, val)
	ElvCF["actionbar"][var] = val
	PositionAllBars()
	
	--Save configui variables
	local myPlayerRealm = GetCVar("realmName")
	local myPlayerName  = ElvDB.myname

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

function ToggleABLock()
	if InCombatLockdown() then return end
	
	if ElvuiABLock == true then
		ElvuiABLock = false
	else
		ElvuiABLock = true
	end
	
	for i, btnnames in pairs(btnnames) do
		if ElvuiABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			ElvuiInfoLeftRButton.Text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (ElvCF["actionbar"].rightbars ~= 0 or (ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			ElvuiInfoLeftRButton.Text:SetTextColor(unpack(ElvCF["media"].valuecolor))
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
	
	if ElvCF["actionbar"].splitbar == true then
		LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", ElvDB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", ElvDB.Scale(-19), 0)
		LeftSplit.Text:SetText(">")
		
		RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", ElvDB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", ElvDB.Scale(19), 0)
		RightSplit.Text:SetText("<")
	else
		LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", ElvDB.Scale(-4), 0)
		LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", ElvDB.Scale(-19), 0)	
		
		RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", ElvDB.Scale(4), 0)
		RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", ElvDB.Scale(19), 0)
	end
	
	if ElvCF["actionbar"].bottomrows == 3 then
		TopMainBar.Text:SetText("-")
	else
		TopMainBar.Text:SetText("+")
	end
	
	TopMainBar:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "TOPLEFT", 0, ElvDB.Scale(4))
	TopMainBar:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPRIGHT", 0, ElvDB.Scale(19))
	
	if ElvuiPetBar:IsShown() and not ElvCF["actionbar"].bottompetbar == true then
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", ElvDB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", ElvDB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
	else
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", ElvDB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", ElvDB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
	end
	
	ElvuiPetBar:HookScript("OnShow", function(self)
		if ElvCF["actionbar"].bottompetbar == true then return end
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", ElvDB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", ElvDB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))	
	end)
	
	ElvuiPetBar:HookScript("OnHide", function(self)
		if InCombatLockdown() then return end
		if ElvCF["actionbar"].bottompetbar == true then return end
		RightBarBig:ClearAllPoints()
		RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", ElvDB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
		RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", ElvDB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
	end)
	
	RightBarBig:HookScript("OnEnter", function()
		if InCombatLockdown() then return end
		RightBarBig:ClearAllPoints()
		if ElvuiPetBar:IsShown() and not ElvCF["actionbar"].bottompetbar == true then
			RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", ElvDB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", ElvDB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
		else
			RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", ElvDB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
			RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", ElvDB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
		end
	end)
	
	if ElvCF["actionbar"].rightbars ~= 0 or (ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true) then
		RightBarBig:Hide()
	end
	
	RightBarInc:SetParent(ElvuiActionBarBackgroundRight)
	RightBarDec:SetParent(ElvuiActionBarBackgroundRight)
	
	--Disable some default button stuff
	if ElvCF["actionbar"].rightbarmouseover == true then
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
	
	RightBarInc:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "BOTTOMLEFT", 0, ElvDB.Scale(-4))
	RightBarInc:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackgroundRight, "BOTTOM", ElvDB.Scale(-2), ElvDB.Scale(-19))
	
	RightBarDec:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "BOTTOMRIGHT", 0, ElvDB.Scale(-4))
	RightBarDec:SetPoint("BOTTOMLEFT", ElvuiActionBarBackgroundRight, "BOTTOM", ElvDB.Scale(2), ElvDB.Scale(-19))
	
	if not ElvuiABLock == nil then ElvuiABLock = false end
	for i, btnnames in pairs(btnnames) do
		if ElvuiABLock == false then
			_G[btnnames]:EnableMouse(false)
			_G[btnnames]:Hide()
			ElvuiInfoLeftRButton.Text:SetTextColor(1,1,1)
		else
			_G[btnnames]:EnableMouse(true)
			if btnnames == "RightBarBig" and not (ElvCF["actionbar"].rightbars ~= 0 or (ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true)) then
				_G[btnnames]:Show()
			elseif btnnames ~= "RightBarBig" then
				_G[btnnames]:Show()
			end
			ElvuiInfoLeftRButton.Text:SetTextColor(unpack(ElvCF["media"].valuecolor))
		end
	end

end)

--Setup button clicks
do
	LeftSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end	
		if ElvCF["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", ElvDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", ElvDB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", ElvDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", ElvDB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", ElvDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", ElvDB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", ElvDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", ElvDB.Scale(19), 0)
		end
		LeftSplit:SetAlpha(0)
		RightSplit:SetAlpha(0)
	end)
	
	RightSplit:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if ElvCF["actionbar"].splitbar ~= true then
			SaveBars("splitbar", true)
			LeftSplit.Text:SetText(">")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", ElvDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", ElvDB.Scale(-19), 0)
			
			RightSplit.Text:SetText("<")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", ElvDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "BOTTOMRIGHT", ElvDB.Scale(19), 0)				
		else
			SaveBars("splitbar", false)
			LeftSplit.Text:SetText("<")
			LeftSplit:ClearAllPoints()
			LeftSplit:SetPoint("TOPRIGHT", ElvuiMainMenuBar, "TOPLEFT", ElvDB.Scale(-4), 0)
			LeftSplit:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, "BOTTOMLEFT", ElvDB.Scale(-19), 0)
			
			RightSplit.Text:SetText(">")
			RightSplit:ClearAllPoints()
			RightSplit:SetPoint("TOPLEFT", ElvuiMainMenuBar, "TOPRIGHT", ElvDB.Scale(4), 0)
			RightSplit:SetPoint("BOTTOMRIGHT", ElvuiMainMenuBar, "BOTTOMRIGHT", ElvDB.Scale(19), 0)
		end
		LeftSplit:SetAlpha(0)
		RightSplit:SetAlpha(0)
	end)
	
	TopMainBar:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if ElvCF["actionbar"].bottomrows == 1 then
			SaveBars("bottomrows", 2)
			TopMainBar.Text:SetText("+")
		elseif ElvCF["actionbar"].bottomrows == 2 then
			SaveBars("bottomrows", 3)
			TopMainBar.Text:SetText("-")
		elseif ElvCF["actionbar"].bottomrows == 3 then
			SaveBars("bottomrows", 1)
			TopMainBar.Text:SetText("+")
		end
		TopMainBar:SetAlpha(0)
	end)
	
	RightBarBig:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		if ElvCF["actionbar"].rightbarmouseover ~= true then 
			ElvDB.SlideIn(ElvuiActionBarBackgroundRight)
		else
			ElvuiActionBarBackgroundRight:SetAlpha(0)
		end
		SaveBars("rightbars", 1)
		self:Hide()
	end)
	
	RightBarInc:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if ElvCF["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 2)
		elseif ElvCF["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 3)
		elseif ElvCF["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not ElvCF["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", ElvDB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", ElvDB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", ElvDB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", ElvDB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end			
		end		
		if ElvCF["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	RightBarDec:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		
		if ElvCF["actionbar"].rightbars == 1 then
			SaveBars("rightbars", 0)
			RightBarBig:Show()
			RightBarBig:ClearAllPoints()
			if ElvuiPetBar:IsShown() and not ElvCF["actionbar"].bottompetbar == true then
				RightBarBig:SetPoint("TOPRIGHT", ElvuiPetBar, "LEFT", ElvDB.Scale(-3), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", ElvuiPetBar, "LEFT", ElvDB.Scale(-19), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))			
			else
				RightBarBig:SetPoint("TOPRIGHT", UIParent, "RIGHT", ElvDB.Scale(-1), (ElvuiActionBarBackgroundRight:GetHeight() * 0.2))
				RightBarBig:SetPoint("BOTTOMLEFT", UIParent, "RIGHT", ElvDB.Scale(-16), -(ElvuiActionBarBackgroundRight:GetHeight() * 0.2))		
			end
		elseif ElvCF["actionbar"].rightbars == 2 then
			SaveBars("rightbars", 1)
		elseif ElvCF["actionbar"].rightbars == 3 then
			SaveBars("rightbars", 2)
		end		
		
		if ElvCF["actionbar"].rightbarmouseover == true then 
			RightBarMouseOver(1)
		end
	end)
	
	--Toggle lock button
	ElvuiInfoLeftRButton:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
		ToggleABLock()	
		
		if ElvuiInfoLeftRButton.hovered == true then
			GameTooltip:ClearLines()
			if ElvuiABLock == false then
				GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", LOCKED,1,1,1,unpack(ElvCF["media"].valuecolor))
			else
				GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", UNLOCK,1,1,1,unpack(ElvCF["media"].valuecolor))
			end
		end
	end)
	
	ElvuiInfoLeftRButton:SetScript("OnEnter", function(self)
		ElvuiInfoLeftRButton.hovered = true
		if InCombatLockdown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, ElvDB.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, ElvDB.mult)
		GameTooltip:ClearLines()
		
		if ElvuiABLock == false then
			GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", LOCKED,1,1,1,unpack(ElvCF["media"].valuecolor))
		else
			GameTooltip:AddDoubleLine(ACTIONBAR_LABEL..":", UNLOCK,1,1,1,unpack(ElvCF["media"].valuecolor))
		end
		GameTooltip:Show()
	end)
	
	ElvuiInfoLeftRButton:SetScript("OnLeave", function(self)
		ElvuiInfoLeftRButton.hovered = false
		GameTooltip:Hide()
	end)
	
end