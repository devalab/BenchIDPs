
set out [open "/path_output/rgyr_mod.dat" w]
set out2 [open "/path_output/rmsd_mod.dat" w]
set out3 [open "/path_output/sasa_mod.dat" w]
set out4 [open "/path_output/E2E_mod.dat" w]
set out5 [open "/path_output/P_mod.dat" w]

set out6 [open "/path_output/Rg_RMSD_2D.dat" w]
set out7 [open "/path_output/Rg_sasa_2D.dat" w]
set out8 [open "/path_output/Rg_E2E_2D.dat" w]
set out9 [open "/path_output/Rg_P_2D.dat" w]
set out10 [open "/path_output/rmsd_sasa_2D.dat" w]
set out11 [open "/path_output/rmsd_E2E_2D.dat" w]
set out12 [open "/path_output/rmsd_P_2D.dat" w]
set out13 [open "/path_output/sasa_E2E_2D.dat" w]
set out14 [open "/path_output/sasa_P_2D.dat" w]
set out15 [open "/path_output/E2E_P_2D.dat" w]

set out16 [open "/path_output/Rg_rmsd_sasa_3D.dat" w]
set out17 [open "/path_output/Rg_rmsd_E2E_3D.dat" w]
set out18 [open "/path_output/Rg_rmsd_P_3D.dat" w]
set out19 [open "/path_output/rmsd_sasa_E2E_3D.dat" w]
set out20 [open "/path_output/rmsd_sasa_P_3D.dat" w]
set out21 [open "/path_output/sasa_E2E_P_3D.dat" w]
set out22 [open "/path_output/rg_sasa_E2E_3D.dat" w]
set out23 [open "/path_output/rg_sasa_P_3D.dat" w]
set out24 [open "/path_output/rg_E2E_P_3D.dat" w]
set out25 [open "/path_output/rmsd_E2E_P_3D.dat" w]

set selection2 "name CA"
set scale 180.0

set sys [mol new ../1iyt_box_solv.gro] 
## this should be changed with the initial gro file, after minimization and equilibration

##ref Rg
set all [atomselect $sys "all and (not water and not ions)"]
set rg [measure rgyr $all weight mass]
set s1_refbb [atomselect $sys "$selection2"]

##ref SASA
set sasaR [measure sasa 1.8 $all]

## For the secondary structural persistence parameter P, reference Phi, Psi values:
set philist_init [$s1_refbb get phi]
set psilist_init [$s1_refbb get psi]

##ref E2E
set a [atomselect $sys "resid 1"]
set c1 [measure center $a weight mass]
unset a
set a [atomselect $sys "resid 42"]
set c2 [measure center $a weight mass]
unset a
set Er [veclength [vecsub $c1 $c2]]
unset c1 c2 all

puts "finished sys"
## CANNOT DELETE REFERENCE SELECTION for RMSD calculation

## this should be changed with the gro file after either 300 K, or 310 K equilibration simulations
set sys2 [mol new ../npt.gro]

##ref RMSD
set bb1 [atomselect $sys2 "$selection2"]
set mat1 [measure fit $bb1 $s1_refbb]
$bb1 move $mat1
set r1 [measure rmsd $bb1 $s1_refbb]
unset mat1

## For the secondary structural persistence parameter P, after equilibration
set philist_curr [$bb1 get phi]
set psilist_curr [$bb1 get psi]
unset bb1
set sum1 0.0

#here the upper limit should be the total number of residues, case specific:
for {set r 0} {$r < 42} {incr r} {
	## ref Phi, Psi from initial gro file
	set refphi [lindex $philist_init $r]
	set refpsi [lindex $psilist_init $r]

	## current Psi, PSi from gro file after equilibration
	set currphi [lindex $philist_curr $r]
	set currpsi [lindex $psilist_curr $r]

	## calculate ref. P:
	set delphi [expr {$currphi - $refphi}]
	set delpsi [expr {$currpsi - $refpsi}]
	set mphi [expr {$delphi/$scale}]
	set mpsi [expr {$delpsi/$scale}]
	set np [expr {abs($mphi)}]
	set ns [expr {abs($mpsi)}]
	set Pval [expr {(exp(-1*$np))*(exp(-1*$ns))}]
	set sum1 [expr {$sum1 + $Pval}]
	unset refphi currphi refpsi currpsi delphi delpsi mphi mpsi np ns Pval
}
unset philist_curr psilist_curr


# the sum1 here should be divided by the total number of residues, case specific
# this is the ref P value:
set Pref [expr {$sum1/42.0}]
unset sum1

## DELETING INITIAL FRAME SELECTION
mol delete $sys2
puts "finished sys2"

set sys3 [mol new ../npt.gro]
## this should be changed with the xtc file, after either 300 K, or 310 K equilibration simulations
mol addfile ../md_300K_100ns_nopbc.xtc step 2 waitfor all

