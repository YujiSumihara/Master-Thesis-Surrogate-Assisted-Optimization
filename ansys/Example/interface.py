#IronPython
import os
import datetime
import traceback

###############################################################################

# Path
CurrentDirectory = os.path.dirname(os.path.abspath(__file__))

# Debug Log
DebugPath = CurrentDirectory + "/debug.txt"
DebugFile = open(DebugPath, "a")

def Log(msg):
	DebugFile.write("[%s] %s\n" % (datetime.datetime.now(), msg))
	DebugFile.flush()

Log("============================================================")
Log("Script iniciado")
Log("CurrentDirectory = %s" % CurrentDirectory)

################################################################################

ProjectName = "Example";

# Load Parameters
try:
	Log("Abrindo input.txt")
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

	Log("Input carregado com sucesso")
	Log("Numero de simulacoes = %d" % len(H1))
	Log("H1 = %s" % H1)
	Log("R1 = %s" % R1)
	Log("X  = %s" % X)
	Log("Y  = %s" % Y)

except Exception as e:
	Log("ERRO ao carregar input.txt")
	Log(str(e))
	Log(traceback.format_exc())
	DebugFile.close()
	raise

################################################################################

try:
	# ANSYS: Get current project path at the TEMP folder
	Log("Obtendo ProjectDirectory")
	ProjectDirectory = GetProjectDirectory()
	Log("ProjectDirectory = %s" % ProjectDirectory)

	# Create Output File
	Log("Criando output.txt")
	OutputFile = open(CurrentDirectory + "/output.txt", "w")

	# ANSYS: Read solid parameters
	Log("Lendo parametros de entrada do ANSYS")
	Param_H1 = Parameters.GetParameter(Name="P1")
	Param_R1 = Parameters.GetParameter(Name="P2")
	Param_X  = Parameters.GetParameter(Name="P3")
	Param_Y  = Parameters.GetParameter(Name="P4")
	Log("Parametros de entrada encontrados: P1, P2, P3, P4")

except Exception as e:
	Log("ERRO na inicializacao do projeto/parametros ANSYS")
	Log(str(e))
	Log(traceback.format_exc())
	DebugFile.close()
	raise

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

	Log("------------------------------------------------------------")
	Log("Simulacao %d/%d" % (i+1, loopMax))
	Log("Valores: H1=%s, R1=%s, X=%s, Y=%s" % (_H1, _R1, _X, _Y))

	try:
		Log("Obtendo DesignPoint Name=0")
		DesignPoint = Parameters.GetDesignPoint(Name="0")

		Log("Aplicando parametros no DesignPoint")
		DesignPoint.SetParameterExpression(Parameter=Param_H1, Expression=("%s [mm]" % _H1))
		DesignPoint.SetParameterExpression(Parameter=Param_R1, Expression=("%s [mm]" % _R1))
		DesignPoint.SetParameterExpression(Parameter=Param_X, Expression=("%s [mm]" % _X))
		DesignPoint.SetParameterExpression(Parameter=Param_Y, Expression=("%s [mm]" % _Y))
		Log("Parametros aplicados com sucesso")

	except Exception as e:
		Log("ERRO ao aplicar parametros no DesignPoint")
		Log(str(e))
		Log(traceback.format_exc())
		i = i + 1
		continue

	# ANSYS: Update (Run Simulations)
	try:
		Log("Antes do Update()")
		Update()
		Log("Depois do Update()")
	except Exception as e:
		Log("ERRO durante Update() na simulacao #%s" % (i+1))
		Log(str(e))
		Log(traceback.format_exc())
		print("Error: Geometry update failed at simulation #%s" % i)
		i = i + 1
	else:

		try:
			Log("Lendo resultados do ANSYS")

			# ANSYS: Results

			# Solid
			Volume = Parameters.GetParameter(Name="P5").Value.Value
			Mass = Parameters.GetParameter(Name="P6").Value.Value

			# Total Deformation (mm)
			TotalDeformation_min = Parameters.GetParameter(Name="P16").Value.Value
			TotalDeformation_avg = Parameters.GetParameter(Name="P18").Value.Value
			TotalDeformation_max = Parameters.GetParameter(Name="P17").Value.Value

			# Equivalent Stress (von-Misses) (MPA)
			EquivalentStress_min = Parameters.GetParameter(Name="P13").Value.Value
			EquivalentStress_avg = Parameters.GetParameter(Name="P15").Value.Value
			EquivalentStress_max = Parameters.GetParameter(Name="P14").Value.Value

			# Mesh
			Mesh_elements = Parameters.GetParameter(Name="P8").Value.Value
			Mesh_nodes = Parameters.GetParameter(Name="P7").Value.Value

			# Mesh Metric
			MeshMetric_min = Parameters.GetParameter(Name="P9").Value.Value
			MeshMetric_avg = Parameters.GetParameter(Name="P11").Value.Value
			MeshMetric_max = Parameters.GetParameter(Name="P10").Value.Value
			MeshMetric_std = Parameters.GetParameter(Name="P12").Value.Value

			Log("Resultados lidos com sucesso")

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

			Log("Gravando resultado no output.txt")

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

			OutputFile.flush()
			Log("Resultado gravado com sucesso")

		except Exception as e:
			Log("ERRO ao ler ou gravar resultados na simulacao #%s" % (i+1))
			Log(str(e))
			Log(traceback.format_exc())
			raise

# Close
Log("Fechando output.txt")
OutputFile.close()

Log("Script finalizado")
DebugFile.close()
