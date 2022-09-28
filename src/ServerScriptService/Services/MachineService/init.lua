-- main control for all machine

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
        newMachine:Start()
    end
end

function MachineService:KnitStart()
    self.MachineModules = {
        script.HydraulicPress,
        script.Volcano,
    } -- modules that can be required

    self:SetupMachines()
end

return MachineService