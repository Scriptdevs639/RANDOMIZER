local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local player = Players.LocalPlayer

    local espEnabled, autoRunning = true, false
    local truePetMap = {}

    -- 🐾 Pet Table
    local petTable = {
        ["Common Egg"] = { "Dog", "Bunny", "Golden Lab" },
        ["Uncommon Egg"] = { "Chicken", "Black Bunny", "Cat", "Deer" },
        ["Rare Egg"] = { "Pig", "Monkey", "Rooster", "Orange Tabby", "Spotted Deer" },
        ["Legendary Egg"] = { "Cow", "Polar Bear", "Sea Otter", "Turtle", "Silver Monkey" },
        ["Mythical Egg"] = { "Grey Mouse", "Brown Mouse", "Squirrel", "Red Fox", "Red Giant Ant" },
        ["Bug Egg"] = { "Snail", "Caterpillar", "Giant Ant", "Praying Mantis", "Dragonfly" },
        ["Bee Egg"] = { "Bee", "Honey Bee", "Bear Bee", "Petal Bee" },
        ["Anti Bee Egg"] = { "Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee" },
        ["Common Summer Egg"] = { "Starfish", "Seagull", "Crab" },
        ["Rare Summer Egg"] = { "Sea Turtle", "Flamingo", "Toucan", "Seal", "Orangutan" },
        ["Oasis Egg"] = { "Meerkat", "Sand Snake", "Axolotl" },
        ["Paradise Egg"] = { "Ostrich", "Peacock", "Capybara", "Mimic Octopus"},
        ["Dinosaur Egg"] = { "Raptor", "Triceratops", "Stegosaurus", "T-Rex", "Pterodactyl", "Brontosaurus" },
        ["Primal Egg"] = { "Spinosaurus", "Ankylosaurus", "Dilophosaurus", "Parasaurolophus", "Iguanodon" },
        ["Night Egg"] = { "Frog", "Hedgehog", "Mole", "Echo Frog", "Night Owl" },
        ["Zen Egg"] = { "Shiba Inu", "Nihonzaru", "Tanuki", "Tanchozuru", "Kappa", "Kitsune" },
        ["Gourmet Egg"] = { "Bagel Bunny", "Pancake Mole", "Sushi Bear", "Spaghetti Sloth", "French Fry Ferret" }
    }

    -- 👁 ESP
    local function applyESP(eggModel, petName)
        if not espEnabled then return end
        if eggModel:FindFirstChild("PetBillboard", true) then eggModel:FindFirstChild("PetBillboard", true):Destroy() end
        local base = eggModel:FindFirstChildWhichIsA("BasePart")
        if not base then return end

        local billboard = Instance.new("BillboardGui", base)
        billboard.Name = "PetBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 4, 0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = eggModel.Name .. " | " .. petName
        label.TextScaled = true
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.FredokaOne
        label.TextStrokeTransparency = 0.2
    end
    local function removeESP(eggModel)
        if eggModel:FindFirstChild("PetBillboard", true) then eggModel:FindFirstChild("PetBillboard", true):Destroy() end
    end

    -- 🔍 Find Eggs
    local function getNearbyEggs(radius)
        local eggs = {}
        local root = (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and petTable[obj.Name] then
                local base = obj:FindFirstChildWhichIsA("BasePart")
                if base then
                    local dist = (base.Position - root.Position).Magnitude
                    if dist <= (radius or 60) then
                        if not truePetMap[obj] then
                            local pets = petTable[obj.Name]
                            truePetMap[obj] = pets[math.random(1, #pets)]
                        end
                        table.insert(eggs, obj)
                    end
                end
            end
        end
        return eggs
    end

    -- 🎲 Randomizer
    local function randomizeEggs()
        for _, egg in ipairs(getNearbyEggs(60)) do
            local pets = petTable[egg.Name]
            local chosen = pets[math.random(1, #pets)]
            truePetMap[egg] = chosen
            applyESP(egg, chosen)
        end
    end

    -- ✅ Rayfield Setup
    local RF = Rayfield or loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = RF:CreateWindow({
        Name = "Pet Randomizer by Kuni",
        LoadingTitle = "Grow A Garden",
        LoadingSubtitle = "Pet ESP + Randomizer",
        KeySystem = false,
    })

    local Tab = Window:CreateTab("Randomizer")

    -- 🎲 Manual Randomizer Button
    Tab:CreateButton({
        Name = "Randomize Pets (Nearby)",
        Callback = function()
            randomizeEggs()
            RF:Notify({
                Title = "Pets Randomized",
                Content = "Nearby eggs were assigned random pets!",
                Duration = 4
            })
        end,
    })

    -- ⚙️ Auto Randomizer Toggle
    Tab:CreateToggle({
        Name = "Auto Randomize",
        CurrentValue = false,
        Flag = "AutoRandomize",
        Callback = function(Value)
            autoRunning = Value
            task.spawn(function()
                while autoRunning do
                    randomizeEggs()
                    task.wait(3)
                end
            end)
        end,
    })

    -- 👁 ESP Toggle
    Tab:CreateToggle({
        Name = "Show ESP",
        CurrentValue = true,
        Flag = "PetESP",
        Callback = function(Value)
            espEnabled = Value
            for _, egg in pairs(getNearbyEggs(60)) do
                if espEnabled then
                    applyESP(egg, truePetMap[egg])
                else
                    removeESP(egg)
                end
            end
        end,
    })

    -- Footer info
    RF:Notify({
        Title = "Pet Randomizer Loaded",
        Content = "Made by Kuni | TikTok: @yawiyawiyawiz1",
        Duration = 6,
    })
end
