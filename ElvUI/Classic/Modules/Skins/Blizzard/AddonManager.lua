local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local GetNumAddOns = GetNumAddOns
local GetAddOnInfo = GetAddOnInfo
local GetAddOnEnableState = GetAddOnEnableState
local UIDropDownMenu_GetSelectedValue = UIDropDownMenu_GetSelectedValue
local hooksecurefunc = hooksecurefunc

function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	local maxShown = _G.MAX_ADDONS_DISPLAYED
	local AddonCharacterDropDown = _G.AddonCharacterDropDown

	S:HandleFrame(AddonList, true)
	S:HandleButton(AddonList.EnableAllButton, true)
	S:HandleButton(AddonList.DisableAllButton, true)
	S:HandleButton(AddonList.OkayButton, true)
	S:HandleButton(AddonList.CancelButton, true)
	S:HandleDropDownBox(AddonCharacterDropDown, 165)
	S:HandleScrollBar(_G.AddonListScrollFrameScrollBar)
	S:HandleCheckBox(_G.AddonListForceLoad)

	_G.AddonListForceLoad:Size(26, 26)

	S:HandleFrame(_G.AddonListScrollFrame, true, nil, -14, 0, 0, -1)

	for i = 1, maxShown do
		S:HandleCheckBox(_G["AddonListEntry"..i.."Enabled"], nil, nil, true)
		S:HandleButton(_G["AddonListEntry"..i].LoadAddonButton)
	end

	local font = E.Libs.LSM:Fetch('font', 'Expressway')
	hooksecurefunc('AddonList_Update', function()
		local numEntrys = GetNumAddOns()
		for i = 1, maxShown do
			local index = AddonList.offset + i
			if index <= numEntrys then
				local entry = _G["AddonListEntry"..i]
				local string = _G["AddonListEntry"..i.."Title"]
				local checkbox = _G["AddonListEntry"..i.."Enabled"]
				local name, title, _, loadable, reason = GetAddOnInfo(index)

				-- Get the character from the current list (nil is all characters)
				local checkall
				local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown)
				if character == true then
					character = nil
				else
					checkall = GetAddOnEnableState(nil, index)
				end

				local checkstate = GetAddOnEnableState(character, index)
				local enabled = checkstate > 0

				string:FontTemplate(font, 13, 'NONE')
				entry.Status:FontTemplate(font, 11, 'NONE')
				entry.Reload:FontTemplate(font, 11, 'NONE')
				entry.Reload:SetTextColor(1.0, 0.3, 0.3)
				entry.LoadAddonButton.Text:FontTemplate(font, 11, 'NONE')

				local enabledForSome = not character and checkstate == 1
				local disabled = not enabled or enabledForSome

				if disabled then
					entry.Status:SetTextColor(0.4, 0.4, 0.4)
				else
					entry.Status:SetTextColor(0.7, 0.7, 0.7)
				end

				if disabled or reason == "DEP_DISABLED" then
					string:SetText(gsub(title or name, '|c%x%x%x%x%x%x%x%x(.-)|?r?','%1'))
				end

				if enabledForSome then
					string:SetTextColor(0.5, 0.5, 0.5)
				elseif enabled and (loadable or reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED") then
					string:SetTextColor(0.9, 0.9, 0.9)
				elseif enabled and reason ~= "DEP_DISABLED" then
					string:SetTextColor(1.0, 0.2, 0.2)
				else
					string:SetTextColor(0.3, 0.3, 0.3)
				end

				local checktex = checkbox:GetCheckedTexture()
				if not enabled and checkall == 1 then
					checktex:SetVertexColor(0.3, 0.3, 0.3)
					checktex:SetDesaturated(false)
					checktex:Show()
				elseif checkstate == 0 then
					checktex:Hide()
				end
			end
		end
	end)
end

S:AddCallback('AddonList')
