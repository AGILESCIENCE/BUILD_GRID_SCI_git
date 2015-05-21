


class AlikeUtils
		def initialize
			
		end
		
		def rewriteMultiInputWithNewCoordinatesSource(multifileinput, multifileoutput, sourcename, l, b)
			fout = File.new(multifileoutput, "w")
			File.open(multifileinput).each_line do | line |
				ll = line.split(" ")
				if ll[6].to_s == sourcename.to_s
					#modifica la riga
					fout.write(ll[0].to_s + " " + l.to_s + " " + b.to_s + " " + ll[3].to_s + " " + ll[4].to_s + " " + ll[5].to_s + " " + ll[6].to_s)
					if ll.size == 8
						fout.write(" " + ll[7].to_s + "\n")
					else
						fout.write("\n")
					end
				else
					#riporta fuori la stessa riga
					fout.write(line)
				end
			end
			fout.close()
		end
		
		def rewriteMultiInputWithSingleSourceToAnalyze(multifileinput, multifileoutput, sourcename, fixflag)
			fout = File.new(multifileoutput, "w")
			File.open(multifileinput).each_line do | line |
				ll = line.split(" ")
				fixflagw  = "0"
				if ll[6].to_s == sourcename.to_s
					fixflagw = fixflag
				end
				fout.write(ll[0].to_s + " " + ll[1].to_s + " " + ll[2].to_s + " " + ll[3].to_s + " " + fixflagw.to_s + " " + ll[5].to_s + " " + ll[6].to_s)
				if ll.size == 8
					fout.write(" " + ll[7].to_s + "\n")
				else
					fout.write("\n")
				end
				
			end
			fout.close()
		end
		
		def rewriteMaplist(oldmaplist, newmaplist, galcoeff, isocoeff)
			ffmaps = File.new(newmaplist, "w");
			indexmaps = 0
			#eventualmente aggiorno il .maplist4 con p.galcoeff e p.isocoeff
			File.open(oldmaplist).each_line do | line |
				ll = line.split(" ")
				outline = ll[0].to_s + " " + ll[1].to_s + " " + ll[2].to_s + " " + ll[3].to_s + " " + galcoeff.to_s.split(",")[indexmaps.to_i].to_s + " " + isocoeff.to_s.split(",")[indexmaps.to_i].to_s + "\n"
				indexmaps = indexmaps.to_i + 1
				ffmaps.write(outline)
			end
			ffmaps.close()
		end

		#da una alike list seleziona solo quelle sorgenti che superano una soglia predefinita
		#fileoutprefix è il prefisso da dare ai file di output
		#listsourceout deve finire con .list
		#minsqrtts è il valore minimo di sqrt(TS) con cui una sorgente passa il filtraggio
		#l'output è un file con .filtered.list in formato alike list
		def filterAlikeListWithSingle(fileoutprefix, listsourceout, minsqrtts, filter, cts, exp, gas, spectralindex, emin, emax, ranal, gascoeff, iso) 
			############# inizio filtering con alike singola
			cmd = "rm " + fileoutprefix.to_s + ".?????.fixed"
			puts cmd
			system(cmd);
			
			#1) step 1 - single alike for selection of starting list
			index = 0;
			outfilelist = [];
			listsource1 = listsourceout;
			File.open(listsource1).each_line do |line|
				if line[0] != "#"
					k =line.split(" ");
					if k.size() > 1
						name = k[0];
						l = k[5].to_f
						b = k[6].to_f
						outfile = fileoutprefix + "." + format("%05d", name.to_s) + ".fixed";
						cmd = "ruby " + ENV["AGILE"] + "/scripts/makeALIKESINGLEfixed.rb " + filter.to_s + " " + cts.to_s + " " + exp.to_s + " " + gas.to_s + " " + spectralindex.to_s + " " + l.to_s + " " + b.to_s + " " + emin.to_s + " " + emax.to_s + " "  + ranal.to_s + " " + outfile + " " + gascoeff.to_s + " " + iso.to_s ;
						puts cmd;
						system(cmd);
						outfilelist = outfilelist + [outfile];
					end
				end
			end
			
			datautils = DataUtils.new
			
			aaa = Dir[fileoutprefix.to_s + ".?????.fixed"]
			aaa.sort!

			listsource2 = listsourceout.split(".list")[0] + ".filtered2.list"
			
			f2 = File.new(listsource2, "w");

			aaa.each do | filef |
				l1 = filef.split(".")[filef.split(".").size()-2];
				datautils.extractALIKEFIXED_SQRTS(filef);
				datautils.extractALIKEFIXED_FLUX(filef);
				if(datautils.sqrts.to_f >= minsqrtts.to_f && datautils.flux.to_f > 0.0)
					datautils.extractALIKEFIXED_LINE(filef);
					ll2 = datautils.alikesingle_line
					ll=ll2.chomp.to_s + " @ " + format("%.12f", datautils.flux.to_f) + " " + l1.to_s + "\n";
					f2.write(ll);	
				end
			end
	
			f2.close();

			listsource3 = listsourceout.split(".list")[0] + ".filtered3.list"

			cmd = "sort -r -n --key=13 " + listsource2.to_s + " > " + listsource3.to_s
			puts cmd
			system(cmd);

			listsource4 = listsourceout.split(".list")[0] + ".filtered4.list"

			f4 = File.new(listsource4, "w");

			File.open(listsource3).each_line do | line |
				
				name2 = line.split("@")[1].split(" ")[1]
				flux = line.split("@")[0].split(" ")[8]
				l1 = 0
				b1 = 0
				File.open(listsource1).each_line do |line|
					if line[0] != "#"
						k =line.split(" ");
						if k.size() > 1
							name = k[0];
							l = k[5].to_f
							b = k[6].to_f
							if name.to_i == name2.to_i
								l1 = l;
								b1 = b;
							end			
						end
					end
				end
				outline = name2.to_i.to_s + " 0+/-0 1 1 1 " + l1.to_s + " " + b1.to_s +  " 1 1 " + flux.to_s + " 0\n"
				f4.write(outline);
			end

			f4.close();

			listsourceend = listsourceout.split(".list")[0] + ".filtered.list"

			cmd = "mv " + listsource4.to_s + " " + listsourceend.to_s
			puts cmd
			system(cmd)

		
			#riscrittura nel formato list
			

			###########fine filtering con alike singola
		end




		
		#list
		#225 0+/-0 1 1 1 346.20 5.19 1 1 1.592e-06 0   
		#multi
		#352.9e-8  195.06  4.31 1.66  2   3.0   Geminga 
		#questa si può usare dopo aver eseguito il filtraggio con alike singola
		def convertListToMulti(filelist, fileout, minsqrtts, spectralindex, antype, binsize) 
			out = File.new(fileout, "w");
			File.open(filelist).each_line do |line|
