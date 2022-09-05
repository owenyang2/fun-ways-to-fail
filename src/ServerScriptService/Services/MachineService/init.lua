-- main control for all machine

local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

local MachineService = Knit.CreateService {
    Name = "MachineService",
    Client = {}
}

function MachineService:SetupMachines()
    for _, module in ipairs(self.MachineModules) do
        local newMachine = require(module).new()
        newMachine:Start()
    end
end

function MachineService:KnitStart()
    self.MachineModules = {
        script.HydraulicPress
    } -- modules that can be required

    self:SetupMachines()
end

return MachineService