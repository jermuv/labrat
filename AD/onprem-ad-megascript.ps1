### Perävalotakuu, omiin legacy juttuihin tarkoitettu muistiinpano
### no miksi tämmöinen megaskripti? no koska mun favoriitti työkalu tulkitaan haitakkeeksi :D
### laittelin viimeisimpiin riveihin tuon samaccountnamen mukaan ettei unohdu
### user search

# general
get-aduser -properties *
get-aduser -properties * | select-object -property *
get-aduser -filter 'enabled -eq "false"'
get-aduser -filter 'enabled -eq "false"' -properties useraccountcontrol, admincount
get-aduser -filter 'enabled -eq "true"' -properties * | export-csv -path .\all.csv  

# date manipulation
get-aduser -filter 'enabled -eq "true"' -properties whencreated, whenchanged, userprincipalname, useraccountcontrol, trustedfordelegation, pwdlastset | ft Name,@{Name='PwdLastSet';Expression={[DateTime]::FromFileTime($_.PwdLastSet)}}
get-aduser -filter 'enabled -eq "true"' -properties whencreated, whenchanged, userprincipalname, useraccountcontrol, pwdlastset | sort PwdLastSet -desc | ft Name,@{Name='PwdLastSet';Expression={[DateTime]::FromFileTime($_.PwdLastSet)}},whenchanged,whencreated



# admin accounts
get-aduser -ldapfilter "(admincount=1)" -properties *
get-aduser -ldapfilter "(admincount=1)" -properties whencreated, whenchanged, userprincipalname, useraccountcontrol, pwdlastset | sort PwdLastSet -desc | ft Name,useraccountcontrol,@{Name='PwdLastSet';Expression={[DateTime]::FromFileTime($_.PwdLastSet)}},whenchanged,whencreated

# generally a list of different useraccountcontrol values
get-aduser -filter * -properties useraccountcontrol | select-object useraccountcontrol | sort useraccountcontrol | get-unique -AsString
get-aduser -ldapfilter "(useraccountcontrol=66050)"


# get favourite dumps
get-aduser -filter * -properties useraccountcontrol, description, info, admincount, pwdlastset, lastlogon, lastlogontimestamp, whencreated, whenchanged
get-aduser -filter * -properties useraccountcontrol, admincount, pwdlastset, lastlogon, lastlogontimestamp, whencreated, whenchanged | ft
get-aduser -ldapfilter "(description=*)" -properties name, description
get-aduser -ldapfilter "(info=*)" -properties name, description

# dates
## initial test for getting some random dates out
get-aduser -filter * -properties lastlogontimestamp, whencreated, whenchanged `
| select-object name, @{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}

## second test for getting some random dates out
get-aduser -filter * -properties lastlogontimestamp, whencreated, whenchanged `
| select-object name, `
@{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}, `
@{name="I_whencreated"; expression={($_.whencreated.tostring('yyyy-MM-dd'))}} `
| export-csv -path .\jeahjoo.csv

## third test
## second test for getting some random dates out
$dumppitime = get-date -format "hhmmss"
get-aduser -filter * -properties useraccountcontrol, employeeid, pwdlastset, lastlogontimestamp, lastlogon, whencreated, whenchanged `
| select-object name, useraccountcontrol, employeeid, `
@{name="I_pwdlastset"; expression={[datetime]::fromfiletime($_.pwdlastset).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogon"; expression={[datetime]::fromfiletime($_.lastlogon).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}, `
@{name="I_whencreated"; expression={($_.whencreated.tostring('yyyy-MM-dd'))}} `
| export-csv -path .\dumppiroinen$dumppitime.csv


# one more, including some random additional?
$dumppitime = get-date -format "hhmmss"
get-aduser -filter * -properties useraccountcontrol, samaccountname, employeeid, admincount, pwdlastset, lastlogontimestamp, lastlogon, whencreated, whenchanged `
| select-object samaccountname, name, useraccountcontrol, employeeid, admincount, `
@{name="I_pwdlastset"; expression={[datetime]::fromfiletime($_.pwdlastset).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogon"; expression={[datetime]::fromfiletime($_.lastlogon).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}, `
@{name="I_whencreated"; expression={($_.whencreated.tostring('yyyy-MM-dd'))}} `
| export-csv -path .\dumppiroinen$dumppitime.csv

## https://www.reddit.com/r/PowerShell/comments/gu81np/getaduser_10000_object_return_limit_issue/

# konetilit kanssa
$dumppitime = get-date -format "hhmmss"
get-adcomputer -filter * -properties distinguishedname, samaccountname, useraccountcontrol, admincount, pwdlastset, lastlogontimestamp, lastlogon, whencreated, whenchanged `
| select-object distinguishedname, name, samaccountname, useraccountcontrol, admincount, `
@{name="I_pwdlastset"; expression={[datetime]::fromfiletime($_.pwdlastset).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogon"; expression={[datetime]::fromfiletime($_.lastlogon).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}, `
@{name="I_whencreated"; expression={($_.whencreated.tostring('yyyy-MM-dd'))}} `
| export-csv -path .\dumppiroinen$dumppitime.csv

# käyttäjät ja dn mukana
$dumppitime = get-date -format "hhmmss"
get-aduser -filter * -properties distinguishedname, samaccountname, useraccountcontrol, employeeid, admincount, pwdlastset, lastlogontimestamp, lastlogon, whencreated, whenchanged `
| select-object distinguishedname, name, samaccountname, useraccountcontrol, employeeid, admincount, `
@{name="I_pwdlastset"; expression={[datetime]::fromfiletime($_.pwdlastset).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogontimestamp"; expression={[datetime]::fromfiletime($_.lastlogontimestamp).tostring('yyyy-MM-dd')}}, `
@{name="I_lastlogon"; expression={[datetime]::fromfiletime($_.lastlogon).tostring('yyyy-MM-dd')}}, `
@{name="I_whenchanged"; expression={($_.whenchanged.tostring('yyyy-MM-dd'))}}, `
@{name="I_whencreated"; expression={($_.whencreated.tostring('yyyy-MM-dd'))}} `
| export-csv -path .\dumppiroinen$dumppitime.csv