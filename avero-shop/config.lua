Config = {

OpenKey = '',
OpenCommand = 'sklep',

UsingLimitSystem = false,

DefaultCategory = 'vehicles', -- This category will show up first
ShopCategories = {
	['vehicles'] = 'POJAZDY',
	['weapons'] = 'PRZEDMIOTY',
	['money'] = 'INNE'
},
--TYPES AVAILABLE BY DEFAULT (Other types can be added in server lua file or request them for another update)
-- car, money, weapon, item
Shop = {
    ['rs6'] = {type = 'car', model = 'rs6', price = 2000, category = 'vehicles'},
    ['m2'] = {type = 'car', model = 'm2', price = 1750, category = 'vehicles'},
    ['rx7r'] = {type = 'car', model = 'rx7r', price = 1000, category = 'vehicles'},
    ['trackhawk'] = {type = 'car', model = 'trackhawk', price = 1500, category = 'vehicles'},
    ['m1000'] = {type = 'item', item= 'money', count = 1000.0, price = 30, category = 'money'},
    ['m10000'] = {type = 'item', item= 'money', count = 10000.0, price = 250, category = 'money'},
    ['m50000'] = {type = 'item', item= 'money', count = 50000.0, price = 1000, category = 'money'},
    ['pistolet'] = {type = 'item', item= 'weapon_pistol', count = 1.0, price = 300, category = 'weapons'},
    ['ammo'] = {type = 'item', item= 'ammo-9', count = 100.0, price = 100, category = 'weapons'},
},


--TYPES AVAILABLE BY DEFAULT (Other types can be added in server lua file or request them for another update)
--run, drive, fly, 
Tasks = {
    [1] = {reward = 5, type='run', value=10, description = 'PRZEBIEGNIJ 10KM'},
    [2] = {reward = 15, type='run', value=30, description = 'PRZEBIEGNIJ 30KM'},
    [3] = {reward = 10, type='drive', value=50, description = 'PRZEJEDŹ AUTEM 30KM'},
    [4] = {reward = 20, type='drive', value=150, description = 'PRZEJEDŹ AUTEM 150KM'},
    [5] = {reward = 50, type='drive', value=500, description = 'PRZEJEDŹ AUTEM 500KM'}

},

--RARITIES (From most common to most rare)
-- supercommon, common, rare, superrare, import
--TYPES OF REWARDS
-- car, credits, weapon, item, money
LowestBet = 25, -- The lowest bet amount
CaseOpeningItems = { -- The image name should be as the id for this reward

    ['1000'] = {type = 'item', item = 'money', count = 1000.0, exchange = 5.0, rarity = 'common'},
    ['20'] = {type = 'credits', credits = 20.0, exchange = 20.0, rarity = 'common'},

    ['50'] = {type = 'credits', credits = 50.0, exchange = 50.0, rarity = 'supercommon'},
    ['5000'] = {type = 'item', item = 'money', count = 5000.0, exchange = 15.0, rarity = 'supercommon'},

    ['100'] = {type = 'credits', credits = 100.0, exchange = 100.0, rarity = 'rare'},
    ['10000'] = {type = 'item', item = 'money', count = 10000.0, exchange = 30.0, rarity = 'rare'},

    ['300'] = {type = 'credits', credits = 300.0, exchange = 300.0, rarity = 'superrare'},
    ['30000'] = {type = 'item', item = 'money', count = 30000.0, exchange = 50.0, rarity = 'superrare'},

    ['500'] = {type = 'credits', credits = 500.0, exchange = 500.0, rarity = 'import'},
    ['rs6'] = {type = 'car', model = 'rmodrs6', exchange = 8000.0, rarity = 'import'},
    ['50000'] = {type = 'item', item = 'money', count = 50000.0, exchange = 150.0, rarity = 'import'},
},


BuyCreditsLink = 'https://discord.gg/avero-gg',
BuyCreditsDescription = 'Kupując kredyty wspierasz serwer!',

Text = {


    ['item_purschased'] = 'Zakupiłeś przedmiot',
    ['not_enough_credits'] = 'Nie posiadasz Kredytów',
    ['wrong_usage'] = 'Niewłaściwe użycie',
    ['item_redeemed'] = 'Odebrano przedmiot',
    ['item_exchanged'] = 'Przedmiot wymieniony na kredyty!',
    ['bet_limit'] = 'Musisz postawić co minimum 25 kredytów!',
    ['task_completed'] = 'Ukończono Zadanie!'


}

}



function SendTextMessage(msg)

        --SetNotificationTextEntry('STRING')
        --AddTextComponentString(msg)
        --DrawNotification(0,1)

        --EXAMPLE USED IN VIDEO
        ESX.ShowNotification(msg)

end
