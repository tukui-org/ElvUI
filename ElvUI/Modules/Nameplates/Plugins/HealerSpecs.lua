local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

-- Lua functions
local gsub = gsub
local format = format
local wipe = wipe
-- WoW API / Variables
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetBattlefieldScore = GetBattlefieldScore
local GetInstanceInfo = GetInstanceInfo
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitName = UnitName
local UNKNOWN = UNKNOWN

local healerSpecIDs = {
	65,		--Paladin Holy
	105,	--Druid Restoration
	256,	--Priest Discipline
	257,	--Priest Holy
	264,	--Shaman Restoration
	270,	--Monk Mistweaver
}

local Healers, HealerSpecs = {}, {}

for _, specID in pairs(healerSpecIDs) do
	local _, name = GetSpecializationInfoByID(specID)
	if name and not HealerSpecs[name] then
		HealerSpecs[name] = true
	end
end

local function WipeTable()
	wipe(Healers)
end

local function Event()
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' or instanceType == 'arena' then
		local numOpps = GetNumArenaOpponentSpecs()

		if (numOpps == 0) then
			local name, _, talentSpec
			for i = 1, GetNumBattlefieldScores() do
				name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
				if name then
					name = gsub(name,'%-'..gsub(E.myrealm,'[%s%-]',''),'') --[[ name = match(name,"([^%-]+).*") ]]
					if name and HealerSpecs[talentSpec] then
						Healers[name] = talentSpec
					elseif name and Healers[name] then
						Healers[name] = nil;
					end
				end
			end
		elseif (numOpps >= 1) then
			for i = 1, numOpps do
				local name, realm = UnitName(format('arena%d', i))
				if name and name ~= UNKNOWN then
					realm = (realm and realm ~= '') and gsub(realm,'[%s%-]','')
					if realm then name = name.."-"..realm end

					local s = GetArenaOpponentSpec(i)
					local _, talentSpec = nil, UNKNOWN

					if s and s > 0 then
						_, talentSpec = GetSpecializationInfoByID(s)
					end

					if talentSpec and talentSpec ~= UNKNOWN and HealerSpecs[talentSpec] then
						Healers[name] = talentSpec
					end
				end
			end
		end
	end
end

local function Update(self)
	local element = self.HealerSpecs

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' or instanceType == 'arena' then
		local name, realm = UnitName(self.unit)
		realm = (realm and realm ~= '') and gsub(realm,'[%s%-]','')
		if realm then name = name.."-"..realm end

		if Healers[name] then
			element:Show()
		else
			element:Hide()
		end
	end

	if (element.PostUpdate) then
		return element:PostUpdate(instanceType)
	end
end

local function Path(self, ...)
	return (self.HealerSpecs.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HealerSpecs
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if (element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture(E.Media.Textures.Healer)
		end

		self:RegisterEvent("UNIT_TARGET", Path)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path, true)
		self:RegisterEvent("UNIT_NAME_UPDATE", Path)
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Event, true)
		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", Event, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", WipeTable, true)

		return true
	end
end

local function Disable(self)
	local element = self.HealerSpecs
	if (element) then
		element:Hide()

		self:UnregisterEvent("UNIT_NAME_UPDATE", Path)
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Event)
		self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE", Event)
		self:UnregisterEvent("UNIT_TARGET", Path)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", WipeTable)
	end
end

oUF:AddElement('HealerSpecs', Path, Enable, Disable)
