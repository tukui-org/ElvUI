local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');
local CH = E:GetModule("Chat");
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
		self.bordertop:SetColorTexture(r, g, b)
		self.borderbottom:SetColorTexture(r, g, b)
		self.borderleft:SetColorTexture(r, g, b)
		self.borderright:SetColorTexture(r, g, b)
	end
	
	local classColorTable, lowerCaseWord, isFirstWord, rebuiltString, tempWord
	local text = self.text:GetText()
	for word in text:gmatch("[^%s]+") do
		lowerCaseWord = word:lower()
		lowerCaseWord = lowerCaseWord:gsub("%p", "")
		if(CH.ClassNames[lowerCaseWord]) then
			classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CH.ClassNames[lowerCaseWord]] or RAID_CLASS_COLORS[CH.ClassNames[lowerCaseWord]];
			tempWord = word:gsub("%p", "")
			word = word:gsub(tempWord, format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..tempWord.."\124r")
		end
		
		if not isFirstWord then
			rebuiltString = word
			isFirstWord = true
		else
			rebuiltString = format("%s %s", rebuiltString, word)
		end		
	end	


	self.text:SetText(rebuiltString)
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
		frame:SetBackdrop(nil)

		frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
		frame.backdrop:SetInside(frame, 4, 4)
		frame.backdrop:SetColorTexture(unpack(E.media.backdropfadecolor))
		frame.backdrop:SetDrawLayer("ARTWORK", -8)
		frame.text:FontTemplate(E.LSM:Fetch("font", E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize)

		frame:SetClampedToScreen(false)
		frame:HookScript('OnShow', M.UpdateBubbleBorder)
		M.UpdateBubbleBorder(frame)
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

		if (region.GetTexture and region:GetTexture() and type(region:GetTexture() == "string") and strlower(region:GetTexture()) == [[interface\tooltips\chatbubble-background.blp]]) then return true end;
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