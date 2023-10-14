local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local ClientComm = require(RepStorage.Packages.Comm).ClientComm
local clientComm = ClientComm.new(RepStorage, false, "MoveRepl")
local comm = clientComm:BuildObject()

local MachineFuncs = require(RepStorage.Common.MachineFunctions)

local FollowController = Knit.CreateController {
    Name = "FollowController"
}

function FollowController:Follow(followingInst, updateSignal, targetPart, lerpInc, dmg, negateY)
    -- set defaults -----------------
    targetPart = targetPart or self.Player.Character.HumanoidRootPart
    lerpInc = lerpInc or 0.02
    dmg = dmg or self.Player.Character.Humanoid.MaxHealth
    -----------------------------------

    local chr = self.Player.Character
    local newTrove = Trove.new()

    newTrove:Add(task.spawn(function()
        while followingInst do
            for i = 0, 1, lerpInc do
                local targetCF = targetPart.CFrame

                if negateY then
                    targetCF -= Vector3.new(0, targetCF.Position.Y, 0) -- set y to 0
                    targetCF += Vector3.new(0, followingInst.CFrame.Position.Y, 0) -- keep y constant
                end

                followingInst.CFrame = followingInst.CFrame:Lerp(targetCF, i)
                updateSignal:Fire(followingInst.CFrame, "Move")
                task.wait()
            end
            task.wait()
        end
    end))

    newTrove:Add(function() -- cleanup
        followingInst.CanCollide = true
        followingInst.Anchored = false

        local tempTrove = Trove.new()
        tempTrove:Add(task.spawn(function()
            local count = 0
            
            while count < game.Players.RespawnTime + 0.5 do
                local start = os.time()
                updateSignal:Fire(followingInst.CFrame, "Move")
                task.wait(0.1)
                count += os.time() - start
            end

            followingInst:Destroy()
            updateSignal:Fire(CFrame.new(), "Destroy")
        end))
    end)

    local dbCounter = self.DmgDB

    newTrove:Connect(RunService.Heartbeat, function(dt)
        if dbCounter < self.DmgDB then -- add delay in damage
            dbCounter += dt
            return
        end

        local parts = game.Workspace:GetPartsInPart(followingInst, MachineFuncs.GetHitboxParams())

        for _, part in ipairs(parts) do
            local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
            if not plr or plr ~= self.Player then continue end

            plr.Character.Humanoid:TakeDamage(dmg)
            dbCounter = 0

            print(plr.Character.Humanoid.Health)

            if plr.Character.Humanoid.Health == 0 then
                newTrove:Clean()
            end
            
            break
        end
    end)
end


function FollowController:Setup()
    local placeModels = game.Workspace.PlaceModels

    print("init receive")

    -- connections -----------------------
    comm.DropApple:Connect(function()
        local newApple = RepStorage.Assets.Apple:Clone()
        newApple.CFrame = placeModels.AppleTree.Apple.CFrame
        newApple.Anchored = true
        newApple.Parent = placeModels.AppleTree
        newApple.Name = self.Player.Name .. "AppleCl"

        self:Follow(newApple, comm.DropApple, self.Player.Character.Head, 0.02)
    end)

    comm.SendPiranha:Connect(function(origCF)
        print("received")

        local newPiranha = RepStorage.Assets.Piranha:Clone()
        newPiranha.CFrame = origCF
        newPiranha.Anchored = true
        newPiranha.Name = self.Player.Name .. "PiranhaCl"
        newPiranha.Parent = placeModels.Piranhas.ReplicatedFish

        self:Follow(newPiranha, comm.SendPiranha, self.Player.Character.HumanoidRootPart, 0.01, 10, true)
    end)

    --------------------------------------

    local targetMachines = {
        placeModels.AppleTree,
        placeModels.Piranhas.ReplicatedFish
    }

    local autoDelete = {
        "Apple", 
        "Piranha"
    }

    for _, machine in ipairs(targetMachines) do
        machine.ChildAdded:Connect(function(obj)
            -- serverside apple for all other clients, although in the future maybe change to a fireallclients for a smooth experience for all
            local found = false
    
            for _, name in ipairs(autoDelete) do
                if obj.Name == (self.Player.Name .. name .. "Sv") then
                    found = true
                    break
                end
            end
            
            if found then
                task.wait(0.1)
                obj:Destroy()
            end
        end)    
    end
end

function FollowController:KnitStart()
    local placeModels = game.Workspace.PlaceModels

    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self.DmgDB = 0.5 -- how long until can be damaged again

    self:Setup()
end

return FollowController