local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = E.LSM

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
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

local function Update(self)
	local element = self.TargetIndicator

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	for i = 1, #element do
		element[i]:Hide()
	end

	if UnitIsUnit(self.unit, "target") and (element.style ~= "none") then
		if element.TopIndicator and (element.style == "style3" or element.style == "style5" or element.style == "style6") then
			element.TopIndicator:Show()
		end

		if (element.LeftIndicator and element.RightIndicator) and (element.style == "style4" or element.style == "style7" or element.style == "style8") then
			element.RightArrow:Show()
			element.LeftArrow:Show()
		end
	end

	if element.healthThreshold > 0 then
		if element.Shadow and (element.style == "style1" or element.style == "style5" or element.style == "style7") then
			element.Shadow:Show()
		end

		if element.Spark and (element.style == "style2" or element.style == "style6" or element.style == "style8") then
			element.Spark:Show()
		end
	end

	if (element.PostUpdate) then
		return element:PostUpdate()
	end
end

local function Path(self, ...)
	return (self.TargetIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.TargetIndicator
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.style then
			element.style = "style1"
		end

		if not element.healthThreshold then
			element.healthThreshold = 30
		end

		if element.Shadow then
			if element.Shadow:IsObjectType('Frame') and not element.Shadow:GetTexture() then
				element.Shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(5)})
			end
		end

		if element.Spark then
			if element.Spark:IsObjectType('Texture') and not element.Spark:GetTexture() then
				element.Spark:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])
			end
		end

		if element.TopIndicator then
			if element.TopIndicator:IsObjectType('Texture') and not element.TopIndicator:GetTexture() then
				element.TopIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator]])
			end
		end

		if element.LeftIndicator then
			if element.LeftIndicator:IsObjectType('Texture') and not element.LeftIndicator:GetTexture() then
				element.LeftIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft]])
			end
		end

		if element.RightIndicator then
			if element.RightIndicator:IsObjectType('Texture') and not element.RightIndicator:GetTexture() then
				element.RightIndicator:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight]])
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path)

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicator
	if (element) then
		element:Hide()

		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end
end

oUF:AddElement('TargetIndicator', Path, Enable, Disable)