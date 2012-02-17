local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local datatexts = {}

function DT:PanelLayoutOptions()	
	for name, _ in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = name
	end
	datatexts[''] = ''
	
	for i = 1, 2 do
		local table = E.Options.args.datatexts.args['spec'..i].args
		for pointLoc, tab in pairs(E.db.datatexts.panels['spec'..i]) do
			if not _G[pointLoc] then E.db.datatexts.panels['spec'..i][pointLoc] = nil; return; end
			if type(tab) == 'table' then
				table[pointLoc] = {
					type = 'group',
					args = {},
					name = L[pointLoc] or pointLoc,
					guiInline = true,
					order = i + -10,
				}			
				for option, value in pairs(tab) do
					table[pointLoc].args[option] = {
						type = 'select',
						name = L[option] or option:upper(),
						values = datatexts,
						get = function(info) return E.db.datatexts.panels['spec'..i][pointLoc][ info[#info] ] end,
						set = function(info, value) E.db.datatexts.panels['spec'..i][pointLoc][ info[#info] ] = value; DT:LoadDataTexts() end,									
					}
				end
			elseif type(tab) == 'string' then
				table[pointLoc] = {
					type = 'select',
					name = L[pointLoc] or pointLoc,
					values = datatexts,
					get = function(info) return E.db.datatexts.panels['spec'..i][pointLoc] end,
					set = function(info, value) E.db.datatexts.panels['spec'..i][pointLoc] = value; DT:LoadDataTexts() end,	
				}						
			end
		end
	end
end

E.Options.args.datatexts = {
	type = "group",
	name = L["DataTexts"],
	childGroups = "select",
	get = function(info) return E.db.datatexts[ info[#info] ] end,
	set = function(info, value) E.db.datatexts[ info[#info] ] = value; DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"],
		},
		specswap = {
			order = 2,
			type = "toggle",
			name = L["Multi-Spec Swap"],
			desc = L['Swap to an alternative layout when changing talent specs. If turned off only the spec #1 layout will be used.'],
		},
		time24 = {
			order = 3,
			type = 'toggle',
			name = L['24-Hour Time'],
			desc = L['Toggle 24-hour mode for the time datatext.'],
		},
		localtime = {
			order = 4,
			type = 'toggle',
			name = L['Local Time'],
			desc = L['If not set to true then the server time will be displayed instead.'],
		},
		spec1 = {
			type = 'group',
			name = L['Primary Talents'],
			order = 100,	
			args = {},
		},
		spec2 = {
			type = 'group',
			name = L['Secondary Talents'],
			order = 200,				
			args = {},		
			disabled = function() return not E.db.datatexts.specswap end,
		},
	},
}