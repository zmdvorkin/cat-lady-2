local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local _  = require(game:GetService("ReplicatedStorage").Common.utils.underscore)
local PlayerLifeCycle =  require(game:GetService("ReplicatedStorage").Common.utils.PlayerLifeCycleModule)


local count_cats = 20
local default_start_location = Vector3.new(100,0,100)

-- Can't figure out how to map to in game position, so store it externally
-- Arguably, this is closer to a view model, so it's more gooder

function PrintTopLine(txt)
  print (txt)
  -- game.Workspace.Billboard.Label1.Text = txt
end

function model_to_movable(model:IntValue)
   return model.Cat
end 


local i = 0 
function Clone(template)
    local clone = template:Clone()
    clone.Parent = game.Workspace
    clone.Name = "CLONE:" .. clone.Name  .. i 
    i = i+1
    return clone
end

function NegateRandomly(x)
    local dice = math.random()
    if dice < 0.5 then 
        return -1*x
    end
    return x
end 

function MoveOneSquareRandom(model:Model)
    old_pos = model_to_movable(model).Position
    if old_pos == nil then
        return
    end
    
    local new_pos = old_pos + Vector3.new(NegateRandomly(1),0,NegateRandomly(1))
    -- print (old_pos)
    -- print (new_pos)
    model:MoveTo(new_pos)
end

function MoveRandom(model)
    local radius = 100
    local x = math.random(-1*radius, 1*radius)
    local z = math.random(-1*radius, 1*radius)
    local location = Vector3.new(x,0,z)
    model:MoveTo(location)
end

function MoveHowZachWants(model:Model)
    DanceUpAndDown(model)
    local target_position = default_start_location
    if PlayerLifeCycle.LastCharacterSpawned ~= nil then
        target_position = PlayerLifeCycle.LastCharacterSpawned.PrimaryPart.Position
    end 
    MoveCloserToPosition(model, target_position)
end 

function MoveCloserToPosition(model, player_pos)
    old_pos = model_to_movable(model).Position
    if old_pos == nil then
        return
    end
    local delta_x=0
    local delta_z=0
    local velocity = 0.5

    if old_pos.x > player_pos.x then
        delta_x = -1* velocity
    elseif  old_pos.x < player_pos.x then
        delta_x = 1*velocity
    end 

    if old_pos.z > player_pos.z then
        delta_z = -1*velocity
    elseif  old_pos.z < player_pos.z then
        delta_z = 1*velocity
    end 

    local delta = Vector3.new (delta_x, delta_z)
    local new_pos = old_pos + delta
    model_to_movable(model).CFrame = CFrame.new(new_pos, player_pos)
end 

function DanceUpAndDown(model:IntValue)
    local old_pos = model_to_movable(model).Position
    local velocity = 1
    local the_max = 10
    local the_min = 0

    local delta_y = NegateRandomly(math.random(velocity))

    delta_y = math.min(old_pos.y + delta_y, the_max)
    delta_y = math.max(old_pos.y + delta_y, the_min)

    local new_pos = old_pos + Vector3.new(0,delta_y, 0)
    model:MoveTo(new_pos)
end


local CatService = Knit.CreateService({Name="CatService"})


function NewCrazyCatLady(character)
    PrintTopLine(character.Name .. " Is the new Cat Lady")
end

function getTemplate()
    return game.Workspace.Templates.Cat
end

function CatService:KnitStart()

    print('CatService:Start v0.3')

    PlayerLifeCycle.ConnectOnNewCharacter(NewCrazyCatLady)

    local catTemplate = getTemplate()

    -- Create Cats
    local all_cats = _.map(_.range(count_cats), function (__) return Clone(catTemplate) end)

    --  Move cats to random locations
    _.each(all_cats, MoveRandom)

    -- For Each Cat in Each Tick
    local eachTick = function (cat)
        MoveHowZachWants(cat)
    end

    -- Run the game loop forever
    while true
    do
        -- hack to make linting work by seeing 
        -- the function actually used.
        MoveHowZachWants(_.head(all_cats))
        _.each(all_cats, eachTick)
        task.wait(1)
    end 
end

return CatService