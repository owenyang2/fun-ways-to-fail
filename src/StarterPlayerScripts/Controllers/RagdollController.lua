local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(RepStorage.Packages.Knit)

local RagdollController = Knit.CreateController {
    Name = "RagdollController"
}

function RagdollController:Toggle(enable)
    self.RagdollService:ToggleRagdoll(enable)

    if self.RagdollService:GetRagdollStatus() then
        self.Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    else
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

    self:SetupInput()
end

return RagdollController