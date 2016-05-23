#/ANALYSIS3/dir_run_output/run_name/runid(.conf)
#/ANALYSIS3/dir_analysis_result/analysis_name
#FILTER_ARCHIVE_IRF
#template_ID, skyregion_id
#copyresults
#copy a .source with a name analysis_result_sourcename or "all", with a sqrt(TS) >= analysis_result_minSqrtTS and within analysis_result_maxdistance_to_original_position (if < 0, do not apply) or within the error box (if present) with a systematic error of analysis_result_useerrorbox (if < 0, do not apply)

#The config file name has the following configuration
#single (single analysis) - spot6 - analysis_name,dir_analysis_result,analysis_result_minSqrtTS (default 0),analysis_result_sourcename(default all),analysis_result_maxdistance_to_original_position(default -1),analysis_result_useerrorbox(default -1)  (0)
#filter_archive_matrix, template_ID, skyregion_id (1)
#tstart (2)
#tstop (3)
#UTC, MJD, TT, CONTACT (4)
#l (5)
#b (6)
#proj: AIT, ARC (7)
#gal or -1 (8)
#iso or -1 (9)
#OP: map params (10) skytype=X mapsize=Y binsize=Z eb=K1 dq=K2 ulcl loccl
#OP: hypothesisgen_lowpriority = spotfinder | cat | nop params (11)
#OP: hypothesisgen_mediumpriority = spotfinder | cat | nop params (12)
#radius selection merger or 0 (13) 
#OP: multi params (14)
#OP: ts map mode (15) - nop or op (op=execute TS map generator)
#ds9 = default, none, additional parameters (16) - ARC/AIT = cts
#ds9 = default, none, additional parameters (17) - ARC/AIT = int
#ds9 = default, none, additional parameters (18) - ARC/AIT = exp
#ds9 = default, none, additional parameters (19) - ARC = cts2
#reg file name (to be added to ds9 map generation)
#detGIF (21) - the name of the source used to determina gal and iso parameter fixed (use [tstart-7days, tstart]) 
#iddisp - for push notifications (22)
#dir_run_output,queue,load_build_command (23) - dir_run_output = where the files of the run are saved (under (ANALYSSI3)), queue (the queue of the cluster, optional), load_build_command the command to load the environment (e.g. agile-B23-r5, optional)
#email or none (24): the send e-mails with results
#run_name (25) (under dir_run_output): the name of the run. 
#comments or none (26)
#use reg/con section: yes or no (27) or nop/reg/con (27). NB: yes=reg
#----- (28)
#multi list to be analyzed
#-----
#reg/con section
#
#Example
# spotfinder 0 2 10 0.7 1 50 {1}
# NB: l'ultimo parametro e' l'indice del file nel MAP.maplist4 usato per fare la ricerca degli spot.
# Gli altri parametri sono quelli passato direttamente a spotfinder
# cat cat2b_4.multi 15 0 20 0 30 0 0
#NB: copy the catalogs (in .multi format) in ENV["AGILE"] + "/share/catalogs/"
#
#Save results
#The analysis is saved in /ANALYSIS3/dir_run_output/proj_dir_run_output
#A selection of the analysis is saved using dir_analysis_result,analysis_result_minSqrtTS,analysis_result_sourcename --> save results in /ANALYSIS3/dir_analysis_result (save .source) with sqrt(TS) >= analysis_result_minSqrtTS and of a source named 'sourcename' or 'all' (analysis_result_sourcename)
#For cluster: use queue


