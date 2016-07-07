param($Name = $null)
cd $PSScriptRoot

$options = @{
    Timeout = 100
    Push    = $true
    Threads = 10

    Mail = @{
        To       = 'miodrag.milic@gmail.com'
        Server   = 'smtp.gmail.com'
        UserName = 'miodrag.milic@gmail.com'
        Password = gc $PSScriptRoot\mail_pass
        Port     = 587
        EnableSsl= $true
    }

    Script = { param($Phase, $Info)
        if ($Phase -ne 'END') { return }

        cd $PSScriptRoot

        $pushed = $Info.results | ? Pushed
        if (!$pushed) { return }

        "`nExecuting git pull"
        git pull

        "Commiting updated packages to git repository"
        $pushed | % { git add $_.PackageName }
        git commit -m "UPDATE BOT: $($pushed.length) packages updated"

        "`nPushing git"
        git push
    }
}

$global:update = updateall -Name $Name -Options $options
$global:update | Export-CliXML update_results.xml
$global:update | ft