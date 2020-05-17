local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, strjoin, pairs = format, strjoin, pairs
local GetInventoryItemDurability = GetInventoryItemDurability
local ToggleCharacter = ToggleCharacter
local DURABILITY = DURABILITY
local InCombatLockdown = InCombatLockdown

local displayString, lastPanel = ""
local tooltipString = "%d%%"
local totalDurability = 0
local invDurability = {}

local slots = {
	[1] = L["Head"],
	[3] = L["Shoulder"],
	[5] = L["Chest"],
	[6] = L["Waist"],
	[7] = L["Legs"],
	[8] = L["Feet"],
	[9] = L["Wrist"],
	[10] = L["Hands"],
	[16] = L["Main Hand"],
	[17] = L["Offhand"],
}

local function OnEvent(self)
	lastPanel = self
	totalDurability = 100

	for index, slotName in pairs(slots) do
		local current, max = GetInventoryItemDurability(index)

		if current then
			invDurability[index] = (current/max)*100

			if ((current/max) * 100) < totalDurability then
				totalDurability = (current/max) * 100
			end
		end
	end

	self.text:SetFormattedText(displayString, totalDurability)
end

local function Click()
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	ToggleCharacter("PaperDollFrame")
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for slot, durability in pairs(invDurability) do
		DT.tooltip:AddDoubleLine(slots[slot], format(tooltipString, durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", DURABILITY, ": ", hex, "%d%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Durability', nil, {"UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"}, OnEvent, nil, Click, OnEnter, nil, DURABILITY)
