local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local UNKNOWN = UNKNOWN
local UnitClass = UnitClass
local UnitName = UnitName
local UnitReaction = UnitReaction
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent, CUSTOM_CLASS_COLORS

function mod:UpdateElement_Name(frame, triggered)
	local name = frame.displayedUnit and UnitName(frame.displayedUnit)

	if not triggered then
		if (not self.db.units[frame.UnitType].showName and frame.UnitType ~= "PLAYER") or not name then
			return
		end

		if frame.UnitType and (frame.UnitType == "PLAYER") and not self.db.units[frame.UnitType].showName then
			frame.Name:SetText()
			return
		end
	end

	frame.Name:SetText(name or UNKNOWN)

	local r, g, b = 1, 1, 1
	local useClassColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useClassColor
	if frame.displayedUnit and frame.UnitType and useClassColor and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "HEALER" or frame.UnitType == "PLAYER") then
		local _, class = UnitClass(frame.displayedUnit)
		local color = class and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
		if color then
			r, g, b = color.r, color.g, color.b
		end
	elseif frame.displayedUnit and (triggered or (not self.db.units[frame.UnitType].healthbar.enable and not frame.isTarget)) then
		local reactionType = UnitReaction(frame.displayedUnit, "player")
		if reactionType then
			if reactionType == 4 then
				r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
			elseif reactionType > 4 then
				r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
			else
				r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
			end
		end
	end

	-- if for some reason the values failed just default to white
	if not (r and g and b) then
		r, g, b = 1, 1, 1
	end

	if triggered or (r ~= frame.Name.r or g ~= frame.Name.g or b ~= frame.Name.b) then
		frame.Name:SetTextColor(r, g, b)
		if not triggered then
			frame.Name.r, frame.Name.g, frame.Name.b = r, g, b
		end
	end

	if self.db.nameColoredGlow then
		frame.Name.NameOnlyGlow:SetVertexColor(r - 0.1, g - 0.1, b - 0.1, 1)
	else
		frame.Name.NameOnlyGlow:SetVertexColor(self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name

	name:SetJustifyH("LEFT")
	name:SetJustifyV("BOTTOM")
	name:ClearAllPoints()
	if self.db.units[frame.UnitType].healthbar.enable or (self.db.alwaysShowTargetHealth and frame.isTarget) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2)
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	else
		name:SetJustifyH("CENTER")
		name:SetPoint("TOP", frame, "CENTER")
	end

	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetWordWrap(false)

	local g = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	g:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])
	g:Hide()
	g:SetPoint("TOPLEFT", name, -20, 8)
	g:SetPoint("BOTTOMRIGHT", name, 20, -8)

	name.NameOnlyGlow = g

	return name
end
