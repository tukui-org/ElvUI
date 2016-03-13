local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule('ChatILvL', 'AceEvent-3.0', 'AceTimer-3.0');

--Cache global variables
--Lua functions
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PaperDollItemsFrame

mod.ignoreSlots = {
	[6] = true,
	[7] = true,
}
mod.InvSlotID = { 1,2,3,6,5,10,11,12,8,9,13,14,15,16,4,17,18,7 }
mod.emptySockets = { 
		["Meta "] = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Meta",
		["Red "] = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Red",
		["Blue "] = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Blue",
		["Yellow "]	= "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Yellow",
		["Prismatic "] = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Prismatic",
}

function mod:Update_Frame()

end

function mod:Player_Update()

end

function mod:Inspect_Update()

end

function mod:CreatePlayerObjects(frame)
	local slots = { frame:GetChildren() };

	for i=1, #slots do
		if not(self.ignoreSlots[i]) then
			local button = slots[i]

			button.slotID = self.InvSlotID[i]
			button.ilvlText = button:CreateFontString(nil, 'OVERLAY')
			button.ilvlText:FontTemplate()
			button.ilvlText:SetPoint("BOTTOMRIGHT", -1, 2)
			button.ilvlText:SetText("625")

			local point, anchorPoint, mult = "RIGHT", "LEFT", -1
			if(i < 9 or i == 18) then
				point = "LEFT"
				anchorPoint = "RIGHT"
				mult = 1
			end

			button.enchant = CreateFrame("Button", nil, button)
			button.enchant:SetSize(15, 15)
			button.enchant:SetPoint("TOP"..point, button, "TOP"..anchorPoint, (mult * 4), 0)
			button.enchant:SetScript("OnEnter", TODO_SCRIPT)
			button.enchant:SetTemplate()
			button.enchant.texture = button.enchant:CreateTexture(nil, 'OVERLAY')
			button.enchant.texture:SetInside()
			button.enchant.texture:SetTexture("INTERFACE/ICONS/INV_Jewelry_Talisman_08")
			button.enchant.texture:SetTexCoord(unpack(E.TexCoords))

			button.gem1 = CreateFrame("Button", nil, button)
			button.gem1:SetSize(15, 15)
			button.gem1:SetPoint("BOTTOM"..point, button, "BOTTOM"..anchorPoint, (mult * 4), 0)
			button.gem1:SetScript("OnEnter", TODO_SCRIPT)
			button.gem1:SetTemplate()	
			button.gem1.texture = button.gem1:CreateTexture(nil, 'OVERLAY')
			button.gem1.texture:SetInside()
			button.gem1.texture:SetTexture(mod.emptySockets["Prismatic "])
			button.gem1.texture:SetTexCoord(unpack(E.TexCoords))

			button.gem2 = CreateFrame("Button", nil, button)
			button.gem2:SetSize(15, 15)
			button.gem2:SetPoint(point, button.gem1, anchorPoint, (mult * 2), 0)
			button.gem2:SetScript("OnEnter", TODO_SCRIPT)
			button.gem2:SetTemplate()	
			button.gem2.texture = button.gem2:CreateTexture(nil, 'OVERLAY')
			button.gem2.texture:SetInside()
			button.gem2.texture:SetTexture(mod.emptySockets["Prismatic "])
			button.gem2.texture:SetTexCoord(unpack(E.TexCoords))

			button.gem3 = CreateFrame("Button", nil, button)
			button.gem3:SetSize(15, 15)
			button.gem3:SetPoint(point, button.gem2, anchorPoint, (mult * 2), 0)
			button.gem3:SetScript("OnEnter", TODO_SCRIPT)
			button.gem3:SetTemplate()	
			button.gem3.texture = button.gem3:CreateTexture(nil, 'OVERLAY')
			button.gem3.texture:SetInside()
			button.gem3.texture:SetTexture(mod.emptySockets["Prismatic "])
			button.gem3.texture:SetTexCoord(unpack(E.TexCoords))			
		end
	end
end

function mod:Initialize()
	self:CreatePlayerObjects(PaperDollItemsFrame)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "Player_Update")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Player_Update")

	self:RegisterEvent("SOCKET_INFO_CLOSE", "Player_Update")
	self:RegisterEvent("SOCKET_INFO_SUCCESS", "Player_Update")
	self:RegisterEvent("SOCKET_INFO_UPDATE", "Player_Update")

	self:RegisterEvent("INSPECT_READY", "Inspect_Update")
end

--E:RegisterModule(mod:GetName())