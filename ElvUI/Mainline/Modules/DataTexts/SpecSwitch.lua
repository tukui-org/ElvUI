local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs, tinsert, tremove = ipairs, tinsert, tremove
local format, next, strjoin = format, next, strjoin

local EasyMenu = EasyMenu
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecializations = GetNumSpecializations
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local HideUIPanel = HideUIPanel
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local LoadAddOn = LoadAddOn
local SetLootSpecialization = SetLootSpecialization
local SetSpecialization = SetSpecialization
local ShowUIPanel = ShowUIPanel

local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_Traits_GetConfigInfo = C_Traits.GetConfigInfo

local GetHasStarterBuild = C_ClassTalents.GetHasStarterBuild
local GetStarterBuildActive = C_ClassTalents.GetStarterBuildActive
local GetConfigIDsBySpecID = C_ClassTalents.GetConfigIDsBySpecID
local GetLastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID
local CanUseClassTalents = PlayerUtil.CanUseClassTalents

local LOOT = LOOT
local UNKNOWN = UNKNOWN
local PVP_TALENTS = PVP_TALENTS
local BLUE_FONT_COLOR = BLUE_FONT_COLOR
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT
local STARTER_ID = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local displayString, active = '|cffFFFFFF%s:|r'
local activeString = strjoin('', '|cff00FF00' , _G.ACTIVE_PETS, '|r')
local inactiveString = strjoin('', '|cffFF0000', _G.FACTION_INACTIVE, '|r')

local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) end },
}

local specList = { { text = _G.SPECIALIZATION, isTitle = true, notCheckable = true } }
local loadoutList = { { text = L["Loadouts"], isTitle = true, notCheckable = true } }

local DEFAULT_TEXT = E:RGBToHex(0.9, 0.9, 0.9, nil, _G.TALENT_FRAME_DROP_DOWN_DEFAULT)
local STARTER_TEXT = E:RGBToHex(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, nil, _G.TALENT_FRAME_DROP_DOWN_STARTER_BUILD)

local mainIcon = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local listIcon = '|T%s:16:16:0:0:50:50:4:46:4:46|t'
local specText = '|T%s:14:14:0:0:64:64:4:60:4:60|t  %s'

local function starter_checked()
	return GetStarterBuildActive()
end

local function loadout_checked(data)
	return data and data.arg1 == DT.ClassTalentsID
end

local loadout_func
do
	local loadoutID
	local function loadout_callback(_, configID)
		return configID == loadoutID
	end

	loadout_func = function(_, arg1)
		if not _G.ClassTalentFrame then
			_G.ClassTalentFrame_LoadUI()
		end

		loadoutID = arg1

		_G.ClassTalentFrame.TalentsTab:LoadConfigByPredicate(loadout_callback)
	end
end

local function menu_checked(data) return data and data.arg1 == GetLootSpecialization() end
local function menu_func(_, arg1) SetLootSpecialization(arg1) end

local function spec_checked(data) return data and data.arg1 == GetSpecialization() end
local function spec_func(_, arg1) SetSpecialization(arg1) end

local function OnEvent(self, event, loadoutID)
	if #menuList == 2 then
		for index = 1, GetNumSpecializations() do
			local id, name, _, icon = GetSpecializationInfo(index)
			if id then
				menuList[index + 2] = { arg1 = id, text = name, checked = menu_checked, func = menu_func }
				specList[index + 1] = { arg1 = index, text = format(specText, icon, name), checked = spec_checked, func = spec_func }
			end
		end
	end

	local specIndex = GetSpecialization()
	local specialization = GetLootSpecialization()
	local info = DT.SPECIALIZATION_CACHE[specIndex]
	local ID = info and info.id

	if not ID then
		self.text:SetText(DEFAULT_TEXT)
		return
	end

	if (event == 'CONFIG_COMMIT_FAILED' or event == 'ELVUI_FORCE_UPDATE' or event == 'TRAIT_CONFIG_DELETED' or event == 'TRAIT_CONFIG_UPDATED') and CanUseClassTalents() then
		if not DT.ClassTalentsID then
			DT.ClassTalentsID = (GetHasStarterBuild() and GetStarterBuildActive() and STARTER_ID) or GetLastSelectedSavedConfigID(ID)
		end

		local builds = GetConfigIDsBySpecID(ID)
		if builds and GetHasStarterBuild() then
			tinsert(builds, STARTER_ID)
		end

		if event == 'TRAIT_CONFIG_DELETED'  then
			for index = #loadoutList, 2, -1 do -- reverse loop to remove the deleted config from the loadout list
				local loadout = loadoutList[index]
				if loadout and loadout.arg1 == loadoutID then
					tremove(loadoutList, index)
				end
			end
		end

		for index, configID in next, builds do
			if configID == STARTER_ID then
				loadoutList[index + 1] = { text = STARTER_TEXT, checked = starter_checked, func = loadout_func, arg1 = STARTER_ID }
			else
				local configInfo = C_Traits_GetConfigInfo(configID)
				loadoutList[index + 1] = { text = configInfo and configInfo.name or UNKNOWN, checked = loadout_checked, func = loadout_func, arg1 = configID }
			end
		end
	end

	local activeLoadout = DEFAULT_TEXT
	for index, loadout in next, loadoutList do
		if index > 1 and loadout.arg1 == DT.ClassTalentsID then
			activeLoadout = loadout.text
			break
		end
	end

	active = specIndex

	local db = E.global.datatexts.settings["Talent/Loot Specialization"]
	local spec, text = format(mainIcon, info.icon)
	if db.displayStyle == 'BOTH' or db.displayStyle == 'SPEC' then
		if specialization == 0 or ID == specialization then
			if db.iconOnly then
				text = format('%s', spec)
			else
				text = format('%s %s', spec, info.name)
			end
		else
			info = DT.SPECIALIZATION_CACHE[specialization]
			if db.iconOnly then
				text = format('%s %s', spec, format(mainIcon, info.icon))
			else
				text = format('%s: %s %s: %s', L["Spec"], spec, LOOT, format(mainIcon, info.icon))
			end
		end
	end

	if db.displayStyle == 'BOTH' or db.displayStyle == 'LOADOUT' then
		text = strjoin('', text and text..(db.iconOnly and ' ' or ' / ') or '', activeLoadout)
	end

	self.text:SetText(text)
end

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

	for index, loadout in next, loadoutList do
		if index > 1 then
			local text = loadout:checked() and activeString or inactiveString
			DT.tooltip:AddLine(strjoin(' - ', loadout.text, text), 1, 1, 1)
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

	local menu
	if button == 'LeftButton' then
		local frame = _G.ClassTalentFrame
		if not frame then
			LoadAddOn('Blizzard_ClassTalentUI')
			frame = _G.ClassTalentFrame
		end

		if IsShiftKeyDown() then
			if frame:IsShown() then
				HideUIPanel(frame)
			else
				ShowUIPanel(frame)
			end
		else
			menu = IsControlKeyDown() and loadoutList or specList
		end
	else
		local _, specName = GetSpecializationInfo(specIndex)
		if specName then
			menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

			menu = menuList
		end
	end

	if menu then
		E:SetEasyMenuAnchor(E.EasyMenu, self)
		EasyMenu(menu, E.EasyMenu, nil, nil, nil, 'MENU')
	end
end

DT:RegisterDatatext('Talent/Loot Specialization', nil, { 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_LOOT_SPEC_UPDATED', 'TRAIT_CONFIG_DELETED', 'TRAIT_CONFIG_UPDATED' }, OnEvent, nil, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
