#IronPython
import os
import datetime

###############################################################################

# Path
CurrentDirectory = os.path.dirname(os.path.abspath(__file__))

################################################################################

ProjectName = "coffee-table";

# Load Parameters
InputFile = open(CurrentDirectory + "/input.txt", "r")

Param = InputFile.readline()
bar1_pos = Param.rstrip(',\n').split(',')
bar1_pos = [float(i) for i in bar1_pos]

Param = InputFile.readline()
bar2_left = Param.rstrip(',\n').split(',')
bar2_left = [float(i) for i in bar2_left]

Param = InputFile.readline()
bar2_right = Param.rstrip(',\n').split(',')
bar2_right = [float(i) for i in bar2_right]

Param = InputFile.readline()
bar1_depth = Param.rstrip(',\n').split(',')
bar1_depth = [float(i) for i in bar1_depth]

Param = InputFile.readline()
bar2_depth = Param.rstrip(',\n').split(',')
bar2_depth = [float(i) for i in bar2_depth]

################################################################################

# ANSYS: Get current project path at the TEMP folder
ProjectDirectory = GetProjectDirectory()

# Create Output File
OutputFile = open(CurrentDirectory + "/output.txt", "w")

# ANSYS: Read solid parameters
Param_bar1_pos     = Parameters.GetParameter(Name="P1")
Param_bar2_left   = Parameters.GetParameter(Name="P3")
Param_bar2_right = Parameters.GetParameter(Name="P2")
Param_bar1_depth   = Parameters.GetParameter(Name="P4")
Param_bar2_depth   = Parameters.GetParameter(Name="P5")

i = 0;
loopMax = len(bar1_pos)

while i < loopMax:

	# Simulation Start Time
	time_start = datetime.datetime.now()

	# ANSYS: Update Geometry
	_bar1_pos     = bar1_pos[i]
	_bar2_left   = bar2_left[i]
	_bar2_right = bar2_right[i]
	_bar1_depth   = bar1_depth[i]
	_bar2_depth   = bar2_depth[i]

	DesignPoint = Parameters.GetDesignPoint(Name="0")
	DesignPoint.SetParameterExpression(Parameter=Param_bar1_pos, Expression=("%s [mm]" % _bar1_pos))
	DesignPoint.SetParameterExpression(Parameter=Param_bar2_left, Expression=("%s [mm]" % _bar2_left))
	DesignPoint.SetParameterExpression(Parameter=Param_bar2_right, Expression=("%s [mm]" % _bar2_right))
	DesignPoint.SetParameterExpression(Parameter=Param_bar1_depth, Expression=("%s [mm]" % _bar1_depth))
	DesignPoint.SetParameterExpression(Parameter=Param_bar2_depth, Expression=("%s [mm]" % _bar2_depth))

	# ANSYS: Update (Run Simulations)
	try:
		Update()
	except:
		print("Error: Geometry update failed at simulation #%s" % i)
		i = i + 1
	else:

		# ANSYS: Results

		# Solid
		Volume = Parameters.GetParameter(Name="P12").Value.Value
		Mass = Parameters.GetParameter(Name="P13").Value.Value

		# Total Deformation (mm)
		TotalDeformation_min = Parameters.GetParameter(Name="P6").Value.Value
		TotalDeformation_avg = Parameters.GetParameter(Name="P8").Value.Value
		TotalDeformation_max = Parameters.GetParameter(Name="P7").Value.Value

		# Equivalent Stress (von-Misses) (MPA)
		EquivalentStress_min = Parameters.GetParameter(Name="P9").Value.Value
		EquivalentStress_avg = Parameters.GetParameter(Name="P11").Value.Value
		EquivalentStress_max = Parameters.GetParameter(Name="P10").Value.Value

		# Mesh
		Mesh_elements = Parameters.GetParameter(Name="P15").Value.Value
		Mesh_nodes = Parameters.GetParameter(Name="P14").Value.Value

		# Mesh Metric
		MeshMetric_min = Parameters.GetParameter(Name="P16").Value.Value
		MeshMetric_avg = Parameters.GetParameter(Name="P18").Value.Value
		MeshMetric_max = Parameters.GetParameter(Name="P17").Value.Value
		MeshMetric_std = Parameters.GetParameter(Name="P19").Value.Value

		## Read Logs
		#NumberEquations = "0.0"
		#ComputationalRate = "0.0"
		#MemoryUsed = "0.0"
		#MemoryAllocated = "0.0"
		
		#with open(ProjectDirectory + "/" + ProjectName + "_files/dp0/SYS-1/MECH/solve.out", "r") as f: 
		#	for line in f: 
		#		if line[0:24] == "   NUMBER OF EQUATIONS =":
		#			NumberEquations = line[24:].strip()
		#		if line[0:51] == "Equation solver computational rate                :":
		#			ComputationalRate = line[51:].strip()
		#		if line[0:51] == "Maximum total memory used                         :":
		#			MemoryUsed = line[51:].strip()
		#		if line[0:51] == "Maximum total memory allocated                    :":
		#			MemoryAllocated = line[51:].strip()

		# Simulation End Time
		time_end = datetime.datetime.now()
		time_elapsed = time_end - time_start

		i = i + 1

		# Save output
		OutputFile.write("%s," % (i))

		# Mesh
		OutputFile.write("%s,%s," % (Mesh_elements, Mesh_nodes))

		# Mesh Metric
		OutputFile.write("%s,%s,%s,%s," % (MeshMetric_min, MeshMetric_avg, MeshMetric_max, MeshMetric_std))

		# Solver
		#OutputFile.write("%s,%s,%s,%s," % (MemoryUsed[:-3], MemoryAllocated[:-3], ComputationalRate[:-7], NumberEquations))

		# Time
		OutputFile.write("%s.%s," % (time_elapsed.seconds, time_elapsed.microseconds))

		# Deformation: TOTAL
		OutputFile.write("%s,%s,%s," % (TotalDeformation_min, TotalDeformation_avg, TotalDeformation_max))

		# Stress: Von Mises
		OutputFile.write("%s,%s,%s," % (EquivalentStress_min, EquivalentStress_avg, EquivalentStress_max))

		# Solid
		OutputFile.write("%s,%s," % (Mass, Volume))

		# Parameters
		OutputFile.write("%s,%s,%s,%s,%s" % (_bar1_pos, _bar2_left, _bar2_right, _bar1_depth, _bar2_depth))

		if (i < loopMax):
			OutputFile.write("\n")

# Close
OutputFile.close()