local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local _G = _G
local pairs = pairs
local select = select
local assert = assert
local tinsert = tinsert
local strsub = strsub
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction

function UF:FrameGlow_MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		local unit = frame.unit or (frame.isForced and 'player')
		return unit and UnitIsUnit('mouseover', unit)
	end

	return false
end

function UF:FrameGlow_ElementHook(frame, glow, which)
	if not (frame and frame.__elements) then return end
	tinsert(frame.__elements, function()
		local unit = frame.unit or (frame.isForced and 'player')
		if unit then
			UF:FrameGlow_SetGlowColor(glow, unit, which)
		end

		if which == 'mouseoverGlow' then
			UF:FrameGlow_PositionTexture(frame)
			UF:FrameGlow_CheckMouseover(frame)
		else
			UF:FrameGlow_PositionGlow(frame, glow, glow.powerGlow)
		end

		if which == 'targetGlow' then
			UF:FrameGlow_CheckTarget(frame)
		end

		if which == 'focusGlow' then
			UF:FrameGlow_CheckFocus(frame)
		end
	end)
end

function UF:FrameGlow_HookPowerBar(frame, power, powerName, glow, offset)
	if (frame and power and powerName and glow and offset) and not glow[powerName..'Hooked'] then
		glow[powerName..'Hooked'] = true
		local func = function() UF:FrameGlow_ClassGlowPosition(frame, powerName, glow, offset, true) end
		power:HookScript('OnShow', func)
		power:HookScript('OnHide', func)
	end
end

function UF:FrameGlow_ClassGlowPosition(frame, powerName, glow, offset, fromScript)
	if not (frame and glow and offset) then return end

	local power = powerName and frame[powerName]
	if not power then return end

	-- check for Additional Power to hook scripts on
	local useBonusPower, bonus
	if powerName == 'ClassPower' then
		local bonusName = (frame.AdditionalPower and 'AdditionalPower') or (frame.Stagger and 'Stagger') or (frame.Runes and 'Runes')
		bonus = bonusName and frame[bonusName]

		if bonus then
			if not fromScript then
				UF:FrameGlow_HookPowerBar(frame, bonus, bonusName, glow, offset)
			end

			useBonusPower = bonus:IsVisible()
		end
	end

	if not fromScript then
		UF:FrameGlow_HookPowerBar(frame, power, powerName, glow, offset)
	end

	if useBonusPower then
		power = bonus
	end

	local portrait = (frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY) and (frame.Portrait and frame.Portrait.backdrop)
	if (power and power.backdrop and power:IsVisible()) and ((power == frame.AlternativePower and not frame.USE_MINI_CLASSBAR) or not (frame.CLASSBAR_DETACHED or frame.USE_MINI_CLASSBAR)) then
		glow:SetPoint('TOPLEFT', (frame.ORIENTATION == 'LEFT' and portrait) or power.backdrop, -offset, offset)
		glow:SetPoint('TOPRIGHT', (frame.ORIENTATION == 'RIGHT' and portrait) or power.backdrop, offset, offset)
	elseif frame.Health and frame.Health.backdrop then
		glow:SetPoint('TOPLEFT', (frame.ORIENTATION == 'LEFT' and portrait) or frame.Health.backdrop, -offset, offset)
		glow:SetPoint('TOPRIGHT', (frame.ORIENTATION == 'RIGHT' and portrait) or frame.Health.backdrop, offset, offset)
	end
end

function UF:FrameGlow_PositionGlow(frame, mainGlow, powerGlow)
	if not frame then return end

	local infoPanel = frame.InfoPanel
	local classPower = frame.ClassPower
	local altPower = frame.AlternativePower
	local pvpSpec = frame.PVPSpecIcon
	local power = frame.Power and frame.Power.backdrop
	local health = frame.Health and frame.Health.backdrop
	local portrait = (frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY) and (frame.Portrait and frame.Portrait.backdrop)
	local offset = (UF.thinBorders and 4) or 5 -- edgeSize is 3

	mainGlow:ClearAllPoints()
	mainGlow:SetPoint('TOPLEFT', (frame.ORIENTATION == 'LEFT' and portrait) or health, -offset, offset)
	mainGlow:SetPoint('TOPRIGHT', (frame.ORIENTATION == 'RIGHT' and portrait) or health, offset, offset)

	if frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR then
		mainGlow:SetPoint('BOTTOMLEFT', health, -offset, -offset)
		mainGlow:SetPoint('BOTTOMRIGHT', health, offset, -offset)
	else
		--offset is set because its one pixel off for some reason
		mainGlow:SetPoint('BOTTOMLEFT', frame, -offset, -(UF.thinBorders and offset or offset-1))
		mainGlow:SetPoint('BOTTOMRIGHT', frame, offset, -(UF.thinBorders and offset or offset-1))
	end

	if powerGlow then
		powerGlow:ClearAllPoints()
		powerGlow:SetPoint('TOPLEFT', power, -offset, offset)
		powerGlow:SetPoint('TOPRIGHT', power, offset, offset)
		powerGlow:SetPoint('BOTTOMLEFT', power, -offset, -offset)
		powerGlow:SetPoint('BOTTOMRIGHT', power, offset, -offset)
	end

	if classPower then
		UF:FrameGlow_ClassGlowPosition(frame, 'ClassPower', mainGlow, offset)
	elseif altPower then
		UF:FrameGlow_ClassGlowPosition(frame, 'AlternativePower', mainGlow, offset)
	elseif pvpSpec and pvpSpec:IsShown() then
		local shownPanel = (infoPanel and infoPanel:IsShown() and infoPanel.backdrop)
		mainGlow:SetPoint('TOPLEFT', pvpSpec.bg, -offset, offset)
		mainGlow:SetPoint('BOTTOMLEFT', shownPanel or pvpSpec.bg, -offset, -offset)
	end
