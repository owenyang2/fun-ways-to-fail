local Players = game:GetService("Players")
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

function BasicController:SetupLClothing()
    -- layered clothing doesn't scale properly when modifying bodyscale on server, 
    -- thus if one changed get correct layered clothing size and replicate to client

    local function propertyChanged()
        print("detected prop change")
        local sizes = self.BasicService:GetLClothingSize()

        print(sizes)

        for name, size in pairs(sizes) do
            local acc = self.Player.Character:FindFirstChild(name)

            print(acc)
            if acc and acc.Handle.Size ~= size then
                acc.Handle.Size = size
                print("changed")
            end
        end
    end

    self.Player.CharacterAdded:Connect(function(chr)
        for _, prop in ipairs(chr:WaitForChild("Humanoid"):GetChildren()) do
            if prop:IsA("NumberValue") then
                prop.Changed:Connect(propertyChanged)
            end
        end
    end)
end

function BasicController:KnitStart()
    self.BasicService = Knit.GetService("BasicService")
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self:SetupInput()
    self:SetupLClothing()
end

return BasicController