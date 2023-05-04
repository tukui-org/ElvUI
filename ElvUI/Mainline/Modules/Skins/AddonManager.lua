local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub = gsub
local unpack = unpack
local GetAddOnInfo = GetAddOnInfo
local GetAddOnEnableState = GetAddOnEnableState
local UIDropDownMenu_GetSelectedValue = UIDropDownMenu_GetSelectedValue
local hooksecurefunc = hooksecurefunc

local function HandleButton(entry, addonIndex)
	if not entry.isSkinned then
		S:HandleCheckBox(entry.Enabled)
		S:HandleButton(entry.LoadAddonButton)

		entry.isSkinned = true
	end

	local checkall -- Get the character from the current list (nil is all characters)
	local character = UIDropDownMenu_GetSelectedValue(_G.AddonCharacterDropDown)
	if character == true then
		character = nil
	else
		checkall = GetAddOnEnableState(nil, addonIndex)
	end

	entry.Title:SetFontObject('ElvUIFontNormal')
	entry.Status:SetFontObject('ElvUIFontSmall')
	entry.Reload:SetFontObject('ElvUIFontSmall')
	entry.Reload:SetTextColor(1.0, 0.3, 0.3)
	entry.LoadAddonButton.Text:SetFontObject('ElvUIFontSmall')

	local checkstate = GetAddOnEnableState(character, addonIndex)
	local enabledForSome = not character and checkstate == 1
	local enabled = checkstate > 0
	local disabled = not enabled or enabledForSome

	if disabled then
		entry.Status:SetTextColor(0.4, 0.4, 0.4)
	else
		entry.Status:SetTextColor(0.7, 0.7, 0.7)
	end

	local name, title, _, loadable, reason = GetAddOnInfo(addonIndex)
	if disabled or reason == 'DEP_DISABLED' then
		entry.Title:SetText(gsub(title or name, '|c%x%x%x%x%x%x%x%x(.-)|?r?','%1'))
	end

	if enabledForSome then
		entry.Title:SetTextColor(0.5, 0.5, 0.5)
	elseif enabled and (loadable or reason == 'DEP_DEMAND_LOADED' or reason == 'DEMAND_LOADED') then
		entry.Title:SetTextColor(0.9, 0.9, 0.9)
	elseif enabled and reason ~= 'DEP_DISABLED' then
		entry.Title:SetTextColor(1.0, 0.2, 0.2)
	else
		entry.Title:SetTextColor(0.3, 0.3, 0.3)
	end

	local checktex = entry.Enabled:GetCheckedTexture()
	checktex.SetVertexColor = nil
	checktex.SetDesaturated = nil

	if not enabled and checkall == 1 then
		checktex:SetVertexColor(0.3, 0.3, 0.3)
		checktex:SetDesaturated(true)
		checktex:Show()
	elseif not checkstate or checkstate == 0 then
		checktex:Hide()
	elseif checkstate == 1 or reason == 'DEP_DISABLED' then
		checktex:SetVertexColor(0.6, 0.6, 0.6)
		checktex:SetDesaturated(true)
		checktex:Show()
	elseif checkstate == 2 then
		checktex:SetVertexColor(unpack(E.media.rgbvaluecolor))
		checktex:SetDesaturated(false)
		checktex:Show()
	end

	-- TriStateCheckbox_SetState interferes (checktex all share the same name)
	checktex.SetVertexColor = E.noop
	checktex.SetDesaturated = E.noop
end

function S:AddonList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.addonManager) then return end

	local AddonList = _G.AddonList
	S:HandlePortraitFrame(AddonList)
	S:HandleButton(AddonList.EnableAllButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.DisableAllButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.OkayButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(AddonList.CancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleDropDownBox(_G.AddonCharacterDropDown, 165)
	S:HandleTrimScrollBar(_G.AddonList.ScrollBar)
	S:HandleCheckBox(_G.AddonListForceLoad)
	_G.AddonListForceLoad:Size(26, 26)

	hooksecurefunc('AddonList_InitButton', HandleButton)
end

S:AddCallback('AddonList')
