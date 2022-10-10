local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local RagdollController = Knit.CreateController {
    Name = "RagdollController"
}

function RagdollController:Toggle(enable)
    if not self.RagdollService:CheckCanRagdoll() then return end

    self.RagdollService:ToggleRagdoll(enable)

    if self.RagdollService:GetRagdollStatus() then
        self.Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        self._trove:Connect(self.Player.Character.Humanoid.Died, function()
            self.RagdollService.Reset:Fire() -- because normal resetting doesn't kill, player, have to manually kill player on server
            self._trove:Clean()
        end)
    else
        self._trove:Clean()
        self.Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

function RagdollController:EditCanRagdoll(canRagdoll)
    self.RagdollService:EditCanRagdoll(canRagdoll)
end

function RagdollController:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not self.Player.Character then return end
        
        if input.KeyCode == Enum.KeyCode.R and not gameProcessed then
            self:Toggle()
        end
    end)
end

function RagdollController:KnitStart()
    self.RagdollService = Knit.GetService("RagdollService")
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self:SetupInput()
end

return RagdollController