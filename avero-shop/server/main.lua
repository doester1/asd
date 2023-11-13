ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

function setCredits(identifier, credits)
    MySQL.Async.execute(
        "UPDATE `users` SET `credits`= @credits WHERE `identifier` = @identifier",
        {["@credits"] = credits, ["@identifier"] = identifier},
        function()
        end
    )
end

function getTasks(identifier)
    local tasks = ""

    tasks =
        MySQL.Sync.fetchScalar(
        "SELECT `tasks` FROM users WHERE identifier = @identifier ",
        {["@identifier"] = identifier}
    )

    if tasks == "" then
        tasks = {}
    else
        tasks = json.decode(tasks)
    end

    return tasks
end

function getWinnings(identifier)
    local winnings = ""

    winnings =
        MySQL.Sync.fetchScalar(
        "SELECT `winnings` FROM users WHERE identifier = @identifier ",
        {["@identifier"] = identifier}
    )

    if winnings == "" then
        winnings = {}
    else
        winnings = json.decode(winnings)
    end

    return winnings
end

function getCredits(identifier)
    return tonumber(
        MySQL.Sync.fetchScalar(
            "SELECT `credits` FROM users WHERE identifier = @identifier ",
            {["@identifier"] = identifier}
        )
    )
end

function giveCredits(identifier, credits)
    MySQL.Async.execute(
        "UPDATE `users` SET `credits`= `credits` + @credits WHERE `identifier` = @identifier",
        {["@credits"] = credits, ["@identifier"] = identifier},
        function()
        end
    )
end

RegisterServerEvent("core_credits:redeem")
AddEventHandler(
    "core_credits:redeem",
    function(item)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        MySQL.Async.fetchScalar(
            "SELECT `winnings` FROM users WHERE identifier = @identifier ",
            {["@identifier"] = xPlayer.identifier},
            function(data)
                local winnings = json.decode(data)

                if winnings[item] > 1 then
                    winnings[item] = winnings[item] - 1
                else
                    winnings[item] = nil
                end

                MySQL.Async.execute(
                    "UPDATE `users` SET `winnings`= @item WHERE `identifier` = @identifier",
                    {["@item"] = json.encode(winnings), ["@identifier"] = xPlayer.identifier},
                    function()
                        local caseItem = Config.CaseOpeningItems[item]

                        if caseItem.type == "car" then
                            local plate =
                                math.random(0, 9) ..
                                math.random(0, 9) ..
                                    math.random(0, 9) ..
                                        math.random(0, 9) ..
                                            math.random(0, 9) ..
                                                math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9)
                            local mods =
                                '{"neonEnabled":[false,false,false,false],"modFrame":-1,"modEngine":3,"engineHealth":1000.0,"modSideSkirt":-1,"modFrontBumper":-1,"modOrnaments":-1,"health":995,"modGrille":-1,"modTransmission":2,"plate":"' ..
                                plate ..
                                    '","modTrimB":-1,"fuelLevel":45.91801071167,"modDoorSpeaker":-1,"windows":[1,false,false,false,false,1,1,1,1,false,1,false,false],"modSpeakers":-1,"modAerials":-1,"modTurbo":1,"pearlescentColor":67,"modVanityPlate":-1,"modSpoilers":-1,"modAirFilter":-1,"modArchCover":-1,"tyreSmokeColor":[255,255,255],"modEngineBlock":-1,"modHood":-1,"modRightFender":-1,"bodyHealth":997.25,"dirtLevel":4.0228095054626,"wheels":0,"modPlateHolder":-1,"modBrakes":2,"wheelColor":156,"modSteeringWheel":-1,"modFender":-1,"color2":62,"color1":9,"neonColor":[255,0,255],"modExhaust":-1,"modDial":-1,"model":' ..
                                        GetHashKey(caseItem.model) ..
                                            ',"plateIndex":1,"windowTint":3,"modBackWheels":-1,"tyres":[false,false,false,false,false,false,false],"modTank":-1,"modHydrolic":-1,"modSmokeEnabled":1,"modRearBumper":-1,"modArmor":4,"modFrontWheels":-1,"modRoof":-1,"extras":[],"modAPlate":-1,"modXenon":1,"modLivery":-1,"modDashboard":-1,"modShifterLeavers":-1,"modTrimA":-1,"modTrunk":-1,"modHorns":-1,"modSeats":-1,"modSuspension":3,"modStruts":-1,"modWindows":-1,"doors":[false,false,false,false,false,false]}'

                            MySQL.Async.execute(
                                "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
                                {
                                    ["@owner"] = xPlayer.identifier,
                                    ["@plate"] = plate,
                                    ["@vehicle"] = mods
                                },
                                function(rowsChanged)
                                end
                            )
                        elseif caseItem.type == "item" then
                            xPlayer.addInventoryItem(caseItem.item, caseItem.count)
                        elseif caseItem.type == "weapon" then
                            xPlayer.addWeapon(caseItem.weapon, caseItem.ammo)
                        elseif caseItem.type == "money" then
                            xPlayer.addAccountMoney("bank", caseItem.money)
                        elseif caseItem.type == "credits" then
                            giveCredits(xPlayer.identifier, caseItem.credits)
                        else
                            TriggerClientEvent("core_credits:sendMessage", src, "Item type does not exist")
                        end

                        TriggerClientEvent("core_credits:sendMessage", src, Config.Text["item_redeemed"])
                        TriggerClientEvent("core_credits:updateCredits", src)
                    end
                )
            end
        )
    end
)

