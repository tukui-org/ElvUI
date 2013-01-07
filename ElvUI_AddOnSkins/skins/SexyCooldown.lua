
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SexyCooldownSkin"
-- Strip skinning settings from in-game GUI
local function SCDStripSkinSettings(bar)
	-- Remove conflicting options
	bar.optionsTable.args.icon.args.borderheader = nil
	bar.optionsTable.args.icon.args.border = nil
	bar.optionsTable.args.icon.args.borderColor = nil
	bar.optionsTable.args.icon.args.borderSize = nil
	bar.optionsTable.args.icon.args.borderInset = nil
	--bar.optionsTable.args.icon.args.sizeOffset = nil
	bar.optionsTable.args.bar.args.bnbheader = nil
	bar.optionsTable.args.bar.args.texture = nil
	bar.optionsTable.args.bar.args.backgroundColor = nil
	bar.optionsTable.args.bar.args.border = nil
	bar.optionsTable.args.bar.args.borderColor = nil
	bar.optionsTable.args.bar.args.borderSize = nil
	bar.optionsTable.args.bar.args.borderInset = nil
end

-- Skin Bars
local function SkinSexyCooldownBar(bar)
	SCDStripSkinSettings(bar)
	AS:SkinFrame(bar)
	if(AS:CheckOption("EmbedSexyCooldown")) then
		bar:ClearAllPoints()
	
		bar:Point('BOTTOM', ElvUI_Bar1, 'TOP', 0, 1)
		bar:CreateShadow()
		bar:SetHeight(ElvUI_Bar1Button1:GetHeight())
		if(AS:CheckOption("SortSettings")) then
			bar:Point('BOTTOM', ElvUI_Bar1, 'TOP', 0, 4)
			bar:SetHeight(ElvUI_Bar1:GetHeight()*.8)
		end
		bar:SetWidth(ElvUI_Bar1:GetWidth())
	
		bar:EnableMouse(false)
		PetBattleFrame:HookScript("OnShow",function() bar:Hide() end)
		PetBattleFrame:HookScript("OnHide",function() bar:Show() end)
	end
end


-- Skin Icons
local function SkinSexyCooldownIcon(bar, icon)
	if not icon.skinned then
		AS:SkinFrame(icon, true)
		icon.overlay:CreateBackdrop("Default")
		icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon.tex.SetTexCoord = E.noop
		icon.overlay:SetBackdropColor(0,0,0,0)
		-- Default no background/border
		icon:SetBackdropColor(0,0,0,0)
		icon:SetBackdropBorderColor(E["media"].bordercolor)
		icon.overlay:SetBackdropBorderColor(E["media"].bordercolor)
		icon.skinned = true
	end
end

local function SkinSexyCooldownLabel(bar,label,store)
	if not label.skinned then
		label:SetFont(AS.pixelFont, store.fontsize, "OUTLINE")
	end
end
local function SkinSexyCooldownBackdrop(bar)
		bar:SetTemplate("Transparent")
end

local function HookSCDBar(bar)
	hooksecurefunc(bar,"UpdateBarLook",SkinSexyCooldownBar)
	hooksecurefunc(bar,"UpdateSingleIconLook", SkinSexyCooldownIcon)
	hooksecurefunc(bar,"UpdateLabel",SkinSexyCooldownLabel)
	hooksecurefunc(bar,"UpdateBarBackdrop", SkinSexyCooldownBackdrop)
	-- Static skinning
	bar.settings.icon.borderInset = 0
end

local function SkinSexyCooldown(self)
	local scd = SexyCooldown2
	local LSM = LibStub("LibSharedMedia-3.0")

	scd.CreateBar_ = scd.CreateBar
	scd.CreateBar = function(self, settings, name)
		local bar = scd:CreateBar_(settings,name)
		HookSCDBar(bar)
		return bar
	end

	-- Skin Pre-existing bars
	for _,bar in ipairs(scd.bars) do
		HookSCDBar(bar)
		-- Force a bar update
		bar:UpdateBarLook()
	end
end

AS:RegisterSkin(name,SkinSexyCooldown)