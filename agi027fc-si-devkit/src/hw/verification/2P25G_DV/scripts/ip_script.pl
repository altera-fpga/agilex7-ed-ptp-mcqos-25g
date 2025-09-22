#!/usr/bin/perl

$text= '$DESIGN_DIR';
$text1= '../../';
#IP LIST
open($DATA1, "<ip_list.tcl") or die "Couldn't open file file.txt, $!";
open($DATA2, ">ip_list.f") or die "Couldn't open file file.txt, $!";

while($line1=<$DATA1>)
{
	chomp $line1;
	$a1=substr($line1,28,1);
	$s1="I";
	if($a1 eq $s1){
		substr($line1,0,36)=$text1;
		}
	else{
		substr($line1,0,38)=$text1;
		}
		
	print $DATA2 "$line1\n";
}

