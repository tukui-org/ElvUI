local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns

function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	local maxShown = _G.MAX_ADDONS_DISPLAYED

	S:HandleFrame(AddonList, true)
	S:HandleButton(AddonList.EnableAllButton, true)
	S:HandleButton(AddonList.DisableAllButton, true)
	S:HandleButton(AddonList.OkayButton, true)
	S:HandleButton(AddonList.CancelButton, true)
	S:HandleScrollBar(_G.AddonListScrollFrameScrollBar)
	S:HandleDropDownBox(AddonList.Dropdown, 165)
	S:HandleCheckBox(_G.AddonListForceLoad)

	_G.AddonListForceLoad:Size(26)

	S:HandleFrame(_G.AddonListScrollFrame, true, nil, -14, 0, 0, -1)

	hooksecurefunc('AddonList_Update', function()
		local numEntrys = GetNumAddOns()
		for i = 1, maxShown do
			local index = AddonList.offset + i
			if index <= numEntrys then
				local entry = _G['AddonListEntry'..i]
				local entryTitle = _G['AddonListEntry'..i..'Title']
				local checkbox = _G['AddonListEntry'..i..'Enabled']
				local _, _, _, _, reason = GetAddOnInfo(index)

				if not entry.IsSkinned then
					S:HandleCheckBox(_G['AddonListEntry'..i..'Enabled'], nil, nil, true)
					S:HandleButton(entry.LoadAddonButton)

					entryTitle:SetFontObject('ElvUIFontNormal')
					entry.Status:SetFontObject('ElvUIFontSmall')
					entry.Reload:SetFontObject('ElvUIFontSmall')
					entry.Reload:SetTextColor(1.0, 0.3, 0.3)
					entry.LoadAddonButton.Text:SetFontObject('ElvUIFontSmall')

					entry.IsSkinned = true
				end

				local checkstate = E:GetAddOnEnableState(index)
				if checkstate == 2 then
					entry.Status:SetTextColor(0.7, 0.7, 0.7)
				else
					entry.Status:SetTextColor(0.4, 0.4, 0.4)
				end

				local checktex = checkbox:GetCheckedTexture()
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
	end)
end

S:AddCallback('AddonList')
