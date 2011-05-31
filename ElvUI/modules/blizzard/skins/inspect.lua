local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].inspect ~= true then return end

local function LoadSkin()
	InspectFrame:StripTextures(true)
	InspectFrameInset:StripTextures(true)
	InspectTalentFramePointsBar:StripTextures()
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:SetAllPoints()
	E.SkinCloseButton(InspectFrameCloseButton)
	
	for i=1, 4 do
		E.SkinTab(_G["InspectFrameTab"..i])
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
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:ClearAllPoints()
		icon:Point("TOPLEFT", 2, -2)
		icon:Point("BOTTOMRIGHT", -2, 2)
		
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:CreateBackdrop("Default")
		slot.backdrop:SetAllPoints()
	end		
	
	E.SkinRotateButton(InspectModelFrameRotateLeftButton)
	E.SkinRotateButton(InspectModelFrameRotateRightButton)
	InspectModelFrameRotateRightButton:Point("TOPLEFT", InspectModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)
	
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
			button.SetHighlightTexture = E.dummy
			button.SetPushedTexture = E.dummy
			button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			
			if button.Rank then
				button.Rank:SetFont(C["media"].font, 12, C["media"].fontFLAG)
				button.Rank:ClearAllPoints()
				button.Rank:SetPoint("BOTTOMRIGHT")
			end		
			
			icon:ClearAllPoints()
			icon:Point("TOPLEFT", 2, -2)
			icon:Point("BOTTOMRIGHT", -2, 2)
			icon:SetTexCoord(.08, .92, .08, .92)
		end
	end		
end

E.SkinFuncs["Blizzard_InspectUI"] = LoadSkin