end

function UF:FrameGlow_CreateGlow(frame, which)
	-- Main Glow to wrap the health frame to it's best ability
	local mainGlow = frame:CreateShadow(4, true)
	mainGlow:SetFrameStrata('BACKGROUND')
	mainGlow:Hide()

	-- Secondary Glow for power frame when using power offset or mini power
	local powerGlow = frame:CreateShadow(4, true)
	powerGlow:SetFrameStrata('BACKGROUND')
	powerGlow:Hide()

	local level = (which == 'mouse' and 5) or (which == 'target' and 4) or 3
	mainGlow:SetFrameLevel(level)
	powerGlow:SetFrameLevel(level)

	-- Eventing Frame
	if not frame.FrameGlow then
		frame.FrameGlow = CreateFrame('Frame', nil, frame)
		frame.FrameGlow:Hide()
		frame.FrameGlow:SetScript('OnEvent', function(_, event)
			if event == 'UPDATE_MOUSEOVER_UNIT' then
				UF:FrameGlow_CheckMouseover(frame)
			elseif event == 'PLAYER_FOCUS_CHANGED' then
				UF:FrameGlow_CheckFocus(frame)
			elseif event == 'PLAYER_TARGET_CHANGED' then
				UF:FrameGlow_CheckTarget(frame)
			end
		end)
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
				local color = E:ClassColor(class)
				if color then
					r, g, b = color.r, color.g, color.b
				end
			end
		elseif reaction then
			local color = _G.FACTION_BAR_COLORS[reaction]
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

	local shouldHide
	if frame.FrameGlow and frame.FrameGlow.texture then
		if E.db.unitframe.colors.frameGlow.mouseoverGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			frame.FrameGlow.texture:SetTexture(dbTexture)
			UF:FrameGlow_SetGlowColor(frame.FrameGlow.texture, unit, 'mouseoverGlow')
		else
			shouldHide = 'texture'
		end
	end

	if frame.MouseGlow then
		if E.db.unitframe.colors.frameGlow.mainGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			UF:FrameGlow_SetGlowColor(frame.MouseGlow, unit, 'mainGlow')
		else
			UF:FrameGlow_HideGlow(frame.MouseGlow)
			if shouldHide then
				shouldHide = 'both'
			end
		end
	end

	if shouldHide then
		if shouldHide == 'both' and frame.FrameGlow:IsShown() then
			frame.FrameGlow:Hide()
		elseif shouldHide == 'texture' then
			frame.FrameGlow.texture:Hide()
		end
	end

	if frame.TargetGlow then
		UF:FrameGlow_CheckTarget(frame, true)
	end

	if frame.FocusGlow then
		UF:FrameGlow_CheckFocus(frame, true)
	end
end

function UF:FrameGlow_CheckUnit(frame, element, setting, color, glowEnabled, frameDisabled)
	if not (element and frame:IsVisible()) then return end

	local unit = frame.unit or (frame.isForced and 'player')
	if (glowEnabled and not frameDisabled) and unit and UnitIsUnit(unit, strsub(setting, 0, -5)) then
		if color then
			UF:FrameGlow_SetGlowColor(element, unit, setting)
		end
		if element.powerGlow then
			if frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR then
				element.powerGlow:Show()
			elseif element.powerGlow:IsShown() then
				element.powerGlow:Hide()
			end
		end
		element:Show()
	else
		UF:FrameGlow_HideGlow(element)
	end
end

function UF:FrameGlow_CheckTarget(frame, color)
	UF:FrameGlow_CheckUnit(frame, frame.TargetGlow, 'targetGlow', color, E.db.unitframe.colors.frameGlow.targetGlow.enable, frame.db and frame.db.disableTargetGlow)
end

function UF:FrameGlow_CheckFocus(frame, color)
	UF:FrameGlow_CheckUnit(frame, frame.FocusGlow, 'focusGlow', color, E.db.unitframe.colors.frameGlow.focusGlow.enable, frame.db and frame.db.disableFocusGlow)
end

