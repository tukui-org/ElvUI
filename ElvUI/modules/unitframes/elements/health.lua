local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local CAN_HAVE_CLASSBAR = (E.myclass == "PALADIN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK" or E.myclass == "PRIEST" or E.myclass == "MONK" or E.myclass == 'MAGE')

function UF:Construct_HealthBar(frame, bg, text, textPos)
	local health = CreateFrame('StatusBar', nil, frame)	
	UF['statusbars'][health] = true
	
	health:SetFrameStrata("LOW")
	health.PostUpdate = self.PostUpdateHealth
	
	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(E["media"].blankTex)
		health.bg.multiplier = 0.25
	end
	
	if text then
		health.value = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
		UF:Configure_FontString(health.value)
		health.value:SetParent(frame)
		
		local x = -2
		if textPos == 'LEFT' then
			x = 2
		end
		
		health.value:Point(textPos, health, textPos, x, 0)		
	end
	
	health.colorTapping = true	
	health.colorDisconnected = true
	health:CreateBackdrop('Default')	

	return health
end

function UF:UpdateElementSettings_Health(frame)
	local db = frame.db
	local health = frame.Health
	
	local SPACING = E.Spacing
	local BORDER = E.Border
	local USE_CLASSBAR = db.classbar.enable and CAN_HAVE_CLASSBAR
	local CLASSBAR_HEIGHT = db.classbar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = (USE_PORTRAIT_OVERLAY or not USE_PORTRAIT) and 0 or db.portrait.width
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.enable and db.power.height or 0
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and db.power.enable
	
	health.Smooth = self.db.smoothbars

	--Text
	local x, y = self:GetPositionOffset(db.health.position)
	health.value:ClearAllPoints()
	health.value:Point(db.health.position, health, db.health.position, x, y)
	frame:Tag(health.value, db.health.text_format)
	
	--Colors
	health.colorSmooth = nil
	health.colorHealth = nil
	health.colorClass = nil
	health.colorReaction = nil
	if self.db['colors'].healthclass ~= true then
		if self.db['colors'].colorhealthbyvalue == true then
			health.colorSmooth = true
		else
			health.colorHealth = true
		end		
	else
		health.colorClass = true
		health.colorReaction = true
	end	
	
	--Position
	health:ClearAllPoints()
	health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)
	if USE_POWERBAR_OFFSET then
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER+POWERBAR_OFFSET)
	elseif USE_MINI_POWERBAR then
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
	else
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
	end
	
	health.bg:ClearAllPoints()
	if not USE_PORTRAIT_OVERLAY then
		health:Point("TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)		
		health.bg:SetParent(health)
		health.bg:SetAllPoints()
	else
		health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		health.bg:Point('TOPRIGHT', health)		
		health.bg:SetParent(frame.Portrait.overlay)			
	end
	
	if USE_CLASSBAR then
		local DEPTH
		if USE_MINI_CLASSBAR then
			DEPTH = -(BORDER+(CLASSBAR_HEIGHT/2))
		else
			DEPTH = -(BORDER+CLASSBAR_HEIGHT+SPACING)
		end
		
		if USE_POWERBAR_OFFSET then
			health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), DEPTH)
		else
			health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, DEPTH)
		end
		
		health:Point("TOPLEFT", frame, "TOPLEFT", PORTRAIT_WIDTH+BORDER, DEPTH)
	end
end

function UF:PostUpdateHealth(unit, min, max)
	local parent = self:GetParent()
	if parent.isForced then
		min = random(1, max)
		self:SetValue(min)
	end

	if parent.ResurrectIcon then
		parent.ResurrectIcon:SetAlpha(min == 0 and 1 or 0)
	end
	
	local r, g, b = self:GetStatusBarColor()
	local colors = E.db['unitframe']['colors'];
	if (colors.healthclass == true and colors.colorhealthbyvalue == true) or (colors.colorhealthbyvalue and parent.isForced) and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		local newr, newg, newb = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

		self:SetStatusBarColor(newr, newg, newb)
		if self.bg and self.bg.multiplier then
			local mu = self.bg.multiplier
			self.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
		end
	end

	if colors.classbackdrop then
		local reaction = UnitReaction(unit, 'player')
		local t
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			t = parent.colors.class[class]
		elseif reaction then
			t = parent.colors.reaction[reaction]
		end

		if t then
			self.bg:SetVertexColor(t[1], t[2], t[3])
		end
	end
	
	--Backdrop
	if colors.customhealthbackdrop then
		local backdrop = colors.health_backdrop
		self.bg:SetVertexColor(backdrop.r, backdrop.g, backdrop.b)		
	end	
end

function UF:GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		order = 100,
		type = 'group',
		name = L['Health'],
		get = function(info) return E.db.unitframe.units[groupName]['health'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]['health'][ info[#info] ] = value; updateFunc(self, groupName, numUnits) end,
		args = {
			position = {
				type = 'select',
				order = 1,
				name = L['Position'],
				values = self.positionValues,
			},
			text_format = {
				order = 100,
				name = L['Text Format'],
				type = 'input',
				width = 'full',
				desc = L['TEXT_FORMAT_DESC'],
			},			
		},
	}
	
	if isGroupFrame then
		config.args.frequentUpdates = {
			type = 'toggle',
			order = 2,
			name = L['Frequent Updates'],
			desc = L['Rapidly update the health, uses more memory and cpu. Only recommended for healing.'],
		}

		config.args.orientation = {
			type = 'select',
			order = 3,
			name = L['Orientation'],
			desc = L['Direction the health bar moves when gaining/losing health.'],
			values = {
				['HORIZONTAL'] = L['Horizontal'],
				['VERTICAL'] = L['Vertical'],
			},
		}
	end
	
	return config
end