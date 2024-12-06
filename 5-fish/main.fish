while read -d '|' l r
  if test -z "$l"
    break
  end
  set -a "k_$l" $r
  set -a "d_$r" $l
end

set i 0
set total 0
while read line
  set pages (string split ',' $line)
  set seen
  set good 1
  for page in $pages
    set -a seen $page
    set pagekey "k_$page"
    for dep in $$pagekey
      if contains $dep $seen
        set good 0
      end
    end
  end

  if test $good -eq 1
    set len (count $pages)
    set mid (math (math -s0 $len / 2) + 1)
    set total (math $total + $pages[$mid])
  else
    set -a badupdates $i
    set "badupdate_$i" $pages
  end

  set i (math $i + 1)
end
echo "Puzzle 1: $total"

set total 0
for i in $badupdates
  set badupdatekey "badupdate_$i"
  set pages $$badupdatekey
  
  # assume only one possible ordering
  set node $pages
  for page in $pages
    set pagekey "k_$page"
    set "tempk_$page" $$pagekey   # copy page so we can mutate
    for dep in $$pagekey
      set node (string match -v $dep $node)
    end
  end
    
  set res
  for _i in $pages
    set -a res $node
    set pagekey "tempk_$node"
    set newnode
    for dep in $$pagekey
      if contains $dep $pages
        set "tempk_$node" (string match -v $dep $$pagekey)
        set noinc 1
        for u in $pages
          set pagekeyu "tempk_$u"
          if contains $dep $$pagekeyu
            set noinc 0
          end
        end
        if test $noinc -eq 1
          set newnode $dep
        end
      end
    end
    set node $newnode
  end

  set len (count $res)
  set mid (math (math -s0 $len / 2) + 1)
  set total (math $total + $res[$mid])
end
echo "Puzzle 2: $total"
