local E, L, V, P, G = unpack(ElvUI)

local min, max, format = min, max, format

local _G = _G
local UIParent = UIParent
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight
local InCombatLockdown = InCombatLockdown
local GetPhysicalScreenSize = GetPhysicalScreenSize

function E:RefreshGlobalFX() -- using RefreshModelScene will taint
	_G.GlobalFXDialogModelScene:Hide()
	_G.GlobalFXDialogModelScene:Show()

	_G.GlobalFXMediumModelScene:Hide()
	_G.GlobalFXMediumModelScene:Show()

	_G.GlobalFXBackgroundModelScene:Hide()
	_G.GlobalFXBackgroundModelScene:Show()
end

function E:IsEyefinity(width, height)
	if E.global.general.eyefinity and width >= 3840 then
		--HQ resolution
		if width >= 9840 then return 3280 end					--WQSXGA
		if width >= 7680 and width < 9840 then return 2560 end	--WQXGA
		if width >= 5760 and width < 7680 then return 1920 end	--WUXGA & HDTV
		if width >= 5040 and width < 5760 then return 1680 end	--WSXGA+

		--Adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then return 1600 end --UXGA & HD+

		--Low resolution screen
		if width >= 4320 and width < 4800 then return 1440 end	--WSXGA
		if width >= 4080 and width < 4320 then return 1360 end	--WXGA
		if width >= 3840 and width < 4080 then return 1224 end	--SXGA & SXGA (UVGA) & WXGA & HDTV
	end
end

function E:IsUltrawide(width, height)
	if E.global.general.ultrawide and width >= 2560 then
		--HQ Resolution
		if width >= 3440 and (height == 1440 or height == 1600) then return 2560 end --DQHD, DQHD+, WQHD & WQHD+

		--Low resolution
		if width >= 2560 and (height == 1080 or height == 1200) then return 1920 end --WFHD, DFHD & WUXGA
	end
end

function E:UIMult()
	E.mult = E.perfect / E.global.general.UIScale
end

function E:UIScale()
	if InCombatLockdown() then
		E:RegisterEventForObject('PLAYER_REGEN_ENABLED', E.UIScale, E.UIScale)
	else -- E.Initialize
		UIParent:SetScale(E.global.general.UIScale)

		E.uiscale = UIParent:GetScale()
		E.screenWidth, E.screenHeight = GetScreenWidth(), GetScreenHeight()

		local width, height = E.physicalWidth, E.physicalHeight
		E.eyefinity = E:IsEyefinity(width, height)
		E.ultrawide = E:IsUltrawide(width, height)

		local testing, newWidth = false, E.eyefinity or E.ultrawide
		if testing then -- Resize E.UIParent if Eyefinity or UltraWide is on.
			-- Eyefinity / UltraWide Test: Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
			-- Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
			width, height = E.screenWidth-250, E.screenHeight-250
		elseif newWidth then -- Center E.UIParent
			width, height = newWidth / (height / E.screenHeight), E.screenHeight
		else
			width, height = E.screenWidth, E.screenHeight
		end

		E.UIParent:SetSize(width, height)
		E.UIParent.origHeight = E.UIParent:GetHeight()

		if E.Retail then
			E:RefreshGlobalFX()
		end

		if E:IsEventRegisteredForObject('PLAYER_REGEN_ENABLED', E.UIScale) then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', E.UIScale, E.UIScale)
		end
	end
end

function E:PixelBestSize()
	return max(0.4, min(1.15, E.perfect))
end

function E:PixelScaleChanged(event)
	if event == 'UI_SCALE_CHANGED' then
		E.physicalWidth, E.physicalHeight = GetPhysicalScreenSize()
		E.resolution = format('%dx%d', E.physicalWidth, E.physicalHeight)
		E.perfect = 768 / E.physicalHeight
	end

	E:UIMult()
	E:UIScale()

	E:Config_UpdateSize(true) -- Reposition config
end

function E:Scale(x)
	local m = E.mult
	if m == 1 or x == 0 then
		return x
	else
		local y = m > 1 and m or -m
		return x - x % (x < 0 and y or -y)
	end
end
