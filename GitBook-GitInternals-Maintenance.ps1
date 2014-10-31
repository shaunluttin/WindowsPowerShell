

# maintenance
cls
git gc --auto
dir .git/refs -Recurse -File
git gc
dir .git/refs -Recurse -File
cat .git/packed-refs 

# data recovery
cls
git log --pretty=oneline -5
git reset --hard 15f57
git log --pretty=oneline -5
git reflog
git log -g -5
git branch recovery-branch 54e0f30
git log --pretty=oneline recovery-branch -5
git branch -D recovery-branch
rm -r -force .git/logs
git fsck --full
git branch recovery-branch2 54e0f
git log --pretty=oneline recovery-branch2 -5

# removing objects
curl http://kernel.org/pub/software/scm/git/git-2.1.3.tar.gz > git.tgz
git add git.tgz
git commit -m "Added git tarball.";
git rm git.tgz
git commit -m "oops - removed large tarball."
git gc
git count-objects -v
dir -Recurse .git/objects/pack
git verify-pack -v .\.git\objects\pack\pack-a5300c1fce152debad4e1206892d2c288fd55e7a.idx 
git filter-branch --index-filter 'git rm --cached --ignore-unmatch git.tgz'
rm -Recurse -Force .\.git\refs\original
rm -Recurse -Force .git\logs
git gc
git count-objects -v
git prune --expire '2014-10-30'