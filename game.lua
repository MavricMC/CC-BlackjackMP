--Blackjack Multiplayer--

local vers = "0.4"

--Made by Mavric--
--How to setup is on my youtube channel--
--Code on https://github.com/MavricMC/CC-BlackjackMP/--

--X cords for dealer cards on main screen depending on number of cards
local cords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

--X cords for each stack of player cords on main screen
local pCords = {
    {22},
    {14, 30},
    {7, 22, 38},
    {5, 15, 25, 41},
    {2, 12, 23, 33, 43}
}

--Y cords for stacking cards on main screen. Should change to gap multiplier
local yCords = {16, 18, 20, 22, 24, 26, 28}

--X cords for cards on mirros clients depending on number of cards
local mCords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

--Settings--
local atm = "casino_1"
local bankSide = "right"
local monSide = "top"
local modemSide = "bottom"
local server = 0
local mainC = 5 --channel for sending stuff to the server--
local players = {10, 20, 30} --there should be a channel for every mirror client--
local drives = {"drive_1", "drive_2", "drive_3"} --there should be a drive name for every mirror client--
local betting = {{}}
local text = {{}}

--Game Buttons--
local buttons = {
--text, x, xend
    {"Stand", 18, colors.black,},
    {"Hit", 24, colors.gray},
    {"Double", 28, colors.red}
}
--Without double--
local button = {
    {"Stand", 20, colors.black, 18, 24},
    {"Hit", 26, colors.gray, 24, 28}
}

