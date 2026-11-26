#!/usr/bin/env bats

setup () {
  bats_require_minimum_version 1.5.0
  dir=$(dirname "$BATS_TEST_FILENAME")
  cd "$dir"
  cpus=$(nproc)
  exe="$dir/../bin/barrnap --threads $cpus"
  dbs="bac arc fun"
  tab=$'\t'
  TRNA="${tab}tRNA${tab}"
  RRNA="${tab}rRNA${tab}"
  NCRNA="${tab}ncRNA${tab}"
  OPERON="${tab}operon${tab}"
  SEQREG="##sequence-region"
}
@test "Script syntax check" {
  run -0 perl -c "$dir/../bin/barrnap"
}
@test "Version" {
  run -0 $exe --version
  [[ "$output" =~ "barrnap" ]]
}
@test "Help" {
  run -0 $exe --help
  [[ "$output" =~ "threads" ]]
}
@test "Ciiation" {
  run -0 $exe --citation
  [[ "$output" =~ "Seemann" ]]
}
@test "No parameters" {
  run ! $exe
}
@test "Bad option" {
  run ! $exe --doesnotexist
}
@test "Install DBs (in CI only)" {
  if [ "$GITHUB_ACTIONS" == "true" ]; then
    run -0 $exe --threads $cpus --updatedb
    [ -r "$dir/../build/Rfam" ]
    [ -r "$dir/../build/blacklist.txt" ]
  fi
}
@test "List DBs" {
  run -0 $exe --listdb
  [[ "$output" =~ "--kingdom" ]]
}
@test "Null input" {
  run ! $exe null.fa
  [[ "$output" =~ "ERROR" ]]
}
@test "Empry input" {
  run ! $exe empty.fa
  [[ "$output" =~ "ERROR" ]]
}
@test "Weird poly-G sequence" {
  run -0 $exe --fast polyg.fa
  [[ "$output" =~ "Found 0 features" ]]
}
@test "Input with no hits" {
  run -0 $exe nohits.fa
  [[ "$output" =~ "Found 0 features" ]]
}
@test "Fast mode" {
  run -0 $exe -q --fast small.fa
  [[ "$output" =~ $RRNA ]]
}
@test "Aragorn clipping is reported and retained as partial in GFF3" {
  local fixture="$BATS_TEST_TMPDIR"
  printf '>short with a description\n%080d\n>long\n%0100d\n' 0 0 |
    tr 0 A > "$fixture/contigs.fa"
  cat > "$fixture/aragorn" <<'EOF'
#!/bin/sh
if [ "$1" = '-h' ]; then
  echo 'ARAGORN v1.2.41'
  exit 0
fi
cat > "$4" <<'REPORT'
>short with a description
5 genes found
1    tRNA-Asn    c[-1,74]    33    (gtt)
2    tRNA-Ala    [8,81]      34    (tgc)
3    tmRNA       [0,83]      35,45 TAG**
4    tRNA-Ile    [81,90]     35    (gat)
5    tRNA-Val    c[1,80]     35    (tac)
>long
1 gene found
1    tRNA-Ala    [8,81]      34    (tgc)
>end    2 sequences 5 tRNA genes 1 tmRNA genes
REPORT
EOF
  chmod +x "$fixture/aragorn"

  run -0 --separate-stderr env PATH="$fixture:$PATH" "$dir/../bin/barrnap" --threads 1 \
    --trna --no-rrna "$fixture/contigs.fa"
  [[ $(grep -c 'Clipping aragorn:1.2.41 prediction' <<< "$stderr") -eq 3 ]]
  [[ "$stderr" == *'WARNING: Clipping aragorn:1.2.41 prediction tRNA-Asn short c[-1,74] to 1..74 (length 80)'* ]]
  [[ "$stderr" == *'WARNING: Clipping aragorn:1.2.41 prediction tRNA-Ala short [8,81] to 8..80 (length 80)'* ]]
  [[ "$stderr" == *'WARNING: Clipping aragorn:1.2.41 prediction tmRNA short [0,83] to 1..80 (length 80)'* ]]
  [[ "$stderr" == *'No in-contig interval for aragorn:1.2.41 prediction tRNA-Ile short [81,90]'* ]]
  awk -F '\t' '
    $3 == "tRNA" || $3 == "tmRNA" { count++ }
    $1 == "short" && $3 == "tRNA" && $4 == 1 && $5 == 74 && $7 == "-" &&
      $9 ~ /;partial=true;start_range=\.,1$/ { left = 1 }
    $1 == "short" && $3 == "tRNA" && $4 == 8 && $5 == 80 && $7 == "+" &&
      $9 ~ /;partial=true;end_range=80,\.$/ { right = 1 }
    $1 == "short" && $3 == "tmRNA" && $4 == 1 && $5 == 80 && $7 == "+" &&
      $9 ~ /;partial=true;start_range=\.,1;end_range=80,\.$/ { both = 1 }
    $1 == "short" && $3 == "tRNA" && $4 == 1 && $5 == 80 && $7 == "-" &&
      $9 !~ /;partial=/ { full = 1 }
    $1 == "long" && $3 == "tRNA" && $4 == 8 && $5 == 81 && $7 == "+" &&
      $9 !~ /;partial=/ { long = 1 }
    END { exit !(count == 5 && left && right && both && full && long) }
  ' <<< "$output"
}
@test "Mini bacterial genome" {
  local outseq="${BATS_TMPDIR}/outseq.fa"
  run -0 $exe --all --quiet \
    --outseq "$outseq" \
    --incseqreg --incseq --addids \
    small.fa
  [[ "$output" =~ $TRNA ]]
  [[ "$output" =~ $RRMA ]]
  [[ "$output" =~ $NCRNA ]]
  [[ "$output" =~ "ID=5S" ]]
  [[ "$output" =~ "ID=16S" ]]
  [[ "$output" =~ "ID=23S" ]]
  [[ "$output" =~ "Alias=SSU" ]]
  [[ ${lines[0]} =~ "##gf" ]]
  [[ "$output" =~ $SEQREG ]]
  [[ "$output" =~ "##FASTA" ]]
  [[ "$output" =~ ">small" ]]
  [[ ! $output =~ "tmRNA\*" ]]
  [[ ! $output =~ "_tmRNA" ]]
  [[ -r "$outseq" ]]
  run -0 grep '>small:' "$outseq"
}

