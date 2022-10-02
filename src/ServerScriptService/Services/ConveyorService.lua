local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(RepStorage.Packages.Knit)
local TableUtil = require(RepStorage.Packages.TableUtil)

local ConveyorService = Knit.CreateService {
    Name = "ConveyorService",
    --Client = {} -- you probably dont want client accessing any functions
}

function ConveyorService:CreateAnimations()
    local info = TweenInfo.new(self.AnimationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    for conveyor, _ in pairs(self.Conveyors) do
        local tween = TweenService:Create(conveyor.Texture, info, {OffsetStudsV = 6})
        
        self.Animations[conveyor] = tween
    
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                conveyor.Texture.OffsetStudsV = 0
                tween:Play()
            end
        end)
    end
end

function ConveyorService:PlayAnimation()
    for conveyor, tween in pairs(self.Animations) do
        tween:Play()
    end
end

function ConveyorService:CancelAnimation()
    for conveyor, tween in pairs(self.Animations) do
        tween:Cancel()
    end
end

function ConveyorService:EnableConveyors()
    for conveyor, info in pairs(self.Conveyors) do
        local speed = if info.Speed then info.Speed else self.DefaultConveyorSpeed
        
        conveyor.AssemblyLinearVelocity = info.Direction * speed
    end

    self:PlayAnimation()
end

function ConveyorService:DisableConveyors()
    for conveyor, info in pairs(self.Conveyors) do     
        conveyor.AssemblyLinearVelocity = 0
    end

    self:CancelAnimation()
end

function ConveyorService:KnitStart()
    self.Conveyors = { -- Direction = [Unit Vector of Direction], Speed = [Optional Custom Speed]
        [game.Workspace.Map.ConveyorAway] = {
            Direction = Vector3.new(0, 0, -1)
        },
        [game.Workspace.Map.ConveyorBack] = {
            Direction = Vector3.new(0, 0, 1)
        }
    }

    self.DefaultConveyorSpeed = 100
    self.AnimationTime = 1

    self.Animations = {}

    self:CreateAnimations()
    self:EnableConveyors()
end

return ConveyorService 