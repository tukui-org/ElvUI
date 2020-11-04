--[[
# Element: Party Indicator

Toggles the visibility of an indicator based on if the player was in a group before joining the instance.

## Widget

PartyIndicator - Player only widget.

## Notes
]]

local _, ns = ...
local oUF = ns.oUF

--[[ 
	* self - the ElvUF_Player element
	--]]
local function Update(self, event)
	local element = self.PartyIndicator	

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	if event == 'GROUP_ROSTER_UPDATE' or event == 'ElvUI_UpdateAllElements' then
		if IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			element:Show()
		else
			element:Hide()
		end
	end
	
	if event == 'UPDATE_CHAT_COLOR' or event == 'ElvUI_UpdateAllElements' then
		local private = ChatTypeInfo["PARTY"];
		element.HomePartyIcon:SetVertexColor(private.r, private.g, private.b, 1);

		local public = ChatTypeInfo["INSTANCE_CHAT"];
		element.InstancePartyIcon:SetVertexColor(public.r, public.g, public.b, 1);
	end

	--[[ Callback: PartyIndicator:PostUpdate(inInstance)
	Called after the element has been updated.
	* inInstance - indicates if the player is inside an instance (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(inInstance)
	end
end

local function Path(self, ...)
	--[[ Override: PartyIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.PartyIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.PartyIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_CHAT_COLOR', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.PartyIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UPDATE_CHAT_COLOR', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
		
	end
end

oUF:AddElement('PartyIndicator', Path, Enable, Disable)
