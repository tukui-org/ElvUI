local E, L, V, P, G = unpack(ElvUI)
local PA = E:GetModule('PrivateAuras')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local CopyTable = CopyTable
local UIParent = UIParent

local C_UnitAuras = C_UnitAuras
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
local SetPrivateWarningTextAnchor = C_UnitAuras.SetPrivateWarningTextAnchor

-- unitframeType is used before its actually initialized
-- because they arent valid we skip them on purpose
local exclude = {
	raid = true,
	raidpet = true,
	party = true,
	partypet = true,
	arena = true,
	boss = true,
}

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
		unitToken = nil,
		auraIndex = 1,
		showCountdownFrame = true,
		showCountdownNumbers = true,
		isContainer = false,
		parent = nil, -- dynamically added in CreateAnchor
		iconInfo = nil, -- added on creation
		durationAnchor = nil, -- added on creation
	}
}

function PA:CreateAnchor(aura, parent, unit, index, db)
	local previousAura = parent.auraIcons[index]
	if previousAura then -- clear any old ones
		PA:RemoveAura(previousAura)
	end

	if not unit then -- try to get the unit token
		unit = (parent.owner and parent.owner.unit) or nil
	end

	-- check one last time, stop if something goes wrong
	if not unit or exclude[unit] then return end

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
	if not aura.anchorID then return end

	RemovePrivateAuraAnchor(aura.anchorID)

	aura.anchorID = nil
end

function PA:RemoveAuras(parent)
	if not parent or not parent.auraIcons then return end

	for _, aura in next, parent.auraIcons do
		PA:RemoveAura(aura)
	end
end

function PA:CreateAura(parent, unit, index, db)
	local aura = parent.auraIcons[index]
	if not aura then
		aura = CreateFrame('Frame', '$parent'..index, parent)
	end

	if not aura.anchorID then
		aura.anchorID = PA:CreateAnchor(aura, parent, unit, index, db)
	end

	-- EnableMouse doesnt work; set the size to 1x1
	if db.clickThrough then
		aura:SetSize(1, 1)
	else
		aura:Size(db.icon.size)
	end

	-- for some reason, its not obeying the frame level; Blizzard bug?
	aura:OffsetFrameLevel(nil, parent) -- set it to something else, fixes the bug
	aura:OffsetFrameLevel(1, parent) -- set it to the level we actually want

	aura:ClearAllPoints()

	local step = db.icon.size + (db.icon.offset or 0)
	local compensate = (db.clickThrough and db.icon.size * 0.5) or 0
	local x, y = 0, 0

	if db.icon.point == 'RIGHT' then
		x = (index - 1) * step + compensate
	elseif db.icon.point == 'LEFT' then
		x = -(index - 1) * step - compensate
	elseif db.icon.point == 'TOP' then
		y = (index - 1) * step + compensate
	elseif db.icon.point == 'BOTTOM' then
		y = -(index - 1) * step - compensate
	end

	aura:Point('CENTER', parent, x, y)

	return aura
end

function PA:SetupAuras(parent, unit)
	local db = parent and parent.db
	if not db then return end

	if not parent.auraIcons then
		parent.auraIcons = {}
	end

	for i = 1, db.icon.amount do
		parent.auraIcons[i] = PA:CreateAura(parent, unit, i, db)
	end
end

function PA:Update()
	PA:RemoveAuras(PA.Auras)

	if E.db.general.privateAuras.enable then
		PA.Auras:Size(E.db.general.privateAuras.icon.size)

		PA:SetupAuras(PA.Auras, 'player')

		E:EnableMover(PA.Auras.mover.name)
	else
		E:DisableMover(PA.Auras.mover.name)
	end
end

function PA:RaidWarning_Update()
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
	PA.Auras.db = E.db.general.privateAuras

	E:CreateMover(PA.Auras, 'PrivateAurasMover', L["Private Auras"], nil, nil, nil, nil, nil, 'auras,privateAuras')
	PA:Update()

	local raidWarning = _G.PrivateRaidBossEmoteFrameAnchor
	if raidWarning then
		E:CreateMover(raidWarning, 'PrivateRaidWarningMover', L["Private Raid Warning"])

		PA:RaidWarning_Update()

		hooksecurefunc(C_UnitAuras, 'SetPrivateWarningTextAnchor', PA.RaidWarning_Reposition)
		hooksecurefunc(raidWarning, 'SetPoint', PA.RaidWarning_Reposition)
		hooksecurefunc(raidWarning, 'SetParent', PA.RaidWarning_Reparent)
	end
end

E:RegisterModule(PA:GetName())
