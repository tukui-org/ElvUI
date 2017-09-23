local MAJOR, MINOR = "LibArtifactData-1.0", 16

assert(_G.LibStub, MAJOR .. " requires LibStub")
local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or _G.LibStub("CallbackHandler-1.0"):New(lib)

local Debug = function() end
if _G.AdiDebug then
	Debug = _G.AdiDebug:Embed({}, MAJOR)
end

-- local store
local artifacts = {}
local equippedID, viewedID, activeID
artifacts.knowledgeLevel = 0
artifacts.knowledgeMultiplier = 1

-- constants
local _G                       = _G
local BACKPACK_CONTAINER       = _G.BACKPACK_CONTAINER
local BANK_CONTAINER           = _G.BANK_CONTAINER
local INVSLOT_MAINHAND         = _G.INVSLOT_MAINHAND
local LE_ITEM_CLASS_ARMOR      = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON     = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT
local NUM_BAG_SLOTS            = _G.NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS         = _G.NUM_BANKBAGSLOTS

-- blizzard api
local aUI                              = _G.C_ArtifactUI
local Clear                            = aUI.Clear
local GetArtifactInfo                  = aUI.GetArtifactInfo
local GetArtifactKnowledgeLevel        = aUI.GetArtifactKnowledgeLevel
local GetArtifactKnowledgeMultiplier   = aUI.GetArtifactKnowledgeMultiplier
local GetContainerItemInfo             = _G.GetContainerItemInfo
local GetContainerNumSlots             = _G.GetContainerNumSlots
local GetCostForPointAtRank            = aUI.GetCostForPointAtRank
local GetCurrencyInfo                  = _G.GetCurrencyInfo
local GetEquippedArtifactInfo          = aUI.GetEquippedArtifactInfo
local GetInventoryItemEquippedUnusable = _G.GetInventoryItemEquippedUnusable
local GetItemInfo                      = _G.GetItemInfo
local GetNumObtainedArtifacts          = aUI.GetNumObtainedArtifacts
local GetNumPurchasableTraits          = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local GetNumRelicSlots                 = aUI.GetNumRelicSlots
local GetPowerInfo                     = aUI.GetPowerInfo
local GetPowers                        = aUI.GetPowers
local GetRelicInfo                     = aUI.GetRelicInfo
local GetRelicLockedReason             = aUI.GetRelicLockedReason
local GetSpellInfo                     = _G.GetSpellInfo
local HasArtifactEquipped              = _G.HasArtifactEquipped
local IsAtForge                        = aUI.IsAtForge
local IsViewedArtifactEquipped         = aUI.IsViewedArtifactEquipped
local SocketContainerItem              = _G.SocketContainerItem
local SocketInventoryItem              = _G.SocketInventoryItem

-- lua api
local select   = _G.select
local strmatch = _G.string.match
local tonumber = _G.tonumber

local private = {} -- private space for the event handlers

