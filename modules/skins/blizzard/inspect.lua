local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.inspect ~= true then return end
	InspectFrame:StripTextures(true)
	InspectFrameInset:StripTextures(true)
	InspectTalentFramePointsBar:StripTextures()
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:SetAllPoints()
	S:HandleCloseButton(InspectFrameCloseButton)
	
	for i=1, 4 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end
	
	InspectModelFrameBorderTopLeft:Kill()
	InspectModelFrameBorderTopRight:Kill()
	InspectModelFrameBorderTop:Kill()
	InspectModelFrameBorderLeft:Kill()
	InspectModelFrameBorderRight:Kill()
	InspectModelFrameBorderBottomLeft:Kill()
	InspectModelFrameBorderBottomRight:Kill()
	InspectModelFrameBorderBottom:Kill()
	InspectModelFrameBorderBottom2:Kill()
	InspectModelFrameBackgroundOverlay:Kill()
	InspectModelFrame:CreateBackdrop("Default")
	
	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot",
	}
	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot:SetTemplate("Default", true)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:ClearAllPoints()
		icon:Point("TOPLEFT", 2, -2)
		icon:Point("BOTTOMRIGHT", -2, 2)
	end		
	
	local CheckItemBorderColor = CreateFrame("Frame")
	local function ScanSlots()
		local notFound
		for _, slot in pairs(slots) do
			-- Colour the equipment slots by rarity
			local target = _G["Inspect"..slot]
			local slotId, _, _ = GetInventorySlotInfo(slot)
			local itemId = GetInventoryItemID("target", slotId)

			if itemId then
				local _, _, rarity, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
				if not rarity then notFound = true end
				if rarity and rarity > 1 then
					target:SetBackdropBorderColor(GetItemQualityColor(rarity))
				else
					target:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				target:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end	
		
		if notFound == true then
			return false
		else
			CheckItemBorderColor:SetScript('OnUpdate', nil) --Stop updating
			return true
		end		
	end
	
	local function ColorItemBorder(self)
		if self and not ScanSlots() then
			self:SetScript("OnUpdate", ScanSlots) --Run function until all items borders are colored, sometimes when you have never seen an item before GetItemInfo will return nil, when this happens we have to wait for the server to send information.
		end 
	end

	CheckItemBorderColor:RegisterEvent("PLAYER_TARGET_CHANGED")
	CheckItemBorderColor:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	CheckItemBorderColor:RegisterEvent("PARTY_MEMBERS_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)	
	InspectFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder(CheckItemBorderColor)	
	
	InspectPVPFrameBottom:Kill()
	InspectGuildFrameBG:Kill()
	InspectPVPFrame:HookScript("OnShow", function() InspectPVPFrameBG:Kill() end)
	
	for i=1, 3 do
		_G["InspectPVPTeam"..i]:StripTextures()
		_G["InspectTalentFrameTab"..i]:StripTextures()
	end
	
	InspectTalentFrame.bg = CreateFrame("Frame", nil, InspectTalentFrame)
	InspectTalentFrame.bg:SetTemplate("Default")
	InspectTalentFrame.bg:Point("TOPLEFT", InspectTalentFrameBackgroundTopLeft, "TOPLEFT", -2, 2)
	InspectTalentFrame.bg:Point("BOTTOMRIGHT", InspectTalentFrameBackgroundBottomRight, "BOTTOMRIGHT", -20, 52)
	InspectTalentFrame.bg:SetFrameLevel(InspectTalentFrame.bg:GetFrameLevel() - 2)
	
	for i = 1, MAX_NUM_TALENTS do
		local button = _G["InspectTalentFrameTalent"..i]
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
		if button then
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate("Default")
			button.SetHighlightTexture = E.noop
			button.SetPushedTexture = E.noop
			button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			
			if button.Rank then
				button.Rank:FontTemplate(nil, 12, 'OUTLINE')
				button.Rank:ClearAllPoints()
				button.Rank:SetPoint("BOTTOMRIGHT")
			end		
			
			icon:ClearAllPoints()
			icon:Point("TOPLEFT", 2, -2)
			icon:Point("BOTTOMRIGHT", -2, 2)
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end		
end

S:RegisterSkin("Blizzard_InspectUI", LoadSkin)