local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local _G = _G
--Lua functions
local tonumber, strsub, strlen = tonumber, strsub, strlen
local abs, floor, min, max = math.abs, math.floor, math.min, math.max
--WoW API / Variables
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetCVar, SetCVar = GetCVar, SetCVar

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

function E:GetUIScale(useEffectiveScale)
	local width, height = E.screenwidth or 0, E.screenheight or 0
	if width == 0 or height == 0 then
		E.screenwidth, E.screenheight = GetPhysicalScreenSize()
		width, height = E.screenwidth or 0, E.screenheight or 0
	end

	local effectiveScale = _G.UIParent:GetEffectiveScale()
	local magic = (not useEffectiveScale and height > 0 and 768 / height) or effectiveScale

	local uiScaleCVar = GetCVar('uiScale')
	if uiScaleCVar then E.global.uiScale = uiScaleCVar end

	local minScale = E.global.general.minUiScale or 0.64
	local scale = max(minScale, min(1.15, (E.global.general.autoScale and magic) or E.global.uiScale or minScale))

	if strlen(scale) > 6 then -- lock to ten thousands decimal place
		scale = tonumber(strsub(scale, 0, 6))
	end

	return scale, magic, effectiveScale, width, height
end

function E:SetResolutionVariables(width, height)
	if width < 1600 then
		E.lowversion = true
	elseif width >= 3840 and E.global.general.eyefinity then
		-- because some user enable bezel compensation, we need to find the real width of a single monitor.
		-- I don't know how it really work, but i'm assuming they add pixel to width to compensate the bezel. :P

		-- HQ resolution
		if width >= 9840 then width = 3280; end							-- WQSXGA
		if width >= 7680 and width < 9840 then width = 2560; end		-- WQXGA
		if width >= 5760 and width < 7680 then width = 1920; end		-- WUXGA & HDTV
		if width >= 5040 and width < 5760 then width = 1680; end		-- WSXGA+

		-- adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then width = 1600; end	-- UXGA & HD+

		-- low resolution screen
		if width >= 4320 and width < 4800 then width = 1440; end		-- WSXGA
		if width >= 4080 and width < 4320 then width = 1360; end		-- WXGA
		if width >= 3840 and width < 4080 then width = 1224; end		-- SXGA & SXGA (UVGA) & WXGA & HDTV

		-- yep, now set ElvUI to lower resolution if screen #1 width < 1600
		if width < 1600 then
			E.lowversion = true
		end

		-- register a constant, we will need it later for launch.lua
		E.eyefinity = width
	end
end

--Determine if Eyefinity is being used, setup the pixel perfect script.
function E:UIScale(event, loginFrame)
	local UIParent, _ = _G.UIParent
	local scale, magic, effectiveScale, width, height = E:GetUIScale()

	--Set UIScale, NOTE: SetCVar for UIScale can cause taints so only do this when we need to..
	if E.global.general.autoScale and event == 'PLAYER_LOGIN' and (E.Round and E:Round(effectiveScale, 5) ~= E:Round(scale, 5)) then
		SetCVar("useUiScale", 1)
		SetCVar("uiScale", scale)

		--SetCVar for UI scale only accepts value as low as 0.64, so scale UIParent if needed
		if scale < 0.64 then
			UIParent:SetScale(scale)
		end

		-- call this after setting CVars and SetScale when using autoscale.. to recalculate based on the blizzard UIParent scale value.
		scale, magic, _, width, height = E:GetUIScale(true)
	end

	E.mult = magic/scale
	E.Spacing = (E.PixelMode and 0) or E.mult
	E.Border = (E.PixelMode and E.mult) or E.mult*2

	if event == 'PLAYER_LOGIN' or event == 'UI_SCALE_CHANGED' then
		--Check if we are using `E.eyefinity` also this will set `E.lowversion`
		E:SetResolutionVariables(width, height)

		--Resize E.UIParent if Eyefinity is on.
		local testingEyefinity = false
		if testingEyefinity then
			-- Eyefinity Test: Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
			-- Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
			width, height = UIParent:GetWidth() - 250, UIParent:GetHeight() - 250
		elseif E.eyefinity and ((not E.global.general.autoScale) or height > 1200) then
			-- if autoscale is off, find a new width value of E.UIParent for screen #1.
			local uiHeight = UIParent:GetHeight()
			width, height = E.eyefinity / (height / uiHeight), uiHeight
		else
			width, height = UIParent:GetSize()
		end

		E.UIParent:SetSize(width, height)
		E.UIParent.origHeight = E.UIParent:GetHeight()
		E.UIParent:ClearAllPoints()

		if E.global.general.commandBarSetting == "ENABLED_RESIZEPARENT" then
			E.UIParent:Point("BOTTOM")
		else
			E.UIParent:Point("CENTER")
		end

		--Calculate potential coordinate differences
		E.diffGetLeft = E:Round(abs(UIParent:GetLeft() - E.UIParent:GetLeft()))
		E.diffGetRight = E:Round(abs(UIParent:GetRight() - E.UIParent:GetRight()))
		E.diffGetTop = E:Round(abs(UIParent:GetTop() - E.UIParent:GetTop()))
		E.diffGetBottom = E:Round(abs(UIParent:GetBottom() - E.UIParent:GetBottom()))

		local change
		if E.Round then
			change = abs((E:Round(UIParent:GetScale(), 5) * 100) - (E:Round(scale, 5) * 100))
		end

		if event == 'UI_SCALE_CHANGED' and (change and change > 1) then
			if E.global.general.autoScale then
				E:StaticPopup_Show('FAILED_UISCALE')
			else
				E:StaticPopup_Show('CONFIG_RL')
			end
		end

		if loginFrame and event == 'PLAYER_LOGIN' then
			loginFrame:UnregisterEvent('PLAYER_LOGIN')
		end
	end
end

-- pixel perfect script of custom ui scale.
function E:Scale(x)
	return E.mult * floor(x/E.mult+.5)
end
