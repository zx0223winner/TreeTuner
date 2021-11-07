# TreeTuner v1.0

# Copyright 2021 Zhang X., Hu Y., Eme L., Maruyama S.,Eveleigh R.JM, Curtis B.A., Sibbald S.J., Hopkins J.F., Filloramo1 G.V.,Wijk K.J.V., Archibald J.M.


#   This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from ete3 import Tree, TreeStyle, TextFace, NodeStyle
from collections import defaultdict

import sys
if len(sys.argv)!=3: #if the input arguments not 3, showing the usage.
	print("Please try this! Usage:python3 color_coarse_tuning_tree.py <taxonomic_info_file> <newick_tree_file> ")
	sys.exit()

color_map = {'Asgard group': '#00FF00',
			 'Candidatus Hydrothermarchaeota': '#32CD32',
			 'Candidatus Thermoplasmatota': '#006400',
			 'DPANN group': '#008000',
			 'Euryarchaeota': '#90EE90',
			 'TACK group': '#00FF7F',
			 'Archaea incertae sedis': '#ADFF2F',
			 'unclassified Archaea': '#2E8B57',
			 'Acidobacteria': '#00FFFF',
			 'Aquificae': '#00CED1',
			 'Atribacterota': '#40E0D0',
			 'Caldiserica/Cryosericota group': '#5F9EA0',
			 'Calditrichaeota': '#4682B4',
			 'Candidatus Krumholzibacteriota': '#6495ED',
			 'Chrysiogenetes': '#00BFFF',
			 'Coleospermum': '#1E90FF',
			 'Coprothermobacterota': '#191970',
			 'Deferribacteres': '#000080',
			 'Dictyoglomi': '#0000CD',
			 'Elusimicrobia': '#0000FF',
			 'FCB group': '#4169E1',
			 'Fusobacteria': '#8A2BE2',
			 'Myxococcota': '#4B0082',
			 'Nitrospinae/Tectomicrobia group': '#483D8B',
			 'Nitrospirae': '#6A5ACD',
			 'Proteobacteria': '#7B68EE',
			 'PVC group': '#9370DB',
			 'Spirochaetes': '#8B008B',
			 'Synergistetes': '#9400D3',
			 'Terrabacteria group': '#ADD8E6',
			 'Thermodesulfobacteria': '#B0E0E6',
			 'Thermotogae': '#BA55D3',
			 'Bacteria incertae sedis': '#800080',
			 'unclassified Bacteria': '#E0FFFF',
			 'Amoebozoa': '#800000',
			 'Ancyromonadida': '#8B0000',
			 'Apusozoa': '#A52A2A',
			 'Breviatea': '#B22222',
			 'CRuMs': '#DC143C',
			 'Cryptophyceae': '#eb67e6', # #FF0000
			 'Discoba': '#FF6347',
			 'Glaucocystophyceae': '#FF7F50',
			 'Haptista': '#CD5C5C',
			 'Hemimastigophora': '#F08080',
			 'Malawimonadida': '#E9967A',
			 'Metamonada': '#FFA07A',
			 'Opisthokonta': '#B8860B',
			 'Rhodelphea': '#FF8C00',
			 'Rhodophyta': '#FFA500',
			 'Sar': '#FFD700',
			 'Viridiplantae': '#FF0000', # #FF0000
			 'Eukaryota incertae sedis': '#DAA520',
			 'unclassified eukaryotes': '#EEE8AA',
			 'environmental samples': '#BDB76B'}


def draw(newick):
	taxa_dict = {}
	with open(sys.argv[1], 'r') as file:
		for line in file:
			if len(line.split('\t')) > 1:
				taxa_dict[line.split('\t')[0]] = line.split('\t')[1]
	t = Tree(newick, format=1)
	ts = TreeStyle()
	ts.show_leaf_name = False
	ts.mode = "c"
	# comment above line to forbidden circular tree
	#ts.show_branch_length = True
	nstyle = NodeStyle()
	nstyle["size"] = 0
	nstyle["fgcolor"] = "black"
	nstyle["hz_line_width"] = 2
	nstyle["vt_line_width"] = 2
	for n in t.traverse():
		n.set_style(nstyle)
	leaf_list = defaultdict(list)
	for leaf in t:
		leaf_list = myLayout(leaf, leaf_list, taxa_dict)
	t.show(tree_style=ts)
	t.render(newick + ".png", w=5000, tree_style=ts) #tree_style=ts


def myLayout(node, leaf_list, taxa_dict):
	if node.is_leaf():
		color = 'black'
		if node.name.split('.')[0] in taxa_dict.keys():
			taxa = taxa_dict[node.name.split('.')[0]].split('; ')[1]
			spieces = taxa_dict[node.name.split('.')[0]].split('; ')[-1]
			if taxa in color_map.keys():
				color = color_map[taxa]
			node.add_face(TextFace(node.name + "_" + spieces, fgcolor=color), column=0)
		else:
			node.add_face(TextFace(node.name, fgcolor=color), column=0)
	# if node.is_leaf():
	# 	specie_name = node.name.split('@')[0].replace('_', ' ')
	# 	if 'undescribed' in specie_name or 'Unidentified' in specie_name or 'non' in specie_name:
	# 		node.detach()
	# 	elif specie_name in leaf_list.keys() and node.up in leaf_list[specie_name]:
	# 		node.detach()
	# 	else:
	# 		leaf_list[specie_name].append(node.up)
	# 		gene_name = '_'.join(node.name.split('@')[1].split('_')[:2])
	# 		color = 'black'
	# 		if specie_name.split('.')[0] in taxa_dict.keys():
	# 			taxa = taxa_dict[specie_name.split('.')[0]].split('; ')[1]
	# 			if taxa in color_map.keys():
	# 				color = color_map[taxa]
	# 		taxa = node.name.split('@')[1].split('_')[3]
	# 		taxa2 = node.name.split('@')[1].split('_')[3] + ' ' + node.name.split('@')[1].split('_')[4]
	# 		if taxa in color_map.keys():
	# 			color = color_map[taxa]
	# 		elif taxa2 in color_map.keys():
	# 			color = color_map[taxa2]
	# 		node.add_face(TextFace(specie_name + ' ' + gene_name, fgcolor=color), column=0)
	return leaf_list


if __name__ == '__main__':
	draw(sys.argv[2])





# ts.show_branch_support = True
# a = t & "aaa"
# a.add_face(AttrFace("name", fgcolor="green"), column=0, position="branch-top")
# style = NodeStyle()
# style["fgcolor"] = "#ff0000"
# style["size"] = 0
# style["vt_line_color"] = "#ff0000"
# style["hz_line_color"] = "#ff0000"
# style["vt_line_type"] = 0
# style["hz_line_type"] = 0
# setChildrenStyle(a, style)
#
# b = t & "abc"
# b.set_style(NodeStyle())
# b.img_style["bgcolor"] = "indianred"



# def setChildrenStyle(node, style):
#     node.set_style(style)
#     if not node.is_leaf():
#          for n in node.children:
#              setChildrenStyle(n, style)
