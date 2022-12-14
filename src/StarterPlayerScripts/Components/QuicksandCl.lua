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

function Quicksand:StopSink()
    if not self.Sinking then return end
    self.Sinking = false
    self._trove:Clean()

    local chr = self.Player.Character

    if chr.Humanoid.Health > 0 then
        chr:FindFirstChild("LinearVelocity"):Destroy()
        chr.Animate.Disabled = false
        self.RagdollController:EditCanRagdoll(true)
    end
end

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
    linearVelocity.LineVelocity = -self.SinkVelocity
    linearVelocity.Attachment0 = self.Player.Character.HumanoidRootPart.RootRigAttachment
    linearVelocity.Parent = chr

    chr.Animate.Disabled = true
    --chr.Humanoid.MaxSlopeAngle = 0

    self._trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.Space then -- detect mobile button later
            chr:PivotTo(chr.PrimaryPart.CFrame + Vector3.new(0, 1, 0))
        end
    end)

    self._trove:Connect(RunService.Heartbeat, function(dt)
        for _, part in ipairs(game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())) do
            if part.Parent == chr then
                return
            end
        end

        self:StopSink()
    end)

    chr.Humanoid.Died:Connect(function()
        self:StopSink()
    end)
end

function Quicksand:HeartbeatUpdate(dt)
    -- if player touches quicksand, start sinking them
    if self.Sinking or not self.Player.Character or not self.Player.Character:FindFirstChild("Humanoid") or self.Player.Character.Humanoid.Health == 0 then return end

    local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

    for _, part in ipairs(parts) do
        local chr = part.Parent
        if self.Player.Character == chr then
            task.spawn(function() -- prevent thread pausing
                self:Sink()
            end)    
        else
            task.spawn(function()
                self:StopSink()
            end)
        end        
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
    self.SinkVelocity = self.Instance:GetAttribute("SinkVelocity") or 0.7
end

return Quicksand