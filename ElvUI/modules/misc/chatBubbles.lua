local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');
local NP = E:GetModule("NamePlates");
local numChildren = -1

function M:UpdateBubbleBorder()
	if not self.text then return end
	self:SetBackdropBorderColor(self.text:GetTextColor())
	--NP:SetVirtualBorder(self, self.text:GetTextColor())
end

function M:SkinBubble(frame)
	local mult = E.mult * (GetCVar('uiScale') or UIParent:GetScale())
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end

	if E.PixelMode then
		frame:SetBackdrop({
		  bgFile = E["media"].blankTex, 
		  edgeFile = E["media"].blankTex, 
		  tile = false, tileSize = 0, edgeSize = mult, 
		  insets = { left = 0, right = 0, top = 0, bottom = 0}
		})	
	else
		frame:SetBackdrop({
		  bgFile = E["media"].blankTex, 
		  edgeFile = E["media"].blankTex, 
		  tile = false, tileSize = 0, edgeSize = mult, 
		  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
		})
	end

	frame:SetBackdropColor(unpack(E["media"].bubblefadecolor))
	
	if not frame.oborder and not frame.iborder and not E.PixelMode then
		local border = CreateFrame("Frame", nil, frame)
		border:SetInside(frame, mult, mult)
		border:SetBackdrop({
			edgeFile = E["media"].blankTex, 
			edgeSize = mult, 
			insets = { left = mult, right = mult, top = mult, bottom = mult }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		frame.iborder = border

		border = CreateFrame("Frame", nil, frame)
		border:SetOutside(frame, mult, mult)
		border:SetFrameLevel(frame:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = E["media"].blankTex, 
			edgeSize = mult, 
			insets = { left = mult, right = mult, top = mult, bottom = mult }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		frame.oborder = border				
	end

	frame:SetBackdropBorderColor(frame.text:GetTextColor())
	frame.text:FontTemplate(nil, 14)

	frame:SetClampedToScreen(false)
	frame.isBubblePowered = true
	frame:HookScript('OnShow', M.UpdateBubbleBorder)
end

function M:IsChatBubble(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	local region = frame:GetRegions()
	return region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]	
end

function M:HookBubbles(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)

		if M:IsChatBubble(frame) and not frame.isBubblePowered then	M:SkinBubble(frame) end
	end
end

function M:LoadChatBubbles()
	if not E.private.general.bubbles then return end
	
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