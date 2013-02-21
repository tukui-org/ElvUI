local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

function UF:Construct_Portrait(frame, type)
	local portrait
	
	if type == 'texture' then
		local backdrop = CreateFrame('Frame',nil,frame)
		portrait = frame:CreateTexture(nil, 'OVERLAY')
		portrait:SetTexCoord(0.15,0.85,0.15,0.85)
		backdrop:SetOutside(portrait)
		backdrop:SetFrameLevel(frame:GetFrameLevel())
		backdrop:SetTemplate('Default')
		portrait.backdrop = backdrop	
	else
		portrait = CreateFrame("PlayerModel", nil, frame)
		portrait:SetFrameStrata('LOW')
		portrait:CreateBackdrop('Default')
	end
	
	portrait.PostUpdate = self.PortraitUpdate

	portrait.overlay = CreateFrame("Frame", nil, frame)
	portrait.overlay:SetFrameLevel(frame:GetFrameLevel() - 5)
	
	return portrait
end

function UF:PortraitUpdate(unit)
	local db = self:GetParent().db
	
	if not db then return end
	
	local portrait = db.portrait
	if portrait.enable and portrait.overlay then
		self:SetAlpha(0); 
		self:SetAlpha(0.35);
	else
		self:SetAlpha(1)
	end
	
	if self:GetObjectType() ~= 'Texture' then
		local model = self:GetModel()
		if model and model.find and model:find("worgenmale") then
			self:SetCamera(1)
		end	

		self:SetCamDistanceScale(portrait.camDistanceScale - 0.01 >= 0.01 and portrait.camDistanceScale - 0.01 or 0.01) --Blizzard bug fix
		self:SetCamDistanceScale(portrait.camDistanceScale)
	end
end

function UF:GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = {
		order = 400,
		type = 'group',
		name = L['Portrait'],
		get = function(info) return E.db.unitframe.units[groupName]['portrait'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]['portrait'][ info[#info] ] = value; updateFunc(self, groupName, numUnits) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
			},
			width = {
				type = 'range',
				order = 2,
				name = L['Width'],
				min = 15, max = 150, step = 1,
			},
			overlay = {
				type = 'toggle',
				name = L['Overlay'],
				desc = L['Overlay the healthbar'],
				order = 3,
			},
			camDistanceScale = {
				type = 'range',
				name = L['Camera Distance Scale'],
				desc = L['How far away the portrait is from the camera.'],
				order = 4,
				min = 0.01, max = 4, step = 0.01,
			},
			style = {
				type = 'select',
				name = L['Style'],
				desc = L['Select the display method of the portrait.'],
				order = 5,
				values = {
					['2D'] = L['2D'],
					['3D'] = L['3D'],
				},
			},
		},
	}

	return config
end