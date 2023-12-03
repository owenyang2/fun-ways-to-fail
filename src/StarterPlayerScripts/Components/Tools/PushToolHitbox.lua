local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local Trove = require(RepStorage.Packages.Trove)

local PushTool = Component.new {
    Tag = "PushToolHitbox"
}

function PushTool:SetupConnections()
    self.Instance.Activated:Connect(function()
        print("pushed")
        if self.Player.Character then
            self.ToolService:PushToolActivated("Push")
        end
    end)
end

function PushTool:Stop()
    self._trove:Destroy()
end

function PushTool:Start()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self.Mouse = self.Player:GetMouse()
    self.ToolService = Knit.GetService("ToolService")

    self.BasicController = Knit.GetController("BasicController")

    self:SetupConnections()
end

return PushTool