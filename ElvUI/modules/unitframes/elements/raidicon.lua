local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

function UF:Construct_RaidIcon(frame)
	local tex = (frame.RaisedElementParent or frame):CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]]) 
	tex:Size(18)
	tex:Point("CENTER", frame.Health, "TOP", 0, 2)
	tex.SetTexture = E.noop
	
	return tex
end

function UF:GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits)
	local config = {
		order = 5000,
		type = 'group',
		name = L['Raid Icon'],
		get = function(info) return E.db.unitframe.units[groupName]['raidicon'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]['raidicon'][ info[#info] ] = value; updateFunc(self, groupName, numUnits) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
			},	
			attachTo = {
				type = 'select',
				order = 2,
				name = L['Position'],
				values = self.PositionValues,
			},
			size = {
				type = 'range',
				name = L['Size'],
				order = 3,
				min = 8, max = 60, step = 1,
			},				
			xOffset = {
				order = 4,
				type = 'range',
				name = L['xOffset'],
				min = -300, max = 300, step = 1,
			},
			yOffset = {
				order = 5,
				type = 'range',
				name = L['yOffset'],
				min = -300, max = 300, step = 1,
			},			
		},
	}
	
	return config
end