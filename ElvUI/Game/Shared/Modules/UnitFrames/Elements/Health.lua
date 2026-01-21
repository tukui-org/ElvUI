local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local _G = _G
local random = random
local strmatch = strmatch

local CreateFrame = CreateFrame
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsCharmed = UnitIsCharmed
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction
local UnitClass = UnitClass

local customBackdrop = Mixin({}, ColorMixin)

function UF.HealthClipFrame_OnUpdate(clipFrame)
	UF.HealthClipFrame_HealComm(clipFrame.__frame)

	clipFrame:SetScript('OnUpdate', nil)
end

function UF:Construct_HealthBar(frame, bg, text, textPos)
	local health = CreateFrame('StatusBar', '$parent_HealthBar', frame)
	UF.statusbars[health] = 'health'

	health:SetFrameLevel(10) --Make room for Portrait and Power which should be lower by default
	health.PostUpdate = UF.PostUpdateHealth
	health.PostUpdateColor = UF.PostUpdateHealthColor

	health.RaisedElementParent = UF:CreateRaisedElement(health)

	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(E.media.blankTex)
	end

	if text then
		health.value = UF:CreateRaisedText(frame.RaisedElementParent)
		health.value:Point(textPos, health, textPos, textPos == 'LEFT' and 2 or -2, 0)
	end

	health:CreateBackdrop(nil, nil, nil, nil, true)

	local clipFrame = UF:Construct_ClipFrame(frame, health)
	clipFrame:SetScript('OnUpdate', UF.HealthClipFrame_OnUpdate)

	return health
end

