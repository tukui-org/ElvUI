local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].bagbar ~= true then return end


local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent)

local function OnEnter()
	ElvUIBags:SetAlpha(1)
end

local function OnLeave()
	ElvUIBags:SetAlpha(0)
end

local function SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag:Size(E.buttonsize)
	bag.oldTex = icon:GetTexture()
	
	bag:StripTextures()
	bag:SetTemplate("Default", true)
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:ClearAllPoints()
	icon:Point("TOPLEFT", 2, -2)
	icon:Point("BOTTOMRIGHT", -2, 2)
	icon:SetTexCoord(.08, .92, .08, .92)
end

local function LoadBagBar(self)
	MainMenuBarBackpackButton:SetParent(self)
	MainMenuBarBackpackButton.SetParent = E.dummy
	MainMenuBarBackpackButton:ClearAllPoints()
	if C["others"].bagbardirection == "VERTICAL" then
		MainMenuBarBackpackButton:Point("BOTTOM", self, "BOTTOM")
	else
		MainMenuBarBackpackButton:Point("LEFT", self, "LEFT")
	end
	
	if C["others"].bagbarmouseover == true then
		MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
		MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)
	end
	
	SkinBag(MainMenuBarBackpackButton)
	MainMenuBarBackpackButtonCount:SetFont(C["media"].font, C["general"].fontscale - 2, "THINOUTLINE")
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", 0, 2)
	
	for i=0, NUM_BAG_FRAMES-1 do
		_G["CharacterBag"..i.."Slot"]:SetParent(self)
		_G["CharacterBag"..i.."Slot"].SetParent = E.dummy
		
		SkinBag(_G["CharacterBag"..i.."Slot"])
		
		if i == 0 then
			_G["CharacterBag"..i.."Slot"]:ClearAllPoints()
			if C["others"].bagbardirection == "VERTICAL" then
				_G["CharacterBag"..i.."Slot"]:Point("BOTTOM", MainMenuBarBackpackButton, "TOP", 0, E.buttonspacing)
			else
				_G["CharacterBag"..i.."Slot"]:Point("LEFT", MainMenuBarBackpackButton, "RIGHT", E.buttonspacing, 0)
			end
		else
			_G["CharacterBag"..i.."Slot"]:ClearAllPoints()
			if C["others"].bagbardirection == "VERTICAL" then
				_G["CharacterBag"..i.."Slot"]:Point("BOTTOM", _G["CharacterBag"..(i-1).."Slot"], "TOP", 0, E.buttonspacing)	
			else
				_G["CharacterBag"..i.."Slot"]:Point("LEFT", _G["CharacterBag"..(i-1).."Slot"], "RIGHT", E.buttonspacing, 0)	
			end
		end
		
		if C["others"].bagbarmouseover == true then
			_G["CharacterBag"..i.."Slot"]:HookScript("OnEnter", OnEnter)
			_G["CharacterBag"..i.."Slot"]:HookScript("OnLeave", OnLeave)		
		end
	end
end

ElvUIBags:RegisterEvent("PLAYER_LOGIN")
ElvUIBags:SetScript("OnEvent", LoadBagBar)
ElvUIBags:Point("BOTTOMLEFT", ElvuiInfoLeft, "BOTTOMRIGHT", 20, 0)

if C["others"].bagbardirection == "VERTICAL" then
	ElvUIBags:Width(E.buttonsize + 4)
	ElvUIBags:Height(E.buttonsize*(NUM_BAG_FRAMES + 1) + E.buttonspacing*(NUM_BAG_FRAMES + 1))
else
	ElvUIBags:Width(E.buttonsize*(NUM_BAG_FRAMES + 1) + E.buttonspacing*(NUM_BAG_FRAMES + 1))
	ElvUIBags:Height(E.buttonsize + 4)
end

if C["others"].bagbarmouseover == true then
	ElvUIBags:SetAlpha(0)
	ElvUIBags:EnableMouse(true)
	ElvUIBags:SetScript("OnEnter", OnEnter)
	ElvUIBags:SetScript("OnLeave", OnLeave)
end

E.CreateMover(ElvUIBags, "BagMover", "Bags", nil, nil)