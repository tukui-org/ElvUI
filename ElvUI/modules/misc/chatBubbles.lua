local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:GetModule('Misc');
local NP = E:GetModule("NamePlates");
local numChildren = -1

function M:UpdateBubbleBorder()
	if not self.text then return end
	NP:SetVirtualBorder(self, self.text:GetTextColor())
end

function M:SkinBubble(frame)
	local noscalemult = E.mult * (GetCVar('uiScale') or UIParent:GetScale())
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	NP:CreateVirtualFrame(frame)	
	NP:SetVirtualBorder(frame, frame.text:GetTextColor())	
	
	if E.PixelMode then
		frame.backdrop2:SetTexture(unpack(E["media"].backdropfadecolor))
	end
	
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