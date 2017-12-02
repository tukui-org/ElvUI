local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitAura = UnitAura

--Cache detection buff names
local DETECTION_BUFF = GetSpellInfo(203761) --Detector
local DETECTION_BUFF2 = GetSpellInfo(213486) --Demonic Vision

function mod:UpdateElement_Detection(frame)
	if not (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable) then
		return;
	end

	local name = UnitAura(frame.displayedUnit, DETECTION_BUFF) or UnitAura(frame.displayedUnit, DETECTION_BUFF2)
	if (name) then
		frame.DetectionModel:Show()
		frame.DetectionModel:SetModel("Spells\\Blackfuse_LaserTurret_GroundBurn_State_Base")
	end
end

function mod:ConfigureElement_Detection(frame)
	if not (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable) then
		return;
	end

	frame.DetectionModel:ClearAllPoints()
	frame.DetectionModel:Point("BOTTOM", frame.TopLevelFrame or frame.Name, "TOP", 0, 0)
end

function mod:ConstructElement_Detection(frame)
	local model = CreateFrame("PlayerModel", nil, frame)
	model:Size(75, 75)
	model:Point("BOTTOM", frame, "TOP", 0, 0)
	model:SetFrameStrata("LOW") --HealthBar is on BACKGROUND
	model:SetPosition(3, 0, 1.25) --Zoom in
	model:Hide()

	return model
end