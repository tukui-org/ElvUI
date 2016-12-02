local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');

--Cache global variables
--Lua functions
local _G = _G
local tonumber, select = tonumber, select
local format, gsub, strmatch, strfind = string.format, string.gsub, string.match, string.find
--WoW API / Variables
local C_ArtifactUIGetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local HasArtifactEquipped = HasArtifactEquipped
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local ShowUIPanel = ShowUIPanel
local SocketInventoryItem = SocketInventoryItem
local AP_NAME = format("|cFFE6CC80%s|r", ARTIFACT_POWER)
local ARTIFACT_POWER = ARTIFACT_POWER
local ARTIFACT_POWER_TOOLTIP_BODY = ARTIFACT_POWER_TOOLTIP_BODY

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, CreateFrame, ArtifactFrame, UIParent
-- GLOBALS: BagArtifactPowerTooltipTextLeft2, BagArtifactPowerTooltipTextLeft4

function mod:GetArtifactPowerInBags()
	if InCombatLockdown() then
		return self.artifactBar.LastKnownAP
	end

	self.artifactBar.BagArtifactPower = 0
	local ID
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			ID = select(10, GetContainerItemInfo(bag, slot))

			if(ID) then
				self.artifactBar.tooltip:SetItemByID(ID)
			end
		end
	end

	if(not self.artifactBar.LastKnownAP) or (self.artifactBar.LastKnownAP ~= self.artifactBar.BagArtifactPower) then
		self.artifactBar.LastKnownAP = self.artifactBar.BagArtifactPower
	end

	return self.artifactBar.BagArtifactPower
end

function mod:UpdateArtifact(event, unit)
	if not mod.db.artifact.enable then return end
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
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
		local _, _, _, _, totalXP, pointsSpent = C_ArtifactUIGetEquippedArtifactInfo();
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP);
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

	local _, _, _, _, totalXP, pointsSpent = C_ArtifactUIGetEquippedArtifactInfo();
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP);
	local remaining = xpForNextPoint - xp
	local apInBags = self.BagArtifactPower

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', xp, xpForNextPoint, xp/xpForNextPoint * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d %s)', xpForNextPoint - xp, remaining / xpForNextPoint * 100, 20 * remaining / xpForNextPoint, L["Bars"]), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["In Bags:"], format(' %d (%d%% - %d %s)', apInBags, apInBags / xpForNextPoint * 100, 20 * apInBags / xpForNextPoint, L["Bars"]), 1, 1, 1)
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

	self.artifactBar.text:FontTemplate(nil, self.db.artifact.textSize)
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
		self:RegisterEvent("CHAT_MSG_LOOT", 'UpdateArtifact')
		self:RegisterEvent("PLAYER_ENTERING_WORLD", 'UpdateArtifact')

		self:UpdateArtifact()
		E:EnableMover(self.artifactBar.mover:GetName())
	else
		self:UnregisterEvent('ARTIFACT_XP_UPDATE')
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		self:UnregisterEvent("CHAT_MSG_LOOT")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		self.artifactBar:Hide()
		E:DisableMover(self.artifactBar.mover:GetName())
	end
end

local function OnTooltipSetItem(self)
	if (mod.artifactBar.line2:GetText() == AP_NAME) then
		if strfind(mod.artifactBar.line4:GetText(), "(%d+),(%d+)") then
			local Num = gsub(strmatch(mod.artifactBar.line4:GetText(), "(%d+,%d+)"), ",", "")

			mod.artifactBar.BagArtifactPower = mod.artifactBar.BagArtifactPower + tonumber(Num)
		elseif strfind(mod.artifactBar.line4:GetText(), "%d+") then
			mod.artifactBar.BagArtifactPower = mod.artifactBar.BagArtifactPower + tonumber(strmatch(mod.artifactBar.line4:GetText(), "%d+"))
		end
	end
end

function mod:LoadArtifactBar()
	self.artifactBar = self:CreateBar('ElvUI_ArtifactBar', self.ArtifactBar_OnEnter, self.ArtifactBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.artifactBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.artifactBar.statusBar:SetMinMaxValues(0, 325)
	self.artifactBar.statusBar:SetFrameLevel(self.artifactBar:GetFrameLevel() + 2)

	self.artifactBar.eventFrame = CreateFrame("Frame")
	self.artifactBar.eventFrame:Hide()
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
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
	self.artifactBar.line2 = BagArtifactPowerTooltipTextLeft2
	self.artifactBar.line4 = BagArtifactPowerTooltipTextLeft4
	self.artifactBar.tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

	self:UpdateArtifactDimensions()
	E:CreateMover(self.artifactBar, "ArtifactBarMover", L["Artifact Bar"])
	self:EnableDisable_ArtifactBar()
end