local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
local LSM = E.Libs.LSM

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

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

function DB:CreateBar(name, key, updateFunc, onEnter, onClick, points)
	local holder = CreateFrame('Frame', name..'Holder', E.UIParent, 'BackdropTemplate')
	holder:SetTemplate(DB.db.transparent and 'Transparent')
	holder:SetScript('OnEnter', onEnter)
	holder:SetScript('OnLeave', DB.OnLeave)
	holder:SetScript('OnMouseDown', onClick)

	if points then
		holder:ClearAllPoints()
		holder:Point(unpack(points))
	end

	local bar = CreateFrame('StatusBar', name, holder)
	bar:SetStatusBarTexture(E.media.normTex)
	bar:EnableMouse(false)
	bar:SetInside()
	bar:Hide()

	bar.barTexture = bar:GetStatusBarTexture()
	bar.text = bar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:Point('CENTER')

	bar.holder = holder
	bar.Update = updateFunc

	E.FrameLocks[holder] = true
	DB.StatusBars[key] = bar

	return bar
end

function DB:UpdateAll()
	local texture = DB.db.customTexture and LSM:Fetch('statusbar', DB.db.statusbar) or E.media.normTex

	for _, bar in pairs(DB.StatusBars) do
		bar.holder.db = bar.db
		bar.holder:Size(bar.db.width, bar.db.height)
		bar.holder:SetTemplate(DB.db.transparent and 'Transparent')
		bar.holder:EnableMouse(not bar.db.clickThrough)
		bar.text:FontTemplate(LSM:Fetch('font', bar.db.font), bar.db.fontSize, bar.db.fontOutline)
		bar:SetStatusBarTexture(texture)
		bar:SetReverseFill(bar.db.reverseFill)

		if bar.db.enable then
			bar.holder:SetAlpha(bar.db.mouseover and 0 or 1)
		end

		if bar.db.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar.holder, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar.holder)
		end

		if bar.db.orientation == 'AUTOMATIC' then
			bar:SetOrientation(bar.db.height > bar.db.width and 'VERTICAL' or 'HORIZONTAL')
			bar:SetRotatesTexture(bar.db.height > bar.db.width)
		else
			bar:SetOrientation(bar.db.orientation)
			bar:SetRotatesTexture(bar.db.orientation ~= 'HORIZONTAL')
		end

		local orientation = bar:GetOrientation()
		local rotatesTexture = bar:GetRotatesTexture()
		local reverseFill = bar:GetReverseFill()

		for i = 1, bar.holder:GetNumChildren() do
			local child = select(i, bar.holder:GetChildren())
			if child:IsObjectType('StatusBar') then
				child:SetStatusBarTexture(texture)
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
