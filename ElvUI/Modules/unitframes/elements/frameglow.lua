local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
local _G = _G
--Lua functions
local pairs = pairs
local select = select
local assert = assert
local tinsert = table.insert
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitExists = UnitExists
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

function UF:FrameGlow_MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		local unit = frame.unit or (frame.isForced and 'player')
		return unit and UnitIsUnit('mouseover', unit)
	end

	return false
end

function UF:FrameGlow_PositionGlow(frame, mainGlow, powerGlow)
	if not (frame and frame.VARIABLES_SET) then return end

	local Trinket			= frame.Trinket
	local InfoPanel			= frame.InfoPanel
	local PVPSpecIcon		= frame.PVPSpecIcon
	local AltPowerBar		= frame.AlternativePower
	local healthBackdrop	= frame.Health	and frame.Health.backdrop
	local powerBackdrop		= frame.Power	and frame.Power.backdrop
	local pixelOffset		= (E.PixelMode and 3) or 4

	mainGlow:ClearAllPoints()
	mainGlow:Point('TOPLEFT', healthBackdrop, -pixelOffset, pixelOffset)
	mainGlow:Point('TOPRIGHT', healthBackdrop, pixelOffset, pixelOffset)

	if frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR then
		mainGlow:Point('BOTTOMLEFT', healthBackdrop, -pixelOffset, -pixelOffset)
		mainGlow:Point('BOTTOMRIGHT', healthBackdrop, pixelOffset, -pixelOffset)
	else
		--offset is set because its one pixel off for some reason
		mainGlow:Point('BOTTOMLEFT', frame, -pixelOffset, -(E.PixelMode and pixelOffset or pixelOffset-1))
		mainGlow:Point('BOTTOMRIGHT', frame, pixelOffset, -(E.PixelMode and pixelOffset or pixelOffset-1))
	end

	if powerGlow then
		powerGlow:ClearAllPoints()
		powerGlow:Point('TOPLEFT', powerBackdrop, -pixelOffset, pixelOffset)
		powerGlow:Point('TOPRIGHT', powerBackdrop, pixelOffset, pixelOffset)
		powerGlow:Point('BOTTOMLEFT', powerBackdrop, -pixelOffset, -pixelOffset)
		powerGlow:Point('BOTTOMRIGHT', powerBackdrop, pixelOffset, -pixelOffset)
	end

	if (AltPowerBar and not AltPowerBar.hookedGlow) and frame.unit and frame.unit:find('boss%d') then
		AltPowerBar.hookedGlow = true
		AltPowerBar:HookScript('OnShow', function()
			mainGlow:Point('TOPLEFT', AltPowerBar.backdrop, -pixelOffset, pixelOffset)
			mainGlow:Point('TOPRIGHT', AltPowerBar.backdrop, pixelOffset, pixelOffset)
		end)
		AltPowerBar:HookScript('OnHide', function()
			mainGlow:Point('TOPLEFT', healthBackdrop, -pixelOffset, pixelOffset)
			mainGlow:Point('TOPRIGHT', healthBackdrop, pixelOffset, pixelOffset)
		end)
	elseif Trinket and not Trinket.hookedGlow then
		Trinket.hookedGlow = true
		Trinket:HookScript('OnShow', function()
			mainGlow:Point('TOPRIGHT', Trinket.bg, pixelOffset, pixelOffset)
			mainGlow:Point('BOTTOMRIGHT', Trinket.bg, pixelOffset, -pixelOffset)
		end)
		Trinket:HookScript('OnHide', function()
			local z = (PVPSpecIcon and PVPSpecIcon:IsShown() and PVPSpecIcon.bg)
			mainGlow:Point('TOPRIGHT', z or healthBackdrop, pixelOffset, pixelOffset)
			mainGlow:Point('BOTTOMRIGHT', z or frame, pixelOffset, -pixelOffset)
		end)
	elseif PVPSpecIcon and PVPSpecIcon:IsShown() then
		local z = (InfoPanel and InfoPanel:IsShown() and InfoPanel.backdrop)
		mainGlow:Point('TOPLEFT', PVPSpecIcon.bg, -pixelOffset, pixelOffset)
		mainGlow:Point('BOTTOMLEFT', z or PVPSpecIcon.bg, -pixelOffset, -pixelOffset)
	end
end

