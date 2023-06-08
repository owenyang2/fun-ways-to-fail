local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

Knit.AddServicesDeep(script.Parent.Services)

local initList = {
    script.Parent:WaitForChild("Components"),
    --script.Parent.Subroutines,
}

Knit.Start():andThen(function()
    for _, path in ipairs(initList) do
        for _, s in ipairs(path:GetChildren()) do
            require(s)
        end
    end
end):catch(warn)