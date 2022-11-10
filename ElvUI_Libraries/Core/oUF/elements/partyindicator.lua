--[[
# Element: Party Indicator (by Caedis)
	Toggles the visibility of an indicator based on if the player was in a group before joining the instance.

## Widget
	PartyIndicator - Player only widget.
]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.PartyIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local forced = not event or event == 'ElvUI_UpdateAllElements'
	if forced or event == 'GROUP_ROSTER_UPDATE' then
		if IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			element:Show()
		else
			element:Hide()
		end
	end

	if forced or event == 'UPDATE_CHAT_COLOR' then
		local private = ChatTypeInfo.PARTY
		if private and element.HomeIcon then
			element.HomeIcon:SetVertexColor(private.r, private.g, private.b, 1)
		end

		local public = ChatTypeInfo.INSTANCE_CHAT
		if public and element.InstanceIcon then
			element.InstanceIcon:SetVertexColor(public.r, public.g, public.b, 1)
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate()
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

local function Enable(self)
	local element = self.PartyIndicator
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_CHAT_COLOR', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element.HomeIcon and element.HomeIcon:IsObjectType('Texture') and not element.HomeIcon:GetTexture()) then
			element.HomeIcon:SetTexture([[Interface\FriendsFrame\UI-Toast-FriendOnlineIcon]])
		end

		if(element.InstanceIcon and element.InstanceIcon:IsObjectType('Texture') and not element.InstanceIcon:GetTexture()) then
			element.InstanceIcon:SetTexture([[Interface\FriendsFrame\UI-Toast-FriendOnlineIcon]])
		end

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
