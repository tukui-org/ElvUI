if not TukuiDB["actionbar"].enable == true then return end

local _G = _G
local media = TukuiDB["media"]
local securehandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
RANGE_INDICATOR = "" -- fix "?" range indicator when hotkey are enabled.

local function style(self)  
	local name = self:GetName()
	local action = self.action
	local Button = self
	local Icon = _G[name.."Icon"]
	local Count = _G[name.."Count"]
	local Flash	 = _G[name.."Flash"]	
	local HotKey = _G[name.."HotKey"]
	local Border  = _G[name.."Border"]
	local Btname = _G[name.."Name"]
	local normal  = _G[name.."NormalTexture"]

	Flash:SetTexture("")

	Button:SetPushedTexture(media.buttonhover)
	Button:SetNormalTexture("")

	Count:ClearAllPoints()
	Count:SetPoint("BOTTOMRIGHT", 0, TukuiDB:Scale(2))
	Count:SetFont(TukuiDB["media"].font, 12, "OUTLINE")
	
	HotKey:ClearAllPoints()
	HotKey:SetPoint("TOPRIGHT", 0, TukuiDB:Scale(-2))
	HotKey:SetFont(TukuiDB["media"].font, 12, "OUTLINE")
	if not TukuiDB["actionbar"].hotkey == true then
		HotKey:SetText("")
		HotKey:Hide()
		HotKey.Show = function() end
	end
	Btname:SetText("")
	Btname:Hide()
	Btname.Show = function() end
	Border:Hide()
	
	if not _G[name.."Panel"] then
		self:SetWidth(TukuiDB.buttonsize)
		self:SetHeight(TukuiDB.buttonsize)
		
		local panel = CreateFrame("Frame", name.."Panel", self)
		TukuiDB:CreatePanel(panel, TukuiDB.buttonsize, TukuiDB.buttonsize, "CENTER", self, "CENTER", 0, 0)
		panel:SetBackdropColor(0, 0, 0, 0)

		Icon:SetTexCoord(.08, .92, .08, .92)
		Icon:SetPoint("TOPLEFT", Button, TukuiDB:Scale(2), TukuiDB:Scale(-2))
		Icon:SetPoint("BOTTOMRIGHT", Button, TukuiDB:Scale(-2), TukuiDB:Scale(2))
	end
	
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT")
	normal:SetPoint("BOTTOMRIGHT")
end

local function stylesmallbutton(normal, button, icon, name, pet)
	local Flash	 = _G[name.."Flash"]
	button:SetPushedTexture(media.buttonhover)
	button:SetNormalTexture("")
	Flash:SetTexture("")
	
	if not _G[name.."Panel"] then
		button:SetWidth(TukuiDB.petbuttonsize)
		button:SetHeight(TukuiDB.petbuttonsize)
		
		local panel = CreateFrame("Frame", name.."Panel", button)
		TukuiDB:CreatePanel(panel, TukuiDB.petbuttonsize, TukuiDB.petbuttonsize, "CENTER", button, "CENTER", 0, 0)
		panel:SetBackdropColor(unpack(media.backdropcolor))

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:ClearAllPoints()
		if pet then
			local autocast = _G[name.."AutoCastable"]
			autocast:SetWidth(TukuiDB:Scale(41))
			autocast:SetHeight(TukuiDB:Scale(40))
			autocast:ClearAllPoints()
			autocast:SetPoint("CENTER", button, 0, 0)
			icon:SetPoint("TOPLEFT", button, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			icon:SetPoint("BOTTOMRIGHT", button, TukuiDB:Scale(-2), TukuiDB:Scale(2))
		else
			icon:SetPoint("TOPLEFT", button, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			icon:SetPoint("BOTTOMRIGHT", button, TukuiDB:Scale(-2), TukuiDB:Scale(2))
		end
	end
	
	normal:SetVertexColor(unpack(media.bordercolor))
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT")
	normal:SetPoint("BOTTOMRIGHT")
end

local function styleshift(pet)
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local name = "ShapeshiftButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture"]
		stylesmallbutton(normal, button, icon, name)
	end
end

local function stylepet()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture2"]
		stylesmallbutton(normal, button, icon, name, true)
	end
end

local function usable(self)
	local name = self:GetName()
	local action = self.action
	local icon = _G[name.."Icon"]
	
	local normal  = _G[name.."NormalTexture"]
	normal:SetAlpha(1)
	
	if IsEquippedAction(action) then
		normal:SetVertexColor(.6, 1, .6)
    elseif IsCurrentAction(action) then
		normal:SetVertexColor(1, 1, 1)
	else
		normal:SetVertexColor(unpack(media.bordercolor))
    end
	
	local isusable, mana = IsUsableAction(action)
	if ActionHasRange(action) and IsActionInRange(action) == 0 then
		icon:SetVertexColor(0.8, 0.1, 0.1)
		return
	elseif mana then
		icon:SetVertexColor(.1, .3, 1)
		return
	elseif isusable then
		icon:SetVertexColor(.8, .8, .8)
		return
	else
		icon:SetVertexColor(.4, .4, .4)
		return
	end
end

local function onupdate(self, elapsed)
	local t = self.rangetimer
	if not t then
		self.rangetimer = 0
		return
	end
	t = t + elapsed
	if t < .2 then
		self.rangetimer = t
		return
	else
		self.rangetimer = 0
		if not ActionHasRange(self.action) then return end
		usable(self)
	end
end

hooksecurefunc("ActionButton_OnUpdate", onupdate)
hooksecurefunc("ActionButton_Update", style)
hooksecurefunc("ActionButton_UpdateUsable", usable)
hooksecurefunc("PetActionBar_Update", stylepet)
hooksecurefunc("ShapeshiftBar_OnLoad", styleshift)
hooksecurefunc("ShapeshiftBar_Update", styleshift)
hooksecurefunc("ShapeshiftBar_UpdateState", styleshift)
