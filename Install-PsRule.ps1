Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force
Install-Module -Name PSRule -Repository PSGallery -Scope CurrentUser -Force
Install-Module -Name PSRule.Rules.Azure -Repository PSGallery -Scope CurrentUser -Force

Update-Module -Name 'PSRule'
Update-Module -Name 'PSRule.Rules.Azure'