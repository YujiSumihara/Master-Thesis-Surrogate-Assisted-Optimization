#IronPython
import os
import datetime

###############################################################################

# Path
CurrentDirectory = os.path.dirname(os.path.abspath(__file__))

################################################################################

ProjectName = "Example";

# Load Parameters
InputFile = open(CurrentDirectory + "/input.txt", "r")

Param = InputFile.readline()
H1 = Param.rstrip(',\n').split(',')
H1 = [float(i) for i in H1]

Param = InputFile.readline()
R1 = Param.rstrip(',\n').split(',')
R1 = [float(i) for i in R1]

Param = InputFile.readline()
X = Param.rstrip(',\n').split(',')
X = [float(i) for i in X]

Param = InputFile.readline()
Y = Param.rstrip(',\n').split(',')
Y = [float(i) for i in Y]

InputFile.close()
################################################################################

# ANSYS: Get current project path at the TEMP folder
ProjectDirectory = GetProjectDirectory()

# Create Output File
OutputFile = open(CurrentDirectory + "/output.txt", "w")

# ANSYS: Read solid parameters
Param_H1 = Parameters.GetParameter(Name="P19")
Param_R1 = Parameters.GetParameter(Name="P20")
Param_X  = Parameters.GetParameter(Name="P21")
Param_Y  = Parameters.GetParameter(Name="P22")

i = 0;
loopMax = len(H1)

while i < loopMax:

	# Simulation Start Time
	time_start = datetime.datetime.now()

	# ANSYS: Update Geometry
	_H1 = H1[i]
	_R1 = R1[i]
	_X = X[i]
	_Y = Y[i]

	DesignPoint = Parameters.GetDesignPoint(Name="0")
	DesignPoint.SetParameterExpression(Parameter=Param_H1, Expression=("%s [mm]" % _H1))
	DesignPoint.SetParameterExpression(Parameter=Param_R1, Expression=("%s [mm]" % _R1))
	DesignPoint.SetParameterExpression(Parameter=Param_X, Expression=("%s [mm]" % _X))
	DesignPoint.SetParameterExpression(Parameter=Param_Y, Expression=("%s [mm]" % _Y))

	# ANSYS: Update (Run Simulations)
	try:
		Update()
	except:
		print("Error: Geometry update failed at simulation #%s" % i)
		i = i + 1
	else:

		# ANSYS: Results

		# Solid
		Volume = Parameters.GetParameter(Name="P5").Value.Value
		Mass = Parameters.GetParameter(Name="P6").Value.Value

		# Total Deformation (mm)
		TotalDeformation_min = Parameters.GetParameter(Name="P18").Value.Value
		TotalDeformation_avg = Parameters.GetParameter(Name="P16").Value.Value
		TotalDeformation_max = Parameters.GetParameter(Name="P17").Value.Value

		# Equivalent Stress (von-Misses) (MPA)
		EquivalentStress_min = Parameters.GetParameter(Name="P15").Value.Value
		EquivalentStress_avg = Parameters.GetParameter(Name="P13").Value.Value
		EquivalentStress_max = Parameters.GetParameter(Name="P14").Value.Value

		# Mesh
		Mesh_elements = Parameters.GetParameter(Name="P12").Value.Value
		Mesh_nodes = Parameters.GetParameter(Name="P11").Value.Value

		# Mesh Metric
		MeshMetric_min = Parameters.GetParameter(Name="P10").Value.Value
		MeshMetric_avg = Parameters.GetParameter(Name="P8").Value.Value
		MeshMetric_max = Parameters.GetParameter(Name="P9").Value.Value
		MeshMetric_std = Parameters.GetParameter(Name="P7").Value.Value

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
		OutputFile.write("%s,%s,%s,%s" % (_H1, _R1, _X, _Y))

		if (i < loopMax):
			OutputFile.write("\n")

# Close
OutputFile.close()