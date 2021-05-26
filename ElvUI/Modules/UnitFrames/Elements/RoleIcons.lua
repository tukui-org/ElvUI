local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local random = random
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsConnected = UnitIsConnected

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

function UF:UpdateRoleIcon(event)
	local lfdrole = self.GroupRoleIndicator
	if not self.db then return end
	local db = self.db.roleIcon

	if not db or not db.enable then
		lfdrole:Hide()
		return
	end

	local role = UnitGroupRolesAssigned(self.unit)
	if self.isForced and role == 'NONE' then
		local rnd = random(1, 3)
		role = rnd == 1 and 'TANK' or (rnd == 2 and 'HEALER' or (rnd == 3 and 'DAMAGER'))
	end

	local shouldHide = ((event == 'PLAYER_REGEN_DISABLED' and db.combatHide and true) or false)

	if (self.isForced or UnitIsConnected(self.unit)) and ((role == 'DAMAGER' and db.damager) or (role == 'HEALER' and db.healer) or (role == 'TANK' and db.tank)) then
		lfdrole:SetTexture(UF.RoleIconTextures[role])
		if not shouldHide then
			lfdrole:Show()
		else
			lfdrole:Hide()
		end
	else
		lfdrole:Hide()
	end
end

function UF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local db = frame.db

	if db.roleIcon.enable then
		frame:EnableElement('GroupRoleIndicator')
		local attachPoint = self:GetObjectAnchorPoint(frame, db.roleIcon.attachTo)

		role:ClearAllPoints()
		role:Point(db.roleIcon.position, attachPoint, db.roleIcon.position, db.roleIcon.xOffset, db.roleIcon.yOffset)
		role:Size(db.roleIcon.size)

		if db.roleIcon.combatHide then
			E:RegisterEventForObject('PLAYER_REGEN_ENABLED', frame, UF.UpdateRoleIcon)
			E:RegisterEventForObject('PLAYER_REGEN_DISABLED', frame, UF.UpdateRoleIcon)
		else
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', frame, UF.UpdateRoleIcon)
			E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', frame, UF.UpdateRoleIcon)
		end
	else
		frame:DisableElement('GroupRoleIndicator')
		role:Hide()
		--Unregister combat hide events
		E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', frame, UF.UpdateRoleIcon)
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', frame, UF.UpdateRoleIcon)
	end
end
