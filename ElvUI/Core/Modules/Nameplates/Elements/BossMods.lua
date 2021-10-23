local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local AB = E:GetModule('ActionBars')

local _G = _G
local wipe = wipe
local next = next
local pairs = pairs
local unpack = unpack
local GetTime = GetTime
local UnitGUID = UnitGUID
local CreateFrame = CreateFrame

NP.BossMods_ActiveUnitGUID = {}
NP.BossMods_TextureCache = {}

local allowHostile = false
function NP:BossMods_CreateIcon(element)
	element.index = not element.index and 1 or (element.index + 1)

	local button = CreateFrame('Button', element:GetName()..'Button'..element.index, element)
	button:EnableMouse(false)
	button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	local cooldown = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cooldown:SetReverse(true)
	cooldown:SetInside(button)
	cooldown.CooldownOverride = 'nameplates'
	E:RegisterCooldown(cooldown)

	local icon = button:CreateTexture(nil, 'ARTWORK')
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside()

	button.icon = icon
	button.cd = cooldown
	button.db = element.db

	return button
end

function NP:BossMods_GetIcon(plate, texture)
	local element, unused, avaiableIcon = plate.BossMods

	local activeButton = element.activeIcons[texture]
	if not activeButton then
		unused, avaiableIcon = next(element.unusedIcons)
		if unused then element.unusedIcons[unused] = nil end
	end

	local button = activeButton or avaiableIcon or NP:BossMods_CreateIcon(element)
	if not activeButton then
		element.activeIcons[texture] = button
	end

	return button
end

function NP:BossMods_PositionIcons(element)
	if not next(element.activeIcons) then return end

	local index = 1
	local anchor, inversed, growthX, growthY, width, height, cols, point, middle = UF:GetAuraPosition(element)

	element.currentRow = nil -- clear this for a new update

	for _, button in pairs(element.activeIcons) do
		UF:SetAuraPosition(element, button, index, anchor, inversed, growthX, growthY, width, height, cols, point, middle)

		button:Size(width, height)
		button:Show()

		AB:TrimIcon(button)

		index = index + 1
	end
end

function NP:BossMods_TrackIcons(track, unitGUID, texture, duration, desaturate, startTime)
	if track then
		NP.BossMods_TextureCache[texture] = true -- use this to easily populate boss mod style filters

		if not NP.BossMods_ActiveUnitGUID[unitGUID] then
			NP.BossMods_ActiveUnitGUID[unitGUID] = {}
		end

		local active = NP.BossMods_ActiveUnitGUID[unitGUID]
		if not active[texture] then
			active[texture] = {}
		end

		local activeTexture = active[texture]
		activeTexture.duration = duration
		activeTexture.desaturate = desaturate
		activeTexture.startTime = startTime
	else
		local active = NP.BossMods_ActiveUnitGUID[unitGUID]
		if active then
			if active[texture] then
				active[texture] = nil
			end

			if not next(active) then
				NP.BossMods_ActiveUnitGUID[unitGUID] = nil
			end
		end
	end
end

function NP:BossMods_ClearIcons()
	if not next(NP.BossMods_ActiveUnitGUID) then return end

	for unitGUID, textures in pairs(NP.BossMods_ActiveUnitGUID) do
		for texture in pairs(textures) do
			local plate = NP.PlateGUID[unitGUID]
			if plate then
				NP:BossMods_ClearIcon(plate, texture)
				NP:StyleFilterUpdate(plate, 'FAKE_BossModAuras')
			end
		end
	end

	wipe(NP.BossMods_ActiveUnitGUID)
end

function NP:BossMods_AddIcon(unitGUID, texture, duration, desaturate, skip)
	local active = NP.BossMods_ActiveUnitGUID[unitGUID]
	local activeTexture = active and active[texture]

	local pastTime = activeTexture and activeTexture.startTime
	local pastDuration = activeTexture and activeTexture.duration
	if pastTime and pastDuration and pastDuration ~= duration then
		pastTime = nil -- reset the cooldown timer if a new duration is given
	end

	local startTime = duration and (pastTime or GetTime()) or nil
	NP:BossMods_TrackIcons(true, unitGUID, texture, duration, desaturate, startTime)

	local plate = NP.PlateGUID[unitGUID]
	if not plate then return end

	local button = NP:BossMods_GetIcon(plate, texture)
	button.icon:SetDesaturated(desaturate)
	button.icon:SetTexture(texture)

	if duration then
		button.cd:SetCooldown(startTime, duration)
	else
		button.cd:Hide()
	end

	if desaturate then
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	else
		local color = _G.DebuffTypeColor.none
		button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
	end

	NP:BossMods_PositionIcons(plate.BossMods)

	if not skip then -- this will happen already during PostUpdateAllElements
		NP:StyleFilterUpdate(plate, 'FAKE_BossModAuras')
	end
end

