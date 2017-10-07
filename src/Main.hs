module Main where
import Model.Game
main :: IO ()
main = do 
    storeGameToJSON "base2.json"
    initGameFromJSON "base2.json"
    
