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
    print("setuped")
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
            self.BasicService:SprintToggle(true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
            self.BasicService:SprintToggle(false)
        end
    end)
end

function BasicController:SetupLClothing()
    -- layered clothing doesn't scale properly when modifying bodyscale on server, 
    -- thus if one changed get correct layered clothing size and replicate to client

    -- nvm this isn't really needed as roblox replication has same size but different visual

    local function propertyChanged()
        print("detected prop change")
        local sizes = self.BasicService:GetLClothingSize()

        for name, size in pairs(sizes) do
            local acc = self.Player.Character:FindFirstChild(name)

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

function BasicController:PlayAnim(id, animProperties) -- in the future, maybe preload animations
    animProperties = animProperties or {}

    local chr = self.Player.Character
    local animator = chr.Humanoid:WaitForChild("Animator")

    local anim = Instance.new("Animation")
    anim.AnimationId = id

    local animTrack = animator:LoadAnimation(anim)

    for name, val in pairs(animProperties) do
        animTrack[name] = val
    end

    animTrack:Play()

    return animTrack
end

function BasicController:SetupAnimPlayer()
    self.BasicService.PlayAnim:Connect(function(id, animProperties)
        self:PlayAnim(id, animProperties)
    end)
end

function BasicController:KnitStart()
    self.BasicService = Knit.GetService("BasicService")
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self:SetupInput()
    self:SetupAnimPlayer()
end

return BasicController