# 				puts "a " + line.to_s
				l = line.split(" ");
				if l.size() <= 3
					next
				end
				outline = l[9].to_s + " " + (l[5].to_f + binsize.to_f).to_s + " " + (l[6].to_f - binsize.to_f).to_s + " " + spectralindex.to_s + " " + antype.to_s + " " + minsqrtts.to_s + " " + l[0].to_s + "\n";
				out.write(outline);
# 				puts "# " + outline.to_s
			end
			out.close()
		end

		#Aggiunge ad una lista per AG_multi (primo file) un'altra lista multi (secondo file). Le sorgenti della seconda lista sono sempre tenute, quelle della prima lista sono rimosse se troppo vicino (<= radiusremove) rispetto a quelle della seconda.
		#Le sorgenti della seconda lista sono messe in cima alla lista
		#E' quindi la seconda lista che ha la precedenza
		def appendMulti(fileinputmulti, fileinputappend, fileoutput, radiousremove)
				list = [];
				listinsert = [];
				index = 0;
				File.open(fileinputmulti).each_line do |line|
					list += [line];
					listinsert += [1];
					index = index + 1;
				end
				puts "NUMBER OF SOURCE FOUND " + index.to_s;
				
				list_fixed = [];
				listinsert_fixed = [];
				index_fixed = 0;
				File.open(fileinputappend).each_line do |line|
					list_fixed += [line];
					listinsert_fixed += [1];
					index_fixed = index_fixed + 1;
				end
				puts "NUMBER OF SOURCE FIXED " + index_fixed.to_s;
				indexk = 0;
				list.each do | sourcel |
					puts sourcel
					list_fixed.each do | sourcef |
						puts sourcef;
						sl = sourcel.split(" ");
						ll = sl[1];
						bl = sl[2];
						if (ll.to_f > 180)
							ll = -(360 - ll.to_f);
						end
						
						sf = sourcef.split(" ");
						lf = sf[1];
						bf = sf[2];
						if(lf.to_f > 180)
							lf = -(360 - lf.to_f )
						end
						d1 = bl.to_f - bf.to_f
						d2 = ll.to_f - lf.to_f;
						d3 = Math.sqrt(d1.to_f*d1.to_f + d2.to_f * d2.to_f);
			
						if d3.to_f < radiousremove.to_f
							#remove the source from list of spot finder
							listinsert[indexk] = 0;
						end
					end
					indexk = indexk + 1
				end
				#e ora costruisci la lista finale mettendo prima quelle fixed, poi le restanti di spot finder
				afo = File.new(fileoutput, "w")
				
				indexl = 0
				list_fixed.each do | sourcef |
					afo.write(sourcef);
				end
				list.each do | sourcel |
					if listinsert[indexl] == 1
						afo.write(sourcel);
					end
					indexl = indexl + 1;
				end
				
				afo.close();
		end

		#Aggiunge ad una lista per AG_srclist (primo file) un'altra lista AG_srclist (secondo file). Le sorgenti della seconda lista sono sempre tenute, quelle della prima lista sono rimosse se troppo vicino (<= radiusremove) rispetto a quelle della seconda.
		#Le sorgenti della seconda lista sono messe in cima alla lista
		#E' quindi la seconda lista che ha la precedenza
		def appendList(fileinputbase, fileinputappend, fileoutput, radiousremove)
				
	
				list = [];
				listinsert = [];
				index = 0;
				File.open(fileinputbase).each_line do |line|
					list += [line];
					listinsert += [1];
					index = index + 1;
				end
				puts "NUMBER OF SOURCE FOUND " + index.to_s;
				
				list_fixed = [];
				listinsert_fixed = [];
				index_fixed = 0;
				File.open(fileinputappend).each_line do |line|
					list_fixed += [line];
					listinsert_fixed += [1];
					index_fixed = index_fixed + 1;
				end
				puts "NUMBER OF SOURCE FIXED " + index_fixed.to_s;
				indexk = 0;
				list.each do | sourcel |
					puts sourcel
					list_fixed.each do | sourcef |
						puts sourcef;
						sl = sourcel.split(" ");
						ll = sl[5];
						bl = sl[6];
						if (ll.to_f > 180)
							ll = -(360 - ll.to_f);
						end
						
						sf = sourcef.split(" ");
						lf = sf[5];
						bf = sf[6];
						if(lf.to_f > 180)
							lf = -(360 - lf.to_f )
						end
						d1 = bl.to_f - bf.to_f
						d2 = ll.to_f - lf.to_f;
						d3 = Math.sqrt(d1.to_f*d1.to_f + d2.to_f * d2.to_f);
			
						if d3.to_f < radiousremove.to_f
							#remove the source from list of spot finder
							listinsert[indexk] = 0;
						end
					end
					indexk = indexk + 1
				end
				#e ora costruisci la lista finale mettendo prima quelle fixed, poi le restanti di spot finder
				afo = File.new(fileoutput, "w")
				
				indexl = 0
				list_fixed.each do | sourcef |
					afo.write(sourcef);
				end
				list.each do | sourcel |
					if listinsert[indexl] == 1
						afo.write(sourcel);
					end
					indexl = indexl + 1;
				end
				
				afo.close();
		end

		def addDistanceToList(filename, l, b) 
			datautil = DataUtils.new;
			index = 0;
			outl = [];
			File.open(filename).each_line do | line |
				if line.split("'").size() >= 2
					outl = outl + [line];
					index = index + 1
					next
				end
				if index.to_i >= 2
					l1 = line.split(" ")[0];
					b1 = line.split(" ")[1];
					dist = datautil.distance(l, b, l1, b1)
					outline = line.chomp + " " + format("%.2f\n", dist);
					outl = outl + [outline];
				else
					outl = outl + [line];
				end
				index = index + 1
			end
			af = File.new(filename, "w")
			outl.each do |line|
				af.write(line);
			end
			af.close();
		end

		def addDistanceToMulti(filename, l, b) 
			datautil = DataUtils.new;
			index = 0;
			outl = [];
			outline = ""
			index = 0
			File.open(filename).each_line do | line |
				if index.to_i < 3
					outl = outl + [line];
					index = index + 1
					next
				end
				if line.split("!").size() >= 2
					outl = outl + [line];
					next
				end
				if line.split("'").size() >= 2
					outl = outl + [line];
					next
				end

				llsize = line.size();	
				lll = line.split(" ")
				l1 = lll[2];
				b1 = lll[3];
				dist = datautil.distance(l, b, l1, b1)
				lout = lll[0].to_s + "\t" + lll[1].to_s + "\t" + l1.to_s + "\t" + b1.to_s + "\t" + lll[4].to_s + "\t" + lll[5].to_s + "\t" + lll[6].to_s + "\t" + lll[7].to_s
				outline = lout.chomp + " " + format("%.2f\n", dist);
				outl = outl + [outline];
				puts outline;
				index = index + 1
			end
			llsize = outline.split(" ").size;
			
			if llsize.to_i == 9
				af = File.new(filename, "w")
				outl.each do |line|
					af.write(line);
				end
				af.close();
			end
		end

		def convertMultiResToMulti(filenameinput, filenameoutput, antype, minsqrtTS, cutsqrtts, maxoffaxis, radioussearch) 
			datautil = DataUtils.new;
			multioutput = MultiOutput.new
			index = 0;
			outl = [];
			modefile = 3
			File.open(filenameinput).each_line do | line |
			
				if line.split("!").size() >= 2
					next
				end
				if line.split("'").size() >= 2
					next
				end
				fs = line.split("Galactic")
				if fs.size == 2
					modefile = 4
					next
				end
				fs = line.split("Isotropic")
				if fs.size == 2
					modefile = 4
					next
				end
				fs = line.split(" ")
				if fs.size == 4
					next
				end
				
				

				la1 = line.split(" ");
				offaxis = -1
				if la1.size == 9
					offaxis = la1[8].chomp
					puts offaxis
				end
				if offaxis.to_f != -1.0
					if offaxis.to_f > maxoffaxis.to_f
						index = index + 1
						next
					end
				end
				ll1 = line.split(" ")
				if(ll1.size() < 3)
					next
				end
				l1 = ll1[2].chomp;
				b1 = ll1[3].chomp;
				flux = ll1[6].chomp;
				name = ll1[0].chomp;
				sqrtts = ll1[1].chomp;
				spectralindex = nil
				if ll1[8] != nil
					spectralindex = ll1[8].chomp;
				end
				#puts spectralindex
				if spectralindex == nil || spectralindex.to_i == 0
					#puts filenameinput.to_s + "_" + ll1[0].to_s
					multioutput.readDataSingleSource(filenameinput.to_s + "_" + ll1[0].to_s)
					spectralindex = multioutput.si
				end
				
				if sqrtts.to_f >= cutsqrtts.to_f || name[0] == "_" || name[0] == 49
					
					if flux.to_s == "Inf" || flux.to_f < 0
						index = index + 1
						next
					end
					if radioussearch.to_f == 0
						radioussearch = ""
					end
					outline = flux.to_s + " " + format("%.2f", l1) + " " + format("%.2f", b1) + " " + spectralindex.to_s + " " + antype.to_s + " " + minsqrtTS.to_s + " " + name.to_s + " " + radioussearch.to_s + "\n";

					outl = outl + [outline];
					puts outline;
				end
				index = index + 1
			end
			af = File.new(filenameoutput, "w")
			outl.each do |line|
				af.write(line);
			end
			af.close();
		end

		def rewriteListResWithShift(filename, binsize)
			fout = File.new(filename.to_s + ".tmp", "w");
			index = 0;
			File.open(filename).each_line do |line|
				if index.to_i < 2
					fout.write(line)
					index = index + 1
					next
				end
				if line.split("'").size() > 2
					fout.write(line.lstrip)
					next
				end
				if line.split("#").size() > 2
					fout.write(line)
					next
				end
				if line.split("!").size() > 2
					fout.write(line)
					next
				end
				ll = line.split(" ");
				newb = ll[1].to_f + binsize.to_f
				outline = "\t" + ll[0].to_s + "\t" + newb.to_s + "\t" + ll[2].to_s + "\t" + ll[3].to_s + "\t" + ll[4].to_s + "\t" + ll[5].to_s + "\t" + ll[6].to_s + "\t" + ll[7].to_s + "\n";
				fout.write(outline)
				index = index + 1
			end
			fout.close()
			cmd = "mv " + filename.to_s + ".tmp " + filename.to_s
			puts cmd
			system(cmd) 
		end

		def rewriteMultiResWithShift(filename, binsize)
			fout = File.new(filename.to_s + ".tmp", "w");
			index = 0;
			File.open(filename).each_line do |line|
				if index.to_i < 2
					fout.write(line)
					index = index + 1
					next
				end
				if line.split("'").size() >= 2
					fout.write(line.lstrip)
					next
				end
				if line.split("#").size() >= 2
					fout.write(line)
					next
				end
				if line.split("!").size() >= 2
					fout.write(line)
					next
				end
				ll = line.split(" ");
				newb = ll[3].to_f + binsize.to_f
				name = ll[0].to_s;
				
				outline =  name + " " + format("%.2f", ll[1]) + " " + format("%.2f", ll[2]) + " " + format("%.2f", newb) + "\t" + ll[4].to_s + "\t" + ll[5].to_s + "\t" + ll[6].to_s + "\t" + ll[7].to_s + "\t" + ll[8].to_s + "\n";
				fout.write(outline)
				index = index + 1
			end
			fout.close()
			cmd = "mv " + filename.to_s + ".tmp " + filename.to_s
			puts cmd
			system(cmd) 
			Dir[filename.to_s + "*.con"].each do | file |
				cmd = "ruby " + ENV["AGILE"] + "/scripts/convertContourLevelsMulti.rb " + file.split(".con")[0].to_s + " " + binsize.to_s
				puts cmd
				system(cmd)
			end

		end

		def rewriteMultiResCorrectName(filename, filediagnostic, maxoffaxis)
			fout = File.new(filename.to_s + ".tmp", "w");
			fdiag = File.new(filediagnostic.to_s, "a");
			#outline = "filename\tNT source\tNT4-5\tNT>5\tmean sqrt(TS)\INDEX\n";
			#fdiag.write(outline);
			index = 0;
			llsize = 0;
			ntotsource0 = 0;
			ntotsource = 0;
			ntotsourcem3 = 0;
			ntotsource3 = 0;
			ntotsource4 = 0;
			ntotsource5 = 0;
			ntotts = 0;
			marker = "-"
			ntotmarker = 0;
			nnan = 0;
			File.open(filename).each_line do |line|
				puts filename.to_s + " " + line.to_s
				if index.to_i <= 3
					fout.write(line)
					index = index + 1
					next
				end
				if line.split("'").size() >= 2
					fout.write(line.lstrip)
					next
				end
				if line.split("#").size() >= 2
					fout.write(line)
					next
				end
				if line.split("!").size() >= 2
					fout.write(line)
					next
				end
				ll = line.split(" ");

				if ll[2].to_f > 360 || ll[2].to_f < 0 || ll[3].to_f > 90 || ll[3].to_f < -90  
					puts "WARNING " + line.to_s + "\t" + ll[2].to_s + "\t" + ll[3].to_s
					marker = "*"
					ntotmarker = ntotmarker + 1;
				end
				
				if ll[1] != "nan"
					newb = ll[3].to_f;
					name = ll[0]; #.split("_")[0];
					
					if ll.size() == 9
						dist = ll[8]
					else
						dist = 0;
					end
					puts "A " + index.to_s + " " + ll[1].to_s + " " + dist.to_s + " " + maxoffaxis.to_s
					if dist.to_f <= maxoffaxis.to_f and dist.to_f >= 0
						ntotsource = ntotsource + 1;
						puts "AAAAAAAAAAAAAA" + ll[1].to_s
						if ll[1].to_f <= 0.01
							ntotsource0 = ntotsource0 + 1
						end
						if ll[1].to_f > 0.01 and ll[1].to_f < 3.00 then
							ntotsourcem3 = ntotsourcem3 + 1
						end
						if ll[1].to_f >= 3.00 and ll[1].to_f < 3.99 then
							ntotsource3 = ntotsource3 + 1
						end
						if ll[1].to_f >= 3.99 and ll[1].to_f < 4.99 then
							ntotsource4 = ntotsource4 + 1
						end
						if ll[1].to_f >= 4.99  then
							ntotsource5 = ntotsource5 + 1
						end
						ntotts = ntotts + ll[1].to_f
					end
					
					
					outline =  name + "\t"  + format("%.3f", ll[1]) + "\t" + format("%.3f", ll[2]) + "\t" + format("%.3f", newb) + "\t" + ll[4].to_s + "\t" + ll[5].to_s + "\t" + ll[6].to_s + "\t" + ll[7].to_s + "\t" + ll[8].to_s + "\n";
					fout.write(outline)
				else
					puts "A NAN"
					nnan = nnan + 1
					outline = line.chomp + "\n";
					fout.write(outline)
				end
	
				
				index = index + 1
			end
			fout.close()
			
			cmd = "mv " + filename.to_s + ".tmp " + filename.to_s
			puts cmd
			system(cmd) 
			
			ntotsource = ntotsource 
			outline = filename.to_s + "\t\t" + marker.to_s + " (" + ntotmarker.to_s + ")\t" + nnan.to_s + " (nan)\t" + (ntotsource).to_s + " (<" + maxoffaxis.to_s + " deg)\t" + ntotsource0.to_s + " (=0)\t" + ntotsourcem3.to_s + " (<3)\t" + ntotsource3.to_s + " (3-4)\t" + ntotsource4.to_s + " (>4)\t" + ntotsource5.to_s + " (>5)\t" + format("%.2f", (ntotts.to_f / ntotsource.to_f)) + "\t" + (ntotsource4.to_i + ntotsource5.to_i).to_s + "\t" + format("%.2f", ((ntotts.to_f / ntotsource.to_f) * (ntotsource4.to_i + ntotsource5.to_i))) +  "\n"
			fdiag.write(outline);
			fdiag.close();
		end
end