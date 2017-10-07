{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Model.DataStructure where

import Data.Aeson
import Data.Text
import Control.Applicative
import Control.Monad
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import Data.Eq

data Color = White | Black
    deriving (Show, Generic)
data Piece =  Piece Int Int String 
    deriving (Show, Generic)

data Board = Board{
    white::[Piece],
    black::[Piece],
    turn::Int,
    player::Color
    } deriving (Show, Generic)
instance Eq Color where
    c == cc = show c == show cc
instance Eq Piece where
    (Piece x y p) == (Piece xx yy pp) = (x == xx) && (y == yy)
instance FromJSON Color
instance ToJSON Color
instance FromJSON Piece
instance ToJSON Piece
instance FromJSON Board
instance ToJSON Board where
   toJSON (Board white black turn player) =
        object ["white" .= white, "black" .= black, "turn" .= turn, "player" .= player]

initGame = Board 
            {
                white=[(Piece a b "p")| a<-[1..8], b<-[1..3]
                        ,   ((a `mod` 2 == 1) && (b `mod` 2 == 1)) 
                                || 
                            ((a `mod` 2 == 0) && (b `mod` 2 == 0))],
                black=[(Piece a b "p")| a<-[1..8], b<-[6..8]
                        ,   ((a `mod` 2 == 1) && (b `mod` 2 == 1)) 
                                || 
                            ((a `mod` 2 == 0) && (b `mod` 2 == 0))],
                turn=0,
                player = White
            }

storeGame :: Board -> FilePath -> IO ()
storeGame board file = B.writeFile file $encode(toJSON board) 

boardDecode x = decode x
readJSON file = B.readFile file 