--Functions--
function balance(account, ATM, pin)
    local msg = {"bal", account, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "balR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function deposit(account, amount, ATM, pin)
    local msg = {"dep", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "depR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function withdraw(account, amount, ATM, pin)
    local msg = {"wit", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "witR" then
        return mes[2], mes[3], amount
    end
    return false, "oof"
end

function transfer(account, account2, amount, ATM, pin)
    local msg = {"tra", account, account2, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "traR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function clearRem(player)
    local msg = {"clear"}
    modem.transmit(player, mainC, msg)
end

function lineRem(y, player)
    local msg = {"line", y}
    modem.transmit(player, mainC, msg)
end

function backgroundRem(colour, player)
    local msg = {"background", colour}
    modem.transmit(player, mainC, msg)
end

function cursorRem(x, y, player)
    local msg = {"cursor", x, y}
    modem.transmit(player, mainC, msg)
end

function textRem(colour, player)
    local msg = {"text", colour}
    modem.transmit(player, mainC, msg)
end

function writeRem(text, player)
    local msg = {"write", text}
    modem.transmit(player, mainC, msg)
end

function picRem(picName, x, y, player)
    local msg = {"pic", picName, x, y}
    modem.transmit(player, mainC, msg)
end

function drawCardRem(x, y, char, suit, Cplayer)
    if (suit == "\5" or suit == "\6") then
        colour = colours.black
    else
        colour = colours.red
    end
    picRem("card", x, y, Cplayer)
    cursorRem(x + 1, y + 1, Cplayer)
    backgroundRem(1, Cplayer)
    textRem(colour, Cplayer)
    writeRem(char, Cplayer)
    cursorRem(x + 3, y + 3, Cplayer)
    writeRem(suit, Cplayer)
    if char == 10 then
        cursorRem(x + 4, y + 5, Cplayer)
    else
        cursorRem(x + 5, y + 5, Cplayer)
    end
    writeRem(char, Cplayer)
end

function clearScreenRem(idle, insert, Splayer)
    backgroundRem(colours.green, Splayer)
    clearRem(Splayer)
    cursorRem(1, 1, Splayer)
    textRem(colours.black, Splayer)
    writeRem("Blackjack Mirror OS ", Splayer)
    cursorRem(1, 2, Splayer)
    textRem(colours.yellow, Splayer)
    writeRem("Made By Mavric, Please Report Bugs", Splayer)
    if (idle) then
        picRem("logo", 20, 4, Splayer)
        if (insert) then
            backgroundRem(colours.green, Splayer)
            cursorRem(17, 13, Splayer)
            writeRem("Please insert card", Splayer)
        end
    end
end

function drawBetRem(PIN, number, Bplayer)
    clearScreenRem(false, false, Bplayer)
    picRem("logo", 20, 4, Bplayer)
    backgroundRem(colours.green, Bplayer)
    textRem(colours.lime, Bplayer)
    cursorRem(1, 3, Bplayer)
    if (PIN) then
        writeRem("ID:", Bplayer)
    else
        writeRem("$", Bplayer)
    end
    writeRem(number, Bplayer)
    cursorRem(20, 13, Bplayer)
    textRem(1, Bplayer)
    if (PIN) then
        writeRem("PIN:", Bplayer)
    else
        writeRem("BET:", Bplayer)
    end
    drawX(Bplayer)
end

function checkX(x, y)
    if x == 49 and y == 17 then
        return true
    else
        return false
    end
end

function drawX(Xplayer)
    textRem(colors.white, Xplayer)
    backgroundRem(colours.red, Xplayer)
    cursorRem(49, 17, Xplayer)
    writeRem("X", Xplayer)
end

function clearScreen(insert)
    term.setBackgroundColour(colours.green)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColour(colours.black)
    term.write("BlackjackMP OS ")
    term.write(vers)
    term.setCursorPos(1, 2)
    term.setTextColour(colours.yellow)
    term.write("Made By Mavric, Please Report Bugs")
    if (insert) then
        local pic = paintutils.loadImage("/blackjackMP/logo.nfp")
        paintutils.drawImage(pic, 20, 14)
        term.setBackgroundColour(colours.green)
        term.setCursorPos(17, 23)
        term.write("Please insert card")
    end
end

function drawCard(x, y, char, suit)
    if (suit == "\5" or suit == "\6") then
        colour = colours.black
    else
        colour = colours.red
    end
    local pic = paintutils.loadImage("/blackjackMP/card.nfp")
    paintutils.drawImage(pic, x, y)
    term.setCursorPos(x + 1, y + 1)
    term.setBackgroundColour(1)
    term.setTextColor(colour)
    term.write(char)
    term.setCursorPos(x + 3, y + 3)
    term.write(suit)
    if char == 10 then
        term.setCursorPos(x + 4, y + 5)
    else
        term.setCursorPos(x + 5, y + 5)
    end
    term.write(char)
end

function drawBack(x, y)
    local pic = paintutils.loadImage("/blackjackMP/cardBack.nfp")
    paintutils.drawImage(pic, x, y)
end

function drawButtons(double, bPlayer)
    textRem(colors.white, bPlayer)
    if (double) then
        for k, v in pairs(buttons) do
            backgroundRem(v[3], bPlayer)
            cursorRem(v[2], 18, bPlayer)
            writeRem(v[1], bPlayer)
        end
    else
        for k, v in pairs(button) do
            backgroundRem(v[3], bPlayer)
            cursorRem(v[2], 18, bPlayer)
            writeRem(v[1], bPlayer)
        end
    end
end

function drawScreen(sNum, dub, play, blank)
    clearScreen(false)
    if (blank) then
        drawCard(cords[2][1], 4, cards.dealer[1][2], cards.dealer[1][3])
        drawBack(cords[2][2], 4)
    else
        for k, v in pairs(cards.dealer) do
            drawCard(cords[table.maxn(cards.dealer)][k], 4, v[2], v[3])
        end
    end
    for k, v in pairs(cards.player) do    
        for k2, v2 in pairs(cards.player[k]) do
            drawCard(pCords[table.maxn(players)][k], yCords[k2], v2[2], v2[3], v)
        end
    end
    if (play) then
        clearScreenRem(false, false, players[sNum])
        drawButtons(dub, players[sNum])
        for k, v in pairs(cards.player[sNum]) do
            drawCardRem(mCords[table.maxn(cards.player[sNum])][k], 10, v[2], v[3], players[sNum])
        end
    end
end

function getDrive(drive)
    for k, v in pairs(drives) do
        if v == drive then
            return true, k
        end
    end
    return false
end

function getPlayer(channel)
    for k, v in pairs(players) do
        if v == channel then
            return true, k
        end
    end
    return false
end

function pinpad(key)
    if (tonumber(key)) then
        if tonumber(key) == 259 then
            return true, 10
        elseif tonumber(key) == 257 then
            return true, 11
        elseif tonumber(key) >= 0 and tonumber(key) <= 9 then
            return true, tonumber(key)
        end
    end
    return false
end

--{"Stand", 20, colors.black, 18, 24},
function buttonClick(x, y, cDub)
    if (cDub) then
        for k, v in pairs(buttons) do
            if x >= v[2] and x < (v[2] + string.len(v[1])) and y == 18 then
                return true, k
            end
        end
    else
        for k, v in pairs(button) do
            if x >= v[2] and x < (v[2] + string.len(v[1])) and y == 18 then
                return true, k
            end
        end
    end
    return false
end

--Check if a hand has a ace--
function isAce(Adeck)
    --Loops through all the cards and returns true if it finds an ace--
    for k, v in pairs(Adeck) do
        if (Adeck[k][2] == "A") then
            return true
        end
    end
    --Returns false if it find nothing--
    return false
end

function getTotal(deck)
    local deckTotal = 0
    for k, v in pairs(deck) do
        deckTotal = deckTotal + v[1]
    end

    if (isAce(deck)) then
        --If there is an ace and the total is less than 12 than offset score by 10--
        if (deckTotal > 11) then
            return deckTotal
        else
            return deckTotal + 10
        end
    else
        return deckTotal
    end
end

function allStand()
    local total = {}
    for p, t in pairs(cards.player) do
        total[p] = getTotal(t)
    end
    
    local ress = {}
    
    for k, v in pairs(cards.player) do
        if total[k] > 21 then
            ress[k] = 10
        else
            ress[k] = 11
        end
    end
    
    local dTotal = getTotal(cards.dealer)
    while dTotal < 16 do
        num = math.random(1, table.maxn(cards.deck))
        card = cards.deck[num]
        table.remove(cards.deck, num)
        table.insert(cards.dealer, card)
        dTotal = getTotal(cards.dealer)
        drawScreen(0, false, false, false)
        if dTotal >= 21 then
            return true, ress
        end
    end

    for k, v in pairs(cards.player) do
        if ress[k] == 11 then
            if total[k] > dTotal then
                ress[k] = 1
            elseif total[k] < dTotal then
                ress[k] = 2
            elseif total[k] == dTotal then
                ress[k] = 3
            else
                ress[k] = 0
            end
        end
    end
    return dee, ress
end

--Mirror game function--
function mirrorGame(gPlayer, playerNum)
    clearScreenRem(false, false, gPlayer)
    local Du = false
    if (betting[playerNum][5] >= (tonumber(text[playerNum][1]) * 2)) then
        Du = true
    end
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.player[playerNum], card)
    
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.player[playerNum], card)
    drawScreen(playerNum, Du, true, true)
    
    local loop = true
    while loop do
        local data = {os.pullEvent()}
        if data[1] == "modem_message" then
            if data[4] == players[playerNum] then
                isP, pNum = getPlayer(data[4])
                if (isP) then
                    if data[5][1] == "mouse_click" then
                        local click, butt = buttonClick(data[5][3], data[5][4], Du)
                        if butt == 1 then
                            backgroundRem(colours.green, gPlayer)
                            textRem(colours.black, gPlayer)
                            cursorRem(18, 6, gPlayer)
                            writeRem("Stand", gPlayer)
                            return
                        elseif butt == 2 then
                            Du = false
                            if table.maxn(cards.player[playerNum]) < 7 then
                                num = math.random(1, table.maxn(cards.deck))
                                card = cards.deck[num]
                                table.remove(cards.deck, num)
                                table.insert(cards.player[playerNum], card)
                                drawScreen(playerNum, Du, true, true)
                                
                                local total = getTotal(cards.player[playerNum])
                                if total > 21 then
                                    --Player bust--
                                    backgroundRem(colours.green, gPlayer)
                                    textRem(colours.black, gPlayer)
                                    cursorRem(18, 6, gPlayer)
                                    writeRem("Bust", gPlayer)
                                    return
                                end
                                
                                if table.maxn(cards.player[playerNum]) > 6 then
                                    --Got 7 cards win out bust--
                                    backgroundRem(colours.green, gPlayer)
                                    textRem(colours.black, gPlayer)
                                    cursorRem(18, 6, gPlayer)
                                    writeRem("Win", gPlayer)
                                    return
                                end
                            end
                        elseif butt == 3 then
                            if (Du) and table.maxn(cards.player[playerNum]) == 2 then
                                local suc, res = withdraw(betting[playerNum][4], tonumber(text[playerNum][1]), atm, text[playerNum][2])
                                if (suc) then
                                    text[playerNum][1] = tostring(tonumber(text[playerNum][1]) * 2)

                                    num = math.random(1, table.maxn(cards.deck))
                                    card = cards.deck[num]
                                    table.remove(cards.deck, num)
                                    table.insert(cards.player[playerNum], card)
                                        
                                    drawScreen(playerNum, Du, true, true)
                                    backgroundRem(colours.green, gPlayer)
                                    textRem(colours.black, gPlayer)
                                    cursorRem(18, 6, gPlayer)
                                    writeRem("Double", gPlayer)
                                    return
                                else
                                    writeRem("Error: ".. res, players[pNum])
                                end
                            end
                        end
                    end
                end
            end
        end         
    end
end

--setup--
modem = peripheral.wrap(modemSide)
modem.open(mainC)
rednet.open(bankSide)

m = peripheral.wrap(monSide)
term.redirect(m)

while true do
    --Betting setup--
    betting = {   --there should be a row of {false, false} for evey mirror client--
        {false, false, false, 0, 0}, --is betting, done betting, is pin, id, balance--
        {false, false, false, 0, 0},
        {false, false, false, 0, 0}
    }

    --there should be a {"", ""} for evey mirror client--
    text = {
        {"", ""}, --bet amount, pin--
        {"", ""},
        {"", ""}
    }

    clearScreen(true)
    for k, v in pairs(players) do
        clearScreenRem(true, true, v)
    end

    --Betting loop--
    local loop = true
    while loop do
        local isP = false
        local pNum = 0
        local tNum = 0
        local data = {os.pullEvent()}
        if data[1] == "disk" then
            isP, pNum = getDrive(data[2])
            if (isP) then
                local id = disk.getID(data[2])
                disk.eject(data[2])
                if id ~= nil then
                    if betting[pNum][3] == false then
                        drawBetRem(true, id, players[pNum])
                        betting[pNum][3] = true
                        betting[pNum][4] = id
                    end
                end
            end
        elseif data[1] == "modem_message" then
            isP, pNum = getPlayer(data[4])
            if (isP) then
                if data[5][1] == "mouse_click" then
                    if (betting[pNum][3]) then
                        if (betting[pNum][2] == false) then
                            if (checkX(data[5][3], data[5][4])) then
                                betting[pNum][1] = false
                                betting[pNum][3] = false
                                betting[pNum][4] = 0
                                betting[pNum][5] = 0
                                text[pNum][1] = ""
                                text[pNum][2] = ""
                                clearScreenRem(true, true, players[pNum])
                            end
                        end
                    end
                elseif data[5][1] == "char" or data[5][1] == "key" then
                    if (betting[pNum][1]) then
                        if (betting[pNum][3]) then
                            if (betting[pNum][2] == false) then
                                local isKey, keyNum = pinpad(data[5][2])
                                if (isKey) then
                                    if keyNum == 10 then
                                        if string.len(text[pNum][1]) > 0 then
                                            text[pNum][1] = string.sub(text[pNum][1], 1, string.len(text[pNum][1]) -1)
                                            backgroundRem(colours.green, players[pNum])
                                            textRem(1, players[pNum])
                                            lineRem(13, players[pNum])
                                            cursorRem(20, 13, players[pNum])
                                            writeRem("BET: ", players[pNum])
                                            writeRem(text[pNum][1], players[pNum])
                                        end
                                    elseif keyNum == 11 then
                                        if string.len(text[pNum][1]) < 6 then
                                            if text[pNum][1] ~= "" then
                                                if (betting[pNum][5] >= tonumber(text[pNum][1]) and tonumber(text[pNum][1]) ~= 0) then
                                                    local suc, res = withdraw(betting[pNum][4], tonumber(text[pNum][1]), atm, text[pNum][2])
                                                    clearScreenRem(false, false, players[pNum])
                                                    backgroundRem(colours.green, players[pNum])
                                                    cursorRem(11, 13, players[pNum])
                                                    if (suc) then
                                                        writeRem("Your bet of $".. text[pNum][1].. " has been set", players[pNum])
                                                        cursorRem(7, 14, players[pNum])
                                                        writeRem("You cant undo this but if you walk away", players[pNum])
                                                        cursorRem(14, 15, players[pNum])
                                                        writeRem("your card wont be saved!", players[pNum])
                                                        betting[pNum][2] = true
                                                        loop = false
                                                        for k, v in pairs(betting) do
                                                            if (v[2] == false) then
                                                                loop = true
                                                            end
                                                        end
                                                    else
                                                        writeRem("Error: ".. res, players[pNum])
                                                    end
                                                else
                                                    clearScreenRem(true, false, players[pNum])
                                                    backgroundRem(colours.green, players[pNum])
                                                    cursorRem(11, 13, players[pNum])
                                                    if (tonumber(text[pNum][1]) == 0) then
                                                        writeRem("Must be more than zero!", players[pNum])
                                                    else
                                                        writeRem("Must be enough money in your account!", players[pNum])
                                                    end
                                                    betting[pNum][1] = false
                                                    betting[pNum][3] = false
                                                    betting[pNum][4] = 0
                                                    betting[pNum][5] = 0
                                                    text[pNum][1] = ""
                                                    text[pNum][2] = ""
                                                    sleep(3)
                                                    clearScreenRem(true, true, players[pNum])
                                                end
                                            end
                                        end
                                    elseif keyNum >= 0 and keyNum <= 9 then
                                        if string.len(text[pNum][1]) < 5 then
                                            text[pNum][1] = text[pNum][1].. keyNum
                                            backgroundRem(colours.green, players[pNum])
                                            textRem(1, players[pNum])
                                            cursorRem(24 + string.len(text[pNum][1]), 13, players[pNum])
                                            writeRem(keyNum, players[pNum])
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if (betting[pNum][3]) then
                            if (betting[pNum][2] == false) then
                                local isKey, keyNum = pinpad(data[5][2])
                                if (isKey) then
                                    if keyNum == 10 then
                                        if string.len(text[pNum][2]) > 0 then
                                            text[pNum][2] = string.sub(text[pNum][2], 1, string.len(text[pNum][2]) -1)
                                            backgroundRem(colours.green, players[pNum])
                                            textRem(1, players[pNum])
                                            lineRem(13, players[pNum])
                                            cursorRem(20, 13, players[pNum])
                                            writeRem("PIN: ", players[pNum])
                                            writeRem(string.sub("****", 1, string.len(text[pNum][2])), players[pNum])
                                        end
                                    elseif keyNum == 11 then
                                        if string.len(text[pNum][2]) == 5 then
                                            local suc, res = balance(betting[pNum][4], atm, text[pNum][2])
                                            if (suc) then
                                                betting[pNum][5] = tonumber(res)
                                                betting[pNum][1] = true
                                                drawBetRem(false, res, players[pNum])
                                            else
                                                betting[pNum][3] = false
                                                betting[pNum][4] = 0
                                                text[pNum][2] = ""
                                                clearScreenRem(true, false, players[pNum])
                                                backgroundRem(colours.green, players[pNum])
                                                cursorRem(11, 13, players[pNum])
                                                writeRem(res, players[pNum])
                                                sleep(3)
                                                clearScreenRem(true, true, players[pNum])
                                            end
                                        end
                                    elseif keyNum >= 0 and keyNum <= 9 then
                                        if string.len(text[pNum][2]) < 5 then
                                            text[pNum][2] = text[pNum][2].. keyNum
                                            backgroundRem(colours.green, players[pNum])
                                            textRem(1, players[pNum])
                                            cursorRem(24 + string.len(text[pNum][2]), 13, players[pNum])
                                            writeRem("*", players[pNum])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --Main setup--
    os.loadAPI("blackjackMP/cards.lua")
    clearScreen(false)

    --Get dealers cards--
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.dealer, card)
    
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.dealer, card)

    --Main loop--
    for k, v in pairs(players) do
        mirrorGame(v, k)
    end
    drawScreen(0, Du, false, false)
    local bust, Gres = allStand()
    if bust then
        for k, v in pairs(players) do
            drawScreen(k, Du, true, false)
            backgroundRem(colours.green, v)
            textRem(colours.black, v)
            cursorRem(18, 6, v)
            local cash = tonumber(text[k][1])
            if Gres[k] == 10 then
                writeRem("Bust", v)
                cash = 0
            elseif Gres[k] == 11 then
                writeRem("Dealer Bust", v)
                cash = cash * 2
            else
                writeRem("Error. Returning money", v)
            end
            if cash ~= 0 then
                local suc, res = deposit(betting[k][4], cash, atm, text[k][2])
                cursorRem(18, 7, v)
                if suc then
                    writeRem("Deposited your winings of: ".. cash, v)
                else
                    writeRem("Error: ".. res, v)
                end
            end
        end
        term.setBackgroundColor(colours.green)
        term.setTextColor(colors.black)
        term.setCursorPos(18, 10)
        write("Dealer bust")
    else
        for k, v in pairs(players) do
            drawScreen(k, Du, true, false)
            backgroundRem(colours.green, v)
            textRem(colours.black, v)
            cursorRem(18, 6, v)
            local cash = tonumber(text[k][1])
            if Gres[k] == 0 then
                writeRem("Error. Returning money", v)
            elseif Gres[k] == 1 then
                textRem(colours.red, v)
                writeRem("Win", v)
                cash = cash * 2
            elseif Gres[k] == 2 then
                writeRem("Lose", v)
                cash = 0
            elseif Gres[k] == 3 then
                writeRem("Push", v)
            elseif Gres[k] == 10 then
                writeRem("Bust", v)
                cash = 0
            else
                writeRem("Error. Returning money", v)
            end
            if cash ~= 0 then
                local suc, res = deposit(betting[k][4], cash, atm, text[k][2])
                cursorRem(18, 7, v)
                if (suc) then
                    writeRem("Deposited your winings of: ".. cash, v)
                else
                    writeRem("Error: ".. res, v)
                end
            end
        end
    end
    os.unloadAPI("blackjackMP/cards.lua") --Discard used deck
    sleep(2) --Allow time to see results
end
