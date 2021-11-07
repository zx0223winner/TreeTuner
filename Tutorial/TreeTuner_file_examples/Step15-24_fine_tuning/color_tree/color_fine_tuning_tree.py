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

import sys
if len(sys.argv)!=2: #if the input arguments not 2, showing the usage.
	print("Please try this! Usage:python3 color_fine_tuning_tree.py <newick_tree_file> ")
	sys.exit()
	
def draw(newick):
	t = Tree(newick, format=1)
	ts = TreeStyle()
	ts.show_leaf_name = False
	ts.show_branch_length = True
	nstyle = NodeStyle()
	nstyle["size"] = 0
	nstyle["fgcolor"] = "black"
	nstyle["hz_line_width"] = 1
	nstyle["vt_line_width"] = 1
	for n in t.traverse():
		n.set_style(nstyle)
	for leaf in t:
		myLayout(leaf)
	t.show(tree_style=ts)
	t.render(newick + ".png", w=5000, tree_style=ts)


def myLayout(node):
	color_map = {'Asgard group': '#00FF00',#Asgard group
			 'Candidatus Hydrothermarchaeota': '#32CD32',#Candidatus Hydrothermarchaeota
			 'Candidatus Thermoplasmatota': '#006400',#Candidatus Thermoplasmatota
			 'DPANN group': '#008000',#DPANN group
			 'Euryarchaeota': '#90EE90',
			 'TACK group': '#00FF7F',#TACK group
			 'Archaea incertae sedis': '#ADFF2F',
			 'unclassified Archaea': '#2E8B57',
			 'Acidobacteria': '#00FFFF',
			 'Aquificae': '#00CED1',
			 'Atribacterota': '#40E0D0',
			 'Caldiserica/Cryosericota group': '#5F9EA0',
			 'Calditrichaeota': '#4682B4',
			 'Candidatus Krumholzibacteriota': '#6495ED',#Candidatus Krumholzibacteriota
			 'Chrysiogenetes': '#00BFFF',
			 'Coleospermum': '#1E90FF',
			 'Coprothermobacterota': '#191970',
			 'Deferribacteres': '#000080',
			 'Dictyoglomi': '#0000CD',
			 'Elusimicrobia': '#0000FF',
			 'FCB group': '#4169E1',#FCB_group
			 'Fusobacteria': '#8A2BE2',
			 'Myxococcota': '#4B0082',
			 'Nitrospinae/Tectomicrobia group': '#483D8B',
			 'Nitrospirae': '#6A5ACD',
			 'Proteobacteria': '#7B68EE',
			 'PVC group': '#9370DB',#PVC group
			 'Spirochaetes': '#8B008B',
			 'Synergistetes': '#9400D3',
			 'Terrabacteria group': '#ADD8E6',#Terrabacteria_group
			 'Thermodesulfobacteria': '#B0E0E6',
			 'Thermotogae': '#BA55D3',
			 'Bacteria incertae sedis': '#800080',
			 'unclassified Bacteria': '#BDB76B', #BDB76B
			 'Amoebozoa': '#800000',
			 'Ancyromonadida': '#8B0000',
			 'Apusozoa': '#A52A2A',
			 'Breviatea': '#B22222',
			 'CRuMs': '#DC143C',
			 'Cryptophyceae': '#eb67e6',
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
			 'Viridiplantae': '#FF4500',
			 'Eukaryota incertae sedis': '#DAA520',
			 'unclassified eukaryotes': '#EEE8AA',
			 'environmental samples': '#E0FFFF'}
	if node.is_leaf():
		try:
			specie_name = node.name.split('@')[0].replace('_', ' ')
			name_items = node.name.split('@')[1].split('_')
			split_point = 3
			for i in range(len(name_items)):
				if name_items[i] in ['Eukaryota', 'Bacteria', 'Archaea']:
					split_point = i
			gene_name = '_'.join(node.name.split('@')[1].split('_')[:split_point])
			taxa = node.name.split('@')[1].split('_')[split_point+1]
			taxa2 = node.name.split('@')[1].split('_')[split_point+1] + ' ' + node.name.split('@')[1].split('_')[split_point+2]
			color = 'black'
			if taxa in color_map.keys():
				color = color_map[taxa]
			elif taxa2 in color_map.keys():
				color = color_map[taxa2]
			node.add_face(TextFace(specie_name + ' ' + gene_name, fgcolor=color), column=0)
		except IndexError:
			print(node.name)


if __name__ == '__main__':
	draw(sys.argv[1])

