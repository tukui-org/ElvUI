local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

local CreateFrame = CreateFrame

function UF:Construct_Cutaway(frame)
	local healthTexture = frame.Health:GetStatusBarTexture()
	local cutawayHealth = CreateFrame("StatusBar", nil, frame.Health.ClipFrame)
	cutawayHealth:SetStatusBarTexture(E.media.blankTex)
	cutawayHealth:SetFrameLevel(10)
	cutawayHealth:SetPoint("TOPLEFT", healthTexture, "TOPRIGHT")
	cutawayHealth:SetPoint("BOTTOMLEFT", healthTexture, "BOTTOMRIGHT")

	if frame.Power then
		local powerTexture = frame.Power:GetStatusBarTexture()
		local cutawayPower = CreateFrame("StatusBar", nil, frame.Power)
		cutawayPower:SetStatusBarTexture(E.media.blankTex)
		cutawayPower:SetFrameLevel(frame.Power:GetFrameLevel())
		cutawayPower:SetPoint("TOPLEFT", powerTexture, "TOPRIGHT")
		cutawayPower:SetPoint("BOTTOMLEFT", powerTexture, "BOTTOMRIGHT")
	end

	return {
		Health = cutawayHealth,
		Power = cutawayPower
	}
end

local healthPoints = {
	[1] = {"TOPLEFT", "TOPRIGHT"},
	[2] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[3] = {"BOTTOMLEFT", "TOPLEFT"},
	[4] = {"BOTTOMRIGHT", "TOPRIGHT"}
}

local DEFAULT_INDEX = 1
local VERT_INDEX = 3

function UF:Configure_Cutaway(frame)
	local db = frame.db and frame.db.cutaway
	local healthDB, powerDB = db and db.health, db and db.power
	local healthEnabled = healthDB and healthDB.enabled
	local powerEnabled = powerDB and powerDB.enabled
	if healthEnabled or powerEnabled then
		if not frame:IsElementEnabled("Cutaway") then
			frame:EnableElement("Cutaway")
		end

		frame.Cutaway:UpdateConfigurationValues(db)
		local health = frame.Cutaway.Health
		if health and healthEnabled then
			local unitHealthDB = frame.db.health
			health:SetReverseFill((unitHealthDB.reverseFill and true) or false)

			local vert = unitHealthDB.orientation and unitHealthDB.orientation == "VERTICAL"
			local pointIndex = vert and VERT_INDEX or DEFAULT_INDEX
			local firstPoint, secondPoint = healthPoints[pointIndex], healthPoints[pointIndex+1]
			local barTexture = frame.Health:GetStatusBarTexture()

			health:ClearAllPoints()
			health:SetPoint(firstPoint[1], barTexture, firstPoint[2])
			health:SetPoint(secondPoint[1], barTexture, secondPoint[2])

			--Party/Raid Frames allow to change statusbar orientation
			if unitHealthDB.orientation then
				health:SetOrientation(unitHealthDB.orientation)
			end

			frame.Health:PostUpdateColor(frame.unit)
		end

		local power = frame.Cutaway.Power
		local powerUsable = powerEnabled and frame.USE_POWERBAR
		if power and powerUsable then
			local unitPowerDB = frame.db.power
			power:SetReverseFill((unitPowerDB.reverseFill and true) or false)
			power:SetFrameLevel(frame.Power:GetFrameLevel())

			frame.Power:PostUpdateColor()
		end
	elseif frame:IsElementEnabled("Cutaway") then
		frame:DisableElement("Cutaway")
	end
end