function NP:BossMods_RemoveIcon(unitGUID, texture)
	NP:BossMods_TrackIcons(false, unitGUID, texture)

	local plate = NP.PlateGUID[unitGUID]
	if plate then
		NP:BossMods_ClearIcon(plate, texture)
		NP:BossMods_PositionIcons(plate.BossMods)
		NP:StyleFilterUpdate(plate, 'FAKE_BossModAuras')
	end
end

function NP:BossMods_ClearIcon(plate, texture)
	local element = plate.BossMods
	local button = element.activeIcons[texture]
	if not button then return end

	button:Hide()

	element.activeIcons[texture] = nil
	element.unusedIcons[texture] = button
end

function NP:BossMods_UpdateIcon(plate, removed)
	local unitGUID = plate.unitGUID
	local active = NP.BossMods_ActiveUnitGUID[unitGUID]

	if not active then
		local element = plate.BossMods
		if next(element.activeIcons) then
			for texture in pairs(element.activeIcons) do
				NP:BossMods_ClearIcon(plate, texture)
			end
		end

		return
	end

	local enabled = allowHostile and NP.db.bossMods.enable
	for texture, info in pairs(active) do
		if removed or not enabled then
			NP:BossMods_ClearIcon(plate, texture)
		elseif enabled then
			NP:BossMods_AddIcon(unitGUID, texture, info.duration, info.desaturate, true)
		end
	end
end

function NP:BossMods_AddIcon_DBM(isGUID, unit, texture, duration, desaturate)
	if not (allowHostile and NP.db.bossMods.enable) then return end

	local unitGUID = (isGUID and unit) or UnitGUID(unit)
	NP:BossMods_AddIcon(unitGUID, texture, duration, desaturate)
end

function NP:BossMods_RemoveIcon_DBM(isGUID, unit, texture)
	local unitGUID = (isGUID and unit) or UnitGUID(unit)
	NP:BossMods_RemoveIcon(unitGUID, texture)
end

function NP:BossMods_AddIcon_BW(_, unitGUID, texture, duration, desaturate)
	if not (allowHostile and NP.db.bossMods.enable) then return end

	NP:BossMods_AddIcon(unitGUID, texture, duration, desaturate)
end

function NP:BossMods_RemoveIcon_BW(_, unitGUID, texture)
	NP:BossMods_RemoveIcon(unitGUID, texture)
end

function NP:BossMods_DisableHostile()
	NP:BossMods_ClearIcons()

	allowHostile = false
end

function NP:BossMods_EnableHostile()
	allowHostile = true
end

function NP:DBM_SupportedNPMod()
	return _G.DBM.Options.UseNameplateHandoff
end

function NP:BossMods_RegisterCallbacks()
	local DBM = _G.DBM
	if DBM and DBM.RegisterCallback and DBM.Nameplate then
		DBM.Nameplate.SupportedNPMod = NP.DBM_SupportedNPMod

		DBM:RegisterCallback('BossMod_ShowNameplateAura',NP.BossMods_AddIcon_DBM)
		DBM:RegisterCallback('BossMod_HideNameplateAura',NP.BossMods_RemoveIcon_DBM)
		DBM:RegisterCallback('BossMod_EnableHostileNameplates',NP.BossMods_EnableHostile)
		DBM:RegisterCallback('BossMod_DisableHostileNameplates',NP.BossMods_DisableHostile)
	end

	local BWL = _G.BigWigsLoader
	if BWL and BWL.RegisterMessage then
		BWL.RegisterMessage(NP,'BigWigs_AddNameplateIcon',NP.BossMods_AddIcon_BW)
		BWL.RegisterMessage(NP,'BigWigs_RemoveNameplateIcon',NP.BossMods_RemoveIcon_BW)
		BWL.RegisterMessage(NP,'BigWigs_EnableHostileNameplates',NP.BossMods_EnableHostile)
		BWL.RegisterMessage(NP,'BigWigs_DisableHostileNameplates',NP.BossMods_DisableHostile)
	end
end

function NP:Update_BossMods(plate)
	local db = NP.db.bossMods
	if not db.enable then return end

	local anchor = db.anchorPoint
	local inverse = E.InversePoints[anchor]

	local element = plate.BossMods
	element:ClearAllPoints()
	element:SetPoint(inverse or 'TOPRIGHT', plate, anchor or 'TOPRIGHT', db.xOffset, db.yOffset)
	element:SetSize(plate.width or 150, db.size)

	element.db = db
	element.spacing = db.spacing
	element.initialAnchor = inverse
	element.growthY = UF.MatchGrowthY[anchor] or db.growthY
	element.growthX = UF.MatchGrowthX[anchor] or db.growthX
	element.size = db.size + (db.spacing or 0)
	element.height = not db.keepSizeRatio and db.height
	element.rows = {}
end

function NP:Construct_BossMods(nameplate)
	local element = CreateFrame('Frame', '$parentBossMods', nameplate)

	element.activeIcons = {}
	element.unusedIcons = {}

	return element
end
