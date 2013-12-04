#!/usr/bin/coffee

io = require "socket.io-client"

bingo = ["B", "I", "N", "G", "O"]
coors = [0..4]
state = ""

snum = (n) -> if n < 10 then " #{n}" else "#{n}"
fnum = (j) -> if j.found then "[#{snum(j.n)}]" else " #{snum(j.n)} "

socket = io.connect "ws://yahoobingo.herokuapp.com"
socket.on "connect", ->

    card = {}

    socket.on "card", (data) ->
        card = for i in bingo
            ({n: j, found: false} for j in data.slots[i])

    socket.on "number", (ball) ->
        return if state
        m = ball.match /([BINGO])(\d+)/
        row = bingo.indexOf(m[1])
        card[row] = for j in card[row]
            if j.found or j.n != +m[2] then j else {n: j.n, found: true}

        may = (m, x, y) -> if card[x][y].found then m+1 else m

        f = (->
            for i in coors
                for test in [((m, j) -> may m, i, j), ((m, j) -> may m, j, i)]
                    if 5 == coors.reduce test, 0
                        return true


            for test in [((m, j) -> may m, j, j), ((m, j) -> may m, j, 4-j)]
                if 5 == coors.reduce test, 0
                    return true

            false)()

        console.log "\n\nBALL: #{ball}\n"
        for i in coors
            console.log(card[i].map(fnum).join(" "))
        if f
            console.log "Looks like you won."
            socket.emit "bingo"

    socket.on "win", -> state = "won"
    socket.on "lose", -> state = "lost"

    socket.on "disconnect", ->
        console.log "You appear to have " + if state then state else "TERMINATED UNEXPECTEDLY."
        process.exit()

    socket.emit "register",
        name: "Elf M. Sternberg"
        email: "elf.sternberg@gmail.com"
        url: "https://github.com/elfsternberg/yahoobingo"
