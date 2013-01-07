
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local function OnEnter11(Self)
  GameTooltip:SetOwner(Self, "ANCHOR_CURSOR")
  GameTooltip:AddLine("Lock or Make Moveable", 1, 1, 1)
  GameTooltip:Show()
end

local function OnEnter10(Self)
  GameTooltip:SetOwner(Self, "ANCHOR_CURSOR")
  GameTooltip:AddLine("Options", 1, 1, 1)
  GameTooltip:Show()
end

local function OnEnter9(Self)
  GameTooltip:SetOwner(Self, "ANCHOR_CURSOR")
  GameTooltip:AddLine("Close", 1, 1, 1)
  GameTooltip:Show()
end

local function OnLeave(Self)
  GameTooltip:Hide()
end

local name = 'BGDefenderSkin'
local function SkinBGDefender(self)
	AS:SkinFrame(BGDefenderFrame)

	local StripAllTextures = {
		"Button9",
		"Button10",
		"Button11",
		}

	local buttons = {
		"Button1",
		"Button2",
		"Button3",
		"Button4",
		"Button5",
		"Button6",
		"Button7",
		"Button8",
		"Button9",
		"Button10",
		"Button11",
		}
							
	for _, object in pairs(StripAllTextures) do
                _G[object]:StripTextures()
	end	

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end	
	
	BGDefenderFrame:SetWidth(160)
	BGDefenderFrame:SetHeight(72)
	Button9:SetWidth(16)
	Button9:SetHeight(16)
	Button10:SetWidth(16)
	Button10:SetHeight(16)
	Button11:SetWidth(16)
	Button11:SetHeight(16)
		
	Text1:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 5, -3)
	Button1:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 5, -25)
	Button2:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 30, -25)
	Button3:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 55, -25)
	Button4:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 80, -25)
	Button5:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 105, -25)
	Button6:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 130, -25)
	Button7:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 5, -48)
	Button8:Point("TOPLEFT", BGDefenderFrame, "TOPLEFT", 97, -48)
	
	S:HandleDropDownBox(DropDown1, 200)
	S:HandleDropDownBox(DropDown2, 200)
	S:HandleDropDownBox(DropDown3, 200)
	
	S:HandleCheckBox(BGDefenderPrefaceButton)
	
	Text1:SetTextColor(23/255, 132/255, 209/255)
		
	Button1:SetNormalFontObject("GameFontHighlight")
	local font = Button1:GetNormalFontObject()
	font:SetTextColor(1, 1, 1, 1)
	Button1:SetNormalFontObject(font)
	
	Button9:SetScript("OnEnter", OnEnter9)
	Button9:SetScript("OnLeave", OnLeave)
	Button10:SetScript("OnEnter", OnEnter10)
	Button10:SetScript("OnLeave", OnLeave)
	Button11:SetScript("OnEnter", OnEnter11)
	Button11:SetScript("OnLeave", OnLeave)
end

AS:RegisterSkin(name,SkinBGDefender)