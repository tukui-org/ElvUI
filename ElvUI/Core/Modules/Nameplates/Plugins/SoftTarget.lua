local E, L, V, P, G = unpack(ElvUI)
local ElvUF = E.oUF

local GetCVarBool = GetCVarBool
local UnitIsUnit = UnitIsUnit
local SetUnitCursorTexture = SetUnitCursorTexture

local function Update(self)
	local element = self.SoftTarget
	if element.PreUpdate then
		element:PreUpdate()
	end

	local doEnemyIcon = GetCVarBool('SoftTargetIconEnemy') and UnitIsUnit(self.unit, 'softenemy')
	local doFriendIcon = GetCVarBool('SoftTargetIconFriend') and UnitIsUnit(self.unit, 'softfriend')
	local doInteractIcon = GetCVarBool('SoftTargetIconInteract') and UnitIsUnit(self.unit, 'softinteract')

	local hasCursorTexture = (doEnemyIcon or doFriendIcon or doInteractIcon) and SetUnitCursorTexture(element.icon, self.unit) and true

	element:SetShown(hasCursorTexture)

	if element.PostUpdate then
		return element:PostUpdate(self.unit)
	end
end

local function Path(self, ...)
	return (self.SoftTarget.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.SoftTarget
	if element and E.Retail then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element.icon and element.icon:IsObjectType('Texture') and not element.icon:GetTexture() then
			element.icon:SetTexture('Interface/TargetingFrame/UI-RaidTargetingIcons')
		end

		self:RegisterEvent('PLAYER_SOFT_INTERACT_CHANGED', Path, true)
		self:RegisterEvent('PLAYER_SOFT_ENEMY_CHANGED', Path, true)
		self:RegisterEvent('PLAYER_SOFT_FRIEND_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.SoftTarget
	if element and E.Retail then
		element:Hide()

		self:UnregisterEvent('PLAYER_SOFT_INTERACT_CHANGED', Path)
		self:UnregisterEvent('PLAYER_SOFT_ENEMY_CHANGED', Path)
		self:UnregisterEvent('PLAYER_SOFT_FRIEND_CHANGED', Path)
	end
end

ElvUF:AddElement('SoftTarget', Path, Enable, Disable)
