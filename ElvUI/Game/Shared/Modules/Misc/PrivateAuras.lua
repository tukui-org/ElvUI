local E, L, V, P, G = unpack(ElvUI)
local PA = E:GetModule('PrivateAuras')

local _G = _G
local next = next
local format = format
local hooksecurefunc = hooksecurefunc

local C_UnitAuras = C_UnitAuras
local CreateFrame = CreateFrame
local CopyTable = CopyTable
local UIParent = UIParent

local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
local SetPrivateWarningTextAnchor = C_UnitAuras.SetPrivateWarningTextAnchor

local warningAnchor = {
	relativeTo = nil, -- dynamically added in RaidWarning_Reposition
	relativePoint = 'TOP',
	point = 'TOP',
	offsetX = 0,
	offsetY = 0,
}

local defaults = {
	durationAnchor = {
		relativeTo = nil, -- dynamically added in CreateAnchor
		point = 'BOTTOM',
		relativePoint = 'BOTTOM',
		offsetX = 0,
		offsetY = 0,
	},
	iconAnchor = {
		relativeTo = nil, -- dynamically added in CreateAnchor
		point = 'CENTER',
		relativePoint = 'CENTER',
		offsetX = 0,
		offsetY = 0
	},
	iconInfo = {
		borderScale = 1,
		iconWidth = 32,
		iconHeight = 32,
		iconAnchor = nil -- added on creation
	},
	anchor = {
		unitToken = 'player',
		auraIndex = 1,
		showCountdownFrame = true,
		showCountdownNumbers = true,
		parent = nil, -- dynamically added in CreateAnchor
		iconInfo = nil, -- added on creation
		durationAnchor = nil, -- added on creation
	}
}

function PA:CreateAnchor(aura, parent, unit, index, db)
	if not unit then unit = parent.unit end

	-- clear any old ones, respawn the new ones
	local previousAura = parent.auraIcons[index]
	if previousAura then
		PA:RemoveAura(previousAura)
	end

	local borderScale = db.borderScale
	if not borderScale then borderScale = 1 end

	local iconSize = db.icon.size
	if not iconSize then iconSize = 32 end

	local iconPoint = db.icon.point
	if not iconPoint then iconPoint = 'CENTER' end

	local durationPoint = db.duration.point
	if not durationPoint then durationPoint = 'CENTER' end

	-- update all possible entries to this as the table is dirty
	local data = aura.data
	if not data then
		data = CopyTable(defaults.anchor)
		aura.data = data
	end

	data.parent = aura
	data.unitToken = unit
	data.auraIndex = index

	data.showCountdownFrame = db.countdownFrame
	data.showCountdownNumbers = db.countdownNumbers

	local icon = data.iconInfo
	if not icon then
		icon = CopyTable(defaults.iconInfo)
		data.iconInfo = icon
	end

	icon.borderScale = borderScale
	icon.iconWidth = iconSize
	icon.iconHeight = iconSize

	local anchor = icon.iconAnchor
	if not anchor then
		anchor = CopyTable(defaults.iconAnchor)
		icon.iconAnchor = anchor
	end

	anchor.relativeTo = aura
	anchor.point = iconPoint
	anchor.relativePoint = iconPoint
	anchor.offsetX = 0
	anchor.offsetY = 0

	local duration = data.durationAnchor
	if db.duration.enable then
		if not duration then
			duration = CopyTable(defaults.durationAnchor)
			data.durationAnchor = duration
		end

		duration.relativeTo = aura
		duration.point = E.InversePoints[durationPoint]
		duration.relativePoint = durationPoint
		duration.offsetX = db.duration.offsetX
		duration.offsetY = db.duration.offsetY
	elseif duration then
		data.durationAnchor = nil
	end

	return AddPrivateAuraAnchor(data)
end

function PA:RemoveAura(aura)
	if aura.anchorID then
		RemovePrivateAuraAnchor(aura.anchorID)
		aura.anchorID = nil
	end
end

function PA:RemoveAuras(parent)
	if parent.auraIcons then
		for _, aura in next, parent.auraIcons do
			PA:RemoveAura(aura)
		end
	end
end