@test "Reverse-strand RBS ends match the mRNA boundary" {
  run -0 $exe --mrna --no-rrna --quiet bac.fa
  awk -F '\t' '
    $3 == "mRNA" && $7 == "-" { mrna_end[$1, $5] = 1 }
    $3 == "RBS" && $7 == "-" && $4 < $5 { rbs_end[$1, $5] = 1; count++ }
    END {
      if (!count) {
        print "Expected a multi-base reverse-strand RBS" > "/dev/stderr"
        exit 1
      }
      for (key in rbs_end) {
        if (!(key in mrna_end)) {
          split(key, locus, SUBSEP)
          print "Reverse-strand RBS end without a matching mRNA end", locus[1], locus[2] > "/dev/stderr"
          exit 1
        }
      }
    }
  ' <<< "$output"
}

barrnap_legacy() {
  run -0 $exe --quiet \
    --kingdom "$1" "$1.fa"
  [[   "$output" =~ $RRMA  ]]
  [[ ! "$output" =~ $TRNA  ]]
  [[ ! "$output" =~ $NCRNA ]]
  [[ ! "$output" =~ "##FASTA" ]]
  [[ ! "$output" =~ $SEQREG ]]
  [[ ! "$output" =~ "ID=" ]]
}
@test "Bacteria" {
  #type barrnap_legacy
  run barrnap_legacy "bac"
  #echo "STATUS=$status" >&3
  #echo "LINE0=${lines[0]}" >&3
  #echo "OUTPUT=$output" >&3
  #[[ "$FOO" =~ "5S_rRNA" ]]
}
@test "Archaea" {
  run -0 barrnap_legacy "arc"
  #[[ "$output" =~ "5S_rRNA" ]]
}
@test "Fungi" {
  run -0 barrnap_legacy "fun"
  #[[ "$output" =~ "28S_rRNA" ]]
}
