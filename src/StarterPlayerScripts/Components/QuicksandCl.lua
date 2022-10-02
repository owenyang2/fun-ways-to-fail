-- setup remote communications tracking keybinds to get out
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local Quicksand = Component.new {
    Tag = "Quicksand"
}

function Quicksand:Sink()
    if self.Sinking then return end
    self.Sinking = true
    print("sink")

    local chr = self.Player.Character

    task.spawn(function()
        self.RagdollController:Toggle(false)
        self.RagdollController:EditCanRagdoll(false)    
    end)

    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
    linearVelocity.LineDirection = Vector3.new(0, 1, 0)
    linearVelocity.MaxForce = 100000
    linearVelocity.LineVelocity = -0.7
    linearVelocity.Attachment0 = self.Player.Character.HumanoidRootPart.RootRigAttachment
    linearVelocity.Parent = chr

    chr.Animate.Disabled = true

    chr.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    self._trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.Space then -- detect mobile button later
            chr:PivotTo(chr.PrimaryPart.CFrame + Vector3.new(0, 1, 0))
        end
    end)

    chr.Humanoid.Died:Connect(function()
        self.Sinking = false
        self._trove:Clean()
    end)
end

function Quicksand:HeartbeatUpdate(dt)
    -- if player touches quicksand, start sinking them
    if self.Sinking or not self.Player.Character or self.Player.Character.Humanoid.Health == 0 then return end

    local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

    for _, part in ipairs(parts) do
        local chr = part.Parent
        local plr = game.Players:GetPlayerFromCharacter(chr)
        if not plr or self.Player ~= plr then return end
        
        task.spawn(function() -- prevent thread pausing
            self:Sink()
        end)
    end
end

function Quicksand:Stop()
    self._trove:Destroy()
end

function Quicksand:Start()
    self.Player = game.Players.LocalPlayer
    self.RagdollController = Knit.GetController("RagdollController")
    self.Sinking = false
    self._trove = Trove.new()
end

return Quicksand