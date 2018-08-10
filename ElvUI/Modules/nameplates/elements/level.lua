local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local UnitLevel = UnitLevel

function mod:UpdateElement_Level(frame)
	if(not self.db.units[frame.UnitType].showLevel and frame.UnitType ~= "PLAYER") then return end
	if frame.UnitType == "PLAYER" and not self.db.units[frame.UnitType].showLevel then frame.Level:SetText() return end
	local level = UnitLevel(frame.displayedUnit)

	local r, g, b
	if(level == -1 or not level) then
		level = '??'
		r, g, b = 0.9, 0, 0
	else
		local color = GetCreatureDifficultyColor(level)
		r, g, b = color.r, color.g, color.b
	end

	if(self.db.units[frame.UnitType].healthbar.enable or frame.isTarget) then
		frame.Level:SetText(level)
	else
		frame.Level:SetFormattedText(" [%s]", level)
	end
	frame.Level:SetTextColor(r, g, b)
end

function mod:ConfigureElement_Level(frame)
	local level = frame.Level

	level:ClearAllPoints()

	if(self.db.units[frame.UnitType].healthbar.enable or (self.db.alwaysShowTargetHealth and frame.isTarget)) then
		level:SetJustifyH("RIGHT")
		level:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, E.Border*2)
	else
		level:SetPoint("LEFT", frame.Name, "RIGHT")
		level:SetJustifyH("LEFT")
	end
	level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end
