local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

function UF:Construct_Cutaway(frame)
	local cutaway = CreateFrame("Frame", nil, frame)

	local cutawayHealth = CreateFrame("StatusBar", nil, frame.Health)
	cutawayHealth:SetStatusBarTexture(E.media.blankTex)
	cutawayHealth:SetFrameLevel(10)
	cutawayHealth:SetPoint("TOPLEFT", frame.Health:GetStatusBarTexture(), "TOPRIGHT")
	cutawayHealth:SetPoint("BOTTOMLEFT", frame.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
	local cutawayPower
	if frame.Power then
		cutawayPower = CreateFrame("StatusBar", nil, frame.Power)
		cutawayPower:SetStatusBarTexture(E.media.blankTex)
		cutawayPower:SetFrameLevel(frame.Power:GetFrameLevel())
		cutawayPower:SetPoint("TOPLEFT", frame.Power:GetStatusBarTexture(), "TOPRIGHT")
		cutawayPower:SetPoint("BOTTOMLEFT", frame.Power:GetStatusBarTexture(), "BOTTOMRIGHT")
	end

	cutaway.Health = cutawayHealth
	cutaway.Power = cutawayPower

	return cutaway
end

function UF:Configure_Cutaway(frame)
	if not frame.VARIABLES_SET then
		return
	end
	local db = frame.db

	local health = frame.Cutaway.Health
	local power = frame.Cutaway.Power

	if db.health then
		if db.health.reverseFill then
			health:SetReverseFill(true)
		else
			health:SetReverseFill(false)
		end

		local firstPoint = {"TOPLEFT", "TOPRIGHT"}
		local secondPoint = {"BOTTOMLEFT", "BOTTOMRIGHT"}
		if db.health.orientation and db.health.orientation == "VERTICAL" then
			firstPoint = {"BOTTOMLEFT", "TOPLEFT"}
			secondPoint = {"BOTTOMRIGHT", "TOPRIGHT"}
		end
		health:ClearAllPoints()
		health:SetPoint(firstPoint[1], frame.Health:GetStatusBarTexture(), firstPoint[2])
		health:SetPoint(secondPoint[1], frame.Health:GetStatusBarTexture(), secondPoint[2])
		--Party/Raid Frames allow to change statusbar orientation
		if db.health.orientation then
			health:SetOrientation(db.health.orientation)
		end

		health.enabled = db.cutaway.health.enabled
		health.lengthBeforeFade = db.cutaway.health.lengthBeforeFade
		health.fadeOutTime = db.cutaway.health.fadeOutTime
		frame.Health:PostUpdateColor(frame.unit)
	end

	if power and frame.USE_POWERBAR then
		if db.power.reverseFill then
			power:SetReverseFill(true)
		else
			power:SetReverseFill(false)
		end

		power:SetFrameLevel(frame.Power:GetFrameLevel())
		power.enabled = db.cutaway.power.enabled
		power.lengthBeforeFade = db.cutaway.power.lengthBeforeFade
		power.fadeOutTime = db.cutaway.power.fadeOutTime
		frame.Power:PostUpdateColor()
	end
end
