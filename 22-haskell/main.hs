import System.IO (isEOF)
import Control.Monad (replicateM)
import Data.Bits (xor, shiftL, shiftR)
import Data.List (tails)
import qualified Data.HashMap.Strict as HashMap
-- no hashmap in std???

numChanges = 2000

windows :: Int -> [a] -> [[a]]
windows m = foldr (zipWith (:)) (repeat []) . take m . tails

mixPrune :: Int -> Int -> Int
mixPrune = xor . (\n -> n `mod` 16777216)

nextSecret :: Int -> Int
nextSecret n =
  let n' = mixPrune (n `shiftL` 6) n
      n'' = mixPrune (n' `shiftR` 5) n'
  in mixPrune (n'' `shiftL` 11) n''

seqPrices :: Int -> HashMap.HashMap (Int, Int, Int, Int) Int
seqPrices secret =
  let secrets = take (numChanges + 1) (iterate nextSecret secret)
      prices = map (\n -> n `mod` 10) secrets
      groups = windows 5 prices
  in foldr (\ps acc -> 
    let diffs = zipWith (-) (tail ps) ps
        dkey = (diffs !! 0, diffs !! 1, diffs !! 2, diffs !! 3)
    in HashMap.insert dkey (last ps) acc
  ) HashMap.empty groups

main :: IO()
main = do
  secrets <- map read . lines <$> getContents :: IO [Int]

  let newSecrets = map (\s -> iterate nextSecret s !! numChanges) secrets
  putStrLn $ "Puzzle 1: " ++ show (foldl (+) 0 newSecrets)

  let secretSeqPrices = foldl (HashMap.unionWith (+)) HashMap.empty (map seqPrices secrets)
  putStrLn $ "Puzzle 2: " ++ show (maximum $ HashMap.elems secretSeqPrices)
