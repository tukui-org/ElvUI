local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local ipairs = ipairs
local format = format
local strjoin = strjoin

local C_EquipmentSet_GetEquipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs
local C_EquipmentSet_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local C_EquipmentSet_UseEquipmentSet = C_EquipmentSet.UseEquipmentSet

local sets = {}
local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine('Equipment Sets')

	for i, set in ipairs(sets) do
		if i == 1 then
			DT.tooltip:AddLine(' ')
		end

		DT.tooltip:AddLine(set.text, set.isEquipped and .2 or 1, set.isEquipped and 1 or .2, .2)
	end

	DT.tooltip:Show()
end

local function OnClick(self)
	E:SetEasyMenuAnchor(E.EasyMenu, self)
	E:ComplicatedMenu(sets, E.EasyMenu, nil, nil, nil, 'MENU')
end

local function OnEvent(self)
	local activeIndex
	local all = C_EquipmentSet_GetEquipmentSetIDs()
	for i, setID in ipairs(all) do
		local set = sets[i]
		if not set then
			set = {
				checked = function(list) return list.isEquipped end,
				func = function(_, arg1) C_EquipmentSet_UseEquipmentSet(arg1) DT:CloseMenus() end
			}

			sets[i] = set
		end

		local name, iconFileID, _, isEquipped = C_EquipmentSet_GetEquipmentSetInfo(setID)
		if isEquipped then
			activeIndex = i
		end

		set.name = name
		set.arg1 = setID
		set.iconFileID = iconFileID
		set.isEquipped = isEquipped
		set.text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', iconFileID, name)
	end

	for i = #all + 1, #sets do
		sets[i] = nil
	end

	local set = sets[activeIndex]
	if not activeIndex then
		self.text:SetText('No Set Equipped')
	elseif set then
		if db.NoLabel then
			self.text:SetFormattedText(displayString, '', set.name, not db.NoIcon and set.iconFileID or '')
		else
			self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or 'Set: ', set.name, not db.NoIcon and set.iconFileID or '')
		end
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', '%s', hex, '%s|r', not db.NoIcon and ' |T%s:16:16:0:0:64:64:4:60:4:60|t' or '')
end

DT:RegisterDatatext('Equipment Sets', nil, { 'PLAYER_EQUIPMENT_CHANGED', 'EQUIPMENT_SETS_CHANGED', 'EQUIPMENT_SWAP_FINISHED' }, OnEvent, nil, OnClick, OnEnter, nil, nil, nil, ApplySettings)