function PA:CreateAura(parent, unit, index, db)
	local aura = parent.auraIcons[index]
	if not aura then
		aura = CreateFrame('Frame', format('%s%d', parent:GetName(), index), parent)
	end

	aura:ClearAllPoints()

	if index == 1 then
		aura:Point('CENTER', parent, 0, 0)
	else
		local offsetX, offsetY = 0, 0
		if db.icon.point == 'RIGHT' then
			offsetX = db.icon.offset
		elseif db.icon.point == 'LEFT' then
			offsetX = -db.icon.offset
		elseif db.icon.point == 'TOP' then
			offsetY = db.icon.offset
		else
			offsetY = -db.icon.offset
		end

		aura:Point(E.InversePoints[db.icon.point], parent.auraIcons[index-1], db.icon.point, offsetX, offsetY)
	end

	aura:Size(db.icon.size)

	aura.anchorID = PA:CreateAnchor(aura, parent, unit or 'player', index, db)

	return aura
end

function PA:SetupPrivateAuras(db, parent, unit)
	if not db then db = E.db.general.privateAuras end
	if not parent then parent = UIParent end

	if not parent.auraIcons then
		parent.auraIcons = {}
	end

	for i = 1, db.icon.amount do
		parent.auraIcons[i] = PA:CreateAura(parent, unit or 'player', i, db)
	end
end

function PA:Update()
	PA:RemoveAuras(PA.Auras)

	if E.db.general.privateAuras.enable then
		PA.Auras:Size(E.db.general.privateAuras.icon.size)

		PA:SetupPrivateAuras(nil, PA.Auras, 'player')

		E:EnableMover(PA.Auras.mover.name)
	else
		E:DisableMover(PA.Auras.mover.name)
	end
end

function PA:Update_RaidWarning()
	PA:RaidWarning_Rescale()
	PA.RaidWarning_Reparent(_G.PrivateRaidBossEmoteFrameAnchor)
end

function PA:RaidWarning_Rescale()
	if not PA.RaidWarning then return end

	local scale = E.db.general.privateRaidWarning.scale or 1
	PA.RaidWarning:SetScale(scale)

	local raidWarning = _G.PrivateRaidBossEmoteFrameAnchor
	if raidWarning and raidWarning.mover then
		local width, height = raidWarning:GetSize()
		raidWarning.mover:SetSize(width * scale, height * scale)
	end
end

function PA:RaidWarning_Reparent(parent)
	if not self then return end

	if not PA.RaidWarning and parent ~= UIParent then
		self:SetParent(UIParent)
	elseif parent ~= PA.RaidWarning then
		self:SetParent(PA.RaidWarning)
	end

	local _, anchor = self:GetPoint()
	if anchor ~= self.mover then
		PA:RaidWarning_Reposition()
	end
end

function PA:RaidWarning_Reposition(_, anchor)
	if not anchor then
		anchor = _G.PrivateRaidBossEmoteFrameAnchor
		warningAnchor.relativeTo = anchor.mover or UIParent
		SetPrivateWarningTextAnchor(anchor, warningAnchor)
	elseif anchor ~= self.mover then
		self:ClearAllPoints()
		self:Point('TOP', self.mover)
	end
end

function PA:Initialize()
	PA.RaidWarning = CreateFrame('Frame', 'ElvUI_PrivateRaidWarning', UIParent)

	PA.Auras = CreateFrame('Frame', 'ElvUI_PrivateAuras', E.UIParent)
	PA.Auras:Point('TOPRIGHT', _G.ElvUI_MinimapHolder or _G.Minimap, 'BOTTOMLEFT', -(9 + E.Border), -4)
	PA.Auras:Size(32)

	E:CreateMover(PA.Auras, 'PrivateAurasMover', L["Private Auras"], nil, nil, nil, nil, nil, 'auras,privateAuras')
	PA:Update()

	local raidWarning = _G.PrivateRaidBossEmoteFrameAnchor
	if raidWarning then
		E:CreateMover(raidWarning, 'PrivateRaidWarningMover', L["Private Raid Warning"])

		PA:Update_RaidWarning()

		hooksecurefunc(C_UnitAuras, 'SetPrivateWarningTextAnchor', PA.RaidWarning_Reposition)
		hooksecurefunc(raidWarning, 'SetPoint', PA.RaidWarning_Reposition)
		hooksecurefunc(raidWarning, 'SetParent', PA.RaidWarning_Reparent)
	end
end

E:RegisterModule(PA:GetName())
