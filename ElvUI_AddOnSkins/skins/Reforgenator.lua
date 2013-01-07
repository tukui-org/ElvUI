local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ReforgenatorSkin"
local function SkinReforgenator(self)
	AS:SkinFrame(ReforgenatorPanel)
	AS:SkinFrame(ReforgenatorMessageFrame)
	AS:SkinFrame(ReforgenatorMessageTextFrame)
	S:HandleDropDownBox(ReforgenatorPanel_ModelSelection)
	ReforgenatorPanel_ModelSelection:Point("TOP", ReforgenatorPanel, "TOP", -10, -25)
	ReforgenatorPanel_Notes:Point("TOPLEFT", ReforgenatorPanel_ModelSelection, "TOPRIGHT", -5, -5)
	ReforgenatorPanel_SandboxSelection:Point("TOP", ReforgenatorPanel, "TOP", -10, -50)
	ReforgenatorPanel_TargetLevelSelection:Point("TOP", ReforgenatorPanel, "TOP", -10, -75)
	S:HandleDropDownBox(ReforgenatorPanel_SandboxSelection)
	S:HandleDropDownBox(ReforgenatorPanel_TargetLevelSelection)
	S:HandleCloseButton(ReforgenatorPanel_CloseButton)
	ReforgeListScrollFrame:StripTextures()
	S:HandleScrollBar(ReforgeListScrollFrameScrollBar)
	ReforgeListScrollFrameScrollBar:Point("TOPLEFT", ReforgeListScrollFrame, "TOPRIGHT", 15, -16)
	hooksecurefunc(Reforgenator,"UpdateWindowItem",function(self, index, itemDescriptor)
		if not itemDescriptor then return end
		local item = _G["ReforgenatorPanel_Item"..index]
		local iconTexture = _G["ReforgenatorPanel_Item" .. index .. "IconTexture"]
		local checked = _G["ReforgenatorPanel_Item" .. index .. "Checked"]
		item:StripTextures()
		iconTexture:SetTexCoord(.08,.88,.08,.88)
		item:CreateBackdrop("Default")
	    local texture = select(10, GetItemInfo(itemDescriptor.itemLink))
	    iconTexture:SetTexture(texture)
		S:HandleCheckBox(checked)
	end)
end

AS:RegisterSkin(name,SkinReforgenator)