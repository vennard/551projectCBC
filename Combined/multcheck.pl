#!/usr/bin/perl

######################################################################
#############USE AT YOUR OWN RISK#####################################
# the revisions to this code are quick, hasty, and relatively untested
######################################################################
printf "\nWARNING: Kind of works with negative numbers...\n";
printf "         Only really trust it with + numbers\n";
print "\nEnter multiplicand (goes in P_reg) (in hex): ";
$m1 = <STDIN>;
print "Enter multiplier (+/- # used based on LSBs of P_reg) (in hex): ";
$m2 = <STDIN>;
chop($m1);
chop($m2);
$m1 = &from_hex($m1);
$m2 = &from_hex($m2);
if ($m1>=8192) { $m1 = ($m1 % 8192) - 8192; }
if ($m2>=8192) { $m2 = ($m2 % 8192) - 8192; }

printf "\nm1 = %8x\n",$m1;

$p = $m1*2;
$p = $p % (2**15);
printf "\nInitial load Preg = %8x\n",$p;
printf "---------------------------\n";
for ($x=0; $x<14; $x++) {
  $sel = $p % 4;	# least significant 2 bits
  if ($sel==1) { $p += $m2*32768; print "adding +    ";}
  elsif ($sel==2) { $p -= $m2*32768; print "adding -    "; }
  else { print "adding zero "; }
  $p = $p % (2**29);
  $p = ($p>>1);
  if ($p>(2**27)) {
    $p += 2**28;
  } 
  printf "P_reg = %8x\n",$p;
}
printf "---------------------------\n";
$p = ($p>>1);
$full_result = $p;
if ($p>(2**27)) {
  $p += 2**28;
} 
printf "28-bit Result = %7x = P_reg[28:1]\n",$full_result;
for ($x=0; $x<11; $x++) {
  $p = ($p>>1);
  if ($p>(2**27)) {
    $p += 2**28;
  } 
}
$p = $p % 16384;
printf "Result/0x800 = %3x\n",$p;


sub from_hex {
  $accum = 0;
  $weight = 1;
  $len = length($_[0]);
  for ($y=$len; $y>0; $y--) {
    $accum=$accum+$weight*&hex_val(substr($_[0],$y-1,1));
    $weight*=16;
  }
  return($accum);
}

sub hex_val {
  if ($_[0]=~/0/) { return(0); }
  elsif ($_[0]=~/1/) { return(1); }
  elsif ($_[0]=~/2/) { return(2); }
  elsif ($_[0]=~/3/) { return(3); }
  elsif ($_[0]=~/4/) { return(4); }
  elsif ($_[0]=~/5/) { return(5); }
  elsif ($_[0]=~/6/) { return(6); }
  elsif ($_[0]=~/7/) { return(7); }
  elsif ($_[0]=~/8/) { return(8); }
  elsif ($_[0]=~/9/) { return(9); }
  elsif ($_[0]=~/a/i) { return(10); }
  elsif ($_[0]=~/b/i) { return(11); }
  elsif ($_[0]=~/c/i) { return(12); }
  elsif ($_[0]=~/d/i) { return(13); }
  elsif ($_[0]=~/e/i) { return(14); }
  elsif ($_[0]=~/f/i) { return(15); }
  else {return(-1);}
}
