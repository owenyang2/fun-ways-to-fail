local RepStorage = game:GetService("ReplicatedStorage")

local Knit = require(RepStorage.Packages.Knit)

Knit.AddControllersDeep(script.Parent.Controllers)

local initList = {
    script.Parent.Components,
    --script.Parent.Subroutines,
}

Knit.Start({ServicePromises = false}):andThen(function()
    for _, path in ipairs(initList) do
        for _, s in ipairs(path:GetChildren()) do
            require(s)
        end
    end
end):catch(warn)