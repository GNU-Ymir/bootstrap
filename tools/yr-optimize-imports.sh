#! /bin/sh
#
# Rewrites the `use' block of Yr source files with yr-mode's
# `yr-optimize-imports': nested groups are merged, duplicate imports dropped,
# roots sorted alphabetically with `std' last, and distinct roots separated by a
# blank line. The rewrite is idempotent, so running it on an already tidy file
# changes nothing.
#
# Usage:
#   tools/yr-optimize-imports.sh [FILE...]
#
# With no FILE, every .yr file under src/ and test/ that the current branch
# changed against the default branch, which is what to run before committing.
#
# test_resources/ is never rewritten, even when named explicitly: those files
# are compiler inputs, and the `.stx' goldens of test_resources/syntax/ are a
# dump of the syntax tree their imports produce.
#
# The rewrite lives in yr-mode.el, outside this repo. Set YR_MODE_EL to point
# somewhere other than the default below.
set -e

YR_MODE_EL=${YR_MODE_EL:-$HOME/.elisp/yr-mode.el}
DEFAULT_BRANCH=${DEFAULT_BRANCH:-master}

command -v emacs >/dev/null 2>&1 || {
    echo "yr-optimize-imports: emacs is needed to run yr-mode's rewrite" >&2
    exit 1
}

test -f "$YR_MODE_EL" || {
    echo "yr-optimize-imports: $YR_MODE_EL not found, set YR_MODE_EL to yr-mode.el" >&2
    exit 1
}

if [ $# -eq 0 ]; then
    # both the committed and the not yet committed changes, since this runs
    # before a commit; sort -u because a file can appear in both lists
    set -- $( { git diff --name-only "$DEFAULT_BRANCH"...HEAD; git status --porcelain | cut -c4-; } \
                  | grep -E '^(src|test)/.*\.yr$' | sort -u)
fi

FILES=""
for f in "$@"; do
    case $f in
        */test_resources/*|test_resources/*) continue ;;
    esac
    test -f "$f" || continue
    FILES="$FILES $f"
done

test -n "$FILES" || { echo "yr-optimize-imports: no Yr source file to rewrite"; exit 0; }

# one emacs for the whole set: starting it up costs more than the rewrite does.
# Backups are off so it does not drop a .yr~ beside every file it touches, and a
# file is written back only when its text really changed: the rewrite marks the
# buffer modified even when it reproduces it, and saving anyway would bump the
# mtime of every file and make gyllir recompile an untouched tree.
emacs --batch -Q -l "$YR_MODE_EL" --eval '
(progn
  (setq make-backup-files nil)
  (dolist (file command-line-args-left)
    (with-current-buffer (find-file-noselect file)
      (when (save-excursion
              (goto-char (point-min))
              (re-search-forward "^[ \t]*use[ \t]+" nil t))
        (let ((before (buffer-string)))
          (yr-optimize-imports)
          (if (string= before (buffer-string))
              (set-buffer-modified-p nil)
            (save-buffer)
            (princ (format "rewrote %s\n" file)))))
      (kill-buffer))))' -- $FILES
