local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.LSM

--Lua functions
--WoW API / Variables
local UnitHealth = UnitHealth
local UnitIsUnit = UnitIsUnit
local UnitHealthMax = UnitHealthMax

--[[ Target Glow Style Option Variables
	style1:'Border',
	style2:'Background',
	style3:'Top Arrow Only',
	style4:'Side Arrows Only',
	style5:'Border + Top Arrow',
	style6:'Background + Top Arrow',
	style7:'Border + Side Arrows',
	style8:'Background + Side Arrows'
]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.TargetIndicator

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	if element.TopIndicator then element.TopIndicator:Hide() end
	if element.LeftIndicator then element.LeftIndicator:Hide() end
	if element.RightIndicator then element.RightIndicator:Hide() end
	if element.Shadow then element.Shadow:Hide() end
	if element.Spark then element.Spark:Hide() end

	if UnitIsUnit(self.unit, 'target') and (element.style ~= 'none') then
		if element.TopIndicator and (element.style == 'style3' or element.style == 'style5' or element.style == 'style6') then
			element.TopIndicator:Show()
		end

		if (element.LeftIndicator and element.RightIndicator) and (element.style == 'style4' or element.style == 'style7' or element.style == 'style8') then
			element.RightIndicator:Show()
			element.LeftIndicator:Show()
		end

		if element.Shadow and (element.style == 'style1' or element.style == 'style5' or element.style == 'style7') then
			element.Shadow:Show()
		end

		if element.Spark and (element.style == 'style2' or element.style == 'style6' or element.style == 'style8') then
			element.Spark:Show()
		end
	end

	local r, g, b
	local showIndicator
	if UnitIsUnit(self.unit, 'target') then
		showIndicator = true
		r, g, b = NP.db.colors.glowColor.r, NP.db.colors.glowColor.g, NP.db.colors.glowColor.b
	elseif (not UnitIsUnit(self.unit, 'target') and element.lowHealthThreshold > 0) then
		local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
		local perc = (maxHealth > 0 and health/maxHealth) or 0

		if perc <= element.lowHealthThreshold then
			showIndicator = true
			if perc <= element.lowHealthThreshold / 2 then
				r, g, b = 1, 0, 0
			else
				r, g, b = 1, 1, 0
			end
		end

	end

	if showIndicator then
		if element.TopIndicator and (element.style == 'style3' or element.style == 'style5' or element.style == 'style6') then
			element.TopIndicator:SetVertexColor(r, g, b)
		end

		if (element.LeftIndicator and element.RightIndicator) and (element.style == 'style4' or element.style == 'style7' or element.style == 'style8') then
			element.RightIndicator:SetVertexColor(r, g, b)
			element.LeftIndicator:SetVertexColor(r, g, b)
		end

		if element.Shadow and (element.style == 'style1' or element.style == 'style5' or element.style == 'style7') then
			element.Shadow:Show()
			element.Shadow:SetBackdropBorderColor(r, g, b)
		end

		if element.Spark and (element.style == 'style2' or element.style == 'style6' or element.style == 'style8') then
			element.Spark:Show()
			element.Spark:SetVertexColor(r, g, b)
		end
	end

	if (element.PostUpdate) then
		return element:PostUpdate(self.unit)
	end
end

local function Path(self, ...)
	return (self.TargetIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.TargetIndicator
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.style then
			element.style = 'style1'
		end

		if not element.lowHealthThreshold then
			element.lowHealthThreshold = .4
		end

		if element.Shadow then
			if element.Shadow:IsObjectType('Frame') and not element.Shadow:GetBackdrop() == nil then
				element.Shadow:SetBackdrop({edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(5)})
			end
		end

		if element.Spark then
			if element.Spark:IsObjectType('Texture') and not element.Spark:GetTexture() then
				element.Spark:SetTexture(E.Media.Textures.Spark)
			end
		end

		if element.TopIndicator then
			if element.TopIndicator:IsObjectType('Texture') and not element.TopIndicator:GetTexture() then
				element.TopIndicator:SetTexture(E.Media.Textures.ArrowUp)
				element.TopIndicator:SetRotation(3.14)
			end
		end

		if element.LeftIndicator then
			if element.LeftIndicator:IsObjectType('Texture') and not element.LeftIndicator:GetTexture() then
				element.LeftIndicator:SetTexture(E.Media.Textures.ArrowUp)
				element.LeftIndicator:SetRotation(1.57)
			end
		end

		if element.RightIndicator then
			if element.RightIndicator:IsObjectType('Texture') and not element.RightIndicator:GetTexture() then
				element.RightIndicator:SetTexture(E.Media.Textures.ArrowUp)
				element.RightIndicator:SetRotation(-1.57)
			end
		end

		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)
		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicator
	if (element) then
		if element.TopIndicator then element.TopIndicator:Hide() end
		if element.LeftIndicator then element.LeftIndicator:Hide() end
		if element.RightIndicator then element.RightIndicator:Hide() end
		if element.Shadow then element.Shadow:Hide() end
		if element.Spark then element.Spark:Hide() end

		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
	end
end

oUF:AddElement('TargetIndicator', Path, Enable, Disable)
