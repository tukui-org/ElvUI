local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetAddOnInfo = C_AddOns.GetAddOnInfo

local function HandleButton(entry, treeNode)
	if not entry.IsSkinned then
		S:HandleCheckBox(entry.Enabled)
		S:HandleButton(entry.LoadAddonButton)

		entry.Title:SetFontObject('ElvUIFontNormal')
		entry.Status:SetFontObject('ElvUIFontSmall')
		entry.Reload:SetFontObject('ElvUIFontSmall')
		entry.Reload:SetTextColor(1.0, 0.3, 0.3)
		entry.LoadAddonButton.Text:SetFontObject('ElvUIFontSmall')

		entry.IsSkinned = true
	end

	local data = treeNode:GetData()
	if data then
		local checkstate = E:GetAddOnEnableState(data.addonIndex)
		if checkstate == 2 then
			entry.Status:SetTextColor(0.7, 0.7, 0.7)
		else
			entry.Status:SetTextColor(0.4, 0.4, 0.4)
		end

		local _, _, _, _, reason = GetAddOnInfo(data.addonIndex)
		local checktex = entry.Enabled:GetCheckedTexture()
		if reason == 'DEP_DISABLED' then
			checktex:SetVertexColor(0.6, 0.6, 0.6)
			checktex:SetDesaturated(true)
		elseif checkstate == 1 then
			checktex:SetVertexColor(1, 0.8, 0.1)
			checktex:SetDesaturated(false)
		elseif checkstate == 2 then
			checktex:SetVertexColor(unpack(E.media.rgbvaluecolor))
			checktex:SetDesaturated(false)
		end
	end
end

function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	S:HandlePortraitFrame(AddonList)
	S:HandleButton(AddonList.EnableAllButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.DisableAllButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.OkayButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.CancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleDropDownBox(AddonList.Dropdown, 165)
	S:HandleTrimScrollBar(AddonList.ScrollBar)
	S:HandleCheckBox(AddonList.ForceLoad)
	AddonList.ForceLoad:Size(26)
	S:HandleEditBox(AddonList.SearchBox)

	hooksecurefunc('AddonList_InitAddon', HandleButton)
end

S:AddCallback('AddonList')
