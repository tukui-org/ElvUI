local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local random = random
local UnitExists = UnitExists
local UnitAffectingCombat = UnitAffectingCombat
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

function UF:Construct_RoleIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK')
	tex:Size(17)
	tex:Point('BOTTOM', frame.Health, 'BOTTOM', 0, 2)
	tex.Override = UF.UpdateRoleIcon
	frame:RegisterEvent('UNIT_CONNECTION', UF.UpdateRoleIcon)

	return tex
end

UF.RoleIconTextures = {
	TANK = E.Media.Textures.Tank,
	HEALER = E.Media.Textures.Healer,
	DAMAGER = E.Media.Textures.DPS
}

function UF:GetRoleIcon(frame)
	if frame.isForced then
		local rnd = random(1, 3)
		return (rnd == 1 and 'TANK') or (rnd == 2 and 'HEALER') or 'DAMAGER'
	else
		return E.allowRoles and UnitGroupRolesAssigned(frame.unit)
	end
end

function UF:UpdateRoleIcon()
	local lfdrole = self.GroupRoleIndicator
	if not self.db then return end

	local role = UF:GetRoleIcon(self)
	self.role = role -- set this here for only healer power

	local db = self.db.roleIcon
	if not db or not db.enable then
		lfdrole:Hide()
		return
	end

	local show = self.isForced or UnitExists(self.unit)
	if show and (not lfdrole.combatHide or not UnitAffectingCombat(self.unit)) and ((role == 'DAMAGER' and db.damager) or (role == 'HEALER' and db.healer) or (role == 'TANK' and db.tank)) then
		lfdrole:SetTexture(UF.RoleIconTextures[role])
		lfdrole:Show()
	else
		lfdrole:Hide()
	end
end

function UF:Configure_RoleIcon(frame)
	local lfdrole = frame.GroupRoleIndicator
	local db = frame.db and frame.db.roleIcon

	if db.enable then
		frame:EnableElement('GroupRoleIndicator')
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachTo)

		lfdrole.combatHide = db.combatHide

		lfdrole:ClearAllPoints()
		lfdrole:Point(db.position, attachPoint, db.position, db.xOffset, db.yOffset)
		lfdrole:Size(db.size)
	else
		frame:DisableElement('GroupRoleIndicator')
		lfdrole:Hide()
	end
end