set nf [molinfo $sys3 get numframes]
set time 0
        for {set f 0} {$f < $nf} {incr f} {
                molinfo $sys3 set frame $f
		## framewise modified Rg
                set a [atomselect $sys3 "all and not water and not ions"]
                set r [measure rgyr $a weight mass]
                set r2 [expr {($r-$rg)/$rg}]
		puts "framewise Rg complete $r2"

		## framewise modified SASA
		set sasa [measure sasa 1.8 $a]
		set sasaM [expr {($sasa-$sasaR)/$sasaR}]
		unset a r sasa
		puts "framewise SASA complete $sasaM"

		## framewise modified E2E
		set a [atomselect $sys3 "resid 1"]
		set c1 [measure center $a weight mass]
		unset a
		set a [atomselect $sys3 "resid 42"]
		set c2 [measure center $a weight mass]
		unset a
		set E2E [veclength [vecsub $c1 $c2]]
		unset c1 c2
		set E2Em [expr {($E2E-$Er)/$Er}]
		unset E2E
		puts "framewise E2E complete $E2Em"

		## framewise modified RMSD
		set b [atomselect $sys3 "$selection2"]
		set mat1 [measure fit $b $s1_refbb]
		$b move $mat1
		set rmsd [measure rmsd $b $s1_refbb]
		set rmsdM [expr {($rmsd-$r1)/$r1}]
		unset mat1 rmsd
		puts "framewise rmsd complete $rmsdM"

		## framewise P value
		set sum1 0.0

		set philist_curr [$b get phi]
		set psilist_curr [$b get psi]

		for {set r 0} {$r < 42} {incr r} {
			## ref Phi, Psi from initial gro file
			set refphi [lindex $philist_init $r]
			set refpsi [lindex $psilist_init $r]
								
			## current Psi, PSi from xtc file after either 300 K or 310 K equilibration simulations
			set currphi [lindex $philist_curr $r]
			set currpsi [lindex $psilist_curr $r]			

			## calculate current framewise  P:
			set delphi [expr {$currphi - $refphi}]
			set delpsi [expr {$currpsi - $refpsi}]
			set mphi [expr {$delphi/$scale}]
			set mpsi [expr {$delpsi/$scale}]
			set np [expr {abs($mphi)}]
			set ns [expr {abs($mpsi)}]
			set Pval [expr {(exp(-1*$np))*(exp(-1*$ns))}]
			set sum1 [expr {$sum1 + $Pval}]
			unset refphi currphi refpsi currpsi delphi delpsi mphi mpsi np ns Pval
		}
			
		# the sum1 here should be divided by the total number of residues, case specific
		# this is the curr P value:
		set Pf [expr {$sum1/42.0}]
		set Pm [expr {($Pf-$Pref)/$Pref}]
		unset b Pf sum1 philist_curr psilist_curr
		puts "framewise P complete $Pm"

                set time [expr {$time + 20}]
                set ts [expr {($time*1.0)/1000.0}]
		## Rg vs time
                puts $out "$ts $r2"

		## rmsd vs time
		puts $out2 "$ts $rmsdM"

		## sasa vs time
		puts $out3 "$ts $sasaM"

		## E2E vs time
		puts $out4 "$ts $E2Em"

		## P vs time
		puts $out5 "$ts $Pm"

		## Rg vs RMSD
		puts $out6 "$r2 $rmsdM"

		## Rg vs SASA
		puts $out7 "$r2 $sasaM"

		## Rg vs E2E
		puts $out8 "$r2 $E2Em"

		## Rg vs P
		puts $out9 "$r2 $Pm"

		## rmsd vs SASA
		puts $out10 "$rmsdM $sasaM"

		## rmsd vs E2E
		puts $out11 "$rmsdM $E2Em"

		## rmsd vs P
		puts $out12 "$rmsdM $Pm"

		## sasa vs E2E
		puts $out13 "$sasaM $E2Em"

		## sasa vs P
		puts $out14 "$sasaM $Pm"

		## E2E vs P
		puts $out15 "$E2Em $Pm"

		## Rg rmsd sasa
		puts $out16 "$r2 $rmsdM $sasaM"

		## Rg rmsd E2E
		puts $out17 "$r2 $rmsdM $E2Em"

		## Rg rmsd P
		puts $out18 "$r2 $rmsdM $Pm"

		## rmsd sasa E2E
		puts $out19 "$rmsdM $sasaM $E2Em"

		## rmsd sasa P
		puts $out20 "$rmsdM $sasaM $Pm"

		## sasa E2E P
		puts $out21 "$sasaM $E2Em $Pm"

		## Rg sasa E2E
		puts $out22 "$r2 $sasaM $E2Em"

		## Rg sasa P
		puts $out23 "$r2 $sasaM $Pm"

		## Rg E2E P
		puts $out24 "$r2 $E2Em $Pm"

		## rmsd E2E P
		puts $out25 "$rmsdM $E2Em $Pm"

		unset ts rmsdM E2Em Pm r2 sasaM

		puts "finished frame $f time $time"
		}

mol delete $sys3
puts "finished sys3"
unset time
close $out

