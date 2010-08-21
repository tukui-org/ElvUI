if not TukuiCF["actionbar"].enable == true then return end

local _G = _G
local media = TukuiCF["media"]
local securehandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
local replace = string.gsub

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
	Button:SetNormalTexture("")
	
	Border:Hide()
	Border = TukuiDB.dummy

	Count:ClearAllPoints()
	Count:SetPoint("BOTTOMRIGHT", 0, TukuiDB.Scale(2))
	Count:SetFont(TukuiCF["media"].font, 12, "OUTLINE")
	
	HotKey:ClearAllPoints()
	HotKey:SetPoint("TOPRIGHT", 0, TukuiDB.Scale(-2))
	HotKey:SetFont(TukuiCF["media"].font, 12, "OUTLINE")
	
	if not TukuiCF["actionbar"].hotkey == true then
		HotKey:SetText("")
		HotKey:Hide()
		HotKey.Show = TukuiDB.dummy
	end

	Btname:SetText("")
	Btname:Hide()
	Btname.Show = TukuiDB.dummy
	
	if not _G[name.."Panel"] then
		self:SetWidth(TukuiDB.buttonsize)
		self:SetHeight(TukuiDB.buttonsize)
		
		local panel = CreateFrame("Frame", name.."Panel", self)
		TukuiDB.CreatePanel(panel, TukuiDB.buttonsize, TukuiDB.buttonsize, "CENTER", self, "CENTER", 0, 0)
		panel:SetBackdropColor(0, 0, 0, 0)
		panel:SetFrameStrata(self:GetFrameStrata())
		panel:SetFrameLevel(self:GetFrameLevel() - 1)

		Icon:SetTexCoord(.08, .92, .08, .92)
		Icon:SetPoint("TOPLEFT", Button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
		Icon:SetPoint("BOTTOMRIGHT", Button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
	end
	
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT")
	normal:SetPoint("BOTTOMRIGHT")
end

local function stylesmallbutton(normal, button, icon, name, pet)
	local Flash	 = _G[name.."Flash"]
	button:SetNormalTexture("")
	Flash:SetTexture(media.buttonhover)
	
	if not _G[name.."Panel"] then
		button:SetWidth(TukuiDB.petbuttonsize)
		button:SetHeight(TukuiDB.petbuttonsize)
		
		local panel = CreateFrame("Frame", name.."Panel", button)
		TukuiDB.CreatePanel(panel, TukuiDB.petbuttonsize, TukuiDB.petbuttonsize, "CENTER", button, "CENTER", 0, 0)
		panel:SetBackdropColor(unpack(media.backdropcolor))
		panel:SetFrameStrata(button:GetFrameStrata())
		panel:SetFrameLevel(button:GetFrameLevel() - 1)

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:ClearAllPoints()
		if pet then
			local autocast = _G[name.."AutoCastable"]
			autocast:SetWidth(TukuiDB.Scale(41))
			autocast:SetHeight(TukuiDB.Scale(40))
			autocast:ClearAllPoints()
			autocast:SetPoint("CENTER", button, 0, 0)
			icon:SetPoint("TOPLEFT", button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			icon:SetPoint("BOTTOMRIGHT", button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
		else
			icon:SetPoint("TOPLEFT", button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			icon:SetPoint("BOTTOMRIGHT", button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
		end
	end
	
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

-- styleButton function authors are Chiril & Karudon.
local function styleButton(b) 
    local name = b:GetName()
 
    local button          = _G[name]
    local icon            = _G[name.."Icon"]
    local count           = _G[name.."Count"]
    local border          = _G[name.."Border"]
    local hotkey          = _G[name.."HotKey"]
    local cooldown        = _G[name.."Cooldown"]
    local nametext        = _G[name.."Name"]
    local flash           = _G[name.."Flash"]
    local normaltexture   = _G[name.."NormalTexture"]
 
    local hover = b:CreateTexture("frame", nil, self) -- hover
    hover:SetTexture(1,1,1,0.4)
    hover:SetHeight(button:GetHeight())
    hover:SetWidth(button:GetWidth())
    hover:SetPoint("TOPLEFT",button,2,-2)
    hover:SetPoint("BOTTOMRIGHT",button,-2,2)
    button:SetHighlightTexture(hover)
 
    local pushed = b:CreateTexture("frame", nil, self) -- pushed
    pushed:SetTexture(0.9,0.8,0.1,0.4)
    pushed:SetHeight(button:GetHeight())
    pushed:SetWidth(button:GetWidth())
    pushed:SetPoint("TOPLEFT",button,2,-2)
    pushed:SetPoint("BOTTOMRIGHT",button,-2,2)
    button:SetPushedTexture(pushed)
 
    local checked = b:CreateTexture("frame", nil, self) -- checked
    checked:SetTexture(0,1,0,0.4)
    checked:SetHeight(button:GetHeight())
    checked:SetWidth(button:GetWidth())
    checked:SetPoint("TOPLEFT",button,2,-2)
    checked:SetPoint("BOTTOMRIGHT",button,-2,2)
    button:SetCheckedTexture(checked)
 
    local flasht = b:CreateTexture("frame", nil, self) -- flash (dunno if this is necessary)
    flasht:SetTexture(1,0,1,0)
    flasht:SetHeight(button:GetHeight())
    flasht:SetWidth(button:GetWidth())
    flasht:SetPoint("TOPLEFT",button,2,-2)
    flasht:SetPoint("BOTTOMRIGHT",button,-2,2)
    flash:SetTexture(flasht)
end

local function updatehotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. 'HotKey']
	local text = hotkey:GetText()
	
	text = replace(text, '(s%-)', 'S')
	text = replace(text, '(a%-)', 'A')
	text = replace(text, '(c%-)', 'C')
	text = replace(text, '(Mouse Button )', 'M')
	text = replace(text, '(Middle Mouse)', 'M3')
	text = replace(text, '(Num Pad )', 'N')
	text = replace(text, '(Page Up)', 'PU')
	text = replace(text, '(Page Down)', 'PD')
	text = replace(text, '(Spacebar)', 'SpB')
	text = replace(text, '(Insert)', 'Ins')
	text = replace(text, '(Home)', 'Hm')
	
	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(text)
	end
end

-- rescale cooldown spiral to fix texture.
local buttonNames = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton", "ShapeshiftButton", "PetActionButton" }
for _, name in ipairs( buttonNames ) do
	for index = 1, 20 do
		local buttonName = name .. tostring(index)
		local button = _G[buttonName]
		local cooldown = _G[buttonName .. "Cooldown"]
 
		if ( button == nil or cooldown == nil ) then
			break;
		end
 
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end
end

do
	for i = 1, 12 do
		styleButton(_G["ActionButton"..i])
	end
	 
	for i=1, 12 do
		styleButton(_G["BonusActionButton"..i])
	end
	 
	for i=1, 10 do
		styleButton(_G["ShapeshiftButton"..i])
	end
	 
	for i=1, 10 do
		styleButton(_G["PetActionButton"..i])
	end
	 
	for i= 1, 12 do
		styleButton(_G["MultiBarRightButton"..i])
	end
	 
	for i= 1, 12 do
		styleButton(_G["MultiBarBottomRightButton"..i])
	end  
	 
	for i= 1, 12 do
		styleButton(_G["MultiBarLeftButton"..i])
	end
	 
	for i=1, 12 do
		styleButton(_G["MultiBarBottomLeftButton"..i])
	end
end

--hooksecurefunc("ActionButton_OnUpdate", onupdate)
hooksecurefunc("ActionButton_Update", style)
hooksecurefunc("PetActionBar_Update", stylepet)
hooksecurefunc("ShapeshiftBar_OnLoad", styleshift)
hooksecurefunc("ShapeshiftBar_Update", styleshift)
hooksecurefunc("ShapeshiftBar_UpdateState", styleshift)
hooksecurefunc("ActionButton_UpdateHotkeys", updatehotkey)