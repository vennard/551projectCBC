#!/usr/bin/perl

######################################################################
#############USE AT YOUR OWN RISK#####################################
# the revisions to this code are quick, hasty, and relatively untested
######################################################################

################################################################### 
# This is a simple Perl Program in which the user specifies an    #
# values for amplitude of V and I, and a phase lag for I          #
# Then an analog_vals.txt is generated with 2^16 values for I & V # 
#                                                                 #
###################################################################
open(OUTFILE,">analog_vals.txt") || die "ERROR: Can't open analog_vals.txt for write\n";

print "Enter amplitude of V channel (value from 0 to 2047): ";
$v_amp = <STDIN>;
print "Enter step size of V channel for various sets : ";
$v_step = <STDIN>;
print "Enter amplitude of I channel (value from 0 to 2047): ";
$i_amp = <STDIN>;
print "Enter step size of I channel for various sets : ";
$i_step = <STDIN>;
print "Enter phase lag of I relative to V (value from -179 to +180): ";
$lag = <STDIN>;
$lag = $lag*3.14159265/180;	# convert to radians

$indx = 0;
for ($sets = 0; $sets<16; $sets++) {
  for ($x=0; $x<64; $x++) {
    $angle = $x*2*3.14159265/64;
    $v = $v_amp*sin($angle)+2048;
    $i = $i_amp*sin($angle-$lag)+2048;
    $vhex = sprintf("%x",$v);
    $ihex = sprintf("%x",$i);
    for ($y=length($vhex); $y<3; $y++) { $vhex = '0'.$vhex; }
    for ($y=length($ihex); $y<3; $y++) { $ihex = '0'.$ihex; }
    printf OUTFILE "\@%x %s_%s\n",$indx,$vhex,$ihex;
    $indx++;
  }
  $v_amp += $v_step;
  $i_amp += $i_step;
}

close(OUTFILE);
