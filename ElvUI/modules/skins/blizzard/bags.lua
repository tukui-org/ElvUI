local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	local QUEST_ITEM_STRING = select(10, GetAuctionItemClasses())

	BankSlotsFrame:StripTextures()

	S:HandleTab(BankFrameTab1)
	S:HandleTab(BankFrameTab2)
	ReagentBankFrame:HookScript("OnShow", function()
		ReagentBankFrame:StripTextures()
	end)
	S:HandleButton(ReagentBankFrame.DespositButton)

	local function UpdateBorderColors(button)
		button:SetBackdropBorderColor(unpack(E['media'].bordercolor))

		if button.type and button.type == QUEST_ITEM_STRING then
			button:SetBackdropBorderColor(1, 0.2, 0.2)
		elseif button.quality and button.quality > 1 then
			local r, g, b = GetItemQualityColor(button.quality)
			button:SetBackdropBorderColor(r, g, b)
		end
	end

	local function SkinButton(button)
		if not button.skinned then
			for i=1, button:GetNumRegions() do
				local region = select(i, button:GetRegions())
				if region and region:GetObjectType() == 'Texture' and region ~= button.searchOverlay then
					region:SetTexture(nil)
				end
			end
			button:SetTemplate("Default", true)
			button:StyleButton()

			local icon = button.icon
			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))

			button.searchOverlay:ClearAllPoints()
			button.searchOverlay:SetAllPoints(icon)

			if button.IconQuestTexture then
				button.IconQuestTexture:SetTexCoord(unpack(E.TexCoords))
				button.IconQuestTexture:SetInside(button)
			end

			if button.Cooldown then
				E:RegisterCooldown(button.Cooldown)
			end

			button.skinned = true
		end
	end

	hooksecurefunc('ContainerFrame_Update', function(frame)
		for i=1, frame.size, 1 do
			local questTexture = _G[frame:GetName().."Item"..i.."IconQuestTexture"];
			if questTexture:IsShown() and questTexture:GetTexture() == TEXTURE_ITEM_QUEST_BORDER then
				questTexture:Hide()
			end
		end
	end)

	local function SkinBagButtons(container, button)
		SkinButton(button)

		local texture, _, _, _, _, _, itemLink = GetContainerItemInfo(container:GetID(), button:GetID())
		local isQuestItem, questId = GetContainerItemQuestInfo(container:GetID(), button:GetID())
		_G[button:GetName().."IconTexture"]:SetTexture(texture)
		button.type = nil
		button.quality = nil
		button.ilink = itemLink
		if button.ilink then
			button.name, _, button.quality, _, _, button.type = GetItemInfo(button.ilink)
		end

		if questId or isQuestItem then
			button.type = QUEST_ITEM_STRING
		end

		UpdateBorderColors(button)
	end

	local function SkinBags()
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local container = _G["ContainerFrame"..i]
			if container and not container.backdrop then
				container:SetFrameStrata("HIGH")
				container:StripTextures(true)
				container:CreateBackdrop("Transparent")
				container.backdrop:SetInside()
				S:HandleCloseButton(_G[container:GetName().."CloseButton"])

				container:HookScript("OnShow", function(self)
					if self and self.size then
						for b=1, self.size, 1 do
							local button = _G[self:GetName().."Item"..b]
							SkinBagButtons(self, button)
						end
					end
				end)

				if i == 1 then
					BackpackTokenFrame:StripTextures(true)
					for i=1, MAX_WATCHED_TOKENS do
						_G["BackpackTokenFrameToken"..i].icon:SetTexCoord(unpack(E.TexCoords))
						_G["BackpackTokenFrameToken"..i]:CreateBackdrop("Default")
						_G["BackpackTokenFrameToken"..i].backdrop:SetOutside(_G["BackpackTokenFrameToken"..i].icon)
						_G["BackpackTokenFrameToken"..i].icon:Point("LEFT", _G["BackpackTokenFrameToken"..i].count, "RIGHT", 2, 0)
					end
				end
			end

			if container and container.size then
				for b=1, container.size, 1 do
					local button = _G[container:GetName().."Item"..b]
					SkinBagButtons(container, button)
				end
			end
		end
	end

	--Bank
	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not BankFrame.backdrop then
			BankFrame:StripTextures(true)
			BankFrame:SetTemplate('Transparent')
			S:HandleButton(BankFramePurchaseButton, true)
			S:HandleCloseButton(BankFrameCloseButton)

			BankFrame.backdrop2 = CreateFrame("Frame", nil, BankSlotsFrame)
			BankFrame.backdrop2:SetTemplate("Default")
			BankFrame.backdrop2:Point("TOPLEFT", BankFrameItem1, "TOPLEFT", -6, 6)
			BankFrame.backdrop2:Point("BOTTOMRIGHT", BankFrameItem28, "BOTTOMRIGHT", 6, -6)

			BankFrame.backdrop3 = CreateFrame("Frame", nil, BankSlotsFrame)
			BankFrame.backdrop3:SetTemplate("Default")
			BankFrame.backdrop3:Point("TOPLEFT", BankSlotsFrame.Bag1, "TOPLEFT", -6, 6)
			BankFrame.backdrop3:Point("BOTTOMRIGHT", BankSlotsFrame.Bag7, "BOTTOMRIGHT", 6, -6)

			BankFrameMoneyFrameInset:Kill()
			BankFrameMoneyFrameBorder:Kill()
			BankFrame.backdrop = true;
		end

		SkinButton(button)

		if not button.levelAdjusted then
			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button.levelAdjusted = true;
		end

		local inventoryID = button:GetInventorySlot()
		local textureName = GetInventoryItemTexture("player",inventoryID);

		if ( textureName ) then
			button.icon:SetTexture(textureName)
		elseif ( button.isBag ) then
			local _, slotTextureName = GetInventorySlotInfo("Bag"..button:GetID())
			button.icon:SetTexture(slotTextureName)
		end

		if not button.isBag then
			local container = button:GetParent():GetID();
			local texture, _, _, _, _, _, itemLink = GetContainerItemInfo(container, button:GetID())
			local isQuestItem, questId = GetContainerItemQuestInfo(container, button:GetID())
			button.type = nil
			button.ilink = itemLink
			button.quality = nil

			if button.ilink then
				button.name, _, button.quality, _, _, button.type = GetItemInfo(button.ilink)
			end

			if isQuestItem or questId then
				button.type = QUEST_ITEM_STRING
			end

			UpdateBorderColors(button)
		end


		--[[if highlight and not highlight.skinned then
			highlight:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3)
			hooksecurefunc(highlight, "SetTexture", function(self, r, g, b, a)
				if a ~= 0.3 then
					highlight:SetTexture(unpack(E["media"].rgbvaluecolor), 0.3)
				end
			end)
			highlight:SetInside()
			highlight.skinned = true
		end]]
	end)

	S:HandleEditBox(BagItemSearchBox)
	BagItemSearchBox:Height(BagItemSearchBox:GetHeight() - 5)

	BagHelpBox:Kill()
	BankItemSearchBox:StripTextures()
	BankItemSearchBox:CreateBackdrop("Overlay")
	BankItemSearchBox.backdrop:Point("TOPLEFT", 10, -1)
	BankItemSearchBox.backdrop:Point("BOTTOMRIGHT", 4, 1)

	local bags = CreateFrame("Frame")
	bags:RegisterEvent("BAG_UPDATE")
	bags:RegisterEvent("ITEM_LOCK_CHANGED")
	bags:RegisterEvent("BAG_CLOSED")
	bags:SetScript("OnEvent", SkinBags)
	SkinBags()
end

S:RegisterSkin('ElvUI', LoadSkin)