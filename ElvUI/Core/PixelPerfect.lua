local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local min, max, floor, format = min, max, floor, format

local UIParent = UIParent
local InCombatLockdown = InCombatLockdown
local GetPhysicalScreenSize = GetPhysicalScreenSize

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
		if width >= 3440 and (height == 1440 or height == 1600) then return 2560 end --WQHD, DQHD, DQHD+ & WQHD+

		--Low resolution
		if width >= 2560 and height == 1080 then return 1920 end --WFHD & DFHD
	end
end

function E:UIScale(init)
	local scale = E.global.general.UIScale
	-- `init` will be the `event` if its triggered after combat
	if init == true then -- E.OnInitialize
		--Set variables for pixel scaling
		local pixel, ratio = 1, 768 / E.screenheight
		E.mult = (pixel / scale) - ((pixel - ratio) / scale)
	elseif InCombatLockdown() then
		E:RegisterEventForObject('PLAYER_REGEN_ENABLED', E.UIScale, E.UIScale)
	else -- E.Initialize
		UIParent:SetScale(scale)

		local width, height = E.screenwidth, E.screenheight
		E.eyefinity = E:IsEyefinity(width, height)
		E.ultrawide = E:IsUltrawide(width, height)

		local newWidth = E.eyefinity or E.ultrawide

		--Resize E.UIParent if Eyefinity or UltraWide is on.
		local testingResize = false
		if testingResize then
			-- Eyefinity / UltraWide Test: Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
			-- Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
			local uiWidth, uiHeight = UIParent:GetSize()
			width, height = uiWidth-250, uiHeight-250
		elseif newWidth then
			-- Center E.UIParent
			local uiHeight = UIParent:GetHeight()
			width, height = newWidth / (height / uiHeight), uiHeight
		else
			width, height = UIParent:GetSize()
		end

		E.UIParent:SetSize(width, height)
		E.UIParent.origHeight = E.UIParent:GetHeight()

		if E:IsEventRegisteredForObject('PLAYER_REGEN_ENABLED', E.UIScale) then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', E.UIScale, E.UIScale)
		end
	end
end

function E:PixelBestSize()
	return max(0.4, min(1.15, 768 / E.screenheight))
end

function E:PixelScaleChanged(event)
	if event == 'UI_SCALE_CHANGED' then
		E.screenwidth, E.screenheight = GetPhysicalScreenSize()
		E.resolution = format('%dx%d', E.screenwidth, E.screenheight)
	end

	E:UIScale(true) --Repopulate variables
	E:UIScale() --Setup the scale

	E:Config_UpdateSize(true) --Reposition config
end

function E:Scale(x)
	return E.mult * floor(x / E.mult + 0.5)
end
