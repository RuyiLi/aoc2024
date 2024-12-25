use namespace HH\Lib\C;
use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;
use namespace HH\Lib\Math;

use HH\Lib\Ref;

<<__EntryPoint>>
function main(): void {
  $A = new Ref(read_register());
  $B = new Ref(read_register());
  $C = new Ref(read_register());
  fgets(STDIN);

  $raw_program = Str\trim(fgets(STDIN));
  $raw_program = Str\split($raw_program, ": ")[1];
  $program = Str\split($raw_program, ",");
  $program = Vec\Map($program, $v ==> Str\to_int($v));

  $b = $B->get();
  $c = $C->get();

  $puzzle1 = interpret($A, $B, $C, $program);
  echo "Puzzle 1: " . $puzzle1 . "\n";

  // bsearch approx lower/upper bounds based on output length.
  // => (35_000_000_000_000, 290_000_000_000_000)
  // outputs are "grouped" by suffix; look for groups in increments of 1e9
  //  that cause the output to share a suffix with my input program.
  // repeat with longer suffix/smaller increment to find new 
  //  lower/upper bounds until the machine can reasonably brute force.
  // => (164376000000000, 164927000000000), 1e8, taillen 3
  //  => (164376950000000, 164926750000000), 5e7, taillen 3
  //   => (164514420000000, 164583150000000), 1e7, taillen 4
  // eventually the suffixes split
  // => (164514425000000, 164540200000000), 5e6, taillen 5
  //  => (164514427000000, 164516575000000), 5e5, taillen 6
  //   => (164515366800000, 164516457350000), 5e4, taillen 8
  //    => (164515377315000, 164515379415000), 5e3, taillen 9
  //     => (164515378364400, 164515378626600), 100, taillen 10
  //      => DEAD
  //    => (164516451055000, 164516455255000), 5e3, taillen 9
  //     => (164516454346700, 164516454465600), 100, taillen 12
  //      => FOUND
  //   => (164515366830000, 164515501050000), 1e4, taillen 7
  //    => (164515377315000, 164515379413000), 1e3, taillen 9
  //     => (164515378364400, 164515378626600), 100, taillen 10
  //      => DEAD
  // => (164557375000000, 164565970000000), 5e6, taillen 5
  //  => (164558450000000, 164559525000000), 1e6, taillen 6
  //   => DEAD (no results for taillen 7)

  $a = 164516454346700;
  while ($a <= 164516454465600) {
    $A->set($a);
    $B->set($b);
    $C->set($c);
    $output = interpret($A, $B, $C, $program);
    // echo "$a: $output\n";
    if ($output == $raw_program) {
      break;
    }
    $a += 1;
  }
  echo "Puzzle 2: " . $a . "\n";
}

function read_register(): int {
  $line = Str\trim(fgets(STDIN));
  $value = Str\split($line, ": ")[1];
  return Str\to_int($value);
}

// mutates $A, $B, $C
function interpret(Ref $A, Ref $B, Ref $C, HH\vec $program): string {
  $combo = (int $op) ==> {
    switch ($op) {
      case 0:
      case 1:
      case 2:
      case 3:
        return $op;
      case 4:
        return $A->get();
      case 5:
        return $B->get();
      case 6:
        return $C->get();
      default:
        echo "bad op $op\n";
        return;
    }
  };

  $outputs = vec[];
  $i = 0;
  $N = C\count($program);
  while ($i < $N) {
    $inst = $program[$i];
    $op = $program[$i + 1];

    if ($inst == 0) {
      // adv
      $num = $A->get();
      $den = 2 ** $combo($op);
      $A->set(Math\int_div($num, $den));
    } else if ($inst == 1) {
      // bxl
      $B->set($B->get() ^ $op);
    } else if ($inst == 2) {
      // bst
      $B->set($combo($op) % 8);
    } else if ($inst == 3) {
      // jnz
      if ($A->get() != 0) {
        $i = $op;
        continue;
      }
    } else if ($inst == 4) {
      // bxc
      $B->set($B->get() ^ $C->get());
    } else if ($inst == 5) {
      // out
      $outputs[] = $combo($op) % 8;
    } else if ($inst == 6) {
      // bdv
      $num = $A->get();
      $den = 2 ** $combo($op);
      $B->set(Math\int_div($num, $den));
    } else {
      // cdv
      $num = $A->get();
      $den = 2 ** $combo($op);
      $C->set(Math\int_div($num, $den));
    }
    $i += 2;
  }

  return Str\join($outputs, ",");
}