class Conf
	def initialize
			
	end
	
	attr_accessor :analysis_name
	
	def process(filenameconf, fnhyp0, fndisplayreg)
		@fndisplayreg = fndisplayreg
		@analysis_name = ""
		@filter = ""
		@template_id = nil
		@skyregion_id = nil
		@tstart = ""
		@tstop = ""
		@timetype = ""
		@l = ""
		@b = ""
		@proj = ""
		@galcoeff = ""
		@isocoeff = ""
		@mapparam = ""
		@hypothesisgen1 = ""
		@hypothesisgen2 = ""
		@radmerger = ""
		@multiparam = ""
		@tsmapparam = ""
		@iddisp = ""
		@dir_run_output = ""
		@mail = ""
		@run_name = ""
		@ds91 = "" #default, none, 1 -1 3 B 2
		@ds92 = "" #default, none, 1 -1 3 B 2
		@ds93 = "" #default, none, 1 -1 3 B 2
		@ds94 = "" #default, none, 1 -1 3 B 2
		@regfile = ""
		@detGIF = ""
		@comments = ""
		@reg = "" #yes/no or nop/con/reg
		@binsize = 0.3

		@queue = nil
		@load_build_command = MODULELOAD
		@dir_analysis_result = nil
		@analysis_result_minSqrtTS = 0
		@analysis_result_sourcename = "all"
		@analysis_result_maxdistance_to_original_position = -1
		@analysis_result_useerrorbox = -1
		
		@confregsection = ""
		
		if fnhyp0 != nil
			f = File.new(fnhyp0 , "w")
		else
			f = nil
		end
		
		fr = nil;

		extractmulti = true
		index = 0
		File.open(filenameconf).each_line do | line |
			line = line.chomp
			if index.to_i == 0
				analysis_name_and_dir_analysis_result = line
				@analysis_name = analysis_name_and_dir_analysis_result.split(",")[0]
				if analysis_name_and_dir_analysis_result.split(",").size >= 2
					@dir_analysis_result = analysis_name_and_dir_analysis_result.split(",")[1]
				end
				if analysis_name_and_dir_analysis_result.split(",").size >= 3
					@analysis_result_minSqrtTS = analysis_name_and_dir_analysis_result.split(",")[2]
				end
				if analysis_name_and_dir_analysis_result.split(",").size >= 4
					@analysis_result_sourcename = analysis_name_and_dir_analysis_result.split(",")[3]
				end
				
				if analysis_name_and_dir_analysis_result.split(",").size >= 5	
					@analysis_result_maxdistance_to_original_position = analysis_name_and_dir_analysis_result.split(",")[4]
				end
				
				if analysis_name_and_dir_analysis_result.split(",").size >= 6
					@analysis_result_useerrorbox = analysis_name_and_dir_analysis_result.split(",")[5]
				end
				
			end

			if index.to_i == 1
				filterstart = line
				@filter = filterstart.split(",")[0]
				if filterstart.split(",").size >= 2
					@template_id = filterstart.split(",")[1]
				end
				if filterstart.split(",").size >= 3
					@skyregion_id = filterstart.split(",")[2]
				end
			end
			if index.to_i == 2
				@tstart = line
			end
			if index.to_i == 3
				@tstop = line
			end
			if index.to_i == 4
				@timetype = line
			end
			if index.to_i == 5
				@l = line
			end
			if index.to_i == 6
				@b = line
			end
			if index.to_i == 7
				@proj = line
			end
			if index.to_i == 8
				@galcoeff = line
			end
			if index.to_i == 9
				@isocoeff = line
			end
			if index.to_i == 10
				@mapparam = line
				if @mapparam.split("binsize").size() > 1
					@binsize  = mapparam.split("binsize")[1].split("=")[1].split(" ")[0]
				else
					@binsize = 0.3
				end
			end
			if index.to_i == 11
				@hypothesisgen1 = line
			end
			if index.to_i == 12
				@hypothesisgen2 = line
			end
			if index.to_i == 13
				@radmerger = line
			end
			if index.to_i == 14
				@multiparam = line
			end
			if index.to_i == 15
				@tsmapparam = line
			end
			if index.to_i == 16
				@ds91 = line
			end
			if index.to_i == 17
				@ds92 = line
			end
			if index.to_i == 18
				@ds93 = line
			end
			if index.to_i == 19
				@ds94 = line
			end
			if index.to_i == 20
				@regfile = line
				if @regfile == "none"
					@regfile = ""
				else
					@regfile = PATH_RES + "/regs/" + @regfile
				end
			end
			if index.to_i == 21
				@detGIF = line
			end
			if index.to_i == 22
				@iddisp = line
			end
			if index.to_i == 23
				user_and_queue = line
				@dir_run_output = user_and_queue.split(",")[0]
				if user_and_queue.split(",").size >= 2
					@queue = user_and_queue.split(",")[1]
				end
				if user_and_queue.split(",").size >= 3
					@load_build_command = user_and_queue.split(",")[2]
				end
			end
			if index.to_i == 24
				@mail = line
			end
			if index.to_i == 25
				@run_name =  line
				#if @proj.to_s == "AIT"
				#	@run_name = "AIT_" + @run_name.to_s;
				#end
				#if @proj.to_s == "ARC"
				#	@run_name = "ARC_" + @run_name.to_s
				#end
			end
			if index.to_i == 26
				@comments =  line
			end
			if index.to_i == 27
				@reg =  line
				if @reg == "yes" or @reg == "reg"
					if @fndisplayreg != nil
						@fndisplayreg += ".reg"
					end
				end
				if @reg == "con"
					if @fndisplayreg != nil
						@fndisplayreg += ".con"
					end
				end
				if @fndisplayreg != nil
					fr = File.new(@fndisplayreg , "w")
				else
					fr = nil
				end
			end
			if index.to_i >= 28
				if index.to_i > 28
					if line.to_s == "-----"
						extractmulti = false
						next
					end
			
					if extractmulti == true
						if line.size() > 2
							if f != nil
								f.write(line + "\n")
							end
						end
					else
						if line.size() > 2
							if fr != nil
								fr.write(line + "\n")
							end
						end
					end
				end
			end
			index = index.to_i + 1
		end

		if f != nil
			f.close()
		end
		if fr != nil
			fr.close()
		end

	end
	
	def setArchive()
		out1 = @filter.split(",")[0]
		@filter = out1.split("_")[0] + "_" + ARCHIVE.to_s + "_" + out1.split("_")[2].chomp
	end
	
	def existsFile(filename)
		if filename == nil
			return ""
		end
		if File.exists?(filename)
			return filename
		else
			return ""
		end
	end
	
	def plotjpgmap_arc(map)
		if File.exists?(map)
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + map + " " + map.split(".gz")[0] + " 1 -1 1 B all png 1400x1400 "
			puts cmd
			system(cmd)		
		end	
	end
	
	def plotjpgmap_ait(map)
		if File.exists?(map)
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + map + " " + map.split(".gz")[0] + " 1 -1 1 B 2 png 1400x1000 ";
			puts cmd
			system(cmd)	
		end
	end
	
	def plotjpgcts1(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.cts.gz"].each do | file |
				if @ds91 != "none"
					fname = file.split(".cts.gz")[0]
					if @ds91 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall " + @ds91.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end

	def plotjpgint(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.int.gz"].each do | file |
				if @ds92 != "none"
					fname = file.split(".int.gz")[0]
					if @ds92 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall " + @ds92.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end

	def plotjpgexp(mle)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.exp.gz"].each do | file |
				if @ds93 != "none"
					fname = file.split(".exp.gz")[0]
					if @ds93 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall 1 -1 1 B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall " + @ds93.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end
	
	

	def plotjpgcts2(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.cts.gz"].each do | file |
				if @ds94 != "none"
					fname = file.split(".cts.gz")[0]
					if @ds94 == "default"
						#cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 jpg 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
						#if reg == "yes" or reg == "reg" or reg == "con"
						#	cmd += " "
						#	cmd += existsFile(@fndisplayreg)
						#end
						#puts cmd
						#system(cmd)
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
						if @reg == "yes" or @reg == "reg" or @reg == "con"
							cmd += " "
							cmd += existsFile(@fndisplayreg)
						end
						puts cmd
						system(cmd)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   " + @ds94.to_s +  " png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
						if @reg == "yes" or @reg == "reg" or @reg == "con"
							cmd += " "
							cmd += existsFile(@fndisplayreg)
						end
						puts cmd
						system(cmd)
					end
			
				end
			end
		end
	end
	
	def detsmooth
		@smooth = 3	
		if @binsize.to_f == 0.05
			@smooth = 20;
		end
		if @binsize.to_f == 0.1
			@smooth = 10;
		end
		if @binsize.to_f == 0.2
			@smooth = 5;
		end
		if @binsize.to_f == 0.25
			@smooth = 4;
		end
		if @binsize.to_f == 0.3
			@smooth = 3;
		end
		if @binsize.to_f == 0.5
			@smooth = 3;
		end
	
	end
	
	def copyresults(mle)
	begin
		pathanalysis = PATH_RES + "/" + @dir_analysis_result + "/" + @analysis_name + "/";
		#copy
		system("mkdir -p " + pathanalysis);
		cmd = "cp " + mle + ".conf " + pathanalysis + "/" + @run_name + "_" + mle + ".conf"
		puts cmd
		system cmd
		cmd = "cp " + mle + ".ll " + pathanalysis + "/" + @run_name + "_" + mle + ".ll"
		puts cmd
		system cmd
		cmd = "cp " + mle + ".multi " + pathanalysis + "/" + @run_name + "_" + mle + ".multi"
		puts cmd
		system cmd
		cmd = "cp " + mle + "_MAP.cts2.png " + pathanalysis + "/" + @run_name + "_" + mle + ".cts2.png"
		puts cmd
		system cmd
		cmd = "cp " + mle + "_MAP.ctsall.png " + pathanalysis + "/" + @run_name + "_" + mle + ".ctsall.png"
		puts cmd
		system cmd
		cmd = "cp " + mle + "_MAP.expall.png " + pathanalysis + "/" + @run_name + "_" + mle + ".expall.png"
		puts cmd
		system cmd
		cmd = "cp " + mle + "_MAP.intall.png " + pathanalysis + "/" + @run_name + "_" + mle + ".intall.png"
		puts cmd
		system cmd

		##################### copy sources:
		sourceexpr = ""
		if @analysis_result_sourcename == "all"
			sourceexpr = mle + "_*.source"
		else
			sourceexpr = mle + "_" + @analysis_result_sourcename + ".source"
		end
		
		Dir[sourceexpr].each do | source |
			mo = MultiOutput.new
			mo.readDataSingleSource(source)
			if mo.sqrtTS.to_f >= @analysis_result_minSqrtTS.to_f
				#distance criteria
				#1) peak < analysis_result_maxdistance_to_original_position
				ccp = false
				if @analysis_result_maxdistance_to_original_position.to_f >= 0
					if mo.dist.to_f <= @analysis_result_maxdistance_to_original_position.to_f
						ccp = true;
					end
				end
				if @analysis_result_useerrorbox.to_f >= 0
					du = DataUtils.new
					if du.distance(mo.l, mo.b, mo.startL, mo.startB) <= mo.r.to_f + @analysis_result_useerrorbox.to_f
						ccp = true;
					end
				end
				if @analysis_result_maxdistance_to_original_position.to_f < 0 and @analysis_result_useerrorbox.to_f < 0
					ccp = true
				end
				#2) analysis_result_useerrorbox = original_position is within the error box (if present)
				#copy
				if ccp == true
					sname = source.split("/")
					sname = sname[sname.size-1];
					cmd = "cp " + source + " " + pathanalysis + "/" + @run_name + "_" + sname 
					puts cmd
					system cmd
					cmd = "cp " + source + " " + pathanalysis + "/" + @run_name + "_" + sname + ".reg"
					puts cmd
					system cmd
					cmd = "cp " + source + " " + pathanalysis + "/" + @run_name + "_" + sname + ".con"
					puts cmd
					system cmd
				end
			end
		end
	
	rescue
		puts "error analysis results"
	end
	end
	
	attr_accessor :filter
	
	attr_accessor :template_id
	
	attr_accessor :skyregion_id
	
	def smooth
		@smooth
	end
	
	attr_accessor :tstart
	
	attr_accessor :tstop
	
	attr_accessor :timetype
	
	attr_accessor :l
	
	attr_accessor :b
	
	attr_accessor :proj
		
	def galcoeff
		@galcoeff
	end
	
	def isocoeff
		@isocoeff
	end
	
	def mapparam
		@mapparam
	end
	
	def hypothesisgen1
		@hypothesisgen1
	end
	
	def hypothesisgen2
		@hypothesisgen2
	end
	
	def radmerger
		@radmerger
	end
	
	def multiparam
		@multiparam
	end
	
	def tsmapparam
		@tsmapparam
	end
	
	attr_accessor :iddisp
	
	attr_accessor :dir_run_output
	
	attr_accessor :mail
	
	attr_accessor :run_name
		
	def ds91
		@ds91
	end
	
	def ds92
		@ds92
	end
	
	def ds93
		@ds93
	end
	
	def ds94
		@ds94
	end
	
	def regfile
		@regfile
	end
	
	def detGIF
		@detGIF
	end
	
	def comments
		@comments
	end	
		
	def reg
		@reg
	end
	
	def binsize
		@binsize
	end
	
	attr_accessor :confregsection
	
	attr_accessor :queue
	
	attr_accessor :load_build_command
		
	attr_accessor :dir_analysis_result
	
	attr_accessor :analysis_result_minSqrtTS
		
	attr_accessor :analysis_result_sourcename
	
	attr_accessor :analysis_result_maxdistance_to_original_position
		
	attr_accessor :analysis_result_useerrorbox
	
	def write(filename)
		fout = File.new(filename, "w")
		fout.write(@analysis_name.to_s + "," + @dir_analysis_result.to_s + "," + @analysis_result_minSqrtTS.to_s + "," + @analysis_result_sourcename.to_s + "," + @analysis_result_maxdistance_to_original_position.to_s + "," + analysis_result_useerrorbox.to_s + "\n");
		fout.write(@filter.to_s + "," + @template_id.to_s + "," + @skyregion_id.to_s + "\n")
		fout.write(@tstart.to_s + "\n")		
		fout.write(@tstop.to_s + "\n")	
		fout.write(@timetype.to_s + "\n")
		fout.write(@l.to_s + "\n")
		fout.write(@b.to_s + "\n")
		fout.write(@proj.to_s + "\n")
		fout.write(@galcoeff.to_s + "\n")
		fout.write(@isocoeff.to_s + "\n")
		fout.write(@mapparam.to_s + "\n")
		fout.write(@hypothesisgen1.to_s + "\n")
		fout.write(@hypothesisgen2.to_s + "\n")
		fout.write(@radmerger.to_s + "\n")
		fout.write(@multiparam.to_s + "\n")
		fout.write(@tsmapparam.to_s + "\n")
		fout.write(@ds91.to_s + "\n")
		fout.write(@ds92.to_s + "\n")
		fout.write(@ds93.to_s + "\n")
		fout.write(@ds94.to_s + "\n")
		rname = regfile.split("/")
		fout.write(rname[rname.size()-1].to_s + "\n")
		fout.write(@detGIF.to_s + "\n")
		fout.write(@iddisp.to_s + "\n")
		fout.write(@dir_run_output.to_s + "," + @queue.to_s + "," + @load_build_command.to_s + "\n")
		fout.write(@mail + "\n")
		fout.write(@run_name + "\n")
		fout.write(@comments + "\n")
		fout.write(@reg + "\n")
		fout.write("-----\n")
		fout.write("-----\n")
		fout.write(@confregsection.to_s + "\n")
		fout.close();
	end
end
