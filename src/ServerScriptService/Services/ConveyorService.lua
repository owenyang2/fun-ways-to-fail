local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

local ConveyorService = Knit.CreateService {
    Name = "ConveyorService",
    --Client = {} -- you probably dont want client accessing any functions
}

function ConveyorService:EnableConveyors()
    for conveyor, info in pairs(self.Conveyors) do
        local speed = if info.Speed then info.Speed else self.DefaultConveyorSpeed
        
        conveyor.AssemblyLinearVelocity = info.Direction * speed
    end
end

function ConveyorService:DisableConveyors()
    for conveyor, info in pairs(self.Conveyors) do     
        conveyor.AssemblyLinearVelocity = 0
    end
end

function ConveyorService:KnitStart()
    self.Conveyors = { -- Direction = [Unit Vector of Direction], Speed = [Optional Custom Speed]
        [game.Workspace.ConveyorAway] = {
            Direction = Vector3.new(0, 0, -1)
        },
        [game.Workspace.ConveyorBack] = {
            Direction = Vector3.new(0, 0, 1)
        }
    }

    self.DefaultConveyorSpeed = 100

    self:EnableConveyors()
end

return ConveyorService 