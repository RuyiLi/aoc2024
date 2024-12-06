@grid = ();
$gr = 0;
$gc = 0;
$rownum = 0;
while (my $line = <STDIN>) {
  chomp($line);
  push(@grid, $line);
  my $guardpos = index($line, "^");
  if ($guardpos != -1) {
    $gr = $rownum;
    $gc = $guardpos;
  }
  $rownum++;
}

$rows = scalar @grid;
$cols = length(@grid[0]);
@adj = (
  [-1, 0],
  [0, 1],
  [1, 0],
  [0, -1]
);

sub bfs {
  my $r = $gr;
  my $c = $gc;
  my %visited = ();
  my $dir = 0;
  while (1) {
    my $vkey = "$r,$c";
    $visited{$vkey} = ($visited{$vkey} // 0) + 1;
    my $tmp = $visited{$vkey};
    if ($visited{$vkey} >= 6) {
      # infinite loop
      return -1;
    }

    my ($dr, $dc) = @{$adj[$dir]};
    my $tr = $r + $dr;
    my $tc = $c + $dc;
    if (not (0 <= $tr < $rows and 0 <= $tc < $cols)) {
      my $numvis = scalar keys %visited;
      return $numvis;
    }

    my $cell = substr($grid[$tr], $tc, 1);
    if ($cell eq "#") {
      $dir = ($dir + 1) % 4;
    } else {
      $r = $tr;
      $c = $tc;
    }
  }
}

# Puzzle 1
printf "Puzzle 1: " . bfs() . "\n";

# Puzzle 2
my $count = 0;
foreach my $or (0..$rows - 1) {
  foreach my $oc (0..$cols - 1) {
    my $cell = substr($grid[$or], $oc, 1);
    if ($cell ne ".") {
      next;
    }
    substr($grid[$or], $oc, 1) = "#";
    if (bfs() == -1) {
      $count++;
    }
    substr($grid[$or], $oc, 1) = $cell;
  }
}
printf "Puzzle 2: $count\n";
