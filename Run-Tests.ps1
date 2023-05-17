# Run ps-rule tests
Assert-PSRule `
    -Module 'PSRule.Rules.Azure' `
    -Baseline 'Defaults' `
    -InputPath '**/.test/'