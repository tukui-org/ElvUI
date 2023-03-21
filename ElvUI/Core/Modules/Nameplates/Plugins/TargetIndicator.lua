local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

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

local function HideIndicators(element)
	if element.TopIndicator then element.TopIndicator:Hide() end
	if element.LeftIndicator then element.LeftIndicator:Hide() end
	if element.RightIndicator then element.RightIndicator:Hide() end
	if element.Shadow then element.Shadow:Hide() end
	if element.Spark then element.Spark:Hide() end
end

local function ShowIndicators(element, isTarget, color)
	if isTarget then
		if element.TopIndicator and (element.style == 'style3' or element.style == 'style5' or element.style == 'style6') then
			element.TopIndicator:SetVertexColor(color.r, color.g, color.b)
			element.TopIndicator:SetTexture(element.arrow)
			element.TopIndicator:Show()
		end

		if element.LeftIndicator and element.RightIndicator and (element.style == 'style4' or element.style == 'style7' or element.style == 'style8') then
			element.LeftIndicator:SetVertexColor(color.r, color.g, color.b)
			element.RightIndicator:SetVertexColor(color.r, color.g, color.b)
			element.LeftIndicator:SetTexture(element.arrow)
			element.RightIndicator:SetTexture(element.arrow)
			element.RightIndicator:Show()
			element.LeftIndicator:Show()
		end
	end

	if element.Shadow and (element.style == 'style1' or element.style == 'style5' or element.style == 'style7') then
		element.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
		element.Shadow:Show()
	end

	if element.Spark and (element.style == 'style2' or element.style == 'style6' or element.style == 'style8') then
		element.Spark:SetVertexColor(color.r, color.g, color.b)
		element.Spark:Show()
	end
end

local function Update(self)
	local element = self.TargetIndicator
	if element.PreUpdate then
		element:PreUpdate()
	end

	HideIndicators(element)

	if element.style ~= 'none' then
		local isTarget = UnitIsUnit(self.unit, 'target')
		local lowHealth = element.lowHealthThreshold > 0
		if isTarget and (element.preferGlowColor or not lowHealth) then
			ShowIndicators(element, isTarget, NP.db.colors.glowColor)
		elseif lowHealth then
			local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit)
			local perc = (maxHealth > 0 and health/maxHealth) or 0

			-- color tables are class updated in UpdateMedia
			if perc <= element.lowHealthThreshold * 0.5 then
				ShowIndicators(element, isTarget, NP.db.colors.lowHealthHalf)
			elseif perc <= element.lowHealthThreshold then
				ShowIndicators(element, isTarget, NP.db.colors.lowHealthColor)
			elseif isTarget then
				ShowIndicators(element, isTarget, NP.db.colors.glowColor)
			end
		end
	end

	if element.PostUpdate then
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
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.style then element.style = 'style1' end
		if not element.preferGlowColor then element.preferGlowColor = true end
		if not element.lowHealthThreshold then element.lowHealthThreshold = .4 end

		if element.Shadow and element.Shadow:IsObjectType('Frame') and not element.Shadow:GetBackdrop() then
			element.Shadow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = 5})
		end

		if element.Spark and element.Spark:IsObjectType('Texture') and not element.Spark:GetTexture() then
			element.Spark:SetTexture(E.Media.Textures.Spark)
		end

		if element.TopIndicator and element.TopIndicator:IsObjectType('Texture') and not element.TopIndicator:GetTexture() then
			element.TopIndicator:SetTexture(E.Media.Textures.ArrowUp)
			element.TopIndicator:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0) --Rotates texture 180 degress (Up arrow to face down)
		end

		if element.LeftIndicator and element.LeftIndicator:IsObjectType('Texture') and not element.LeftIndicator:GetTexture() then
			element.LeftIndicator:SetTexture(E.Media.Textures.ArrowUp)
			element.LeftIndicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) --Rotates texture 90 degrees clockwise (Up arrow to face right)
		end

		if element.RightIndicator and element.RightIndicator:IsObjectType('Texture') and not element.RightIndicator:GetTexture() then
			element.RightIndicator:SetTexture(E.Media.Textures.ArrowUp)
			element.RightIndicator:SetTexCoord(1, 1, 0, 1, 1, 0, 0, 0) --Flips texture horizontally (Right facing arrow to face left)
		end

		if E.Classic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_HEALTH', Path)
		end

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicator
	if element then
		HideIndicators(element)

		if E.Classic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		else
			self:UnregisterEvent('UNIT_HEALTH', Path)
		end

		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

ElvUF:AddElement('TargetIndicator', Path, Enable, Disable)
