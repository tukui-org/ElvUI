local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')

local format = string.format
local lastPanel, active
local displayString = '';
local talent = {}
local activeString = string.join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = string.join("", "|cffFF0000", FACTION_INACTIVE, "|r")

local function OnEvent(self, event)
	lastPanel = self
	if not GetSpecializationInfo(1) then
		return
	end	
	
	active = GetActiveSpecGroup()
	if GetSpecialization(false, false, active) then
		self.text:SetText(select(2, GetSpecializationInfo(GetSpecialization(false, false, active))))
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1, GetNumSpecGroups() do
		if GetSpecialization(false, false, i) then
			GameTooltip:AddLine(string.join(" ", string.format(displayString, select(2, GetSpecializationInfo(GetSpecialization(false, false, i)))), (i == active and activeString or inactiveString)),1,1,1)
		end
	end
	
	GameTooltip:Show()
end

local function OnClick(self)
	SetActiveSpecGroup(active == 1 and 2 or 1)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "|cffFFFFFF%s:|r ")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Spec Switch',{"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED"}, OnEvent, nil, OnClick, OnEnter)
