local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

local CreateFrame = CreateFrame

function UF:Construct_Cutaway(frame)
	local cutaway = CreateFrame("Frame", nil, frame)

	local cutawayHealth = CreateFrame("StatusBar", nil, frame.Health)
	cutawayHealth:SetStatusBarTexture(E.media.blankTex)
	cutawayHealth:SetFrameLevel(10)
	cutawayHealth:SetPoint("TOPLEFT", frame.Health:GetStatusBarTexture(), "TOPRIGHT")
	cutawayHealth:SetPoint("BOTTOMLEFT", frame.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
	cutaway.Health = cutawayHealth

	if frame.Power then
		local cutawayPower = CreateFrame("StatusBar", nil, frame.Power)
		cutawayPower:SetStatusBarTexture(E.media.blankTex)
		cutawayPower:SetFrameLevel(frame.Power:GetFrameLevel())
		cutawayPower:SetPoint("TOPLEFT", frame.Power:GetStatusBarTexture(), "TOPRIGHT")
		cutawayPower:SetPoint("BOTTOMLEFT", frame.Power:GetStatusBarTexture(), "BOTTOMRIGHT")
		cutaway.Power = cutawayPower
	end

	return cutaway
end

local healthPoints = {
	[1] = {"TOPLEFT", "TOPRIGHT"},
	[2] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[3] = {"BOTTOMLEFT", "TOPLEFT"},
	[4] = {"BOTTOMRIGHT", "TOPRIGHT"}
}

function UF:Configure_Cutaway(frame)
	local db = frame.db and frame.db.cutaway
	local healthDB, powerDB = db and db.health, db and db.power
	local healthEnabled = healthDB and healthDB.enabled
	local powerEnabled = powerDB and powerDB.enabled
	if healthEnabled or powerEnabled then
		if not frame:IsElementEnabled("Cutaway") then
			frame:EnableElement("Cutaway")
		end

		if healthDB then
			local health = frame.Cutaway.Health
			health:SetReverseFill((healthDB.reverseFill and true) or false)

			local vert = healthDB.orientation and healthDB.orientation == "VERTICAL"
			local firstPoint, secondPoint = healthPoints[(vert and 3) or 1], healthPoints[(vert and 4) or 2]
			local sbTexture = frame.Health:GetStatusBarTexture()

			health:ClearAllPoints()
			health:SetPoint(firstPoint[1], sbTexture, firstPoint[2])
			health:SetPoint(secondPoint[1], sbTexture, secondPoint[2])

			--Party/Raid Frames allow to change statusbar orientation
			if healthDB.orientation then
				health:SetOrientation(healthDB.orientation)
			end

			health.enabled = healthEnabled
			health.lengthBeforeFade = healthDB.lengthBeforeFade
			health.fadeOutTime = healthDB.fadeOutTime
			frame.Health:PostUpdateColor(frame.unit)
		end

		local power = frame.Cutaway.Power
		if power and frame.USE_POWERBAR then
			power:SetReverseFill((powerDB.reverseFill and true) or false)
			power:SetFrameLevel(frame.Power:GetFrameLevel())

			power.enabled = powerEnabled
			power.lengthBeforeFade = powerDB.lengthBeforeFade
			power.fadeOutTime = powerDB.fadeOutTime
			frame.Power:PostUpdateColor()
		end
	elseif frame:IsElementEnabled("Cutaway") then
		frame:DisableElement("Cutaway")
	end
end
