local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

function UF:Construct_NameText(frame)
	local parent = frame.RaisedElementParent or frame
	local name = parent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(name)
	name:SetPoint('CENTER', frame.Health)
	
	return name
end

function UF:UpdateNameSettings(frame)
	local db = frame.db
	local name = frame.Name
	if not db.power.hideonnpc then
		local x, y = self:GetPositionOffset(db.name.position)
		name:ClearAllPoints()
		name:Point(db.name.position, frame.Health, db.name.position, x, y)				
	end
	
	frame:Tag(name, db.name.text_format)	
end

function UF:PostNamePosition(frame, unit)
	if not frame.Power.value:IsShown() then return end
	
	if UnitIsPlayer(unit) then
		local db = frame.db
		
		local position = db.name.position
		local x, y = self:GetPositionOffset(position)
		frame.Power.value:SetAlpha(1)
		
		frame.Name:ClearAllPoints()
		frame.Name:Point(position, frame.Health, position, x, y)	
	else
		frame.Power.value:SetAlpha(0)
		
		frame.Name:ClearAllPoints()
		frame.Name:SetPoint(frame.Power.value:GetPoint())
	end
end


function UF:GetOptionsTable_Name(updateFunc, groupName, numUnits)
	local config = {
		order = 400,
		type = 'group',
		name = L['Name'],
		get = function(info) return E.db.unitframe.units[groupName]['name'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]['name'][ info[#info] ] = value; updateFunc(self, groupName, numUnits) end,
		args = {
			position = {
				type = 'select',
				order = 2,
				name = L['Position'],
				values = self.PositionValues,
			},	
			text_format = {
				order = 100,
				name = L['Text Format'],
				type = 'input',
				width = 'full',
				desc = L['TEXT_FORMAT_DESC'],
			},					
		},
	}
	
	return config
end