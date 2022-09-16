local E, L, V, P, G = unpack(ElvUI)
local T = E:GetModule('Totems')

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local GetTotemInfo = GetTotemInfo
local MAX_TOTEMS = MAX_TOTEMS

function T:Update()
	for i = 1, MAX_TOTEMS do
		local totem = _G['TotemFrameTotem'..i]
		local button = self.bar[i]

		if totem:IsShown() then
			local _, _, startTime, duration, icon = GetTotemInfo(totem.slot)

			button:Show()
			button.iconTexture:SetTexture(icon)
			button.cooldown:SetCooldown(startTime, duration)

			totem:ClearAllPoints()
			totem:SetParent(button.holder)
			totem:SetAllPoints(button.holder)
		else
			button:Hide()
		end
	end
end

function T:PositionAndSize()
	if not E.private.general.totemBar then return end

	for i = 1, MAX_TOTEMS do
		local button = self.bar[i]
		local prevButton = self.bar[i-1]
		button:Size(self.db.size)
		button:ClearAllPoints()

		if self.db.growthDirection == 'HORIZONTAL' and self.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', self.bar, 'LEFT', self.db.spacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', self.db.spacing, 0)
			end
		elseif self.db.growthDirection == 'VERTICAL' and self.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', self.bar, 'TOP', 0, -self.db.spacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -self.db.spacing)
			end
		elseif self.db.growthDirection == 'HORIZONTAL' and self.db.sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', self.bar, 'RIGHT', -self.db.spacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -self.db.spacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', self.bar, 'BOTTOM', 0, self.db.spacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, self.db.spacing)
			end
		end
	end

	if self.db.growthDirection == 'HORIZONTAL' then
		self.bar:Width(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Height(self.db.size + self.db.spacing*2)
	else
		self.bar:Height(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Width(self.db.size + self.db.spacing*2)
	end

	self:Update()
end

function T:Initialize()
	self.Initialized = true

	if not E.private.general.totemBar then return end

	self.db = E.db.general.totems

	local bar = CreateFrame('Frame', 'ElvUI_TotemBar', E.UIParent)
	bar:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', 490, 4)
	self.bar = bar

	for i = 1, MAX_TOTEMS do
		local frame = CreateFrame('Button', bar:GetName()..'Totem'..i, bar)
		frame:SetID(i)
		frame:SetTemplate()
		frame:StyleButton()
		frame:Hide()
		frame.holder = CreateFrame('Frame', nil, frame)
		frame.holder:SetAlpha(0)
		frame.holder:SetAllPoints()

		frame.iconTexture = frame:CreateTexture(nil, 'ARTWORK')
		frame.iconTexture:SetTexCoord(unpack(E.TexCoords))
		frame.iconTexture:SetInside()

		frame.cooldown = CreateFrame('Cooldown', frame:GetName()..'Cooldown', frame, 'CooldownFrameTemplate')
		frame.cooldown:SetReverse(true)
		frame.cooldown:SetInside()

		E:RegisterCooldown(frame.cooldown)

		self.bar[i] = frame
	end

	self:PositionAndSize()

	self:RegisterEvent('PLAYER_TOTEM_UPDATE', 'Update')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update')

	E:CreateMover(bar, 'TotemBarMover', L["Class Totems"], nil, nil, nil, nil, nil, 'general,totems')
end

E:RegisterModule(T:GetName())
