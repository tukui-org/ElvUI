local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs = ipairs
local format, strjoin = format, strjoin

local IsShiftKeyDown = IsShiftKeyDown
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecializations = GetNumSpecializations
local SetLootSpecialization = SetLootSpecialization
local SetActiveSpecGroup = C_SpecializationInfo.SetActiveSpecGroup
local GetActiveSpecGroup = C_SpecializationInfo.GetActiveSpecGroup
local GetSpecialization = C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

local LOOT = LOOT
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT

local displayString = '|cffFFFFFF%s:|r'
local activeString = strjoin('', '|cff00FF00' , _G.ACTIVE_PETS, '|r')
local inactiveString = strjoin('', '|cffFF0000', _G.FACTION_INACTIVE, '|r')

local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) DT:CloseMenus() end },
}

local specList = { { text = _G.SPECIALIZATION, isTitle = true, notCheckable = true } }

local DEFAULT_TEXT = L["No Specialization"]

local mainSize = 16
local mainIcon = '|T%s:%d:%d:0:0:64:64:4:60:4:60|t'
local listIcon = '|T%s:16:16:0:0:50:50:4:46:4:46|t'
local listText = '|T%s:14:14:0:0:64:64:4:60:4:60|t  %s'

local function MenuChecked(data) return data and data.arg1 == GetLootSpecialization() end
local function MenuFunc(_, arg1) SetLootSpecialization(arg1) DT:CloseMenus() end

local function SpecChecked(data) return data and data.arg1 == GetActiveSpecGroup() end
local function SpecFunc(_, arg1) SetActiveSpecGroup(arg1) DT:CloseMenus() end

local function OnEvent(self)
	self.timeSinceUpdate = 0

	if #menuList == 2 then
		for index = 1, GetNumSpecializations() do
			local id, name = GetSpecializationInfo(index)
			if id then
				menuList[index + 2] = { arg1 = id, text = name, checked = MenuChecked, func = MenuFunc }
			end
		end

		for index = 1, 2 do
			local specGroup = GetSpecialization(nil, nil, index)
			local _, name, _, icon = GetSpecializationInfo(specGroup)
			if icon then
				specList[index + 1] = { arg1 = index, text = format(listText, icon, name ~= '' and name or DEFAULT_TEXT), checked = SpecChecked, func = SpecFunc }
			end
		end
	end

	local specIndex = GetSpecialization()
	local info = DT.SPECIALIZATION_CACHE[specIndex]
	local ID = info and info.id

	if not ID then
		self.text:SetText(DEFAULT_TEXT)
		return
	end

	local db = E.global.datatexts.settings["Talent/Loot Specialization"]
	local size = db.iconSize or mainSize
	local spec = format(mainIcon, info.icon, size, size)

	local text
	local specLoot = GetLootSpecialization()
	if (specLoot == 0 or ID == specLoot) and not db.showBoth then
		if db.iconOnly then
			text = format('%s', spec)
		else
			text = format('%s %s', spec, info.name)
		end
	else
		local cache = DT.SPECIALIZATION_CACHE[(specLoot == 0 and specIndex) or specLoot]
		if db.iconOnly then
			text = format('%s %s', spec, format(mainIcon, cache.icon, size, size))
		else
			text = format('%s: %s %s: %s', L["Spec"], spec, LOOT, format(mainIcon, cache.icon, size, size))
		end
	end

	self.text:SetText(text)
end

local function OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 1 then
		OnEvent(self)
	end
end

local function AddTexture(texture)
	return texture and format(listIcon, texture) or ''
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local currentSpec = GetSpecialization()
	for i, info in ipairs(DT.SPECIALIZATION_CACHE) do
		DT.tooltip:AddLine(strjoin(' ', format(displayString, info.name), AddTexture(info.icon), i == currentSpec and activeString or inactiveString), 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')

	local specLoot = GetLootSpecialization()
	local sameSpec = specLoot == 0 and currentSpec
	local specIndex = DT.SPECIALIZATION_CACHE[sameSpec or specLoot]

	local specName = (specIndex and specIndex.name ~= '' and specIndex.name) or DEFAULT_TEXT
	DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, sameSpec and format(LOOT_SPECIALIZATION_DEFAULT, specName) or specName))

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])
	DT.tooltip:Show()
end

local function OnClick(self, button)
	local specIndex = GetSpecialization()
	if not specIndex then return end

	local menu
	if button == 'LeftButton' then
		if IsShiftKeyDown() then
			if not E:AlertCombat() then
				_G.ToggleTalentFrame()
			end
		else
			menu = specList
		end
	else
		local _, specName = GetSpecializationInfo(specIndex)
		if specName then
			menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName ~= '' and specName or DEFAULT_TEXT)

			menu = menuList
		end
	end

	if menu then
		E:SetEasyMenuAnchor(E.EasyMenu, self)
		E:ComplicatedMenu(menu, E.EasyMenu, nil, nil, nil, 'MENU')
	end
end

DT:RegisterDatatext('Talent/Loot Specialization', nil, { 'PLAYER_SPECIALIZATION_CHANGED', 'PLAYER_TALENT_UPDATE', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_LOOT_SPEC_UPDATED', 'TRAIT_CONFIG_DELETED', 'TRAIT_CONFIG_UPDATED', 'CHAT_MSG_SYSTEM' }, OnEvent, OnUpdate, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
