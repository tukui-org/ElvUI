local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

local tooltip = CreateFrame('GameTooltip', "NPCTitleScanningTooltip", UIParent, 'GameTooltipTemplate')

function mod:UpdateElement_Name(frame)
	local name, realm = UnitName(frame.displayedUnit)
	if((not self.db.units[frame.UnitType].showName and frame.UnitType ~= "PLAYER") or not name) then return end
	if frame.UnitType == "PLAYER" and not self.db.units[frame.UnitType].showName then frame.Name:SetText() return end

	frame.Name:SetText(name)

	if(frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		local _, class = UnitClass(frame.displayedUnit)
		local color = RAID_CLASS_COLORS[class]
		if(class and color) then
			frame.Name:SetTextColor(color.r, color.g, color.b)
		end
	elseif(not self.db.units[frame.UnitType].healthbar.enable) then
		local reactionType = UnitReaction(frame.unit, "player")
		local r, g, b
		if(reactionType == 4) then
			r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
		elseif(reactionType > 4) then
			r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
		else
			r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
		end

		frame.Name:SetTextColor(r, g, b)

		--From KuiNameplates
		if frame.UnitType == "FRIENDLY_NPC" or frame.UnitType == "ENEMY_NPC" then
			tooltip:SetOwner(UIParent, "ANCHOR_NONE")
			tooltip:SetUnit(frame.displayedUnit)

			--Get "guild" text
			local guildText = NPCTitleScanningTooltipTextLeft2:GetText()
			tooltip:Hide()

			if not guildText or guildText:find("^Level ") then return end

			frame.NPCTitle:SetFormattedText("< %s >", guildText)
			frame.NPCTitle:SetTextColor(r, g, b)
		end
	else
		frame.Name:SetTextColor(1, 1, 1)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name
	local title = frame.NPCTitle

	name:SetJustifyH("LEFT")
	name:SetJustifyV("BOTTOM")
	name:ClearAllPoints()
	title:SetJustifyH("CENTER")
	title:SetJustifyV("TOP")
	title:ClearAllPoints()
	if(self.db.units[frame.UnitType].healthbar.enable or frame.isTarget) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2)
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	else
		name:SetJustifyH("CENTER")
		name:SetPoint("TOP", frame, "CENTER")
		title:SetPoint("TOP", name, "BOTTOM", 0, -2)
	end

	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	title:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetWordWrap(false)

	return name
end

function mod:ConstructElement_NPCTitle(frame)
	local title = frame:CreateFontString(nil, "OVERLAY")
	title:SetWordWrap(false)

	return title
end