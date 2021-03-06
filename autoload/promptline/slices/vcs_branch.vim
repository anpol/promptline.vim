fun! promptline#slices#vcs_branch#function_body(options)
  let branch_symbol = promptline#symbols#get().vcs_branch
  let git = get(a:options, 'git', 1)
  let svn = get(a:options, 'svn', 0)
  let hg = get(a:options, 'hg', 0)
  let fossil = get(a:options, 'fossil', 0)

  let lines = [
        \'function __promptline_vcs_test() {',
        \'  local dir="$(pwd -P 2>/dev/null)"',
        \'  while [[ -n $dir ]]; do',
        \'    if test "$1" "$dir/$2"; then',
        \'      return 0',
        \'    fi',
        \'    dir=${dir%/*}',
        \'  done',
        \'  return 0',
        \'}',
        \'function __promptline_vcs_branch {',
        \'  if [ ! -z "$DISABLE_PROMPT_VCS_BRANCH" ]; then',
        \'    return 1',
        \'  fi',
        \'',
        \'  local branch',
        \'  local branch_symbol="' . branch_symbol . '"']

  if git
    let lines += [
        \'',
        \'  # git',
        \'  if hash git 2>/dev/null && __promptline_vcs_test -e .git; then',
        \'    if branch=$( { git symbolic-ref --quiet --short HEAD || git describe --tags --exact-match || git rev-parse --short HEAD; } 2>/dev/null ); then',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  if hg
    let lines += [
        \'',
        \'  # mercurial',
        \'  if hash hg 2>/dev/null && __promptline_vcs_test -e .hg; then',
        \'    if branch=$(hg branch 2>/dev/null); then',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  if svn
    let lines += [
        \'',
        \'  # svn',
        \'  if hash svn 2>/dev/null && __promptline_vcs_test -e .svn; then',
        \'    local svn_info',
        \'    if svn_info=$(svn info 2>/dev/null); then',
        \'      local svn_url=${svn_info#*URL:\ }',
        \'      svn_url=${svn_url/$' . "'" . '\n' . "'" . '*/}',
        \'',
        \'      local svn_root=${svn_info#*Repository\ Root:\ }',
        \'      svn_root=${svn_root/$' . "'" . '\n' . "'" . '*/}',
        \'',
        \'      if [[ -n $svn_url ]] && [[ -n $svn_root ]]; then',
        \'        # https://github.com/tejr/dotfiles/blob/master/bash/bashrc.d/prompt.bash#L179',
        \'        branch=${svn_url/$svn_root}',
        \'        branch=${branch#/}',
        \'        branch=${branch#branches/}',
        \'        branch=${branch%%/*}',
        \'',
        \'        printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'        return',
        \'      fi',
        \'    fi',
        \'  fi',
        \'']
  endif

  if fossil
    let lines += [
        \'',
        \'  # fossil',
        \'  if hash fossil 2>/dev/null && __promptline_vcs_test -f .fslckout; then',
        \'    if branch=$( fossil branch 2>/dev/null ); then',
        \'      branch=${branch##* }',
        \'      printf "%s" "${branch_symbol}${branch:-unknown}"',
        \'      return',
        \'    fi',
        \'  fi']
  endif

  let lines += [
        \'  return 1',
        \'}']
  return lines
endfun

