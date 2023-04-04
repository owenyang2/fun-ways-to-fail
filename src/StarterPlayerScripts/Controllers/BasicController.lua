local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local BasicController = Knit.CreateController {
    Name = "BasicController"
}

function BasicController:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self.BasicService:SprintToggle(true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self.BasicService:SprintToggle(false)
        end
    end)
end

function BasicController:KnitStart()
    self.BasicService = Knit.GetService("BasicService")
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self:SetupInput()
end

return BasicController