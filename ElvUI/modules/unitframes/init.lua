local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

function E.LoadLayout(layout)
	for name, func in pairs(E.Layouts) do
		if name == layout then
			func() 
			E.LoadLayout = nil --only load 1 layout
			wipe(E.Layouts) --only load 1 layout
			break
		end
	end
end
E.LoadLayout(C["general"].layoutoverride)