function UF:Configure_HealthBar(frame, powerUpdate)
	local db = frame.db
	local health = frame.Health

	health:SetColorTapping(true)
	health:SetColorDisconnected(true)

	if not E.Midnight then
		E:SetSmoothing(health, db.health and db.health.smoothbars)
	end

	-- Text
	if db.health and health.value then
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.health.attachTextTo)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position or 'RIGHT', attachPoint, db.health.position or 'RIGHT', db.health.xOffset or -2, db.health.yOffset or 0)
		frame:Tag(health.value, db.health.text_format or '')
	end

	-- Colors
	local colorSelection
	health.colorSmooth = nil
	health.colorHealth = nil
	health.colorClass = nil
	health.colorReaction = nil

	if db.colorOverride == 'FORCE_ON' or db.colorOverride == 'ALWAYS' then
		health.colorClass = true
		health.colorReaction = true
	elseif db.colorOverride == 'FORCE_OFF' then
		if UF.db.colors.colorhealthbyvalue then
			health.colorSmooth = true
		else
			health.colorHealth = true
		end
	else
		if E.Retail and UF.db.colors.healthselection then
			colorSelection = true
		elseif UF.db.colors.healthclass ~= true then
			if UF.db.colors.colorhealthbyvalue then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
			health.colorClass = not UF.db.colors.forcehealthreaction
			health.colorReaction = true
		end
	end

	health:SetColorSelection(colorSelection)

	--Position
	health.WIDTH = db.width or 60
	health.HEIGHT = db.height or 10

	local BORDER_SPACING = UF.BORDER + UF.SPACING
	local LESS_SPACING = -UF.BORDER - UF.SPACING

	local CLASSBAR_YOFFSET = frame.CLASSBAR_YOFFSET or 0
	local PORTRAIT_WIDTH = frame.PORTRAIT_WIDTH or 0
	local POWERBAR_HEIGHT = frame.POWERBAR_HEIGHT or 0
	local POWERBAR_OFFSET = frame.POWERBAR_OFFSET or 0
	local PVPINFO_WIDTH = frame.PVPINFO_WIDTH or 0

	local BOTTOM_SPACING = BORDER_SPACING + frame.BOTTOM_OFFSET
	local CLASSBAR_LESSSPACING = LESS_SPACING - CLASSBAR_YOFFSET
	local CLASSBAR_YSPACING = BORDER_SPACING + CLASSBAR_YOFFSET
	local PORTRAIT_NOSPACING = -PORTRAIT_WIDTH - BORDER_SPACING
	local PORTRAIT_SPACING = BORDER_SPACING + PORTRAIT_WIDTH
	local POWERBAR_HALF = UF.SPACING + (POWERBAR_HEIGHT * 0.5) -- this is meant to have UF.SPACING
	local POWERBAR_SPACING = BORDER_SPACING + POWERBAR_OFFSET
	local PVPINFO_LESSSPACING = LESS_SPACING - PVPINFO_WIDTH
	local PVPINFO_SPACING = BORDER_SPACING + PVPINFO_WIDTH

	local HEIGHT_YCLASSBAR = health.HEIGHT - CLASSBAR_YSPACING
	local WIDTH_POWERBAR = health.WIDTH - POWERBAR_SPACING
	local WIDTH_PVPINFO = health.WIDTH - PVPINFO_SPACING

	health:ClearAllPoints()
	if frame.ORIENTATION == 'LEFT' then
		health:Point('TOPRIGHT', frame, 'TOPRIGHT', PVPINFO_LESSSPACING, CLASSBAR_LESSSPACING)

		if frame.USE_POWERBAR_OFFSET and frame.POWERBAR_SHOWN then
			health:Point('TOPRIGHT', frame, 'TOPRIGHT', LESS_SPACING - POWERBAR_OFFSET, CLASSBAR_LESSSPACING)
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', PORTRAIT_SPACING, POWERBAR_SPACING)

			health.WIDTH = WIDTH_POWERBAR - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_SPACING
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', PORTRAIT_SPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		elseif frame.USE_MINI_POWERBAR and frame.POWERBAR_SHOWN then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', PORTRAIT_SPACING, POWERBAR_HALF)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_HALF
		else
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', PORTRAIT_SPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		end
	elseif frame.ORIENTATION == 'RIGHT' then
		health:Point('TOPLEFT', frame, 'TOPLEFT', PVPINFO_SPACING, CLASSBAR_LESSSPACING)

		if frame.USE_POWERBAR_OFFSET and frame.POWERBAR_SHOWN then
			health:Point('TOPLEFT', frame, 'TOPLEFT', POWERBAR_SPACING, CLASSBAR_LESSSPACING)
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', PORTRAIT_NOSPACING, POWERBAR_SPACING)

			health.WIDTH = WIDTH_POWERBAR - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_SPACING
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', PORTRAIT_NOSPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		elseif frame.USE_MINI_POWERBAR and frame.POWERBAR_SHOWN then
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', PORTRAIT_NOSPACING, POWERBAR_HALF)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_HALF
		else
			health:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', PORTRAIT_NOSPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		end
	elseif frame.ORIENTATION == 'MIDDLE' then
		health:Point('TOPRIGHT', frame, 'TOPRIGHT', PVPINFO_LESSSPACING, CLASSBAR_LESSSPACING)

		if frame.USE_POWERBAR_OFFSET and frame.POWERBAR_SHOWN then
			health:Point('TOPRIGHT', frame, 'TOPRIGHT', LESS_SPACING - POWERBAR_OFFSET, CLASSBAR_LESSSPACING)
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', POWERBAR_SPACING, POWERBAR_SPACING)

			health.WIDTH = WIDTH_POWERBAR - POWERBAR_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_SPACING
		elseif frame.POWERBAR_DETACHED or not frame.USE_POWERBAR or frame.USE_INSET_POWERBAR then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', BORDER_SPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - BORDER_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		elseif frame.USE_MINI_POWERBAR and frame.POWERBAR_SHOWN then
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', BORDER_SPACING, POWERBAR_HALF)

			health.WIDTH = WIDTH_PVPINFO - BORDER_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - POWERBAR_HALF
		else
			health:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', PORTRAIT_SPACING, BOTTOM_SPACING)

			health.WIDTH = WIDTH_PVPINFO - PORTRAIT_SPACING
			health.HEIGHT = HEIGHT_YCLASSBAR - BOTTOM_SPACING
		end
	end

	if db.health then
		--Party/Raid Frames allow to change statusbar orientation
		if db.health.orientation then
			health:SetOrientation(db.health.orientation or 'HORIZONTAL')
		end

		health:SetReverseFill(not not db.health.reverseFill)
	end

	if powerUpdate then return end -- we dont need to redo this stuff, power updated it

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg, true, nil, db.health and db.health.reverseFill)

	UF:Configure_FrameGlow(frame)

	if frame:IsElementEnabled('Health') then
		frame.Health:ForceUpdate()
	end
end

function UF:GetHealthBottomOffset(frame)
	local BORDER_NOSPACING = UF.BORDER - UF.SPACING
	local bottomOffset = 0

	if frame.USE_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_INSET_POWERBAR and frame.POWERBAR_SHOWN then
		bottomOffset = bottomOffset + frame.POWERBAR_HEIGHT - BORDER_NOSPACING
	end

	if frame.USE_INFO_PANEL then
		bottomOffset = bottomOffset + frame.INFO_PANEL_HEIGHT - BORDER_NOSPACING
	end

	return bottomOffset
end

