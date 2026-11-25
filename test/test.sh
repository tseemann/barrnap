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
