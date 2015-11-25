local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local abs, floor, min, max = math.abs, math.floor, math.min, math.max
local match = string.match
--WoW API / Variables
local IsMacClient = IsMacClient
local GetCVar, SetCVar = GetCVar, SetCVar
local GetScreenHeight, GetScreenWidth = GetScreenHeight, GetScreenWidth

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent, WorldMapFrame

--Determine if Eyefinity is being used, setup the pixel perfect script.
local scale

function E:UIScale(event)
	if IsMacClient() and self.global.screenheight and self.global.screenwidth and (self.screenheight ~= self.global.screenheight or self.screenwidth ~= self.global.screenwidth) then
		self.screenheight = self.global.screenheight
		self.screenwidth = self.global.screenwidth
	end

	if self.global.general.autoScale then
		scale = max(0.64, min(1.15, 768/self.screenheight));
	else
		scale = max(0.64, min(1.15, GetCVar('uiScale') or UIParent:GetScale() or 768/self.screenheight));
	end

	if self.screenwidth < 1600 then
			self.lowversion = true;
	elseif self.screenwidth >= 3840 and self.global.general.eyefinity then
		local width = self.screenwidth;
		local height = self.screenheight;

		-- because some user enable bezel compensation, we need to find the real width of a single monitor.
		-- I don't know how it really work, but i'm assuming they add pixel to width to compensate the bezel. :P

		-- HQ resolution
		if width >= 9840 then width = 3280; end                   	                -- WQSXGA
		if width >= 7680 and width < 9840 then width = 2560; end                     -- WQXGA
		if width >= 5760 and width < 7680 then width = 1920; end 	                -- WUXGA & HDTV
		if width >= 5040 and width < 5760 then width = 1680; end 	                -- WSXGA+

		-- adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then width = 1600; end   -- UXGA & HD+

		-- low resolution screen
		if width >= 4320 and width < 4800 then width = 1440; end 	                -- WSXGA
		if width >= 4080 and width < 4320 then width = 1360; end 	                -- WXGA
		if width >= 3840 and width < 4080 then width = 1224; end 	                -- SXGA & SXGA (UVGA) & WXGA & HDTV

		-- yep, now set ElvUI to lower resolution if screen #1 width < 1600
		if width < 1600 then
			self.lowversion = true;
		end

		-- register a constant, we will need it later for launch.lua
		self.eyefinity = width;
	end

	self.mult = 768/match(GetCVar("gxResolution"), "%d+x(%d+)")/scale;

	--Set UIScale, NOTE: SetCVar for UIScale can cause taints so only do this when we need to..
	if E.Round and E:Round(UIParent:GetScale(), 5) ~= E:Round(scale, 5) and (event == 'PLAYER_LOGIN') then
		SetCVar("useUiScale", 1);
		SetCVar("uiScale", scale);
		WorldMapFrame.hasTaint = true;
	end

	if (event == 'PLAYER_LOGIN' or event == 'UI_SCALE_CHANGED') then
		if IsMacClient() then
			self.global.screenheight = floor(GetScreenHeight()*100+.5)/100
			self.global.screenwidth = floor(GetScreenWidth()*100+.5)/100
		end

		--Resize self.UIParent if Eyefinity is on.
		if self.eyefinity then
			local width = self.eyefinity;
			local height = self.screenheight;

			-- if autoscale is off, find a new width value of self.UIParent for screen #1.
			if not self.global.general.autoScale or height > 1200 then
				local h = UIParent:GetHeight();
				local ratio = self.screenheight / h;
				local w = self.eyefinity / ratio;

				width = w;
				height = h;
			end

			self.UIParent:SetSize(width, height);
		else
			--[[Eyefinity Test mode
				Resize the E.UIParent to be smaller than it should be, all objects inside should relocate.
				Dragging moveable frames outside the box and reloading the UI ensures that they are saving position correctly.
			]]
			--self.UIParent:SetSize(UIParent:GetWidth() - 250, UIParent:GetHeight() - 250);

			self.UIParent:SetSize(UIParent:GetSize());
		end

		self.UIParent:ClearAllPoints();
		self.UIParent:SetPoint("CENTER");

		local change
		if E.Round then
			change = abs((E:Round(UIParent:GetScale(), 5) * 100) - (E:Round(scale, 5) * 100))
		end

		if event == 'UI_SCALE_CHANGED' and change and change > 1 and self.global.general.autoScale then
			E:StaticPopup_Show('FAILED_UISCALE')
		elseif event == 'UI_SCALE_CHANGED' and change and change > 1 then
			E:StaticPopup_Show('CONFIG_RL')
		end

		self:UnregisterEvent('PLAYER_LOGIN')
	end
end

-- pixel perfect script of custom ui scale.
function E:Scale(x)
    return self.mult*floor(x/self.mult+.5);
end