function UF:FrameGlow_CreateGlow(frame, mouse)
	-- Main Glow to wrap the health frame to it's best ability
	frame:CreateShadow('Default')
	local mainGlow = frame.shadow
	mainGlow:SetFrameStrata('BACKGROUND')
	mainGlow:Hide()
	frame.shadow = nil

	-- Secondary Glow for power frame when using power offset or mini power
	frame:CreateShadow('Default')
	local powerGlow = frame.shadow
	powerGlow:SetFrameStrata('BACKGROUND')
	powerGlow:Hide()
	frame.shadow = nil

	if mouse then
		mainGlow:SetFrameLevel(4)
		powerGlow:SetFrameLevel(4)
	else
		mainGlow:SetFrameLevel(3)
		powerGlow:SetFrameLevel(3)
	end

	-- Eventing Frame
	if not frame.Highlight then
		frame.Highlight = CreateFrame('Frame', nil, frame)
		frame.Highlight:Hide()
	end

	mainGlow.powerGlow = powerGlow
	return mainGlow
end

function UF:FrameGlow_SetGlowColor(glow, unit, which)
	if not glow then return end
	local option = E.db.unitframe.colors.frameGlow[which]
	local r, g, b, a = 1, 1, 1, 1

	if option.color then
		local color = option.color
		r, g, b, a = color.r, color.g, color.b, color.a
	end

	if option.class then
		local isPlayer = unit and UnitIsPlayer(unit)
		local reaction = unit and UnitReaction(unit, 'player')

		if isPlayer then
			local _, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				if color then
					r, g, b = color.r, color.g, color.b
				end
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			if color then
				r, g, b = color.r, color.g, color.b
			end
		end
	end

	if which == 'mouseoverGlow' then
		glow:SetVertexColor(r, g, b, a)
	else
		glow:SetBackdropBorderColor(r, g, b, a)
		if glow.powerGlow then
			glow.powerGlow:SetBackdropBorderColor(r, g, b, a)
		end
	end
end

function UF:FrameGlow_ElementHook(frame, glow, which)
	if not (frame and frame.__elements) then return end
	tinsert(frame.__elements, function()
		local unit = frame.unit or (frame.isForced and 'player')
		if unit then
			UF:FrameGlow_SetGlowColor(glow, unit, which)
		end

		if which == 'mouseoverGlow' then
			UF:FrameGlow_PositionHighlight(frame)
			UF:FrameGlow_CheckMouseover(frame, glow)
		else
			UF:FrameGlow_PositionGlow(frame, glow, glow.powerGlow)
		end

		if which == 'targetGlow' then
			UF:FrameGlow_CheckTarget(frame, glow)
		end
	end)
end

function UF:FrameGlow_HideGlow(glow)
	if not glow then return end
	if glow:IsShown() then glow:Hide() end
	if glow.powerGlow and glow.powerGlow:IsShown() then
		glow.powerGlow:Hide()
	end
end

function UF:FrameGlow_ConfigureGlow(frame, unit, dbTexture)
	if not frame then return end

	if not unit then
		unit = frame.unit or (frame.isForced and 'player')
	end

	if frame.Highlight and frame.Highlight.texture then
		if E.db.unitframe.colors.frameGlow.mouseoverGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			frame.Highlight.texture:SetTexture(dbTexture)
			UF:FrameGlow_SetGlowColor(frame.Highlight.texture, unit, 'mouseoverGlow')
		elseif frame.Highlight:IsShown() then
			frame.Highlight:Hide()
		end
	end

	if frame.MouseGlow then
		if E.db.unitframe.colors.frameGlow.mainGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			UF:FrameGlow_SetGlowColor(frame.MouseGlow, unit, 'mainGlow')
		else
			UF:FrameGlow_HideGlow(frame.MouseGlow)
		end
	end

	if frame.TargetGlow then
		UF:FrameGlow_CheckTarget(frame, frame.TargetGlow, true)
	end
end

function UF:FrameGlow_CheckTarget(frame, glow, setColor)
	if not frame then return end

	local unit = frame.unit or (frame.isForced and 'player')
	if E.db.unitframe.colors.frameGlow.targetGlow.enable and unit and UnitIsUnit(unit, 'target') and not (frame.db and frame.db.disableTargetGlow) then
		if setColor then
			UF:FrameGlow_SetGlowColor(frame.TargetGlow, unit, 'targetGlow')
		end
		if glow.powerGlow and (frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR) then
			glow.powerGlow:Show()
		end
		glow:Show()
	else
		UF:FrameGlow_HideGlow(glow)
	end
end

function UF:FrameGlow_CheckMouseover(frame, glow)
	if UF:FrameGlow_MouseOnUnit(frame) then
		if E.db.unitframe.colors.frameGlow.mainGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			if glow.powerGlow and (frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR) then
				glow.powerGlow:Show()
			end
			if frame.Highlight then
				frame.Highlight:Show()
				frame.Highlight.texture:Hide()
			end
			glow:Show()
		end

		if E.db.unitframe.colors.frameGlow.mouseoverGlow.enable and frame.Highlight and frame.Highlight.texture and not (frame.db and frame.db.disableMouseoverGlow) then
			if not frame.Highlight:IsShown() then
				frame.Highlight:Show()
			end
			frame.Highlight.texture:Show()
		end
	elseif frame.Highlight and frame.Highlight:IsShown() then
		frame.Highlight:Hide()
	end
