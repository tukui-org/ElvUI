local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local tonumber, select, pcall = tonumber, select, pcall
local format, gsub, strmatch, strfind = string.format, string.gsub, string.match, string.find
--WoW API / Variables
local BreakUpLargeNumbers = BreakUpLargeNumbers
local C_ArtifactUI_GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetItemSpell = GetItemSpell
local GetSpellInfo = GetSpellInfo
local HasArtifactEquipped = HasArtifactEquipped
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local ShowUIPanel = ShowUIPanel
local SocketInventoryItem = SocketInventoryItem
local ARTIFACT_POWER = ARTIFACT_POWER
local ARTIFACT_POWER_TOOLTIP_BODY = ARTIFACT_POWER_TOOLTIP_BODY

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, CreateFrame, ArtifactFrame, UIParent

function mod:UpdateArtifact(event, unit)
	if not mod.db.artifact.enable then return end
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		--We only need to scan bags once on this event, not on every load screen
		self.artifactBar.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	local bar = self.artifactBar
	local showArtifact = HasArtifactEquipped();
	if not showArtifact or (event == "PLAYER_REGEN_DISABLED" and self.db.artifact.hideInCombat) then
		bar:Hide()
	elseif showArtifact and (not self.db.artifact.hideInCombat or not InCombatLockdown()) then
		bar:Show()

		if self.db.artifact.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo();
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier);

		bar.statusBar:SetMinMaxValues(0, xpForNextPoint)
		bar.statusBar:SetValue(xp)

		local BagValue = self:GetArtifactPowerInBags()
		if(BagValue and BagValue > 0) then
			self.artifactBar.bagValue:SetMinMaxValues(0, xpForNextPoint)
			self.artifactBar.bagValue:SetValue(xp + BagValue)
		else
			self.artifactBar.bagValue:SetMinMaxValues(0, 1)
			self.artifactBar.bagValue:SetValue(0)
		end

		local textFormat = self.db.artifact.textFormat
		if textFormat == 'PERCENT' then
			text = format('%d%%', xp / xpForNextPoint * 100)
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %d%%', E:ShortValue(xp), xp / xpForNextPoint * 100)
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(totalXP))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(xpForNextPoint - xp))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint - xp))
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %d%% (%s)', E:ShortValue(xp), xp / xpForNextPoint * 100, E:ShortValue(xpForNextPoint - xp))
		end

		bar.text:SetText(text)
	end
end

