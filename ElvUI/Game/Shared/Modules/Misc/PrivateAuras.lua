local E, L, V, P, G = unpack(ElvUI)
local PA = E:GetModule('PrivateAuras')

local _G = _G
local hooksecurefunc = hooksecurefunc

local C_UnitAuras = C_UnitAuras
local SetPrivateWarningTextAnchor = C_UnitAuras.SetPrivateWarningTextAnchor
local CreateFrame = CreateFrame
local UIParent = UIParent

local warningAnchor = {
	relativeTo = nil, -- dynamically added in RaidWarning_Reposition
	relativePoint = 'TOP',
	point = 'TOP',
	offsetX = 0,
	offsetY = 0,
}

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
