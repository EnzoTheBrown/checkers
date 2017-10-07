module Model.Game where
import Model.DataStructure
import Data.Maybe

onBoard (Piece x y _) =
    x >= 1 && x <= 8 && y >= 1 && y <= 8

forward (Piece x y p)
    | p == "p"
        = ((Piece x y p), filter onBoard [(Piece (x + 1) (y + 1) "p"), (Piece (x - 1) (y + 1) "p")])
    | otherwise
        = ((Piece x y p), filter onBoard [(Piece (x + 1) (y + 1) "q"), (Piece (x + 1) (y - 1) "q"), (Piece (x - 1) (y + 1) "q"), (Piece (x - 1) (y - 1) "q")])

backward (Piece x y p)
    | p == "p"
        = ((Piece x y p), filter onBoard [(Piece (x - 1) (y - 1) "p"), (Piece (x + 1) (y - 1) "p")])
    | otherwise
        = ((Piece x y p), filter onBoard [(Piece (x - 1) (y + 1) "q"), (Piece (x - 1) (y - 1) "q"), (Piece (x + 1) (y + 1) "q"), (Piece (x + 1) (y - 1) "q")])

forceCatchWhite _ [] = []
forceCatchWhite (Piece x y p) ((Piece xx yy pp):xs)
    | p == "p" && y == yy + 1 && (x == xx + 1 || x == xx - 1)
        = ((Piece x y p), (Piece xx yy pp)) : forceCatchWhite (Piece x y p) xs
    | p == "q" && (x == xx + 1 || x == xx -1) && (y == yy + 1 || y == yy - 1)
        = ((Piece x y p), (Piece xx yy pp)) : forceCatchWhite (Piece x y p) xs
    | otherwise
        = forceCatchWhite (Piece x y p) xs

forceCatchBlack _ [] = []
forceCatchBlack (Piece x y p) ((Piece xx yy pp):xs)
    | p == "p" && y == yy - 1 && (x == xx + 1 || x == xx - 1)
        = ((Piece x y p), (Piece xx yy pp)) : forceCatchBlack (Piece x y p) xs
    | p == "q" && (x == xx + 1 || x == xx -1) && (y == yy + 1 || y == yy - 1)
        = ((Piece x y p), (Piece xx yy pp)) : forceCatchBlack (Piece x y p) xs
    | otherwise
        = forceCatchBlack (Piece x y p) xs


tileBusy (Piece a b _) [] = False
tileBusy (Piece a b c) ((Piece x y _) : xs)
    | a == x && b == y = True
    | otherwise = tileBusy (Piece a b c) xs
filterBusy (_, [])  _ = []
filterBusy (p, (x:xs)) pieces
    | not(tileBusy x pieces) = (p, x) : filterBusy (p, xs) pieces
    | otherwise = filterBusy (p, xs) pieces

replacePawn :: (Piece, Piece) -> [Piece] -> [Piece]
replacePawn (p1, p2) (x:xs)
    | x == p1 = p2:xs
    | otherwise = x:(replacePawn (p1, p2) xs)


accessWhite (Board a _ _ _) = a
accessBlack (Board _ a _ _) = a
accessTurn (Board _ _ a _) = a
accessPlayer (Board _ _ _ a) = a

storeGameToJSON file = do
    storeGame initGame file

sup x y
    | x < y = True
    | otherwise = False


forceMove (Board w b t p)
    | p == White = concat [forceCatchWhite x b | x <- w]
    | otherwise = concat [forceCatchBlack x w | x <- b]

nextPlayer p
    | p == White = Black
    | otherwise = White

nextBoards:: Board -> [Board]
nextBoards (Board w b t p) =
    if f == []
    then

        if (p == White)
        then
            [
                (Board (replacePawn x w) b (t + 1) (nextPlayer p))
                | x <- (concat [filterBusy (forward x) (w ++ b)| x <- w])
            ]
        else
            [
                (Board (replacePawn x b) w (t + 1) (nextPlayer p))
                | x <- (concat [filterBusy (backward x) (w ++ b)| x <- b])
            ]
    else
    [
        (Board (replacePawn x w) b t p)
        | x <- f
    ]
    where
        f = forceMove (Board w b t p)

getPieceB x y [] = ' '
getPieceB x y ((Piece xx yy p):xs)
    | (xx == x && yy == y) = 'O'
    | otherwise = getPieceB x y xs
getPieceW x y [] b = getPieceB x y b
getPieceW x y ((Piece xx yy p):xs) b
    | (xx == x && yy == y) = 'X'
    | otherwise = getPieceW x y xs b


displayBoard (Board w b t p) = do
    putStrLn $concat [[(getPieceW y x w b) | y <- [1..8]]++"\n" |x <- [1..8]]
    putStrLn ("turn: " ++ (show t))
    putStrLn ("player: "++ (show p))

gameLoop board = do
    putStrLn $show $nextBoards board
    let n = ((nextBoards board)!!1)
    displayBoard n
    gameLoop n


initGameFromJSON file = do
    x <- readJSON file
    gameLoop $fromJust (boardDecode x::Maybe Board)

