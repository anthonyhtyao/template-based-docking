import sys
import filedownload
import requests
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException


'''
This file contains the function that requests an alignment between two
PDB files in InterEvolAlign.
The central function is runAlign and is still in progress : it is not fully
automatic and for the moment, there is no way for the user to tinker the
parameters of the alignment or extract other informations that the PDB files
of the resulting interologs.
For the moment, the __main__ requires three arguments :
    - dir1 : the directory containing the PDB files of the subunits
    - dir2 : the directory containing the FASTA sequences
    - dir3 : the directory containing the PDB files of the interologs
    - receptor : the filename of the receptor
    - ligand : the filename of the ligand

!! CAUTION !!
For the moment, the runAlign function is not temporized to not send a request
to the InterEvol website will one is already running, and it could be possible to send
with some modifications many requests at once to the website : do not do that or you'll risk IP-ban
from the website. Only use runAlign do to a request at once.
!! CAUTION !!
'''
    
def runAlign(file1,file2):
    """
    Send a alignment request to the InterEvol database
    input : two FASTA files
    output : a dictionnary with the keys corresponding to the interologs
    and the values corresponding to the sequence identities of the ligand
    and the receptor
    """
    
    url = "http://biodev.cea.fr/interevol/interevalign.aspx"
    
    """
    Firstly, writes the content of the FASTA file in two variables fasta1 and fasta2
    """
    with open(file1, 'r') as content_file:
        fasta1 = content_file.read()
    with open(file2, 'r') as content_file:
        fasta2 = content_file.read()
    
    """
    Creates a webdriver object named browser to open the website
    Notes that with part of the script requires the installation of geckodriver
    Latest releases of geckodriver : https://github.com/mozilla/geckodriver/releases
    On Unix system, extract the executable to /usr/bin
    Then make geckodriver executable with chmod +x geckodriver
    If you run into an error with geckodriver, an easy fix is to retrograde your selenium version
    For that, simply use the command "pip install selenium==2.53.6
    """
    browser = webdriver.Firefox()
    browser.implicitly_wait(5)
    browser.get(url)
    
    """
    Fills the HTML forms of interests, mainly :
        - 'seqReceptor' textarea with the FASTA sequence contained in fasta1
        - 'seqLigand' textarea with the FASTA sequence contained in fasta2
        - Submit the job by clicking on the "Submit" button
    """
    browser.find_element_by_id('seqReceptor').send_keys(fasta1) 
    browser.find_element_by_id('seqLigand').send_keys(fasta2)
    browser.find_element_by_id('btnRun').click() 
    
    
    delay = 1200 #in seconds
    print("Starting alignment")
    
    try:
        WebDriverWait(browser, delay).until(EC.title_is('InterEvolAlign results page'))
        #The browser will wait the delay or until the results page appears before anymore script is run
        print("Page is ready!") #If the page appears, the rest of the script is run
    except TimeoutException:
        print("Loading took too much time!")
        browser.quit()
        return #Otherwise, the function is stopped
    
    browser.implicitly_wait(5)
    
    """
    Looks for a href tag in the source code with "interid" (interology)
    """
    interolog = "interid"  
    InterologList = browser.find_elements_by_xpath('//a[contains(@href, "%s")]' % interolog)        
    PDBid=list()
    rchain=list()
    result = {}                
    
    """
    Extract the four letter PDB id of interelog domains
    """
    for element in InterologList:
        e=element.text
        r = e[5:-1]
        print(e,r)
        PDBid.append(e)
        rchain.append(r)
    
    """
    First step is to find the table containing the interologs
    """
    table_id = browser.find_element_by_id('GridView3')
    rows = table_id.find_elements_by_tag_name("tr") # get all of the rows in the table
    rows.pop(0)
    
    """
    The next step is to extract the identity percentages    
    """
    Idllist=list()
    Idrlist=list()
    
    for row in rows:
        #Get the columns      
        coll = row.find_elements_by_tag_name("td")[2] #note: index start from 0, 1 is col 2
        colr = row.find_elements_by_tag_name("td")[3]
        #prints text from the element
        print((coll.text))
        print((colr.text))
        Idllist.append(coll.text)
        Idrlist.append(colr.text)
    
    """
    The interologs and the identity percentages are stored in a dictionnary
    The keys correspond to the interologs PDB ID
    The values of each keys is a list containing the identity percentages
    If the identity with of the receptor and the ligand is 100%, it means that
    the complex already exists
    Therefore, the interolog is not downloaded and the PDB id is removed from the PDBid list
    """
    
    j=-1
    for i in xrange(0,len(Idllist)):
        j=j+1
        if((Idllist[i] == "100%") and (Idrlist[i] == "100%")):
            print("The complex seems to have already been caracterized !")
            del PDBid[i]
            j=i-1
        else:
            result[PDBid[j]]=[Idllist[i],Idrlist[i],rchain[i]]
        
    print(PDBid)    
    print(result)

    """
    Downloads the PDB file of interologs from InterEvol
    """
    for element in PDBid:
        url = "http://biodev.cea.fr/interevol/interevol.aspx?interid="+element+"#footer"
        browser.get(url)
        print(browser.current_url)
        browser.implicitly_wait(5)
        url = browser.find_element_by_id("downloadAlignment")
        print(url)
        url = url.get_attribute("href")
        print(url)
        r = requests.get(url)
        with open(interDirectory+element[:4]+".pdb", "wb") as code:
            code.write(r.content)
        
    print("Finished downloading")
    print((browser.current_url))
        
if __name__ == '__main__':
    print("Begin")
    try:
        #The directory containing the PDB files of the subunits
        subunitsDirectory = sys.argv[sys.argv.index("-dir1")+1]
        #The directory where the FASTA sequences will be stored
        fastaDirectory = sys.argv[sys.argv.index("-dir2")+1]
        #The directory where the PDB files of the interologs will be stored
        interDirectory = sys.argv[sys.argv.index("-dir3")+1]
                
    except:    
        print("ERROR: please enter the names of the directories\n")
        sys.exit()
        
    try:
        #The name of the PDB file of the receptor
        ligand = sys.argv[sys.argv.index("-receptor")+1]
        #The name of the PDB file of the ligand
        receptor = sys.argv[sys.argv.index("-ligand")+1]
    except:
        print("ERROR : specified file does not exist\n")
        sys.exit()
        
    
    print("Creating FASTA sequence")
    ligf = filedownload.FASTAfromPDB(ligand, subunitsDirectory, fastaDirectory)
    recf = filedownload.FASTAfromPDB(receptor, subunitsDirectory, fastaDirectory)
    
    print("Alignment function")
    dico = runAlign(recf,ligf)
    
