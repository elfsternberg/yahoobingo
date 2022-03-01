import io from "socket.io-client";
const bingo = ["B", "I", "N", "G", "O"];
const coors = [0, 1, 2, 3, 4];

interface Space {
    num: number;
    found: boolean;
}

type Card = Record<string, number[]>;

const space_num = (n: number) => (n < 10 ? ` ${n}` : `${n}`);

const format_space = (s: Space) => {
    const t = space_num(s.num);
    return s.found ? `[${t}]` : ` ${t} `;
};

const socket = io.connect("ws://yahoobingo.herokuapp.com");

const bingo_re = /([BINGO])(\d+)/i;
type LineTest = (m: number, j: number) => number;

socket.on("connect", () => {
    let card: Space[][] = [];
    let state = "";

    // After receiving a new card, initialize the bingo card.  The data
    // is a map of the letters across, for which each has five vertical
    // slots, filled with random numbers which vary, depending upon the
    // standard rules, of 1 through 75 or 1 through 90.  Numbers do not
    // repeat on a single card, but there is no restriction on the
    // column-number relationship.
    socket.on("card", (data: Card) => (card = bingo.map((l) => data.slots[l].map({ num: l, found: false }))));

    socket.on("number", function (ball: string) {
        if (state) {
            return;
        }
        const ball_m = ball.match(bingo_re);
        if (!ball_m) {
            throw new Error("Number message malformed!");
        }

        const [ball_letter, ball_rep] = ball_m.slice(1, 3);
        if (ball_letter === undefined || ball_rep === undefined) {
            throw new Error("Number message missing number");
        }

        const row = bingo.indexOf(ball_letter.toUpperCase());
        if (!row) {
            throw new Error("Number message *really* malformed!");
        }

        const card_row = card[row];
        if (!card_row) {
            throw new Error("Row letter did not correspond");
        }

        const ball_num = parseInt(ball_rep, 10);
        const found = card[row].findIndex((c) => (c.num = ball_num));
        if (found) {
            card[row][found].found = true;
        }

        const scan_for_bingo = () => {
            const may = (m: number, x: number, y: number) => m + (card[x][y].found ? 1 : 0);

            const make_tests = (i: number): LineTest[] => [
                (m: number, j: number) => may(m, i, j),
                (m: number, j: number) => may(m, j, i),
            ];

            for (const i of coors) {
                const tests = make_tests(i);
                for (const test of tests) {
                    if (5 === coors.reduce(test, 0)) {
                        return true;
                    }
                }
            }

            const diag_tests: LineTest[] = [
                (m: number, j: number) => may(m, j, j),
                (m: number, j: number) => may(m, j, 4 - j),
            ];

            for (const test of diag_tests) {
                if (5 === coors.reduce(test, 0)) {
                    return true;
                }
            }

            return false;
        };

        console.log("\n\nBall: ${ball}\n");
        for (const i of coors) {
            console.log(card[i].map(format_space).join(" "));
        }

        if (scan_for_bingo()) {
            socket.emit("bingo");
            console.log("Looks like you won.");
        }
    });

    socket.on("win", () => {
        state = "won";
    });
    socket.on("lose", () => {
        state = "lost";
    });

    socket.on("disconnect", () => {
        const oops = "TERMINATED UNEXPECTEDLY";
        console.log("You appear to have ${state || oops}");
        process.exit();
    });

    socket.emit("register", {
        name: "Elf M. Sternberg",
        email: "elf.sternberg@gmail.com",
        url: "https://github.com/elfsternberg/yahoobingo",
    });
});