local HOSTILE_REACTION = 2

function UF:PostUpdateHealthColor(unit, color)
	local parent = self:GetParent()
	local colors = E.db.unitframe.colors
	local env = (parent.isForced and UF.ConfigEnv) or _G

	local isTapped = UnitIsTapDenied(unit)
	local isDeadOrGhost = env.UnitIsDeadOrGhost(unit)
	local healthBreak = not isTapped and colors.healthBreak

	local r, g, b = colors.health.r, colors.health.g, colors.health.b

	-- Recheck offline status when forced
	if parent.isForced and self.colorDisconnected and not env.UnitIsConnected(unit) then
		color = parent.colors.disconnected
	end

	-- Charmed player should have hostile color
	if unit and (strmatch(unit, 'raid%d+') or strmatch(unit, 'party%d+')) then
		if not isDeadOrGhost and env.UnitIsConnected(unit) and UnitIsCharmed(unit) and UnitIsEnemy('player', unit) then
			color = parent.colors.reaction[HOSTILE_REACTION]
		end
	end

	local minValue, maxValue = self.cur, self.max
	local newr, newg, newb, healthbreakBackdrop
	if not color and not E.Midnight then -- dont need to process this when its hostile
		if not parent.db or parent.db.colorOverride ~= 'ALWAYS' then
			if ((colors.healthclass and colors.colorhealthbyvalue) or (colors.colorhealthbyvalue and parent.isForced)) and not isTapped then
				newr, newg, newb = E:ColorGradient(maxValue == 0 and 0 or (minValue / maxValue), 1, 0, 0, 1, 1, 0, r, g, b)
			elseif healthBreak and healthBreak.enabled and (not healthBreak.onlyFriendly or UnitIsFriend('player', unit)) then
				local breakPoint = self.max > 0 and (self.cur / self.max) or 1
				local threshold = healthBreak.threshold

				if threshold.bad and (breakPoint <= healthBreak.low) then
					color = healthBreak.bad
				elseif threshold.good and (breakPoint >= healthBreak.high and breakPoint ~= 1) then
					color = healthBreak.good
				elseif threshold.neutral and (breakPoint >= healthBreak.low and breakPoint < healthBreak.high) then
					color = colors.healthBreak.neutral
				end

				healthbreakBackdrop = color and healthBreak.colorBackdrop
			end
		end
	end

	local bg, bgc = self.bg
	if bg then
		if colors.useDeadBackdrop and isDeadOrGhost then
			bgc = colors.health_backdrop_dead
		elseif healthbreakBackdrop then
			bgc = color
		elseif colors.healthbackdropbyvalue and not E.Midnight then
			if colors.customhealthbackdrop then
				local bgr, bgg, bgb = E:ColorGradient(maxValue == 0 and 0 or (minValue / maxValue), 1, 0, 0, 1, 1, 0, colors.health_backdrop.r, colors.health_backdrop.g, colors.health_backdrop.b)
				customBackdrop:SetRGB(bgr, bgg, bgb)
				bgc = true -- will use the color above
			elseif not newb and not colors.colorhealthbyvalue then
				local bgr, bgg, bgb = E:ColorGradient(maxValue == 0 and 0 or (minValue / maxValue), 1, 0, 0, 1, 1, 0, r, g, b)
				customBackdrop:SetRGB(bgr, bgg, bgb)
				bgc = true -- will use the color above
			end
		elseif colors.customhealthbackdrop then
			bgc = colors.health_backdrop
		elseif colors.classbackdrop then
			if UnitIsPlayer(unit) or (E.Retail and UnitInPartyIsAI(unit)) then
				local _, unitClass = UnitClass(unit)
				bgc = parent.colors.class[unitClass]
			end

			local reaction = not bgc and UnitReaction(unit, 'player')
			if reaction then
				bgc = parent.colors.reaction[reaction]
			end
		end
	end

	if newb then
		UF:SetStatusBarColor(self, newr, newg, newb, (bgc == true and customBackdrop) or bgc)
	elseif color then
		UF:SetStatusBarColor(self, color.r, color.g, color.b, (bgc == true and customBackdrop) or bgc)
	end
end

function UF:PostUpdateHealth(_, cur)
	local parent = self:GetParent()
	if parent.isForced then
		self.cur = random(1, 100)
		self.max = 100

		self:SetMinMaxValues(0, self.max)
		self:SetValue(self.cur)
	elseif parent.ResurrectIndicator then
		parent.ResurrectIndicator:SetAlpha((E:NotSecretValue(cur) and cur == 0) and 1 or 0)
	end
end
