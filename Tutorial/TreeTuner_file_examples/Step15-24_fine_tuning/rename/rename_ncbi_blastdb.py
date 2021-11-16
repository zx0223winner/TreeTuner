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

from collections import defaultdict
from ete3 import NCBITaxa
# from eutils import Client

import sys
if len(sys.argv)!=4: #if the input arguments not 4, showing the usage.
	print("Please try this! Usage:python3 rename_ncbi_blastdb.py <FASTA File> <Taxon Id FILE> <Renamed FASTA File> ")

class FastaOutput:
	def __init__(self):
		self.taxID = -1
		self.specieName = ""
		self.seq = ""


def loadFastaData(fastaFile, taxidFile):
#     # Read from blast file
#     geneDict = defaultdict(list)  # Dictionary to store demanded genes and their blast result gene names
#     print("Reading from " + blastFile + " ...")
#     with open(blastFile, 'r') as blastFilehandler:
#         for line in blastFilehandler:
#             lineItems = line.split("\t")
#             if len(lineItems) > 1 and lineItems[0] in geneList:
#                 try:
#                     refName = lineItems[1].split('|')[1]
#                     geneDict[lineItems[0]].append(refName)
#                 except IndexError:
#                     print("incorrect gene name format in blast file" + line)
#                     continue
    # Get the list of genes which need to be renamed
#     geneListToRename = []
#     for key in geneDict.keys():
#         geneDict[key] = list(set(geneDict[key]))
#         geneListToRename = geneListToRename + geneDict[key]
#     geneListToRename = list(set(geneListToRename))  # To make list items unique
    # Read from fasta file
	fastaDict = {}
	geneList = []
#     found = 0
	print("Loading Fasta Data from " + fastaFile + " ...")
	with open(fastaFile, 'r') as fastaFileHandler:
		for line in fastaFileHandler:
			if line.startswith('>'):
				line = line.strip().strip('>')
#                 inList = False
				try:
					geneName = line.split(' ')[0]
					if '[' in line:
						specieName = line.split('[')[1].split(']')[0]
					else:
						specieName = '_'.join(line.split(' ')[1:])
					specieName = specieName.replace(' ', '_')
				except IndexError:
					print("'" + line + "': incorrect gene name format in fasta file.")
					continue
#                 if geneName in geneListToRename:
#                     inList = True
#                     found += 1
#                     print(str(found) + '/' + str(len(geneListToRename)))
				fastaDict[geneName] = FastaOutput()
				fastaDict[geneName].specieName = specieName
				geneList.append(geneName)
			else:
				fastaDict[geneName].seq += line
    # Read from taxid file
	print("Reading taxid from " + taxidFile + " ...")
	with open(taxidFile, 'r') as taxidFileHandler:
		for line in taxidFileHandler:
			lineItems = line.split('\t')
			if len(lineItems) == 4:
				geneNameItem = lineItems[1]
				taxidItem = lineItems[2]
				if geneNameItem in fastaDict.keys():
					try:
						fastaDict[geneNameItem].taxID = int(taxidItem)
					except ValueError:
						print("The '" + taxidItem + "' is not a NCBI taxid. (taxid must be a number)")
						continue
	return fastaDict, geneList


def renameSequence(fastaFile, fastaDict, geneList):
	ncbi = NCBITaxa()
	# Upgrade NCBI local database
	# Uncomment the two lines blow to upgrade your ncbi taxa database
	print("Upgrading NCBI local database...")
	ncbi.update_taxonomy_database()
	print("Renaming fasta file...")
	with open(sys.argv[3], 'w') as outFileHandler:
		for gene in geneList:
#         print("\n\nRenaming fasta file for '" + key + "' ...")
			renamedFastaResult = ""
#         with open('fastaNotFind_' + key + '.txt', 'w') as errorLog:
#         	for gene in geneDict[key]:
#                 if gene not in fastaDict.keys():
#                     errorLog.write(gene+'\n')
#                     print("Cannot find fasta sequence for gene '" + gene + "'.")
#                     continue
			if not fastaDict[gene].taxID == -1:
				ncbiID = fastaDict[gene].taxID
			else:
				print("Cannot find taxid for gene " + gene)
				continue
			try:
				# Extract tax information using taxid
				lineage = ncbi.get_lineage(ncbiID)
				names = ncbi.get_taxid_translator(lineage)
				taxNames = [names[taxid].replace(' ', '_') for taxid in lineage]
				newName = fastaDict[gene].specieName + '@' + 'NCBI' + '_' + gene + '_' + '_'.join(taxNames[2:]) + '_' + str(fastaDict[gene].taxID)
			except (IndexError, ValueError):
				print(str(ncbiID) + " taxid not found in NCBI database")
			renamedFastaResult += '>' + newName + '\n' + fastaDict[gene].seq
			outFileHandler.write(renamedFastaResult)



if __name__ == '__main__':
	fastaFile = sys.argv[1]
	taxidFile = sys.argv[2]
	fastaDict, geneList = loadFastaData(fastaFile, taxidFile)
	renameSequence(fastaFile, fastaDict, geneList)
