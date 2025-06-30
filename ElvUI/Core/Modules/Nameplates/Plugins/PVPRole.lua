local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local wipe = wipe
local next = next
local format = format

local UnitName = UnitName
local GetInstanceInfo = GetInstanceInfo
local GetBattlefieldScore = GetBattlefieldScore
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = GetNumBattlefieldScores

local UNKNOWN = UNKNOWN

local Healers, HealerSpecs = {}, {}
local Tanks, TankSpecs = {}, {}

NP.PVPRole = {
	Tanks = Tanks,
	Healers = Healers,
	HealerSpecs = HealerSpecs,
	TankSpecs = TankSpecs
}

local function Event(_, event, initLogin, isReload)
	if event == 'PLAYER_ENTERING_WORLD' then
		if initLogin or isReload then
			for _, specInfo in next, E.SpecInfoBySpecClass do
				if specInfo.role == 'HEALER' then
					HealerSpecs[specInfo.name] = true
				elseif specInfo.role == 'TANK' then
					TankSpecs[specInfo.name] = true
				end
			end
		else
			wipe(Healers)
			wipe(Tanks)
		end
	end

	if not E.private.nameplates.enable then return end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' or instanceType == 'arena' then
		local numOpps = GetNumArenaOpponentSpecs()
		if numOpps >= 1 then
			for i = 1, numOpps do
				local name, realm = UnitName(format('arena%d', i))
				if name and name ~= UNKNOWN then
					realm = (realm and realm ~= '') and E:ShortenRealm(realm)

					if realm then name = name..'-'..realm end

					local specID = GetArenaOpponentSpec(i)
					local specInfo = E.SpecInfoBySpecID[specID]
					local specName = specInfo and specInfo.name

					if HealerSpecs[specName] then
						Healers[name] = specName
					end

					if TankSpecs[specName] then
						Tanks[name] = specName
					end
				end
			end
		else
			for i = 1, GetNumBattlefieldScores() do
				local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, specName = GetBattlefieldScore(i)
				name = name and name ~= UNKNOWN and E:StripMyRealm(name)

				if name then
					if HealerSpecs[specName] then
						Healers[name] = specName
					elseif Healers[name] then
						Healers[name] = nil
					end

					if TankSpecs[specName] then
						Tanks[name] = specName
					elseif Tanks[name] then
						Tanks[name] = nil
					end
				end
			end
		end
	end
end

local function Update(self)
	local element, isShown = self.PVPRole

	if element.PreUpdate then
		element:PreUpdate()
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' or instanceType == 'arena' then
		local name, realm = UnitName(self.unit)
		realm = (realm and realm ~= '') and E:ShortenRealm(realm)
		if realm then name = name..'-'..realm end

		if Healers[name] and element.ShowHealers then
			element:SetTexture(element.HealerTexture)
			isShown = true
		elseif Tanks[name] and element.ShowTanks then
			element:SetTexture(element.TankTexture)
			isShown = true
		end
	end

	element:SetShown(isShown)

	if element.PostUpdate then
		return element:PostUpdate(instanceType)
	end
end

local function Path(self, ...)
	return (self.PVPRole.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PVPRole
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.HealerTexture then element.HealerTexture = E.Media.Textures.Healer end
		if not element.TankTexture then element.TankTexture = E.Media.Textures.Tank end

		self:RegisterEvent('UNIT_TARGET', Path)
		self:RegisterEvent('UNIT_NAME_UPDATE', Path)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.PVPRole
	if element then
		element:Hide()

		self:UnregisterEvent('UNIT_TARGET', Path)
		self:UnregisterEvent('UNIT_NAME_UPDATE', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('ARENA_OPPONENT_UPDATE')
frame:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', Event)

ElvUF:AddElement('PVPRole', Path, Enable, Disable)