RegisterServerEvent("core_credits:taskCompleted")
AddEventHandler(
    "core_credits:taskCompleted",
    function(task)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        TriggerClientEvent("core_credits:sendMessage", src, Config.Text["task_completed"])
        giveCredits(xPlayer.identifier, task.reward)
        TriggerClientEvent("core_credits:updateCredits", src)
    end
)

RegisterServerEvent("core_credits:updateTasks")
AddEventHandler(
    "core_credits:updateTasks",
    function(tasks)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        MySQL.Async.execute(
            "UPDATE `users` SET `tasks_completed`= @tasks WHERE `identifier` = @identifier",
            {["@tasks"] = json.encode(tasks), ["@identifier"] = xPlayer.identifier},
            function()
            end
        )
    end
)

RegisterServerEvent("core_credits:exchange")
AddEventHandler(
    "core_credits:exchange",
    function(item)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        MySQL.Async.fetchScalar(
            "SELECT `winnings` FROM users WHERE identifier = @identifier ",
            {["@identifier"] = xPlayer.identifier},
            function(data)
                local winnings = json.decode(data)

                if winnings[item] > 1 then
                    winnings[item] = winnings[item] - 1
                else
                    winnings[item] = nil
                end

                MySQL.Async.execute(
                    "UPDATE `users` SET `winnings`= @item WHERE `identifier` = @identifier",
                    {["@item"] = json.encode(winnings), ["@identifier"] = xPlayer.identifier},
                    function()
                        giveCredits(xPlayer.identifier, Config.CaseOpeningItems[item].exchange)
                        TriggerClientEvent("core_credits:sendMessage", src, Config.Text["item_exchanged"])
                        TriggerClientEvent("core_credits:updateCredits", src)
                    end
                )
            end
        )
    end
)

RegisterServerEvent("core_credits:addWinning")
AddEventHandler(
    "core_credits:addWinning",
    function(item)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        MySQL.Async.fetchScalar(
            "SELECT `winnings` FROM users WHERE identifier = @identifier ",
            {["@identifier"] = xPlayer.identifier},
            function(data)
                local winnings = json.decode(data)

                if winnings == nil then
                    winnings = {}
                end

                if not winnings[item] then
                    winnings[item] = 0
                end
                winnings[item] = winnings[item] + 1

                MySQL.Async.execute(
                    "UPDATE `users` SET `winnings`= @item WHERE `identifier` = @identifier",
                    {["@item"] = json.encode(winnings), ["@identifier"] = xPlayer.identifier},
                    function()
                        TriggerClientEvent("core_credits:updateCredits", src)
                    end
                )
            end
        )
    end
)

RegisterServerEvent("core_credits:removeCredits")
AddEventHandler(
    "core_credits:removeCredits",
    function(c)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        setCredits(xPlayer.identifier, getCredits(xPlayer.identifier) - c)
    end
)

RegisterServerEvent("core_credits:progressTask")
AddEventHandler(
    "core_credits:progressTask",
    function(task, progress)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        local tasks =
            MySQL.Sync.fetchScalar(
            "SELECT `tasks` FROM users WHERE identifier = @identifier ",
            {["@identifier"] = xPlayer.identifier
        })

        if tasks == "" then
            tasks = {}
        else
            tasks = json.decode(tasks)
        end

        if tasks[task] then
            tasks[task] = tasks[task] + progress
        else
            tasks[task] = progress
        end

        MySQL.Async.execute(
            "UPDATE `users` SET `tasks`= @tasks WHERE `identifier` = @identifier",
            {["@tasks"] = json.encode(tasks), ["@identifier"] = xPlayer.identifier},
            function()
            end
        )
    end
)