end

function UF:FrameGlow_PositionHighlight(frame)
	if frame.Highlight and frame.Highlight.texture then
		frame.Highlight.texture:ClearAllPoints()
		frame.Highlight.texture:Point('TOPLEFT', frame.Health, 'TOPLEFT')
		frame.Highlight.texture:Point('BOTTOMRIGHT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	end
end

function UF:Configure_HighlightGlow(frame)
	if frame.Highlight and frame.Highlight.texture then
		local dbTexture = UF.LSM:Fetch('statusbar', E.db.unitframe.colors.frameGlow.mouseoverGlow.texture)
		frame.Highlight.texture:SetTexture(dbTexture)
	end
end

function UF:Construct_HighlightGlow(frame, glow)
	if frame.Health and frame.Highlight then
		frame.Highlight:HookScript('OnHide', function()
			UF:FrameGlow_HideGlow(glow)

			if frame.Highlight and frame.Highlight.texture and frame.Highlight.texture:IsShown() then
				frame.Highlight.texture:Hide()
			end
		end)
		frame.Highlight:SetScript('OnUpdate', function(watcher, elapsed)
			if watcher.elapsed and watcher.elapsed > 0.1 then
				if not UF:FrameGlow_MouseOnUnit(frame) then
					watcher:Hide()
				end
				watcher.elapsed = 0
			else
				watcher.elapsed = (watcher.elapsed or 0) + elapsed
			end
		end)

		frame.Highlight.texture = frame.Health:CreateTexture('$parentHighlight', 'ARTWORK', nil, 1)
		frame.Highlight.texture:Hide()

		UF:FrameGlow_ElementHook(frame, frame.Highlight.texture, 'mouseoverGlow')
	end
end

function UF:Construct_MouseGlow(frame)
	local mainGlow = UF:FrameGlow_CreateGlow(frame, true)
	UF:FrameGlow_ElementHook(frame, mainGlow, 'mainGlow')

	frame.Highlight:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	frame.Highlight:HookScript('OnEvent', function(_, event)
		if event == 'UPDATE_MOUSEOVER_UNIT' then
			UF:FrameGlow_CheckMouseover(frame, mainGlow)
		end
	end)

	UF:Construct_HighlightGlow(frame, mainGlow)

	return mainGlow
end

function UF:Construct_TargetGlow(frame)
	local mainGlow = UF:FrameGlow_CreateGlow(frame)
	UF:FrameGlow_ElementHook(frame, mainGlow, 'targetGlow')

	frame.Highlight:RegisterEvent('PLAYER_TARGET_CHANGED')
	frame.Highlight:HookScript('OnEvent', function(_, event)
		if event == 'PLAYER_TARGET_CHANGED' then
			UF:FrameGlow_CheckTarget(frame, mainGlow)
		end
	end)

	return mainGlow
end

function UF:FrameGlow_CheckChildren(frame, dbTexture)
	if frame.GetName then
		local pet = _G[frame:GetName()..'Pet']
		if pet then
			UF:FrameGlow_ConfigureGlow(pet, pet.unit, dbTexture)
		end

		local target = _G[frame:GetName()..'Target']
		if target then
			UF:FrameGlow_ConfigureGlow(target, target.unit, dbTexture)
		end
	end
end

function UF:FrameGlow_UpdateFrames()
	local dbTexture = UF.LSM:Fetch('statusbar', E.db.unitframe.colors.frameGlow.mouseoverGlow.texture)

	-- focus, focustarget, pet, pettarget, player, target, targettarget, targettargettarget
	for unit in pairs(self.units) do
		UF:FrameGlow_ConfigureGlow(self[unit], unit, dbTexture)
	end

	-- arena{1-5}, boss{1-5}
	for unit in pairs(self.groupunits) do
		UF:FrameGlow_ConfigureGlow(self[unit], unit, dbTexture)
	end

	-- assist, tank, party, raid, raid40, raidpet
	for groupName in pairs(self.headers) do
		assert(self[groupName], 'UF FrameGlow: Invalid group specified.')
		local group = self[groupName]

		if group.GetNumChildren then
			for i=1, group:GetNumChildren() do
				local frame = select(i, group:GetChildren())
				if frame and frame.Health then
					UF:FrameGlow_ConfigureGlow(frame, frame.unit, dbTexture)
					UF:FrameGlow_CheckChildren(frame, dbTexture)
				elseif frame then
					for n = 1, frame:GetNumChildren() do
						local child = select(n, frame:GetChildren())
						if child and child.Health then
							UF:FrameGlow_ConfigureGlow(child, child.unit, dbTexture)
							UF:FrameGlow_CheckChildren(child, dbTexture)
						end
					end
				end
			end
		end
	end
end