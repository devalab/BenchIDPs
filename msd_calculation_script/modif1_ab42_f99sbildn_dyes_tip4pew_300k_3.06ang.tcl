set sys2 [mol new md_300K.gro]
set allwat [atomselect top "name OW"]
set allwatid [$allwat get index]
set out [open "/path_output/uniqID_allwat_ab42_f99sbildn_dyes_tip4pew_nojump_300k_1ps_3.06angs.dat" w]
puts $out "$allwatid"
close $out
mol delete top

   set outfile1 [open "/path_output/input_OxyMx_ab42_f99sbildn_dyes_tip4pew_nojump_300k_1ps_3.06angs.dat" w]
   set outfile2 [open "/path_output/input_OxyMy_ab42_f99sbildn_dyes_tip4pew_nojump_300k_1ps_3.06angs.dat" w]
   set outfile3 [open "/path_output/input_OxyMz_ab42_f99sbildn_dyes_tip4pew_nojump_300k_1ps_3.06angs.dat" w]
   set outfile5 [open "/path_output/uniqID_shell_ab42_f99sbildn_dyes_tip4pew_nojump_300k_1ps_3.06angs.dat" w]

set sys2 [mol new md_300K.gro]
mol addfile md_prod_300k_hfreq_nvt_1ns_nojump.xtc first 0 last 999 waitfor all 
set nf [molinfo top get numframes]

   set all2 [atomselect $sys2 all]
   set selO [atomselect $sys2 "name OW"]

  set tot_wat [$selO num]

  set nframes [molinfo $sys2 get numframes]
  puts "nframes=$nframes"

  for {set i 0} {$i<$nframes} {incr i} {

	molinfo $sys2 set frame $i
	set sel [atomselect top "name OW and (within 3.06 of (all and not water and not ions))"]
	set id_shell [$sel get index]
        set num_shell [$sel num]
	$sel delete

        set Oxyx_pbc ""
        set Oxyy_pbc ""
        set Oxyz_pbc ""

        $all2 update
        $selO update

        set O_x_i [$selO get x]
        set O_y_i [$selO get y]
        set O_z_i [$selO get z]

        set l [llength $O_z_i]

        for {set n 0} {$n < $l} {incr n} {

                set Ox [lindex $O_x_i $n]
                set Oy [lindex $O_y_i $n]
                set Oz [lindex $O_z_i $n]

                lappend Oxyx_pbc $Ox
                lappend Oxyy_pbc $Oy
                lappend Oxyz_pbc $Oz
        }


        puts $outfile1 "$Oxyx_pbc"
        puts $outfile2 "$Oxyy_pbc"
        puts $outfile3 "$Oxyz_pbc"
        puts $outfile5 "$num_shell $id_shell"

        puts "i=$i"
  }

close $outfile1
close $outfile2
close $outfile3
close $outfile5
