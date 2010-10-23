local Items = {
	39213, -- Massive Seaforium Charge (Strand of the Ancients)
	47030, -- Huge Seaforium Bombs (Isle of Conquest)
	42986, -- The RP-GG (Wintergrasp)
	37860, -- Ruby Drake (Occulus)
	37815, -- Emerald Drake (Occulus)
	37859, -- Amber Essence (Occulus)
	46029, -- Mimiron's Core (Ulduar)
	--34722, -- Frostweave Bandage (Test)
}

local EquipedItems = {
	49278, -- Goblin Rocket Pack (ICC)
	--50356, -- Corroded Skeleton Key (Test)
}

local function AutoButtonHide()
	AutoButton:SetAlpha(0)
	if not InCombatLockdown() then
		AutoButton:EnableMouse(false)
	else
		AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
		AutoButton:SetScript("OnEvent", function(self, event) 
			if event == "PLAYER_REGEN_ENABLED" then
				AutoButton:EnableMouse(false) 
				AutoButton:UnregisterEvent("PLAYER_REGEN_ENABLED") 
			end
		end)
	end
end

local function AutoButtonShow(item)
	AutoButton:SetAlpha(1)
	if not InCombatLockdown() then
		AutoButton:EnableMouse(true)
		if item then
			AutoButton:SetAttribute("item", item)
		end
	else
		AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
		AutoButton:SetScript("OnEvent", function(self, event) 
			if event == "PLAYER_REGEN_ENABLED" then
				AutoButton:EnableMouse(true) 
				if item then
					AutoButton:SetAttribute("item", item)
				end
				AutoButton:UnregisterEvent("PLAYER_REGEN_ENABLED") 
			end
		end)
	end
end

--Create our Button
local AutoButton = CreateFrame("Button", "AutoButton", UIParent, "SecureActionButtonTemplate")
AutoButton:SetWidth(TukuiDB.Scale(40))
AutoButton:SetHeight(TukuiDB.Scale(40))
AutoButton:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(-58))
TukuiDB.SetTemplate(AutoButton)
TukuiDB.StyleButton(AutoButton, false) 
AutoButton:SetAttribute("type", "item")
AutoButtonHide()

--Texture for our button
AutoButton.t = AutoButton:CreateTexture(nil,"OVERLAY",nil)
AutoButton.t:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
AutoButton.t:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))	
AutoButton.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)

--Count text for our button
AutoButton.c = AutoButton:CreateFontString(nil,"OVERLAY",f)
AutoButton.c:SetFont(TukuiCF.media.font,12,"OUTLINE")
AutoButton.c:SetTextColor(0.8, 0.8, 0.8, 1)
AutoButton.c:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
AutoButton.c:SetJustifyH("CENTER")	

--Cooldown
AutoButton.Cooldown = CreateFrame("Cooldown",nil,AutoButton)
AutoButton.Cooldown:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
AutoButton.Cooldown:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))	

local Scanner = CreateFrame("Frame")
Scanner:RegisterEvent("BAG_UPDATE")
Scanner:RegisterEvent("UNIT_INVENTORY_CHANGED")
Scanner:SetScript("OnEvent", function()
	AutoButtonHide()
	--Scan bags for Item matchs
	for b = 0, NUM_BAG_SLOTS do
		for s = 1, GetContainerNumSlots(b) do
			local itemID = GetContainerItemID(b, s)
			itemID = tonumber(itemID)
			for i, Items in pairs(Items) do
				if itemID == Items then
					local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemID) 
					local count = GetItemCount(itemID)
					local itemIcon = GetItemIcon(itemID)
				
					--Set our texture to the item found in bags
					AutoButton.t:SetTexture(itemIcon)
					
					--Get the count if there is one
					if count and count ~= 1 then
						AutoButton.c:SetText(count)
					else	
						AutoButton.c:SetText("")
					end
					
					AutoButton:SetScript("OnUpdate", function(self, elapsed)
						local cd_start, cd_finish, cd_enable = GetContainerItemCooldown(b, s)
						CooldownFrame_SetTimer(AutoButton.Cooldown, cd_start, cd_finish, cd_enable)
					end)
					AutoButtonShow(itemName)
				end
			end
		end
	end
	
	--Scan inventory for Equipment matches
	for w = 1, 19 do
		for e, EquipedItems in pairs(EquipedItems) do
			if GetInventoryItemID("player", w) == EquipedItems then
				local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(EquipedItems) 
				local itemIcon = GetInventoryItemTexture("player",w)
				--Set our texture to the item found in bags
				AutoButton.t:SetTexture(itemIcon)
				AutoButton.c:SetText("")
				
				AutoButton:SetScript("OnUpdate", function(self, elapsed)
					local cd_start, cd_finish, cd_enable = GetInventoryItemCooldown("player",w)
					CooldownFrame_SetTimer(AutoButton.Cooldown, cd_start, cd_finish, cd_enable)
				end)
				AutoButtonShow(itemName)
			end
		end
	end
end)