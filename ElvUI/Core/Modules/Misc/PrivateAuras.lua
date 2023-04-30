local E, L, V, P, G = unpack(ElvUI)
local PA = E:GetModule('PrivateAuras')

local _G = _G
local C_UnitAuras = C_UnitAuras
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
local SetPrivateWarningTextAnchor = C_UnitAuras.SetPrivateWarningTextAnchor

local warningAnchor = {
	relativePoint = 'TOP',
	point = 'TOP',
	offsetX = 0,
	offsetY = 0,
}

local tempAnchor = {
	unitToken = 'player',
	parent = _G.UIParent,
	auraIndex = 1,

	showCountdownFrame = true,
	showCountdownNumbers = true,

	iconInfo = {
		iconWidth = 32,
		iconHeight = 32,
		iconAnchor = {
			relativeTo = _G.UIParent,
			point = 'CENTER',
			relativePoint = 'CENTER',
			offsetX = 0,
			offsetY = 0,
		},
	},

	durationAnchor = {
		relativeTo = _G.UIParent,
		point = 'BOTTOM',
		relativePoint = 'BOTTOM',
		offsetX = 0,
		offsetY = 0,
	}
}

function PA:CreateAnchor(parent, unit, index, db)
	if not unit then unit = parent.unit end

	-- clear any old ones, respawn the new ones
	local anchorID = parent.auraAnchors[index]
	if anchorID then
		RemovePrivateAuraAnchor(anchorID)
	end

	-- update all possible entries to this as the table is dirty
	tempAnchor.unitToken = unit
	tempAnchor.parent = parent
	tempAnchor.auraIndex = index

	tempAnchor.showCountdownFrame = db.frameCooldown
	tempAnchor.showCountdownNumbers = db.auraCooldown

	local iconSize = db.icon.size
	if not iconSize then iconSize = 32 end

	local iconPoint = db.icon.point
	if index == 1 or not iconPoint then iconPoint = 'CENTER' end

	local durationPoint = db.duration.point
	if index == 1 or not durationPoint then durationPoint = 'CENTER' end

	local iconX, iconY, durationX, durationY = PA:CalculateDirection(db, index, (index - 1) * iconSize)

	local icon = tempAnchor.iconInfo
	icon.iconWidth = iconSize
	icon.iconHeight = iconSize
	icon.iconAnchor.relativeTo = parent
	icon.iconAnchor.point = iconPoint
	icon.iconAnchor.relativePoint = iconPoint
	icon.iconAnchor.offsetX = iconX
	icon.iconAnchor.offsetY = iconY

	local duration = tempAnchor.durationAnchor
	duration.relativeTo = parent
	duration.point = E.InversePoints[durationPoint]
	duration.relativePoint = durationPoint
	duration.offsetX = durationX
	duration.offsetY = durationY

	return AddPrivateAuraAnchor(tempAnchor)
end

function PA:CalculateDirection(db, index, size)
	if index == 1 then
		return 0, 0, 0, 0
	else
		local dir = db.icon.direction
		local duraX, duraY = db.duration.offsetX or 0, db.duration.offsetY or 0
		local iconX = (dir == 'LEFT' or dir == 'RIGHT') and db.icon.offset or 0
		local iconY = (dir == 'UP' or dir == 'DOWN') and db.icon.offset or 0

		if dir == 'LEFT' then
			return -(size + iconX), -iconY, -(size + duraX), -duraY
		elseif dir == 'RIGHT' then
			return (size + iconX), iconY, (size + duraX), duraY
		elseif dir == 'DOWN' then
			return -iconX, -(size + iconY), -duraX, -(size + duraY)
		else
			return iconX, (size + iconY), duraX, (size + duraY)
		end
	end
end

function PA:SetupPrivateAuras(db, parent, unit)
	if not db then db = E.db.general.privateAuras end
	if not parent then parent = _G.UIParent end

	if not parent.auraAnchors then
		parent.auraAnchors = {}
	end

	for i = 1, db.icon.amount do
		parent.auraAnchors[i] = PA:CreateAnchor(parent, unit or 'player', i, db)
	end
end

function PA:PlayerPrivateAuras()
	if PA.auras.auraAnchors then
		for _, anchorID in pairs(PA.auras.auraAnchors) do
			RemovePrivateAuraAnchor(anchorID)
		end
	end

	local db = E.db.general.privateAuras
	PA:SetupPrivateAuras(nil, PA.auras, 'player')
	PA.auras:Size(db.icon.size)
end

function PA:WarningText_Reposition(_, anchor)
	if not anchor then
		anchor = _G.PrivateRaidBossEmoteFrameAnchor
		warningAnchor.relativeTo = anchor.mover or _G.UIParent
		SetPrivateWarningTextAnchor(anchor, warningAnchor)
	elseif anchor ~= self.mover then
		self:ClearAllPoints()
		self:Point('TOP', self.mover)
	end
end

function PA:WarningText_Reparent(parent)
	if parent ~= _G.UIParent then
		self:SetParent(_G.UIParent)
	end

	local _, anchor = self:GetPoint()
	if anchor ~= self.mover then
		PA:WarningText_Reposition()
	end
end

function PA:Initialize()
	PA.auras = CreateFrame('Frame', 'ElvUIPrivateAuras', E.UIParent)
	PA.auras:Point('CENTER', _G.UIParent)
	PA.auras:SetSize(32, 32)
	E:CreateMover(PA.auras, 'PrivateAurasMover', L["Private Auras"])
	PA:PlayerPrivateAuras()

	local warningText = _G.PrivateRaidBossEmoteFrameAnchor
	if warningText then
		E:CreateMover(warningText, 'PrivateRaidWarningMover', L["Private Raid Warning"])

		hooksecurefunc(C_UnitAuras, 'SetPrivateWarningTextAnchor', PA.WarningText_Reposition)
		hooksecurefunc(warningText, 'SetPoint', PA.WarningText_Reposition)
		hooksecurefunc(warningText, 'SetParent', PA.WarningText_Reparent)
	end
end

E:RegisterModule(PA:GetName())
