local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, wipe = ipairs, wipe
local format, next, strjoin = format, next, strjoin
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecializations = GetNumSpecializations
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetTalentInfo = GetTalentInfo
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local SetLootSpecialization = SetLootSpecialization
local SetSpecialization = SetSpecialization
local ShowUIPanel = ShowUIPanel
local LOOT = LOOT
local PVP_TALENTS = PVP_TALENTS
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT
local TALENT_FRAME_DROP_DOWN_STARTER_BUILD = TALENT_FRAME_DROP_DOWN_STARTER_BUILD
local STARTER_BUILD_TRAIT_CONFIG_ID = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_ClassTalents_GetConfigIDsBySpecID = C_ClassTalents.GetConfigIDsBySpecID
local C_ClassTalents_GetLastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID
local C_ClassTalents_GetHasStarterBuild = C_ClassTalents.GetHasStarterBuild
local C_ClassTalents_GetStarterBuildActive = C_ClassTalents.GetStarterBuildActive
local C_Traits_GetConfigInfo = C_Traits.GetConfigInfo
local C_ClassTalents_LoadConfig = C_ClassTalents.LoadConfig
local C_ClassTalents_UpdateLastSelectedSavedConfigID = C_ClassTalents.UpdateLastSelectedSavedConfigID
local C_ClassTalents_SetStarterBuildActive = C_ClassTalents.SetStarterBuildActive

local displayString, lastPanel, active, activeLoadout = '' -- todo show active loadout in datatext
local activeString = strjoin('', '|cff00FF00' , _G.ACTIVE_PETS, '|r')
local inactiveString = strjoin('', '|cffFF0000', _G.FACTION_INACTIVE, '|r')
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) end },
}

local specList = {
	{ text = _G.SPECIALIZATION, isTitle = true, notCheckable = true },
}

local loadoutList = {
	{ text = L["Loadouts"], isTitle = true, notCheckable = true },
}

local mainIcon = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local function OnEvent(self, event)
	lastPanel = self

	if #menuList == 2 then
		for index = 1, GetNumSpecializations() do
			local id, name, _, icon = GetSpecializationInfo(index)
			if id then
				menuList[index + 2] = { text = name, checked = function() return GetLootSpecialization() == id end, func = function() SetLootSpecialization(id) end }
				specList[index + 1] = { text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', icon, name), checked = function() return GetSpecialization() == index end, func = function() SetSpecialization(index) end }
			end
		end
	end

	local specIndex = GetSpecialization()
	local specialization = GetLootSpecialization()
	local info = DT.SPECIALIZATION_CACHE[specIndex]

	if not info then
		self.text:SetText('N/A')
		return
	end

	if event == 'ELVUI_FORCE_UPDATE' or event == 'TRAIT_CONFIG_UPDATED' or event == 'TRAIT_CONFIG_DELETE' then
		local builds = C_ClassTalents_GetConfigIDsBySpecID(info.id)

		if C_ClassTalents_GetHasStarterBuild() and not builds[STARTER_BUILD_TRAIT_CONFIG_ID] then
			tinsert(builds, STARTER_BUILD_TRAIT_CONFIG_ID)
		end

		-- todo refactor funcs?
		for index, configID in next, builds do
			if configID == STARTER_BUILD_TRAIT_CONFIG_ID then
				loadoutList[index + 1] = {
					text = BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD),
					checked = function()
						return C_ClassTalents_GetStarterBuildActive()
					end,
					func = function()
						C_ClassTalents_SetStarterBuildActive(true)
						C_ClassTalents_UpdateLastSelectedSavedConfigID(info.id, STARTER_BUILD_TRAIT_CONFIG_ID)
					end
				}
			else
				local configInfo = C_Traits_GetConfigInfo(configID)
				loadoutList[index + 1] = {
					text = configInfo.name,
					checked = function()
						return configID == C_ClassTalents_GetLastSelectedSavedConfigID(info.id)
					end,
					func = function()
						C_ClassTalents_LoadConfig(configID, true)
						if C_ClassTalents_GetLastSelectedSavedConfigID(info.id) ~= STARTER_BUILD_TRAIT_CONFIG_ID then
							C_ClassTalents_SetStarterBuildActive(false)
						end
						C_ClassTalents_UpdateLastSelectedSavedConfigID(info.id, configID)
					end
				}
			end
		end
	end

	active = specIndex

	local spec = format(mainIcon, info.icon)

	if specialization == 0 or info.id == specialization then
		self.text:SetFormattedText('%s %s', spec, info.name)
	else
		info = DT.SPECIALIZATION_CACHE[specialization]
		self.text:SetFormattedText('%s: %s %s: %s', L["Spec"], spec, LOOT, format(mainIcon, info.icon))
	end
