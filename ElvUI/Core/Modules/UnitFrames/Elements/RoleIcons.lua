local E, L, V, P, G = unpack(ElvUI)
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

function UF:GetRoleIcon(frame)
	if frame.isForced then
		local rnd = random(1, 3)
		return (rnd == 1 and 'TANK') or (rnd == 2 and 'HEALER') or 'DAMAGER'
	else
		return (E.Retail or E.Cata) and UnitGroupRolesAssigned(frame.unit)
	end
end

function UF:UpdateRoleIcon(event)
	local lfdrole = self.GroupRoleIndicator
	if not self.db then return end

	local role = UF:GetRoleIcon(self)
	self.role = role -- set this here for only healer power

	local db = self.db.roleIcon
	if not db or not db.enable then
		lfdrole:Hide()
		return
	end

	if (self.isForced or UnitIsConnected(self.unit)) and ((role == 'DAMAGER' and db.damager) or (role == 'HEALER' and db.healer) or (role == 'TANK' and db.tank)) then
		lfdrole:SetTexture(UF.RoleIconTextures[role])

		if not (event == 'PLAYER_REGEN_DISABLED' and db.combatHide) then
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
	local db = frame.db and frame.db.roleIcon

	if db.enable then
		frame:EnableElement('GroupRoleIndicator')
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachTo)

		role:ClearAllPoints()
		role:Point(db.position, attachPoint, db.position, db.xOffset, db.yOffset)
		role:Size(db.size)

		if db.combatHide then
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
