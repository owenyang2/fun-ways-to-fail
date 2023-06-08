-- main control for all machine

--[[
Each machine should be formatted like this:

    Hole.AvailableInstances = {
        game.Workspace.PlaceModels:FindFirstChild("Hole")
    }

    function Hole.new(baseTbl)
        local newInst = baseTbl.MachineFuncs.GetAvailableInst(Hole.AvailableInstances)
        if not newInst then return end

        local self = setmetatable(TableUtil.Assign(baseTbl, {
            Instance = newInst,
            
            _trove = Trove.new()
        }), Hole)

        return self
    end
--]]

local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

local MachineFunctions = require(RepStorage.Common.MachineFunctions)

local MachineService = Knit.CreateService {
    Name = "MachineService",
    Client = {}
}

function MachineService:SetupMachines()
    for _, module in ipairs(self.MachineModules) do
        if not module:IsA("ModuleScript") then
            warn("Machine " .. module.Name .. " could not be initialized as it is not a modulescript.")
            continue
        end

        local newMachine = require(module).new({
            MachineFuncs = MachineFunctions
        }) 
        print(module.Name)
        newMachine:Start()
    end
end

function MachineService:KnitStart()
    self.MachineModules = {
        script.HydraulicPress,
        script.Volcano,
        script.Hole,
        script.Saw,
        script.Quicksand,
        script.Cooking,
        script.Potion,
        script.Food,
        script.IceLake,
        script.Rocket,
        script.Cannon,
        script.AppleTree
    } -- modules that can be required

    self:SetupMachines()
end

return MachineService