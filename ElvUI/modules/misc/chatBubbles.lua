local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');
local NP = E:GetModule("NamePlates");
local numChildren = -1

--Cache global variables
--Lua functions
local select, unpack, type = select, unpack, type
local strlower = strlower
--WoW API / Variables
local CreateFrame = CreateFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, WorldFrame

function M:UpdateBubbleBorder()
	if not self.text then return end

	if E.PixelMode then
		self:SetBackdropBorderColor(self.text:GetTextColor())
	else
		local r, g, b = self.text:GetTextColor()
		self.bordertop:SetTexture(r, g, b)
		self.borderbottom:SetTexture(r, g, b)
		self.borderleft:SetTexture(r, g, b)
		self.borderright:SetTexture(r, g, b)
	end
end

function M:SkinBubble(frame)
	local mult = E.mult * UIParent:GetScale()
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end

	if E.private.general.chatBubbles == 'backdrop' then
		if E.PixelMode then
			frame:SetBackdrop({
			  bgFile = E["media"].blankTex,
			  edgeFile = E["media"].blankTex,
			  tile = false, tileSize = 0, edgeSize = mult,
			  insets = { left = 0, right = 0, top = 0, bottom = 0}
			})
		else
			frame:SetBackdrop(nil)
		end

		local r, g, b = frame.text:GetTextColor()
		if not E.PixelMode then
			frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.backdrop:SetAllPoints(frame)
			frame.backdrop:SetTexture(unpack(E.media.backdropfadecolor))
			frame.backdrop:SetDrawLayer("ARTWORK", -8)

			frame.bordertop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop:SetPoint("TOPLEFT", frame, "TOPLEFT", -mult*2, mult*2)
			frame.bordertop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", mult*2, mult*2)
			frame.bordertop:SetHeight(mult)
			frame.bordertop:SetTexture(r, g, b)
			frame.bordertop:SetDrawLayer("ARTWORK", -6)

			frame.bordertop.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.bordertop.backdrop:SetPoint("TOPLEFT", frame.bordertop, "TOPLEFT", -mult, mult)
			frame.bordertop.backdrop:SetPoint("TOPRIGHT", frame.bordertop, "TOPRIGHT", mult, mult)
			frame.bordertop.backdrop:SetHeight(mult * 3)
			frame.bordertop.backdrop:SetTexture(0, 0, 0)
			frame.bordertop.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderbottom = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -mult*2, -mult*2)
			frame.borderbottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", mult*2, -mult*2)
			frame.borderbottom:SetHeight(mult)
			frame.borderbottom:SetTexture(r, g, b)
			frame.borderbottom:SetDrawLayer("ARTWORK", -6)

			frame.borderbottom.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderbottom.backdrop:SetPoint("BOTTOMLEFT", frame.borderbottom, "BOTTOMLEFT", -mult, -mult)
			frame.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", frame.borderbottom, "BOTTOMRIGHT", mult, -mult)
			frame.borderbottom.backdrop:SetHeight(mult * 3)
			frame.borderbottom.backdrop:SetTexture(0, 0, 0)
			frame.borderbottom.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderleft = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft:SetPoint("TOPLEFT", frame, "TOPLEFT", -mult*2, mult*2)
			frame.borderleft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", mult*2, -mult*2)
			frame.borderleft:SetWidth(mult)
			frame.borderleft:SetTexture(r, g, b)
			frame.borderleft:SetDrawLayer("ARTWORK", -6)

			frame.borderleft.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderleft.backdrop:SetPoint("TOPLEFT", frame.borderleft, "TOPLEFT", -mult, mult)
			frame.borderleft.backdrop:SetPoint("BOTTOMLEFT", frame.borderleft, "BOTTOMLEFT", -mult, -mult)
			frame.borderleft.backdrop:SetWidth(mult * 3)
			frame.borderleft.backdrop:SetTexture(0, 0, 0)
			frame.borderleft.backdrop:SetDrawLayer("ARTWORK", -7)

			frame.borderright = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright:SetPoint("TOPRIGHT", frame, "TOPRIGHT", mult*2, mult*2)
			frame.borderright:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -mult*2, -mult*2)
			frame.borderright:SetWidth(mult)
			frame.borderright:SetTexture(r, g, b)
			frame.borderright:SetDrawLayer("ARTWORK", -6)

			frame.borderright.backdrop = frame:CreateTexture(nil, "ARTWORK")
			frame.borderright.backdrop:SetPoint("TOPRIGHT", frame.borderright, "TOPRIGHT", mult, mult)
			frame.borderright.backdrop:SetPoint("BOTTOMRIGHT", frame.borderright, "BOTTOMRIGHT", mult, -mult)
			frame.borderright.backdrop:SetWidth(mult * 3)
			frame.borderright.backdrop:SetTexture(0, 0, 0)
			frame.borderright.backdrop:SetDrawLayer("ARTWORK", -7)
		else
			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(r, g, b)
		end


		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize)

		frame:SetClampedToScreen(false)
		frame:HookScript('OnShow', M.UpdateBubbleBorder)
	elseif E.private.general.chatBubbles == 'nobackdrop' then
		frame:SetBackdrop(nil)
		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize)
		frame:SetClampedToScreen(false)
	end
	frame.isBubblePowered = true
end

function M:IsChatBubble(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if (region.GetTexture and region:GetTexture() and type(region:GetTexture() == "string") and strlower(region:GetTexture()) == [[interface\tooltips\chatbubble-background]]) then return true end;
	end
	return false
end

function M:HookBubbles(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)

		if M:IsChatBubble(frame) and not frame.isBubblePowered then	M:SkinBubble(frame) end
	end
end

function M:LoadChatBubbles()
	if E.private.general.bubbles == false then
		E.private.general.chatBubbles = 'disabled'
		E.private.general.bubbles = nil
	end

	if E.private.general.chatBubbles == 'disabled' then return end

	local frame = CreateFrame('Frame')
	frame.lastupdate = -2 -- wait 2 seconds before hooking frames

	frame:SetScript('OnUpdate', function(self, elapsed)
		self.lastupdate = self.lastupdate + elapsed
		if (self.lastupdate < .1) then return end
		self.lastupdate = 0

		local count = WorldFrame:GetNumChildren()
		if(count ~= numChildren) then
			numChildren = count
			M:HookBubbles(WorldFrame:GetChildren())
		end
	end)
end