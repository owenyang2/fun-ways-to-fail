local HydraulicPress = {}
HydraulicPress.__index = {}

HydraulicPress.AvailablePresses = {game.Workspace.PlaceModels.Place1} -- available presses

local function getAvailablePress()
    if #HydraulicPress.AvailablePresses == 0 then warn("No available hydraulic presses to set up.") return end

    local press = HydraulicPress.AvailablePresses[#HydraulicPress.AvailablePresses]
    table.remove(HydraulicPress.AvailablePresses[#HydraulicPress.AvailablePresses])
    return press
end

function HydraulicPress:Start()
    -- start
end

function HydraulicPress.new()
    local press = getAvailablePress()
    if not press then return end

    local newHydraulicPress = setmetatable({
        Instance = press
    }, HydraulicPress)

    return newHydraulicPress
end

return HydraulicPress