$userlist = import-csv -path .\users.csv -delimiter "|"
$userlist | format-table