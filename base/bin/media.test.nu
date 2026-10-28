#!/usr/bin/env -S nu --no-config-file
# End-to-end tests for `media` against a scratch folder on the real server.
# Run: nu ~/dotfiles/base/bin/media.test.nu

const MEDIA = path self media
const STUB = "MEDIA-ARCHIVED.md"

$env.MEDIA_ROOT = "/tank/archive/.selftest"
$env.MEDIA_STATE = (mktemp -d -t media-state.XXXXXX)
let fx = ($env.HOME | path join ".media-selftest")
let remote = {|name| $"($env.MEDIA_ROOT)/.media-selftest/($name)" }

def --wrapped media [...args] { ^$MEDIA ...$args | complete }

def check [name: string, ok: bool, detail?: string] {
    if $ok { print $"ok    ($name)" } else { print $"FAIL  ($name) ($detail | default '')"; exit 1 }
}

def hashes [dir: string] {
    cd $dir
    ^find . -type f ! -name .media-manifest.sha256 ! -name $STUB -print0
    | split row (char nul) | where $it != "" | each {|f| ^shasum -a 256 $f } | sort
}

# Error text with Nushell's line wrapping undone.
def said [r: record, s: string] {
    $r.stderr | str replace --all --regex '\s*\n\s*\|?\s*' " " | str contains $s
}

def ssh-sh [cmd: string] { ^ssh -o BatchMode=yes server $cmd | complete }

rm -rf $fx
ssh-sh $"rm -rf ($env.MEDIA_ROOT) && mkdir ($env.MEDIA_ROOT)" | ignore
mkdir $fx

# Round trip: awkward names, nesting, a symlink, binary data.
let rt = ($fx | path join rt)
mkdir ($rt | path join "nested/deep")
"hello\n" | save ($rt | path join "a b.txt")
"hej\n" | save ($rt | path join "ö it's.txt")
^head -c 1048576 /dev/urandom | save ($rt | path join "nested/deep/x.bin")
^head -c 20971520 /dev/urandom | save ($rt | path join "big.bin")
^ln -s "a b.txt" ($rt | path join "link")
let ref = (hashes $rt)

let r = (media archive $rt --dry-run)
check "dry run succeeds" ($r.exit_code == 0) $r.stderr
check "dry run leaves files and no stub" ((hashes $rt) == $ref and not ($rt | path join $STUB | path exists))
check "dry run creates nothing on the server" ((ssh-sh $"test -e (do $remote rt)").exit_code != 0)

let r = (media archive $rt)
check "archive succeeds" ($r.exit_code == 0) $r.stderr
check "only the stub is left" ((ls -a $rt | get name | path basename) == [$STUB])
check "verify passes" ((media verify $rt).exit_code == 0)
check "status lists the archive" ((media status).stdout =~ ".media-selftest/rt")

let r = (media fetch $rt)
check "fetch succeeds" ($r.exit_code == 0) $r.stderr
check "fetched files are byte-identical" ((hashes $rt) == $ref)
check "symlink restored" (($rt | path join link | path type) == "symlink")
check "stub removed" (not ($rt | path join $STUB | path exists))

# Re-archive after a fetch updates the existing server copy.
"changed\n" | save -f ($rt | path join "a b.txt")
let r = (media archive $rt)
check "re-archive after fetch succeeds" ($r.exit_code == 0) $r.stderr

# A server file that rsync's quick check skips (same size and mtime, other
# content) must stop the archive before anything local is deleted.
let cor = ($fx | path join cor)
mkdir $cor
"AAAA\n" | save ($cor | path join f.txt)
^touch -t 202601010000 ($cor | path join f.txt)
ssh-sh $"mkdir -p (do $remote cor) && printf 'BBBB\\n' > (do $remote cor)/f.txt && touch -t 202601010000 (do $remote cor)/f.txt && : > (do $remote cor)/.media-manifest.sha256" | ignore
let r = (media archive $cor)
check "corrupt server copy fails the archive" ($r.exit_code != 0 and (said $r "did not match")) $r.stderr
check "local file kept after failed verify" ((open --raw ($cor | path join f.txt)) == "AAAA\n")
check "no stub after failed verify" (not ($cor | path join $STUB | path exists))

# `verify` catches corruption on the server after the fact.
ssh-sh $"printf X >> (do $remote rt)/nested/deep/x.bin" | ignore
check "verify detects server corruption" ((media verify $rt).exit_code != 0)
let r = (media fetch $rt)
check "fetch of corrupt copy fails" ($r.exit_code != 0) $r.stdout
check "stub kept when fetch fails" ($rt | path join $STUB | path exists)

# Refusals.
let fg = ($fx | path join foreign)
mkdir $fg
"x\n" | save ($fg | path join f.txt)
ssh-sh $"mkdir -p (do $remote foreign) && touch (do $remote foreign)/other" | ignore
let r = (media archive $fg)
check "refuses a server folder media did not make" ($r.exit_code != 0 and (said $r "not made by media")) $r.stderr

let g = ($fx | path join tracked)
mkdir $g
"x\n" | save ($g | path join f.txt)
^git -C $g init -q
^git -C $g add f.txt
let r = (media archive $g)
check "refuses git-tracked files" ($r.exit_code != 0 and (said $r "git-tracked")) $r.stderr

let u = ($fx | path join unreach)
mkdir $u
"x\n" | save ($u | path join f.txt)
let r = (with-env {MEDIA_HOST: "nonexistent.invalid"} { media archive $u })
check "unreachable host fails" ($r.exit_code != 0 and (said $r "cannot reach")) $r.stderr
check "unreachable host deletes nothing" (($u | path join f.txt | path exists) and not ($u | path join $STUB | path exists))

# A transfer killed mid-copy leaves the local folder intact and resumes.
let k = ($fx | path join killed)
mkdir $k
^head -c 314572800 /dev/urandom | save ($k | path join big.bin)
let kref = (hashes $k)
^bash -c $"'($MEDIA)' archive '($k)' >/dev/null 2>&1 & p=$!
  for i in $\(seq 300\); do pgrep -f 'rsync -a --partial ($k)' >/dev/null && break; sleep 0.1; done
  sleep 1; pkill -f 'rsync -a --partial ($k)'; wait $p; true"
check "killed transfer keeps local data" ((hashes $k) == $kref and not ($k | path join $STUB | path exists))
let r = (media archive $k)
check "rerun after kill completes" ($r.exit_code == 0) $r.stderr
check "rerun leaves only the stub" ((ls -a $k | get name | path basename) == [$STUB])

rm -rf $fx $env.MEDIA_STATE
ssh-sh $"rm -rf ($env.MEDIA_ROOT)" | ignore
print "all passed"
