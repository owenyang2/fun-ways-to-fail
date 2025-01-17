local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

Knit.AddServicesDeep(script.Parent.Services)

local initList = {
    script.Parent:WaitForChild("Components"),
    --script.Parent.Subroutines,
}

Knit.Start():andThen(function()
    for _, path in ipairs(initList) do
        for _, s in ipairs(path:GetDescendants()) do
            if s:IsA("ModuleScript") then
                require(s)
            end
        end
    end
end):catch(warn)