lib.frame = lib.frame or _G.CreateFrame("Frame")
local frame = lib.frame
frame:UnregisterAllEvents() -- deactivate old versions
frame:SetScript("OnEvent", function(_, event, ...) private[event](event, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function CopyTable(tbl)
	if not tbl then return {} end
	local copy = {};
	for k, v in pairs(tbl) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function PrepareForScan()
	frame:UnregisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:UnregisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		ArtifactFrame:UnregisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

local function RestoreStateAfterScan()
	frame:RegisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:RegisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		Clear()
		ArtifactFrame:RegisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:RegisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:RegisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

local function InformEquippedArtifactChanged(artifactID)
	if artifactID ~= equippedID then
		Debug("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		lib.callbacks:Fire("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		equippedID = artifactID
	end
end

local function InformActiveArtifactChanged(artifactID)
	local oldActiveID = activeID
	if artifactID and not GetInventoryItemEquippedUnusable("player", INVSLOT_MAINHAND) then
		activeID = artifactID
	else
		activeID = nil
	end
	if oldActiveID ~= activeID then
		Debug("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
		lib.callbacks:Fire("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
	end
end

local function InformTraitsChanged(artifactID)
	Debug("ARTIFACT_TRAITS_CHANGED", artifactID, artifacts[artifactID].traits)
	lib.callbacks:Fire("ARTIFACT_TRAITS_CHANGED", artifactID, CopyTable(artifacts[artifactID].traits))
end

local function StoreArtifact(itemID, altItemID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable, power, maxPower, traits, relics, tier)
	if not artifacts[itemID] then
		artifacts[itemID] = {
			altItemID = altItemID,
			name = name,
			icon = icon,
			unspentPower = unspentPower,
			numRanksPurchased = numRanksPurchased,
			numRanksPurchasable = numRanksPurchasable,
			power = power,
			maxPower = maxPower,
			powerForNextRank = maxPower - power,
			traits = traits,
			relics = relics,
			tier = tier,
		}
		Debug("ARTIFACT_ADDED", itemID, name)
		lib.callbacks:Fire("ARTIFACT_ADDED", itemID)
	else
		local current = artifacts[itemID]
		current.unspentPower = unspentPower
		current.numRanksPurchased = numRanksPurchased -- numRanksPurchased does not include bonus traits from relics
		current.numRanksPurchasable = numRanksPurchasable
		current.power = power
		current.maxPower = maxPower
		current.powerForNextRank = maxPower - power
		current.traits = traits
		current.relics = relics
		current.tier = tier
	end
end

local function ScanTraits(artifactID)
	local traits = {}
	local powers = GetPowers()

	for i = 1, #powers do
		local traitID = powers[i]
		local info = GetPowerInfo(traitID)
		local spellID = info.spellID
		if (info.currentRank) > 0 then
			local name, _, icon = GetSpellInfo(spellID)
			traits[#traits + 1] = {
				traitID = traitID,
				spellID = spellID,
				name = name,
				icon = icon,
				currentRank = info.currentRank,
				maxRank = info.maxRank,
				bonusRanks = info.bonusRanks,
				isGold = info.isGoldMedal,
				isStart = info.isStart,
				isFinal = info.isFinal,
				maxRanksFromTier = info.numMaxRankBonusFromTier,
				tier = info.tier,
			}
		end
	end

	if artifactID then
		artifacts[artifactID].traits = traits
	end

	return traits
end

local function ScanRelics(artifactID)
	local relics = {}
	for i = 1, GetNumRelicSlots() do
		local isLocked, name, icon, slotType, link, itemID = GetRelicLockedReason(i) and true or false
		if not isLocked then
			name, icon, slotType, link = GetRelicInfo(i)
			if link then
				itemID = strmatch(link, "item:(%d+):")
			end
		end
		relics[i] = { type = slotType, isLocked = isLocked, name = name, icon = icon, itemID = itemID, link = link }
	end

	if artifactID then
		artifacts[artifactID].relics = relics
	end

	return relics
end

local function GetArtifactKnowledge()
	if viewedID == 133755 then return end -- exclude Underlight Angler
	local lvl = GetArtifactKnowledgeLevel()
	local mult = GetArtifactKnowledgeMultiplier()
	if artifacts.knowledgeMultiplier ~= mult or artifacts.knowledgeLevel ~= lvl then
		artifacts.knowledgeLevel = lvl
		artifacts.knowledgeMultiplier = mult
		Debug("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
		lib.callbacks:Fire("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
	end
end

local function GetViewedArtifactData()
	local itemID, altItemID, name, icon, unspentPower, numRanksPurchased, _, _, _, _, _, _, tier = GetArtifactInfo()
	if not itemID then
		Debug("|cffff0000ERROR:|r", "GetArtifactInfo() returned nil.")
		return
	end
	viewedID = itemID
	Debug("GetViewedArtifactData", name, itemID)
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower, tier)
	local traits = ScanTraits()
	local relics = ScanRelics()
	StoreArtifact(itemID, altItemID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable, power, maxPower, traits, relics, tier)

	if IsViewedArtifactEquipped() then
		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end

	GetArtifactKnowledge()
end

local function ScanEquipped()
	if HasArtifactEquipped() then
		PrepareForScan()
		SocketInventoryItem(INVSLOT_MAINHAND)
		GetViewedArtifactData()
		Clear()
		RestoreStateAfterScan()
		frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	end
end

local function ScanContainer(container, numObtained)
	for slot = 1, GetContainerNumSlots(container) do
		local _, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
		if quality == LE_ITEM_QUALITY_ARTIFACT then
			local classID = select(12, GetItemInfo(itemID))
			if classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR then
				Debug("ARTIFACT_FOUND", "in", container, slot)
				SocketContainerItem(container, slot)
				GetViewedArtifactData()
				Clear()
				if numObtained <= lib:GetNumObtainedArtifacts() then break end
			end
		end
	end
end

local function IterateContainers(from, to, numObtained)
	PrepareForScan()
	for container = from, to do
		ScanContainer(container, numObtained)
		if numObtained <= lib:GetNumObtainedArtifacts() then break end
	end
	RestoreStateAfterScan()
end

local function ScanBank(numObtained)
	if numObtained > lib:GetNumObtainedArtifacts() then
		PrepareForScan()
		ScanContainer(BANK_CONTAINER, numObtained)
		RestoreStateAfterScan()
	end
	if numObtained > lib:GetNumObtainedArtifacts() then
		IterateContainers(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, numObtained)
	end
end

function private.PLAYER_ENTERING_WORLD(event)
	frame:UnregisterEvent(event)
	frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	frame:RegisterEvent("BAG_UPDATE_DELAYED")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	frame:RegisterEvent("ARTIFACT_CLOSE")
	frame:RegisterEvent("ARTIFACT_XP_UPDATE")
	frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
end

-- bagged artifact data becomes obtainable
function private.BAG_UPDATE_DELAYED(event)
	local numObtained = GetNumObtainedArtifacts()
	if numObtained <= 0 then return end

	-- prevent double-scanning if UNIT_INVENTORY_CHANGED fired first
	-- UNIT_INVENTORY_CHANGED does not fire after /reload
	if not equippedID and HasArtifactEquipped() then
		ScanEquipped()
	end

	if numObtained > lib:GetNumObtainedArtifacts() then
		IterateContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS, numObtained)
	end

	frame:UnregisterEvent(event)
end

-- equipped artifact data becomes obtainable
function private.UNIT_INVENTORY_CHANGED(event)
	ScanEquipped(event)
end

function private.ARTIFACT_CLOSE()
	viewedID = nil
end

function private.ARTIFACT_UPDATE(event, newItem)
	Debug(event, newItem)
	if newItem then
		GetViewedArtifactData()
	else
		if not GetNumRelicSlots() then
			Debug("|cffff0000ERROR:|r", "artifact data unobtainable.")
			return
		end
		local newRelics = ScanRelics()
		local oldRelics = artifacts[viewedID].relics

		for i = 1, #newRelics do
			local newRelic = newRelics[i]
			-- TODO: test third slot unlock
			if newRelic.isLocked ~= oldRelics[i].isLocked or newRelic.itemID ~= oldRelics[i].itemID then
				oldRelics[i] = newRelic
				Debug("ARTIFACT_RELIC_CHANGED", viewedID, i, newRelic)
				lib.callbacks:Fire("ARTIFACT_RELIC_CHANGED", viewedID, i, CopyTable(newRelic))
				-- if a relic changed, so did the traits
				ScanTraits(viewedID)
				InformTraitsChanged(viewedID)
				break
			end
		end
	end
end

function private.ARTIFACT_XP_UPDATE(event)
	-- at the forge the player can purchase traits even for unequipped artifacts
	local GetInfo = IsAtForge() and GetArtifactInfo or GetEquippedArtifactInfo
	local itemID, _, _, _, unspentPower, numRanksPurchased, _, _, _, _, _, _, tier = GetInfo() -- NOTE: 7.2 compat
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower, tier)

	local artifact = artifacts[itemID]
	if not artifact then
		return lib.ForceUpdate()
	end

	local diff = unspentPower - artifact.unspentPower

	if numRanksPurchased ~= artifact.numRanksPurchased then
		-- both learning traits and artifact respec trigger ARTIFACT_XP_UPDATE
		-- however respec has a positive diff and learning traits has a negative one
		ScanTraits(itemID)
		InformTraitsChanged(itemID)
	end

	if diff ~= 0 then
		artifact.unspentPower = unspentPower
		artifact.power = power
		artifact.maxPower = maxPower
		artifact.numRanksPurchased = numRanksPurchased
		artifact.numRanksPurchasable = numRanksPurchasable
		artifact.powerForNextRank = maxPower - power
		Debug(event, itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
		lib.callbacks:Fire("ARTIFACT_POWER_CHANGED", itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
	end
end

function private.BANKFRAME_OPENED()
	local numObtained = GetNumObtainedArtifacts()
	if numObtained > lib:GetNumObtainedArtifacts() then
		ScanBank(numObtained)
	end
end

function private.CURRENCY_DISPLAY_UPDATE(event)
	local _, lvl = GetCurrencyInfo(1171)
	if lvl ~= artifacts.knowledgeLevel then
		artifacts.knowledgeLevel = lvl
		Debug("ARTIFACT_DATA_MISSING", event, lvl)
		lib.callbacks:Fire("ARTIFACT_DATA_MISSING", "knowledge", lvl)
	end
end

function private.PLAYER_EQUIPMENT_CHANGED(event, slot)
	if slot == INVSLOT_MAINHAND then
		local itemID = GetEquippedArtifactInfo()

		if itemID and not artifacts[itemID] then
			ScanEquipped(event)
		end

		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end
end

-- needed in case the game fails to switch artifacts
function private.PLAYER_SPECIALIZATION_CHANGED(event)
	local itemID = GetEquippedArtifactInfo()
	Debug(event, itemID)
	InformActiveArtifactChanged(itemID)
end

function lib.GetActiveArtifactID()
	return activeID
end

function lib.GetArtifactInfo(_, artifactID)
	artifactID = artifactID or equippedID
	return artifactID, CopyTable(artifacts[artifactID])
end

function lib.GetAllArtifactsInfo()
	return CopyTable(artifacts)
end

function lib.GetNumObtainedArtifacts()
	local numArtifacts = 0
	for artifact in pairs(artifacts) do
		if tonumber(artifact) then
			numArtifacts = numArtifacts + 1
		end
	end

	return numArtifacts
end

function lib.GetArtifactTraits(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, CopyTable(data.traits)
		end
	end
end

function lib.GetArtifactRelics(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, CopyTable(data.relics)
		end
	end
end

function lib.GetArtifactPower(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, data.unspentPower, data.power, data.maxPower, data.powerForNextRank, data.numRanksPurchased, data.numRanksPurchasable
		end
	end
end

function lib.GetArtifactKnowledge()
	return artifacts.knowledgeLevel, artifacts.knowledgeMultiplier
end

function lib.GetAcquiredArtifactPower(_, artifactID)
	local total = 0

	if artifactID then
		local data = artifacts[artifactID]
		total = total + data.unspentPower
		local rank = 1
		while rank < data.numRanksPurchased do
			total = total + GetCostForPointAtRank(rank, data.tier)
			rank = rank + 1
		end

		return total
	end

	for itemID, data in pairs(artifacts) do
		if tonumber(itemID) then
			total = total + data.unspentPower
			local rank = 1
			while rank < data.numRanksPurchased do
				total = total + GetCostForPointAtRank(rank, data.tier)
				rank = rank + 1
			end
		end
	end

	return total
end

function lib.ForceUpdate()
	if _G.ArtifactFrame and _G.ArtifactFrame:IsShown() then
		Debug("ForceUpdate", "aborted because ArtifactFrame is open.")
		return
	end
	local numObtained = GetNumObtainedArtifacts()
	if numObtained > 0 then
		ScanEquipped("FORCE_UPDATE")
		IterateContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS, numObtained)
	end
end
