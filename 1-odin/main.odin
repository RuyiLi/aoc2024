package main

import "core:io"
import "core:os"
import "core:fmt"
import "core:slice"
import "core:bufio"
import "core:strconv"
import "core:strings"

main :: proc() {
	stream := os.stream_from_handle(os.stdin)
	
	// https://odin-lang.org/docs/overview/#allocators
	scanner: bufio.Scanner
	bufio.scanner_init(&scanner, stream, context.temp_allocator)
	defer bufio.scanner_destroy(&scanner)

	left: [dynamic]int
	right: [dynamic]int
	defer delete(left)
	defer delete(right)

	for bufio.scanner_scan(&scanner) {
		line := bufio.scanner_text(&scanner)
		tokens := strings.split(line, " ")
		l := strconv.atoi(tokens[0])
		r := strconv.atoi(tokens[len(tokens) - 1])
		append(&left, l)
		append(&right, r)
	}

	puzzle_1(left[:], right[:])
	puzzle_2(left[:], right[:])
}

puzzle_1 :: proc(left: []int, right: []int) {
	slice.sort(left)
	slice.sort(right)

	total := 0
	for v in soa_zip(l=left, r=right) {
		total += abs(v.l - v.r)
	}
	
	fmt.println(total)
}

puzzle_2 :: proc(left: []int, right: []int) {
	freq: map[int]int
	defer delete(freq)

	for r in right {
		freq[r] += 1
	}
	
	score := 0
	for l in left {
		score += l * freq[l]
	}

	fmt.println(score)
}
