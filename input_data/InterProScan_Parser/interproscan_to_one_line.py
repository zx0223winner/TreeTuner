import sys

if len(sys.argv)!=4: #if the input arguments not 4, showing the usage.
        print(" Usage: python3 Pfam_to_one_line.py <inputfile.interproscan.tsv> <output file> <parameter: i.e., Pfam>")
        sys.exit()

class gggg:
	def __init__(self, a, b, c, d):
		self.a = a
		self.b = b
		self.c = c
		self.d = d
# 		self.e = e
# 		self.f = f
		#self.g = g

handle=open(sys.argv[1],'r')
all_list = []
for line in handle:
	line = line.strip('\n')
	items = line.split('\t')
	if items[3] == sys.argv[3]:
		all_list.append(gggg(items[0],items[3],items[4],items[5]))

# output_list = []
# for i in range(len(all_list)-1):
# 	j = i+1
# 	if all_list[i].a == all_list[j].a:
# 		if all_list[i].c == all_list[j].c:
# 			all_list[i].a = ""
# 	if all_list[i].a != "":
# 		output_list.append(all_list[i])

for i in range(len(all_list)-1):
	j = i+1
	if all_list[i].a != "" and all_list[i].a == all_list[j].a:
		all_list[j].b = all_list[i].b+','+all_list[j].b
		all_list[j].c = all_list[i].c+','+all_list[j].c
		all_list[j].d = all_list[i].d+','+all_list[j].d
	# 	output_list[j].e = output_list[i].e+','+output_list[j].e
# 		output_list[j].f = output_list[i].f+','+output_list[j].f
		#output_list[j].g = output_list[i].g+','+output_list[j].g
		all_list[i].a = ""

outfile = open(sys.argv[2],'w') #'Pfam_one_line_draft'
for item in all_list:
	if item.a != "":
		outfile.write(item.a+'\t'+item.c+'\t'+item.d)
		outfile.write('\n')






