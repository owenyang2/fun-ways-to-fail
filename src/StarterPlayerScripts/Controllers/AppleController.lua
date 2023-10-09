local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local ClientComm = require(RepStorage.Packages.Comm).ClientComm
local clientComm = ClientComm.new(RepStorage, false, "AppleTree")
local comm = clientComm:BuildObject()

local MachineFuncs = require(RepStorage.Common.MachineFunctions)

local AppleController = Knit.CreateController {
    Name = "AppleController"
}

function AppleController:SpawnApple()
    local chr = self.Player.Character

    local newApple = RepStorage.Assets.Apple:Clone()
    newApple.CFrame = self.Instance.Apple.CFrame
    newApple.Anchored = true
    newApple.Parent = self.Instance
    newApple.Name = self.Player.Name .. "AppleCl"

    local newTrove = Trove.new()

    newTrove:Add(task.spawn(function()
        while newApple do
            for i = 0, 1, 0.02 do
                newApple.CFrame = newApple.CFrame:Lerp(self.Player.Character.Head.CFrame, i)
                comm.DropApple:Fire(newApple.CFrame, "Move")
                task.wait()
            end
            task.wait()
        end
    end))

    newTrove:Add(function() -- cleanup apple
        newApple.CanCollide = true
        newApple.Anchored = false

        local tempTrove = Trove.new()
        tempTrove:Add(task.spawn(function()
            local count = 0
            
            while count < game.Players.RespawnTime + 0.5 do
                local start = os.time()
                comm.DropApple:Fire(newApple.CFrame, "Move")
                task.wait(0.1)
                count += os.time() - start
            end

            newApple:Destroy()
            comm.DropApple:Fire(CFrame.new(), "Destroy")
            print('end')
        end))
    end)

    newTrove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(newApple, MachineFuncs.GetHitboxParams())

        for _, part in ipairs(parts) do
            print(part.Parent)
            local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
            if not plr or plr ~= self.Player then continue end

            print('kill')

            plr.Character.Humanoid.Health = 0
            newTrove:Clean()
            break
        end
    end)
end

function AppleController:Setup()
    comm.DropApple:Connect(function()
        self:SpawnApple()
    end)

    self.Instance.ChildAdded:Connect(function(obj)
        -- serverside apple for all other clients, although in the future maybe change to a fireallclients for a smooth experience for all
        if obj.Name == (self.Player.Name .. "AppleSv") then
            task.wait(0.1)
            obj:Destroy()
        end
    end)
end

function AppleController:KnitStart()
    self.Player = game.Players.LocalPlayer
    self.Instance = game.Workspace.PlaceModels:FindFirstChild("AppleTree")
    self._trove = Trove.new()

    self:Setup()
end

return AppleController