end

local listIcon = '|T%s:16:16:0:0:50:50:4:46:4:46|t'
local function AddTexture(texture)
	return texture and format(listIcon, texture) or ''
end

local function OnEnter()
	DT.tooltip:ClearLines()

	for i, info in ipairs(DT.SPECIALIZATION_CACHE) do
		DT.tooltip:AddLine(strjoin(' ', format(displayString, info.name), AddTexture(info.icon), (i == active and activeString or inactiveString)), 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')

	local specialization = GetLootSpecialization()
	local sameSpec = specialization == 0 and GetSpecialization()
	local specIndex = DT.SPECIALIZATION_CACHE[sameSpec or specialization]
	if specIndex and specIndex.name then
		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, sameSpec and format(LOOT_SPECIALIZATION_DEFAULT, specIndex.name) or specIndex.name))
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Loadouts"], 0.69, 0.31, 0.31)

	if #loadoutList > 1 then
		for index = 2, #loadoutList do
			local loadout = loadoutList[index]
			DT.tooltip:AddLine(strjoin(' - ', loadout.text, (loadout.checked() and activeString or inactiveString)), 1, 1, 1)
		end
	end

	local pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()
	if next(pvpTalents) then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(PVP_TALENTS, 0.69, 0.31, 0.31)

		for i, talentID in next, pvpTalents do
			if i > 4 then break end
			local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
			if name and unlocked then
				DT.tooltip:AddLine(AddTexture(icon)..' '..name)
			end
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	DT.tooltip:AddLine(L["|cffFFFFFFControl + Left Click:|r Change Loadout"])
	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])
	DT.tooltip:Show()
end

local function OnClick(self, button)
	local specIndex = GetSpecialization()
	if not specIndex then return end

	if button == 'LeftButton' then
		if not _G.ClassTalentFrame then
			_G.LoadAddOn('Blizzard_ClassTalentUI')
		end
		if IsShiftKeyDown() then
			if not _G.ClassTalentFrame:IsShown() then
				ShowUIPanel(_G.ClassTalentFrame)
			else
				HideUIPanel(_G.ClassTalentFrame)
			end
		elseif IsControlKeyDown() then
			E:SetEasyMenuAnchor(E.EasyMenu, self)
			_G.EasyMenu(loadoutList, E.EasyMenu, nil, nil, nil, 'MENU')
		else
			E:SetEasyMenuAnchor(E.EasyMenu, self)
			_G.EasyMenu(specList, E.EasyMenu, nil, nil, nil, 'MENU')
		end
	else
		local _, specName = GetSpecializationInfo(specIndex)
		menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

		E:SetEasyMenuAnchor(E.EasyMenu, self)
		_G.EasyMenu(menuList, E.EasyMenu, nil, nil, nil, 'MENU')
	end
end

local function ValueColorUpdate()
	displayString = strjoin('', '|cffFFFFFF%s:|r ')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Talent/Loot Specialization', nil, { 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_LOOT_SPEC_UPDATED', 'TRAIT_CONFIG_UPDATED', 'TRAIT_CONFIG_DELETED' }, OnEvent, nil, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
