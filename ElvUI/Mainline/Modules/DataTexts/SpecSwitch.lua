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
local TALENTS = TALENTS
local PVP_TALENTS = PVP_TALENTS
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT
local TALENT_FRAME_DROP_DOWN_STARTER_BUILD = TALENT_FRAME_DROP_DOWN_STARTER_BUILD
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_ClassTalents_GetConfigIDsBySpecID = C_ClassTalents.GetConfigIDsBySpecID
local C_ClassTalents_GetLastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID
local C_ClassTalents_GetHasStarterBuild = C_ClassTalents.GetHasStarterBuild
local C_ClassTalents_GetStarterBuildActive = C_ClassTalents.GetStarterBuildActive
local C_Traits_GetConfigInfo = C_Traits.GetConfigInfo

local displayString, lastPanel, active = ''
local activeString = strjoin('', '|cff00FF00' , _G.ACTIVE_PETS, '|r')
local inactiveString = strjoin('', '|cffFF0000', _G.FACTION_INACTIVE, '|r')
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) end },
}

local specList = {
	{ text = _G.SPECIALIZATION, isTitle = true, notCheckable = true },
}

local mainIcon = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local function OnEvent(self)
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
	DT.tooltip:AddLine(TALENTS, 0.69, 0.31, 0.31)

	local specID = DT.SPECIALIZATION_CACHE[GetSpecialization()].id
	local builds = C_ClassTalents_GetConfigIDsBySpecID(specID)

	if C_ClassTalents_GetHasStarterBuild() then
		tinsert(builds, 'STARTER')
	end

	if next(builds) then
		local activeConfigID = C_ClassTalents_GetLastSelectedSavedConfigID(specID)
		for _, configID in next, builds do
			if configID == 'STARTER' then
				DT.tooltip:AddLine(strjoin(' - ', TALENT_FRAME_DROP_DOWN_STARTER_BUILD, (C_ClassTalents_GetStarterBuildActive() and activeString or inactiveString)), 1, 1, 1)
			else
				local configInfo = C_Traits_GetConfigInfo(configID)
				DT.tooltip:AddLine(strjoin(' - ', configInfo.name, (configID == activeConfigID and activeString or inactiveString)), 1, 1, 1)
			end
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
	--DT.tooltip:AddLine(L["|cffFFFFFFControl + Left Click:|r Change Loadout"]) -- TODO
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
		--[[elseif IsControlKeyDown() then -- TODO
			E:SetEasyMenuAnchor(E.EasyMenu, self)
			_G.EasyMenu(loadoutList, E.EasyMenu, nil, nil, nil, 'MENU')]]
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

DT:RegisterDatatext('Talent/Loot Specialization', nil, { 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_LOOT_SPEC_UPDATED', 'TRAIT_CONFIG_UPDATED' }, OnEvent, nil, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