function UF:FrameGlow_CheckMouseover(frame)
	if not (frame and frame.MouseGlow and frame:IsVisible()) then return end

	local shouldShow
	if UF:FrameGlow_MouseOnUnit(frame) then
		if E.db.unitframe.colors.frameGlow.mainGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			shouldShow = 'frame'
		end
		if E.db.unitframe.colors.frameGlow.mouseoverGlow.enable and not (frame.db and frame.db.disableMouseoverGlow) then
			shouldShow = (shouldShow and 'both') or 'texture'
		end
	end

	if shouldShow then
		if frame.FrameGlow and not frame.FrameGlow:IsShown() then
			frame.FrameGlow:Show()
		end
		if shouldShow == 'both' or shouldShow == 'frame' then
			if frame.MouseGlow.powerGlow then
				if frame.USE_POWERBAR_OFFSET or frame.USE_MINI_POWERBAR then
					frame.MouseGlow.powerGlow:Show()
				elseif frame.MouseGlow.powerGlow:IsShown() then
					frame.MouseGlow.powerGlow:Hide()
				end
			end
			frame.MouseGlow:Show()

			if shouldShow == 'frame' and frame.FrameGlow.texture and frame.FrameGlow.texture:IsShown() then
				frame.FrameGlow.texture:Hide()
			end
		end
		if (shouldShow == 'both' or shouldShow == 'texture') and frame.FrameGlow.texture and not frame.FrameGlow.texture:IsShown() then
			frame.FrameGlow.texture:Show()
		end
	elseif frame.FrameGlow and frame.FrameGlow:IsShown() then
		frame.FrameGlow:Hide()
	end
end

function UF:FrameGlow_PositionTexture(frame)
	if frame.FrameGlow and frame.FrameGlow.texture then
		frame.FrameGlow.texture:ClearAllPoints()
		frame.FrameGlow.texture:SetPoint('TOPLEFT', frame.Health, 'TOPLEFT')
		frame.FrameGlow.texture:SetPoint('BOTTOMRIGHT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	end
end

function UF:Configure_FrameGlow(frame)
	if frame.FrameGlow and frame.FrameGlow.texture then
		local dbTexture = LSM:Fetch('statusbar', E.db.unitframe.colors.frameGlow.mouseoverGlow.texture)
		frame.FrameGlow.texture:SetTexture(dbTexture)
	end
end

function UF:Construct_FrameGlow(frame, glow)
	if frame.Health and frame.FrameGlow then
		frame.FrameGlow:SetScript('OnHide', function(watcher)
			UF:FrameGlow_HideGlow(glow)

			if watcher.texture and watcher.texture:IsShown() then
				watcher.texture:Hide()
			end
		end)

		frame.FrameGlow:SetScript('OnUpdate', function(watcher, elapsed)
			if watcher.elapsed and watcher.elapsed > 0.1 then
				if not UF:FrameGlow_MouseOnUnit(frame) then
					watcher:Hide()
				end
				watcher.elapsed = 0
			else
				watcher.elapsed = (watcher.elapsed or 0) + elapsed
			end
		end)

		frame.FrameGlow.texture = frame.Health:CreateTexture('$parentFrameGlow', 'ARTWORK', nil, 1)
		frame.FrameGlow.texture:Hide()

		UF:FrameGlow_ElementHook(frame, frame.FrameGlow.texture, 'mouseoverGlow')
	end
end

function UF:Construct_MouseGlow(frame)
	local mainGlow = UF:FrameGlow_CreateGlow(frame, 'mouse')
	UF:FrameGlow_ElementHook(frame, mainGlow, 'mainGlow')
	UF:Construct_FrameGlow(frame, mainGlow)
	frame.FrameGlow:RegisterEvent('UPDATE_MOUSEOVER_UNIT')

	return mainGlow
end

function UF:Construct_TargetGlow(frame)
	local targetGlow = UF:FrameGlow_CreateGlow(frame, 'target')
	UF:FrameGlow_ElementHook(frame, targetGlow, 'targetGlow')
	frame.FrameGlow:RegisterEvent('PLAYER_TARGET_CHANGED')

	return targetGlow
end

function UF:Construct_FocusGlow(frame)
	local focusGlow = UF:FrameGlow_CreateGlow(frame, 'focus')
	UF:FrameGlow_ElementHook(frame, focusGlow, 'focusGlow')
	frame.FrameGlow:RegisterEvent('PLAYER_FOCUS_CHANGED')

	return focusGlow
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
	local dbTexture = LSM:Fetch('statusbar', E.db.unitframe.colors.frameGlow.mouseoverGlow.texture)

	-- focus, focustarget, pet, pettarget, player, target, targettarget, targettargettarget
	for unit in pairs(UF.units) do
		UF:FrameGlow_ConfigureGlow(UF[unit], unit, dbTexture)
	end

	-- arena{1-5}, boss{1-5}
	for unit in pairs(UF.groupunits) do
		UF:FrameGlow_ConfigureGlow(UF[unit], unit, dbTexture)
	end

	-- assist, tank, party, raid1, raid2, raid3, raidpet
	for groupName in pairs(UF.headers) do
		local group = UF[groupName]
		if group and group.GetNumChildren then
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