RegisterServerEvent("core_credits:buyItem")
AddEventHandler(
    "core_credits:buyItem",
    function(item)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local shopItem = Config.Shop[item]

        local credits = getCredits(xPlayer.identifier)

        if shopItem.price <= credits then
            if shopItem.type == "car" then
                local plate =
                    math.random(0, 9) ..
                    math.random(0, 9) ..
                        math.random(0, 9) ..
                            math.random(0, 9) ..
                                math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9)
                local mods =
                    '{"neonEnabled":[false,false,false,false],"modFrame":-1,"modEngine":3,"engineHealth":956.921875,"modSideSkirt":-1,"modFrontBumper":-1,"modOrnaments":-1,"health":995,"modGrille":-1,"modTransmission":2,"plate":"' ..
                    plate ..
                        '","modTrimB":-1,"fuelLevel":45.91801071167,"modDoorSpeaker":-1,"windows":[1,false,false,false,false,1,1,1,1,false,1,false,false],"modSpeakers":-1,"modAerials":-1,"modTurbo":1,"pearlescentColor":67,"modVanityPlate":-1,"modSpoilers":-1,"modAirFilter":-1,"modArchCover":-1,"tyreSmokeColor":[255,255,255],"modEngineBlock":-1,"modHood":-1,"modRightFender":-1,"bodyHealth":997.25,"dirtLevel":4.0228095054626,"wheels":0,"modPlateHolder":-1,"modBrakes":2,"wheelColor":156,"modSteeringWheel":-1,"modFender":-1,"color2":62,"color1":9,"neonColor":[255,0,255],"modExhaust":-1,"modDial":-1,"model":' ..
                            GetHashKey(shopItem.model) ..
                                ',"plateIndex":1,"windowTint":3,"modBackWheels":-1,"tyres":[false,false,false,false,false,false,false],"modTank":-1,"modHydrolic":-1,"modSmokeEnabled":1,"modRearBumper":-1,"modArmor":4,"modFrontWheels":-1,"modRoof":-1,"extras":[],"modAPlate":-1,"modXenon":1,"modLivery":-1,"modDashboard":-1,"modShifterLeavers":-1,"modTrimA":-1,"modTrunk":-1,"modHorns":-1,"modSeats":-1,"modSuspension":3,"modStruts":-1,"modWindows":-1,"doors":[false,false,false,false,false,false]}'

                MySQL.Async.execute(
                    "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
                    {
                        ["@owner"] = xPlayer.identifier,
                        ["@plate"] = plate,
                        ["@vehicle"] = mods
                    },
                    function(rowsChanged)
                        print(plate)
                    end
                )
            elseif shopItem.type == "item" then
                xPlayer.addInventoryItem(shopItem.item, shopItem.count)
            elseif shopItem.type == "weapon" then
                xPlayer.addWeapon(shopItem.weapon, shopItem.ammo)
            elseif shopItem.type == "money" then
                xPlayer.addAccountMoney("bank", shopItem.money)
            else
                TriggerClientEvent("core_credits:sendMessage", src, "Item type does not exist")
            end

            TriggerClientEvent("core_credits:sendMessage", src, Config.Text["item_purschased"])
            setCredits(xPlayer.identifier, credits - shopItem.price)
            Wait(500)
            TriggerClientEvent("core_credits:updateCredits", src)
        else
            TriggerClientEvent("core_credits:sendMessage", src, Config.Text["not_enough_credits"])
        end
    end
)

ESX.RegisterServerCallback(
    "core_credits:getInfo",
    function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)

        MySQL.Async.fetchAll(
            "SELECT * FROM users WHERE identifier = @identifier ",
            {["@identifier"] = xPlayer.identifier},
            function(data)
                data = data[1]

                if data.tasks == "" then
                    data.tasks = {}
                else
                    data.tasks = json.decode(data.tasks)
                end

                if data.winnings == "" then
                    data.winnings = {}
                else
                    data.winnings = json.decode(data.winnings)
                end

                if data.tasks_completed == "" then
                    data.tasks_completed = {}
                else
                    data.tasks_completed = json.decode(data.tasks_completed)
                end

                cb(
                    {
                        credits = data.credits,
                        tasks = data.tasks,
                        winnings = data.winnings,
                        tasks_completed = data.tasks_completed
                    }
                )
            end
        )
    end
)

RegisterCommand(
    "givecredits",
    function(source, args, rawCommand)
        if source ~= 0 then
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer.getGroup() == "best" then
                if args[1] ~= nil then
                    local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
                    if xTarget ~= nil then
                        if args[2] ~= nil then
                            giveCredits(xTarget.identifier, tonumber(args[2]))
                        else
                            TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                        end
                    else
                        TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
            end
        end
    end,
    false
)

RegisterCommand(
    "setcredits",
    function(source, args, rawCommand)
        if source ~= 0 then
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer.getGroup() == "owner" or xPlayer.getGroup() == "best" then
                if args[1] ~= nil then
                    local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
                    if xTarget ~= nil then
                        if args[2] ~= nil then
                            setCredits(xTarget.identifier, tonumber(args[2]))
                        else
                            TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                        end
                    else
                        TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_credits:sendMessage", source, Config.Text["wrong_usage"])
            end
        end
    end,
    false
)
