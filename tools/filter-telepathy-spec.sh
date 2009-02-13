git filter-branch --prune-empty --tree-filter \
'rm -rf									\
AUTHORS 								\
NEWS 									\
*.conf 									\
*.png 									\
*.py 									\
*.sh 									\
*.css 									\
order 									\
spec* 									\
*.manager 								\
TODO* 									\
_* 									\
*.cheddar 								\
docs/* 									\
doc/* 									\
spec/*.xml 								\
telepathy/* 								\
telepathy/client/* 							\
telepathy/server/* 							\
tabby/* 								\
tools/gen*.py 								\
tools/*.def 								\
server/*.py 								\
client/*.py 								\
test/*.sh 								\
services*/*								\
client/.git-darcs-dir							\
doc/.git-darcs-dir							\
docs/.git-darcs-dir							\
server/.git-darcs-dir							\
services/.git-darcs-dir							\
services.in/.git-darcs-dir						\
tabby/.git-darcs-dir							\
telepathy/.git-darcs-dir						\
test/expected/.git-darcs-dir						\
test/.git-darcs-dir							\
test/input/.git-darcs-dir						\
test/services.in/.git-darcs-dir						\
test/services.in/org.freedesktop.Telepathy.ConnectionManager.cheddar	\
test/session.conf							\
tools/.git-darcs-dir							\
' -- master

git for-each-ref  --format='%(refname)' refs/original | while read ref;
	do git update-ref -d $ref;
done

git reflog expire --expire=0

git prune
git repack -adf

# drop merges
git rebase $(git log | tail | grep commit | cut -f2 -d' ')

