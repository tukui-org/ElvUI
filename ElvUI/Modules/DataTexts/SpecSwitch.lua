local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local format, next, wipe, strjoin = format, next, wipe, strjoin
--WoW API / Variables
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecializations = GetNumSpecializations
local GetPvpTalentInfoByID = GetPvpTalentInfoByID
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetTalentInfo = GetTalentInfo
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local SetLootSpecialization = SetLootSpecialization
local SetSpecialization = SetSpecialization
local ShowUIPanel = ShowUIPanel
local LOOT = LOOT
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local TALENTS = TALENTS
local PVP_TALENTS = PVP_TALENTS

local displayString, lastPanel, active = ''
local activeString = strjoin("", "|cff00FF00" , _G.ACTIVE_PETS, "|r")
local inactiveString = strjoin("", "|cffFF0000", _G.FACTION_INACTIVE, "|r")
local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() SetLootSpecialization(0) end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}
local specList = {
	{ text = _G.SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local function OnEvent(self)
	lastPanel = self

	local specIndex = GetSpecialization()
	if not specIndex then
		self.text:SetText('N/A')
		return
	end

	active = specIndex

	local spec, loot, text = '', 'N/A', LOOT
	local specialization = GetLootSpecialization()

	local _, _, _, specTex = GetSpecializationInfo(specIndex)
	if specTex then
		spec = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', specTex)
	end

	if specialization == 0 then
		loot, text = spec, '|cFF54FF00'..text..'|r'
	else
		local _, _, _, texture = GetSpecializationInfoByID(specialization)
		if texture then
			loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
		end
	end

	self.text:SetFormattedText('%s: %s %s: %s', L["Spec"], spec, text, loot)
end

local function AddTexture(texture)
	texture = texture and '|T'..texture..':16:16:0:0:50:50:4:46:4:46|t' or ''
	return texture
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1, GetNumSpecializations() do
		local _, name, _, icon = GetSpecializationInfo(i)
		if name then
			DT.tooltip:AddLine(strjoin(" ", format(displayString, name), AddTexture(icon), (i == active and activeString or inactiveString)), 1, 1, 1)
		end
	end

	DT.tooltip:AddLine(' ')

	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization()
		if specIndex then
			local _, name = GetSpecializationInfo(specIndex)
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
		end
	else
		local specID, name = GetSpecializationInfoByID(specialization)
		if specID then
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(TALENTS, 0.69, 0.31, 0.31)

	for i = 1, _G.MAX_TALENT_TIERS do
		for j = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(i, j, 1)
			if selected then
				DT.tooltip:AddLine(AddTexture(icon)..' '..name)
			end
		end
	end

	if E.mylevel >= _G.SHOW_PVP_TALENT_LEVEL then
		local pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()

		if #pvpTalents > 0 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddLine(PVP_TALENTS, 0.69, 0.31, 0.31)
			for _, talentID in next, pvpTalents do
				local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
				if name and unlocked then
					DT.tooltip:AddLine(AddTexture(icon)..' '..name)
				end
			end
		end

		wipe(pvpTalents)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])

	DT.tooltip:Show()
end

local function OnClick(self, button)
	local specIndex = GetSpecialization()
	if not specIndex then return end

	if button == "LeftButton" then
		DT.tooltip:Hide()
		if not _G.PlayerTalentFrame then
			_G.LoadAddOn("Blizzard_TalentUI")
		end
		if IsShiftKeyDown() then
			if not _G.PlayerTalentFrame:IsShown() then
				ShowUIPanel(_G.PlayerTalentFrame)
			else
				HideUIPanel(_G.PlayerTalentFrame)
			end
		else
			for index = 1, 4 do
				local id, name, _, texture = GetSpecializationInfo(index)
				if ( id ) then
					specList[index + 1].text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
					specList[index + 1].func = function() SetSpecialization(index) end
				else
					specList[index + 1] = nil
				end
			end
			_G.EasyMenu(specList, menuFrame, "cursor", -15, -7, "MENU", 2)
		end
	else
		DT.tooltip:Hide()
		local _, specName = GetSpecializationInfo(specIndex)
		menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

		for index = 1, 4 do
			local id, name = GetSpecializationInfo(index)
			if ( id ) then
				menuList[index + 2].text = name
				menuList[index + 2].func = function() SetLootSpecialization(id) end
			else
				menuList[index + 2] = nil
			end
		end

		_G.EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
	end
end

local function ValueColorUpdate()
	displayString = strjoin("", "|cffFFFFFF%s:|r ")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Talent/Loot Specialization',{"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED", 'PLAYER_LOOT_SPEC_UPDATED'}, OnEvent, nil, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
