#!/usr/bin/perl

######################################################################
#############USE AT YOUR OWN RISK#####################################
# the revisions to this code are quick, hasty, and relatively untested
######################################################################

################################################################### 
# This is a simple Perl Program which reads the eep_init.txt file #
# to get Xset and PID coefficients.  Then it read accel_vals.txt  #
# to get raw accelerometer readings.                              #
#                                                                 #
# Then it calculates the duty cycle value that should be written  #
# to the PWM peripheral                                           #
#                                                                 #
# This program should be run in the directory where:              #
# eep_init.txt & accel_vals.txt exist                             #
###################################################################
open(INFILE1,"eep_init.txt") || die "ERROR: Can't open eep_init in current directory\n";
open(INFILE2,"accel_vals.txt") || die "ERROR: Can't open accel_vals.txt in current directory\n";

$not_found=4;
while (<INFILE1>) {
  chop($_);
  @words=split(/\s+/,$_);
  if ($words[0]=~/^\@0/) { $Xset = &from_hex($words[1]); $not_found--; };
  if ($words[0]=~/^\@1/) { 
    $Pterm = &from_hex($words[1]);
    $not_found--;;
    if ($Pterm>8191) {
      print "ERROR: Pterm value should always be positive, negative makes no sense\n"; 
      exit(1);
    }
  }
  if ($words[0]=~/^\@2/) { 
    $Iterm = &from_hex($words[1]);
    $not_found--;
    if ($Iterm>8191) {
      printf "ERROR: Iterm value should always be positive, negative makes no sense\n";
      exit(1);
    }
  }
  if ($words[0]=~/^\@3/) {
    $Dterm = &from_hex($words[1]);
    $not_found--;
    if ($Dterm>1) {
      print "WARNING: Dterm is typically a small negative number or zero\n";
    }
  }
}
close(INFILE);
if ($not_found) {
  print "ERROR: I need to find four entries in eep_init.txt\n";
  exit(1);
}

if ($Xset>8191) { $Xset = $Xset - 16384; }   # from_hex routine is for unsigned, so have to convert
if ($Dterm>8191) { $Dterm = $Dterm - 16384; }  # from_hex routine is for unsigned, so have to convert
printf "Xset value = %d\n\n",$Xset;
printf "Pterm value as decimal = %f\n\n",$Pterm/2048;
printf "Iterm value as decimal = %f\n\n",$Iterm/2048;
printf "Dterm value as decimal = %f\n\n",$Dterm/2048;
# JOHN ADDED -- -- -- -- -- -- -- -- -- -- -- --
print "\nPlease enter the prev_err value : ";
$m1 = <STDIN>;
print "\nPlease enter the sum_err value : ";
$m2 = <STDIN>;
open outfile, ">", "check_math_out.txt" or die $!;

$indx=0;
while (<INFILE2>) {
  chop($_);
  @words=split(/\s+/,$_);
  $accel[$indx]=&from_hex($words[1]);
  if ($accel[$indx]>8191) {
      $accel[$indx] = $accel[$indx] - 16384;
  }
  $indx++;
}
close(INFILE2);

$num_indx = $indx;
$prev_err = $m1;
$sumErr = $m2;
for ($indx=0; $indx<$num_indx; $indx++) {
  print "------------------------------------\n";
  $err = $accel[$indx] - $Xset;
  $err = &saturate($err);
  printf("Error term as integer is %d\n",$err);
  $working = ($Pterm*$err)/2048.0;
  $duty = &digital_trunc($working);
  printf("Result of multiply of err term by Pterm is %4x\n",$duty);
  $sumErr = $sumErr + $err;
  $sumErr = &saturate($sumErr);
  printf("sumErr register contains %4x after this iteration\n",$sumErr);
  $working = ($Iterm*$sumErr)/2048.0;
  $temp = &digital_trunc($working);
  printf("Result of multiply of sumErr by Iterm is %4x\n",$temp);
  $duty = $duty + $temp;  # add Pterm result with Iterm result
  $duty = &saturate($duty);
  $derr = $err - $prev_err;		# Calculate differential error term
  $working = ($Dterm*$derr)/2048.0;
  $temp = &digital_trunc($working);
  printf("Result of multiply of differential err term by Dterm is %4x\n",$temp);
  $duty = $duty + $temp;
  $duty = &saturate($duty);
  printf("Value written to PWM is %4x\n",$duty);
  ################ JOHN ADDED
  &format_duty($duty);
  # print outfile $dutyout, "\n" ; 
  $prev_err = $err;
}

# ADDED ending -> print out sum_err
if($indx==$num_indx) {
  printf " sum_err is %d\n ",$sumErr ;
  printf " prev_err at the end is %d\n ",$prev_err;
  close outfile;
}

#ADDED function - formats duty to be 16 bits before turning to hex for output
sub format_duty {
   $tmp = uc(sprintf("%x",$_[0]));
	if($duty>=0) { 
		 $tmp = sprintf("%04s",$tmp);
		 print outfile $tmp, "\n";  
		}
	else {
	  my $h0 = chop($tmp);
	  my $h1 = chop($tmp);
	  my $h2 = chop($tmp);
	  my $h3 = chop($tmp);
	  print outfile ($h3,$h2,$h1,$h0,"\n");
	  #$tmp = sprintf("%.4s",$tmp);
	}
	return ($tmp);
}

sub saturate {
  if ($_[0]>8191) { print "  Pos Saturation occurred\n";  return(8191); }
  if ($_[0]<-8192) { print "  Neg Saturation occurred\n";  return(-8192); }
  else { return ($_[0]); }
}

sub digital_trunc {
  if ($_[0]<0) {
    $temp = -$_[0];
    $temp = int($temp+0.99);
    return(-$temp);
  }
  else { return(int($_[0])); }
}

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
