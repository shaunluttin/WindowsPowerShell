# WindowsPowerShell

Clone to your Windows PowerShell profile directory. 

    cd ~\Documents
    git clone https://github.com/bigfont/WindowsPowerShell.git

Install PoshGit and move its module contents (`.ps1` and `.psm1` files) to the modules folder. 

    choco install poshgit -y
    cd C:\tools\poshgit\dahlbyk-posh-git-fadc4dd
    dir *.ps* | % { copy $_ ~\Documents\WindowsPowerShell\Modules\Posh-Git }

Then restart PowerShell.
