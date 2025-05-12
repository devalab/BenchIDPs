#!/bin/bash

gmx pdb2gmx -f 1iyt.pdb -o 1iyt.gro -ignh << EOF
1
1
EOF

gmx editconf -f 1iyt.gro -o 1iyt_box.gro -c -d 1.5 -bt cubic
gmx solvate -cp 1iyt_box.gro -cs a99SBdisp_water.gro -o 1iyt_box_solv.gro -p topol.top
gmx grompp -f ./mdp/ions.mdp -c 1iyt_box_solv.gro -p topol.top -o ions.tpr
gmx genion -s ions.tpr -o 1iyt_box_solv.gro -p topol.top -pname NA -nname CL -neutral << EOF
13
EOF
gmx grompp -f ./mdp/minim.mdp -c 1iyt_box_solv.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em -nt 40
echo Potential | gmx energy -f em.edr -o potential.xvg
gmx grompp -f ./mdp/nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
gmx mdrun -v -deffnm nvt -nt 40
echo Temperature | gmx energy -f nvt.edr -o temperature.xvg
gmx trjconv -s nvt.tpr -f nvt.xtc -o nvt_nopbc.xtc -pbc mol -center << EOF
1
0
EOF
gmx grompp -f ./mdp/npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun -v -deffnm npt -nt 40
echo Pressure | gmx energy -f npt.edr -o pressure.xvg
echo Density | gmx energy -f npt.edr -o density.xvg
gmx trjconv -s npt.tpr -f npt.xtc -o npt_nopbc.xtc -pbc mol -center << EOF
1
0
EOF
gmx grompp -f ./mdp/md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_300K_100ns.tpr
gmx mdrun -v -deffnm md_300K_100ns -nt 40
gmx trjconv -s md_300K_100ns.tpr -f md_300K_100ns.xtc -o md_300K_100ns_nopbc.xtc -pbc mol -center << EOF
1
0
EOF

gmx grompp -f ./mdp/anneal_warm.mdp -c md_300K_100ns.gro -t md_300K_100ns.cpt -p topol.top -o md_anneal_300K_600K.tpr -maxwarn 1
gmx mdrun -v -deffnm md_anneal_300K_600K -nt 40
gmx trjconv -s md_anneal_300K_600K.tpr -f md_anneal_300K_600K.xtc -o md_anneal_300K_600K_nopbc.xtc -pbc mol -center << EOF
1
0
EOF
gmx grompp -f ./mdp/nvt_600.mdp -c md_anneal_300K_600K.gro -t md_anneal_300K_600K.cpt -p topol.top -o nvt_600K_10ns.tpr -maxwarn 1
gmx mdrun -v -deffnm nvt_600K_10ns -nt 40
gmx trjconv -s nvt_600K_10ns.tpr -f nvt_600K_10ns.xtc -o nvt_600K_10ns_nopbc.xtc -pbc mol -center << EOF
1
0
EOF
gmx grompp -f ./mdp/anneal_cool.mdp -c nvt_600K_10ns.gro -t nvt_600K_10ns.cpt -p topol.top -o md_anneal_600K_310K.tpr -maxwarn 1
gmx mdrun -v -deffnm md_anneal_600K_310K -nt 40
gmx trjconv -s md_anneal_600K_310K.tpr -f md_anneal_600K_310K.xtc -o md_anneal_600K_310K.xtc -pbc mol -center << EOF
1
0
EOF
gmx grompp -f ./mdp/npt_310.mdp -c md_anneal_600K_310K.gro -t md_anneal_600K_310K.cpt -p topol.top -o md_npt_310k_a99sb_disp_disp_water.tpr -maxwarn 1
gmx mdrun -v -deffnm md_npt_310k_a99sb_disp_disp_water -nt 40
gmx trjconv -s md_npt_310k_a99sb_disp_disp_water.tpr -f md_npt_310k_a99sb_disp_disp_water.xtc -o md_npt_310k_a99sb_disp_disp_water_nopbc.xtc -pbc mol -center << EOF
1 
0
EOF
gmx grompp -f ./mdp/md_310.mdp -c md_npt_310k_a99sb_disp_disp_water.gro -t md_npt_310k_a99sb_disp_disp_water.cpt -p topol.top -o md_prod_310k_a99sb_disp_disp_water_1.tpr -maxwarn 1
gmx mdrun -v -deffnm md_prod_310k_a99sb_disp_disp_water_1 -nt 40
gmx trjconv -s md_prod_310k_a99sb_disp_disp_water_1.tpr -f md_prod_310k_a99sb_disp_disp_water_1.xtc -o md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -pbc mol -center << EOF
1
0
EOF

mkdir analysis
cd analysis
mkdir RMSD
cd RMSD
gmx rms -s ../../md_prod_310k_a99sb_disp_disp_water_1.tpr -f ../../md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -o rmsd_protein_calpha_a99sb_disp_disp_water.xvg -tu ns << EOF
3
3
EOF

cd ../
mkdir RMSF
cd RMSF
gmx rmsf -s ../../md_prod_310k_a99sb_disp_disp_water_1.tpr -f ../../md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -o rmsf_protein_calpha_a99sb_disp_disp_water.xvg -res << EOF
3
3
EOF

cd ../
mkdir Rg
cd Rg
gmx gyrate -s ../../md_prod_310k_a99sb_disp_disp_water_1.tpr -f ../../md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -o gyrate_protein_md_prod_310k_a99sb_disp_disp_water.xvg << EOF
1
EOF

cd ../
mkdir SASA
cd SASA
gmx sasa -s ../../md_prod_310k_a99sb_disp_disp_water_1.tpr -f ../../md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -o sasa_protein_a99sb_disp_disp_water.xvg -surface Protein

cd ../
mkdir j_coupling
cd j_coupling
gmx chi -s ../../md_prod_310k_a99sb_disp_disp_water_1.tpr -f ../../md_prod_310k_a99sb_disp_disp_water_1_nopbc.xtc -g j_coup_a99sb_disp_disp_water.log -jc j_coup_a99sb_disp_disp_water.xvg -o order_a99sb_disp_disp_water.xvg


echo Finish = `date`
