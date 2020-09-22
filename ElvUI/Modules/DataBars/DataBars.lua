local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local pairs, select = pairs, select
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local C_PvP_IsWarModeActive = C_PvP.IsWarModeActive

function DB:OnLeave()
	if self.db.mouseover then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	_G.GameTooltip:Hide()
end

function DB:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame('StatusBar', name, E.UIParent)
	bar:Point(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', DB.OnLeave)
	bar:SetScript('OnMouseDown', onClick)
	bar:SetFrameStrata('LOW')
	bar:SetStatusBarTexture(E.media.normTex)
	bar:CreateBackdrop(DB.db.transparent and 'Transparent')
	bar:Hide()

	bar.text = bar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:Point('CENTER')

	return bar
end

function DB:UpdateAll()
	local customStatusBar = E.LSM:Fetch('statusbar', DB.db.statusbar)

	for _, bar in pairs(DB.StatusBars) do
		local barTexture = DB.db.customTexture and customStatusBar or E.media.normTex

		bar:SetWidth(bar.db.width)
		bar:SetHeight(bar.db.height)
		bar:SetReverseFill(bar.db.reverseFill)
		bar:SetStatusBarTexture(barTexture, 'ARTWORK', 7)
		bar:EnableMouse(not bar.db.clickThrough)
		bar.backdrop:SetTemplate(DB.db.transparent and 'Transparent')
		bar.text:FontTemplate(E.Libs.LSM:Fetch('font', bar.db.font), bar.db.fontSize, bar.db.fontOutline)

		if bar.db.enable then
			bar:SetAlpha(bar.db.mouseover and 0 or 1)
		end

		if bar.db.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		if bar.db.orientation == 'AUTOMATIC' then
			bar:SetOrientation(bar.db.height > bar.db.width and 'VERTICAL' or 'HORIZONTAL')
			bar:SetRotatesTexture(bar.db.height > bar.db.width)
		else
			bar:SetOrientation(bar.db.orientation)
			bar:SetRotatesTexture(bar.db.orientation ~= 'HORIZONTAL')
		end

		local frameLevel = bar:GetFrameLevel()
		local orientation = bar:GetOrientation()
		local rotatesTexture = bar:GetRotatesTexture()
		local reverseFill = bar:GetReverseFill()

		for i = 1, bar:GetNumChildren() do
			local child = select(i, bar:GetChildren())
			if child:IsObjectType('StatusBar') then
				child:SetStatusBarTexture(barTexture, 'ARTWORK', -i)
				child:SetFrameLevel(frameLevel)
				child:SetOrientation(orientation)
				child:SetRotatesTexture(rotatesTexture)
				child:SetReverseFill(reverseFill)
			end
		end
	end

	DB:PvPCheck()
end

function DB:PLAYER_LEVEL_UP()
	local isMaxLevel = IsPlayerAtEffectiveMaxLevel()

	for _, bar in pairs(DB.StatusBars) do
		if bar.db.enable and (bar.db.hideAtMaxLevel ~= nil or bar.db.hideBelowMaxLevel ~= nil) then
			bar:SetShown(not ((bar.db.hideAtMaxLevel and isMaxLevel) or (bar.db.hideBelowMaxLevel and not isMaxLevel)))
		end
	end
end

function DB:CombatCheck(event)
	local notInCombat = event == 'PLAYER_REGEN_ENABLED'
	for _, bar in pairs(DB.StatusBars) do
		if bar.db.enable and bar.db.hideInCombat then
			bar:SetShown(notInCombat)
			if notInCombat and bar.Update then
				bar:Update()
			end
		end
	end
end

function DB:PvPCheck()
	local PvPInstance = select(2, GetInstanceInfo()) == 'pvp'
	local WarMode = C_PvP_IsWarModeActive()

	for _, bar in pairs(DB.StatusBars) do
		if bar.db.enable and bar.db.hideOutsidePvP then
			bar:SetShown(not (PvPInstance or WarMode))
		end
	end
end

function DB:Initialize()
	DB.Initialized = true
	DB.StatusBars = {}

	DB.db = E.db.databars

	DB:ExperienceBar()
	DB:ReputationBar()
	DB:HonorBar()
	DB:AzeriteBar()
	DB:ThreatBar()

	DB:UpdateAll()

	DB:RegisterEvent('PLAYER_LEVEL_UP')
	DB:RegisterEvent('PLAYER_REGEN_ENABLED', 'CombatCheck')
	DB:RegisterEvent('PLAYER_REGEN_DISABLED', 'CombatCheck')
	DB:RegisterEvent('PVP_TIMER_UPDATE', 'PvPCheck')
	DB:RegisterEvent('PLAYER_ENTERING_WORLD', 'PvPCheck')
end

E:RegisterModule(DB:GetName())
