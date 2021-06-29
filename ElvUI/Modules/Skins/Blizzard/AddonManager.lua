local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local unpack = unpack
local GetAddOnInfo = GetAddOnInfo
local GetAddOnEnableState = GetAddOnEnableState
local UIDropDownMenu_GetSelectedValue = UIDropDownMenu_GetSelectedValue
local hooksecurefunc = hooksecurefunc

function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	local maxShown = _G.MAX_ADDONS_DISPLAYED
	local AddonCharacterDropDown = _G.AddonCharacterDropDown

	S:HandlePortraitFrame(AddonList)
	S:HandleButton(AddonList.EnableAllButton, true, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.DisableAllButton, true, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.OkayButton, true, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.CancelButton, true, nil, nil, true, nil, nil, nil, true)
	S:HandleDropDownBox(AddonCharacterDropDown, 165)
	S:HandleScrollBar(_G.AddonListScrollFrameScrollBar)
	S:HandleCheckBox(_G.AddonListForceLoad)
	_G.AddonListForceLoad:Size(26, 26)

	_G.AddonListScrollFrame:StripTextures()
	_G.AddonListScrollFrame:CreateBackdrop('Transparent')
	_G.AddonListScrollFrame.backdrop:Point('TOPLEFT', -14, 0)
	_G.AddonListScrollFrame.backdrop:Point('BOTTOMRIGHT', 0, -1)

	for i = 1, maxShown do
		S:HandleCheckBox(_G['AddonListEntry'..i..'Enabled'])
		S:HandleButton(_G['AddonListEntry'..i].LoadAddonButton)
	end

	hooksecurefunc('AddonList_Update', function()
		for i = 1, maxShown do
			local entry = _G['AddonListEntry'..i]
			if entry and entry:IsShown() then
				local id = entry:GetID()
				local text = _G['AddonListEntry'..i..'Title']
				local checkbox = _G['AddonListEntry'..i..'Enabled']
				local checktex = checkbox:GetCheckedTexture()

				local checkall -- Get the character from the current list (nil is all characters)
				local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown)
				if character == true then
					character = nil
				else
					checkall = GetAddOnEnableState(nil, id)
				end

				text:SetFontObject('ElvUIFontNormal')
				entry.Status:SetFontObject('ElvUIFontSmall')
				entry.Reload:SetFontObject('ElvUIFontSmall')
				entry.Reload:SetTextColor(1.0, 0.3, 0.3)
				entry.LoadAddonButton.Text:SetFontObject('ElvUIFontSmall')

				local checkstate = GetAddOnEnableState(character, id)
				local enabledForSome = not character and checkstate == 1
				local enabled = checkstate > 0
				local disabled = not enabled or enabledForSome

				if disabled then
					entry.Status:SetTextColor(0.4, 0.4, 0.4)
				else
					entry.Status:SetTextColor(0.7, 0.7, 0.7)
				end

				local name, title, _, loadable, reason = GetAddOnInfo(id)
				if disabled or reason == 'DEP_DISABLED' then
					text:SetText(gsub(title or name, '|c%x%x%x%x%x%x%x%x(.-)|?r?','%1'))
				end

				if enabledForSome then
					text:SetTextColor(0.5, 0.5, 0.5)
				elseif enabled and (loadable or reason == 'DEP_DEMAND_LOADED' or reason == 'DEMAND_LOADED') then
					text:SetTextColor(0.9, 0.9, 0.9)
				elseif enabled and reason ~= 'DEP_DISABLED' then
					text:SetTextColor(1.0, 0.2, 0.2)
				else
					text:SetTextColor(0.3, 0.3, 0.3)
				end

				if not enabled and checkall == 1 then
					checktex:SetVertexColor(0.3, 0.3, 0.3)
					checktex:SetDesaturated(true)
					checktex:Show()
				elseif not checkstate or checkstate == 0 then
					checktex:Hide()
				elseif checkstate == 1 then
					checktex:SetVertexColor(0.6, 0.6, 0.6)
					checktex:SetDesaturated(true)
					checktex:Show()
				elseif checkstate == 2 then
					checktex:SetVertexColor(unpack(E.media.rgbvaluecolor))
					checktex:SetDesaturated(false)
					checktex:Show()
				end
			end
		end
	end)
end

S:AddCallback('AddonList')
