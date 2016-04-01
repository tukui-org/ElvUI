local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

function UF:Construct_TargetGlow(frame)
	frame:CreateShadow('Default')
	local x = frame.shadow
	frame.shadow = nil
	--x:SetFrameStrata('BACKGROUND')
	x:Hide();

	--Secondary TargetGlow, for power frame when using power offset
	frame:CreateShadow('Default')
	local shadow = frame.shadow
	shadow:SetFrameStrata('BACKGROUND')
	x.powerGlow = shadow
	frame.shadow = nil

	return x
end

function UF:UpdateTargetGlow(event)
	if not self.unit then return; end
	local unit = self.unit

	if UnitIsUnit(unit, 'target') and self.USE_TARGET_GLOW then
		self.TargetGlow:Show()
		if self.USE_POWERBAR_OFFSET then
			self.TargetGlow.powerGlow:Show()
		end
		local reaction = UnitReaction(unit, 'player')

		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
				self.TargetGlow.powerGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
				self.TargetGlow.powerGlow:SetBackdropBorderColor(1, 1, 1)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			self.TargetGlow.powerGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
			self.TargetGlow.powerGlow:SetBackdropBorderColor(1, 1, 1)
		end
	else
		self.TargetGlow:Hide()
		self.TargetGlow.powerGlow:Hide()
	end
end

function UF:Configure_TargetGlow(frame)
	local SHADOW_SPACING = frame.SHADOW_SPACING
	local targetHealthGlow = frame.TargetGlow
	local targetPowerGlow = frame.TargetGlow.powerGlow
	targetHealthGlow:ClearAllPoints()

	if frame.USE_POWERBAR_OFFSET then
		if frame.ORIENTATION == "RIGHT" then
			targetHealthGlow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING - frame.STAGGER_WIDTH, frame.SHADOW_SPACING + frame.SPACING + (frame.USE_CLASSBAR and (frame.USE_MINI_CLASSBAR and 0 or frame.CLASSBAR_HEIGHT) or 0))
			targetHealthGlow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
		else
			targetHealthGlow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING + (frame.USE_CLASSBAR and (frame.USE_MINI_CLASSBAR and 0 or frame.CLASSBAR_HEIGHT) or 0))
			targetHealthGlow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING + frame.STAGGER_WIDTH, -frame.SHADOW_SPACING - frame.SPACING)
		end

		targetPowerGlow:ClearAllPoints()
		targetPowerGlow:Point("TOPLEFT", frame.Power.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING)
		targetPowerGlow:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
	else
		targetHealthGlow:Point("TOPLEFT", -frame.SHADOW_SPACING, frame.SHADOW_SPACING-(frame.USE_MINI_CLASSBAR and frame.CLASSBAR_YOFFSET or 0))

		if frame.USE_MINI_POWERBAR then
			targetHealthGlow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
			targetHealthGlow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
		else
			targetHealthGlow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
			targetHealthGlow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
		end
	end
end