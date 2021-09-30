local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

AB.barDefaults.bar1.conditions = format('[overridebar] %d; [vehicleui] %d; [possessbar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetOverrideBarIndex(), GetVehicleBarIndex(), GetVehicleBarIndex())
