#-------------------------------------------------------------------------------
# This script is designed to run the simulation
#-------------------------------------------------------------------------------
# 1. Import modules and packages.
from pylmgc90.chipy import *
#-------------------------------------------------------------------------------
# 2. Check if the working directories exist.
checkDirectories()
#-------------------------------------------------------------------------------
# 3. Set the space dimension.
SetDimension(2)
#-------------------------------------------------------------------------------
# 4. Set the simulation parameters.
# System parameter
sigma_0 = 10000.
# Control parameters
dt = 1.e-2 # Time step
nb_steps = 2000 # Number of time steps
theta = 0.5 # Theta coefficient in the movement integration
freq_detect = 1 # Frequency of contact detection
# Parameters for the non-linear Gauss-Seidel solver
type = 'Stored_Delassus_Loops         ' # Type of solver
norm = 'QM/16' # Type of norm
tol = 0.1666e-3 # Convergence tolerance demanded
relax = 1. # Relaxation parameter
gs_it1 = 50 # Minimal number of iterations
gs_it2 = 1000 # Multiplier for the maximal number of iterations
nlgs_SetWithQuickScramble() # Scramble the contact list
#-------------------------------------------------------------------------------
# 5. Set the visualization and output writing parameters.
freq_display = 10 # Visualization frequency
freq_outFiles = 10 # Frequency for writing the output files
ref_radius = 1. # Reference radius for drawing the contact and force networks
#-------------------------------------------------------------------------------
# 6. Read the imput files, and load behaviors and interaction laws to be used in
# the simulation.
utilities_logMes('READ BODIES')
ReadBodies()
utilities_logMes('READ BEHAVIOURS')
ReadBehaviours()
utilities_logMes('LOAD BEHAVIOURS')
LoadBehaviours()
utilities_logMes('READ INI DOF')
ReadIniDof()
utilities_logMes('READ DRIVEN DOF')
ReadDrivenDof()
utilities_logMes('LOAD TACTORS')
LoadTactors()
utilities_logMes('READ INI Vloc Rloc')
ReadIniVlocRloc()
#-------------------------------------------------------------------------------
# 7. For verification purposes, write the files containing the bodies,
# behaviors, and driven degrees of freedom.
utilities_logMes('WRITE BODIES')
WriteBodies()
utilities_logMes('WRITE BEHAVIOURS')
WriteBehaviours()
utilities_logMes('WRITE DRIVEN DOF')
WriteDrivenDof()
#-------------------------------------------------------------------------------
# 8. Initialize time and set the movement integrator parameters.
utilities_logMes('INIT TIME STEPPING')
TimeEvolution_SetTimeStep(dt)
Integrator_InitTheta(theta)
#-------------------------------------------------------------------------------
# 9. Compute the particles' masses.
ComputeMass()
#-------------------------------------------------------------------------------
# 10. Open display and postprocessing files.
OpenDisplayFiles()
#OpenPostproFiles()
#-------------------------------------------------------------------------------
# 11. Solve the system (i.e., find particles' positions and contact forces)
# throug time, and write display and postprocessing files
#
nb_rbdy2 = RBDY2_GetNbRBDY2()          # total number of bodies
#
for k in xrange(1, nb_steps, 1):
   IncrementStep()
   ComputeFext()
   ## We need to compute the size of the box in order to apply the stress
   #1. Bodies Number
   Num_wall_right = nb_rbdy2
   Num_wall_left  = nb_rbdy2 - 1
   Num_wall_up    = nb_rbdy2 - 2
   Num_wall_down  = nb_rbdy2 - 3
   #2. Horizontal lengths of the box
   vector1 = RBDY2_GetBodyVector("Coor_", Num_wall_right)
   vector2 = RBDY2_GetBodyVector("Coor_", Num_wall_left)
   Length_x = abs(vector2[0] - vector1[0])
   #3. Vertical lengths of the box
   vector1 = RBDY2_GetBodyVector("Coor_", Num_wall_down)
   vector2 = RBDY2_GetBodyVector("Coor_", Num_wall_up)
   Length_y = abs(vector2[1] - vector1[1])
   #4. Application of the force the Up wall
   Fwall = sigma_0*Length_x
   RBDY2_PutBodyVector("Fext_", Num_wall_up, [0,-Fwall,0])
   #4. Application of the force the Right wall
   Fwall = sigma_0*Length_y
   RBDY2_PutBodyVector("Fext_", Num_wall_right, [-Fwall,0,0])
   #. END of this procedure.
   ##
   ComputeBulk()
   ComputeFreeVelocity()
   SelectProxTactors(freq_detect)
   RecupRloc()
   nlgs_ExSolver(type,norm,tol,relax,gs_it1,gs_it2)
   StockRloc()
   ComputeDof()
   UpdateStep()
   WriteOutDof(freq_outFiles)
   WriteOutVlocRloc(freq_outFiles)
   WriteDisplayFiles(freq_display,ref_radius)
#   WritePostproFiles()
#-------------------------------------------------------------------------------
# 12. Close display and postprocessing files.
CloseDisplayFiles()
#ClosePostproFiles()
#-------------------------------------------------------------------------------
