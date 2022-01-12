#!/usr/bin/env ruby
# 
# ver.v2.5.1
#
# [ Reference ]
# Shinichiro Maruyama / Robert J. M. Eveleigh / John M. Archibald
# TreeTrimmer: a method for phylogenetic dataset size reduction. BMC Research Notes 2013, 6:145.

# usage
usage = " Usage: #{__FILE__} [Newick_tree_file] [Parameter_input_file] [Taxonomic_information_file (option)] > output_file"
if ARGV[1] == nil; STDERR.puts "", usage, ""; Process.exit; end

require 'bio'

class Bio::Tree
	def median_node(nodes_ary, base_node)
		dist_ary = []
		dist_ary = nodes_ary.dup.map{|each_node| self.distance(each_node, base_node)}
		med_len = dist_ary.dup.sort[(dist_ary.size/2.0).ceil - 1]
		med_pos = dist_ary.index(med_len)
		nodes_ary[med_pos]
	end
end

### Setting parameters
cutoff = 0.0
num_retained = 2
unflagable_taxa = Array.new
taxa_hash = Hash.new
annotated_hash = Hash.new

query_tag = "QUERY"
query_leaf = Bio::Tree::Node.new
taxon_delimiter = ";\s"

open(ARGV[1]) do |param|
	param.each_line.each do |line|
		line.chomp!
		line = line.split(/#/)[0] if line =~ /#/

		next if line =~ /^\s*$/
		if line =~ /cutoff=/
			cutoff = line.split("cutoff=")[1].gsub(/\s*/,"").to_f
		elsif line =~ /query_tag=/
			query_tag = line.split("query_tag=")[1]
		elsif line =~ /taxon_delimiter=/
			taxon_delimiter = line.split("taxon_delimiter=")[1]
		elsif line =~ /num_retained=/
			num_retained = line.split("num_retained=")[1].gsub(/\s*/,"").to_i
		else
			ary = Array.new
			ary = line.split(/\t/)
			if ary.size < 2
				STDERR.print "\n",
				" Invalid delimiter in Parameter input file:",
				" You can only use TAB field seperator to specify which taxa should be pruned.",
				"\n\n"
				Process.exit
			end

			taxa_hash.store( ary[0].gsub(/_/," "), ary[1].to_i )

			if ary[1].to_s.upcase == "ALL"
				unflagable_taxa.push ary[0].gsub(/_/," ")
			elsif ary[1].to_i > num_retained
				if ary[2] == nil
					annotated_hash.store( ary[0].gsub(/_/," "), [ ary[1].to_i ] )
				else
					annotated_hash.store( ary[0].gsub(/_/," "), [ ary[1].to_i, ary[2].gsub(/_/," ") ] )
				end
			end
		end
	end
end

### Taxonomy information
open(ARGV[0]) do |input_newick|
	tree = Bio::Newick.new(input_newick.read).tree

	id_coord_taxa = Hash.new
	if ARGV[2] == nil
		tree.dup.leaves.join("\t").split("\t").map do |each_otu|
			id_coord_taxa.store each_otu, each_otu
		end
	else		
		open(ARGV[2]) do |tax_list|
			tax_list.each_line do |line|
				id_coord_taxa.store line.chomp.split("\t")[0].gsub(/_/,"\s"), line.chomp.split("\t")[1]
			end
		end
	end

### Tree parsing
# 1. Flag all OTUs in sub-trees supported with SH supports above threshold
	supported = Array.new

	tree.each_node do |node|
		begin
			if tree.get_node_bootstrap(node).to_f >= cutoff
				supported.push node
			end
		rescue => ex
			STDERR.print "\t", ex.class, ": ", ex.message, ": ", ARGV[1], "\n"
			Process.exit
		end
	end

# 2. Examine OTUs within highly supported sub-trees: same taxonomic category or multiple categories?
# 2.1. Flag all OTUs in a clade
	mono_hash = Hash.new
	base_ary = Array.new
	query_flag = 0
	
	supported.each do |e|
		leaves = Array.new
		leaf_names = Array.new
					
		leaves = tree.leaves(e)
		if leaves.size > num_retained
			leaves.dup.join(",").split(/,/).each do |leaf|

				# 2.2. Tag query if present in this clade
				if leaf =~ /#{query_tag}/
					if query_flag == 0
						query_leaf = tree.get_node_by_name(leaf)
						query_flag += 1
					end
				end

				# 2.3. Collect leaf names
				if id_coord_taxa[leaf] =~ /#{taxa_hash.keys.join("|")}/
					taxa_hash.each_key do |thk|
						if id_coord_taxa[leaf] =~ /#{thk}/
							leaf_names.push thk
							break
						end
					end
				else
					leaf_name = leaf.split('.')[0]
					if id_coord_taxa.key?(leaf_name)
							leaf_names.push id_coord_taxa[leaf_name].split(taxon_delimiter)[-1]
					else
						leaves.delete(leaf)
						print leaf+"\n"
					end
				end
			end
			
			# 2.4. Collect leaves of a clade containing a single taxonomic category; but de-flag and ignore [unflagable_taxa] 
			if leaf_names.uniq.size == 1
				unless (leaf_names.uniq - unflagable_taxa).empty?
					unless base_ary.include? e
						mono_hash.store(leaves, e) 
						base_ary.push e
					end
				end
			end
		end
	end

# 3. From each sub-tree, scale back to the largest sub-tree containing OTUs of the same taxonomic category
	keys = mono_hash.keys
	smaller = Array.new
	
	keys.each do |x|
		keys.each do |y|
			smaller.push x if x != y && (x - y).empty?
		end
	end
	smaller.uniq.each do |z|
		mono_hash.delete(z)
	end

# 4. Determine the branch lengths of all leaves in the subtrees and determine the median branch length
	redund_leaves = Array.new
	deflag_hash = Hash.new

	mono_hash.each do |k,v|
		deflag_ary = Array.new
		num_deflag = num_retained

# 4.1. Keep one [annotated] OTU with median branch length among all the [annotated] OTUs
		annotated_hash.each_key do |anogen|
			if id_coord_taxa[k[0].to_s] =~ /#{anogen}/
				annotated = Array.new		
				k.each do |ee|
					annotated.push ee if id_coord_taxa[ee.to_s] =~ /#{annotated_hash[anogen][1]}/
				end
				if annotated.size > 0
					deflag_ary.push k.delete(tree.median_node(annotated, v))
				end
				num_deflag = annotated_hash[anogen][0] - deflag_ary.size
			end
		end		

# 4.2. Keep [num_deflag] OTUs with median branch lengths among all OTUs		
		num_deflag.times do
			if k.size > 0
				deflag_ary.push k.delete(tree.median_node(k, v))
			end
		end
		
# 4.3. Retain query OTU
		if ([query_leaf] - k).empty?
			k.push deflag_ary.pop
			deflag_ary.push k.delete(query_leaf)
		end
		
# 4.4. Collect flagged OTUs to be removed
		deflag_hash.store(deflag_ary, [deflag_ary.size, k.size])
		redund_leaves = redund_leaves + k
	end
	redund_leaves.uniq

# 5. De-replicate each subtree
	tree.each_node do |z|
		if redund_leaves.include? z
			tree.remove_node(z) 
			tree.remove_nonsense_nodes
		end
	end
	
# 6. Output

###  Label OTU names with the numbers of retained and total OTUs in the original tree
	flat_hash = Hash.new
	deflag_hash.each_pair do |a,b|
		a.each do |c|
			flat_hash.store(c.to_s, b)
		end
	end

	puts tree.leaves.join(",").split(/,/).map{|z| 
		z_name = z.split('.')[0]
		if id_coord_taxa.key?(z_name)
			if flat_hash.key? z
				num_retained = String.new
				num_total = String.new
				num_retained = flat_hash[z][0].to_s
				num_total = (flat_hash[z][0] + flat_hash[z][1]).to_s
				if flat_hash[z][1] > 0
					z = z.gsub(/\s/,"_") + "\t" + id_coord_taxa[z_name] + "\t" + num_retained + "\t" + num_total
				else
					z.gsub(/\s/,"_") + "\t" + id_coord_taxa[z_name]
				end
			else
				z.gsub(/\s/,"_") + "\t" + id_coord_taxa[z_name]
			end
		else
			z.gsub(/\s/,"_")
		end
	}.sort


###	Output newick format tree
	open("#{File.basename(ARGV[0])}__#{File.basename(ARGV[1])}.tt#{cutoff}.tre", "w") do |out_tre|
		if tree.output_newick.to_s == "(\n);\n"
			out_tre.write tree.subtree(tree.nodes).output_newick(:bootstrap_style => :disabled)
		else
			out_tre.write tree.output_newick(:bootstrap_style => :disabled)
		end
	end
end
