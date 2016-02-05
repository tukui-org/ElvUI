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

	return x
end

function UF:UpdateTargetGlow(event)
	if not self.unit then return; end
	local unit = self.unit

	if UnitIsUnit(unit, 'target') then
		self.TargetGlow:Show()
		local reaction = UnitReaction(unit, 'player')

		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
		end
	else
		self.TargetGlow:Hide()
	end
end

function UF:Configure_TargetGlow(frame)
		local SHADOW_SPACING = frame.SHADOW_SPACING
		local tGlow = frame.TargetGlow
		tGlow:ClearAllPoints()

		tGlow:Point("TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING)
		tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)

		if frame.USE_MINI_POWERBAR then
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
		else
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
		end

		if USE_POWERBAR_OFFSET then
			tGlow:Point("TOPLEFT", -SHADOW_SPACING+frame.POWERBAR_OFFSET, SHADOW_SPACING)
			tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
			tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING+frame.POWERBAR_OFFSET, -SHADOW_SPACING+frame.POWERBAR_OFFSET)
			tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING+frame.POWERBAR_OFFSET)
		end
end