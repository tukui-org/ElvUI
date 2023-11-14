local E, L, V, P, G = unpack(ElvUI)
local ElvUF = E.oUF

local textures = {}
local atlases = {
	elite = 'nameplates-icon-elite-gold',
	worldboss = 'nameplates-icon-elite-gold',
	rareelite = 'nameplates-icon-elite-silver',
	rare = 'nameplates-icon-elite-silver'
}

local function Update(self)
	local element = self.ClassificationIndicator
	local classification = self.classification

	if element.PreUpdate then
		element:PreUpdate()
	end

	local atlas = atlases[classification]
	local texture = textures[classification]
	if atlas then
		element:SetAtlas(atlas)
		element:Show()
	elseif texture then
		element:SetTexture(texture)
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(classification)
	end
end

local function Path(self, ...)
	return (self.ClassificationIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ClassificationIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.ListTexture then
			element.ListTexture = textures
		end

		if not element.ListAtlas then
			element.ListAtlas = atlases
		end

		if element:IsObjectType('Texture') and not element:GetTexture() then
			element:SetTexture([[Interface\TARGETINGFRAME\Nameplates]])
		end

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		return true
	end
end

local function Disable(self)
	local element = self.ClassificationIndicator
	if element then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

ElvUF:AddElement('ClassificationIndicator', Path, Enable, Disable)