function mod:ArtifactBar_OnEnter()
	if mod.db.artifact.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	GameTooltip:AddLine(ARTIFACT_POWER)
	GameTooltip:AddLine(' ')

	local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo();
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier);

	local remaining = xpForNextPoint - xp
	local apInBags = self.BagArtifactPower

	GameTooltip:AddDoubleLine(L["XP:"], format(' %s / %s (%d%%)', BreakUpLargeNumbers(xp), BreakUpLargeNumbers(xpForNextPoint), xp/xpForNextPoint * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %s (%d%% - %d %s)', BreakUpLargeNumbers(xpForNextPoint - xp), remaining / xpForNextPoint * 100, 20 * remaining / xpForNextPoint, L["Bars"]), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["In Bags:"], format(' %s (%d%% - %d %s)', BreakUpLargeNumbers(apInBags), apInBags / xpForNextPoint * 100, 20 * apInBags / xpForNextPoint, L["Bars"]), 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(format(ARTIFACT_POWER_TOOLTIP_BODY, numPointsAvailableToSpend), nil, nil, nil, true)

	GameTooltip:Show()
end

function mod:ArtifactBar_OnClick()
	if not ArtifactFrame or not ArtifactFrame:IsShown() then
		ShowUIPanel(SocketInventoryItem(16))
	elseif ArtifactFrame and ArtifactFrame:IsShown() then
		HideUIPanel(ArtifactFrame)
	end
end

function mod:UpdateArtifactDimensions()
	self.artifactBar:Width(self.db.artifact.width)
	self.artifactBar:Height(self.db.artifact.height)
	self.artifactBar.statusBar:SetOrientation(self.db.artifact.orientation)
	self.artifactBar.statusBar:SetReverseFill(self.db.artifact.reverseFill)
	self.artifactBar.bagValue:SetOrientation(self.db.artifact.orientation)
	self.artifactBar.bagValue:SetReverseFill(self.db.artifact.reverseFill)

	self.artifactBar.text:FontTemplate(LSM:Fetch("font", self.db.artifact.font), self.db.artifact.textSize, self.db.artifact.fontOutline)
	if self.db.artifact.mouseover then
		self.artifactBar:SetAlpha(0)
	else
		self.artifactBar:SetAlpha(1)
	end
end

function mod:EnableDisable_ArtifactBar()
	if self.db.artifact.enable then
		self:RegisterEvent('ARTIFACT_XP_UPDATE', 'UpdateArtifact')
		self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateArtifact')
		self:RegisterEvent("BAG_UPDATE_DELAYED", 'UpdateArtifact')

		self:UpdateArtifact()
		E:EnableMover(self.artifactBar.mover:GetName())
	else
		self:UnregisterEvent('ARTIFACT_XP_UPDATE')
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		self:UnregisterEvent("BAG_UPDATE_DELAYED")

		self.artifactBar:Hide()
		E:DisableMover(self.artifactBar.mover:GetName())
	end
end

local apStringValueMillion = {
	["enUS"] = "(%d*[%p%s]?%d+) million",
	["enGB"] = "(%d*[%p%s]?%d+) million",
	["ptBR"] = "(%d*[%p%s]?%d+) [[milhão][milhões]]?",
	["esMX"] = "(%d*[%p%s]?%d+) [[millón][millones]]?",
	["deDE"] = "(%d*[%p%s]?%d+) [[Million][Millionen]]?",
	["esES"] = "(%d*[%p%s]?%d+) [[millón][millones]]?",
	["frFR"] = "(%d*[%p%s]?%d+) [[million][millions]]?",
	["itIT"] = "(%d*[%p%s]?%d+) [[milione][milioni]]?",
	["ruRU"] = "(%d*[%p%s]?%d+) млн",
	["koKR"] = "(%d*[%p%s]?%d+)만",
	["zhTW"] = "(%d*[%p%s]?%d+)萬",
	["zhCN"] = "(%d*[%p%s]?%d+) 万",
}
local apValueMultiplier = {
	["koKR"] = 1e4,
	["zhTW"] = 1e4,
	["zhCN"] = 1e4,
}

local apStringValueMillionLocal = apStringValueMillion[GetLocale()]
local apValueMultiplierLocal = (apValueMultiplier[GetLocale()] or 1e6) --Fallback to 1e6 which is used by all non-asian clients
local empoweringSpellName

--AP item caches
local apValueCache = {}
local apItemCache = {}

--This function scans the tooltip of an item to determine whether or not it grants AP.
--If it is found to grant AP, then the value is extracted and returned.
local apLineIndex
local function GetAPFromTooltip(itemLink)
	local apValue = 0

	local itemSpell = GetItemSpell(itemLink)
	if itemSpell and itemSpell == empoweringSpellName then
		--Clear tooltip from previous item
		mod.artifactBar.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		--We need to use SetHyperlink, as SetItemByID doesn't work for items you looted before
		-- gaining Artifact Knowledge level. For those items it would display a value higher
		-- than what you would actually get.
		mod.artifactBar.tooltip:SetHyperlink(itemLink)

		local apFound
		for i = #mod.artifactBar.tooltipLines, 1, -1 do
			local tooltipText = mod.artifactBar.tooltipLines[i]:GetText()

			if (tooltipText) then
				local digit1, digit2, digit3, ap
				local value = strmatch(tooltipText, apStringValueMillionLocal)

				if (value) then
					digit1, digit2 = strmatch(value, "(%d+)[%p%s](%d+)")
					if (digit1 and digit2) then
						ap = tonumber(format("%s.%s", digit1, digit2)) * apValueMultiplierLocal --Multiply by 1 million (or 10.000 for asian clients)
					else
						ap = tonumber(value) * apValueMultiplierLocal --Multiply by 1 million (or 10.000 for asian clients)
					end 
				else
					digit1, digit2, digit3 = strmatch(tooltipText,"(%d+)[%p%s]?(%d+)[%p%s]?(%d+)")
					ap = tonumber(format("%s%s%s", digit1 or "", digit2 or "", (digit2 and digit3) and digit3 or ""))
				end

				if (ap) then
					apValue = ap
					apFound = true
					break
				end
			end
		end

		if (not apFound) then
			apItemCache[itemLink] = false --Cache item as not granting AP
		end
	else
		apItemCache[itemLink] = false --Cache item as not granting AP
	end

	return apValue
end

--This can be used to test if the tooltip scanning works as expected
--/run ElvUI[1].DataBars:TestAPExtraction(147203)
--/run ElvUI[1].DataBars:TestAPExtraction(140307)
function mod:TestAPExtraction(itemID)
	local itemLink = select(2, GetItemInfo(itemID))
	if not itemLink then --WoW client hasn't seen this item before, so run again a little later when info has been received
		C_Timer.After(2, function() mod:TestAPExtraction(itemID) end)
		return
	end

	local apValue = GetAPFromTooltip(itemLink)
	E:Print("AP value from", itemLink, "is:", apValue, "("..BreakUpLargeNumbers(apValue, true)..")")
end

--This function is responsible for retrieving the AP value from an itemLink.
--It will cache the itemLink and respective AP value for future requests, thus saving CPU resources.
local function GetAPForItem(itemLink)
	if (apItemCache[itemLink] == false) then
		--Get out early if item has already been determined to not grant AP
		return 0
	end

	--Check if item is cached and return value
	if apValueCache[itemLink] then
		return apValueCache[itemLink]
	else
		--Not cached, do a tooltip scan and cache the value
		local apValue = GetAPFromTooltip(itemLink)
		if apValue > 0 then
			apValueCache[itemLink] = apValue
		end
		return apValue
	end
end

function mod:GetArtifactPowerInBags()
	if InCombatLockdown() then
		return self.artifactBar.LastKnownAP
	end

	self.artifactBar.BagArtifactPower = 0
	local ID, link, AP
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			ID = select(10, GetContainerItemInfo(bag, slot))
			link = GetContainerItemLink(bag, slot)

			if (ID and link) then
				AP = GetAPForItem(link)
				self.artifactBar.BagArtifactPower = self.artifactBar.BagArtifactPower + AP
			end
		end
	end

	if(not self.artifactBar.LastKnownAP) or (self.artifactBar.LastKnownAP ~= self.artifactBar.BagArtifactPower) then
		self.artifactBar.LastKnownAP = self.artifactBar.BagArtifactPower
	end

	return self.artifactBar.BagArtifactPower
end

function mod:LoadArtifactBar()
	empoweringSpellName = GetSpellInfo(227907)

	self.artifactBar = self:CreateBar('ElvUI_ArtifactBar', self.ArtifactBar_OnEnter, self.ArtifactBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.artifactBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.artifactBar.statusBar:SetMinMaxValues(0, 325)
	self.artifactBar.statusBar:SetFrameLevel(self.artifactBar:GetFrameLevel() + 2)

	self.artifactBar.eventFrame = CreateFrame("Frame")
	self.artifactBar.eventFrame:Hide()
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.artifactBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateArtifact(event) end)

	self.artifactBar.bagValue = CreateFrame("StatusBar", nil, self.artifactBar)
	self.artifactBar.bagValue:SetAllPoints(self.artifactBar.statusBar)
	self.artifactBar.bagValue:SetStatusBarTexture(E['media'].normTex)
	self.artifactBar.bagValue:SetStatusBarColor(0, 0.43, 0.95)
	self.artifactBar.bagValue:SetFrameStrata("LOW")
	self.artifactBar.bagValue:SetMinMaxValues(0, 1)
	self.artifactBar.bagValue:SetValue(0)
	self.artifactBar.bagValue:SetFrameLevel(self.artifactBar:GetFrameLevel() + 1)
	self.artifactBar.BagArtifactPower = 0

	self.artifactBar.tooltip = CreateFrame("GameTooltip", "BagArtifactPowerTooltip", UIParent, "GameTooltipTemplate")
	self.artifactBar.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	self.artifactBar.tooltipLines = {}
	for i = 1, 5 do
		self.artifactBar.tooltipLines[i] = _G[format("BagArtifactPowerTooltipTextLeft%d", i)]
	end

	self:UpdateArtifactDimensions()
	E:CreateMover(self.artifactBar, "ArtifactBarMover", L["Artifact Bar"])
	self:EnableDisable_ArtifactBar()
end