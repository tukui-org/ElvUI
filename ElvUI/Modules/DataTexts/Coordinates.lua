local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin
local InCombatLockdown = InCombatLockdown

local displayString = ''
local inRestrictedArea = false
local mapInfo = E.MapInfo

local function Update(self, elapsed)
	if inRestrictedArea or not mapInfo.coordsWatching then return end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		self.text:SetFormattedText(displayString, mapInfo.xText or 0, mapInfo.yText or 0)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	if mapInfo.x and mapInfo.y then
		inRestrictedArea = false
		self.text:SetFormattedText(displayString, mapInfo.xText or 0, mapInfo.yText or 0)
	else
		inRestrictedArea = true
		self.text:SetText('N/A')
	end
end

local function Click()
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
	_G.ToggleFrame(_G.WorldMapFrame)
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', hex, '%.2f|r', ' | ', hex, '%.2f|r')
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Coords', nil, {'LOADING_SCREEN_DISABLED', 'ZONE_CHANGED', 'ZONE_CHANGED_INDOORS', 'ZONE_CHANGED_NEW_AREA'}, OnEvent, Update, Click, nil, nil, L["Coords"], mapInfo, ValueColorUpdate)
