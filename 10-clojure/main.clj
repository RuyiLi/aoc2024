(require '[clojure.set])

(defn read-grid []
  (map
    (partial map (fn [c] (Character/digit c 10)))
    (clojure.string/split-lines (slurp *in*))))

;; just assume rows == cols
(defn at [grid r c]
  (let [size (count grid)]
    (if (and (<= 0 r (- size 1)) (<= 0 c (- size 1)))
      (nth (nth grid r) c)
      -1)))

(defn zeroes [grid]
  (let [size (count grid)]
    (for [r (range size)
          c (range size)
          :when (= 0 (at grid r c))]
      [r c])))

(defn trail-reduce [base coll]
  (letfn [(rec [grid [r c]]
            (if (== 9 (at grid r c))
              (base [r c])
              (coll
                (for [[dr dc] [[-1 0] [0 1] [1 0] [0 -1]]
                      :let [tr (+ r dr) tc (+ c dc)]
                      :when (= (+ 1 (at grid r c)) (at grid tr tc))]
                  (rec grid [tr tc])))))]
    (memoize rec)))

;; puzzle 1
(def trail-ends (trail-reduce (partial hash-set) (partial apply clojure.set/union)))
(defn puzzle1 [grid]
  (reduce + (map (comp count (partial trail-ends grid)) (zeroes grid))))

;; puzzle 2
(def trail-rating (trail-reduce (fn [_] 1) (partial reduce +)))
(defn puzzle2 [grid]
  (reduce + (map (partial trail-rating grid) (zeroes grid))))

(let [grid (read-grid)]
  (printf "Puzzle 1: %d\n" (time (puzzle1 grid)))
  (printf "Puzzle 2: %d\n" (time (puzzle2 grid))))
